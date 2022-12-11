classdef CIE_Metamers
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        datapath                 % metamerism data from ISO 23603
        d50
        d55
        d65
        d75
    end

    methods

        function obj = CIE_Metamers
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here

            [folder, name, ext] = fileparts(which('CIE_Metamers'));                 % where the data file is
            obj.datapath = [folder '/cie_metamerism_data.mat'];                     % store the datapath
            load (obj.datapath,'spec_ref','spec_d50','spec_d55','spec_d65','spec_d75');                     % spec is a 81x6 matrix

            spec_comp = spec_d50;
            s = {};
            for mat = 1:5
                wavelength = spec_ref(:,1);
                amplitude = spec_ref(:,1+mat);
                s{mat,1} = SpectrumClass(wavelength,amplitude);

                wavelength = spec_comp(:,1);
                amplitude = spec_comp(:,1+mat);
                s{mat,2} = SpectrumClass(wavelength,amplitude);
            end
            obj.d50 = s;

            spec_comp = spec_d55;
            s = {};
            for mat = 1:5
                wavelength = spec_ref(:,1);
                amplitude = spec_ref(:,1+mat);
                s{mat,1} = SpectrumClass(wavelength,amplitude);

                wavelength = spec_comp(:,1);
                amplitude = spec_comp(:,1+mat);
                s{mat,2} = SpectrumClass(wavelength,amplitude);
            end
            obj.d55 = s;

            spec_comp = spec_d65;
            s = {};
            for mat = 1:5
                wavelength = spec_ref(:,1);
                amplitude = spec_ref(:,1+mat);
                s{mat,1} = SpectrumClass(wavelength,amplitude);

                wavelength = spec_comp(:,1);
                amplitude = spec_comp(:,1+mat);
                s{mat,2} = SpectrumClass(wavelength,amplitude);
            end
            obj.d65 = s;

            spec_comp = spec_d75;
            s = {};
            for mat = 1:5
                wavelength = spec_ref(:,1);
                amplitude = spec_ref(:,1+mat);
                s{mat,1} = SpectrumClass(wavelength,amplitude);

                wavelength = spec_comp(:,1);
                amplitude = spec_comp(:,1+mat);
                s{mat,2} = SpectrumClass(wavelength,amplitude);
            end
            obj.d75 = s;
            
        end

    end

end