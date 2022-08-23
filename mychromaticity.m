% create chromaticity plane
step = 1/200;
[X Y] = meshgrid(0:step:1,0:step:1);
Z = 1 - X - Y;

% linearize
X1 = X(:);
Y1 = Y(:);
Z1 = Z(:);
mask0 = (Z1 < 0) | (Z1 > 1);

xyz_blue = rgb2xyz([0 0 1])
targetY = xyz_blue(2)*10

X1 = X1 ./ Y1 .* targetY;
Y1 = Y1 ./ Y1 .* targetY;
Z1 = Z1 ./ Y1 .* targetY;

XYZ1 = [X1 Y1 Z1];
mask = (Z1 < 0) | (Z1 > 1);

rgb1 = xyz2rgb(XYZ1);
rgb1(mask,:) = 0;

rgb1my = rgb1;
rgb2 = reshape(rgb1,size(X,1),size(X,2),3);
imshow(rgb2)
axis equal

size(rgb2)
%return

%rgb1(mask0,:) = 0;

mask1 = (rgb1(:,1) < 0);
mask11 = (rgb1(:,1) > 1);
%mask111 = (rgb1(:,1) <1.6);

mask2 = (rgb1(:,2) < 0);
mask22 = (rgb1(:,2) > 1);
mask3 = (rgb1(:,3) < 0);
mask33= (rgb1(:,3) > 1);

rgb1(mask1,:) = 0;
rgb1(mask11,:) = 0;
rgb1(mask2,:) = 0;
rgb1(mask22,:) = 0;
rgb1(mask3,:) = 0;
rgb1(mask33,:) = 0;

rgb = uint8(reshape(rgb1,size(X,1),size(X,2),3)*255);
rgbflipped = flipud(rgb);
image(rgbflipped)
axis equal
