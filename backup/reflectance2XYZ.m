% D65
% 7-23-2015
% convert reflectance into RGB using D65
% usage: rgb = reflectance2D65(reflectance_array7);

function XYZ = reflectance2XYZ (reflect_array, sizey, sizex, ls)

    disp('Combining reflectance and illuminant into XYZ...')
    
    XYZxyz0 = spd2XYZ(ls); 
    whiteY = XYZxyz0(2);

%    ls_array = repmat(ls,1,480*640);
%    ls_array = repmat(ls,1,2736*2192);
%    ls_array = repmat(ls,1,676*844);
    
    ls_array = repmat(ls,1,sizey*sizex); %ls_array is list of scalars: y vals of D65 illuminant's SPD
    spd_array = reflect_array .* ls_array; %array multiplication: gives SPD of SAMPLE
    
    % rescale to [0:1]
    % define the white level here
    XYZ = spd2XYZ(spd_array)/whiteY * 1;

end

% convert spectrum into XYZxyz

function XYZ = spd2XYZ (s); %returns a transposed matrix

% CIEXYZ 1931
cmf = [
380.0 0.001368 0.000039 0.006450;
390.0 0.004243 0.000120 0.020050;
400.0 0.014310 0.000396 0.067850;
410.0 0.043510 0.001210 0.207400;
420.0 0.134380 0.004000 0.645600;
430.0 0.283900 0.011600 1.385600;
440.0 0.348280 0.023000 1.747060;
450.0 0.336200 0.038000 1.772110;
460.0 0.290800 0.060000 1.669200;
470.0 0.195360 0.090980 1.287640;
480.0 0.095640 0.139020 0.812950;
490.0 0.032010 0.208020 0.465180;
500.0 0.004900 0.323000 0.272000;
510.0 0.009300 0.503000 0.158200;
520.0 0.063270 0.710000 0.078250;
530.0 0.165500 0.862000 0.042160;
540.0 0.290400 0.954000 0.020300;
550.0 0.433450 0.994950 0.008750;
560.0 0.594500 0.995000 0.003900;
570.0 0.762100 0.952000 0.002100;
580.0 0.916300 0.870000 0.001650;
590.0 1.026300 0.757000 0.001100;
600.0 1.062200 0.631000 0.000800;
610.0 1.002600 0.503000 0.000340;
620.0 0.854450 0.381000 0.000190;
630.0 0.642400 0.265000 0.000050;
640.0 0.447900 0.175000 0.000020;
650.0 0.283500 0.107000 0.000000;
660.0 0.164900 0.061000 0.000000;
670.0 0.087400 0.032000 0.000000;
680.0 0.046770 0.017000 0.000000;
690.0 0.022700 0.008210 0.000000;
700.0 0.011359 0.004102 0.000000;
710.0 0.005790 0.002091 0.000000;
720.0 0.002899 0.001047 0.000000;
730.0 0.001440 0.000520 0.000000;
740.0 0.000690 0.000249 0.000000;
750.0 0.000332 0.000120 0.000000;
760.0 0.000166 0.000060 0.000000;
770.0 0.000083 0.000030 0.000000;
780.0 0.000042 0.000015 0.000000;    
];

    % show color matching functions
    if 0
        clf
        hold on;
        plot(cmf(:,1),cmf(:,2),'Color','r');
        plot(cmf(:,1),cmf(:,3),'Color','g');
        plot(cmf(:,1),cmf(:,4),'Color','b');
        title('Color Matching Functions')
    end
    
    input_n = size(s,2); %find length of second dimension of s
    x_bar = repmat(cmf(:,2),1,input_n);
    y_bar = repmat(cmf(:,3),1,input_n);
    z_bar = repmat(cmf(:,4),1,input_n);
    
%    k = 100/10.6858;
 k = 1;
 
    X = k * sum(s .* x_bar); %integral of TISSUE SPD times color matching function
    Y = k * sum(s .* y_bar);
    Z = k * sum(s .* z_bar);

    XYZ = [X' Y' Z'];
end
