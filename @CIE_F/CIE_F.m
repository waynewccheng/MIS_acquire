classdef CIE_F
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        spec_cief = zeros(12,401);

        sc = 0.00005;

        classpath = fileparts(which('CIE_F'));        
    end

    methods

        function obj = CIE_F 
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here

            datapath = sprintf('%s/%s',obj.classpath,'cieF.mat');
            load(datapath,'spec_cief')
    
            obj.spec_cief = spec_cief;
        end
    end

    methods (Static)

        function speC = getSpectrum (f_num)
            
            cF = CIE_F;

            wl = [380:780]';
            sp = cF.spec_cief(f_num,:)' * cF.sc ;

            speC = SpectrumClass(wl,sp);

        end

    end
end