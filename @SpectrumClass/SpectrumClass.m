%% SpectrumClass

classdef SpectrumClass < handle
    %SPECTRUMCLASS SpectrumClas SUMMARY
    %   Class for processing spectral data obtained by different
    %   spectroradiometers
    %
    %   WCC
    %   6/13/2022
    %   6/17/2022: added CIE_D

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


        function obj = addTime (obj, date, inst, time_used)
            %%ADDTIME Add time stamps to a measurement
            obj.date = date;
            obj.instrument = inst;
            obj.time_used = time_used;
        end

        function plot (obj)
            plot(obj.wavelength,obj.amplitude);
            xlabel('wavelength (nm)')
            ylabel('SPD')
            title('Spectrum')
        end

        function ret = XYZ (obj)
            spec = obj.amplitude(1:10:end);
            cc = ColorConversionClass;

            ret = cc.spd2XYZ(spec);
        end

        function ret = xyz (obj)
            XYZ = obj.XYZ;
            ret = XYZ ./ sum(XYZ);
        end

        function disp (obj)
            [obj.wavelength' obj.amplitude']
        end

        function obj3 = plus (obj1, obj2)
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

    methods (Static)

        function obj = CIE_D (T)
            % Convert CCK to spectrum
            % CCK = CIE D standard illuminants (D65, D50...)
            % 8-12-2015
            % 3/25/2022: classify
            % 6/17/2022: merged into SpectrumClass
            % spec = cieD2spec(6500); plot(spec);

            if nargin ~= 1
                fprintf('need CCK argument\n')
                return
            end

            % http://www.brucelindbloom.com/index.html?Eqn_DIlluminant.html

            if 4000 <= T && T <= 7000
                x = -4.6070e9/(T^3) + 2.9678e6/(T^2) + 0.09911e3/(T) + 0.244063;
            elseif 7000 < T && T <= 25000
                x = -2.0064e9/(T^3) + 1.9018e6/(T^2) + 0.24748e3/(T) + 0.237040;
            else
                fprintf('out of range\n')
                return
            end

            y = -3.0000 * (x^2) + 2.870 * x - 0.275;

            xy = [x y];

            %
            % http://www.brucelindbloom.com/index.html?Eqn_DIlluminant.html
            %
            % S0, S1, S2: 41x1 double
            S0 = [63.4000000000000;65.8000000000000;94.8000000000000;104.800000000000;105.900000000000;96.8000000000000;113.900000000000;125.600000000000;125.500000000000;121.300000000000;121.300000000000;113.500000000000;113.100000000000;110.800000000000;106.500000000000;108.800000000000;105.300000000000;104.400000000000;100;96;95.1000000000000;89.1000000000000;90.5000000000000;90.3000000000000;88.4000000000000;84;85.1000000000000;81.9000000000000;82.6000000000000;84.9000000000000;81.3000000000000;71.9000000000000;74.3000000000000;76.4000000000000;63.3000000000000;71.7000000000000;77;65.2000000000000;47.7000000000000;68.6000000000000;65];
            S1 = [38.5000000000000;35;43.4000000000000;46.3000000000000;43.9000000000000;37.1000000000000;36.7000000000000;35.9000000000000;32.6000000000000;27.9000000000000;24.3000000000000;20.1000000000000;16.2000000000000;13.2000000000000;8.60000000000000;6.10000000000000;4.20000000000000;1.90000000000000;0;-1.60000000000000;-3.50000000000000;-3.50000000000000;-5.80000000000000;-7.20000000000000;-8.60000000000000;-9.50000000000000;-10.9000000000000;-10.7000000000000;-12;-14;-13.6000000000000;-12;-13.3000000000000;-12.9000000000000;-10.6000000000000;-11.6000000000000;-12.2000000000000;-10.2000000000000;-7.80000000000000;-11.2000000000000;-10.4000000000000];
            S2 = [3;1.20000000000000;-1.10000000000000;-0.500000000000000;-0.700000000000000;-1.20000000000000;-2.60000000000000;-2.90000000000000;-2.80000000000000;-2.60000000000000;-2.60000000000000;-1.80000000000000;-1.50000000000000;-1.30000000000000;-1.20000000000000;-1;-0.500000000000000;-0.300000000000000;0;0.200000000000000;0.500000000000000;2.10000000000000;3.20000000000000;4.10000000000000;4.70000000000000;5.10000000000000;6.70000000000000;7.30000000000000;8.60000000000000;9.80000000000000;10.2000000000000;8.30000000000000;9.60000000000000;8.50000000000000;7;7.60000000000000;8;6.70000000000000;5.20000000000000;7.40000000000000;6.80000000000000];

            M = 0.0241 + 0.2562*x - 0.7341 * y;
            M1 = (-1.3515 - 1.7703*x + 5.9114*y) / M;
            M2 = (0.0300 - 31.4424*x + 30.0717*y) / M;

            % m12 = [M1 M2]

            %
            % 41x1
            %
            spec = S0 + M1 * S1 + M2 * S2;

            %
            % extend to 401x1 by interpolation
            %
            spec = interp1(380:10:780,spec,380:780);

            obj = SpectrumClass(380:780,spec);

            return
        end
   
    end

end

