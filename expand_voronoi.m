function exp_varray = expand_voronoi(node_x,node_y,hn,xTarget,yTarget,CLOSED,vx, vy)
    %Function to return expanded array to be used in Astar.
    %This function takes a node and returns the expanded list
    %of successors,with the calculated fn values.
    %The criteria being none of the successors are on the CLOSED list.
    % Note this code uses the voronoi vertexes 
    %   Copyright 2009-2010 The MathWorks, Inc.
    
    
    connected = []; % connected nodes
    con_count = 1;
    for i = 1:size(vx,2)
        if(node_x == vx(1,i) && node_y == vy(1,i))
            connected(1, con_count) = vx(2,i);
            connected(2, con_count) = vy(2,i);
            con_count = con_count + 1;
        elseif (node_x == vx(2,i) && node_y == vy(2,i))
            connected(1, con_count) = vx(1,i);
            connected(2, con_count) = vy(1,i);
            con_count = con_count + 1;
        end 
    end
    exp_varray=[];
    exp_count=1;
    % what are the connected nodes?
    c2=size(CLOSED,1);%Number of elements in CLOSED including the zeros
    for k = 1:con_count - 1
        k
        s_x = connected(1,k);
        s_y = connected(2,k);
        flag=1;                    
        for c1=1:c2
            if(s_x == CLOSED(c1,1) && s_y == CLOSED(c1,2))
                flag=0;
            end;
        end;%End of for loop to check if a successor is on closed list.
        if (flag == 1)
            exp_varray(exp_count,1) = s_x;
            exp_varray(exp_count,2) = s_y;
            exp_varray(exp_count,3) = hn+distance(node_x,node_y,s_x,s_y);%cost of travelling to node
            exp_varray(exp_count,4) = distance(xTarget,yTarget,s_x,s_y);%distance between node and goal
            exp_varray(exp_count,5) = exp_varray(exp_count,3)+exp_varray(exp_count,4);%fn
            exp_count=exp_count+1;
        end%Populate the exp_array list!!!
    end





end