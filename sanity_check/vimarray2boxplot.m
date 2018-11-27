%% Show multispectral images of 41 bands
% revised 7-18-2018: added under- and over-flow pixels in percent
function vimarray2boxplot (foldername)

    % read the "reflectance.mat" file from the folder
%    load([foldername '\vimarray'],'vimarray')
    load([foldername],'vimarray')
    
    sizey = size(vimarray,2);
    sizex = size(vimarray,3);
    n_total = sizey * sizex;
    
    vimarray1 = reshape(vimarray,41,n_total);
    
    % the "reflectance" matrix is 41x570544
    whos

    % create a big figure; otherwise the titles are unreadable
    h1 = figure('position',[10 100 1900 1000]);
    
    % boxplot        
    boxplot(vimarray1')
   
    % save the image
    % saveas(h1,[foldername '\boxplot.png'])    
end
