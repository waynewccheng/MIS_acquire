for step = 1:20
    list = [0 15 30 45 060 75 90 105 120 135 150 165 180 195 210 225 240 255]
    
    r1 = list(1:6);
    r2 = list(12:-1:7);
    r3 = list(13:18);
    
    r = [r1;r2;r3];
    
    rowall = [];
    for i = 1:3
        row = [];
        for j = 1:6
            ind = r(i,j);
            im = my_tg270_sqc(ind,step);
            row = [row im];
        end
        rowall = [rowall ; row];
    end
    
    im = rowall;
    fn = sprintf('all-%d.png',step)
    imwrite(im,fn)
    
    image(im)
    axis image
    axis off
    
end
