#!/usr/bin/env python
# -*- coding: utf-8 -*-

from MPSSEMultiCh import MPSSEMultiCh
import time

class Aeat6012:
    ver = '23.8.2'
    def __init__(self, argSpi):
        self.spi = argSpi
        self.coef = 360/(2**12-1)
    def readAsDigit(self, ch, cs):
        return self.bytesToInt(self.spi.spiRead(ch, cs, 2))
    def readAsDigitAtOnce(self, ch, CSs):
        Values = []
        for cs in CSs:
            Values.append(self.bytesToInt(self.spi.spiRead(ch, cs, 2)))
        return Values
    def readAsFloat(self, ch, cs):
        return self.readAsDigit(ch, cs)*self.coef
    def readAsFloatAtOnce(self, ch, CSs):
        Values = []
        for cs in CSs:
            Values.append( self.bytesToInt(self.spi.spiRead(ch, cs, 2))*self.coef )
        return Values
    
    def resetSpiCh(self, argSpi):
        self.spi = argSpi
    
    @staticmethod
    def bytesToInt(data):
        # return (data[0] << 4)+(data[1] >> 4)
        return ((data[0]&0b01111111) << 5)+(data[1] >> 3)

def testAeat6012():
    mpsse = MPSSEMultiCh('./libMPSSE.dll')
    mpsse.showDevices()
    ch = mpsse.openChannel(0, 1e6, 2, 2) # Max 1MHz
    aeat = Aeat6012(mpsse)
    # cs = 0
    # print(aeat.readAsDigit(ch, cs))
    # print(aeat.readAsFloat(ch, cs))
    CSs = [0, 1]
    print(aeat.readAsDigitAtOnce(ch, CSs))
    print(aeat.readAsFloatAtOnce(ch, CSs))

    mpsse.closeChannel(ch)

def testDirectRead():
    mpsse = MPSSEMultiCh('./libMPSSE.dll')
    mpsse.showDevices()
    ch = mpsse.openChannel(1, 1e6, 2, 2) # Max 1MHz
    cs = 1
    start = time.perf_counter() # Since Python ver.3.8, otherwise use time.time()
    data = mpsse.spiRead(ch, cs, 2)
    value = (data[0] << 4)+(data[1] >> 4)
    elapsed_time = (time.perf_counter() - start)*1e3
    print('%.2f [msec]'% elapsed_time )
    print(value)
    print(value/(2**(12-1))*360)
 
    mpsse.closeChannel(ch)

if __name__ == '__main__':
    testAeat6012()
    # testDirectRead()

