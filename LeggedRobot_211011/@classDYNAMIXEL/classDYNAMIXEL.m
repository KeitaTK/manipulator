classdef classDYNAMIXEL
    properties (Hidden)
    end
    
    properties (SetAccess = private)
        failed = 1;
        lib_name = 'dxl_x64_c';
        port_num;

        COMM_SUCCESS                = 0;            % Communication Success result value
        COMM_TX_FAIL                = -1001;        % Communication Tx Failed

        % Default setting
        PROTOCOL_VERSION            = int32(2.0);          % See which protocol version is used in the Dynamixel
        BAUDRATE;
        % 0:9600, 1:57600, 2:115200, 3:1e6, 4:2e6, 5:3e6, 6:4e6, 7:4.5e6
        DEVICENAME;       % Check which port is being used on your controller
    end
    
    properties (Constant)
        ver = '20.11.27-SyncWriteIsNotSupportedForGoalPosition'
    end
%{
    % Define an event called InsufficientFunds
    events
        InsufficientFunds 
    end
%}
    methods
        function self = classDYNAMIXEL(PORT, BAUD)
            self.DEVICENAME = PORT;
            self.BAUDRATE = BAUD;
            % 0:9600, 1:57600, 2:115200, 3:1e6, 4:2e6, 5:3e6, 6:4e6, 7:4.5e6

            % Load Libraries
            notfound = {};
            warnings = '';
            % Load Libraries
            if ~libisloaded(self.lib_name)
                [notfound, warnings] = loadlibrary(self.lib_name, 'dynamixel_sdk.h',...
                    'addheader', 'port_handler.h',...
                    'addheader', 'packet_handler.h',...
                    'addheader', 'group_sync_write.h',...
                    'addheader', 'group_sync_read.h',...
                    'addheader', 'group_bulk_read.h',...
                    'addheader', 'group_bulk_write.h');
            end
            if size(notfound)*[1;0] ~= 0
%                 disp(size(notfound)*[1;0]);
                disp('notfound');
            end
%             fprintf('warnings:%s',warnings);
%             disp('You get warning every time');

            self.port_num = int32( calllib(self.lib_name, 'portHandler', self.DEVICENAME) );
            disp(self.port_num);
            calllib(self.lib_name, 'packetHandler');

            % Open port
            if (calllib(self.lib_name, 'openPort',self.port_num))
                fprintf('Succeeded to open the port!\n');
                % Set port baudrate
                if (calllib(self.lib_name, 'setBaudRate', self.port_num, self.BAUDRATE))
                    fprintf('Succeeded to change the baudrate!\n');
                    self.failed = 0;
                else
                    unloadlibrary(self.lib_name);
                    fprintf('Failed to change the baudrate!\n');
                    self.failed = 1;
%                     self.delete();
                    self.closePort();
%                     input('Press any key to terminate...\n');
%                     return;
                end
            else
                unloadlibrary(self.lib_name);
                fprintf('Failed to open the port!\n');
                self.failed = 1;
%                 self.delete();
                self.closePort();
%                 input('Press any key to terminate...\n');
%                 return;
            end
            
%             try
%             catch MExc
%                 disp(MExc.message);
%             end
        end
        
        function delete (self)
            % object destructor
            % self is always scalar
            disp('deleted. port closing');
            self.closePort();
        end

        function closePort(self)
            % Close port
            calllib(self.lib_name, 'closePort', self.port_num);
            % Unload Library
