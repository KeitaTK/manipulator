#!/usr/bin/env python
# -*- coding: utf-8 -*-

from MPSSE import MPSSE
import time

from ctypes import *

class Mcp23S08:
    ver = '21.9.27'
    def __init__(self, argSpi, argCs=2):
        self.spi = argSpi
        self.cs = argCs
    def initAsGPIORead(self):
        self.spi.spiWrite(self.cs, [0b01000000, 0x05, 0b00100000]) # IOCON setting, SEQOP=1, addres pointer is not inclemented.
        time.sleep(0.05)
        self.spi.spiWrite(self.cs, [0b01000000, 0x00, 0xFF]) # Set IODIR, I/O direction as input.
        time.sleep(0.05)
        self.spi.spiWrite(self.cs, [0b01000000, 0x06, 0xFF]) # Pullup
        # self.spi.spiWrite(self.cs, [0b01000000, 0x06, 0x00]) # Pullup off
        time.sleep(0.05)
        self.spi.spiWrite(self.cs, [0b01000001, 0x09, 0]) # Below, we can only read addr 0x06.
        time.sleep(0.05)
    def gpioRead(self):
        ret = self.spi.spiReadWrite(self.cs, [0b01000001, 0x09])
        return ret[1]
    def initAsGPIOWrite(self):
        # This is not tested.
        self.spi.spiWrite(self.cs, [0b01000000, 0x05, 0b00100000]) # IOCON setting
        time.sleep(0.05)
        self.spi.spiWrite(self.cs, [0b01000000, 0x00, 0x00]) # Set IODIR, I/O direction as input.
        time.sleep(0.05)

def testMcp23S08():
    print('hoge')
    mpsse = MPSSE('./libMPSSE.dll')
    mpsse.showDevices()
    mpsse.openChannel(0, 1e7) # max 10MHz
    mcp23S08 = Mcp23S08( mpsse, 2 )
    mcp23S08.initAsGPIORead()
    print(mcp23S08.gpioRead())
    print(mcp23S08.gpioRead())
    print(mcp23S08.gpioRead())

    mpsse.closeChannel()

def testDirectRead():
    mpsse = MPSSE('./libMPSSE.dll')
    mpsse.showDevices()
    mpsse.openChannel(0, 1e5)
    # print(mpsse.gpioRead())

    mcp23S08 = Mcp23S08( mpsse )
    cs = 2
    # mpsse.dll.FT_WriteGPIO(mpsse.pChannelHandle, c_uint8(255), c_uint8(255))    # C0 to C7-High
    # time.sleep(5.0)
    # mpsse.dll.FT_WriteGPIO(mpsse.pChannelHandle, c_uint8(255), c_uint8(0))    # C0 to C7-High
    # time.sleep(5.0)

    # print(mpsse.spiReadWrite(cs, [0b01000000, 0x09, 0xFF]))

    # mpsse.spiWrite(cs, [0b01000000, 0x05, 0b00100000]) # IOCON setting, SEQOP=1, addres pointer is not inclemented.
    # time.sleep(0.05)
    # mpsse.spiWrite(cs, [0b01000000, 0x00, 0xFF]) # Set IODIR, I/O direction as input.
    # time.sleep(0.05)
    # mpsse.spiWrite(cs, [0b01000000, 0x06, 0xFF]) # Pullup
    # time.sleep(0.05)
    # mpsse.spiWrite(cs, [0b01000001, 0x09, 0]) # Below, we can only read addr 0x06.
    # time.sleep(0.05)
    # print(mpsse.spiRead(cs, 1))
    # print(mpsse.spiRead(cs, 1))

    # GPIO Write
    # print(mpsse.spiReadWrite(cs, [0b01000000, 0x00, 0x00]))
    # print(mpsse.spiReadWrite(cs, [0b01000000, 0x09, 0xFF]))
    print(mpsse.spiReadWrite(cs, [0b01000001, 0x09]))
    # print(mpsse.spiReadWrite(cs, [0b01000000, 0x0A, 0xFF]))
    # time.sleep(0.5)

    mpsse.closeChannel()

if __name__ == '__main__':
    # print('hoge')
    testMcp23S08()
    # testDirectRead()

