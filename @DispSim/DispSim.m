%% Display simulator
classdef DispSim < handle
    
    properties
        sc
        spec_r
        spec_g
        spec_b
        classpath
        gamma_srgb
        
        vec_r
        vec_g
        vec_b
        
        HIMS
        vec_file = 'OL490_vec_HIMS2.mat'
    end
    
    methods
        
        function show_spectra (obj)
            %%SHOW_SPECTRA Plot the spectra of primary colors
            
            %clf
            hold on
            plot(380:1:780,obj.spec_r,'r');
            plot(380:1:780,obj.spec_g,'g');
            plot(380:1:780,obj.spec_b,'b');
            % axis([380 780 0 4e-4])
            legend('Red','Green','Blue')
            legend('Location','northwest')
            xlabel('Wavelengh (nm)')
            ylabel('SPD')
        end
        
        function [spec rgb_lin] = rgb2spec (obj,rgb)
            %%RGB2SPEC Predict the output spectrum of an sRGB input
            obj.build_gamma;
            
            rgb_lin = interp1(obj.gamma_srgb(:,1),obj.gamma_srgb(:,2),rgb/255.0);
            spec = obj.spec_r * rgb_lin(1) + obj.spec_g * rgb_lin(2) + obj.spec_b * rgb_lin(3);
        end
        
        function build_gamma (obj)
            %%BUILD_GAMMA Build the LUT for sRGB gamma
            
            ddl = [0:255]/255;
            rgb = [ddl' ddl' ddl'];
            lab = rgb2lab(rgb);
            xyz = lab2xyz(lab);
            obj.gamma_srgb(:,1) = ddl;
            obj.gamma_srgb(:,2) = xyz(:,2);
            
            %            plot(obj.gamma_srgb(:,1),obj.gamma_srgb(:,2))
        end
        
        function rgb_lin = gamut (obj)
            %%GAMUT Show the 2D triangle color gamuts on CIE chromaticity
            %%diagram
            
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
        
        function OL490_model (obj,ol490sim)
            %%OL490_model Calculate the OL490 vec needed to generate the
            %%spectra
            
            'Modeling R'
            vec_r = ol490sim.INV_spd2vec(obj.spec_r);
            'Modeling G'
            vec_g = ol490sim.INV_spd2vec(obj.spec_g);
            'Modeling B'
            vec_b = ol490sim.INV_spd2vec(obj.spec_b);
            
            vec_filename = sprintf('%s/%s',obj.classpath,obj.vec_file);
            save(vec_filename,'vec_r','vec_g','vec_b')
            
        end
        
        function OL490_load_vec (obj)
            %%OL490_model Load the pre-calculated OL490 vec needed to generate the
            %%spectra
            
            vec_filename = sprintf('%s/%s',obj.classpath,obj.vec_file);
            load(vec_filename,'vec_r','vec_g','vec_b')
            obj.vec_r = vec_r;
            obj.vec_g = vec_g;
            obj.vec_b = vec_b;
            
        end
        
        %
        % Matching colors for calculating metamers
        %
        function rgb_lin = XYZ2RGB_lin (obj, XYZ_target)
            %XYZ2RGB_LIN Find the linear RGB for the display to generate
            %XYZ
            
            % XYZ_target is 1x3
            assert(isequal(size(XYZ_target),[1 3]))
            
            spec_r = obj.spec_r(1:10:end)';
            spec_g = obj.spec_g(1:10:end)';
            spec_b = obj.spec_b(1:10:end)';
            
            cc = ColorConversionClass;
            
            XYZ_r = cc.spd2XYZ(spec_r);
            XYZ_g = cc.spd2XYZ(spec_g);
            XYZ_b = cc.spd2XYZ(spec_b);
            
            M = [XYZ_r' XYZ_g' XYZ_b'];
            M_inv = inv(M);
            
            rgb_lin = M_inv*XYZ_target';
            
        end
        
        function vec = RGB_lin2vec (obj, rgb_lin)
            %RGB_LIN2VEC Mix the RGB vec values according to rgb_lin
            %
            
            % assume additivity
            vec = obj.vec_r * rgb_lin(1) + obj.vec_g * rgb_lin(2) + obj.vec_b * rgb_lin(3);
            
            % trimming
            vec = max(0,vec);
            vec = min(1,vec);
        end
        
    end
    
    methods (Static)
        
        function show_primary_spectra_holo_only
            %% Primary Analysis of Three Displays
            %% Preparation
            
            rift = RiftSim(2)
            hp = HPZ24xSim(2)
            nec = NECPA271Sim(2)
            holo = Hololens2(2)
            
            % Spectral comparison of the red, green, and blue primary colors of the simulated displays

            xa = 380:780;
            axisrange = [380 780 0 4e-4] ;
            lw = 2;
            tfs = 12;
            
            clf
            t = tiledlayout(2,3,'TileSpacing','Tight')

            nexttile(1)
            plot(xa,rift.spec_b,'b','LineWidth',lw)
            axis(axisrange)
            %xlabel('Wavelength (nm)')
            ylabel('Oculus','FontSize',tfs,'FontWeight','bold')
            axis square

            nexttile(2)
            plot(xa,rift.spec_g,'g','LineWidth',lw)
            axis(axisrange)
            yticklabels({});
            %xlabel('Wavelength (nm)')
            axis square

            nexttile(3)
            plot(xa,rift.spec_r,'r','LineWidth',lw)
            axis(axisrange)
            yticklabels({});
            %xlabel('Wavelength (nm)')
            axis square

            nexttile(4)
            plot(xa,holo.spec_b,'b','LineWidth',lw)
            axis(axisrange)
            %xlabel('Wavelength (nm)')
            ylabel('Hololens2','FontSize',tfs,'FontWeight','bold')
            axis square
            
            nexttile(5)
            plot(xa,holo.spec_g,'g','LineWidth',lw)
            axis(axisrange)
            yticklabels({});
            %xlabel('Wavelength (nm)')
            axis square

            nexttile(6)
            plot(xa,holo.spec_r,'r','LineWidth',lw)
            axis(axisrange)
            yticklabels({});
            %xlabel('Wavelength (nm)')
            axis square
            
            t.XLabel.String = 'Wavelength (nm)';
            %t.YLabel.String = 'Power';

            a = gcf;
            a.Position = [1557 518 640 465];

            saveas(gcf,'compare3spectra.png')
            
            return
        end
        
        function show_primary_spectra
            %% Primary Analysis of Three Displays
            %% Preparation
            
            rift = RiftSim(2)
            hp = HPZ24xSim(2)
            nec = NECPA271Sim(2)
            holo = Hololens2(2)
            
            % Spectral comparison of the red, green, and blue primary colors of the simulated displays

            xa = 380:780;
            axisrange = [380 780 0 4e-4] ;
            lw = 2;
            tfs = 12;
            
            clf
            t = tiledlayout(4,3,'TileSpacing','Compact')

            
            nt = nexttile(1);
            plot(xa,nec.spec_b,'b','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            title('Blue','FontSize',tfs)  
            ylabel('NEC','FontSize',tfs,'FontWeight','bold')
            PlotBeautify(nt)
            legend off
            
            nt = nexttile(2)
            plot(xa,nec.spec_g,'g','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            title('Green','FontSize',tfs)            
            PlotBeautify(nt)
            legend off

            nt = nexttile(3)
            plot(xa,nec.spec_r,'r','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            xticklabels({});
            yticklabels({});
            title('Red','FontSize',tfs)            
            PlotBeautify(nt)
            legend off

            nt = nexttile(4)
            plot(xa,hp.spec_b,'b','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            ylabel('HP','FontSize',tfs,'FontWeight','bold')
            PlotBeautify(nt)
            legend off
            
            nt = nexttile(5)
            plot(xa,hp.spec_g,'g','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            PlotBeautify(nt)
            legend off

            nt = nexttile(6)
            plot(xa,hp.spec_r,'r','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            PlotBeautify(nt)
            legend off

            nt = nexttile(7)
            plot(xa,rift.spec_b,'b','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            %xlabel('Wavelength (nm)')
            ylabel('Rift','FontSize',tfs,'FontWeight','bold')
            PlotBeautify(nt)
            legend off

            nt = nexttile(8)
            plot(xa,rift.spec_g,'g','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            yticklabels({});
            %xlabel('Wavelength (nm)')
            PlotBeautify(nt)
            legend off

            nt = nexttile(9)
            plot(xa,rift.spec_r,'r','LineWidth',lw)
            xticklabels({});
            yticklabels({});
            axis(axisrange)
            yticklabels({});
            %xlabel('Wavelength (nm)')
            PlotBeautify(nt)
            legend off

            nt = nexttile(10)
            plot(xa,holo.spec_b,'b','LineWidth',lw)
            yticklabels({});            
            axis(axisrange)
            %xlabel('Wavelength (nm)')
            ylabel('Hololens2','FontSize',tfs,'FontWeight','bold')
            PlotBeautify(nt)
            legend off
            
            nt = nexttile(11)
            plot(xa,holo.spec_g,'g','LineWidth',lw)
            axis(axisrange)
            yticklabels({});
            xlabel('Wavelength (nm)','FontSize',tfs)
            PlotBeautify(nt)
            legend off

            nt = nexttile(12)
            plot(xa,holo.spec_r,'r','LineWidth',lw)
            axis(axisrange)
            yticklabels({});
            %xlabel('Wavelength (nm)')
            PlotBeautify(nt)
            legend off
            
            %t.XLabel.String = 'Wavelength (nm)';
            %t.YLabel.String = 'Power';

            a = gcf;
            a.Units = 'inch';
            a.Position = [-0.2812 0.5104 12.9271 10.6354];

            saveas(gcf,'compare3spectra.png')
            
            return
        end
        
        function show_primary_chromaticity_holo_only
            
            % Color gamuts of the three displays to be simulated
            
            rift = RiftSim(2)
            holo = Hololens2(2)
            
            srgb = [0.64 0.33; 0.3 0.6 ; 0.15 0.06];
            p3 = [0.68 0.32; 0.265 0.69 ; 0.15 0.06];
            rec2020 = [0.708 0.292; 0.170 0.797 ; 0.131 0.046];
            
            cc = ColorConversionClass;
            
            clf
            hold on
            plot(srgb([1 2 3 1],1),srgb([1 2 3 1],2),':')
            plot(p3([1 2 3 1],1),p3([1 2 3 1],2),':')
            plot(rec2020([1 2 3 1],1),rec2020([1 2 3 1],2),':')
            
            dp = holo;
            XYZ_r = cc.spd2XYZ(dp.spec_r(1:10:end)');
            XYZ_g = cc.spd2XYZ(dp.spec_g(1:10:end)');
            XYZ_b = cc.spd2XYZ(dp.spec_b(1:10:end)');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            plot([xyz_r(1) xyz_g(1) xyz_b(1) xyz_r(1)],[xyz_r(2) xyz_g(2) xyz_b(2) xyz_r(2)],'o')
            
            dp = rift;
            XYZ_r = cc.spd2XYZ(dp.spec_r(1:10:end)');
            XYZ_g = cc.spd2XYZ(dp.spec_g(1:10:end)');
            XYZ_b = cc.spd2XYZ(dp.spec_b(1:10:end)');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            plot([xyz_r(1) xyz_g(1) xyz_b(1) xyz_r(1)],[xyz_r(2) xyz_g(2) xyz_b(2) xyz_r(2)],'v')
            
            axis([0 1 0 1])
            axis equal
            xlabel('CIE x')
            ylabel('CIE y')
            
            
            legend('sRGB','DCI-P3','Rec 2020','HoloLens2','Oculus')
        end
    
        function show_primary_chromaticity
            
            % Color gamuts of the three displays to be simulated
            
            rift = RiftSim(2)
            hp = HPZ24xSim(2)
            nec = NECPA271Sim(2)
            holo = Hololens2(2)
            
            srgb = [0.64 0.33; 0.3 0.6 ; 0.15 0.06];
            p3 = [0.68 0.32; 0.265 0.69 ; 0.15 0.06];
            rec2020 = [0.708 0.292; 0.170 0.797 ; 0.131 0.046];
            
            cc = ColorConversionClass;
            
            clf
            hold on
            plot(srgb([1 2 3 1],1),srgb([1 2 3 1],2),':')
            plot(p3([1 2 3 1],1),p3([1 2 3 1],2),':')
            plot(rec2020([1 2 3 1],1),rec2020([1 2 3 1],2),':')
            
            dp = holo;
            XYZ_r = cc.spd2XYZ(dp.spec_r(1:10:end)');
            XYZ_g = cc.spd2XYZ(dp.spec_g(1:10:end)');
            XYZ_b = cc.spd2XYZ(dp.spec_b(1:10:end)');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            plot([xyz_r(1) xyz_g(1) xyz_b(1) xyz_r(1)],[xyz_r(2) xyz_g(2) xyz_b(2) xyz_r(2)],'o')
            
            dp = rift;
            XYZ_r = cc.spd2XYZ(dp.spec_r(1:10:end)');
            XYZ_g = cc.spd2XYZ(dp.spec_g(1:10:end)');
            XYZ_b = cc.spd2XYZ(dp.spec_b(1:10:end)');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            plot([xyz_r(1) xyz_g(1) xyz_b(1) xyz_r(1)],[xyz_r(2) xyz_g(2) xyz_b(2) xyz_r(2)],'v')
            
            
            dp = nec;
            XYZ_r = cc.spd2XYZ(dp.spec_r(1:10:end)');
            XYZ_g = cc.spd2XYZ(dp.spec_g(1:10:end)');
            XYZ_b = cc.spd2XYZ(dp.spec_b(1:10:end)');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            plot([xyz_r(1) xyz_g(1) xyz_b(1) xyz_r(1)],[xyz_r(2) xyz_g(2) xyz_b(2) xyz_r(2)],'s')
            
            dp = hp;
            XYZ_r = cc.spd2XYZ(dp.spec_r(1:10:end)');
            XYZ_g = cc.spd2XYZ(dp.spec_g(1:10:end)');
            XYZ_b = cc.spd2XYZ(dp.spec_b(1:10:end)');
            
            xyz_r = XYZ_r / sum(XYZ_r);
            xyz_g = XYZ_g / sum(XYZ_g);
            xyz_b = XYZ_b / sum(XYZ_b);
            
            plot([xyz_r(1) xyz_g(1) xyz_b(1) xyz_r(1)],[xyz_r(2) xyz_g(2) xyz_b(2) xyz_r(2)],'^')
            
            
            axis([0 1 0 1])
            axis equal
            xlabel('CIE x')
            ylabel('CIE y')
            
            
            legend('sRGB','DCI-P3','Rec 2020','HoloLens2','Oculus','NEC','HP')
        end
    end
end

