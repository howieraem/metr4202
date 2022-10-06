function o = setupMotors(portNum)
% Check the COM port number from device manager
baudRate = 1; % 1000000 bps
o = MyDynamixel();
o.portNum = portNum; 
o.baudNum = baudRate; 
o.init();

% Motor setup
for motorID = 1:3
	o.addDevice(motorID);
	o.setMode(motorID,'JOINT');
end
o.addDevice(4);
o.setSpeed('id',4,'RPM',5);   % Speed above 10 is not recommended
o.setMode(4,'JOINT');
end