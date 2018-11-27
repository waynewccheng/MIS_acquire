% 4-12-2018: save cam.vid and cam.src in info.mat
% 4-10-2018: merge big and small
% 10-9-2015
% example: ol490 = OL490Class; camera2frame('dataout/1009-test1',1,ol490)
%
% 8-3-2015: hardware trigger; needs software reset!
% 7-23-2015: replace grasshopper function with camera_*
% usage: camera2frame('0723-7')
% 7-21-2015: revisit
% capture images with camera
% capture 41 images from 380 to 780
% output: vimarray(41,480,640)  

function vimarray = camera2frame (pathout, numberofshots, ol490, big_or_small)
% capture an image with multispectral

    disp('Capturing frames with wavelength from 380 to 780 nm...')
    
    mkdir(pathout)
    fnout = sprintf('%s/vimarray',pathout);
    fnout_info = sprintf('%s/info',pathout);

    % aqusition
    if big_or_small == 1
        cam = CameraClass9MPBig
    else
        cam = CameraClass9MPSmall
    end
    
    cam_vid = get(cam.vid);
    cam_src = get(cam.src);
   
    save(fnout_info,'cam_vid','cam_src','-append')

    % data
    vimarray = zeros(41,cam.sizey,cam.sizex);


    % prepare light
    bandwidth = 10;
    intensity = 100;

    % add some delay here because 380 nm has problems
    ol490.setPeak(380,bandwidth,intensity); 
    pause(1)
    
    k = 1;
    for wl=380:10:780
        % prepare light    
        
        ol490.setPeak(wl,bandwidth,intensity); 

        % focus
%        f_opt = myfocus(cam)

        % need pause here???
        % pause(0.25)
        
        % acqusition
        vim = cam.snap(numberofshots);
        vimarray(k,:,:) = vim;

        k = k + 1;
    end

    % exit
    cam.close;

    beep
    
    % save data after closing devices
    %disp('Saving captured frames in vimarray...')
    %save(fnout,'vimarray','-V7.3')

    ol490.setPeak(550,10,100)

    % ring
    beep on
    beep

return

end
