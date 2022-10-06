function [theta1_f, theta2_f, angOut] = simulate_2rArm(j, ang1, ang2, px1, py1, px2, py2, l1, l2)
%simulate the movement of the 2r planar arm from point (px1, py1) to point
%(px2, py2) or alternatively set j to be 'a' and then the initial angle
%will be used to derive the initial positon of the end effector. l1 and l2
%are the lengths of each arm segment. Angles are given in degrees.


%Set Work space
axis([-350 350 -200 350]);

%Perform inverse kinematics to find the final and initial joint angles
if j == 'a'
    theta1_init = deg2rad(ang1);
    theta2_init = deg2rad(ang2);   
else
    [theta1_init, theta2_init] = InverseKinematics2rArm(px1, py1, l1, l2); 
end
 

[theta1, theta2] = InverseKinematics2rArm(px2, py2, l1, l2); 
theta1_f = rad2deg(theta1);
theta2_f = rad2deg(theta2);

%Vector for storing 200 spaced joint angles between initial and final
%positions
theta1_speed = linspace(theta1_init, theta1, 200);
theta2_speed = linspace(theta2_init, theta2, 200);

angOut(:,1) = linspace(rad2deg(theta1_init), theta1_f, 2);
angOut(:,2) = linspace(rad2deg(theta2_init), theta2_f, 2);


count = 1;
final_pointsX = zeros(200);
final_pointsY = zeros(200);

while count <= 200
    %Compute the forward Kinematics
    [midpointX, midpointY, finalX, finalY] = FKinematics2rArm(theta1_speed(count), theta2_speed(count), l1, l2);
    
    %Add end point to array for plotting trajectory.
    final_pointsX(count) = finalX;
    final_pointsY(count) = finalY;
    
%     hold off;
%     plot([0 midpointX], [0 midpointY], 'g');
%     hold on;
%     plot([midpointX finalX], [midpointY, finalY], 'g'); 
    count = count + 1;
end

%Plot the end point positions
plot(final_pointsX, final_pointsY, '.');  
hold on;
%plot the Workspace boundary
plot([-300 300], [0 0], 'k');
plot([300 300], [0 300], 'k');
plot([-300 300], [300 300], 'k');
plot([-300 -300], [0 300], 'k');

axis([-350 350 -200 350]);

%Compute the forward kinematics for initial position
[midpointX, midpointY, finalX, finalY] = FKinematics2rArm(theta1_init, theta2_init, l1, l2);

plot([0 midpointX], [-50 midpointY], 'r');
hold on;
plot([midpointX finalX], [midpointY, finalY], 'r'); 

%Compute the forward kinematics for final position
[midpointX, midpointY, finalX, finalY] = FKinematics2rArm(theta1, theta2, l1, l2);
plot([0 midpointX], [-50 midpointY], 'g');
plot([midpointX finalX], [midpointY, finalY], 'g');

title('2r Manipulator Simulation');
axis([-350 350 -200 350]);

