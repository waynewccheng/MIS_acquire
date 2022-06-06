classdef HPZ24xSim < DispSim
    
    %     properties
    %         %sc
    %         spec_r
    %         spec_g
    %         spec_b
    %     end
    
    %     properties (Constant)
    %
    %         % the data files are stored in the class folder
    %
    %         classpath = fileparts(which('HPZ24xSim'));
    %     end
    
    methods
        
        function obj = HPZ24xSim
            
            obj.classpath = fileparts(which('HPZ24xSim'));
            
            % scaling factor
            obj.sc = 0.07;
            
            datapath = sprintf('%s/%s',objhp.classpath,'hpz24x_rgb.csv');
            spec_z24x = xlsread(datapath);
            spec_z24x = spec_z24x(21:end,:)' * obj.sc;
            
            obj.spec_r = spec_z24x(1,:);
            obj.spec_g = spec_z24x(2,:);
            obj.spec_b = spec_z24x(3,:);
            
        end
        
    end
end

