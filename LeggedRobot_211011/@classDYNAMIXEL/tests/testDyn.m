clear;
lib_name = 'dxl_x64_c';

% Load Libraries
if ~libisloaded(lib_name)
    [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h',...
        'addheader', 'port_handler.h',...
        'addheader', 'packet_handler.h');
end

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

% Default setting
PROTOCOL_VERSION            = 2.0;          % See which protocol version is used in the Dynamixel
DXL_ID                      = 1;            % Dynamixel ID: 1
BAUDRATE                    = 57600;
DEVICENAME                  = 'COM3';       % Check which port is being used on your controller

port_num = calllib(lib_name, 'portHandler', DEVICENAME);
calllib(lib_name, 'packetHandler');

% Open port
if (calllib(lib_name, 'openPort',port_num))
    fprintf('Succeeded to open the port!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to open the port!\n');
    input('Press any key to terminate...\n');
    return;
end
% Set port baudrate
if (calllib(lib_name, 'setBaudRate', port_num, BAUDRATE))
    fprintf('Succeeded to change the baudrate!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to change the baudrate!\n');
    input('Press any key to terminate...\n');
    return;
end

% Enable Dynamixel Torque
tic
calllib(lib_name, 'write1ByteTxOnly', port_num, PROTOCOL_VERSION, DXL_ID, 65, 1);
toc
pause(1.0);
% write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
dxl_comm_result = calllib(lib_name, 'getLastTxRxResult', port_num, PROTOCOL_VERSION);
dxl_error = calllib(lib_name, 'getLastRxPacketError', port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', calllib(lib_name, 'getTxRxResult', PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', calllib(lib_name, 'getRxPacketError', PROTOCOL_VERSION, dxl_error));
else
%     fprintf('Dynamixel has been successfully connected \n');
end

calllib(lib_name, 'write1ByteTxOnly', port_num, PROTOCOL_VERSION, DXL_ID, 65, 0);
tic
calllib(lib_name, 'write1ByteTxRx', port_num, PROTOCOL_VERSION, DXL_ID, 65, 1);
toc
pause(1.0);
calllib(lib_name, 'write1ByteTxRx', port_num, PROTOCOL_VERSION, DXL_ID, 65, 0);
% write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
dxl_comm_result = calllib(lib_name, 'getLastTxRxResult', port_num, PROTOCOL_VERSION);
dxl_error = calllib(lib_name, 'getLastRxPacketError', port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', calllib(lib_name, 'getTxRxResult', PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', calllib(lib_name, 'getRxPacketError', PROTOCOL_VERSION, dxl_error));
else
%     fprintf('Dynamixel has been successfully connected \n');
end


% Close port
calllib(lib_name, 'closePort', port_num);

% Unload Library
unloadlibrary(lib_name);
