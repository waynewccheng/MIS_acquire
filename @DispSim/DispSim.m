classdef DispSim < handle
    
    properties
        sc
        spec_r
        spec_g
        spec_b        
        classpath
        gamma_srgb
    end
    
    methods

        function show_spectra (obj)
            %clf
            hold on
            plot(380:1:780,obj.spec_r,'r');
            plot(380:1:780,obj.spec_g,'g');
            plot(380:1:780,obj.spec_b,'b');            
            legend('Red','Green','Blue')
        end
        
        function [spec rgb_lin] = rgb2spec (obj,rgb)
            obj.build_gamma;
            
            rgb_lin = interp1(obj.gamma_srgb(:,1),obj.gamma_srgb(:,2),rgb/255.0);
            spec = obj.spec_r * rgb_lin(1) + obj.spec_g * rgb_lin(2) + obj.spec_b * rgb_lin(3);
        end
        
        function build_gamma (obj)
            ddl = [0:255]/255;
            rgb = [ddl' ddl' ddl'];
            lab = rgb2lab(rgb);
            xyz = lab2xyz(lab);
            obj.gamma_srgb(:,1) = ddl;
            obj.gamma_srgb(:,2) = xyz(:,2);
            
%            plot(obj.gamma_srgb(:,1),obj.gamma_srgb(:,2))
        end
        
        function rgb_lin = gamut (obj)
            
            srgb = [0.64 0.33; 0.3 0.6 ; 0.15 0.06];
            p3 = [0.68 0.32; 0.265 0.69 ; 0.15 0.06];
            rec2020 = [0.708 0.292; 0.170 0.797 ; 0.131 0.046];
            
            cc = ColorConversionClass;
            
            XYZ_r = cc.spd2XYZ(obj.spec_r(1:10:end)');
            XYZ_g = cc.spd2XYZ(obj.spec_g(1:10:end)');
            XYZ_b = cc.spd2XYZ(obj.spec_b(1:10:end)');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            %clf
            hold on
            plot(srgb([1 2 3 1],1),srgb([1 2 3 1],2),'-')
            plot(p3([1 2 3 1],1),p3([1 2 3 1],2),'-')
            plot(rec2020([1 2 3 1],1),rec2020([1 2 3 1],2),'-')

            legend('sRGB','P3','Rec 2020')

            plot(xyz_r(1),xyz_r(2),'or')
            plot(xyz_g(1),xyz_g(2),'og')
            plot(xyz_b(1),xyz_b(2),'ob')

            
            axis equal

        end        
        
    end
end

