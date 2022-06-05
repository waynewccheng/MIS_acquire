classdef RiftSim < handle
    
    properties
        dataspec
        ramp_r
        ramp_g
        ramp_b
        lut_x
        lut
        sc
    end
    
    properties (Constant)
        
        % the data files are stored in the class folder
        
        classpath = fileparts(which('RiftSim'));
    end
    
    methods
        
        function obj = RiftSim (sc)
            % scaling factor
            obj.sc = sc;
            
            datapath = sprintf('%s/%s',LightSim.classpath,'mydata04042022-prelens.mat');
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
            
            obj.ramp_r = ramp_r;
            obj.ramp_g = ramp_g;
            obj.ramp_b = ramp_b;
        end
        
        function rgb_lin = gamma (obj,rgb)
            rgb = rgb / 255;
            
            r_lin = interp1(obj.lut_x,obj.lut(:,1),rgb(1));
            g_lin = interp1(obj.lut_x,obj.lut(:,2),rgb(2));
            b_lin = interp1(obj.lut_x,obj.lut(:,3),rgb(3));
            
            rgb_lin = [r_lin g_lin b_lin];
        end

        function rgb_lin = gamut (obj)
            
            srgb = [0.64 0.33; 0.3 0.6 ; 0.15 0.06];
            p3 = [0.68 0.32; 0.265 0.69 ; 0.15 0.06];
            rec2020 = [0.708 0.292; 0.170 0.797 ; 0.131 0.046];
            
            spec_r = obj.ramp_r(end,1:10:end);
            spec_g = obj.ramp_g(end,1:10:end);
            spec_b = obj.ramp_b(end,1:10:end);
            
            cc = ColorConversionClass;
            
            XYZ_r = cc.spd2XYZ(spec_r');
            XYZ_g = cc.spd2XYZ(spec_g');
            XYZ_b = cc.spd2XYZ(spec_b');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            clf
            hold on
            plot(xyz_r(1),xyz_r(2),'or')
            plot(xyz_g(1),xyz_g(2),'og')
            plot(xyz_b(1),xyz_b(2),'ob')

            plot(srgb([1 2 3 1],1),srgb([1 2 3 1],2),'-')
            plot(p3([1 2 3 1],1),p3([1 2 3 1],2),'-')
            plot(rec2020([1 2 3 1],1),rec2020([1 2 3 1],2),'-')
            
            axis equal
            'oh'

            return
            
            plot(380:780,spec_r,'r')
            plot(380:780,spec_g,'g')
            plot(380:780,spec_b,'b')            
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
