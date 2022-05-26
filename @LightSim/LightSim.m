classdef LightSim < handle
    % Find relationship between 1024-column control and ouput spectra of OL490

    properties

        col_wl_amp_spec    % store final data; dark removed
        spec_dark         % when all column are off (zero); needed for finding linearity

        spec_1024
    end

    properties (Constant)

        % the data files are stored in the class folder

        classpath = fileparts(which('LightSim'));
    end

    methods

        function obj = LightSim

            % examine a "peak1col_??.mat file
            % to compare the expected peak and measured peak
            % ?? means expected wavelength [400+?? : 50 : 750] nm
            % for exmaple: 00 means [400:50:750], 10 means [410:50:750]

            %
            % get dark
            %
            datapath = sprintf('%s/%s',LightSim.classpath,'dark.mat');
            load(datapath,'s_dark');
            obj.spec_dark = s_dark;

            % data stored
            col_wl_amp_spec_all = [];

            %for wl_offset = 00:10:40


            for wl_offset = 0:1:49

                % retrieve the data file
                datapath = sprintf('%s/%s_%02d',LightSim.classpath,'peak1col',wl_offset);
                load(datapath,'s','wl_target','col_range');

                % analyze the spectrum
                spec_no_dark = s.amplitude-s_dark.amplitude;
                peaks = LightSim.find_spikes(wl_target,spec_no_dark);

                % consolidate data
                col = col_range';
                %wl = peaks(:,1);
                %amp = peaks(:,2);
                %spec = peaks(:,3:end);

                col_wl_amp_spec = [col peaks];
                col_wl_amp_spec_all = [col_wl_amp_spec_all ; col_wl_amp_spec];

                if 0
                    %
                    % report
                    %
                    datapath

                    %
                    % visualize
                    %
                    clf
                    s.plot

                    % mark the target wavelength
                    for i = 1:length(wl_target)
                        x = wl_target(i);
                        xline(x,'b')
                    end

                    % mark the measured wavelength
                    for i = 1:length(wl_target)
                        x = peaks(i,1);
                        xline(x,'r:')
                    end
                end
            end

            %
            % condition the data to remove same wavelengths generated by different columns
            %

            % sort by column first
            col_wl_amp_spec_all = sortrows(col_wl_amp_spec_all);

            % retrieve the wl column
            wl = col_wl_amp_spec_all(:,2);

            %
            % remove wl < 400 nm
            %
            wl_mask = (wl >= 400);
            col_wl_amp_spec_all = col_wl_amp_spec_all(wl_mask,:);

            %
            % remove col-duplicated rows
            %

            % retrieve the col column
            col = col_wl_amp_spec_all(:,1);

            % get unique col
            [C,ia,ic] = unique(col);

            col_wl_amp_spec_all = col_wl_amp_spec_all(ia,:);


            %
            % remove wl-duplicated rows
            %

            % retrieve the wl column
            wl = col_wl_amp_spec_all(:,2);

            % get unique wl
            [C,ia,ic] = unique(wl);

            col_wl_amp_spec_all = col_wl_amp_spec_all(ia,:);

            obj.col_wl_amp_spec = col_wl_amp_spec_all;


            obj.col_spec_model

        end

        function check_data (obj)
            spec_all = obj.col_wl_amp_spec(:,4:end);

            mesh(spec_all)
            xlabel('Wavelength Order')
            ylabel('Column')
            title('Spectra')
            view([64.1830986 49.8000002])
        end

        function sout = col_spec_model (obj)
            spec_302 = obj.col_wl_amp_spec(:,4:end);

            col_measured = obj.col_wl_amp_spec(:,1);

            spec_1024 = zeros(1024,401);

            ol490_wl_range = 380:780;

            for w = 1:401
                spec_measured = spec_302(:,w);
                %
                % use "linear" to interpolate between measured datapoints
                % use "extrap" to extend to both sides
                %
                spec_predict = interp1(col_measured,spec_measured,1:1024,'linear','extrap');
                spec_1024(:,w) = spec_predict';
            end

            %
            % remove anything outside wavelength 400:750
            %
            spec_1024(:,1:19) = 0;
            spec_1024(:,end-29:end) = 0;

            %
            % remove anything outside columns measured
            %
            spec_1024(1:col_measured(1),:) = 0;
            spec_1024(col_measured(end):end,:) = 0;

            %
            % conditioning
            %
            near_zero = 0.00000001;
            for i = 1:1024
                s = spec_1024(i,:);

                % get the peak
                [peak_y peak_x] = max(s);

                % remove tiny signals
                m = s < (peak_y * 0.05);
                s(m) = near_zero;

                % remove out-of-band signals for near UV and IR
                % bandwidth are mostly 18, 19, and 20
                x_grid = 1:401;
                m = abs(x_grid - peak_x) > 25/2;
                s(m) = near_zero;

                spec_1024(i,:) = s;
            end

            obj.spec_1024 = spec_1024;

        end

        function sout = predict_vec_spec (obj, vec)
            % vec: 1x1024
            % sout: OL490 spectrum

            assert(length(vec)==1024);

            spec_vec = obj.spec_1024';
            sout = spec_vec * vec + obj.spec_dark.amplitude';
            return

            %             sout = zeros(1,401);
            %             for v = 1:length(vec)
            %                 v_i = vec(v);
            %                 spec_i = obj.spec_1024(v,:);
            %                 sout = sout + spec_i .* v_i;
            %             end
            %
            %             % add dark
            %             sout = sout + obj.spec_dark.amplitude;

        end
    end

    methods (Static)

        %
        % find the peak of a single spike in a spectrum
        %
        function [x y z] = find_spike (wl_tar, spec)

            % spec is 1x401 from OL490 output

            %
            % convert to 780x1 as absolute wavelength
            %
            t2 = zeros(780,1);
            t2(380:780,1) = spec';

            % create a mask to isolate the current peak
            % the spikes are 50 nm apart, so use width=25
            x_axis = 1:780;
            width = 25;
            mask = (x_axis < wl_tar-width) | (x_axis > wl_tar+width);
            t3 = t2;
            t3(mask) = 0;

            % calculate CDF
            t4 = cumsum(t3);

            % normalize
            t5 = t4 / max(t4);

            % find the mid point, defined as 50%, by linear search
            i = 1;
            while i <= length(t5) && t5(i) < 0.5
                i = i + 1;
            end

            % return values
            x = i;
            y = t3(i);
            z = t3(380:780);  % in OL490 form
        end

        %
        % find the peaks of 8 spikes in a spectrum
        %
        function peaks = find_spikes (wl_target, spec)

            % spec is 1x401

            %
            % convert to 780x1
            %

            n = length(wl_target);
            for i = 1:n

                % the target wavelength
                wl_tar = wl_target(i);

                [x y z] = LightSim.find_spike(wl_tar,spec);

                peaks(i,1) = x;
                peaks(i,2) = y;
                peaks(i,3:3+400) = z;

            end

        end

        function col_predict = wl_column_interpolate (wl,col,wl_target)
            %
            % predict column between 1 and 1024 by the look-up table
            %
            col_predict = round(interp1(wl,col,wl_target,'spline','extrap'));
            col_predict = min(col_predict,1024);
            col_predict = max(col_predict,1);

        end

        function vout = multiple_peaks (col_range)
            %
            % generate a column vector using the column numbers
            %
            v_max = 1;              % max intensity
            col_width = 0;          % width: only one column

            vout = zeros(1024,1);
            for i = 1:length(col_range)
                col = col_range(i);
                assert((col >= 1) && (col <= 1024));
                vout = LightSim.add_a_peak(vout,col,col_width,v_max);
            end

        end

        function vout = add_a_peak (vin, col, width, amp)
            %
            % turn on one more column (+/- width) in the given vector
            %
            vout = vin;

            col_start = col-width;
            col_stop = col+width;
            %
            % check range
            %
            col_start = max(1,col_start);
            col_stop = min(1024,col_stop);

            %
            % set the columns
            %
            vout(col_start:col_stop,1) = amp;

        end

    end

end

