% 7-18-2018
% 4-10-2018
% autofocus

function ret = myfocus_from (f_init)

    % f_init = -3798;
    f_step = 200;
    f_range = 2000;
    
    % start stage
    load('config.mat','LUDL_PORT');

    ludl = LudlClass(LUDL_PORT);    
    
    % start camera
    cam = CameraClass9MPSmall;
    
    % contrast measure
    contrast_measure_old = 0;
    
    % linear search
    f_optimal = -1;
    
    % store results
    k = 0;
    data = zeros(2,1000);
    
    for focus = f_init-f_range : f_step : f_init+f_range
        
        % set the focus
        ludl.setZ(focus);
        
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
        
        % update the optimal
        if contrast_measure > contrast_measure_old
            f_optimal = focus;
            contrast_measure_old = contrast_measure;
        end
        
    end
    
    % conclude
    ret = f_optimal
    ludl.setZ(f_optimal);
    
    % save the image
    im_optimal = cam.snap(5);
    cam.close;
    ludl.close;

    
    % show results
    clf
    
    % the image
    subplot(3,4,[1:3 5:7 9:11])
    imagesc(im_optimal); colormap gray;
    axis image
    axis off
    title('Image obtained at the optimcal focus')
    
    % the curve
    subplot(3,4,8)
    plot(data(1,1:k),data(2,1:k),'o')
    axis square
    axis([f_optimal-3000 f_optimal+3000 0 max(data(2,1:k))])
    xlabel('Z position')
    ylabel('Contrast Measure')

    return

end

% focus measure
function ret = mycontrast (i1)

    xn = size(i1,2);
    yn = size(i1,1);

    diffver = mean(mean(abs(i1(1:yn-1,1:xn) - i1(2:yn,1:xn))));
    ret = diffver;
    
end
