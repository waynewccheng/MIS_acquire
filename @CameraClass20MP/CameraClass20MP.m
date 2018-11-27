% 4-11-2018: superclass

classdef CameraClass20MP
    properties
        vid
        sizey
        sizex        
    end
    
    methods
        %%
        function obj = CameraClass20MP
  
            obj.vid = videoinput('winvideo', 1, 'RGB32_5472x3648')

            obj.vid.FramesPerTrigger = 1

            obj.vid.ReturnedColorspace = 'grayscale';

            obj.sizey = 3648;
            obj.sizex = 5472;
            
        end
        
        %%
        function close (obj)
            
            % close the device
            closepreview;
            delete(obj.vid);
            
        end
        
        %% nround not working!!!
        function vim = snap(obj, nround)
            
            preview(obj.vid)

            start(obj.vid)

            vim = getdata(obj.vid);

            stop(obj.vid)

            stoppreview(obj.vid)

            return
            
            % initialize the sum matrix
            imsum = zeros(obj.sizey,obj.sizex,'double');
            
            start(obj.vid);
            for r = 1:nround
                imtemp = getdata(obj.vid);
                imsum = imsum + double(imtemp);
            end
            stop(obj.vid);
            
            % mean of all frame
            vim = imsum / (nround);
           
        end
    end
end
