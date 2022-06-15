%% SpectrumClass

classdef SpectrumClass
    %SPECTRUMCLASS SpectrumClas SUMMARY
    %   Class for processing spectral data obtained by different
    %   spectroradiometers
    %
    %   WCC
    %   6/13/2022

    %% Properties
    properties
        wavelength
        amplitude
        date
        instrument
    end

    %% Methods
    methods

        function obj = SpectrumClass (wl, amp)
            if nargin < 2
                disp('require wl and amp')
            else
                if size(wl) ~= size(amp)
                    disp('wrong size')
                else
                    obj.wavelength = wl;
                    obj.amplitude = amp;
                end
            end
        end


        function obj = addTime (obj, date, inst)
            %%ADDTIME Add time stamps to a measurement
            obj.date = date;
            obj.instrument = inst;
        end

        function plot (obj)
            plot(obj.wavelength,obj.amplitude);
            xlabel('wavelength (nm)')
            ylabel('SPD')
            title('Spectrum')
        end

        function disp (obj)
            [obj.wavelength' obj.amplitude']
        end

        function obj3 = plus (obj1, obj2)
            obj3 = SpectrumClass(obj1.wavelength,obj1.amplitude+obj2.amplitude);
        end

        function obj2 = mtimes (obj,s)
            obj2 = SpectrumClass(obj.wavelength,obj.amplitude*s);
        end
    end
end