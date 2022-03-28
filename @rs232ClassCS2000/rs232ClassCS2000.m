%%
% WCC 3-24-2022
classdef rs232ClassCS2000
    %%
    properties
        S
    end
    
    %%
    methods

        function obj = rs232ClassCS2000 (portname)
            obj.S = serialport(portname,38400,'DataBits',8,'StopBits',1,'FlowControl','none');
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
                else
                    ret = [ret b];
                end
            end
        end

        %% send a string+13 to the serial port
        function send (obj,str)
            write(obj.S,str,"uint8");
            write(obj.S,13,"uint8");
        end

    end
end
