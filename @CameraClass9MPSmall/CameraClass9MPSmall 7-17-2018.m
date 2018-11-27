% 4-11-2018: inherent superclass
% 4-10-2018

classdef CameraClass9MPSmall < CameraClass9MP
    properties
    end
    
    methods
        %%
        function obj = CameraClass9MPSmall
            
            % open the device
            obj.vid = videoinput('pointgrey', 1, 'F7_Mono8_844x676_Mode5');

            obj.src = getselectedsource(obj.vid);

            obj.sizey = 676;
            obj.sizex = 844;
            
            %load('lightsetting','src')
            %obj.src = src;
            
            % fix the camera settings
            obj.src.ExposureMode = 'Manual';
            obj.src.FrameRatePercentageMode = 'Manual';
            obj.src.GainMode = 'Manual';
            obj.src.ShutterMode = 'Manual';
            obj.src.SharpnessMode = 'Manual';
            
            % grap the camera settings
            % load('cameravstruth.mat','myBrightness','myExposure','myShutter','myGain')
            myBrightness = 0;
            myExposure = 1.65;
            myShutter = 0.68;
            myGain = 0;            

            %% set the exposure time
            % for skin setup
            obj.src.Brightness = myBrightness;
            obj.src.Exposure = myExposure;
            obj.src.Shutter = myShutter;
            obj.src.Gain = myGain;
            obj.src.Gamma = 1;
            obj.src.FrameRatePercentage = 100;
            obj.src.Sharpness = 1532;
            
            % open preview window
            preview(obj.vid);
        end
        
    end
end
