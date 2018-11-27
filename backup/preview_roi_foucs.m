% Test the OL490 and Ludl
% 4-10-2018

function [xy z] = preview_roi_focus (ol490, prompt)

load('config.mat');

ludl = LudlClass(LUDL_PORT);

% turn on the light
ol490.setGreen
    
vid = videoinput('pointgrey', 1, 'F7_Mono8_844x676_Mode5');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;

preview(vid);

response = input(prompt)

xy = ludl.getXY
z = ludl.getZ

delete(vid)

ludl.close;

end
