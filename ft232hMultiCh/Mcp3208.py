#!/usr/bin/env python
# -*- coding: utf-8 -*-

from MPSSEMultiCh import MPSSEMultiCh
import time

from ctypes import *

class Mcp3208:
    ver = '22.8.3'
    def __init__(self, mpsse):
        self.spi = mpsse
    def analogReadAsDigit(self, devCh, cs, adCh):
        adCh =  adCh & 0b111
        ret = self.spi.spiReadWrite(devCh, cs, [0b00000110 | (adCh >> 2), 0x00 | ((adCh & 0b011) << 6)])
        ret[0] = 0x0F & ret[0]
        return (ret[0] << 8) | ret[1]
    def analogReadAsFloat(self, devCh, cs, adCh):
        return float(self.analogReadAsDigit(devCh, cs, adCh))/4095
    def analogReadAsDigitAtOnce(self, devCh, cs, adChs):
        return [ self.analogReadAsDigit(devCh, cs, adCh) for adCh in adChs ]
    def analogReadAsFloatAtOnce(self, devCh, cs, adChs):
        return [ float(self.analogReadAsDigit(devCh, cs, adCh))/4095 for adCh in adChs ]

def testMcp3208():
    mpsse = MPSSEMultiCh('./libMPSSE.dll')
    mpsse.showDevices()
    devCh = mpsse.openChannel(0, 2e6) # max 2MHz
    cs = 0
    mcp23S08 = Mcp3208( mpsse )
    
    # 8 ch, 12 bit
    print(mcp23S08.analogReadAsDigit(devCh, cs, 0))
    print(mcp23S08.analogReadAsDigitAtOnce(devCh, cs, [0, 1, 2]))
    print(mcp23S08.analogReadAsFloat(devCh, cs, 0))
    print(mcp23S08.analogReadAsFloatAtOnce(devCh, cs, [0, 1, 2]))

    mpsse.closeChannel(devCh)

def testDirectRead():
    mpsse = MPSSEMultiCh('./libMPSSE.dll')
    mpsse.showDevices()
    devCh = mpsse.openChannel(0, 1e5)
    mpsse.closeChannel(devCh)

if __name__ == '__main__':
    testMcp3208()
    # testDirectRead()

