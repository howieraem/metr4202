function actuate(o, m, angles, initSpeed, speedGain, angle4Diff)
dt = 120;   % in milliseconds
% Speed in RPM above 10 is not recommended considering rig structure.
% 1 RPM = 6 degrees per second = 0.006 degrees per millisecond
% m = mode, m = 1 is start path mode, m= 0 is coin move mode
for ind = 1:3
    o.setSpeed('id',o.Devices(ind).id,'RPM',initSpeed);
end
o.setSpeed('id',o.Devices(4).id,'RPM',10);

if m == 1 
    o.writeAngle('id',o.Devices(3).id,'deg',-30);
    pause(2);
else 
    o.writeAngle('id',o.Devices(3).id,'deg',-89);
end 
% Implement every angle in the path joint space
angle1 = -angles(1,1)+240;  % Angle conversion due to motor 1 mounting
o.writeAngle('id',o.Devices(1).id,'deg',angle1);
o.writeAngle('id',o.Devices(2).id,'deg',angles(1,2));
currentAngles = readAngles(o);
while abs(currentAngles(1,1) - angles(1,1))>0.5 && abs(currentAngles(1,2) - (angles(1,2)))>0.5
    pause(.5);
	currentAngles = readAngles(o)
end
pause(1);
o.writeAngle360('id',o.Devices(4).id,'deg',0);
if m == 0
    o.writeAngle('id',o.Devices(3).id,'deg',-89);
else
    o.writeAngle('id',o.Devices(3).id,'deg',-75);
end
compensateAngle4 = (angles(1,1)-angles(size(angles,1),1))+(angles(1,2)-angles(size(angles,1),2));
angle4Diff = angle4Diff - compensateAngle4;
if angle4Diff > 180
    angle4Diff = angle4Diff - 360;
elseif angle4Diff < -180
    angle4Diff = angle4Diff + 360;
end
pause(1);

for stepInd=2:size(angles,1)
    %tic;
    angle1 = -angles(stepInd,1) + 240;  % Angle conversion due to motor 1 mounting
    currentAngles = readAngles(o);
    o.writeAngle('id',o.Devices(1).id,'deg',angle1);
    o.writeAngle('id',o.Devices(2).id,'deg',angles(stepInd,2));
    speedGain1 = abs(angles(stepInd,1)-angles(stepInd-1,1))/dt*speedGain;
    speedGain2 = abs(angles(stepInd,2)-angles(stepInd-1,2))/dt*speedGain;
    while abs(currentAngles(1,1) - angles(stepInd,1))>0.9 && abs(currentAngles(1,2) - angles(stepInd,2))>0.9
        speed1 = speedGain1*abs(currentAngles(1,1)...
            -angles(stepInd,1));
        speed2 = speedGain2*abs(currentAngles(1,2)...
            -angles(stepInd,2));
        if speed1 > 5
            speed1 = 5;
        end
        if speed2 > 4
            speed2 = 4;
        end
        o.setSpeed('id',o.Devices(1).id,'RPM',speed1);
        o.setSpeed('id',o.Devices(2).id,'RPM',speed2);
        currentAngles = readAngles(o)
    end
    %milliPause(toc/1000);
end
%o.setSpeed('id',o.Devices(3).id,'RPM',3);
%o.setSpeed('id',o.Devices(4).id,'RPM',3);
pause(1);
if m == 0
    o.setSpeed('id',o.Devices(4).id,'RPM',5);
    o.writeAngle360('id',o.Devices(4).id,'deg',angle4Diff);
end
end