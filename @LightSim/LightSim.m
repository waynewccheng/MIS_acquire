classdef LightSim < handle
    % Find relationship between 1024-column control and ouput spectra of OL490
    
    properties
        
        col_spec
        spd_max
        spd_min
        spd_max_date
        spd_min_date
        
    end
    
    properties (Constant)
        
        % the data files are stored in the class folder
        
        classpath = fileparts(which('LightSim'));
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
        
        function test_vec (obj,ol,cs,vec)
            ol.setColumn1024Gamma(vec);
            mea = cs.measure;
            
            clf
            mea.plot
        end
                
        function vec = spd2vec (obj,spd_target)
            % find the linear vector to generate spd
            
            % visualize
            clf
            hold on
            plot(380:780,obj.spd_max)
            plot(380:780,spd_target)
            legend('spd max','spd target')
            title('Check the target spd')
            
            %
            % calcualte the reflectance
            %
            ref_target_orig = (spd_target - obj.spd_min) ./ (obj.spd_max - obj.spd_min);
            ref_target = min(1,ref_target_orig);
            ref_target = max(0,ref_target);
            
            % visualize
            clf
            hold on
            plot(ref_target_orig)
            plot(ref_target)
            title('Check target reflectance')
            
            %
            % solve the equation with R
            %
            ref_m = obj.col_spec';
            vec_orig = R_callRsolver1024(ref_m,ref_target);
if 0
load('vec','vec')
vec_orig = vec;
end
            % limit to [0,1]
            vec = vec_orig;
            vec = min(1,vec);
            vec = max(0,vec);
            
            % visualize the vector
            clf
            plot(vec)
            title('Check the vector given by R')

            % predict the reflectance
            ref_predicted = obj.vec2ref(vec);

            % visualize
            clf
            hold on
            plot(ref_target)
            plot(ref_predicted)
            legend('target','predicted')
            title('Check predicted reflectance')
            
        end
        
        function ref_predicted = vec2ref (obj,vec)
            % predict the reflectance with linear vector
            
            ref_predicted = obj.col_spec' * vec + (obj.spd_min ./ obj.spd_max);

            % visualize
            clf
            plot(ref_predicted)
            title('Check predicted reflectance')
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

