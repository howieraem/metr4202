function [x, y] = voronoi_pathfind(grid, sx, sy, tx, ty)
% Path finding using voronoi diagram
% cx, cy = coordinates of centre of joined bounding boxes (with dilution) on grid. 
% sx, sy = start position
% tx, ty = target position
% finds path with clearence
% returned [x,y] as coordinates in tge grid
% grid = grid of thei thing

% get the corners of shapes of the grid

corners = []; % corners on the grid to use for voronoi
corner_count = 1;
max_x = size(grid,1);
max_y = size(grid,2);
%newgrid = imrotate(grid, -90);
figure(3), imshow(grid)
%truesize(gcf, [300,600])
hold on

for i = 1:max_x
    for j = 1:max_y
        count = 0;
        if(grid(i,j) == 1)
            if(i ~= 1)
                if(grid(i-1, j) == 0)
                    count = count + 1;
                end
            end
            if(j ~= 1)
                if(grid(i,j-1) == 0)
                    count = count + 1;
                end
            end
            if(i ~= max_x)
                if(grid(i+1, j) == 0)
                    count = count + 1;
                end
            end
            if(j ~= max_y)
                if(grid(i, j+1) == 0)
                    count = count + 1;
                end
            end
        else
            if(i == 1 || j == 1 || j == max_y || i == max_x)
                count = 2; % too much computation?
            end
            
        end
        if(count > 1)
            corners(corner_count, 2) = i;
            corners(corner_count, 1) = j;
            corner_count = corner_count + 1;
        end
    end
end
corners = transpose(corners);
%figure(3), voronoi(corners(1,:),corners(2,:)) % corners working
%axis([0 max_x 0 max_y]);
figure(3), hold on
% if coordinate issue, probably this
[vx, vy] = voronoi(corners(1,:), corners(2,:)); % gets voronoi nodes. 
%scatter(vx(1,:), vy(1,:))
vxn = []; % points after removal
vyn = [];
new_count = 1;
%size(corners, 1)
mindist = 100;
mingoaldist= 100;

figure(3), hold on
for i = 1:size(vx, 2)
    
    x1 = round(vx(1,i));
    x2 = round(vx(2,i));
    y1 = round(vy(1,i));
    y2 = round(vy(2,i));
    % if within the grid bound and empty
    if((x1 > 0 && x1 <= max_y)...
            && (x2 > 0 && x2 <= max_y) && (y1 > 0 && y1 <= max_x) && ...
            (y2 > 0 && y2 <= max_x)&& grid(y1,x1) ~= 1 && grid(y2, x2) ~= 1)
        vxn(:,new_count) = vx(:,i);%[x1;x2];
        vyn(:,new_count) = vy(:,i);%[y1;y2]; % Get the edges not intersecting the grid
        new_count = new_count + 1;
        
        x1 = vx(1,i);
        x2 = vx(2,i);
        y1 = vy(1,i);
        y2 = vy(2,i);
        short = min(distance(sx,sy,x1,y1), distance(sx,sy,x2,y2));
        if(mindist > min(mindist, short))
            mindist = short;
            if(distance(sx,sy,x1,y1)> distance(sx,sy,x2,y2))
                sxc = x2;
                syc = y2;
            else
                sxc = x1;
                syc = y1;
            end
        end
        shortgoal = min(distance(tx,ty,x1,y1), distance(tx,ty,x2,y2));
        if(mingoaldist > min(mingoaldist, shortgoal))
            mingoaldist = shortgoal;
            if(distance(tx,ty,x1,y1)> distance(tx,ty,x2,y2))
                txc = x2;
                tyc = y2;
            else
                txc = x1;
                tyc = y1;
            end
        end
    end
end
figure(3), hold on
for i = 1:size(vxn,2)
    plot([vxn(1,i),vxn(2,i)], [vyn(1,i), vyn(2,i)])
end
%figure(3), plot(vxn(1,:),vyn(1,:),vxn(2,:),vyn(2,:))


CLOSED=[];

CLOSED_COUNT=1;
%set the starting node as the first node
xTarget = txc;
yTarget = tyc;
xNode=sxc;
yNode=syc;
OPEN_COUNT=1;
path_cost=0;
goal_distance=2*distance(xNode,yNode,xTarget,yTarget);
OPEN(OPEN_COUNT,:)=insert_open(xNode,yNode,xNode,yNode,path_cost,goal_distance,goal_distance);
OPEN(OPEN_COUNT,1)=0;
OPEN_COUNT = OPEN_COUNT + 1;
path_cost = distance(sx,sy,sxc,syc);
gn = goal_distance - path_cost;
OPEN(OPEN_COUNT,:)=insert_open(sxc,syc,xNode,yNode,path_cost,gn,goal_distance);
OPEN(OPEN_COUNT,1)=1;

