clear;
xm430 = classDYNAMIXEL('COM4', 1e6); % (port, baud)
if (xm430.failed == 1)
    return;
end

try

    DynIDAll = zeros(18,1);
    DynIDAll = 1:18;

    DynId = cell(6);
    DynId{1} = [1; 2; 3];
    DynId{2} = [4; 5; 6];
    DynId{3} = [7; 8; 9];
    DynId{4} = [10; 11; 12];
    DynId{5} = [13; 14; 15];
    DynId{6} = [16; 17; 18];

    xm430.writeOperatingMode(DynIDAll, 3*ones(18,1));
    xm430.writeTorqueEnable(DynIDAll, 1*ones(18,1));

    xm430.writeGoalPosition(DynId{6}, [1548; 2048; 2048]);
    pause(1.0);
    
    groupSyncWriteObj = xm430.groupSyncWrite(uint16(116), uint8(4));
    xm430.groupSyncWriteClearParam(groupSyncWriteObj);
    dxl_addparam_result = xm430.groupSyncWriteAddParam(groupSyncWriteObj, uint8(16), uint32(2048), uint8(4));
    if dxl_addparam_result ~= true
        fprintf('[ID:%03d] groupSyncWrite addparam failed', 16);
        return;
    end
    dxl_addparam_result = xm430.groupSyncWriteAddParam(groupSyncWriteObj, uint8(17), uint32(2048), uint8(4));
    if dxl_addparam_result ~= true
        fprintf('[ID:%03d] groupSyncWrite addparam failed', 17);
        return;
    end
    dxl_addparam_result = xm430.groupSyncWriteAddParam(groupSyncWriteObj, uint8(18), uint32(2048), uint8(4));
    if dxl_addparam_result ~= true
        fprintf('[ID:%03d] groupSyncWrite addparam failed', 18);
        return;
    end
    xm430.groupSyncWriteTxPacket(groupSyncWriteObj);
%     dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
%     if dxl_comm_result ~= xm430.COMM_SUCCESS
%         fprintf('%s\n', getTxRxResult('ver2.0', dxl_comm_result));
%     end
%         dxl_getdata_result = groupSyncReadIsAvailable(groupread_num, DXL1_ID, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);
%         if dxl_getdata_result ~= true
%           fprintf('[ID:%03d] groupSyncRead getdata failed', DXL1_ID);
%           return;
%         end
%     dxl_comm_result = getLastTxRxResult



%     xm430.writeGoalPosition(DynId{6}, [2048; 2048; 2048]);
    pause(1.0);
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end

