%% convert a XYZ vector into sRGB
% 9-3-2015
function rgb = XYZ2sRGB (XYZ)
        %% constants
        m=[3.2410 -1.5374 -0.4986; -0.9692 1.8760 0.0416; 0.0556 -0.2040 1.0570];
        a=0.055;
        
        %% linearize
        rgb = m*XYZ';

        %% conditional mask
        rgb_lessorequal = (rgb <= 0.0031308);

        %% conditional assignment
        rgb(rgb_lessorequal) = rgb(rgb_lessorequal) * 12.92;
        rgb(~rgb_lessorequal) = (1+a)*(rgb(~rgb_lessorequal).^(1/2.4)) - a;

        %% comply with the old form
        rgb = rgb';
end
