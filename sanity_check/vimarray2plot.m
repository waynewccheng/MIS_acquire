%% Show multispectral images of 41 bands
% revised 7-18-2018: added under- and over-flow pixels in percent
function vimarray2plot (foldername)

    % read the "reflectance.mat" file from the folder
    load(foldername,'vimarray')
    
    sizey = size(vimarray,2);
    sizex = size(vimarray,3);
    
    % the "reflectance" matrix is 41x570544
    whos
    
    % get the pixel count
    n_total = sizey * sizex;

    % convert the matrix from 1D to 2D
    data = reshape(vimarray,41,sizey,sizex);
    
    % create a big figure; otherwise the titles are unreadable
    h1 = figure('position',[10 100 1900 1000]);
    
    % sweep the wavelength
    wl = 380;
    for i = 1:41
        
        % retrieve the frame
        im1 = squeeze(data(i,:,:));
        
        % get statistics
        n_over =  nnz(im1 >= 1);
        n_under = nnz(im1 <= 0);
        
        % re-create a color image
%         im = uint8(zeros(sizey,sizex,3));
%         im(:,:,1) = im1*255;
%         im(:,:,2) = im1*255;
%         im(:,:,3) = im1*255;
                
        % find a space to show the image
        subplot(6,7,i)

        imagesc(im1)
        axis off
        
        % show the statistics
        title(sprintf('%d: [%.2f%% %.2f%%]',wl,n_under/n_total*100,n_over/n_total*100),'FontSize',8)

        % post iteration
        wl = wl + 10;
    end
    
    return 
    
    % save the image
    saveas(h1,[foldername '\frames41'])    
end
