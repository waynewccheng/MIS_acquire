load('D:\WCC2015\MATLAB_WCC\OL490 9-22-2015\lightmatching 10-2-2015\datain\cie_illuminants.mat')
clf
hold on
plot(380:780,d65)
plot(380:780,f7*6)
axis([380 780 0 280])
legend('CIE D65','CIE F7')