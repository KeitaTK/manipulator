classdef MPSSE
    properties (Hidden)
    end
    
    properties (SetAccess = private)
        pyObject;
    end
    
    properties (Constant)
        ver = '21.10.11'
    end
%{
    % Define an event called InsufficientFunds
    events
        InsufficientFunds 
    end
%}
    methods
        function self = MPSSE()
            % addpath('@MPSSE');
            self.pyObject =  py.MPSSE.MPSSE('./@MPSSE/libMPSSE.dll');
        end
        
        function delete (self)
            % object destructor
            % self is always scalar
            
        end
        function showDevices (self)
            self.pyObject.showDevices();
        end
        function openChannel (self, num)
            % def openChannel(self, num, clock=2e6, latency=2, mode=0):
            self.pyObject.openChannel (num);
        end
        function closeChannel (self)
            self.pyObject.closeChannel ();
        end
        function out = gpioRead (self)
            out = int64(self.pyObject.gpioRead ());
        end
        function out = gpioReadAsVector (self)
            bits = self.gpioRead();
            out = zeros(8,1);
            out(1) = bitand(bits, 1);
            out(2) = bitshift(bitand(bits, 2), -1);
            out(3) = bitshift(bitand(bits, 4), -2);
            out(4) = bitshift(bitand(bits, 8), -3);
            out(5) = bitshift(bitand(bits, 16), -4);
            out(6) = bitshift(bitand(bits, 32), -5);
            out(7) = bitshift(bitand(bits, 64), -6);
            out(8) = bitshift(bitand(bits, 128), -7);
        end

    end % methods
    methods(Static)
    end % methods(Static)
end % classdef
