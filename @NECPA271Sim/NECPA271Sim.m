classdef NECPA271Sim < DispSim
    
    methods
        
        function obj = NECPA271Sim
            
            obj.classpath = fileparts(which('NECPA271Sim'));
            
            % scaling factor
            obj.sc = 0.07;
            
%            datapath = sprintf('%s/%s',obj.classpath,'necsrgb.csv');
            datapath = sprintf('%s/%s',obj.classpath,'necadobe.csv');
            
            %
            % forgot to traspose 3x481 in Excel 
            %
            spec = xlsread(datapath)';
            spec = spec(21:end,:)' * obj.sc;
            
            obj.spec_r = spec(1,:);
            obj.spec_g = spec(2,:);
            obj.spec_b = spec(3,:);
            
        end
        
    end
end

