%% 
% Obtain multispectral data with a single code
% need to have "ol490 = OL490Class" before running the code; nothing else
% 25 slices per run
% NEED: RANGE, STEP

%% 
function main_3pass (foldername, ol490, big_or_small)

tic

load('config.mat','LUDL_PORT');

ludl = LudlClass(LUDL_PORT);

%foldername_white = [foldername '_white']
load ('datain/spec_cied65','spec');
ls = spec(1:10:401,2);
%% 0: choose ROI and focus

if 1 

    % determine the ROI locations for target and reference white
    findroi
    ludl.close;
    % save the ROI locations
    mkdir(foldername)
    save([foldername '\info.mat'],'xy','xy_white','z','z_white')

else
    
    % shortcut: use the previously saved locations
    load([foldername '\info.mat'],'xy','xy_white','z','z_white')

end

%% 1: take frames
        c = 1;
        A = [-12000 -9600];
        B = [12000 0];
        C = [0, 9600];
        
        load('config.mat','LUDL_PORT');
        ludl = LudlClass(LUDL_PORT);
        ludl.setXY(xy);
        ludl.close; 
        [ret, n] = myfocus_wavelength3;
        f_init = ret
        f_range = 800
        f_step = 100
        load('config.mat','LUDL_PORT');
        ludl = LudlClass(LUDL_PORT);

 for i= 1:9
        % image roi
            %f_init=ret;
            if i ==2
            xy = xy + A;
            elseif i ==3 || i ==4
            xy = xy +B;
            elseif i ==5 || i ==6
            xy = xy + C;
            elseif i ==7 || i ==8
            xy = xy - B;
            elseif i ==9
            xy = xy - C;
        end
        f = [foldername '_region' num2str(i,'%02d')];
        mkdir(f)
        c=1;
    for focus = f_init-f_range: f_step : f_init+f_range
        
        ludl.setXY(xy);
        ludl.setZ(focus);
        a = [foldername '_slice' num2str(c,'%02d')];
        mkdir(a)
        
        vimarray = camera2frame2(foldername,2,ol490,big_or_small);
        %save([a '\vimarray.mat'],'vimarray','-V7.3')
        
        %image white
        ludl.setXY(xy_white)
        vimarray0 = camera2frame2(foldername,2,ol490,big_or_small);
        %save([a '\vimarray0.mat'],'vimarray0','-V7.3')

        % show progress
        %[focus contrast_measure]
        
        %calculate transmittance
        [reflectance_array, sizey, sizex] = frame2reflectance_white(vimarray, vimarray0);
        if 1
        %save([a '\reflectance'],'reflectance_array','sizey','sizex','-v7.3')
        imwrite(reflectance_array, 'reflectance_array.tiff')
        end
        %calculate XYZ
        %XYZ = reflectance2XYZ(reflectance_array, sizey, sizex, ls);
        %rgb = XYZ2sRGB(XYZ);
        %save([a '\rgb'],'rgb')

        %im = reshape(rgb,sizey,sizex,3);
        %imwrite(im,[a '\truth.tif'])
        movefile('reflectance_array.tiff',a)
        movefile(a,f)
        
        c = c+1;        
    end
    

 movefile(f,foldername)
 end 
ol490.setWhite

ludl.setXY(xy)
ludl.setZ(z)

ludl.close;

    % save data after closing devices
    %disp('Saving captured frames in vimarray...')
    %save([foldername '\vimarray.mat'],'vimarray','-V7.3')
    %save([foldername '\vimarray0.mat'],'vimarray0','-V7.3')

%% 2: calculate transmittance
%[reflectance_array, sizey, sizex] = frame2reflectance_white(vimarray, vimarray0);

%if 1
%save([foldername '\reflectance'],'reflectance_array','sizey','sizex','-v7.3')
%end

%% 3: calculate XYZ
% prepare the light source
%load ('datain/spec_cied65','spec');
%ls = spec(1:10:401,2);

%XYZ = reflectance2XYZ(reflectance_array, sizey, sizex, ls);
%%
%% 4: reconstruct sRGB image
%rgb = XYZ2sRGB(XYZ);
%save([foldername '\rgb'],'rgb')

%im = reshape(rgb,sizey,sizex,3);
%imwrite(im,[foldername '\truth.tif'])

% visualize
%clf
%image(im)
%axis image

toc

end
