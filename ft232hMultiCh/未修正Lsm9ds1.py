#!/usr/bin/env python
# -*- coding: utf-8 -*-

from MPSSE import MPSSE

import numpy as np
import math

import threading
import time


class ImuThreading(threading.Thread):
    def __init__(self, lsm9ds1):
        threading.Thread.__init__(self)
        self.gain = 5

        self.sensor = lsm9ds1
        self.kill_flag = False

        self.Acc, self.Gyr = self.sensor.readAccGyr()
        self.Mag = self.sensor.readMag()
        self.Euler = np.array(self.getStaticEuler(self.Acc, self.Gyr))
        self.dt = 0

    # def __del__(self):
    def run(self):
        self.Acc, self.Gyr = self.sensor.readAccGyr()
        self.Euler = np.array(self.getStaticEuler(self.Acc, self.Gyr))
        self.dt = 0
        while not(self.kill_flag):
            # print('hoge')
            # startTime = time.time()
            startTime = time.perf_counter()
            self.Acc, self.Gyr = self.sensor.readAccGyr()
            # AccNp = np.array(self.Acc)
            GyrNp = np.array(self.Gyr)
            EulerAcc = np.array(self.getStaticEuler(self.Acc, self.Gyr))
            dEuler = np.dot(ImuThreading.matrixP(self.Euler) , GyrNp)
            self.Euler = self.Euler + dEuler*self.dt + (EulerAcc - self.Euler)*self.gain*self.dt
            # time.sleep(.001)
            # self.dt = time.time() - startTime
            self.dt = time.perf_counter() - startTime

    # 
    # test  *****
    # 
    # import numpy as np
    # a = np.matrix([[1,0,1],[0,1,0],[0,0,1]])
    # b = np.matrix([1, 2, 3])
    # print(a*b)
    def getStaticEuler (self, Acc, Gyr):
        # Acc, Gyr = self.sensor.readAccGyr()
        # Mag = np.array(self.readMag())
        Acc = np.array(Acc)
        eulerAcc = [0,0,0]
        # eulerAcc[0] = math.atan2(Acc[2], Acc[1])
        # eulerAcc[1] = math.asin(Acc[0]/np.linalg.norm(Acc, ord=2))
        normalAcc = Acc/np.linalg.norm(Acc, ord=2)
        eulerAcc[0] = math.atan(normalAcc[1]/normalAcc[2])
        eulerAcc[1] = math.asin(normalAcc[0])

        # Mag = np.matrix(Mag - self.centerMag).T
        # Mag = self.matrixR(eulerAcc)*Mag
        # print(Mag)
        # eulerAcc[2] = math.atan2(Mag[1], Mag[0])-self.magZeroDirection
        return eulerAcc

    @staticmethod
    def matrixP(Theta):
        # print('---')
        # print(Theta)
        # print(type(Theta))
        return np.array([
            [1, math.sin(Theta[0])*math.tan(Theta[1]), math.cos(Theta[0])*math.tan(Theta[1])],
            [0, math.cos(Theta[0]), math.sin(Theta[0])],
            [0, math.sin(Theta[0])/math.cos(Theta[1]), math.cos(Theta[0])/math.cos(Theta[1])]
        ])
    @staticmethod
    def matrixR(Theta):
        return np.array([
            [math.cos(Theta[1])*math.cos(Theta[2]), math.cos(Theta[2])*math.sin(Theta[0])*math.sin(Theta[1]) - math.cos(Theta[0])*math.sin(Theta[2]), math.sin(Theta[0])*math.sin(Theta[2]) + math.cos(Theta[0])*math.cos(Theta[2])*math.sin(Theta[1])],
            [math.cos(Theta[1])*math.sin(Theta[2]), math.cos(Theta[0])*math.cos(Theta[2]) + math.sin(Theta[0])*math.sin(Theta[1])*math.sin(Theta[2]), math.cos(Theta[0])*math.sin(Theta[1])*math.sin(Theta[2]) - math.cos(Theta[2])*math.sin(Theta[0])],
            [-math.sin(Theta[1]), math.cos(Theta[1])*math.sin(Theta[0]), math.cos(Theta[0])*math.cos(Theta[1])]
        ])

