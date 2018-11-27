%% 
% Obtain multispectral data with a single code
% need to have "ol490 = OL490Class" before running the code; nothing else
% (e.g., ludl)
% 7-9-2018: revised
% 4-11-2018: added saving info.mat
% 4-10-2018
% 4-9-2018: added sizey and sizex to make camera-independent 

%% 
function main_1pass (foldername, ol490, big_or_small)

tic

load('config.mat','LUDL_PORT');

ludl = LudlClass(LUDL_PORT);

foldername_white = [foldername '_white']

%% 0: choose ROI and focus

if 1 

    % determine the ROI locations for target and reference white
    findroi
    
    % save the ROI locations
    mkdir(foldername)
    save([foldername '\info.mat'],'xy','xy_white','z','z_white')

else
    
    % shortcut: use the previously saved locations
    load([foldername '\info.mat'],'xy','xy_white','z','z_white')

end

%% 1: take frames
ludl.setXY(xy)
ludl.setZ(z)

    vimarray = camera2frame(foldername,1,ol490,big_or_small);
   
ludl.setXY(xy_white)
ludl.setZ(z_white)

    vimarray0 = camera2frame(foldername,1,ol490,big_or_small);

    
ol490.setWhite

ludl.setXY(xy)
ludl.setZ(z)

ludl.close;

    % save data after closing devices
    disp('Saving captured frames in vimarray...')
    save([foldername '\vimarray.mat'],'vimarray','-V7.3')
    save([foldername '\vimarray0.mat'],'vimarray0','-V7.3')

%% 2: calculate transmittance
[reflectance_array, sizey, sizex] = frame2reflectance_white(vimarray, vimarray0);

if 1
save([foldername '\reflectance'],'reflectance_array','sizey','sizex','-v7.3')
end

%% 3: calculate XYZ
% prepare the light source
load ('datain/spec_cied65','spec');
ls = spec(1:10:401,2);

XYZ = reflectance2XYZ(reflectance_array, sizey, sizex, ls);

%% 4: reconstruct sRGB image
rgb = XYZ2sRGB(XYZ);
%save([foldername '\rgb'],'rgb')

im = reshape(rgb,sizey,sizex,3);
imwrite(im,[foldername '\truth.tif'])

% visualize
clf
image(im)
axis image

toc

end
