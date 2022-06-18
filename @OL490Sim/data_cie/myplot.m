clf
hold on

for i = 1:12
subplot(3,4,i)
    fn = sprintf('s_f%d',i)
load(fn)
plot(s)
end

