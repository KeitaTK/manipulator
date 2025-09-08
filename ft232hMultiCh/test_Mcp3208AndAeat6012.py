#!/usr/bin/env python
# -*- coding: utf-8 -*-

from MPSSEMultiCh import MPSSEMultiCh
from Mcp3208 import Mcp3208
from Aeat6012 import Aeat6012
import time

from ctypes import *

if __name__ == '__main__':
    mpsse = MPSSEMultiCh('./libMPSSE.dll')
    mpsse.showDevices()
    devForADC = mpsse.openChannelFromSerial('FTNPK1U0', 2e6) # max 2MHz
    devForAEAT = mpsse.openChannelFromSerial('FTL35PIN', 1e6)
    aeat = Aeat6012(mpsse)
    mcp23S08 = Mcp3208( mpsse )
    
    # 8 ch, 12 bit
    csForADC = 0
    print(mcp23S08.analogReadAsDigit(devForADC, csForADC, 0))
    print(mcp23S08.analogReadAsDigitAtOnce(devForADC, csForADC, [0, 1, 2]))
    print(mcp23S08.analogReadAsFloat(devForADC, csForADC, 0))
    print(mcp23S08.analogReadAsFloatAtOnce(devForADC, csForADC, [0, 1, 2]))

    csForAEAT = 1
    CSsForAEAT = [0, 1]
    print(aeat.readAsDigit(devForAEAT, csForAEAT))
    print(aeat.readAsFloat(devForAEAT, csForAEAT))
    print(aeat.readAsDigitAtOnce(devForAEAT, CSsForAEAT))
    print(aeat.readAsFloatAtOnce(devForAEAT, CSsForAEAT))

    mpsse.closeChannel(devForAEAT)
    mpsse.closeChannel(devForADC)
