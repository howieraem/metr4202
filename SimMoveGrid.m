function [out] = SimMoveGrid(valid_moves, startX, startY, endX, endY, m , dx , dy)
%SIMMOVEGRID Summary of this function goes here
%   Detailed explanation goes here
%grid is 20x10
% m = 1, the initial coord is just grid coordinate,
% m - 0, initial coord is real world coord
% dx & dy are offsets for path point coordinates
%Find length of grid space commands
Ptr = size(valid_moves,1);
out = [];
index = 1;

% Add extra 5 considering the end effector will be lowered down
dx = dx + 5;
dy = dy + 5;
%Calculate first points in world coordinates - transform from gird
% coordinates

if m == 1 
    px_init1 = 300 - (valid_moves(Ptr, 2) - 0.5) * 30;
    py_init1 = (valid_moves(Ptr, 1) - 0.5) * 30;
    length1 = 285;
    length2 = 300;      %Account for extra lenght when the arm is raised (start Path)
else
    px_init1 = startX;
    py_init1 = startY;
    length1 = 285;
    length2 = 305;
    % Increase or reduce the offset based on arm lengths & tunning
    dx = dx - 20;
    dy = dy - 2;
end

if Ptr > 2 
    px_init2 = 300 - (valid_moves((Ptr - 1), 2) - 0.5) * 30;
    py_init2 = (valid_moves((Ptr - 1), 1) - 0.5) * 30;
    %Simulate first joint movement 
    [theta1, theta2, angOut] = simulate_2rArm('p', 0, 0, px_init1, py_init1, px_init2, py_init2, length1, length2);

    out = angOut;
    index = index + 1;

    if Ptr > 3
        for i = (Ptr - 2):-1:2
            px = 300 - (valid_moves(i, 2) - 0.5) * 30 + dx;
            py = (valid_moves(i, 1) - 0.5) * 30 + dy;
            hold on;
            [theta1_n, theta2_n, angOut] = simulate_2rArm('a', theta1, theta2,0, 0,px,py, length1, length2);
            theta1 = theta1_n;
            theta2 = theta2_n;
        %     out(index, 1) = round(theta1);
        %     out(index, 2) = round(theta2);
            out = [out; angOut];
            index = index + 1;
        end
    end

    [theta1_n, theta2_n, angOut] = simulate_2rArm('a', theta1, theta2,0, 0,endX,endY, 285, 305);

else 

    
    [theta1, theta2, angOut] = simulate_2rArm('p', 0, 0, px_init1, py_init1, endX, endY, 285, 305);

end

out = [out; angOut];
camroll(180);
  
end

