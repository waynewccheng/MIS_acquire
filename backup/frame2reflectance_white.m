%% Convert frames (DDL) to reflectance by using reference white background
% 7-18-2018: 380 nm is too dark
% 7-30-2015
% 

function [reflectance_array, sizey, sizex] = frame2reflectance_white (vimarray, vimarray0)

    disp('Combining frames into reflectance...')

    %fnin = sprintf('%s/vimarray',foldername_white);
    %load(fnin,'vimarray');
    %vimarray0 = vimarray;
    
    [sizewl sizey sizex] = size(vimarray0);
    
    %fnin = sprintf('%s/vimarray',foldername);
    %load(fnin,'vimarray');
    
    % calculate the reflectance
    ddl_array = reshape(vimarray,sizewl,sizey*sizex);
    ddl_white_array = reshape(vimarray0,sizewl,sizey*sizex);
    
    reflectance_array = ddl_array ./ ddl_white_array;
    
    % clip the transmittance at 1.0 because reference white might be darker
    % due to dust and other artifacts
    reflectance_array = min(reflectance_array,1);
    
    % set the transmittance as 0 if the reference white is too dark
    % ddl_white_array < 0.00 
    
    % ----------------------------------
    return
end
