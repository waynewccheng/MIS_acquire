classdef OL490Class1Column < handle
    %OL490Class1Column Find relationship between 1024-column control and ouput spectra of OL490

    properties
        %
        % columns used to mypeakmeasure
        %
        col_range = [37,49,70,96,124,152,179,202,231,238,301,306,330,355,380,405,432,457,483,505,533,556,583,608,633,658,682,708,734,760,780,810,834,857,886,905,933,956,976,1035,1120]';

        spec_dark         % when all column are off (zero); needed for finding linearity
        spec_all = zeros(41,401)  % store final data; dark removed
        wl_target
        wl_measured

        col_wl_amp_all
    end

    properties (Constant)
        %
        % the data files are stored in the class folder
        %
        classpath = fileparts(which('OL490Class1Column'));
    end

    methods

        function obj = OL490Class1Column

            which(class(obj))

            obj.wl_target = [380:10:780]';

            %
            % read the data
            %
            datapath = sprintf('%s/%s',obj.classpath,'mypeakmeasure.mat');
            load(datapath,'mypeakmeasure');

            obj.spec_dark = mypeakmeasure{42}.amplitude;

            for i = 1:41
                obj.spec_all(i,:) = mypeakmeasure{i}.amplitude - obj.spec_dark;
            end

        end

        function show_measurement (obj)
            clf
            plot(obj.spec_all')
            title('Measurement')
        end

    end

    methods (Static)

        %
        % find the peak of a single spike in a spectrum
        %
        function [x y] = find_spike (wl_tar, spec)

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

                [x y] = OL490Class1Column.find_spike(wl_tar,spec);

                peaks(i,1) = x;
                peaks(i,2) = y;

            end

        end

        function col_wl_amp_all = check_measurement_data
            % examine a "peak1col_??.mat file
            % to compare the expected peak and measured peak
            % ?? means expected wavelength [400+?? : 50 : 750] nm
            % for exmaple: 00 means [400:50:750], 10 means [410:50:750]

            %
            % get dark
            %
            datapath = sprintf('%s/%s',OL490Class1Column.classpath,'dark.mat');
            load(datapath,'s_dark');

            % data stored
            col_wl_amp_all = []

            %for wl_offset = 00:10:40


            for wl_offset = 0:1:49

                % retrieve the data file
                datapath = sprintf('%s/%s_%02d',OL490Class1Column.classpath,'peak1col',wl_offset);
                load(datapath,'s','wl_target','col_range');

                % analyze the spectrum
                spec_no_dark = s.amplitude-s_dark.amplitude;
                peaks = OL490Class1Column.find_spikes(wl_target,spec_no_dark);


                col = col_range';
                wl = peaks(:,1);
                amp = peaks(:,2);

                col_wl_amp = [col wl amp];
                col_wl_amp_all = [col_wl_amp_all ; col_wl_amp];

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

        end

        function measurement_trial_search_x50_summary

            datapath = sprintf('%s/%s.mat',OL490Class1Column.classpath,'my_col_wl');
            load(datapath,'col_wl_all');

            clf
            plot(col_wl_all(:,1),col_wl_all(:,2),'.')
            xlabel('OL490 Input Column (#)')
            ylabel('OL490 Output Wavelength (nm)')
            title('Relationship between OL490 column # and output wavelength')

            return

            col_wl = []
            for i = 00:1:49

                datapath = sprintf('%s/%s_%02d.mat',OL490Class1Column.classpath,'peak1col',i);
                load(datapath);

                % col_wl =
            end
        end

        function measurement_trial_search_x50 (ol,cs)
            %
            % collect data at 1 nm over 50 times
            %

            datapath = sprintf('%s/dark.mat',OL490Class1Column.classpath);
            load(datapath,'s_dark');

            col_wl_all = [];
            for i = 00:1:49

                wl_target = [400+i:50:750];
                col_wl = OL490Class1Column.measurement_trial_search(ol,cs,wl_target,s_dark);
                col_wl_all = [col_wl_all ; col_wl];

                %
                % save the spectral result
                %
                datapath_old = sprintf('%s/%s_%02d.mat',OL490Class1Column.classpath,'peak1col',99);
                datapath_new = sprintf('%s/%s_%02d.mat',OL490Class1Column.classpath,'peak1col',i);
                movefile(datapath_old,datapath_new);

            end

            col_wl_all = sortrows(col_wl_all);
            save('my_col_wl','col_wl_all')

        end

        function col_wl = measurement_trial_search (ol,cs,wl_target,s_dark)
            %
            % multi-trial measurements
            %   ol: OL490
            %   cs: spectroradiometer
            %   wl_target: a list of wavelengths to match
            %   col_range: a list of column numbers to use
            %   s_dark: pre-measured dark level
            %

            %
            % target
            %
            % wl_target = [400+40:50:750];

            %
            % initial guess
            %
            col = OL490Class1Column.col2peak_predict(wl_target);

            %
            % iterate until good results found or max trials
            %
            err = 100;
            i = 1;
            max_trial = 5;
            while i <= max_trial && err > 1
                fprintf('Iteration #%d\n',i)
                [s wl] = OL490Class1Column.measurement_trial(ol,cs,wl_target,col,s_dark);
                col = OL490Class1Column.wl_column_interpolate(wl,col,wl_target);
                err = max(abs(wl_target - wl))
                i = i + 1;
            end

            %
            % return
            %
            col_wl = zeros(length(wl_target),2);
            col_wl(:,1) = col';
            col_wl(:,2) = wl';

        end

        function col_predict = wl_column_interpolate (wl,col,wl_target)
            %
            % predict column between 1 and 1024 by the look-up table
            %
            col_predict = round(interp1(wl,col,wl_target,'spline','extrap'));
            col_predict = min(col_predict,1024);
            col_predict = max(col_predict,1);

        end

        function [s_measured,wl_measured] = measurement_trial (ol,cs,wl_target,col_range,s_dark)
            %
            % one trial measurement
            %   ol: OL490
            %   cs: spectroradiometer
            %   wl_target: a list of wavelengths to match
            %   col_range: a list of column numbers to use
            %   s_dark: pre-measured dark level
            %

            %
            % prepare the input
            %
            %            col_range = OL490Class1Column.col2peak_predict(wl_target);
            col_vector = OL490Class1Column.multiple_peaks(col_range);

            %
            % control light
            %
            ol.setColumn1024(col_vector);

            %
            % measure
            %
            s = cs.measure;

            %
            % analyze
            %
            spec_no_dark = s.amplitude-s_dark.amplitude;

            peaks = OL490Class1Column.find_spikes(wl_target,spec_no_dark);

            s_measured = s;
            wl_measured = peaks(:,1)';

            %
            % report
            %
            [wl_target' wl_measured']

            %
            % visualize
            %
            clf
            s.plot

            %
            % mark the target wavelength
            %
            for i = 1:length(wl_target)
                x = wl_target(i);
                xline(x,'b')
            end

            %
            % mark the measured wavelength
            %
            for i = 1:length(wl_target)
                x = wl_measured(i);
                xline(x,'r:')
            end

            %
            % save the measurement results
            %
            datapath = sprintf('%s/%s_%02d',OL490Class1Column.classpath,'peak1col',99);
            save(datapath,'s','wl_target','col_range','col_vector','s_dark');

            return

        end

        function col = col2peak_predict (wl)
            %
            % predict the columns using old measurement data
            % wl: a list of peaks
            %
            load('col2peak.mat','col2peak')

            for i = 1:length(wl)
                wl_target = wl(i);
                col_predict = round(interp1(col2peak(:,2),col2peak(:,1),wl_target,'spline','extrap'));

                if col_predict > 1024
                    %
                    % over
                    %
                    fprintf('%d %d exceed 1024 for %d\n',i,col_predict,wl_target)
                    col(i) = 1024;
                else
                    if col_predict < 1
                        %
                        % under
                        %
                        fprintf('%d %d exceed 1 for %d\n',i,col_predict,wl_target)
                        col(i) = 1;
                    else
                        %
                        % normal cases
                        %
                        col(i) = col_predict;
                    end
                end
            end
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
                vout = OL490Class1Column.add_a_peak(vout,col,col_width,v_max);
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

