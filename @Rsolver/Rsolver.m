classdef Rsolver < handle
    %RSOLVER Summary of this class goes here

    properties
        M
        B
        A
    end

    properties (Constant)
        classpath = fileparts(which('Rsolver'));

        r_command = '"C:/Program Files/R/R-4.2.0/bin/x64/R" CMD BATCH R_my1024.R';
    end

    methods

        function obj = Rsolver (M,B)
%             load([Rsolver.classpath '/runme_data'],'M','B')
% 
             obj.M = M;
             obj.B = B;

            obj.R_callRsolver;
            obj.check;
        end

        function A = R_callRsolver (obj)
            ['Solving M * A = B with R...']

            M = obj.M;
            B = obj.B;

            csvwrite([obj.classpath '/R_M1024.txt'],M);
            csvwrite([obj.classpath '/R_B.txt'],B);
            delete([obj.classpath '/R_A.txt']);

            % for AMD FX
            %    system('"C:/Program Files/R/R-3.2.2/bin/x64/R" CMD BATCH my1024.R')

            % NUC2
            % check the version 3.2.2 !
            % system('"C:/Program Files/R/R-3.2.2/bin/x64/R" CMD BATCH R_my1024.R')

            % NUC1
            % check the version 3.2.2 !
            %system('"C:/Program Files/R/R-3.3.1/bin/x64/R" CMD BATCH R_my1024.R')

            % Dell Win10
            mycd = cd;
            cd(obj.classpath)
            system(obj.r_command)
            cd(mycd)

            A = csvread([obj.classpath '/R_A.txt']);
            obj.A = A;

        end

        function check (obj)
            clf
            
            subplot(1,2,1)
            plot(obj.A)

            subplot(1,2,2)
            hold on
                        plot(obj.B)
                        plot(obj.M * obj.A)
        end
    end
end

