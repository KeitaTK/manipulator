#!/usr/bin/env python
# -*- coding: utf-8 -*-

from dynamixel_sdk import *                    # Uses Dynamixel SDK library
import time

class Dynamixel:
    ver = '20.12.24'
    # Control table address
    # Addr, Size, Name, RW, Default, Range, Unit
    # 8	1	Baud Rate	RW	1	0 ~ 7	-
    # 9	1	Return Delay Time	RW	250	0 ~ 254	2 [μsec]
    ADDR_RETURN_DELAY_TIME  = 9
    # 10	1	Drive Mode	RW	0	0 ~ 5	-
    ADDR_DRIVE_MODE = 10
    #     1: Reverse mode
    # 11	1	Operating Mode	RW	3	0 ~ 16	-
    ADDR_OPERATING_MODE     = 11
    #     0: Current Control Mode
    #     1: Velocity Control Mode
    #     3: Position Control Mode
    #     16: PWM Control Mode (Voltage Control Mode)
    # 36	2	PWM Limit	RW	885	0 ~ 885	0.113 [%]
    # 38	2	Current Limit	RW	1,193	0 ~ 1,193	2.69 [mA]
    # 44	4	Velocity Limit	RW	200	0 ~ 1,023	0.229 [rev/min]
    # 48	4	Max Position Limit	RW	4,095	0 ~ 4,095	1 [pulse]
    # 52	4	Min Position Limit	RW	0	0 ~ 4,095	1 [pulse]
    # 64	1	Torque Enable	RW	0	0 ~ 1	-
    ADDR_TORQUE_ENABLE      = 64
    # 65	1	LED	RW	0	0 ~ 1	-
    ADDR_LED = 65
    # 68	1	Status Return Level	RW	2	0 ~ 2	-
    #     0: PING Instruction
    #     1: PING Instruction, READ Instruction
    #     2: All Instructions	
    ADDR_STATUS_RETURN_LEVEL = 68
    # 100	2	Goal PWM	RW	-	-PWM Limit(36) ~ PWM Limit(36)	-
    # 102	2	Goal Current	RW	-	-Current Limit(38) ~ Current Limit(38)	2.69 [mA]
    ADDR_GOAL_CURRENT       = 102
    # 104	4	Goal Velocity	RW	-	-Velocity Limit(44) ~ Velocity Limit(44)	0.229 [rev/min]
    # 116	4	Goal Position	RW	-	Min Position Limit(52) ~ Max Position Limit(48)	1 [pulse]
    ADDR_GOAL_POSITION      = 116
    # 124	2	Present PWM	R	-	-	-
    # 126	2	Present Current	R	-	-	2.69 [mA]
    ADDR_PRESENT_CURRENT = 126
    # 128	4	Present Velocity	R	-	-	0.229 [rev/min]
    ADDR_PRESENT_VELOCITY = 128
    # 132	4	Present Position	R	-	-	1 [pulse]
    ADDR_PRESENT_POSITION   = 132

    # Protocol version
    PROTOCOL_VERSION            = 2.0               # See which protocol version is used in the Dynamixel
    # COMM_SUCCESS                = 0;            % Communication Success result value
    # COMM_TX_FAIL                = -1001;        % Communication Tx Failed

    def __init__(self, device_name, baud=57600):
        self.DEVICENAME = device_name
        self.BAUDRATE = baud
        # Initialize PortHandler instance
        # Set the port path
        # Get methods and members of PortHandlerLinux or PortHandlerWindows
        self.portHandler = PortHandler(self.DEVICENAME)

        # Initialize PacketHandler instance
        # Set the protocol version
        # Get methods and members of Protocol1PacketHandler or Protocol2PacketHandler
        self.packetHandler = PacketHandler(Dynamixel.PROTOCOL_VERSION)

        # Open port
        if not self.portHandler.openPort():
            print("Failed to open the port")
            self.portHandler.closePort()
            quit()

        # Set port baudrate
        if  not self.portHandler.setBaudRate(self.BAUDRATE):
            print("Failed to change the baudrate")
            self.portHandler.closePort()
            quit()
        # print(len(self.DXL_IDs))

        self.groupSyncWriteGoalPosition = GroupSyncWrite(self.portHandler, self.packetHandler, Dynamixel.ADDR_GOAL_POSITION, 4)
        self.groupSyncWriteGoalCurrent = GroupSyncWrite(self.portHandler, self.packetHandler, Dynamixel.ADDR_GOAL_CURRENT, 2)
        self.groupSyncReadPresentVelocity = GroupSyncRead(self.portHandler, self.packetHandler, Dynamixel.ADDR_PRESENT_VELOCITY, 4)
        self.groupSyncReadPresentPosition = GroupSyncRead(self.portHandler, self.packetHandler, Dynamixel.ADDR_PRESENT_POSITION, 4)
        self.groupSyncReadPresentCurrent = GroupSyncRead(self.portHandler, self.packetHandler, Dynamixel.ADDR_PRESENT_CURRENT, 2)
        
    def __del__(self):
        # Close port
        self.portHandler.closePort()

    def readReturnDelayTime(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        for DXL_ID in DXL_IDs:
            data[DXL_IDs.index(DXL_ID)], dxl_comm_result, dxl_error = self.packetHandler.read1ByteTxRx(self.portHandler, DXL_ID, Dynamixel.ADDR_RETURN_DELAY_TIME)
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
            elif dxl_error != 0:
                print("%s" % self.packetHandler.getRxPacketError(dxl_error))
        return data
    def writeReturnDelayTime(self, DXL_IDs, data):
        for DXL_ID in DXL_IDs:
            dxl_comm_result = self.packetHandler.write1ByteTxOnly(self.portHandler, DXL_ID, Dynamixel.ADDR_RETURN_DELAY_TIME, int(data[DXL_IDs.index(DXL_ID)]))
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def readDriveMode(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        for DXL_ID in DXL_IDs:
            data[DXL_IDs.index(DXL_ID)], dxl_comm_result, dxl_error = self.packetHandler.read1ByteTxRx(self.portHandler, DXL_ID, Dynamixel.ADDR_DRIVE_MODE)
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
            elif dxl_error != 0:
                print("%s" % self.packetHandler.getRxPacketError(dxl_error))
        return data
    def writeDriveMode(self, DXL_IDs, data):
        for DXL_ID in DXL_IDs:
            dxl_comm_result = self.packetHandler.write1ByteTxOnly(self.portHandler, DXL_ID, Dynamixel.ADDR_DRIVE_MODE, int(data[DXL_IDs.index(DXL_ID)]))
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def readOperatingMode(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        for DXL_ID in DXL_IDs:
            data[DXL_IDs.index(DXL_ID)], dxl_comm_result, dxl_error = self.packetHandler.read1ByteTxRx(self.portHandler, DXL_ID, Dynamixel.ADDR_OPERATING_MODE)
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
            elif dxl_error != 0:
                print("%s" % self.packetHandler.getRxPacketError(dxl_error))
        return data
    def writeOperatingMode(self, DXL_IDs, data):
        for DXL_ID in DXL_IDs:
            dxl_comm_result = self.packetHandler.write1ByteTxOnly(self.portHandler, DXL_ID, Dynamixel.ADDR_OPERATING_MODE, int(data[DXL_IDs.index(DXL_ID)]))
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def readTorqueEnable(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        for DXL_ID in DXL_IDs:
            data[DXL_IDs.index(DXL_ID)], dxl_comm_result, dxl_error = self.packetHandler.read1ByteTxRx(self.portHandler, DXL_ID, Dynamixel.ADDR_TORQUE_ENABLE)
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
            elif dxl_error != 0:
                print("%s" % self.packetHandler.getRxPacketError(dxl_error))
        return data
    def writeTorqueEnable(self, DXL_IDs, data):
        for DXL_ID in DXL_IDs:
            dxl_comm_result = self.packetHandler.write1ByteTxOnly(self.portHandler, DXL_ID, Dynamixel.ADDR_TORQUE_ENABLE, int(data[DXL_IDs.index(DXL_ID)]))
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def readLED(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        for DXL_ID in DXL_IDs:
            data[DXL_IDs.index(DXL_ID)], dxl_comm_result, dxl_error = self.packetHandler.read1ByteTxRx(self.portHandler, DXL_ID, Dynamixel.ADDR_LED)
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
            elif dxl_error != 0:
                print("%s" % self.packetHandler.getRxPacketError(dxl_error))
        return data
    def writeLED(self, DXL_IDs, data):
        for DXL_ID in DXL_IDs:
            dxl_comm_result = self.packetHandler.write1ByteTxOnly(self.portHandler, DXL_ID, Dynamixel.ADDR_LED, int(data[DXL_IDs.index(DXL_ID)]))
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def readStatusReturnLevel(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        for DXL_ID in DXL_IDs:
            data[DXL_IDs.index(DXL_ID)], dxl_comm_result, dxl_error = self.packetHandler.read1ByteTxRx(self.portHandler, DXL_ID, Dynamixel.ADDR_STATUS_RETURN_LEVEL)
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
            elif dxl_error != 0:
                print("%s" % self.packetHandler.getRxPacketError(dxl_error))
        return data
    def writeStatusReturnLevel(self, DXL_IDs, data):
        for DXL_ID in DXL_IDs:
            dxl_comm_result = self.packetHandler.write1ByteTxOnly(self.portHandler, DXL_ID, Dynamixel.ADDR_STATUS_RETURN_LEVEL, int(data[DXL_IDs.index(DXL_ID)]))
            if dxl_comm_result != COMM_SUCCESS:
                print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def writeGoalCurrent(self, DXL_IDs, data):
        # Clear syncwrite parameter storage
        self.groupSyncWriteGoalCurrent.clearParam()
        # Add Dynamixel goal current to the Syncwrite parameter storage
        for DXL_ID in DXL_IDs:
            iData = int(data[DXL_IDs.index(DXL_ID)])
            param = [ iData&0xFF, (iData>>8)&0xFF ]
            dxl_addparam_result = self.groupSyncWriteGoalCurrent.addParam(DXL_ID, param)
            if dxl_addparam_result != True:
                print("[ID:%03d] groupSyncWrite addparam failed" % DXL_ID)
                # quit()
        # Syncwrite goal current
        dxl_comm_result = self.groupSyncWriteGoalCurrent.txPacket()
        if dxl_comm_result != COMM_SUCCESS:
            print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def writeGoalPosition(self, DXL_IDs, data):
        # Clear syncwrite parameter storage
        self.groupSyncWriteGoalPosition.clearParam()
        # Add Dynamixel goal position to the Syncwrite parameter storage
        for DXL_ID in DXL_IDs:
            iData = int(data[DXL_IDs.index(DXL_ID)])
            param_goal_position = [ iData&0xFF, (iData>>8)&0xFF, (iData>>16)&0xFF, (iData>>24)&0xFF ]
            dxl_addparam_result = self.groupSyncWriteGoalPosition.addParam(DXL_ID, param_goal_position)
            if dxl_addparam_result != True:
                print("[ID:%03d] groupSyncWrite addparam failed" % DXL_ID)
                # quit()
        # Syncwrite goal position
        dxl_comm_result = self.groupSyncWriteGoalPosition.txPacket()
        if dxl_comm_result != COMM_SUCCESS:
            print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
    def readPresentVelocity(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        # Clear syncread parameter storage
        self.groupSyncReadPresentVelocity.clearParam()
        # Add parameter storage for Dynamixel data value
        for DXL_ID in DXL_IDs:
            dxl_addparam_result = self.groupSyncReadPresentVelocity.addParam(DXL_ID)
            if dxl_addparam_result != True:
                print("[ID:%03d] groupSyncRead addparam failed" % DXL_ID)
        # Syncread data
        dxl_comm_result = self.groupSyncReadPresentVelocity.txRxPacket()
        if dxl_comm_result != COMM_SUCCESS:
            print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
        for DXL_ID in DXL_IDs:
            # Check if groupsyncread data of Dynamixel is available
            dxl_getdata_result = self.groupSyncReadPresentVelocity.isAvailable(DXL_ID, Dynamixel.ADDR_PRESENT_VELOCITY, 4)
            if dxl_getdata_result != True:
                print("[ID:%03d] groupSyncRead getdata failed" % DXL_ID)
            # Get Dynamixel value
            data[DXL_IDs.index(DXL_ID)] = self.groupSyncReadPresentVelocity.getData(DXL_ID, Dynamixel.ADDR_PRESENT_VELOCITY, 4)
            # unsigned integer to signed integer conversion for 4 Bytes
            data[DXL_IDs.index(DXL_ID)]=float(data[DXL_IDs.index(DXL_ID)]+(data[DXL_IDs.index(DXL_ID)]>>31)*(1-0xFFFFFFFF))
        return data
    def readPresentPosition(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        # Clear syncread parameter storage
        self.groupSyncReadPresentPosition.clearParam()
        # Add parameter storage for Dynamixel present position value
        for DXL_ID in DXL_IDs:
            dxl_addparam_result = self.groupSyncReadPresentPosition.addParam(DXL_ID)
            if dxl_addparam_result != True:
                print("[ID:%03d] groupSyncRead addparam failed" % DXL_ID)
        # Syncread present position
        dxl_comm_result = self.groupSyncReadPresentPosition.txRxPacket()
        if dxl_comm_result != COMM_SUCCESS:
            print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
        for DXL_ID in DXL_IDs:
            # Check if groupsyncread data of Dynamixel#1 is available
            dxl_getdata_result = self.groupSyncReadPresentPosition.isAvailable(DXL_ID, Dynamixel.ADDR_PRESENT_POSITION, 4)
            if dxl_getdata_result != True:
                print("[ID:%03d] groupSyncRead getdata failed" % DXL_ID)
            # Get Dynamixel#1 present position value
            data[DXL_IDs.index(DXL_ID)] = self.groupSyncReadPresentPosition.getData(DXL_ID, Dynamixel.ADDR_PRESENT_POSITION, 4)
            # unsigned integer to signed integer conversion for 4 Bytes
            data[DXL_IDs.index(DXL_ID)]=float(data[DXL_IDs.index(DXL_ID)]+(data[DXL_IDs.index(DXL_ID)]>>31)*(1-0xFFFFFFFF))
        return data
    def readPresentCurrent(self, DXL_IDs):
        data = [0]*len(DXL_IDs)
        # Clear syncread parameter storage
        self.groupSyncReadPresentCurrent.clearParam()
        # Add parameter storage for Dynamixel present Current value
        for DXL_ID in DXL_IDs:
            dxl_addparam_result = self.groupSyncReadPresentCurrent.addParam(DXL_ID)
            if dxl_addparam_result != True:
                print("[ID:%03d] groupSyncRead addparam failed" % DXL_ID)
        # Syncread present Current
        dxl_comm_result = self.groupSyncReadPresentCurrent.txRxPacket()
        if dxl_comm_result != COMM_SUCCESS:
            print("%s" % self.packetHandler.getTxRxResult(dxl_comm_result))
        for DXL_ID in DXL_IDs:
            # Check if groupsyncread data of Dynamixel#1 is available
            dxl_getdata_result = self.groupSyncReadPresentCurrent.isAvailable(DXL_ID, Dynamixel.ADDR_PRESENT_CURRENT, 2)
            if dxl_getdata_result != True:
                print("[ID:%03d] groupSyncRead getdata failed" % DXL_ID)
            # Get Dynamixel#1 present Current value
            data[DXL_IDs.index(DXL_ID)] = self.groupSyncReadPresentCurrent.getData(DXL_ID, Dynamixel.ADDR_PRESENT_CURRENT, 2)
            # unsigned integer to signed integer conversion for 4 Bytes
            # data[DXL_IDs.index(DXL_ID)]=float(data[DXL_IDs.index(DXL_ID)]+(data[DXL_IDs.index(DXL_ID)]>>15)*(1-0xFFFF))
            if data[DXL_IDs.index(DXL_ID)] >= 0x8000:
                data[DXL_IDs.index(DXL_ID)] -= 0xFFFF
        return data


if __name__ == '__main__':
    DXL_IDs                      = [17, 14, 11, 8, 5, 2]
    BAUDRATE                    = 1e6             # Dynamixel default baudrate : 57600
    # Check which port is being used on your controller
    DEVICENAME                  = 'COM4' # for Win
    # DEVICENAME                  = '/dev/tty.usbserial-A906DIB5' # for macOS
    dyn = Dynamixel(DEVICENAME, BAUDRATE)

    # dyn.writeTorqueEnable(DXL_IDs, [0, 0])
    # dyn.writeOperatingMode(DXL_IDs, [0, 0])
    # dyn.writeOperatingMode(DXL_IDs, [3, 3])
    # dyn.writeTorqueEnable(DXL_IDs, [1, 1, 1])

    pos = dyn.readPresentPosition(DXL_IDs)
    print(pos)
    current = dyn.readPresentCurrent(DXL_IDs)
    print(current)
    current = dyn.readPresentCurrent(DXL_IDs)
    print(current)
    current = dyn.readPresentCurrent(DXL_IDs)
    print(current)
    # pos = dyn.readPresentVelocity(DXL_IDs)
    # print(pos)
    # dyn.writeGoalPosition(DXL_IDs, [0,0])
    # time.sleep(0.1)
    # pos = dyn.readPresentVelocity(DXL_IDs)
    # print(pos)
    # time.sleep(0.5)
    # start = time.time()
    # pos = dyn.readPresentPosition(DXL_IDs)
    # elapsed_time = time.time() - start
    # print("%.2f, %.2f[deg], dt=%.2f[msec]" % (pos[0]*0.088, pos[1]*0.088, elapsed_time*1000))


    # start = time.time()
    # dyn.writeGoalCurrent(DXL_IDs, [-500,-500])
    # elapsed_time = time.time() - start
    # print ("elapsed_time:{0}".format(elapsed_time*1000) + "[msec]")
    # time.sleep(0.5)
    # dyn.writeGoalCurrent(DXL_IDs, [0,0])
    # dyn.writeTorqueEnable(DXL_IDs, [0, 0])

    # start = time.time()
    # dyn.writeGoalPosition(DXL_IDs, [1048,2048,2048])
    # elapsed_time = time.time() - start
    # print ("elapsed_time:{0}".format(elapsed_time*1000) + "[msec]")
    # time.sleep(0.5)
    # dyn.writeGoalPosition(DXL_IDs, [2048,2048,2048])
    # time.sleep(0.5)

    # dyn.writeLED(DXL_IDs, [0, 0])
    # dyn.writeReturnDelayTime(DXL_IDs, [2, 2])
    # data = dyn.readReturnDelayTime(DXL_IDs)
    # print(data)

    # dyn.writeTorqueEnable(DXL_IDs, [0, 0, 0])

