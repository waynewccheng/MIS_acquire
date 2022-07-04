classdef HPZ24xSim < DispSim

    methods

        function obj = HPZ24xSim (HIMS)

            obj.classpath = fileparts(which('HPZ24xSim'));

            % scaling factor
            if HIMS == 1
                obj.sc = 0.5;
                obj.vec_file = 'OL490_vec_HIMS1.mat'                
            else
                obj.sc = 0.04;
                obj.vec_file = 'OL490_vec_HIMS2.mat'                
            end

            datapath = sprintf('%s/%s',obj.classpath,'hpz24x_rgb.csv');
            spec_z24x = xlsread(datapath);
            spec_z24x = spec_z24x(21:end,:)' * obj.sc;

            obj.spec_r = spec_z24x(1,:);
            obj.spec_g = spec_z24x(2,:);
            obj.spec_b = spec_z24x(3,:);

            % obj.OL490_load_vec;

        end

    end

end

