%% Generate colored chromaticity diagram
% Q: How to show the color gamut boundaries of sRGB in CIEXYZ xyY?
% 7-4-2022
% 12-19-2018
% 12-20-2018

classdef RGB_in_xyY < handle

    properties

        rgb_space = 'srgb'
        interval_step = 15
        wall_transparency = 0.3

        % user parameters
        % interval_step = 15;                      % resolution of the mesh
        % wall_transparency = 0.3;

        % constants used by subroutines
        interval
        interval_rev
    end

    methods

        function obj = wg51 (obj)
            %% for IEC WG51 tutorial
            % constants used by subroutines
            obj.interval = 0:obj.interval_step:255;
            obj.interval_rev = 255:-obj.interval_step:0;
            obj.rgb_space = 'srgb';
            obj.interval_step = 15;
            obj.wall_transparency = 0.1;

            % 3D plot

            % fg = figure('Units','inches','Position',[2 2 8 8]);

            hold on

            grid on

            % add labels
            xlabel('CIEXYZ x')
            ylabel('CIEXYZ y')
            zlabel('CIEXYZ Y')

            % change background to gray because white background cannot show 255,255,255
            ax = gca;
            ax.Color = [1 1 1]*0.85;

            axis([0 0.8 0 0.85])
            % view(0,90)

            view(22,14)

            % turn on the rotation button
            rotate3d on

            return

        end

        function obj = RGB_in_xyY
            % constants used by subroutines
            obj.interval = 0:obj.interval_step:255;
            obj.interval_rev = 255:-obj.interval_step:0;
        end
        
        function sRGB_in_xyY (obj)
        % created another method so that the constructer does not generate figure

            % 3D plot

            % fg = figure('Units','inches','Position',[2 2 8 8]);

            hold on

            if 0
                obj.spectral_locus
            end

            if 1
                obj.paint_6_walls;
            end

            if 1
                obj.draw_primary_lines;
            end

            if 1
                obj.draw_chroma_lines;
            end

            if 0
                % show the Z-axis
                quiver3(0,0,0,0,0,1,0,'k')
            end

            grid on

            % add labels
            xlabel('CIEXYZ x')
            ylabel('CIEXYZ y')
            zlabel('CIEXYZ Y')

            % change background to gray because white background cannot show 255,255,255
            ax = gca;
            ax.Color = [1 1 1]*0.85;

            axis([0 0.8 0 0.85 0 1])

            view(22,14)

            % turn on the rotation button
            rotate3d on

            return

        end

        function paint_6_walls (obj)
            obj.plot_wall(obj.prep_rgb_wall_rg);
            obj.plot_wall(obj.prep_rgb_wall_gb);
            obj.plot_wall(obj.prep_rgb_wall_rb);
            obj.plot_wall(obj.prep_rgb_wall_r);
            obj.plot_wall(obj.prep_rgb_wall_g);
            obj.plot_wall(obj.prep_rgb_wall_b);
        end

        function draw_grayscale (obj)
            
            obj.spectral_locus_color

            % add primary lines
            gray_scale = obj.prep_gray_scale;
            XYZ_gray_scale = rgb2xyz(gray_scale/255,'ColorSpace',obj.rgb_space);
            Yxy_gray_scale = XYZ_gray_scale;
            Yxy_gray_scale(:,1) = XYZ_gray_scale(:,2);
            Yxy_gray_scale(:,2) = XYZ_gray_scale(:,1)./sum(XYZ_gray_scale,2);
            Yxy_gray_scale(:,3) = XYZ_gray_scale(:,2)./sum(XYZ_gray_scale,2);
            obj.show_as_balls(Yxy_gray_scale,gray_scale)

            % add labels
            xlabel('CIEXYZ x')
            ylabel('CIEXYZ y')
            zlabel('CIEXYZ Y')

            % change background to gray because white background cannot show 255,255,255
            ax = gca;
            ax.Color = [1 1 1]*0.85;

            axis([0 0.8 0 0.85 0 1])
            view(25,10)
            grid on

            % turn on the rotation button
            rotate3d on
        end

        function draw_colorscale (obj)
            
            obj.spectral_locus_color

            % add primary lines
            rgb_primary = obj.prep_rgb_primary_only;
            XYZ_primary = rgb2xyz(rgb_primary/255,'ColorSpace',obj.rgb_space);
            Yxy_primary = XYZ_primary;
            Yxy_primary(:,1) = XYZ_primary(:,2);
            Yxy_primary(:,2) = XYZ_primary(:,1)./sum(XYZ_primary,2);
            Yxy_primary(:,3) = XYZ_primary(:,2)./sum(XYZ_primary,2);
            obj.show_as_balls(Yxy_primary,rgb_primary)

            % add labels
            xlabel('CIEXYZ x')
            ylabel('CIEXYZ y')
            zlabel('CIEXYZ Y')

            % change background to gray because white background cannot show 255,255,255
            ax = gca;
            ax.Color = [1 1 1]*0.85;

            axis([0 0.8 0 0.85 0 1])
            view(25,10)
            grid on

            % turn on the rotation button
            rotate3d on
            
        end

        function draw_primary_lines (obj)
            % add primary lines
            rgb_primary = obj.prep_rgb_primary;
            XYZ_primary = rgb2xyz(rgb_primary/255,'ColorSpace',obj.rgb_space);
            Yxy_primary = XYZ_primary;
            Yxy_primary(:,1) = XYZ_primary(:,2);
            Yxy_primary(:,2) = XYZ_primary(:,1)./sum(XYZ_primary,2);
            Yxy_primary(:,3) = XYZ_primary(:,2)./sum(XYZ_primary,2);
            obj.show_as_lines(Yxy_primary,rgb_primary)
        end

        function draw_chroma_lines (obj)
                % add primary lines
                rgb_chroma = obj.prep_rgb_chroma;
                XYZ_chroma = rgb2xyz(rgb_chroma/255,'ColorSpace',obj.rgb_space);
                Yxy_chroma = XYZ_chroma;
                Yxy_chroma(:,1) = XYZ_chroma(:,2);
                Yxy_chroma(:,2) = XYZ_chroma(:,1)./sum(XYZ_chroma,2);
                Yxy_chroma(:,3) = XYZ_chroma(:,2)./sum(XYZ_chroma,2);
                obj.show_as_lines(Yxy_chroma,rgb_chroma)
        end


        function spectral_locus_color (obj)
            
            lut = obj.my_spectral_locus;

            if 0
            polarplot(lut(:,1),lut(:,2))
            end

            rs = 0.001;

            [x y] = meshgrid(0:rs:1,0:rs:1);
            z = 1 - x - y;

            % CIE x y
            x1 = x(:);
            y1 = y(:);

            % calculate center
            XYZ_d65 = rgb2xyz([1 1 1]);
            xyz_d65 = XYZ_d65 ./ sum(XYZ_d65);
            x_d65 = xyz_d65(1);
            y_d65 = xyz_d65(2);

            % calculate hue
            theta = atan2((y1 - y_d65),(x1 - x_d65));
            theta = theta + 2*pi;
            theta = mod(theta,2*pi);

            % calculate chroma
            chroma = ((y1 - y_d65).^2 + (x1 - x_d65).^2) ;

            t2 = theta';
            t3 = repmat(t2,size(lut,1),1);

            lut3 = repmat(lut(:,1),1,size(t3,2));
            diff3 = lut3 - t3;
            diff4 = sign(diff3);
            diff5 = diff4<=0;
            diff6 = sum(diff5,1)';            

            diff6 = min(size(lut,1)-1,diff6);

            mask = chroma > lut(diff6+1,2);

            XYZ1 = lut(diff6+1,3:5);
            XYZ1(mask,1) = 0;
            XYZ1(mask,2) = 0;
            XYZ1(mask,3) = 0;

            alpha = chroma ./ lut(diff6+1,2);
            XYZ1 = [alpha alpha alpha] .* XYZ1 + [(1-alpha) (1-alpha) (1-alpha)] .* repmat(XYZ_d65,size(XYZ1,1),1);

            rgb1 = xyz2rgb(XYZ1);

            rgb = reshape(rgb1,size(x,1),size(x,2),3);
            
            %clf
