clear;
py.DynPick.DynPick.show_list_ports();
% dpick = py.DynPick.DynPick('COM4'); % ポート番号は適宜変更すること
dpick = py.DynPick.DynPick.open_ports_by_serial_number("AU05U761A");

dpick.show_firmware_version();
dpick.show_sensitivity();
disp(string(dpick.read_temperature())+'(deg C)');

data = dpick.read_once();
disp(double(data));
disp("[N], [Nm]");

dpick.start_continuous_read();
tic;
for ii=1:1000
    data = dpick.read_continuous();
end
toc
disp(double(data));
disp("[N], [Nm]");

clear dpick;
