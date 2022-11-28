%% DispSim => NEC
classdef NECPA271Sim < DispSim

    methods

        function obj = NECPA271Sim (HIMS)

            obj.classpath = fileparts(which('NECPA271Sim'));

            % scaling factor
            if HIMS == 1
                obj.sc = 0.5;
                obj.vec_file = 'OL490_vec_HIMS1.mat'                
            else
                obj.sc = 0.04;
                obj.vec_file = 'OL490_vec_HIMS2.mat'                
            end

            %            datapath = sprintf('%s/%s',obj.classpath,'necsrgb.csv');
            datapath = sprintf('%s/%s',obj.classpath,'necadobe.csv');

            %
            % forgot to traspose 3x481 in Excel
            %
            spec = csvread(datapath)';
            spec = spec(21:end,:)' * obj.sc;

            obj.spec_r = spec(1,:);
            obj.spec_g = spec(2,:);
            obj.spec_b = spec(3,:);

            % obj.OL490_load_vec;
            
        end

    end
end

