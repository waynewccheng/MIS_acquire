% 4-11-2018: superclass

classdef CameraClass9MP
    properties
        vid
        src
        sizey
        sizex        
    end
    
    methods
        %%
        function obj = CameraClass9MP
  
        end
        
        %%
        function close (obj)
            
            % close the device
            closepreview;
            delete(obj.vid);
            
        end
        
        %%
        function vim = snap(obj, nround)
            
            % initialize the sum matrix
            imsum = zeros(obj.sizey,obj.sizex,'double');
            
            for r = 1:nround
                imtemp = getsnapshot(obj.vid);
                imsum = imsum + double(imtemp);
            end
            
            % mean of all frame
            vim = imsum / (nround);
           
        end
    end
end