class Lsm9ds1:
    ver = '20.11.26'
    def __init__(self, argSpi, argCs=[0,1]):
        self.spi = argSpi
        self.cs = argCs

        self.GRAV = 9.81
        self.centerMag = np.array([0,0,0])
        self.magZeroDirection = 0
        # self.gyroOffset = np.array([0,0,0])
        self.gyroOffset = np.array([-0.02998, 0.01148, 0.01294])

        self.initAccGyr()
        self.initMag()

    def initAccGyr (self):
        value = self.spi.spiReadWrite(self.cs[0], [0x80|0x0F]) # Read AccGry/Mag Whoami
        if value[0]!=0b01101000: # '0110 1000'
            print('Acc/Gry Error.')
            self.spi.close()
            quit()
            return -1
        else:
            # print('Acc/Gry Ready.')
            # value = self.spi.spiReadWrite(self.cs[0], [0x80|0x13])
            # print(value)
            self.spi.spiWrite(self.cs[0], [0x13, 0b00010000]) # Y axis: negative '00 010 000' ORIENT_CFG_G(13h), 00 SignX_G Y_G Z_G 000
            self.spi.spiWrite(self.cs[0], [0x10, 0b11000000]) # Output data rate ODR=110, 952Hz (Gyro) '110 00000'
            self.spi.spiWrite(self.cs[0], [0x20, 0b11000000]) # Output data rate ODR=110, 952Hz (Accel) '110 00000'
            return 0

    def initMag (self):
        value = self.spi.spiReadWrite(self.cs[1], [0x80|0x0F]) # Read AccGry/Mag Whoami
        if value[0]!=0b00111101: # '0011 1101'
            print('Mag Error.')
            quit()
            return -1
        else:
            # print('Mag Ready.')
            self.spi.spiWrite(self.cs[1], [0x20, 0b01111100]) # '0 11 111 00' X and Y axes operative mode OM ODR=11, Ultra-high performance mode, Output data rate ODR=111, 80Hz
            self.spi.spiWrite(self.cs[1], [0x22, 0b10000000]) # '1 0 0 00 0 00' Operating mode selection MD: 00, Continuous-conversion mode
            return 0
       
    def readAccGyr (self): # Read Acc/Gry Data
        uint8Gyr = self.spi.spiReadWrite(self.cs[0], [152, 0,0,0,0,0]) # [bitor(hex2dec('80'),hex2dec('18')); 0;0;0;0;0]
        Gyr = np.array(Lsm9ds1.uint8toDouble(uint8Gyr))*4.27605667 - self.gyroOffset # rad/s # *245/180*math.pi
        Gyr = Gyr.tolist()
        uint8Acc = self.spi.spiReadWrite(self.cs[0], [168, 0,0,0,0,0]) # [bitor(hex2dec('80'),hex2dec('28')); 0;0;0;0;0]
        Acc = np.array(Lsm9ds1.uint8toDouble(uint8Acc))*2*self.GRAV # % m/^2
        Acc = Acc.tolist()

        # Modify Directions
        tmp = Acc[0]
        Acc[0] = Acc[1]
        Acc[1] = tmp
        Acc[2] = -Acc[2]
        tmp = Gyr[0]
        Gyr[0] = Gyr[1]
        Gyr[1] = -tmp
        return Acc, Gyr

    def readMag (self): # Read Mag Data
        uint8Mag = self.spi.spiReadWrite(self.cs[1], [168, 0,0,0,0,0,0]) # [bitor(hex2dec('80'),hex2dec('28')); 0;0;0;0;0]
        Mag = Lsm9ds1.uint8toDouble(uint8Mag)
        Mag[0] = Mag[0] *4.0 # gauss
        Mag[1] = -Mag[1] *4.0 # gauss
        Mag[2] = Mag[2] *4.0 # gauss
        return Mag

    # def diffPitchForComplementaryFilter (self, pitch, gain):
    #     Acc, Gyr = self.readAccGyr()
    #     # Mag = np.array(self.readMag())
    #     staticPitch = math.asin(Acc[0]/np.linalg.norm(Acc, ord=2))
    #     diffPitch = Gyr[1]- gain*(pitch-staticPitch)
    #     return diffPitch

    def getStaticEuler (self):
        Acc, Gyr = self.readAccGyr()
        # Mag = np.array(self.readMag())
        Acc = np.array(Acc)
        eulerAcc = [0,0,0]
        # eulerAcc[0] = math.atan2(Acc[2], Acc[1])
        # eulerAcc[1] = math.asin(Acc[0]/np.linalg.norm(Acc, ord=2))
        normalAcc = Acc/np.linalg.norm(Acc, ord=2)
        eulerAcc[0] = math.atan(normalAcc[1]/normalAcc[2])
        eulerAcc[1] = math.asin(normalAcc[0])

        # Mag = np.matrix(Mag - self.centerMag).T
        # Mag = self.matrixR(eulerAcc)*Mag
        # print(Mag)
        # eulerAcc[2] = math.atan2(Mag[1], Mag[0])-self.magZeroDirection
        return eulerAcc

    @staticmethod
    def uint8toDouble ( arg1 ):
        ret1 = [0,0,0]
        ret1[0] = (arg1[1]<<8)+arg1[0]
        ret1[0] = ret1[0] + (ret1[0]>>15)*(1-0xFFFF)
        ret1[0] = ret1[0]/32767.0
        ret1[1] = (arg1[3]<<8)+arg1[2]
        ret1[1] = ret1[1] + (ret1[1]>>15)*(1-0xFFFF)
        ret1[1] = ret1[1]/32767.0
        ret1[2] = (arg1[5]<<8)+arg1[4]
        ret1[2] = ret1[2] + (ret1[2]>>15)*(1-0xFFFF)
        ret1[2] = ret1[2]/32767.0
        return ret1