%             unloadlibrary(self.lib_name);
        end
        
        %% Basic Functions
        function value = read1ByteTxRx(self, dxl_ID, addr)
            value = double( calllib(self.lib_name, 'read1ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr)) );
        end
        function read1ByteTx(self, dxl_ID, addr)
            calllib(self.lib_name, 'read1ByteTx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr));
        end
        function value = read1ByteRx(self)
            value = double( calllib(self.lib_name, 'read1ByteTxRx', self.port_num, self.PROTOCOL_VERSION) );
        end
        function value = read2ByteTxRx(self, dxl_ID, addr)
            value = double( calllib(self.lib_name, 'read2ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr)) );
        end
        function value = read4ByteTxRx(self, dxl_ID, addr)
            value = double( calllib(self.lib_name, 'read4ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr)) );
        end
        function write1ByteTxOnly(self, dxl_ID, addr, value)
            calllib(self.lib_name, 'write1ByteTxOnly', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr), uint8(value));
        end
        function write1ByteTxRx(self, dxl_ID, addr, value)
            calllib(self.lib_name, 'write1ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr), uint8(value));
        end
        function write2ByteTxOnly(self, dxl_ID, addr, value)
            calllib(self.lib_name, 'write2ByteTxOnly', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr), uint16(value));
        end
        function write2ByteTxRx(self, dxl_ID, addr, value)
            calllib(self.lib_name, 'write2ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr), uint16(value));
        end
        function write4ByteTxOnly(self, dxl_ID, addr, value)
            calllib(self.lib_name, 'write4ByteTxOnly', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr), uint32(value));
        end
        function write4ByteTxRx(self, dxl_ID, addr, value)
            calllib(self.lib_name, 'write4ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID), uint16(addr), uint32(value));
        end
        function VALUE = getLastTxRxResult(self)
            VALUE = calllib(self.lib_name, 'getLastTxRxResult', self.port_num, self.PROTOCOL_VERSION);
        end
        function STRING = getTxRxResult(self, result)
            STRING = calllib(self.lib_name, 'getTxRxResult', self.PROTOCOL_VERSION, result);
        end

            %% group sync r/w
        function groupNum = groupSyncWrite(self, addr, len)
            groupNum = calllib(self.lib_name, 'groupSyncWrite', self.port_num, self.PROTOCOL_VERSION, addr, len);
        end 
        function result = groupSyncWriteAddParam(self, groupNum, id, value, len)
            result = calllib(self.lib_name, 'groupSyncWriteAddParam', groupNum, id, value, len);
        end
        function groupSyncWriteClearParam( self, groupNum )
            calllib(self.lib_name, 'groupSyncWriteClearParam', groupNum);
        end
        function groupSyncWriteTxPacket(self, groupNum)
            calllib(self.lib_name, 'groupSyncWriteTxPacket', groupNum);
        end
        function groupNum = groupSyncRead(self, addr, len)
            groupNum = calllib(self.lib_name, 'groupSyncRead', self.port_num, self.PROTOCOL_VERSION, addr, len);
        end
        function VALUE = groupSyncReadAddParam(self, groupNum, id )
            VALUE = calllib(self.lib_name, 'groupSyncReadAddParam', groupNum, id);
        end
        function groupSyncReadTxRxPacket(self, groupNum )
            calllib(self.lib_name, 'groupSyncReadTxRxPacket', groupNum);
        end
        function VALUE = groupSyncReadIsAvailable(self, groupNum, id, address, data_length )
            VALUE = calllib(self.lib_name, 'groupSyncReadIsAvailable', groupNum, id, address, data_length);
        end
        function VALUE = groupSyncReadGetData(self, groupNum, id, address, data_length )
            VALUE = calllib(self.lib_name, 'groupSyncReadGetData', groupNum, id, address, data_length);
        end
        
        
        % function [VALUE] = groupSyncWriteChangeParam( group_num, id, data, data_length, data_pos )
        % end
        % function [] = groupSyncWriteRemoveParam( group_num, id )
        % end
        
        %% Convenient functions
        function writeReturnDelayTime(self, dxl_ID, value)
            addr = 9;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write1ByteTxOnly(dxl_ID(ii), addr, value(ii));
            end
        end
        function value = readReturnDelayTime(self, dxl_ID)
            addr = 9;
            n = length(dxl_ID);
            value = zeros(n, 1);
            for ii=1:n
                value(ii) = self.read1ByteTxRx(dxl_ID(ii), addr);
            end
        end
        function writeDriveMode(self, dxl_ID, value)
            addr = 10;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write1ByteTxOnly(dxl_ID(ii), addr, value(ii));
            end
        end
        function value = readDriveMode(self, dxl_ID)
            addr = 10;
            n = length(dxl_ID);
            value = zeros(n, 1);
            for ii=1:n
                value(ii) = self.read1ByteTxRx(dxl_ID(ii), addr);
            end
        end
        function writeOperatingMode(self, dxl_ID, value)
            addr = 11;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write1ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writeHomingOffset(self, dxl_ID, value)
            addr = 20;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write4ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writePWMLimit(self, dxl_ID, value)
            addr = 36;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write2ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writeCurrentLimit(self, dxl_ID, value)
            addr = 38;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write2ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writeVelocityLimit(self, dxl_ID, value)
            addr = 44;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write4ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writeMaxPositionLimit(self, dxl_ID, value)
            addr = 48;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write4ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writeMinPositionLimit(self, dxl_ID, value)
            addr = 52;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write4ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writeTorqueEnable(self, dxl_ID, value)
            addr = 64;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write1ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function writeLED(self, dxl_ID, value)
            addr = 65;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write1ByteTxRx(dxl_ID(ii), addr, value(ii));
            end
        end
        function value = readLED(self, dxl_ID)
            addr = 65;
            n = length(dxl_ID);
            value = zeros(n, 1);
            for ii=1:n
                value(ii) = self.read1ByteTxRx(dxl_ID(ii), addr);
            end
        end
        function writeStatusReturnLevel(self, dxl_ID, value)
            addr = 68;
            n = min([length(dxl_ID); length(value)]);
            for ii=1:n
                self.write1ByteTxOnly(dxl_ID(ii), addr, value(ii));
            end
        end
        function value = readStatusReturnLevel(self, dxl_ID)
            addr = 68;
            n = length(dxl_ID);
            value = zeros(n, 1);
            for ii=1:n
                value(ii) = self.read1ByteTxRx(dxl_ID(ii), addr);
            end
        end
        function writeGoalCurrent(self, dxl_ID, value)
            addr = uint16(102);
            n = length(dxl_ID);
            for ii=1:n
                calllib(self.lib_name, 'write2ByteTxOnly', self.port_num, ...
                    self.PROTOCOL_VERSION, uint8(dxl_ID(ii)), addr, uint16(value(ii)));
            end
        end
        function writeGoalVelocity(self, dxl_ID, value)
            addr = uint16(104);
            n = length(dxl_ID);
            for ii=1:n
                calllib(self.lib_name, 'write4ByteTxOnly', self.port_num, ...
                    self.PROTOCOL_VERSION, uint8(dxl_ID(ii)), addr, uint32(value(ii)));
            end
        end
        function value = writeGoalPosition(self, dxl_ID, value)
            n = length(dxl_ID);
            addr = uint16(116);
            len = uint8(4);
            groupSyncWriteObj = self.groupSyncWrite(addr, len);
            % self.groupSyncWriteClearParam(groupSyncWriteObj);
            for ii=1:n
                dxl_addparam_result = self.groupSyncWriteAddParam(groupSyncWriteObj, uint8(dxl_ID(ii)), uint32(value(ii)), len);
                if dxl_addparam_result ~= true
                    fprintf('[ID:%03d] groupSyncWrite addparam failed', dxl_ID(ii));
                    return;
                end
            end
            self.groupSyncWriteTxPacket(groupSyncWriteObj);
            % n = length(dxl_ID);
            % for ii=1:n
            %     calllib(self.lib_name, 'write4ByteTxOnly', self.port_num, ...
            %         self.PROTOCOL_VERSION, uint8(dxl_ID(ii)), addr, uint32(value(ii)));
            % end
        end
        function value = readPresentCurrent(self, dxl_ID)
            addr = uint16(126);
            n = length(dxl_ID);
            value = zeros(n, 1);
            % for ii=1:n
            %     value(ii) = double( calllib(self.lib_name, 'read2ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID(ii)), addr) );
            % end
            len = uint8(2);
            groupSyncReadObj = self.groupSyncRead(addr, len);
            % xm430.groupSyncReadClearParam(groupSyncReadObj);
            for ii=1:n
                dxl_addparam_result = self.groupSyncReadAddParam( groupSyncReadObj, uint8(dxl_ID(ii)) );
                if dxl_addparam_result ~= true
                    fprintf('[ID:%03d] groupSyncRead addparam failed', dxl_ID(ii));
                    return;
                end
            end
            self.groupSyncReadTxRxPacket(groupSyncReadObj);
            dxl_comm_result = self.getLastTxRxResult();
            if dxl_comm_result ~= self.COMM_SUCCESS
                fprintf('%s\n', self.getTxRxResult(dxl_comm_result));
            end
            for ii=1:n
                dxl_getdata_result = self.groupSyncReadIsAvailable(groupSyncReadObj, uint8(dxl_ID(ii)), addr, len);
                if dxl_getdata_result ~= true
                  fprintf('[ID:%03d] groupSyncRead getdata failed', dxl_ID(ii));
                  return;
                end
            end
            for ii=1:n
                value(ii) = double( self.groupSyncReadGetData(groupSyncReadObj, uint8(dxl_ID(ii)), addr, len) );
                if value(ii) >= 2^(double(len)*8-1)
                    value(ii) = -( 2^(double(len)*8) - value(ii) );
                end
            end
        end
        function value = readPresentPosition(self, dxl_ID)
            addr = uint16(132);
            n = length(dxl_ID);
            value = zeros(n, 1);
            for ii=1:n
                value(ii) = double( calllib(self.lib_name, 'read4ByteTxRx', self.port_num, self.PROTOCOL_VERSION, uint8(dxl_ID(ii)), addr) );
            end
        end

%{
% Error processing is not implemented.
dxl_comm_result = calllib(lib_name, 'getLastTxRxResult', port_num, PROTOCOL_VERSION);
dxl_error = calllib(lib_name, 'getLastRxPacketError', port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', calllib(lib_name, 'getTxRxResult', PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', calllib(lib_name, 'getRxPacketError', PROTOCOL_VERSION, dxl_error));
else
%}        
        
    end % methods
    methods(Static)
    end % methods(Static)
end % classdef
