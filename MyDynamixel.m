classdef MyDynamixel < handle
    %MYDYNAMIXEL Summary of this class goes here
    %   Detailed explanation goes here
    properties(Hidden, Access = private)
        mode = 'JOINT'
    end
    properties
        portNum;
        baudNum;
        libName = 'dynamixel'
        Devices = struct('id',[],'offset',0,'x',0,'xMin',0,'xMax',deg2rad(360),'name','motor1','index',1,'status','active','speed',10,...
            'maxSpeed',114);
        Instruction;
        numDevices = 0;
        
    end
    methods
        function MD = MyDynamixel(port,baud)
            if (nargin == 2)
            MD.portNum = port;
            MD.baudNum = baud;
            res = calllib(MD.libName, 'dxl_initialize',MD.portNum, MD.baudNum);
            if res == 0
                fprintf('Cannot init dynamixel \n');
            end
            else
                fprintf('Serial port does not configure \n')
            end
            MD.Instruction.PING = hex2dec('01');
            MD.Instruction.READ_DATA = hex2dec('02');
            MD.Instruction.WRITE_DATA = hex2dec('03');
            MD.Instruction.REG_WRITE = hex2dec('04');
            MD.Instruction.ACTION = hex2dec('05');
            MD.Instruction.RESET = hex2dec('06');
            MD.Instruction.SYNC_WRITE = hex2dec('83');
            loadlibrary('dynamixel', 'dynamixel.h')        
        end
        function Exit(MD)
            calllib('dynamixel','dxl_terminate');
            unloadlibrary(MD.libName);            
        end
        function init(MD,port,baud)       
            if (nargin ==3)
                MD.portNum = port;
                MD.baudNum = baud;
                res = calllib(MD.libName, 'dxl_initialize',MD.portNum, MD.baudNum);
                if res == 0
                    fprintf('Cannot init dynamixel \n');
                end
                else
                    res = calllib(MD.libName, 'dxl_initialize',MD.portNum, MD.baudNum);
                    if res == 0
                        fprintf('Cannot init dynamixel \n');
                    end
            end
        end
        function viewSupportFcn(MD)
           libfunctions(MD.libName);
        end
        function addDevice(MD,id)
            MD.numDevices = MD.numDevices + 1;
            MD.Devices(MD.numDevices).id = id;
            MD.Devices(MD.numDevices).status = 'active';
            MD.Devices(MD.numDevices).index = MD.numDevices;
            if id == 4
                MD.Devices(MD.numDevices).offset = 180;
                MD.Devices(MD.numDevices).xMin = 0;
                MD.Devices(MD.numDevices).xMax = 360;
            elseif id == 1
                MD.Devices(MD.numDevices).offset = 0;
                MD.Devices(MD.numDevices).xMin = 0;
                MD.Devices(MD.numDevices).xMax = 300;
            else
                MD.Devices(MD.numDevices).offset = 150;
                MD.Devices(MD.numDevices).xMin = 0;
                MD.Devices(MD.numDevices).xMax = 300;
            end
            
            MD.Devices(MD.numDevices).x = 0;
            MD.Devices(MD.numDevices).name = 'noname';
            MD.Devices(MD.numDevices).speed = 5;
            MD.Devices(MD.numDevices).maxSpeed = 114;
        end
        function removeDevice(MD,id)
            for i = 1: MD.numDevices
                if (id == MD.Devices(i).id)
                    MD.Devices(i).status = 'inactive';
                end
            end
            
        end        
        function writeAngle(MD,varargin)
            n = length(varargin);
            i = 1;
            if (n >=3)
                while(i < n)
                    prop = varargin{i};
                    val = varargin{i+1};
                    switch prop
                        case 'id'
                            for j = 1: length(MD.Devices)
                                if MD.Devices(j).id == val
                                    ind = j;
                                end
                            end
                        case 'index'
                            ind = val;
                        case 'deg'
                            val = val + MD.Devices(ind).offset;                                                                                                             
                            if val < MD.Devices(ind).xMin
                                val = MD.Devices(ind).xMin;
                            end
                            if val > MD.Devices(ind).xMax
                                val = MD.Devices(ind).xMax;
                            end
                            MD.Devices(ind).x = val;        
                            dat = uint16(val*1023/300);
                        case 'rad'
                            val = rad2deg(val)+ MD.Devices(ind).offset;
                            if val < MD.Devices(ind).xMin
                                val = MD.Devices(ind).xMin;
                            end
                            if val > MD.Devices(ind).xMax
                                val = MD.Devices(ind).xMax;
                            end
                            MD.Devices(ind).x = val;
                            %prepare real data for dynamixel
                            dat = uint16(val*1023/300);
                    end                      
                    i = i+2;
                end
                calllib('dynamixel','dxl_write_word',MD.Devices(ind).id,ControlTable.GoalPos_L,dat); 
            end
        end
        
        function writeAngle360(MD,varargin)
            n = length(varargin);
            i = 1;
            if (n >=3)
                while(i < n)
                    prop = varargin{i};
                    val = varargin{i+1};
                    switch prop
                        case 'id'
                            for j = 1: length(MD.Devices)
                                if MD.Devices(j).id == val
                                    ind = j;
                                end
                            end
                        case 'index'
                            ind = val;
                        case 'deg'
                            val = val + MD.Devices(ind).offset;                                                                                                             
                            if val < MD.Devices(ind).xMin
                                val = MD.Devices(ind).xMin;
                            end
                            if val > MD.Devices(ind).xMax
                                val = MD.Devices(ind).xMax;
                            end
                            MD.Devices(ind).x = val;        
                            dat = uint16(val*4095/360);
                        case 'rad'
                            val = rad2deg(val)+ MD.Devices(ind).offset;
                            if val < MD.Devices(ind).xMin
                                val = MD.Devices(ind).xMin;
                            end
                            if val > MD.Devices(ind).xMax
                                val = MD.Devices(ind).xMax;
                            end
                            MD.Devices(ind).x = val;
                            %prepare real data for dynamixel
                            dat = uint16(val*4095/360);
                    end                      
                    i = i+2;
                end
                calllib('dynamixel','dxl_write_word',MD.Devices(ind).id,ControlTable.GoalPos_L,dat); 
            end
        end
        
        function writeSpeed(MD,id, speed)
            if (speed > 1023) 
                speed = 1023;
            end
            if (speed < -1023) 
                speed = -1023; 
            end
            if (speed >=0)
                calllib('dynamixel','dxl_write_word',id,ControlTable.MovingSpeed_L,speed);
            else
                speed = abs(speed) + 1025;
                calllib('dynamixel','dxl_write_word',id,ControlTable.MovingSpeed_L,speed);
            end
        end
        
        function setSpeed(MD,varargin)
            n = length(varargin);
            i = 1;
            if (n >=3)
                while(i < n)
                    prop = varargin{i};
                    val = varargin{i+1};
                    switch prop
                        case 'id'
                            for j = 1: length(MD.Devices)
                                if MD.Devices(j).id == val
                                    ind = j;
                                end
                            end
                        case 'index'
                            ind = val;
                        case 'RPM'                                                                                                             
                            if val < 1
                                val = 1;
                            end
                            if val > MD.Devices(ind).maxSpeed
                                val = MD.Devices(ind).maxSpeed;
                            end
                            MD.Devices(ind).speed = val;                
                            dat = uint16(val*1023/114);
                        case 'maxSpeed'
                            MD.Devices(ind).speed = 114;
                            dat = 1023;
                        case 'maxSpeedNoControl'
                            MD.Devices(ind).speed = 0;
                            dat = 0;
                    end                      
                    i = i+2;
                end
                calllib('dynamixel','dxl_write_word',MD.Devices(ind).id,ControlTable.MovingSpeed_L,dat); 
            end
        end
        function ledOn(MD)
            calllib(MD.libName,'dxl_write_byte',2,ControlTable.LED,1);    
        end
        function ledOff(MD)
            calllib(MD.libName,'dxl_write_byte',2,ControlTable.LED,0);
        end
        function setMode(MD,id,mode)
            switch mode
                case 'WHEEL'
                    calllib(MD.libName,'dxl_write_word',id,ControlTable.CWAngleLimit_L,0);
                    calllib(MD.libName,'dxl_write_word',id,ControlTable.CCWAngleLimit_L,0);
                case 'JOINT'
                    if id == 4
                        calllib(MD.libName,'dxl_write_word',id,ControlTable.CCWAngleLimit_L,4095);
                    else
                        calllib(MD.libName,'dxl_write_word',id,ControlTable.CCWAngleLimit_L,1023);
                    end
            end
        end
    end
    
end

