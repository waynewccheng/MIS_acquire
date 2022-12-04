classdef Hololens2 < DispSim
    %HOLOLENS2 Measured by CL-500 from Matt's headset on 7/29/2022
    %  Measured by CL-500 from Matt's headset on 7/29/2022
    % `holo.xlsx`: original CL-500 data downloaded
    % `spec_07292022.mat`: converted to .mat

    %
    % dominant wavelength: 641, 521, and 453 nm
    %

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

            %
            % Since Matt's test pattern was white, the RGB spectra need to
            % be separately manually
            %
            obj.spec_b = spec_rgb;
            obj.spec_b(101:end) = 0;

            obj.spec_g = spec_rgb;
            obj.spec_g([1:100 201:end]) = 0;

            obj.spec_r = spec_rgb;
            obj.spec_r([1:200 401:end]) = 0;

        end

    end
end

