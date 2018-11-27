% 4-11-2018: inherent superclass
% 4-10-2018

classdef CameraClass9MPBig < CameraClass9MP
    properties
    end
    
    methods
        %%
        function obj = CameraClass9MPBig
            
            % open the device
            obj.vid = videoinput('pointgrey', 1, 'F7_Raw16_3376x2704_Mode7'); % adaptorname pointgrey, ID 1, format F7_Raw16_3376x2704_Mode7

            obj.src = getselectedsource(obj.vid); %searches input object obj.vid
            
            obj.sizey = 2704;
            obj.sizex = 3376;
            
            %load('lightsetting','src')
            %obj.src = src;
            
            % fix the camera settings
            obj.src.ExposureMode = 'Manual';
            obj.src.FrameRateMode = 'Manual';
            obj.src.GainMode = 'Manual';
            obj.src.ShutterMode = 'Manual';
            
            % grap the camera settings
            % load('cameravstruth.mat','myBrightness','myExposure','myShutter','myGain')
            myBrightness = 0;
            myExposure = 1.5;
            myShutter = 6;
            myGain = 0;            

            %% set the exposure time
            % for skin setup
            obj.src.Brightness = myBrightness;
            obj.src.Exposure = myExposure;
            obj.src.Shutter = myShutter;
            obj.src.Gain = myGain;
            obj.src.Gamma = 1;
            obj.src.FrameRate = 1;
            % open preview window
            preview(obj.vid);
        end
        
    end
end
