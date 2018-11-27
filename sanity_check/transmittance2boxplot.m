%% Show multispectral images of 41 bands
% revised 7-18-2018: added under- and over-flow pixels in percent
function transmittance2boxplot (foldername)

    % read the "reflectance.mat" file from the folder
    load([foldername],'transmittance_array','sizey','sizex')

    % the "reflectance" matrix is 41x570544
    whos

    % create a big figure; otherwise the titles are unreadable
    h1 = figure('position',[10 100 1900 1000]);
    
    % boxplot        
    boxplot(transmittance_array')
   
    % save the image
    % saveas(h1,[foldername '\boxplot.png'])    
end
