classdef Rsolver < handle
    %RSOLVER Solving B = M*A
    
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
            
            % show prompt
            ['Solving M * A = B with R...']
            tic
            
            % decide file location
            filepath_M = [obj.classpath '/R_M1024.txt'];
            filepath_A = [obj.classpath '/R_A.txt'];
            filepath_B = [obj.classpath '/R_B.txt'];
            filepath_Rout = [obj.classpath '/R_my1024.Rout'];
            filepath_Rscript = [obj.classpath '/R_my1024.R'];
            
            % delete all data files
            if isfile(filepath_A)
                delete(filepath_A);
            end
            if isfile(filepath_B)
                delete(filepath_B);
            end
            if isfile(filepath_M)
                delete(filepath_M);
            end
            
            % create data files for R
            csvwrite(filepath_M,M);
            csvwrite(filepath_B,B);
            
            % create R script

            fid = fopen(filepath_Rscript,'w');

            line1 = sprintf('source("%s/R_mysolveA1024.R")',obj.classpath);
            % replace "\" with "/"
            line1 = strrep(line1,'\','/');
            
            fprintf(fid,'%s\n',line1);
            fprintf(fid,'R_mysolveA1024()\n');
            
            fclose(fid)

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
            
            % show R log file
            type(filepath_Rout)
            
            A = csvread(filepath_A);
            obj.A = A;
            
            % show prompt
            ['Done solving M * A = B with R...']
            toc
            
        end
        
        function check (obj)
            clf
            
            subplot(1,2,1)
            plot(obj.A)
            title('Vector found')
            axis([1 1024 0 1.5])
            
            subplot(1,2,2)
            hold on
            plot(380:780,obj.B)
            plot(380:780,obj.M * obj.A)
            legend('B','M*A')
            title('Fitness check')
        end
    end
end

