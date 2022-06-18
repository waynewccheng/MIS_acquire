load('cieF_380_5_780','cief')
spec_cief = zeros(12,401);

for i = 1:12
    spec_cief(i,:) = interp1(380:5:780,cief(:,i),380:780);
end

save('cieF','spec_cief')