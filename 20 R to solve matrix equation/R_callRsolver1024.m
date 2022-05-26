function A = R_callRsolver (M, B)
    ['Solving M * A = B with R...']

    csvwrite('R_M1024.txt',M);
    csvwrite('R_B.txt',B);
    delete('R_A.txt');

    % for AMD FX
%    system('"C:/Program Files/R/R-3.2.2/bin/x64/R" CMD BATCH my1024.R')
    
    % NUC2
    % check the version 3.2.2 !
    % system('"C:/Program Files/R/R-3.2.2/bin/x64/R" CMD BATCH R_my1024.R')

    % NUC1
    % check the version 3.2.2 !
    %system('"C:/Program Files/R/R-3.3.1/bin/x64/R" CMD BATCH R_my1024.R')

    % Dell Win10
    %system('"C:/Program Files/R/R-4.2.0/bin/x64/R" CMD BATCH R_my1024.R')

    % Chihlei
    system('"C:/Program Files/R/R-3.3.1/bin/x64/R" CMD BATCH R_my1024.R')

    A = csvread('R_A.txt');
end
