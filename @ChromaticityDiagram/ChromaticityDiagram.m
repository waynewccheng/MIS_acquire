%% Generate colored chromaticity diagram
% Q: How to show the color gamut boundaries of sRGB in CIEXYZ xyY?
% 3-4-2024 rewrite classes
% 3-3-2024 check spectral locus
% 7-4-2022
% 12-19-2018
% 12-20-2018

classdef ChromaticityDiagram < handle

    properties
        cmf
    end

    methods

        function demo (obj)

            clf
            hold on

            obj.draw_spectral_locus();
            obj.draw_purple_line();
            obj.draw_labels();

            ct = ChromaticityTriangle;
            %ct.show_triangle();
            ct.shade_triangle();

            obj.draw_white_point();
        end
        
        function obj = ChromaticityDiagram
            
            obj.cmf = CMF_CIE_2deg;                                           % use the CIE 2-degree CMF to get the bigger gamut

        end

        function draw_spectral_locus (obj)

            obj.draw_curve_with_color(obj.cmf.spectral_locus_xyz(:,2:3));
            
        end

        function draw_purple_line (obj)

            obj.draw_curve_with_color(obj.cmf.purple_line_xy(:,1:2));
          
        end

        function draw_curve_with_color (obj, xy)
            ct = ChromaticityTriangle;

            hold on
            for i = 1 : size(xy,1)-1
                rgb = ct.xy2fakecolor(xy(i,:));
                plot(xy(i:i+1,1),xy(i:i+1,2),'-','LineWidth',2,'Color',rgb);
            end

        end

        function draw_white_point (obj)
            wp = 'd65';

            XYZ = whitepoint(wp);
            xyz = XYZ / sum(XYZ);

            plot(xyz(1),xyz(2),'ok');
        end

        function draw_labels (obj)
            xlabel('CIE x')
            ylabel('CIE y')

            axis equal
            axis ([0 1 0 1])
        end
    end

end


