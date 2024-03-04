classdef ColorMatchingFunction < handle
    %ColorMatchingFunction CIE color matching functions
    %   including color matching functions, spectral locus, and purple line
    % 3/4/2024 add purple line
    % 3/3/2024 for CIE CMF

    properties
        cmf_wl_x_y_z

        spectral_locus_xyz
        spectral_locus_theta
        spectral_locus_start_wl_x_y_index
        spectral_locus_end_wl_x_y_index
        spectral_locus_xyz_official

        purple_line_xy
        purple_line_theta
    end

    methods

        function show_color_matching_functions (obj, itv)

            cmf = obj.cmf_wl_x_y_z;

            if nargin < 2
                itv = 1:size(cmf,1);
            end

            % clf
            hold on

            w = cmf(itv,1);
            x = cmf(itv,2);
            y = cmf(itv,3);
            z = cmf(itv,4);

            plot(w,x,'.r')
            plot(w,y,'.g')
            plot(w,z,'.b')

            xlabel('Wavelength (nm)')

            ylabel('Spectral Power Distribution')
            set(gca,'yticklabel',[])

            hleg = legend('$\bar{x}$','$\bar{y}$','$\bar{z}$');
            set(hleg,'Interpreter','latex')
            axis([380 780 0 2.5])
        end

        function show_color_matching_functions_380_780 (obj)

            cmf = obj.cmf_wl_x_y_z;

            % clf
            hold on

            w = 380:780;
            x = interp1(cmf(:,1),cmf(:,2),w,'spline');
            y = interp1(cmf(:,1),cmf(:,3),w,'spline');
            z = interp1(cmf(:,1),cmf(:,4),w,'spline');

            plot(w,x,'r')
            plot(w,y,'g')
            plot(w,z,'b')

            xlabel('Wavelength (nm)')

            ylabel('Spectral Power Distribution')
            set(gca,'yticklabel',[])

            hleg = legend('$\bar{x}$','$\bar{y}$','$\bar{z}$');
            set(hleg,'Interpreter','latex')
            axis([380 780 0 2.5])

        end

        function xyz = calc_spectral_locus_xyz (obj)

            XYZ = obj.cmf_wl_x_y_z(:,2:4) * 1e8;
            wl = obj.cmf_wl_x_y_z(:,1);
            xyz = XYZ ./ sum(XYZ,2);
            obj.spectral_locus_xyz = [wl xyz];

            %
            % calculate the angle
            %
            obj.calc_spectral_locus_theta();

            obj.calc_purple_line();

        end

        function show_spectral_locus (obj, itv)
            if nargin < 2
                itv = 1:size(obj.spectral_locus_xyz,1);
            end

            hold on
            plot(obj.spectral_locus_xyz(itv,2), obj.spectral_locus_xyz(itv,3),'.')
            axis square
            xlabel('CIE x')
            ylabel('CIE y')
        end

        function show_spectral_locus_official (obj, itv)
            if nargin < 2
                itv = 1:size(obj.spectral_locus_xyz_official,1);
            end

            hold on
            plot(obj.spectral_locus_xyz_official(itv,2), obj.spectral_locus_xyz_official(itv,3),'.')
            axis square
            xlabel('CIE x')
            ylabel('CIE y')
        end

        function plot_spectral_locus_xy (obj, itv)
            if nargin < 2
                itv = 1:size(obj.spectral_locus_xyz,1);
            end

            hold on
            plot(obj.spectral_locus_xyz(itv,1),obj.spectral_locus_xyz(itv,2),'.-')
            plot(obj.spectral_locus_xyz(itv,1),obj.spectral_locus_xyz(itv,3),'.-')
        end

        function plot_spectral_locus_xy_official (obj, itv)
            if nargin < 2
                itv = 1:size(obj.spectral_locus_xyz_official,1);
            end

            hold on
            plot(obj.spectral_locus_xyz_official(itv,1),obj.spectral_locus_xyz_official(itv,2),'.-')
            plot(obj.spectral_locus_xyz_official(itv,1),obj.spectral_locus_xyz_official(itv,3),'.-')
        end

        function import_cie_data_xyz (obj, fn)
            % 'C:\Users\WCC4\OneDrive - FDA\Documents\github\MIS_acquire\@CMF_CIE_10deg\CIE_xyz_1964_10deg.csv'

            t = readtable(fn);
            cmf = table2array(t);

            for i = 1:size(cmf,1)
                fprintf('%d %e %e %e;\n',cmf(i,1),cmf(i,2),cmf(i,3),cmf(i,4))
            end
        end

        function import_cie_data_cc (obj, fn)
            % 'C:\Users\WCC4\OneDrive - FDA\Documents\github\MIS_acquire\@CMF_CIE_10deg\CIE_cc_1964_10deg.csv'

            t = readtable(fn);
            cmf = table2array(t);

            for i = 1:size(cmf,1)
                fprintf('%d %e %e;\n',cmf(i,1),cmf(i,2),cmf(i,3))
            end
        end

        function calc_spectral_locus_theta (obj)

            xyz = obj.spectral_locus_xyz(:,2:4);                               % get the xyz

            % XYZ_d65 = whitepoint("d65");                                       % get the white point
            % xyz_d65 = XYZ_d65 ./ sum(XYZ_d65);
            % 
            % theta = atan2(xyz(:,2)-xyz_d65(2),xyz(:,1)-xyz_d65(1));            % get the angle

            theta = obj.xy2hue(xyz(:,1:2));

            % making theta a continuous function
            % break the circle at -90 degree
            cutoff = -pi / 2;
            theta(theta<cutoff) = theta(theta<cutoff) + 2*pi;                  % if theta < -90, make it positive

            obj.spectral_locus_theta = theta;                                  % store the result

            [Mmax,Imax] = max(theta);                                          % find the max theta => the blue end
            [Mmin,Imin] = min(theta);                                          % find the min theta => the red end

            obj.spectral_locus_end_wl_x_y_index = [obj.spectral_locus_xyz(Imin,1) obj.spectral_locus_xyz(Imin,2) obj.spectral_locus_xyz(Imin,3) Imin]  ;
            obj.spectral_locus_start_wl_x_y_index = [obj.spectral_locus_xyz(Imax,1) obj.spectral_locus_xyz(Imax,2) obj.spectral_locus_xyz(Imax,3) Imax]  ;
        end

        function calc_purple_line (obj)
            % add the purple line between the first and last points of the
            % spectral locus
            xy2 = obj.spectral_locus_start_wl_x_y_index(2:3);
            xy1 = obj.spectral_locus_end_wl_x_y_index(2:3);

            pl_x = linspace(xy1(1),xy2(1),200)';                             % interpolation
            pl_y = linspace(xy1(2),xy2(2),200)';
            pl_xy = [pl_x pl_y];            

            obj.purple_line_xy = pl_xy;
            obj.purple_line_theta = obj.xy2hue(pl_xy);            
        end

        function hue = xy2hue (obj, xy)
            % xy is nx3

            XYZ_d65 = whitepoint("d65");                                       % get the white point
            xy_d65 = XYZ_d65(1:2) ./ sum(XYZ_d65);

            hue = atan2( xy(:,2)-xy_d65(2), xy(:,1)-xy_d65(1) );            % get the angle
            
        end


    end
end