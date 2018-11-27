% focus measure
function ret = mycontrast (i1)

    xn = size(i1,2);
    yn = size(i1,1);

    diffver = mean(mean(abs(i1(1:yn-1,1:xn) - i1(2:yn,1:xn))));
    ret = diffver;
    
end