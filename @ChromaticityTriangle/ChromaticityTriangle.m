%% Generate colored chromaticity diagram
% Q: How to show the color gamut boundaries of sRGB in CIEXYZ xyY?
% 3-3-2024 check spectral locus
% 7-4-2022
% 12-19-2018
% 12-20-2018

classdef ChromaticityTriangle < handle

    properties

        rgb_space = 'srgb'
%         rgb_space = "adobe-rgb-1998"
%        rgb_space = "prophoto-rgb"

        interval_step = 1

        % constants used by subroutines
        interval
        interval_rev

        rgb
        XYZ
        xyz
        XYZ_d65
        xyz_d65
        hue
    end

    methods


        function obj = ChromaticityTriangle
            % constants used by subroutines

            obj.interval = [0:obj.interval_step:255]';
            obj.interval_rev = [255:-obj.interval_step:0]';

            obj.prep_rgb_chroma();
        end


        %
        % colors with the largest chroma
        %
        function prep_rgb_chroma (obj)

            %
            % B => C => G => Y => R => M => B
            %
            rgb = [...
                obj.interval * [0 1 0] + [0 0 255] ;                            
                obj.interval_rev * [0 0 1] + [0 255 0] ;
                obj.interval * [1 0 0] + [0 255 0] ;
                obj.interval_rev * [0 1 0] + [255 0 0] ;
                obj.interval * [0 0 1] + [255 0 0] ;
                obj.interval_rev * [1 0 0] + [0 0 255] ];


            XYZ = rgb2xyz(rgb/255,"ColorSpace",obj.rgb_space,'WhitePoint','d65');

            XYZ_d65 = whitepoint("d65");

            xyz = XYZ ./ sum(XYZ,2);
            xyz_d65 = XYZ_d65 ./ sum(XYZ_d65,2);

            hue = atan2(xyz(:,2)-xyz_d65(2),xyz(:,1)-xyz_d65(1));

            obj.rgb = rgb;
            obj.XYZ = XYZ;
            obj.xyz = xyz;
            obj.XYZ_d65 = XYZ_d65;
            obj.xyz_d65 = xyz_d65;
            obj.hue = hue;

        end

        function show_triangle (obj)

            hold on

            axis equal
            axis([0 1 0 1])

            for i = 1:size(obj.rgb,1)                                        % draw n points

                rgb = obj.rgb(i,1:3);
                xy = obj.xyz(i,1:2);                                     % for each point

                plot(xy(1),xy(2),'-o','Color',rgb/255);

                %                pause(0.01)
            end

        end

        function shade_triangle (obj)

            hold on

            axis equal
            axis([0 1 0 1])

            obj.shade_3points_rgb255([1 1 1; 1 0 0; 1 1 0]);
            obj.shade_3points_rgb255([1 1 1; 0 1 0; 1 1 0]);
            obj.shade_3points_rgb255([1 1 1; 0 1 0; 0 1 1]);
            obj.shade_3points_rgb255([1 1 1; 0 1 1; 0 0 1]);
            obj.shade_3points_rgb255([1 1 1; 0 0 1; 1 0 1]);
            obj.shade_3points_rgb255([1 1 1; 1 0 1; 1 0 0]);

            return

            for i = 1:size(obj.rgb,1)                                        % draw n points

                rgb = obj.rgb(i,1:3);
                xy = obj.xyz(i,1:2);                                     % for each point

                plot(xy(1),xy(2),'-o','Color',rgb/255);

                %                pause(0.01)
            end
           
        end

            function shade_3points_rgb255 (obj, rgbx3)
                % rgbx3 is 3x3 - 3 rows of RGB
                % c-by-3 colormap. Each row specifies one RGB color value.

                XYZx3 = rgb2xyz(rgbx3,"ColorSpace",obj.rgb_space,"WhitePoint","d65");

                xyzx3 = XYZx3 ./ sum(XYZx3,2) ;

                v = xyzx3(:,1:2);
                f = [1 2 3];
                col = rgbx3;
                patch('Faces',f,'Vertices',v,'FaceVertexCData',col,'FaceColor','interp','LineStyle','none');

            end


        function index = hue2index (obj, hue_target)

            diff = abs(obj.hue - hue_target);

            [M,I] = min(diff);

            index = I;
        end

        function rgb = xy2fakecolor (obj, xy)

            hue = obj.xy2hue(xy);

            idx = obj.hue2index(hue);

            rgb = xyz2rgb(obj.XYZ(idx,:),"ColorSpace",obj.rgb_space,"WhitePoint","d65");
            
            % clipping
            rgb = min(rgb,1);
            rgb = max(rgb,0);
        end

        function hue = xy2hue (obj, xy)
            % xy is nx3

            XYZ_d65 = whitepoint("d65");                                       % get the white point
            xy_d65 = XYZ_d65(1:2) ./ sum(XYZ_d65);

            hue = atan2( xy(:,2)-xy_d65(2), xy(:,1)-xy_d65(1) );            % get the angle
            
        end

        function debug_hue (obj)
            % check whether hue is continuous

            clf
            hold on

            %plot(obj.hue)

            for i = 1:size(obj.rgb,1)                                        % draw n points
                plot(i,obj.hue(i),'o','Color',obj.rgb(i,1:3)/255);
            end

            plot(obj.xyz(:,1))
            plot(obj.xyz(:,2))
        end

    end

end


