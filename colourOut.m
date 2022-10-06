function [outlines, colourMat, work] = colourOut(im)
% separates the clutter based on color
% outlines = outline of the shapes
% colourMat = colour matrix of boundingbox corrosponding to same outline
% index. 
% coloutMat representations
% 1: red
% 2: blue
% 3: green
% 4: yellow
% 
% doesn't deal with target and coin
% 
work = 1;
red = sepRed(im);
blue = sepBlue(im);
green = sepGreen(im);
yellow = sepYellow(im);
rout = regionprops(red);
bout = regionprops(blue);
gout = regionprops(green);
yout = regionprops(yellow);

% put the matrices together
outlines = cat(1,rout,bout,gout,yout);
%{
for i = 1:size(outline,1)
    if i <= size(rout,1)
        colourMat(i,1) = 1;
    elseif i <= (size(rout,1) + size(bout,1))
        colourMat(i,1) = 2;
    elseif i <= (size(rout,1) + size(bout,1) + size(gout,1))
        colourMat(i,1) = 3;
    elseif i <= (size(rout,1) + size(bout,1) + size(gout,1) + size(yout,1))
        colourMat(i,1) = 4;
    else
        outlines(100000); % just throw error
    end
end
%}
% Select valid clutters using bounding box size
clutterMatInd = 1;
clutterIndexes = zeros(length(outlines),1);
for k = 1 : size(outlines,1)
    if outlines(k).BoundingBox(3) > 15
        if outlines(k).Area > 300
            clutterIndexes(clutterMatInd) = k;
            clutterMatInd = clutterMatInd + 1;
        end
    end
end
if clutterMatInd ==1
    outlines = 0;
    colourMat = 0;
    work = 0;
    return;
end
% Create a clutterObj struct containing info of all valid clutters
clutterObj = struct('Area',cell(length(clutterIndexes),1),'Centroid',...
    cell(length(clutterIndexes),1),'BoundingBox',cell(length(clutterIndexes),1)...
    );

% Allocate colour to cMat
cInd = 1;
for i = 1:size(clutterIndexes,1)

    if clutterIndexes(i) ~= 0
        clutterObj(i)=outlines(clutterIndexes(i));

        if clutterIndexes(i) <= size(rout,1)
            colourMat(cInd,1) = 1;
        elseif clutterIndexes(i) <= (size(rout,1) + size(bout,1))
            colourMat(cInd,1) = 2;
        elseif clutterIndexes(i) <= (size(rout,1) + size(bout,1) + size(gout,1))
            colourMat(cInd,1) = 3;
        elseif clutterIndexes(i) <= (size(rout,1) + size(bout,1) + size(gout,1) + size(yout,1))
            colourMat(cInd,1) = 4;
        else
            outlines(100000); % just throw error
        end
        cInd = cInd + 1;
    else 
        colourMat(1,1) = 0;
    end
end
% delete empty objects
outlines = clutterObj(~cellfun(@isempty,{clutterObj.Area}));

end