    a = csvread('R_A.txt');
    b = csvread('R_B.txt');
    m = csvread('R_M1024_new.txt');
    m0 = csvread('R_M1024_backup.txt');
    b_out = m*a;
    b0_out = m0*a;
    clf
    hold on
    plot(b)
    plot(b_out)
    plot(b0_out)