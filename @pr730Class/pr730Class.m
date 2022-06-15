classdef pr730Class < handle
    %%PR730CLASS Class for Photo Research PR730 Spectroradiometer
    %
    %   WCC 3/22/2022, 9/24/2015, 6/13/2022
    %   Last used on HIMSs, Matlab R2022a, 6/13/2022
    %   Last used on Ivies, Matlab R2020b
    %   needs to be a subclass of handle to use destructor
    
    properties
        ver = '6/13/2022'
        comPort
        connected = false
        settings
    end
    
    methods
        %% Enter remote mode
        function obj = pr730Class (portname)
            % enter and exit the remote mode to avoid receiving the 'REMOTE MODE' message; should flush the serial port
            % enter Remote mode
            
            if nargin ~= 1
                fprintf('Specify the COM port number such as COM3\n')
                serialportlist('available')
                return
            end
            
            obj.comPort = rs232Class(portname);
            
            obj.comPort.send('P');
            obj.comPort.send('H');
            obj.comPort.send('O');
            obj.comPort.send('T');
            obj.comPort.send('O');
            
            pause(2)
            
            obj.settings = obj.status
            
            obj.connected = true;
            
            return
            
        end
        
        
        %%
        function close (obj)
            % exit Remote mode
            obj.comPort.send('Q')
            obj.comPort.send(13)
            
            % close RS232
            obj.comPort.close;
            
            pause(1)
        end
        
        %%
        function ret = status (obj)
            obj.comPort.send('D')
            obj.comPort.send('602')
            obj.comPort.send(13)
            
            ret = obj.comPort.get;
        end
        
        %%
        function spect = measure (obj)
            slocal = zeros(401,2);
            
            % send command to take a measurement
            obj.comPort.send('M')
            obj.comPort.send('5')
            obj.comPort.send(13)
            
            % obtain reading here
            k = obj.comPort.get;
            
            % get rid of the leading 'REMOTE MODE'
            while (k(1)>'9' || k(1)<'0')
                k = k(2:end);
            end
            
            ind = 0;
            for ii = 380:780
                k = obj.comPort.get;
                % get rid of the leading 'REMOTE MODE'
                while (k(1)>'9' || k(1)<'0')
                    k = k(2:end);
                end
                val = textscan(k,'%d,%f\n');
                val2 = cell2mat(val(2));
                
                ind = ind + 1;
                slocal(ind,1) = ii;
                slocal(ind,2) = val2;
            end
            
            measure_time = datetime;
            measure_inst = obj.settings;
            spect = SpectrumClass(slocal(:,1),slocal(:,2));
            spect.addTime(measure_time,measure_inst);
        end
        
        function ret = mode4x (obj)
            
            % send command to take a measurement
            obj.comPort.send('S')
            obj.comPort.send('G')
            obj.comPort.send('3')
            obj.comPort.send(13)
            
            % obtain reading here
            ret = obj.comPort.get;
            
        end
        
        %%
        function ret = mode1x (obj)
            
            % send command to take a measurement
            obj.comPort.send('S')
            obj.comPort.send('G')
            obj.comPort.send('0')
            obj.comPort.send(13)
            
            % obtain reading here
            ret = obj.comPort.get;
            
        end
        
        %% destructor
        % exit remote mode and close RS232
        % because frequently forgot to close PR730 before exiting Matlab
        % doesn't work as hoped
        function delete (obj)
            if obj.connected
                instrfindall
                ['Deleting PR730 object...']
                obj.connected = false;
                obj.close;
            end
            return
        end
    end
    
end
