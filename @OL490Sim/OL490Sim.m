%% OL490 characterization -- including forward and inverse models
% use OL490 to simulate a given spectrum
classdef OL490Sim < handle
    %OL490SIM Characterization of OL490
    %   Detailed explanation goes here

    properties
        col_spec       % 1024x401 reflectance table

        HIMS_VER       % measurement from HIMS1/HIMS2 and date

        spike_filename % data file for spectral characterization
        gamma_filename % data file for gamma characterization
        col_spec_filename % data file for characterization

        speC_max
        speC_min

        reflC_min

        classpath
        spikedatapath
        gammadatapath
        col_specdatapath
    end

    methods

        function obj = OL490Sim (hims)
            %OL490Sim Construct an instance of this class
            %  assign the pathnames
            %  load the data if present 

            if hims == 1
                obj.HIMS_VER = 'HIMS1_12132022';
            else
                obj.HIMS_VER = 'HIMS2_07032022';
            end
            
            obj.spike_filename = ['spike_' obj.HIMS_VER '.mat'];
            obj.gamma_filename = ['gamma_' obj.HIMS_VER '.mat'];
            obj.col_spec_filename = ['col_spec_' obj.HIMS_VER '.mat'];
        
            obj.classpath = fileparts(which('OL490Sim'));
            obj.spikedatapath = sprintf('%s/%s',obj.classpath,obj.spike_filename);
            obj.col_specdatapath = sprintf('%s/%s',obj.classpath,obj.col_spec_filename);
            obj.gammadatapath = sprintf('%s/%s',obj.classpath,obj.gamma_filename);

            if isfile(obj.col_specdatapath)
                load(obj.col_specdatapath,'col_spec')
            end
            
            % obj.FWD_characterize;

        end

        function FWD_stimulate_spectrally (obj, ol, cs)
            %FWD_STIMULATE Stimulate the OL490 with various vectors and measure its responses

            time_spectrally = tic

            spike_white = {};
            spike_spike = {};
            for i = 1:50
                % show some progress
                fprintf('Spectral measurement: %d of %d\n',i,50)

                spike_white{i} = measure_white(ol,cs);

                wl_range = [400+(i-1)*1:50:750];
                wl_range_spike{i} = wl_range;

                mea = measure_8_spikes(ol,cs,wl_range);
                spike_spike{i} = mea;
            end

            spike_black = measure_black(ol,cs);

            time_spent = toc(time_spectrally)

            save(obj.spikedatapath,'spike_black','spike_white','spike_spike','wl_range_spike','time_spent')

            return

            function mea = measure_white (ol,cs)
                c_range = 1:1024;
                vec = OL490Class.VEC_multiple_peaks(c_range);
                ol.setColumn1024(vec)
                mea = cs.measure;
            end

            function mea = measure_black (ol,cs)
                c_range = [];
                vec = OL490Class.VEC_multiple_peaks(c_range);
                ol.setColumn1024(vec)
                mea = cs.measure;
            end

            function mea = measure_8_spikes (ol,cs,wl_range)

                col_center = [72 202 327 454 583 708 834 956];
                wl_center = [400 450 500 550 600 650 700 750];

                col_range = round(interp1(wl_center,col_center,wl_range,'spline','extrap'));

                col_range = min(col_range,1024);
                col_range = max(col_range,1);

                vec = LightSim.multiple_peaks(col_range);
                ol.setColumn1024(vec)
                mea = cs.measure;

            end

        end

        function FWD_stimulate_spectrally_finding (obj)
            load(obj.spikedatapath,'spike_black','spike_white','spike_spike','time_spent')

            clf
            spike_spike{1}.plot

        end

        function FWD_stimulate_gamma (obj, ol, cs)
            %FWD_STIMULATE_GAMMA Characterize the column gamma

            assert(isa(ol,'OL490Class'))
            % how to check pr730?

            VIS = 0;

            time_gamma = tic

            % Sweep the column amplitude
            vec_max = repmat([1],1,1024);      % all columns on
            scale = 0:0.1:1;                   % scaling factor

            meascale = {};
            for i = 1:length(scale)
                vec = vec_max * scale(i);
                ol.setColumn1024(vec)

                fprintf('Gamma measurement: %d of %d\n',i,length(scale))

                mea = cs.measure;
                meascale{i} = mea;
            end

            % visualize
            if VIS
                clf
                hold on
                for i=1:length(scale)
                    meascale{i}.plot
                end
            end

            % use area under the curve to calculate the ratio
            for i=1:length(scale)
                mea_net = meascale{i} - meascale{1};
                meaarea(i) = sum(mea_net.amplitude);
            end

            % normalize
            meaarea = meaarea / max(meaarea);

            if VIS
                clf
                plot(scale,meaarea,'o')
                grid on
            end

            % save the data
            gamma_lut = zeros(11,2);
            gamma_lut(:,1) = scale;
            gamma_lut(:,2) = meaarea;

            time_spent = toc(time_gamma)

            save(obj.gammadatapath,'gamma_lut','meascale','meaarea','time_spent')

        end

        function FWD_stimulate_gamma_finding (obj)
            %FWD_STIMULATE_GAMMA_FINDING Show results

            load(obj.gammadatapath,'gamma_lut','meascale','meaarea','time_spent')

            clf

            subplot(2,1,1)
            hold on
            for i=1:length(meascale)
                meascale{i}.plot;
            end
            axis square

            subplot(2,1,2)
            plot(gamma_lut(:,1),gamma_lut(:,2),'o')
            axis equal
            axis([0 1 0 1])
            grid on
            xlabel('Input')
            ylabel('Output')

        end

        function FWD_characterize_spectrally (obj)
            %FWD_CHARACTERIZE Analyze the collected data to construct the
            %reflectance matrix
            %

            VIS = 0;

            load(obj.spikedatapath,'spike_black','spike_white','spike_spike')

            %
            % Lmax
            %
            % consider taking the average of 50
            obj.speC_max = spike_white{25};

            %
            % Lmin
            %
            obj.speC_min = spike_black;
            obj.reflC_min = obj.speC_min ./ obj.speC_max;

            if VIS
                clf
                hold on
                for i = 1:50
                    spike_spike{i}.plot;
                end
            end

            %
            % calculate the reflectance
            %
            spike_reflectance = {};
            for i = 1:50
                spike_reflectance{i} = (spike_spike{i}-spike_black)./(spike_white{i}-spike_black);
            end

            %
            % visualize
            %
            if VIS
                clf
                i = 20;
                spike_reflectance{i}.plot;
                axis([350 800 0 0.08])
            end

            %
            % break the combs
            %

            comb_array = zeros(750,780);

            for i = 1:50
                % decide the x values
                wl_range = [400+(i-1)*1:50:750];
                wl_range_n = length(wl_range);

                % take one curve
                comb = spike_reflectance{i};

                % convert to real wavelength
                comb_real = zeros(1,780);
                comb_real(1,380:780) = comb.amplitude;

                % iterate each spike
                for j = 1:wl_range_n
                    wl = wl_range(j);
                    wl_width = 25;

                    comb_array(wl,wl-wl_width:wl+wl_width) = comb_real(1,wl-wl_width:wl+wl_width);
                end

            end

            %
            % visualize
            %
            if VIS
                clf
                i = 691;
                plot(comb_array(i,:))
                axis([380 780 0 0.08])
            end

            %
            % link column with spectrum
            %
            col_spec = zeros(1024,401);

            % mapping between column and wavelength from previous findings
            col_center = [72 202 327 454 583 708 834 956];
            wl_center = [400 450 500 550 600 650 700 750];

            % interpolate columns between 72 and 956
            for col_i = 72:956
                wl_i = round(interp1(col_center,wl_center,col_i,'linear'));
                spec = comb_array(wl_i,:);
                col_spec(col_i,:) = spec(380:780);
            end

            % clip
            col_spec = min(1,col_spec);
            col_spec = max(0,col_spec);

            %
            % visualize
            %
            if VIS
                clf
                i = 86;
                plot(380:780,col_spec(i,:))
                axis([380 780 0 0.08])
            end

            obj.col_spec = col_spec;

            %
            % save the result
            %
            save(obj.col_specdatapath,'col_spec')

        end

        function FWD_characterize_spectrally_finding (obj)
            col_spec = obj.col_spec;

            clf
            [X Y] = meshgrid(380:780,1:1024);
            mesh (X,Y,col_spec)
            axis square
            axis([380 780 1 1024 0 0.08])
            xlabel('Wavelength (nm)')
            ylabel('Column #')
            colorbar
            view(0,90)
            title('Reflectance')
        end

        function reflC_predicted = FWD_vec2reflC (obj,vec)
            %FWD_VEC2REFL Predict the reflectance for vec

            assert(length(vec)==1024);

            refl = obj.col_spec' * vec + obj.reflC_min.amplitude;
            refl = min(1,refl);
            refl = max(0,refl);

            reflC_predicted = SpectrumClass([380:780]',refl);
        end

        function spdC_predicted = FWD_vec2spdC (obj,vec)
            %FWD_VEC2REFL Predict the output spd for vec

            assert(length(vec)==1024);

            reflC = obj.FWD_vec2reflC(vec);
            spdC_predicted = reflC .* obj.speC_max;
        end

        function vec = INV_spd2vec (obj,spd_target)
            %%SPD2VEC Inverse model
            % find the linear vector to generate spd

            VIS = 0;

            if ~(size(spd_target,1)==401 && size(spd_target,2)==1)
                spd_target = spd_target';
            end

            % need to be vertical
            assert(size(spd_target,1)==401 && size(spd_target,2)==1);

            % visualize
            if VIS
                clf
                hold on
                plot(380:780,obj.spd_max)
                plot(380:780,spd_target)
                legend('spd max','spd target')
                title('Check the target spd')
            end

            %
            % calcualte the reflectance
            %
            ref_target_orig = (spd_target - obj.speC_min.amplitude) ./ (obj.speC_max.amplitude - obj.speC_min.amplitude);
            ref_target = min(1,ref_target_orig);
            ref_target = max(0,ref_target);

            % visualize
            if VIS
                clf
                hold on
                plot(ref_target_orig)
                plot(ref_target)
                title('Check target reflectance')
            end

            %
            % solve the equation with R
            %
            ref_m = obj.col_spec';
            rsolve = Rsolver(ref_m,ref_target);

            vec_orig = rsolve.A;

            %            vec_orig = R_callRsolver1024(ref_m,ref_target);
            if VIS
                load('vec','vec')
                vec_orig = vec;
            end

            % limit to [0,1]
            vec = vec_orig;
            vec = min(1,vec);
            vec = max(0,vec);

            % visualize the vector
            if VIS
                clf
                plot(vec)
                title('Check the vector given by R')
            end
        end

        function check_ol_cs (obj,ol,cs)
            % to check whether the OL490 is working correctly
            'Set the light to green and show its spectrum'
            ol.setGreen;
            mea = cs.measure;
            mea.plot;
        end
        
    end

end