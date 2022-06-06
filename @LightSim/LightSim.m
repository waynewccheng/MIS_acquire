classdef LightSim < handle
    % Find relationship between 1024-column control and ouput spectra of OL490
    
    properties
        
        col_spec
        spd_max
        spd_min
        spd_max_date
        spd_min_date
       
        vec_r
        vec_g
        vec_b
        
        rs
    end
    
    properties (Constant)
        
        % the data files are stored in the class folder
        
        classpath = fileparts(which('LightSim'));
        
        colorchecker_rgb = [115 82 68;
            194 150 130;
            98  122 157;
            87  108 67;
            133 128 177;
            103 189 170;
            
            214 126 44;
            80  91  166;
            193 90  99;
            94  60  108;
            157 188 64;
            224 163 46;
            
            56  61  150;
            70  148 73;
            175 54  60;
            231 199 31;
            187 86  149;
            8   133 161;
            
            243 243 242;
            200 200 200;
            160 160 160;
            122 122 121;
            85  85  85;
            52  52  52];
    end
    
    methods
        
        function obj = LightSim
            
            %
            % get column-reflectance data
            %
            datapath = sprintf('%s/%s',LightSim.classpath,'col_spec.mat');
            load(datapath,'col_spec');
            obj.col_spec = col_spec;
            
            %
            % get previous measurement data
            %
            datapath = sprintf('%s/%s',LightSim.classpath,'spd_max.mat');
            load(datapath,'spd_m*');
            obj.spd_max = spd_max;
            obj.spd_min = spd_min;
            obj.spd_max_date = spd_max_date;
            obj.spd_min_date = spd_min_date;
            
        end
        
        function colorchecker_test_temp (obj,ol,cs,disp,vec_filename)
            
            spd_disp_24 = {};
            spd_ol490_24 = {};
            
            clf
            for i = 1:24
                subplot(4,6,i)
                [spd_disp spd_ol490] = obj.compare_disp_ol490(ol,cs,disp,vec_filename,obj.colorchecker_rgb(i,:));
                spd_disp_24{i} = spd_disp;
                spd_ol490_24{i} = spd_ol490;
            end
            save('colorchecker_test_result_temp.mat','spd_disp_24','spd_ol490_24')
            
            gh = gcf;
            gh.Position = [680 265 1363 833];
            saveas(gh,'colorchecker_test_result_temp.png')
        end
        
        function colorchecker_test (obj,ol,cs)
            
            spd_rift_24 = {};
            spd_ol490_24 = {};
            
            clf
            for i = 1:24
                subplot(4,6,i)
                [spd_rift spd_ol490] = obj.compare_rift(ol,cs,obj.colorchecker_rgb(i,:));
                spd_rift_24{i} = spd_rift;
                spd_ol490_24{i} = spd_ol490;
            end
            save('colorchecker_test_result.mat','spd_rift_24','spd_ol490_24')
            
            gh = gcf;
            gh.Position = [680 265 1363 833];
            saveas(gh,'colorchecker_test_result.png')
        end

        function rs = model_NEC (obj)
            
            % NEC PA271 Adobe
            
            nec = NECPA271Sim;
            
            vec_r = obj.spd2vec(nec.spec_r);
            vec_g = obj.spd2vec(nec.spec_g);
            vec_b = obj.spd2vec(nec.spec_b);
            
            save('vec_nec','vec*')

        end
        
        function rs = model_HPZ24x (obj)
            % temp -- see HPZ24xSim
            sc = 0.07;
            spec_z24x = xlsread('hpz24x_rgb.csv');
            
            spec_z24x = spec_z24x(21:end,:)'*sc;
            
            vec_r = obj.spd2vec(spec_z24x(1,:));
            vec_g = obj.spd2vec(spec_z24x(2,:));
            vec_b = obj.spd2vec(spec_z24x(3,:));
            
            save('vec_hp24z','vec*')

        end
        
        function rs = model_rift (obj)
            rs = RiftSim(0.08);
            
            obj.vec_r = obj.spd2vec(rs.output([255 0 0]));
            obj.vec_g = obj.spd2vec(rs.output([0 255 0]));
            obj.vec_b = obj.spd2vec(rs.output([0 0 255]));
            
            obj.rs = rs;
        end
        

        function dE = analyze_rift (obj)
            
            load('colorchecker_test_result.mat','spd_rift_24','spd_ol490_24')
            
            
            cc = ColorConversionClass;

            spec = zeros(24,41);
            for i = 1:24
                s = spd_ol490_24{i};
                s = s(1:10:end);
                spec(i,:) = s;
            end

            % XYZ is 24x3
            XYZ_ol490 = cc.spd2XYZ(spec');
            LAB_ol490 = cc.XYZ2lab(XYZ_ol490,XYZ_ol490(19,:));
            
            spec = zeros(24,41);
            for i = 1:24
                s = spd_rift_24{i};
                s = s(1:10:end);
                spec(i,:) = s;
            end
            
            % XYZ is 24x3
            XYZ_rift = cc.spd2XYZ(spec');
            LAB_rift = cc.XYZ2lab(XYZ_rift,XYZ_rift(19,:));
            
            for i = 1:24
                 [dE00 dE94 dEab] = cc.LAB2dE(LAB_rift(i,:)',LAB_ol490(i,:)');
                 dE(i) = dE00;
            end
            'oh'
        end


        function compare_primary (obj,ol,cs,vec_filename,dispsim)
            load(vec_filename)
            
            % lit the light
            spd_ol490_r = obj.test_vec(ol,cs,vec_r);
            spd_ol490_g = obj.test_vec(ol,cs,vec_g);
            spd_ol490_b = obj.test_vec(ol,cs,vec_b);
            
            clf
            hold on
            plot(380:780,spd_ol490_r,':r')
            plot(380:780,dispsim.spec_r,'r')            
            plot(380:780,spd_ol490_g,':g')
            plot(380:780,dispsim.spec_g,'g')            
            plot(380:780,spd_ol490_b,':b')
            plot(380:780,dispsim.spec_b,'b')      
            
            save('primary_results','spd_*')
        end
        
        function [spd_disp spd_ol490] = compare_disp_ol490 (obj,ol,cs,disp,vec_filename,rgb)
            
            % obtain linear RGB on Rift
            [spd_disp rgb_lin] = disp.rgb2spec(rgb);
            
            % get pre-calculated vectors for Rift primaries
            load(vec_filename,'vec_r','vec_g','vec_b')
            
            % assume additivity
            vec = vec_r * rgb_lin(1) + vec_g * rgb_lin(2) + vec_b * rgb_lin(3);
            vec = max(0,vec);
            vec = min(1,vec);
            
            % lit the light
            spd_ol490 = obj.test_vec(ol,cs,vec);
            
            %clf
            hold on
            plot(380:780,spd_disp)
            plot(380:780,spd_ol490)
            legend('Display','OL490')
            axis([380 780 0 3e-4])
            
        end

        function [spd_rift spd_ol490] = compare_rift (obj,ol,cs,rgb)
            
            % obtain linear RGB on Rift
            rgb_lin = obj.rs.gamma(rgb);
            
            % get pre-calculated vectors for Rift primaries
            % load('rift_vec','vec_r','vec_g','vec_b')
            
            % assume additivity
            vec = obj.vec_r * rgb_lin(1) + obj.vec_g * rgb_lin(2) + obj.vec_b * rgb_lin(3);
            
            % lit the light
            spd_ol490 = obj.test_vec(ol,cs,vec);
            
            % pre-determined earlier
            spd_rift = obj.rs.output(rgb);
            
            hold on
            plot(380:780,spd_rift)
            plot(380:780,spd_ol490)
            legend('Rift','OL490')
            axis([380 780 0 3e-4])
            
        end
        
        function spd = test_vec (obj,ol,cs,vec)
            ol.setColumn1024Gamma(vec);
            mea = cs.measure;
            spd = mea.amplitude;
            
            if 0
            clf
            mea.plot
            end
        end
        
        function vec = spd2vec (obj,spd_target)
            % find the linear vector to generate spd
            
            if ~(size(spd_target,1)==401 && size(spd_target,2)==1)
                spd_target = spd_target';
            end
            
            % need to be vertical
            assert(size(spd_target,1)==401 && size(spd_target,2)==1);
            
            % visualize
            if 0
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
            ref_target_orig = (spd_target - obj.spd_min) ./ (obj.spd_max - obj.spd_min);
            ref_target = min(1,ref_target_orig);
            ref_target = max(0,ref_target);
            
            % visualize
            if 0
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
            if 0
                load('vec','vec')
                vec_orig = vec;
            end
            
            % limit to [0,1]
            vec = vec_orig;
            vec = min(1,vec);
            vec = max(0,vec);
            
            % visualize the vector
            if 0
            clf
            plot(vec)
            title('Check the vector given by R')
            end
            
            % predict the reflectance
            ref_predicted = obj.vec2ref(vec);
            
            % visualize
            if 0
            clf
            hold on
            plot(ref_target)
            plot(ref_predicted)
            legend('target','predicted')
            title('Check predicted reflectance')
            end
            
        end
        
        function ref_predicted = vec2ref (obj,vec)
            % predict the reflectance with linear vector
            
            ref_predicted = obj.col_spec' * vec + (obj.spd_min ./ obj.spd_max);
            
            % visualize
            if 0
            clf
            plot(ref_predicted)
            title('Check predicted reflectance')
            end
            
        end
        
        %         function construct_vec_8_pencils (obj)
        %
        %             col_center = [72 202 327 454 583 708 834 956];
        %             wl_center = [400 450 500 550 600 650 700 750];
        %
        %             col_n = length(col_center);
        %             col_width = 0;
        %
        %             col_array = zeros(col_n,1024);
        %             for i = 1:col_n
        %                 c_center = col_center(i);
        %                 col_array(i,c_center-col_width:c_center+col_width) = 1;
        %             end
        %
        %             obj.vec_8_pencils = col_array;
        %             obj.vec_8_wl = wl_center;
        %
        %         end
        
        %         function construct_vec_8_spikes (obj)
        %
        %             col_center = [72 202 327 454 583 708 834 956];
        %             wl_center = [400 450 500 550 600 650 700 750];
        %
        %             col_n = length(col_center);
        %             col_width = 25;
        %
        %             col_array = zeros(col_n,1024);
        %             for i = 1:col_n
        %                 c_center = col_center(i);
        %                 col_array(i,c_center-col_width:c_center+col_width) = 1;
        %             end
        %
        %             obj.vec_8_spikes = col_array;
        %             obj.vec_8_wl = wl_center;
        %
        %         end
        
        function sout = predict_col_spec (obj, vec, spec_max)
            % Predict the output spd with vector based on the maximum light
            % vec: 1x1024
            % sout: OL490 spectrum
            
            assert(length(vec)==1024);
            
            spec_vec = obj.col_spec';
            reflectance_total = spec_vec * vec;
            spd_reflected = spec_max .* reflectance_total;
            
            sout = spd_reflected + obj.spd_0';
            
            return
            
        end
        
        function update_max (obj,ol,cs)
            % Measure the maximum light
            c_range = 1:1024;
            vec = LightSim.multiple_peaks(c_range);
            ol.setColumn1024(vec)
            mea = cs.measure;
            obj.spd_max = mea.amplitude;
            obj.spd_max_date = datetime;
        end
        
        function update_min (obj,ol,cs)
            % Measure the maximum light
            c_range = [];
            vec = LightSim.multiple_peaks(c_range);
            ol.setColumn1024(vec)
            mea = cs.measure;
            obj.spd_min = mea.amplitude;
            obj.spd_min_date = datetime;
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

