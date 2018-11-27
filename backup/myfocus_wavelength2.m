% 4-10-2018
% autofocus

function ret = myfocus_wavelength2()
    %f_init = 500;
    f_step = 100;
    f_rangeminus = 1100;
    f_rangeplus = 900;

    % start stage
    load('config.mat','LUDL_PORT');

    ludl = LudlClass(LUDL_PORT);    
    
    % start camera
    cam = CameraClass9MPSmall;
    
    contrast_measure_old = 0;
    
    % linear search
    f_optimal = -1;
    
    % store results
    k = 0;
    data = zeros(2,f_step/2);
    f_init = getZ(ludl);
    
    for focus = f_init-f_rangeminus: f_step : f_init+f_rangeplus
        
        % set the focus
        ludl.setZ(focus);
        pause(.25)
        % take the image
        im = cam.snap(2);
        
        % calculate the focus measure
        contrast_measure = mycontrast(im);
        
        % show progress
        [focus contrast_measure]
        
        % save results
        k = k + 1;
        data(1,k) = focus;
        data(2,k) = contrast_measure;

        if contrast_measure > contrast_measure_old
            f_optimal = focus;
            contrast_measure_old = contrast_measure;
        end
 
    end
    
    ret = f_optimal
    ludl.setZ(f_optimal);
    
    im_optimal = cam.snap(5);
    cam.close;
    ludl.close;
    
    d = data(2, :)
    indices = find(abs(d)<500);
    d(indices) = [];
    n = numel(d)
    % show results
    
    subplot(1,2,1)
    imagesc(im_optimal); colormap gray;
    axis image
    
    subplot(1,2,2)
    plot(data(1,1:k),data(2,1:k),'o')
    axis square
    xlabel('Z position')
    ylabel('Contrast Measure')

end

% focus measure
function ret = mycontrast (i1)

    xn = size(i1,2);
    yn = size(i1,1);

    diffver = mean(mean(abs(i1(1:yn-1,1:xn) - i1(2:yn,1:xn))));
    ret = diffver;
    
end
