
function im = my_tg270_sqc(colorbg,step)

%colorbg = 0;
colorplus = colorbg + step;
colorminus = colorbg - step;

if colorplus > 255
    colorplus = 255 - 3;
end

if colorminus < 0 
    colorminus = 0 + 3;
end

patchsize = 135;
im = uint8(ones(patchsize,patchsize,3)*colorbg);

leny = 30;

starty = 40;
for i=3:8
startx = i*6+10;
im(starty:starty+leny,startx:startx+2,1) = colorplus;
im(starty:starty+leny,startx:startx+2,2) = colorplus;
im(starty:starty+leny,startx:startx+2,3) = colorplus;
end

starty = 20+60;
for i=12:12+5
startx = i*6;
im(starty:starty+leny,startx:startx+2,1) = colorminus;
im(starty:starty+leny,startx:startx+2,2) = colorminus;
im(starty:starty+leny,startx:startx+2,3) = colorminus;
end

% clf
% image(im)
% axis image

end


