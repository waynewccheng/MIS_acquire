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
    end
    
    methods
        
        %%
        function obj = OL490Class

            [filepath,name,ext] = fileparts(which('OL490Class'));                
            ol490dllpath = filepath;

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
        function setColumn1024Gamma (obj, A)
            veclut = [0,0; 0.100000000000000,0.0174154675672971;0.200000000000000,0.0288521591733234;0.300000000000000,0.0443881664199884;0.400000000000000,0.0722865877650448;0.500000000000000,0.140172225476376;0.600000000000000,0.247878154595747;0.700000000000000,0.400399361796317;0.800000000000000,0.596147604681164;0.900000000000000,0.772382655388365;1,1];
            
            st = zeros(1,1024);

            for colno = 1:1024
                
                % adjust this value
                sc_linear = A(colno);
                sc = interp1(veclut(:,2),veclut(:,1),sc_linear,'spline');
                st(1,colno) = obj.max_column_value * sc;
            end

            e = obj.m.TurnOnColumn(st);            
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
end
