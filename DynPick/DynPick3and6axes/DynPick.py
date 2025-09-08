#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import serial
import serial.tools.list_ports
import struct

class DynPick:
    # LPFとゼロ点の設定は未実装，他は実装済み
    ver = '23.10.27'
    is_started = 0
    force = [0]*6
    digit = [0]*6
    sensitivity = [1]*6
    def __init__(self, port):
        self.ser = serial.Serial(
            port,
            baudrate = 921600,
            # parity = serial.PARITY_NONE,
            # bytesize = serial.EIGHTBITS,
            # stopbits = serial.STOPBITS_ONE,
            # timeout = None,
            # xonxoff = 0,
            # rtscts = 0,
            )
        self.stop_continuous_read()
        self.autoset_sensitivity()
    def __del__(self):
        self.close()
    def close(self):
        if self.ser.is_open:
            self.stop_continuous_read()
            self.ser.close()
    def show_firmware_version(self):
        time.sleep(0.100)
        self.ser.flush()
        self.ser.write([ord('V')])
        time.sleep(0.100)
        in_waiting = self.ser.in_waiting
        if in_waiting > 0:
            print(self.ser.read(in_waiting).decode())
    def show_sensitivity(self):
        time.sleep(0.100)
        self.ser.flush()
        self.ser.write([ord('p')])
        time.sleep(0.100)
        in_waiting = self.ser.in_waiting
        if in_waiting > 0:
            print(self.ser.read(in_waiting).decode())
    def autoset_sensitivity(self):
        time.sleep(0.100)
        self.ser.flush()
        self.ser.write([ord('p')])
        time.sleep(0.100)
        in_waiting = self.ser.in_waiting
        recv = self.ser.read(in_waiting)
        data = recv[0:len(recv)-2].decode().split(",")
        if len(data) == 6:
            for i in range(6):
                if not float(data[i]) == 0:
                    self.sensitivity[i] = 1/float(data[i])
                else:
                    self.sensitivity[i] = 0
            return self.sensitivity
        else:
            print("Sensitivity read error.")
            return [1]*6
        print(float(data[0]))
    def read_temperature(self):
        time.sleep(0.100)
        self.ser.flush()
        self.ser.write([ord('T')])
        time.sleep(0.100)
        in_waiting = self.ser.in_waiting
        if in_waiting > 0:
            recv = self.ser.read(in_waiting)
            data = struct.unpack('=4s2B', recv)
            return float(int(data[0].decode(),16))/16.0
        else:
            return None

    def read_once(self):
        data = self.read_once_as_digit()
        if not data is None:
            return self.bytesToDouble(data)
        else:
            return None
    def read_once_as_digit(self):
        self.ser.write([ord('R')])
        time.sleep(0.020)
        in_waiting = self.ser.in_waiting
        if in_waiting == 27:
            recv = self.ser.read(in_waiting)
            data = struct.unpack('=B4s4s4s4s4s4s2B', recv)[1:7]
            return data
        else:
            print('No available data.')
            return None

    def start_continuous_read(self):
        self.ser.flush()
        self.ser.write([ord('S')])
        while self.ser.in_waiting < 27*2:
            time.sleep(1e-3)
        self.is_started = 1
        self.force = self.read_continuous()
    def stop_continuous_read(self):
        self.ser.write([ord('E')])
        time.sleep(0.020)
        self.ser.flush()
        self.is_started = 0
    def read_continuous(self):
        if not self.read_continuous_as_digit() is None:            
            return self.force
        else:
            return None
    def read_continuous_as_digit(self):
        # 13	0D	CR
        # 10	0A	LF
        if self.is_started:
            in_waiting = self.ser.in_waiting
            if in_waiting >= 27*2:
                recv = self.ser.read(in_waiting)
                if 0x0A in recv:
                    ii = recv.rfind(0x0A)
                    recv = recv[ii-27+1:ii+1]
                    if recv[25] == 0x0D:
                        data = struct.unpack('=B4s4s4s4s4s4s2B', recv)[1:7]
                        self.digit = data
                        self.force = self.bytesToDouble(data)
                return self.digit
            else:
                return self.digit
        else:
            print('Data send is NOT started.')
            return None
    def bytesToDouble(self, argBytes6):
        zeroOutput = [0x2000, 0x2000, 0x2000, 0x2000, 0x2000, 0x2000]
        retInt6 = [int(argBytes6[0].decode(),16), int(argBytes6[1].decode(),16), int(argBytes6[2].decode(),16),
                   int(argBytes6[3].decode(),16), int(argBytes6[4].decode(),16), int(argBytes6[5].decode(),16) ]
        retDouble6 = [ float(retInt6[0]-zeroOutput[0])*self.sensitivity[0],
                       float(retInt6[1]-zeroOutput[1])*self.sensitivity[1],
                       float(retInt6[2]-zeroOutput[2])*self.sensitivity[2],
                       float(retInt6[3]-zeroOutput[3])*self.sensitivity[3],
                       float(retInt6[4]-zeroOutput[4])*self.sensitivity[4],
                       float(retInt6[5]-zeroOutput[5])*self.sensitivity[5] ]
        return retDouble6

    @classmethod
    def open_ports_by_serial_number(cls, serial_number):
        ports = serial.tools.list_ports.comports()
        for port in ports:
            if port.serial_number == serial_number:
                return cls(port.device)
    @staticmethod
    def show_list_ports():
        ports = serial.tools.list_ports.comports()
        for port in ports:
            if port.vid is None:
                port.serial_number = "None"
                port.vid = 0
                port.pid = 0
            print('Name:%s, Serial Number:%s, VID:PID:%04X:%04X, Manufacturer:%s'%(
                port.device,
                port.serial_number,
                port.vid,
                port.pid,
                port.manufacturer) )
    #         print("-----------")
    #         print(port.device)
    #         print(port.name)
    #         print(port.description)
    #         print(port.hwid)
    #         print(port.vid)
    #         print(port.pid)
    #         print(port.serial_number)
    #         print(port.location)
    #         print(port.manufacturer)
    #         print(port.product)
    #         print(port.interface)
if __name__ == '__main__':

    DynPick.show_list_ports()
    dpick = DynPick.open_ports_by_serial_number("AU05U761A")
    # dpick = DynPick('/dev/tty.usbserial-AU02EQ8G')    # for Unix os
    # dpick = DynPick('COM4') # for win

    dpick.show_firmware_version()
    # dpick.show_sensitivity()
    print(dpick.sensitivity)
    print(str(dpick.read_temperature())+'(deg C)')

    data = dpick.read_once()
    print(data)
    print("[N], [Nm]")

    dpick.start_continuous_read()
    data = dpick.read_continuous()
    print(data)