CLOSED_COUNT=CLOSED_COUNT+1;
CLOSED(CLOSED_COUNT,1)=xNode;
CLOSED(CLOSED_COUNT,2)=yNode;
NoPath=1;
while((xNode ~= xTarget || yNode ~= yTarget) && NoPath == 1)
%  plot(xNode+.5,yNode+.5,'go');
 exp_array=expand_voronoi(xNode,yNode,path_cost,xTarget,yTarget,CLOSED,vxn, vyn);
 exp_count=size(exp_array,1);
 %UPDATE LIST OPEN WITH THE SUCCESSOR NODES
 %OPEN LIST FORMAT
 %--------------------------------------------------------------------------
 %IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
 %--------------------------------------------------------------------------
 %EXPANDED ARRAY FORMAT
 %--------------------------------
 %|X val |Y val ||h(n) |g(n)|f(n)|
 %--------------------------------
 for i=1:exp_count
    flag=0;
    for j=1:OPEN_COUNT
        if(exp_array(i,1) == OPEN(j,2) && exp_array(i,2) == OPEN(j,3) )
            OPEN(j,8)=min(OPEN(j,8),exp_array(i,5)); %#ok<*SAGROW>
            if OPEN(j,8)== exp_array(i,5)
                %UPDATE PARENTS,gn,hn
                OPEN(j,4)=xNode;
                OPEN(j,5)=yNode;
                OPEN(j,6)=exp_array(i,3);
                OPEN(j,7)=exp_array(i,4);
            end;%End of minimum fn check
            flag=1;
        end;%End of node check
%         if flag == 1
%             break;
    end;%End of j for
    if flag == 0
        OPEN_COUNT = OPEN_COUNT+1;
        OPEN(OPEN_COUNT,:)=insert_open(exp_array(i,1),exp_array(i,2),xNode,yNode,exp_array(i,3),exp_array(i,4),exp_array(i,5));
     end;%End of insert new element into the OPEN list
 end;%End of i for
 
 
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %END OF WHILE LOOP
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %Find out the node with the smallest fn 
  index_min_node = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget);
  if (index_min_node ~= -1)    
   %Set xNode and yNode to the node with minimum fn
   xNode=OPEN(index_min_node,2);
   yNode=OPEN(index_min_node,3);
   path_cost=OPEN(index_min_node,6);%Update the cost of reaching the parent node
  %Move the Node to list CLOSED
  CLOSED_COUNT=CLOSED_COUNT+1;
  CLOSED(CLOSED_COUNT,1)=xNode;
  CLOSED(CLOSED_COUNT,2)=yNode;
  OPEN(index_min_node,1)=0;
  else
      %No path exists to the Target!!
      NoPath=0;%Exits the loop!
  end;%End of index_min_node check
end;%End of While Loop
%Once algorithm has run The optimal path is generated by starting of at the
%last node(if it is the target node) and then identifying its parent node
%until it reaches the start node.This is the optimal path

i=size(CLOSED,1);
Optimal_path=[];
xval=CLOSED(i,1);
yval=CLOSED(i,2);
i=1;
Optimal_path(i,1)=xval;
Optimal_path(i,2)=yval;
i=i+1;

if ( (xval == xTarget) && (yval == yTarget))
    inode=0;
   %Traverse OPEN and determine the parent nodes
   parent_x=OPEN(node_index(OPEN,xval,yval),4);%node_index returns the index of the node
   parent_y=OPEN(node_index(OPEN,xval,yval),5);
   
   while( parent_x ~= sxc || parent_y ~= syc)
           Optimal_path(i,1) = parent_x;
           Optimal_path(i,2) = parent_y;
           %Get the grandparents:-)
           inode=node_index(OPEN,parent_x,parent_y);
           parent_x=OPEN(inode,4);%node_index returns the index of the node
           parent_y=OPEN(inode,5);
           i=i+1;
    end;
 j=size(Optimal_path,1);
 %Plot the Optimal Path!
 % add .5 to all points?
 p=plot(Optimal_path(j,1),Optimal_path(j,2),'bo');
 j=j-1;
 for i=j:-1:1
  pause(.25);
  set(p,'XData',Optimal_path(i,1),'YData',Optimal_path(i,2));
 drawnow ;
 end;
 plot(Optimal_path(:,1),Optimal_path(:,2));
else
 pause(1);
 h=msgbox('Sorry, No path exists to the Target!','warn');
 uiwait(h,5);
end
x = Optimal_path(:,1);
y = Optimal_path(:,2);
    



end