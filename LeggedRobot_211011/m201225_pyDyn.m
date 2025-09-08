
DXL_IDs = cInt(v2c([16, 17, 18]));
BAUDRATE = uint32(1e6);
DEVICENAME = 'COM4';
dyn =  py.Dynamixel.Dynamixel(DEVICENAME, BAUDRATE);
% dyn.writeLED({uint8(18)}, {uint8(1)});
dyn.writeTorqueEnable(DXL_IDs, cInt(v2c([1, 1, 1])));
dyn.writeGoalPosition(DXL_IDs, cInt(v2c([1548,2048,2048])));
pause(0.5);
dyn.writeGoalPosition(DXL_IDs, cInt(v2c([2048,2048,2048])));
pause(0.5);
dyn.writeTorqueEnable(DXL_IDs, cInt(v2c([0, 0, 0])));

% dyn.readPresentCurrent(DXL_IDs)
function ret = v2c( vec )
    len = length(vec);
    ret = cell(1, len);
    for ii=1:len
        ret{ii} = vec(ii);
    end
end
function argCell = cInt( argCell )
    for ii=1:length(argCell)
        argCell{ii} = uint32(argCell{ii});
    end
end
