%% Konica Minolta CS2000A control
% 6-28-2022 change measure to vertical nx2 
% 3-24-2022 old code doesn't work on Win7; replaced rs232 calls 
% 8-28-2015
classdef cs2000Class < handle
    %%
    properties
        ver = '6/28/2022'
        comPort
        settings
   end
    
    %%
    methods
        
        %% Enter remote mode
        function obj = cs2000Class (portname)
            % enter and exit the remote mode to avoid receiving the 'REMOTE MODE' message; should flush the serial port 
            % enter Remote mode

            %
            % must provide the port name
            %
            if nargin ~= 1
                fprintf('Specify the COM port number such as COM3\n')
                serialportlist("available")
                return
            end
            
            obj.comPort = rs232ClassCS2000(portname);
            
            obj.comPort.send('RMTS,1');

            obj.settings = 'CS2000';
            
            ret = obj.comPort.get;
        end
        
        %% Exit remote mode
        function ret = close (obj)

            obj.comPort.send('RMTS,0');
            ret = obj.comPort.get;

            % ? try?
            pause(5)
            
            % close RS232
            obj.comPort.close;
        end

        function Yxy = measure_Yxy (obj)

            %% --- trigger measurement
            obj.comPort.send('MEAS,1');

            % pre-measurement
            err = obj.comPort.get;
            if (err(1:5)=='OK00,')
                wait = err(6:length(err));
                waitsec = str2num(wait) + 1;
                pause(waitsec)
            else
                disp error pre-measure
                obj.comPort.close;
                obj.close;
            end

            % actual measurement completed
            err = obj.comPort.get;
            if (err(1:4)~='OK00')
                disp error actual
                obj.comPort.close;
                obj.close;
            end

            %% --- obtain colorimetric measurement data
            obj.comPort.send('MEDR,2,0,02');
            err = obj.comPort.get;
            if (err(1:4) ~= 'OK00')
                disp error obtain
                obj.comPort.close;
                obj.close;
            else
                % parse result
                val = textscan(err,'%s %f %f %f\n','Delimiter',',');
                vciex = cell2mat(val(2));
                vciey = cell2mat(val(3));
                vy = cell2mat(val(4));
                Yxy = [vy vciex vciey atan2d(vciey,vciex) (vciey.^2+vciex.^2).^0.5];
            end            
        end
        
        %% Take a measurement
        function myspec = measure (obj)

            spec = zeros(1,401);

            %% --- trigger measurement
            obj.comPort.send('MEAS,1');

            % pre-measurement
            err = obj.comPort.get;
            if (err(1:5)=='OK00,')
                wait = err(6:length(err));
                waitsec = str2num(wait) + 1;
                pause(waitsec)
            else
                disp error pre-measure
                obj.comPort.close;
                obj.close;
            end

            % actual measurement completed
            err = obj.comPort.get;
            if (err(1:4)~='OK00')
                disp error actual
                obj.comPort.close;
                obj.close;
            end

            %% --- obtain colorimetric measurement data
            obj.comPort.send('MEDR,2,0,02');
            err = obj.comPort.get;
            if (err(1:4) ~= 'OK00')
                disp error obtain
                obj.comPort.close;
                obj.close;
            else
                % parse result
                val = textscan(err,'%s %f %f %f\n','Delimiter',',');
                vciex = cell2mat(val(2));
                vciey = cell2mat(val(3));
                vy = cell2mat(val(4));
                Yxy = [vy vciex vciey];
                
                % show the Yxy?
                Yxy
                %
            end

            %% --- obtain spectral measurement data
            
            % receiving spectrum needs 4 reads 
            specindex = 1;
            
            %% 1st read
            obj.comPort.send('MEDR,1,0,01');
            err = obj.comPort.get;
            if (err(1:4) ~= 'OK00')
                disp error obtain
                obj.exit;
                obj.comPort.close;
            else
                % parse result
                commapos = strfind(err,',');
                commapos(101) = length(err)+1;

                for i = 1:100
                   wavelength = err(commapos(i)+1:commapos(i+1)-1);
                   spec(specindex) = str2num(wavelength);
                   specindex = specindex + 1;
                end
            end

            %% 2nd read
            obj.comPort.send('MEDR,1,0,02');
            err = obj.comPort.get;
            if (err(1:4) ~= 'OK00')
                disp error obtain
                obj.comPort.close;
                obj.close;
            else
                % parse result
                commapos = strfind(err,',');
                commapos(101) = length(err)+1;

                for i = 1:100
                   wavelength = err(commapos(i)+1:commapos(i+1)-1);
                   spec(specindex) = str2num(wavelength);
                   specindex = specindex + 1;
                end
            end

            %% 3rd read
            obj.comPort.send('MEDR,1,0,03');
            err = obj.comPort.get;
            if (err(1:4) ~= 'OK00')
                disp error obtain
                obj.exit;
                obj.comPort.close;
            else
                % parse result
                commapos = strfind(err,',');
                commapos(101) = length(err)+1;

                for i = 1:100
                   wavelength = err(commapos(i)+1:commapos(i+1)-1);
                   spec(specindex) = str2num(wavelength);
                   specindex = specindex + 1;
                end
            end

            %% 4th read
            obj.comPort.send('MEDR,1,0,04');
            err = obj.comPort.get;
            if (err(1:4) ~= 'OK00')
                disp error obtain
                obj.comPort.close;
                obj.close;
            else
                % parse result
                commapos = strfind(err,',');
                commapos(102) = length(err)+1;

                for i = 1:101
                   wavelength = err(commapos(i)+1:commapos(i+1)-1);
                   spec(specindex) = str2num(wavelength);
                   specindex = specindex + 1;
                end
            end
            
            %% return spectrum class
            % changed to vertical 6/28/2022
            myspec = SpectrumClass([380:780]',spec');
        end

    end
end