function [midX, midY, x, y] = FKinematics2rArm(theta1, theta2, l1, l2)
% Compute the forward kinematics for a 2r manipulator given the joint 
% angles and lengths

midX = l1 * cos(theta1);
midY = l1 * sin(theta1) - 155;
x = midX + l2 * cos(theta2 + theta1);
y = midY + l2 * sin(theta2 + theta1);


end

