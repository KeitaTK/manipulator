 BUFSIZE = uint16(1024);

MatIP = "127.0.0.1";
MatSendPort = uint16(22221);
MatSendAddr = {MatIP, MatSendPort};
MatRcvPort = uint16(22222);
MatRcvAddr = {MatIP, MatRcvPort};

PyIP = "127.0.0.1";
% PySendPort = 11111
PyRcvPort = uint16(11112);
PyRcvAddr = {PyIP,PyRcvPort};

matSendSock = py.SocketExt.SocketExt(py.socket.AF_INET, py.socket.SOCK_DGRAM);
matSendSock.bind(MatSendAddr);

matRcvSock = py.SocketExt.SocketExt(py.socket.AF_INET, py.socket.SOCK_DGRAM);
matRcvSock.bind(MatRcvAddr);
matRcvSock.setblocking(0);

% Exit command, must run
% matSendSock.sendComplexListTo('B',{ uint8(81) },PyRcvAddr);

%{
while (1)
    matSendSock.sendComplexListTo('B',{ uint8(82) },PyRcvAddr);
    result = matRcvSock.recvComplexListFrom('3d', BUFSIZE);
    addr = cell(result{2});
    ip = string(addr{1});
    port = double(addr{2});
    if port % data recieved
        data = cell(result{1});
        disp(data);
%         disp(double(data{1}));
    end
    
    pause(1.0);
end
%}
