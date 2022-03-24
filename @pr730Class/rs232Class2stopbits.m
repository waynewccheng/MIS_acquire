%%
% modified for Ludl stage

classdef rs232Class2stopbits
    %%
    properties
        S
    end
    
    %%
    methods

        function obj = rs232Class2stopbits (portname)
            obj.S = serial(portname,'RequestToSend','off','Timeout',3, 'Baudrate',9600, 'Parity', 'none','Stopbits', 2);
            fopen(obj.S);
        end
        
        %% close the serial port
        function close (obj)
            fclose(obj.S);
            delete(obj.S);
        end
        
        function ret = get (obj)
            ret = fgetl(obj.S);
        end
        
        %% get a 13-terminating string from the serial port
        function ret = get_old (obj)
            flag = 1;
            ret = '';
            while flag
                b = fread(obj.S,1,'uint8');
                if b == 13
                    flag = 0;
                    b2 = fread(obj.S,1,'uint8');
                else
                    ret = [ret b];
                end
            end
        end

        %% send a string+13 to the serial port
        function send (obj,str)
            fwrite(obj.S,str);
        end

    end
end
