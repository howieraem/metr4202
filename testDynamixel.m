%% Initialise
% ID 1 to 3 for AX-12A, and ID 4 for MX-12W (from the RoboPlus Dynamixel Wizard)
% predefined for individual motor debugging
motor1ID = 1;
motor2ID = 2;
motor3ID = 3;
motor4ID = 4;

o = setupMotors(3); % Input COM number

%% Main function / Debugging Section

%angles = load("angles.mat");
tic;
initSpeed = 7;
gain = 20;
actuate(o,angles,initSpeed,gain, angle4Diff);
%currentAngles = readAngles(o)
duration = toc
o.Exit();
clear o;

%% Motor Functions
function actuate(o,angles,initSpeed, speedGain, angle4Diff)
dt = 100;   % in milliseconds
% Speed in RPM above 10 is not recommended considering rig structure.
% 1 RPM = 6 degrees per second = 0.006 degrees per millisecond
for ind = 1:4
    o.setSpeed('id',o.Devices(ind).id,'RPM',initSpeed);
end
o.writeAngle('id',o.Devices(3).id,'deg',-60);

% Implement every angle in the path joint space
angle1 = -angles(1,1)+240;  % Angle conversion due to motor 1 mounting
o.writeAngle('id',o.Devices(1).id,'deg',angle1);
o.writeAngle('id',o.Devices(2).id,'deg',angles(1,2));
currentAngles = readAngles(o);
while abs(currentAngles(1,1) - angles(1,1))>0.5 && abs(currentAngles(1,2) - (angles(1,2)))>0.5
    milliPause(500);
	currentAngles = readAngles(o)
%     if abs(currentAngles(1,1) - angles(1,1))<=1 && abs(currentAngles(1,2) - (angles(1,2)))<=1
%         
%         break;
%     end
end
%o.writeAngle('id',o.Devices(3).id,'deg',-80);
milliPause(1500);

for stepInd=2:size(angles,1)
    %tic;
    angle1 = -angles(stepInd,1) + 240;  % Angle conversion due to motor 1 mounting
    currentAngles = readAngles(o);
    o.writeAngle('id',o.Devices(1).id,'deg',angle1);
    o.writeAngle('id',o.Devices(2).id,'deg',angles(stepInd,2));
    speedGain1 = abs(angles(stepInd,1)-angles(stepInd-1,1))/dt*speedGain;
    speedGain2 = abs(angles(stepInd,2)-angles(stepInd-1,2))/dt*speedGain;
    while abs(currentAngles(1,1) - angles(stepInd,1))>1 && abs(currentAngles(1,2) - angles(stepInd,2))>1
        speed1 = speedGain1*abs(currentAngles(1,1)...
            -angles(stepInd,1));
        speed2 = speedGain2*abs(currentAngles(1,2)...
            -angles(stepInd,2));
        if speed1 > 5
            speed1 = 5;
        end
        if speed2 > 5
            speed2 = 5;
        end
        o.setSpeed('id',o.Devices(1).id,'RPM',speed1);
        o.setSpeed('id',o.Devices(2).id,'RPM',speed2);
        currentAngles = readAngles(o)
    end
    %milliPause(toc/1000);
end
%o.setSpeed('id',o.Devices(3).id,'RPM',3);
%o.setSpeed('id',o.Devices(4).id,'RPM',3);
o.writeAngle360('id',o.Devices(4).id,'deg',currentAngles(1,4)-angle4Diff);
end

function resetArms(o)
% The zero degree position for AX-12A's is set to the centre
for ind = 2:3
    o.writeAngle('id',o.Devices(ind).id,'deg',0);
end
o.writeAngle('id',o.Devices(1).id,'deg',240);
o.writeAngle360('id',o.Devices(4).id,'deg',0);
end

%{
function currentAngles = readAngles(o)
currentAngles = cell(1,4);
for i = 1:4
    posnValue=calllib('dynamixel','dxl_read_word',o.Devices(i).id,ControlTable.PresentPos_L);
    if i == 1
        currentAngles(1,i) = num2cell(240-(posnValue/1023*300));
    elseif i == 2 || i == 3
        currentAngles(1,i) = num2cell(posnValue/1023*300-150);
    else
        currentAngles(1,i) = num2cell(posnValue/4095*360-150);
    end
end
currentAngles = cell2mat(currentAngles);
end
%}