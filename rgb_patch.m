function rgb_patch (rgb)
im = uint8(zeros(1000,1000,3));
im(:,:,1) = rgb(1);
im(:,:,2) = rgb(2);
im(:,:,3) = rgb(3);
image(im)
imwrite(im,'rgb_patch.png')
end
