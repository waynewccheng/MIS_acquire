%% Spectrum class defined for exchange between spectroradiometers

classdef SpectrumClass < handle
    %SPECTRUMCLASS SpectrumClas SUMMARY
    %   Class for processing spectral data obtained by different
    %   spectroradiometers and operations
    %
    %   WCC
    %   6/13/2022
    %   6/17/2022: added CIE_D -- to remove
    %   6/21/2022: to add optional info/parameters in addTime
    %   6/28/2022: enforce vertical input as nx2

    %% Properties
    properties
        wavelength
        amplitude
        date
        instrument
        time_used
    end

    %% Methods
    methods

        %
        % Construction
        %
        function obj = SpectrumClass (wl, amp)
            if nargin < 2
                disp('require wl and amp')
            else
                if size(wl) ~= size(amp)
                    disp('wrong size')
                else
                    assert(size(wl,2)==1);
                    assert(size(amp,2)==1);
                    assert(size(wl,1)==size(amp,1));
                    
                    obj.wavelength = wl;
                    obj.amplitude = amp;
                end
            end
        end

        function obj = addTime (obj, date, inst, time_used)
            %%ADDTIME Add time stamps to a measurement
            obj.date = date;
            obj.instrument = inst;
            obj.time_used = time_used;
        end

        %
        % Visualize
        %
        function plot (obj)
            %%PLOT Visualize the curve

            plot(obj.wavelength,obj.amplitude);
            xlabel('wavelength (nm)')
            ylabel('SPD')
            title('Spectrum')
        end

        function disp (obj)
            [obj.wavelength' obj.amplitude']
        end

        %
        % Colorimetry
        %
        function ret = XYZ (obj)
            spec = obj.amplitude(1:10:end);
            cc = ColorConversionClass;

            ret = cc.spd2XYZ(spec);
        end

        function ret = xyz (obj)
            XYZ = obj.XYZ;
            ret = XYZ ./ sum(XYZ);
        end

        %
        % Operations
        %
        function obj3 = plus (obj1, obj2)
            %PLUS +
            assert(nnz(obj1.wavelength == obj2.wavelength)==length(obj1.wavelength));

            obj3 = SpectrumClass(obj1.wavelength,obj1.amplitude + obj2.amplitude);
        end

        function obj3 = minus (obj1, obj2)
            assert(nnz(obj1.wavelength == obj2.wavelength)==length(obj1.wavelength));

            obj3 = SpectrumClass(obj1.wavelength,obj1.amplitude - obj2.amplitude);
        end

        function obj3 = times (obj1, obj2)
            assert(nnz(obj1.wavelength == obj2.wavelength)==length(obj1.wavelength));

            obj3 = SpectrumClass(obj1.wavelength,obj1.amplitude .* obj2.amplitude);
        end

        function obj3 = rdivide (obj1, obj2)
            %%RDIVIDE Define division of two spectra ./
            assert(nnz(obj1.wavelength == obj2.wavelength)==length(obj1.wavelength));

            obj3 = SpectrumClass(obj1.wavelength,obj1.amplitude ./ obj2.amplitude);
        end

    end

end

