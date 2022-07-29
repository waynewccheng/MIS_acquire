classdef Hololens2 < DispSim
    %HOLOLENS2 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        
        function obj = Hololens2 (HIMS)

            % scaling factor
            if HIMS == 1
                obj.sc = 0.5;
            else
                obj.sc = 0.002;
            end
            
            obj.classpath = fileparts(which('Hololens2'));
            datapath = sprintf('%s/%s',obj.classpath,'spec_07292022.mat');
            load(datapath,'spec')
            
            spec_rgb = mean(spec(6:9,21:end)) * obj.sc;

            obj.spec_b = spec_rgb;
            obj.spec_b(101:end) = 0;
            
            obj.spec_g = spec_rgb;
            obj.spec_g([1:100 201:end]) = 0;

            obj.spec_r = spec_rgb;
            obj.spec_r([1:200 401:end]) = 0;
           
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

