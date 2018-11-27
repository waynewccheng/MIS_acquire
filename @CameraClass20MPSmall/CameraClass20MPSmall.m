% 4-11-2018: inherent superclass
% 4-10-2018
% 7-18-2018: adjusted exposure for Zeiss APO-Plan 20X 

classdef CameraClass20MPSmall < CameraClass20MP
    properties
    end
    
    methods
        %%
        function obj = CameraClass9MPSmall
            
            % open the device
            obj.vid = videoinput('winvideo', 1, 'RGB32_5472x3648');

            vid.FramesPerTrigger = 1;
            vid.ReturnedColorspace = 'grayscale';
            
            obj.src = getselectedsource(obj.vid);

            obj.sizey = 3648;
            obj.sizex = 5472;
            
            %load('lightsetting','src')
            %obj.src = src;
            
            % fix the camera settings
%             obj.src.ExposureMode = 'Manual';
%             obj.src.FrameRatePercentageMode = 'Manual';
%             obj.src.GainMode = 'Manual';
%             obj.src.ShutterMode = 'Manual';
%             obj.src.SharpnessMode = 'Manual';
%             
%             % grap the camera settings
%             % load('cameravstruth.mat','myBrightness','myExposure','myShutter','myGain')
%             myBrightness = 0;
%             myExposure = 1;
%             myShutter = 0.197;
%             myGain = 0;            
% 
%             %% set the exposure time
%             % for skin setup
%             obj.src.Brightness = myBrightness;
%             obj.src.Exposure = myExposure;
%             obj.src.Shutter = myShutter;
%             obj.src.Gain = myGain;
%             obj.src.Gamma = 1;
%             obj.src.FrameRatePercentage = 100;
%             obj.src.Sharpness = 1532;
            
            % open preview window
            preview(obj.vid);
        end
        
    end
end
