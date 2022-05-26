load('runme_data','M','B')

A = R_callRsolver1024(M,B);

A = min(1,A);
% A(1:71) = 0;
% A(957:1024) = 0;

clf

subplot(1,2,1)
plot(A)

subplot(1,2,2)
hold on
plot(B)
plot(M * A)