def testLSM9DS1_whoami():
    mpsse = MPSSE('./libMPSSE.dll')
    mpsse.showDevices()
    mpsse.openChannel(0)
    data = mpsse.spiReadWrite(0, [0x80|0x0F])
    print(0b01101000)
    print(data)
    data = mpsse.spiReadWrite(1, [0x80|0x0F])
    print(0b00111101)
    print(data)

def testLSM9DS1():
    mpsse = MPSSE('./libMPSSE.dll')
    mpsse.showDevices()
    mpsse.openChannel(0)
    lsm9ds1 = Lsm9ds1( mpsse )
    Acc, Gyr = lsm9ds1.readAccGyr()
    start = time.time()
    sumGyr = np.array([0,0,0])
    num = 100.0
    for i in range(int(num)):
        Acc, Gyr = lsm9ds1.readAccGyr()
        sumGyr = sumGyr + Gyr
    elapsed_time = (time.time() - start)*1000
    print('%.2f [msec], 100 r/w'% elapsed_time )
    print(sumGyr/100*180/math.pi)  # deg/s
    print('[%.5f, %.5f, %.5f]'%(sumGyr[0]/num, sumGyr[1]/num, sumGyr[2]/num))  # deg/s
    # Mag = lsm9ds1.readMag()
    # print(np.array(Gyr)*180/math.pi)  # deg/s
    # print(Gyr)  # rad/s
    # print(Acc)  # m^s
    # print(Mag)  # gauss
    # print(np.array(lsm9ds1.getStaticEuler())*180.0/math.pi)   # roll, pitch, yaw. Currently, yaw is incorrect.

    mpsse.closeChannel()

def testIMU():
    mpsse = MPSSE('./libMPSSE.dll')
    mpsse.showDevices()
    mpsse.openChannel(0)
    lsm9ds1 = Lsm9ds1( mpsse )
    t = ImuThreading(lsm9ds1)

    # a = np.array([1, 2, 3])
    # b = ImuThreading.matrixP([0,0,0])
    # print(b*a.T)
    # print(np.dot(b, a.T))
    # print(b*a)
    # print(np.dot(b, a))

    # スレッドを実行
    t.start()
    startTime = time.time()

    while time.time()-startTime < 10:
        # print(np.array(t.Gyr)*180/math.pi)
        # print(np.array(t.Acc))
        print(t.dt*1000)
        print(t.Euler*180/math.pi)
        time.sleep(0.5)

    # # 実行中のスレッドに対して `line` を上書き
    # time.sleep(1)
    # print(t.Acc)

    # # 実行中のスレッドに対して `line` を上書き
    # time.sleep(1)
    # print(t.Acc)

    # 実行中のスレッドを終了する
    t.kill_flag = True

if __name__ == '__main__':
    # print('hoge')
    # testLSM9DS1()
    testIMU()


