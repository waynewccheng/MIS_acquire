cc = ColorConversionClass;
data = zeros(41,2);
for w = 1:41
    sp = zeros(41,1);
    sp(w) = 100000;
    XYZ = cc.spd2XYZ(sp);
    xyz = XYZ ./ sum(XYZ);
    data(w,:) = xyz(1:2);
end

data2 = zeros(401,2);
data2(:,1) = interp1(380:10:780,data(:,1),380:780,'spline');
data2(:,2) = interp1(380:10:780,data(:,2),380:780,'spline');
data2 = [data2 ; data2(1,:) ];

clf
plot(data2(:,1),data2(:,2),'-')
axis equal
axis([0 1 0 1])