%             image(flipud(rgb))
%             axis equal

            return


            locus = obj.my_spectral_locus;

            XYZ1 = zeros(size(x1,1),3);
            XYZ1(:,1) = XYZ_d65(1);
            XYZ1(:,2) = XYZ_d65(2);
            XYZ1(:,3) = XYZ_d65(3);

            mask = chroma < 0.5;
            XYZ1(mask,1) = 0;
            XYZ1(mask,2) = 0;
            XYZ1(mask,3) = 0;

            rgb1 = xyz2rgb(XYZ1);
            rgb = reshape(rgb1,size(x,1),size(x,2),3);

            image(rgb)
            axis equal

            return



            
            % targetY = 0.5 / (X1 + Y1 + Z1);
            %
            % X1 = X1 ./ Y1 .* targetY;
            % Y1 = Y1 ./ Y1 .* targetY;
            % Z1 = Z1 ./ Y1 .* targetY;

            XYZ1 = [X1 Y1 Z1];
            mask = (Z1 < 0) | (Z1 > 1);


            rgb1 = xyz2rgb(XYZ1);
            rgb1my = rgb1;

            %rgb1(mask0,:) = 0;

            mask1 = (rgb1(:,1) < 0);
            mask11 = (rgb1(:,1) > 1);
            mask111 = (rgb1(:,1) <1.6);

            mask2 = (rgb1(:,2) < 0);
            mask22 = (rgb1(:,2) > 1);
            mask3 = (rgb1(:,3) < 0);
            mask33= (rgb1(:,3) > 1);

            rgb1(mask1,:) = 0;
            %rgb1(mask11,:) = 0;
            rgb1(mask2,:) = 0;
            rgb1(mask22,:) = 0;
            rgb1(mask3,:) = 0;
            rgb1(mask33,:) = 0;

            rgb = uint8(reshape(rgb1,size(X,1),size(X,2),3)*255);
            rgbflipped = flipud(rgb);
            image(rgbflipped)
            axis equal

        end

        function spectral_locus (obj)

            cc = ColorConversionClass;

            data = zeros(41,2);
            for w = 1:41
                sp = zeros(41,1);
                sp(w) = 100000;
                XYZ = cc.spd2XYZ(sp);
                xyz = XYZ ./ sum(XYZ);
                data(w,:) = xyz(1:2);
            end

            data2 = zeros(401,2);
            data2(:,1) = interp1(380:10:780,data(:,1),380:780,'spline');
            data2(:,2) = interp1(380:10:780,data(:,2),380:780,'spline');

            % add purple line
            xy1 = data2(1,:);
            xy2 = data2(end,:);
            pl_x = linspace(xy1(1),xy2(1),200)';
            pl_y = linspace(xy1(2),xy2(2),200)';
            pl_xy = [pl_x pl_y];

            data2 = [data2 ; pl_xy];

            lut_theta_rgb = obj.calc_triangle;

            XYZ_d65 = rgb2xyz([1 1 1]);
            xyz_d65 = XYZ_d65 ./ sum(XYZ_d65);

            %clf
            hold on
            for i = 1:size(data2,1)-1
                % calculate the angle
                xy = data2(i,1:2);

                th = atan2(xy(2)-xyz_d65(2),xy(1)-xyz_d65(1));
                th = th + 2*pi;
                th = mod(th,2*pi);

                % linear search
                j = 1;
                while (th > lut_theta_rgb(j,1)) && j < size(lut_theta_rgb,1)
                    j = j + 1;
                end

                rgb = lut_theta_rgb(j,2:4);

                plot(data2(i:i+1,1),data2(i:i+1,2),'-','LineWidth',2,'Color',rgb/255);
            end

            axis equal
            axis([0 1 0 1])

        end

        function ret = my_spectral_locus (obj)

            cc = ColorConversionClass;

            % center
            XYZ_d65 = rgb2xyz([1 1 1]);
            xyz_d65 = XYZ_d65 ./ sum(XYZ_d65);

            % get 380:10:780
            data = zeros(41,2);
            for w = 1:41
                sp = zeros(41,1);
                sp(w) = 100000;
                XYZ = cc.spd2XYZ(sp);
                xyz = XYZ ./ sum(XYZ);
                data(w,:) = xyz(1:2);
            end

            % get 380:1:780
            data_xy = zeros(401,2);
            data_xy(:,1) = interp1(380:10:780,data(:,1),380:780,'spline');
            data_xy(:,2) = interp1(380:10:780,data(:,2),380:780,'spline');

            % add purple line
            xy1 = data_xy(1,:);
            xy2 = data_xy(end,:);
            pl_x = linspace(xy1(1),xy2(1),200)';
            pl_y = linspace(xy1(2),xy2(2),200)';
            pl_xy = [pl_x pl_y];

            data_xy = [data_xy ; pl_xy];

            % calculate theta
            theta = atan2(data_xy(:,2)-xyz_d65(2),data_xy(:,1)-xyz_d65(1));
            theta = theta + 2*pi;
            theta = mod(theta,2*pi);
            
            chroma = ((data_xy(:,2)-xyz_d65(2)).^2 + (data_xy(:,1)-xyz_d65(1)).^2 ) ;

            % get triangle
            lut = obj.my_calc_triangle;
            
            data_XYZ = zeros(size(data_xy,1),3);

            for i = 1:size(data_xy,1)
                % calculate the angle
                xy = data_xy(i,1:2);

                % linear search
                j = 1;
                while (theta(i,:) > lut(j,1)) && (j < size(lut,1))
                    j = j + 1;
                end

                data_XYZ(i,:) = lut(j,5:7);
            end

            ret = [theta chroma data_XYZ];
            ret = sortrows(ret,1);
            
            if 1
            clf
            hold on
            for i = 1:size(data_xy,1)-1
                rgb = xyz2rgb(data_XYZ(i,:));
                rgb = min(1,rgb);
                rgb = max(0,rgb);
                plot(data_xy(i:i+1,1),data_xy(i:i+1,2),'-','Color',rgb)
            end            

            axis equal
            axis([0 1 0 1])
            end

        end

        function lut = my_calc_triangle (obj)

            rgb = obj.prep_rgb_chroma;

            if 0
                clf
                plot(xyz(:,1),xyz(:,2),'o');
            end

            XYZ = rgb2xyz(rgb/255);
            xyz = XYZ ./ sum(XYZ,2);

            XYZ_d65 = rgb2xyz([1 1 1]);
            xyz_d65 = XYZ_d65 ./ sum(XYZ_d65);

            theta = atan2(xyz(:,2)-xyz_d65(2),xyz(:,1)-xyz_d65(1));
            theta = theta + 2*pi;
            theta = mod(theta,2*pi);

            lut = [theta rgb XYZ];
            lut = sortrows(lut,1);

            if 0
                clf
                hold on
                for i = 1:size(rgb,1)
                    plot(cos(lut(i,1)),sin(lut(i,1)),'o','Color',lut(i,2:4)/255)
                end
                axis equal
            end

        end
        
        function lut = calc_triangle (obj)
            rgb = obj.prep_rgb_chroma;

            if 0
                clf
                plot(xyz(:,1),xyz(:,2),'o');
            end

            XYZ = rgb2xyz(rgb);
            xyz = XYZ ./ sum(XYZ,2);

            XYZ_d65 = rgb2xyz([1 1 1]);
            xyz_d65 = XYZ_d65 ./ sum(XYZ_d65);

            theta = atan2(xyz(:,2)-xyz_d65(2),xyz(:,1)-xyz_d65(1));
            theta = theta + 2*pi;
            theta = mod(theta,2*pi);

            lut = [theta rgb];
            lut = sortrows(lut,1);

            if 0
                clf
                hold on
                for i = 1:size(rgb,1)
                    plot(cos(lut(i,1)),sin(lut(i,1)),'o','Color',lut(i,2:4)/255)
                end
                axis equal
            end

        end

        %
        % generate an animated GIF
        %
        function create_animation (obj)

            % fix the camera view
            axis vis3d

            filename = 'color_scale_in_CIELAB.gif'

            for n = 1:360/10

                camorbit(10,0,'data',[0 0 1])

                % Capture the plot as an image
                frame = getframe(gcf);
                im = frame2im(frame);
                [imind,cm] = rgb2ind(im,256);

                % Write to the GIF File
                if n == 1
                    imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
                else
                    imwrite(imind,cm,filename,'gif','WriteMode','append');
                end

            end

        end

        %
        % show one of the 6 walls
        %
        function plot_wall (obj,rgb)

            XYZ_primary = rgb2xyz(rgb/255,'ColorSpace',obj.rgb_space);
            Yxy_primary = XYZ_primary;
            Yxy_primary(:,:,1) = XYZ_primary(:,:,2);
            Yxy_primary(:,:,2) = XYZ_primary(:,:,1)./sum(XYZ_primary,3);
            Yxy_primary(:,:,3) = XYZ_primary(:,:,2)./sum(XYZ_primary,3);

            surf(Yxy_primary(:,:,2),Yxy_primary(:,:,3),Yxy_primary(:,:,1),rgb/255,...
                'EdgeColor','none','FaceAlpha',obj.wall_transparency)
        end


        function rgb = prep_rgb_wall_rg (obj)

            rgb = zeros(255/obj.interval_step,255/obj.interval_step,3);

            for i = obj.interval
                k1 = i/obj.interval_step + 1;
                for j = obj.interval
                    k2 = j/obj.interval_step + 1;

                    rgb(k1,k2,:) = [i j 0];
                end
            end

        end


        function rgb = prep_rgb_wall_gb (obj)

            rgb = zeros(255/obj.interval_step,255/obj.interval_step,3);

            for i = obj.interval
                k1 = i/obj.interval_step + 1;
                for j = obj.interval
                    k2 = j/obj.interval_step + 1;

                    rgb(k1,k2,:) = [0 i j];
                end
            end

        end

        function rgb = prep_rgb_wall_rb (obj)

            rgb = zeros(255/obj.interval_step,255/obj.interval_step,3);

            for i = obj.interval
                k1 = i/obj.interval_step + 1;
                for j = obj.interval
                    k2 = j/obj.interval_step + 1;

                    rgb(k1,k2,:) = [i 0 j];
                end
            end

        end


        function rgb = prep_rgb_wall_r (obj)

            rgb = zeros(255/obj.interval_step,255/obj.interval_step,3);

            for i = obj.interval
                k1 = i/obj.interval_step + 1;
                for j = obj.interval
                    k2 = j/obj.interval_step + 1;

                    rgb(k1,k2,:) = [255 i j];
                end
            end

        end

        function rgb = prep_rgb_wall_g (obj)

            rgb = zeros(255/obj.interval_step,255/obj.interval_step,3);

            for i = obj.interval
                k1 = i/obj.interval_step + 1;
                for j = obj.interval
                    k2 = j/obj.interval_step + 1;

                    rgb(k1,k2,:) = [i 255 j];
                end
            end

        end

        function rgb = prep_rgb_wall_b (obj)

            rgb = zeros(255/obj.interval_step,255/obj.interval_step,3);

            for i = obj.interval
                k1 = i/obj.interval_step + 1;
                for j = obj.interval
                    k2 = j/obj.interval_step + 1;

                    rgb(k1,k2,:) = [i j 255];
                end
            end

        end

        function rgb = prep_gray_scale (obj)

            rgb = zeros(255/obj.interval_step,3);
            k = 0;

            if 1
                % gray
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i i i];
                end
            end
        end

        function rgb = prep_rgb_primary_only (obj)
            rgb = zeros(255/obj.interval_step,3);
            k = 0;

            % red
            for i = obj.interval
                k = k + 1;
                rgb(k,:) = [i 0 0];
            end

            % green
            for i = obj.interval
                k = k + 1;
                rgb(k,:) = [0 i 0];
            end

            % blue
            for i = obj.interval
                k = k + 1;
                rgb(k,:) = [0 0 i];
            end
        end

        function rgb = prep_rgb_primary (obj)

            rgb = zeros(255/obj.interval_step,3);
            k = 0;

            if 1
                % gray
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i i i];
                end
            end

            if 1
                % red
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i 0 0];
                end
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [255 i i];
                end

                % green
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [0 i 0];
                end
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i 255 i];
                end

                % blue
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [0 0 i];
                end
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i i 255];
                end
            end

            if 1
                % yellow
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i i 0];
                end
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [255 255 i];
                end

                % cyan
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [0 i i];
                end
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i 255 255];
                end

                % magenta
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [i 0 i];
                end
                for i = obj.interval
                    k = k + 1;
                    rgb(k,:) = [255 i 255];
                end

            end

        end

        %
        % colors with the largest chroma
        %
        function rgb = prep_rgb_chroma (obj)

            rgb = zeros(255/15,3);
            k = 0;

            for i = obj.interval
                k = k + 1;
                rgb(k,:) = [255 i 0];
            end

            for i = obj.interval_rev
                k = k + 1;
                rgb(k,:) = [i 255 0];
            end

            for i = obj.interval
                k = k + 1;
                rgb(k,:) = [0 255 i];
            end

            for i = obj.interval_rev
                k = k + 1;
                rgb(k,:) = [0 i 255];
            end

            for i = obj.interval
                k = k + 1;
                rgb(k,:) = [i 0 255];
            end

            for i = obj.interval_rev
                k = k + 1;
                rgb(k,:) = [255 0 i];
            end

        end

        function rgb = prep_rgb_sample_original (obj)
            rgb = [0 0 0;
                096 000 080;
                096 096 176;
                080 192 080;
                224 224 080;
                208 144 000;
                255 0 0;
                255 255 255
                ];
        end


        function show_as_balls (obj,lab,rgb)
            hold on
            % show balls
            for k = 1:size(lab,1)

                plot3(lab(k,2),lab(k,3),lab(k,1),'o',...
                    'MarkerFaceColor',rgb(k,:)/255,...
                    'MarkerEdgeColor',[0 0 0],...
                    'MarkerSize',5)

                if 1
                    % add text labels
                    step = k-1;
                    txt = sprintf('#%d',step);
                    text(lab(k,2)+10,lab(k,3),lab(k,1),txt)
                end

            end

        end

        function show_as_lines (obj,lab,rgb)
            % show lines

            for k = 1:size(lab,1)-1

                plot3(lab(k:k+1,2),lab(k:k+1,3),lab(k:k+1,1),'-',...
                    'Color',rgb(k,:)/255)

            end

        end

    end

end

