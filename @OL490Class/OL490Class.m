%% OL490 Tunable Light Source
% 6/14/2022: add VEC
% 3-24-2022: CCK project
% 4-5-2018: added setGreen
% 4-5-2018: added setWhite
% 4-5-2018: changed to @class folder
% 8-5-2016: calibrated: 
% calibration: 40000 => too low 
% increased to 45000
% 10-9-2015

classdef OL490Class < handle

    properties
        m
        asmCyUSB
        asmOLIPlugin
        asmOL490Lib
        asmOL490SDK
                    
        % use 40000 for calibration
        max_column_value = 40000;
        
        gamma_lut
        classpath

        vec_x
        vec_y
        vec_z

        HIMS
    end
    
    methods
        
        %%
        function obj = OL490Class

            [filepath,name,ext] = fileparts(which('OL490Class'));                
            ol490dllpath = filepath;
            obj.classpath = ol490dllpath;
            obj.HIMS = -1;

            %% todo: check existing assembly
            % http://stackoverflow.com/questions/5368974/how-to-check-if-net-assembly-was-already-added-in-matlab
            
            asm = System.AppDomain.CurrentDomain.GetAssemblies;
            
            MyName = 'CyUSB';
            if any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), MyName, length(MyName)), 1:asm.Length)) == 0
                asmCyUSB = NET.addAssembly([ol490dllpath '\CyUSB.dll'])
            end

            MyName = 'OLIPluginLibrary';
            if any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), MyName, length(MyName)), 1:asm.Length)) == 0
                asmOLIPlugin = NET.addAssembly([ol490dllpath '\OLIPluginLibrary.dll'])
            end
            
            MyName = 'OL490Lib';
            if any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), MyName, length(MyName)), 1:asm.Length)) == 0
                asmOL490Lib = NET.addAssembly([ol490dllpath '\OL490Lib.dll'])
            end
            
            MyName = 'OL490_SDK_Dll';
            if any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), MyName, length(MyName)), 1:asm.Length)) == 0
                asmOL490SDK = NET.addAssembly([ol490dllpath '\OL490_SDK_Dll.dll'])
            end
            
            obj.m = OL490_SDK_Dll.OL490SdkLibrary

            obj.m.Initialize()

            e = obj.m.ConnectToOL490(0)

            e = obj.m.LoadAndUseStoredCalibration(0)

            e = obj.m.EnableLinearLightReduction(-1)

            e = obj.m.SetGrayScaleValue(0)

            % use HIMS1 as the default
            obj.setParameters(1);
        end

        function setParameters (obj, HIMS)

            if HIMS==1
                filepath = sprintf('%s/%s.mat',obj.classpath,'gamma_lut_HIMS1_06162022')
                %filepath2 = sprintf('%s/%s.mat',obj.classpath,'vec_colormatchingfunction_HIMS1_06172022')
            else
                filepath = sprintf('%s/%s.mat',obj.classpath,'gamma_lut')
            end
            
            load(filepath,'gamma_lut');
            obj.gamma_lut = gamma_lut;

            %load(filepath2,'vec_x','vec_y','vec_z','cmf_x','cmf_y','cmf_z','sc')
%             
%             obj.vec_x = vec_x;
%             obj.vec_y = vec_y;
%             obj.vec_z = vec_z;

            obj.HIMS = HIMS;
        end

        function vec = XYZ2vec (obj,XYZ)
            %XYZ2vec Color matching functions
            %

            % assume additivity
            vec = obj.vec_x * XYZ(1) + obj.vec_y * XYZ(2) + obj.vec_z * XYZ(3);
            
            % trimming
            vec = max(0,vec);
            vec = min(1,vec);
        end

        %%
        function setPeak (obj, wl, bandwidth, intensity)
            e = obj.m.SendLivePeak(wl, bandwidth, intensity); 
        end

        %%
        function setColumn1024 (obj, A)
            st = zeros(1,1024);

            for colno = 1:1024
                % adjust this value
                st(1,colno) = obj.max_column_value * A(colno);
            end

            e = obj.m.TurnOnColumn(st);            
        end

        %%
        function spec = setColumn1024andMeasure (obj, A, cs)
            %%SETCOLUMN1024ANDMEASURE Set the raw column values and measure
            %%the output spectrum
            obj.setColumn1024(A);
            spec = cs.measure;
        end
                
        %%
        function setColumn1024Gamma (obj, A)
            
            % 6/3/2022
            st = zeros(1,1024);

            for colno = 1:1024
                
                % adjust this value
                sc_linear = A(colno);
                sc = interp1(obj.gamma_lut(:,2),obj.gamma_lut(:,1),sc_linear,'linear');
                st(1,colno) = obj.max_column_value * sc;
            end

            e = obj.m.TurnOnColumn(st);            
        end
        
        %%
        function spec = setColumn1024GammaandMeasure (obj, A, cs)
            %%SETCOLUMN1024ANDMEASURE Set the raw column values and measure
            %%the output spectrum
            obj.setColumn1024Gamma(A);
            spec = cs.measure;
        end
                
        %%
        function setBlack (obj)
            A = zeros(1024,1);       % 1024x1 double
            obj.setColumn1024(A);
        end
        
        %%
        function setWhite (obj)
            load('D65_6363K');       % 1024x1 double
            obj.setColumn1024(A);
        end
        
        %%
        function setGreen (obj)
            obj.setPeak(550, 10, 100);
        end
    end

    methods (Static)

        function vout = VEC_multiple_peaks (col_range)
            %%VEC_MULTIPLE_PEAKS Generate a 1024 column vector using a list of column numbers
            %

            v_max = 1;              % max intensity
            col_width = 0;          % width: only one column
            
            vout = zeros(1024,1);
            for i = 1:length(col_range)
                col = col_range(i);
                assert((col >= 1) && (col <= 1024));
                vout = LightSim.add_a_peak(vout,col,col_width,v_max);
            end
            
        end
        
        function vout = VEC_add_a_peak (vin, col, width, amp)
            %%VEC_ADD_A_PEAK Add one section of columns into a 1024 vector
            %
            % turn on one more column (+/- width) in the given vector
            %
            vout = vin;
            
            col_start = col-width;
            col_stop = col+width;
            %
            % check range
            %
            col_start = max(1,col_start);
            col_stop = min(1024,col_stop);
            
            %
            % set the columns
            %
            vout(col_start:col_stop,1) = amp;
        end        
        
    end

end
