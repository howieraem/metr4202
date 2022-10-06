function [theta1, theta2] = InverseKinematics2rArm(px, py, l1, l2) 
%Returns the inverse kinematics, the two joint angles, given
% the position px and py and arm lengths l1 and l2 for a 2d planar
% 2r arm.

py = py + 155;

theta2 = acos((px^2 + py^2 - l1^2 - l2^2)/(2*l1*l2));
ctheta1  = (px*(l1+l2*cos(theta2)) + py*l2*sin(theta2))/(l1^2 + l2^2 + 2*l1*l2*cos(theta2));
stheta1 = (py*(l1+l2*cos(theta2)) - px*l2*sin(theta2))/(l1^2 + l2^2 + 2*l1*l2*cos(theta2));
theta1 = atan2(stheta1, ctheta1);