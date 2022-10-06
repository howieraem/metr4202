o  = MyDynamixel();
o.portNum = 9; % COM9
o.baudNum = 1; % baud = 1000000 bps
o.init()
o.addDevice(16); % ID = 16
%% Set Speed
o.setSpeed('id',16,'RPM',0); % set speed 0 rpm
%% Set Wheel Mode
o.setMode(16,'WHEEL');

%% Write Command
o.writeSpeed(16,100); %id 16, CCW
o.writeSpeed(16,-100); %id 16, CW
