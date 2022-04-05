classdef wheelClass < handle
    %Filter Wheel Thorlabs FW102
    %
    %   WCC 4/5/2022
    
    properties
        comPort
        state = "";
    end
    
    methods

        function obj = wheelClass (portname)
           
            if nargin ~= 1
                fprintf('Specify the COM port number such as COM3\n')
                serialportlist("available")
                return
            end
            
            obj.comPort = rs232ClassWheel(portname);
            
            obj.state = obj.getstatus;

            return
            
        end
        
        
        %%
        function ret = getstatus (obj)

            obj.comPort.send('*idn?')
            
            pause(2)

            ret = obj.comPort.get;
            
        end

        %%
        function ret = getpos (obj)

            obj.comPort.send('pos?')
            
            pause(1)

            ret = obj.comPort.get;
            
        end
        
        %%
        function ret = setpos (obj, pos)

            
            obj.comPort.send(sprintf('pos=%d',pos));
            
            pause(1)

            ret = obj.comPort.get;
            
        end
       
        %% destructor
        % exit remote mode and close RS232
        % because frequently forgot to close PR730 before exiting Matlab
        % doesn't work as hoped
        function delete (obj)
            delete(obj.comPort)
            return
        end
    end
    
end
