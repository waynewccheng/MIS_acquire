list = [0 15 30 45 060 75 90 105 120 135 150 165 180 195 210 225 240 255];
clf
for i = 1:18
    j = list(i);
    step = 5;
    subplot(3,6,i);
    im = my_tg270_sqc(j,step);
    image(im)
    axis image
    axis off
    fn = sprintf('%03d-%d.png',j,step)
    imwrite(im,fn)
end