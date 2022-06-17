classdef RiftSim < DispSim
    
    properties
        dataspec
        ramp_r
        ramp_g
        ramp_b
        lut_x
        lut
    end
    
    methods
        
        function obj = RiftSim
            obj.classpath = fileparts(which('RiftSim'));

            % scaling factor
%            obj.sc = 0.08;
            obj.sc = 1;
            
            datapath = sprintf('%s/%s',obj.classpath,'mydata04042022-prelens.mat');
            load(datapath,'dataspec');
            obj.dataspec = dataspec;
            
            % seperate channels
            ramp_r = dataspec(1:4:1024,:);
            ramp_g = dataspec(2:4:1024,:);
            ramp_b = dataspec(3:4:1024,:);
            
            % calculate auc
            auc = zeros(256,3);
            for i = 0:255
                auc(i+1,1) = sum(ramp_r(i+1,:)) / sum(ramp_r(end,:));
                auc(i+1,2) = sum(ramp_g(i+1,:)) / sum(ramp_g(end,:));
                auc(i+1,3) = sum(ramp_b(i+1,:)) / sum(ramp_b(end,:));
            end
            
            % visualize
            if 0
            clf
            plot(auc)
            end
            
            % use only 18 points
            lut = zeros(18,3);
            lut_x = 0:1/17:1;
            lut = auc(1:15:256,:);
            
            % visualize
            if 0
            clf
            hold on
            plot(lut_x,lut(:,1),'ro-')
            plot(lut_x,lut(:,2),'go-')
            plot(lut_x,lut(:,3),'bo-')
            end
            
            obj.lut_x = lut_x';
            obj.lut = lut;
            
            % scaled down the public data
            obj.ramp_r = ramp_r * obj.sc;
            obj.ramp_g = ramp_g * obj.sc;
            obj.ramp_b = ramp_b * obj.sc;

            obj.spec_r = ramp_r(end,:) * obj.sc;
            obj.spec_g = ramp_g(end,:) * obj.sc;
            obj.spec_b = ramp_b(end,:) * obj.sc;
            
            obj.OL490_load_vec;
            
        end
        
        function rgb_lin = gamma (obj,rgb)
            rgb = rgb / 255;
            
            r_lin = interp1(obj.lut_x,obj.lut(:,1),rgb(1));
            g_lin = interp1(obj.lut_x,obj.lut(:,2),rgb(2));
            b_lin = interp1(obj.lut_x,obj.lut(:,3),rgb(3));
            
            rgb_lin = [r_lin g_lin b_lin];
        end

        function spec = output (obj, rgb)
            
            rgb = round(rgb);
            
            spec_r = obj.ramp_r(rgb(1)+1,:);
            spec_g = obj.ramp_g(rgb(2)+1,:);
            spec_b = obj.ramp_b(rgb(3)+1,:);
            
            spec_dark = (obj.ramp_r(1,:) + obj.ramp_g(1,:) + obj.ramp_b(1,:))/3; 
            
            spec = obj.sc * (spec_r + spec_g + spec_b + spec_dark);
           
        end
        
    end
end

