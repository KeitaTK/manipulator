#!/usr/bin/env python
# -*- coding: utf-8 -*-


import struct
import socket
import time

class SocketExt(socket.socket):
    def __init__(self, af, sock):
        socket.socket.__init__(self, af, sock)
    # def __del__(self):
    def sendComplexListTo(self, dataformat, data, addr):
        data_ = struct.pack(dataformat, *data)
        self.sendto(data_, addr)
    def recvComplexListFrom(self, dataformat, buf_size):
        try:
            data, addr = self.recvfrom(buf_size)
        except socket.error:
            data_ = []
            addr = ('0.0.0.0',0)
            pass
        else:
            data_ = struct.unpack(dataformat, data)
        return data_, addr

    def sendIntListTo(self, data, addr):
        data_ = struct.pack('%sB' % len(data), *data)
        self.sendto(data_, addr)
    def sendDoubleListTo(self, data, addr):
        data_ = struct.pack('%sd' % len(data), *data)
        self.sendto(data_, addr)
    def recvDoubleListFrom(self, buf_size):
        data, addr = self.recvfrom(buf_size)
        data_ = struct.unpack('%sd' % int(len(data)/8), data)
        return list(data_), addr

    # def bytes2float(self, data):
    #     data_ = struct.unpack('%sd' % int(len(data)/8), data)
    #     return list(data_)
    # def float2bytes(self, data):
    #     data_ = struct.pack('%sd' % len(data), *data)
    #     return list(data_)
    # def list2float(self, data):
    #     data_ = struct.pack('%sB' % len(data), *data)
    #     data__ = struct.unpack('%sd' % int(len(data_)/8), data_)
    #     return list(data__)
    # def float2list(self, data):
    #     data_ = struct.pack('%sd' % len(data), *data)
    #     data__ = struct.unpack('%sB' % len(data_), data_)
    #     return list(data__)

def rcv():
    # 受信側アドレスの設定
    SrcAddr = ("127.0.0.1", 22222) # 受信側IP，受信側ポート番号        
    # バッファサイズ指定
    BUFSIZE = 1024

    # ソケット作成
    udpServSock = SocketExt(socket.AF_INET, socket.SOCK_DGRAM)
    # 受信側アドレスでソケットを設定
    udpServSock.bind(SrcAddr)
    udpServSock.setblocking(0)

    while True:                                     
        data, addr = udpServSock.recvComplexListFrom('3dB', BUFSIZE) 
        print(data, addr)
        print('---')
        time.sleep(1.0)
    # udpServSock.close()
if __name__ == '__main__':
    rcv()
