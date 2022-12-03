classdef Matlab2latex < handle

    methods (Static)

        function table2latex (tab)

            row_name = tab.Properties.DimensionNames{1};
            var_name = tab.Properties.DimensionNames{2};
            col_name = tab.Properties.VariableNames;

            row_array_name = ['tab.' row_name];
            row_array = eval(row_array_name);

            mat_name = ['tab.' var_name];
            mat = eval(mat_name);

            n_row = size(mat,1);
            n_col = size(mat,2);

            fn = 'output.tex';
            fid = fopen(fn,'w');

            fprintf(fid,'%s','\begin{tabular}');
            fprintf(fid,'%c','{');
            for c = 1:n_col+1
                fprintf(fid,'%c','c');
            end
            fprintf(fid,'%c','}');
            fprintf(fid,'%s\n','');

            fprintf(fid,'  %s\n','\hline');

            %
            % head row
            %
            fprintf(fid,'  %s ','');
            for c = 1:n_col
                entry = col_name{c};
                fprintf(fid,'& %s ',entry);
            end
            fprintf(fid,'%s\n','\\');

            fprintf(fid,'  %s\n','\hline');
            for r = 1:n_row

                entry = row_array{r};
                fprintf(fid,'  %s ',entry);

                for c = 1:n_col
                    entry = mat(r,c);
                    fprintf(fid,'& %.2f ',entry);
                end
                fprintf(fid,'%s\n','\\');
            end
            fprintf(fid,'  %s\n','\hline');

            fprintf(fid,'%s\n','\end{tabular}');

            fclose(fid);
        end

        function mat2latex (mat)
            %UNTITLED8 Summary of this function goes here
            %   Detailed explanation goes here

            n_row = size(mat,1);
            n_col = size(mat,2);

            fn = 'output.tex';
            fid = fopen(fn,'w');

            fprintf(fid,'%s','\begin{tabular}');
            fprintf(fid,'%c','{');
            for c = 1:n_col
                fprintf(fid,'%c','c');
            end
            fprintf(fid,'%c','}');
            fprintf(fid,'%s\n','');

            fprintf(fid,'  %s\n','\hline');
            for r = 1:n_row
                for c = 1:n_col
                    entry = mat(r,c);
                    if c>1
                        fprintf(fid,'%s',' & ');
                    end
                    fprintf(fid,'%.2f ',entry);
                end
                fprintf(fid,'%s\n','\\');
            end
            fprintf(fid,'  %s\n','\hline');

            fprintf(fid,'%s\n','\end{tabular}');

            fclose(fid);
        end

    end
end