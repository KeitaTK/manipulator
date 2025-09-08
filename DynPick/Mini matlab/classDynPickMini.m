classdef classDynPickMini < handle
    properties (Hidden)
    end
    
    properties (SetAccess = public)
        PORT_HANDLE;
        ZeroLSB = [ % Zero Output
            8192;
            8192;
            8192;
            8192;
            8192;
            8192
            ];
        LSBperNorNm = [ % Conversion Rate
            24; % Range: 21--27
            24;
            24;
            1638; % Ragne: 1474--1802
            1638;
            1638
            ];
    end
    
    properties (SetAccess = private)
        PORT_NAME = '';
        BAUD = 921600;
        TERMINATOR = 'CR/LF';
        TIMEOUT = 1;
%         IN_BUFF_SIZE = 128;
        IN_BUFF_SIZE = 2^17;
    end
    
%{

    % Define an event called InsufficientFunds
    events
        InsufficientFunds 
    end
%}
    methods
        function self = classDynPickMini (argPORT_NAME)
            self.PORT_NAME = argPORT_NAME;
            self.PORT_HANDLE = serial(self.PORT_NAME);
            self.PORT_HANDLE.BaudRate = self.BAUD;
            self.PORT_HANDLE.Terminator = self.TERMINATOR;
            self.PORT_HANDLE.Timeout = self.TIMEOUT;
            self.PORT_HANDLE.InputBufferSize = self.IN_BUFF_SIZE;
            fopen(self.PORT_HANDLE);
        end
        
        function delete (self)
            % object destructor
            % self is always scalar
            self.closePort();
        end
        
        function closePort (self)
            % Close port
            if strcmp( self.PORT_HANDLE.Status, 'open')
                self.stopDataSending();
                fclose(self.PORT_HANDLE);
                disp('Port closed.');
            end
        end
        
        function startDataSending(self)
            ser = self.PORT_HANDLE;
            fwrite(ser, double(uint8('S')));
        end
        
        function stopDataSending(self)
            ser = self.PORT_HANDLE;
            fwrite(ser, double(uint8('E')));
            self.clearBuffer();
        end
        
        function resetOffset(self)
            ser = self.PORT_HANDLE;
            fwrite(ser, double(uint8('O')));
        end
        
        function [value, num] = continuousRead(self)
            ser = self.PORT_HANDLE;
            num = -1;
            value = zeros(6,1); % Fx, Fy, Fz, Mx, My, Mz
            while ser.BytesAvailable ~= 0
                vec = string(fscanf(ser, '%s', ser.BytesAvailable));
                if strlength(vec)==25
                    num = str2double(extractBetween(vec,1,1));
                    for ii=1:6
                        temp = (ii-1)*4+2;
                        value(ii) = hex2dec(extractBetween(vec,temp,temp+3));
                        value(ii) = ( value(ii)-self.ZeroLSB(ii) )/self.LSBperNorNm(ii);
                    end
                    self.clearBuffer();
                    return;
                end
            end
        end
        
        function [value, num, time_ms] = continuousReadWithTimeMeasure(self)
            t = tic;
            [value, num] = self.continuousRead();
            time_ms = toc(t)*1e3;
        end
        
        function [value, num] = read(self)
            [value, num] = self.readRawLSB();
            for ii=1:6
                value(ii) = ( value(ii)-self.ZeroLSB(ii) )/self.LSBperNorNm(ii);
            end
        end
        
        function [value, num] = readRawLSB(self)
            ser = self.PORT_HANDLE;
            fwrite(ser, 82);
            % fwrite(ser, double(uint8('R')));
            t = tic;
            while ser.BytesAvailable == 0
                if toc(t)>self.TIMEOUT/5 % Timeout
                    num = -1;
                    value = zeros(6,1);
                    return;
                end
            end
            vec = string(fscanf(ser, '%s', ser.BytesAvailable));
            num = str2double(extractBetween(vec,1,1));
            value = zeros(6,1); % Fx, Fy, Fz, Mx, My, Mz
            for ii=1:6
                temp = (ii-1)*4+2;
                value(ii) = hex2dec(extractBetween(vec,temp,temp+3));
            end
        end
        
        function [value, num, time_ms] = readWithTimeMeasure(self)
            t = tic;
            [value, num] = self.read();
            time_ms = toc(t)*1e3;
        end
        
        function clearBuffer(self)
            ser = self.PORT_HANDLE;
            while ( ser.BytesAvailable > 0 )
                fread( ser, ser.BytesAvailable );
%                 fread( ser );
%                 fgets( ser );
%                 fscanf( ser );
            end
        end
        
    end % methods
%{
    methods(Static)
    end % methods(Static)
%}
end % classdef
