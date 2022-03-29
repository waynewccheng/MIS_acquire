%%
classdef rs232Class
    %%
    properties
        S
    end
    
    %%
    methods

        function obj = rs232Class (portname)
            obj.S = serialport(portname,9600,'DataBits',8,'StopBits',1,'FlowControl','none','Timeout',60);
        end
        
        %% close the serial port
        function close (obj)
%            fclose(obj.S);
%            delete(obj.S);
        end

        %% get a 13-terminating string from the serial port
        function ret = get (obj)
            flag = 1;
            ret = '';
            while flag
                b = read(obj.S,1,'uint8');
                if b == 13
                    flag = 0;
                    b2 = read(obj.S,1,'uint8');
                else
                    ret = [ret b];
                end
            end
        end

        %% send a string+13 to the serial port
        function send (obj,str)
            write(obj.S,str,"uint8");
        end

    end
end
