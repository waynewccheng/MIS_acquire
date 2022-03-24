%%
classdef rs232Class
    %%
    properties
        S
    end
    
    %%
    methods

        function obj = rs232Class (portname)
            obj.S = serial(portname,'RequestToSend','off','BaudRate',9600,'DataBits',8,'StopBits',1,'FlowControl','none');
            fopen(obj.S);
        end
        
        %% close the serial port
        function close (obj)
            fclose(obj.S);
            delete(obj.S);
        end

        %% get a 13-terminating string from the serial port
        function ret = get (obj)
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
