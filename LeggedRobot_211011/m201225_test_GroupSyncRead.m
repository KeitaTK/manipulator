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

%     xm430.writeGoalPosition(DynId{6}, [1548; 2048; 2048]);
%     pause(1.0);
    dxl_ID = DynId{6};
    xm430.readPresentCurrent(dxl_ID)
%     n = length(dxl_ID);
%     addr = uint16(126);
%     len = uint8(2);
%     groupSyncReadObj = xm430.groupSyncRead(addr, len);
% %     xm430.groupSyncReadClearParam(groupSyncReadObj);
%     for ii=1:n
%         dxl_addparam_result = xm430.groupSyncReadAddParam( groupSyncReadObj, uint8(dxl_ID(ii)) );
%         if dxl_addparam_result ~= true
%             fprintf('[ID:%03d] groupSyncRead addparam failed', dxl_ID(ii));
%             return;
%         end
%     end
%     xm430.groupSyncReadTxRxPacket(groupSyncReadObj);
%     dxl_comm_result = xm430.getLastTxRxResult();
%     if dxl_comm_result ~= xm430.COMM_SUCCESS
%         fprintf('%s\n', xm430.getTxRxResult(dxl_comm_result));
%     end
%     for ii=1:n
%         dxl_getdata_result = xm430.groupSyncReadIsAvailable(groupSyncReadObj, uint8(dxl_ID(ii)), addr, len);
%         if dxl_getdata_result ~= true
%           fprintf('[ID:%03d] groupSyncRead getdata failed', dxl_ID(ii));
%           return;
%         end
%     end
%     value = zeros(n, 1);
%     for ii=1:n
%         value(ii) = double( xm430.groupSyncReadGetData(groupSyncReadObj, uint8(dxl_ID(ii)), addr, len) );
%         if value(ii) >= 2^(len*8-1)
%             value(ii) = -( 2^(len*8) - value(ii) );
%         end
%     end
%     disp(value);

%     xm430.writeGoalPosition(DynId{6}, [2048; 2048; 2048]);
    pause(1.0);
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end

