%%
classdef rs232ClassWheel
    %%
    properties
        S
    end
    
    %%
    methods

        function obj = rs232ClassWheel (portname)
            obj.S = serialport(portname,115200,'DataBits',8,'StopBits',1,'Parity','none','FlowControl','none','Timeout',5);
        end
        
        %% close the serial port
        function delete (obj)
            delete(obj.S)
        end

        %% get a 13-terminating string from the serial port
        function ret = get (obj)
            
            n = obj.S.NumBytesAvailable;
            if n > 0
                ret = char(read(obj.S,n,'uint8'));
            else
                ret = '';
            end
            
        end

        %% send a string+13 to the serial port
        function send (obj,str)
            
            % send the string char by char
            n = length(str);
            for i = 1:n
                write(obj.S,str(i),"uint8");
            end

            % add "CR"
            write(obj.S,13,"uint8");

        end

    end
end
