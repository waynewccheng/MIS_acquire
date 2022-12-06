function [poly,rsq,yfit] = liinearity_analyzer (x,y)

%
% sort the data points 
%
xy = [x y];
xy = sortrows(xy);
x = xy(:,1);
y = xy(:,2);

poly = polyfit(x,y,1);
yfit = polyval(poly,x);
yresid = y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rsq = 1 - SSresid/SStotal;

hold on
plot(x, y,'^r');
plot(x, yfit,'b:', 'LineWidth', 1.0);
grid on

%PlotBeautify(haxis)
legend_str = sprintf('%.0ft + %.3f, R^{2}=%.4f',poly(1),poly(2),rsq);
legend('',legend_str,'Location','northwest')

end