%% Main Script for METR4202 PS3

%% Initialise
% Test camera and prepare a photo
clearvars;
close all;

% First take some photos and verify if the set parameters have been applied
% which may not be true when the camera is just turned on
moveOnVar = 0;
while ~moveOnVar
    figure(7);
    imshow(takePhoto());
    moveOnVar = str2double(input('Does the photo look fine(Y=1, N=0)? ','s'));
    pause(1);
end
close(7);

% If the camera setup have changed, points need to be reselected from the
% undistorted image and the full top-down image (not cropped yet). Or, load
% from working folder.
moveOnVar = str2double(input('Did the cam move(Y=1, N=0)? ','s'));

movingPoints = [];
movingPoints1 = [];
%}
load('cameraParams.mat');
load('fixedPoints.mat');
if ~moveOnVar
    load('movingPoints.mat');
    load('movingPoints1.mat');
else
    Is = undistortImage(takePhoto(), cameraParams);
    % Select the four corners of the actual workspace precisely and
    % randomly select 4 points on the checkerboard. Export the four corners
    % as movingPoints (overwrite) and do not export the fixedPoints.
    cpselect(Is,checkerboard(100));
    while isempty(movingPoints)
        pause(2);
    end
    tform = cp2tform(movingPoints,fixedPoints,'projective');
    Is = imtransform(Is,tform);
    % Select the top left corner of the actual workspace precisely and
    % select the rest 3 pairs of points randomly. Export only the
    % movingPoints1 (overwrite).
    cpselect(Is,checkerboard(100));
    while isempty(movingPoints1)
        pause(2);
    end

    % Force the cropping parameters to match the correct size 600*300
    movingPoints1(2:3,1) = movingPoints1(1,1)+600;
    movingPoints1(4,1) = movingPoints1(1,1);
    movingPoints1(2,2) = movingPoints1(1,2);
    movingPoints1(3:4,2) = movingPoints1(1,2)+300;
    
    save('movingPoints.mat','movingPoints');
    save('movingPoints1.mat','movingPoints1');
end
%}

% filename = input('Image File Name (no quotes): ','s');
% I = generateTopDownFromFile(filename,movingPoints,movingPoints1,fixedPoints); % prepare the top-down view from the existing image
I = generateTopDown(takePhoto(),movingPoints,movingPoints1,fixedPoints);% prepare the top-down view directly from the camera

%% Image Preprocessing
[height, width, ~] = size(I); % image size information, ideally 300*600

% Produce the image without the coin and the target
Ins = removeShadow(I);

% Increase brightness to avoid shadows
Ig = rgb2gray(I);
Igns = rgb2gray(Ins);
b = 20;
% b1 = 40;
for m = 1:1:height
    for n = 1:1:width
        Ig(m,n)=Ig(m,n)+b;
        % Igns(m,n)=Igns(m,n)+b1;
    end
end

% Sharpen and adjust contrast to highlight edges
edgeThreshold = 0.09;
amount = 0.96;
Ig = localcontrast(Ig, edgeThreshold, amount);
%Igns = localcontrast(Igns, edgeThreshold, amount);
Ig = imsharpen(Ig);
Igns = imsharpen(Igns);
Igns = imsharpen(Igns);
% Ig = imsharpen(Ig);

% Filter the image to remove noises and shadows
Igf = wiener2(Ig);
Igf = wiener2(Igf);
Igf = imgaussfilt(Igf);

% Detect edges
threshold = [0.08,0.18];
threshold1 = 0.015;
E = edge(Igf,'canny',threshold);
%E = edge(Igf,'Roberts',threshold1,'nothinning');
E1 = edge(Igns,'Roberts',threshold1,'nothinning');
E1 = imfill(E1,'holes');
E2 = edge(Igns,'canny',threshold);

% Remove abnormal small objects
E2 = bwareaopen(E2, 95);
E1 = bwareaopen(E1, 45);

% Line thickening
se1 = strel('line',3,0);
se2 = strel('line',3,90);
E2 = imdilate(E2,[se1,se2]);

%% RGB Colour Detections & Bounding Boxes
%objOutlines = regionprops(E1);
clutterExist = 0;

[clutterObj, cMat, work] = colourOut(I);
if exist('clutterObj','var') && work ~=0
    E6 = allMask(I);
    I = showColour(clutterObj, cMat, I);
    figure(6);
    imshow(E6);
    hold on;
    clutterExist = 1;
else
    figure(6);
    imshow(E);
    hold on;
end

% Show images, one original and the other edge B&W
figure(1);
imshow(I);
hold on;
% figure, imshow(Igns);
% hold on;
% figure, imshow(E1);
% hold on;
% figure, imshow(E2);
% hold on;

%% Clutter detection without shape classifications
% Make copies of the properties of the clutter objects found and plot boxes
if clutterExist
    clutterBox = zeros(size(clutterObj,1),4);
    clutterCentroid = zeros(size(clutterObj,1),2);
    clutterArea = zeros(size(clutterObj,1),1);
    for clutterMatInd = 1:size(clutterObj,1)
        clutterBox(clutterMatInd,:)=clutterObj(clutterMatInd).BoundingBox;
        clutterCentroid(clutterMatInd,:)=clutterObj(clutterMatInd).Centroid;
        clutterArea(clutterMatInd)=clutterObj(clutterMatInd).Area;
        figure(6);
        rectangle('Position', [clutterBox(clutterMatInd,1),clutterBox(clutterMatInd,2),...
            clutterBox(clutterMatInd,3),clutterBox(clutterMatInd,4)],'EdgeColor','r','LineWidth',2);
        hold on;
    end
end

%% Find circular objects
% Initialise or preallocate variables
[centers, radii] = imfindcircles(E,[13 35]);
numOfCircles = size(centers,1);
validCirMatInd = 1;
cylinderMatInd = 1;
validCirIndexes = zeros(numOfCircles,1);
cylinderIndexes = zeros(numOfCircles,1);

% Return the centers of target/coin (validCir) and cylindral clutters
if numOfCircles <= 1
    return
else
    for cirInd=1:numOfCircles
        validVar = 1;
        cylinderVar = 0;
        if clutterExist
            for clutInd=1:size(clutterObj,1)
                dx = 5;
                dy = 25;
                xv = [clutterBox(clutInd,1)-dx,clutterBox(clutInd,1)+clutterBox(clutInd,3)+dx,...
                    clutterBox(clutInd,1)+clutterBox(clutInd,3)+dx,...
                    clutterBox(clutInd,1)-dx,clutterBox(clutInd,1)-dx];
                yv = [clutterBox(clutInd,2),clutterBox(clutInd,2),...
                    clutterBox(clutInd,2)+clutterBox(clutInd,4)+dy,...
                    clutterBox(clutInd,2)+clutterBox(clutInd,4)+dy,...
                    clutterBox(clutInd,2)];
                if inpolygon(centers(cirInd,1),centers(cirInd,2),xv,yv)
                    validVar = 0;
                else
                    cylinderVar = 1;
                end
            end
        end
        % Determine whether the center found is inside any clutter bounding
        % boxes
        if validVar
            validCirIndexes(validCirMatInd) = cirInd;
            validCirMatInd = validCirMatInd + 1;
        elseif cylinderVar
            cylinderIndexes(cylinderMatInd) = cirInd;
            cylinderMatInd = cylinderMatInd + 1;
        end
        
    end
    
    % Record the centers of target/coin and cylinders
    for validCirMatInd = 1:size(validCirIndexes,1)
        if validCirIndexes(validCirMatInd) ~= 0
            validCenters(validCirMatInd,:) = centers(validCirIndexes(validCirMatInd),:);
            validRadii(validCirMatInd) = radii(validCirIndexes(validCirMatInd),:);
        end
    end
    
    for cylinderMatInd = 1:size(cylinderIndexes,1)
        if cylinderIndexes(cylinderMatInd) ~= 0
            cylinderCenters(cylinderMatInd,:) = centers(cylinderIndexes(cylinderMatInd),:);
        end
    end
end

% Outline the coin and the target
if size(validCenters,1)<2
    return
end
figure(6);
viscircles(validCenters, validRadii,'EdgeColor','b');
cylinderExist = 0;
if exist('cylinderCenters','var')
    cylinderExist = 1;
end

% Exclude repeated detections of cylinders (i.e. the top surface and the
% bottom surface are both circular)
if cylinderExist
    for cylinderMatInd = 1:size(cylinderCenters,1)
        for cylinderMatInd1 = 1:size(cylinderCenters,1)
            if cylinderCenters(cylinderMatInd1,1)-cylinderCenters(cylinderMatInd,1) < 35 ...
                && abs(norm(cylinderCenters(cylinderMatInd1))-norm(cylinderCenters(cylinderMatInd))) < 35
                if abs(cylinderCenters(cylinderMatInd1,2)-cylinderCenters(cylinderMatInd,2)) < 55
                    if cylinderCenters(cylinderMatInd1,2)>=cylinderCenters(cylinderMatInd,2)
                        cylinderCenters(cylinderMatInd1,:)=cylinderCenters(cylinderMatInd,:);
                    else
                        cylinderCenters(cylinderMatInd,:)=cylinderCenters(cylinderMatInd1,:);
                    end
                end
            end
        end
    end
    cylinderCenters = unique(cylinderCenters,'rows');
    
    % Plot cylinders, assuming radii are all about 15
    cylinderRadii = 15*ones(size(cylinderCenters,1),1);
    figure(6);
    viscircles(cylinderCenters, cylinderRadii,'EdgeColor','m');
end


% Distinguish between targets and coins by sampling the pixel colour or
% brightness
dx = 1;
dy = 1;
pixelSet = impixel(Igf,[validCenters(1,1),validCenters(2,1)],...
    [validCenters(1,2),validCenters(2,2)]);

% Exclude the first sampling points which might be on the black mark
while norm(pixelSet(1,:)) < 90
    pixelSet = impixel(Igf,[validCenters(1,1)+dx,validCenters(2,1)+dy],...
    [validCenters(1,2),validCenters(2,2)]);
    dx = dx + 1;
    dy = dy + 1;
end
while norm(pixelSet(2,:)) < 90
    pixelSet = impixel(Igf,[validCenters(1,1),validCenters(2,1)],...
    [validCenters(1,2)+dx,validCenters(2,2)+dy]);
    dx = dx + 1;
    dy = dy + 1;
end

% Brighter colour has greater norm
if norm(pixelSet(1,:)) > norm(pixelSet(2,:))
   targetCenter = validCenters(1,:);
   coinCenter = validCenters(2,:);
else
    targetCenter = validCenters(2,:);
    coinCenter = validCenters(1,:);
end

figure(6);
plot(targetCenter(1),targetCenter(2),'y+','MarkerSize',10);
hold on;
plot(coinCenter(1),coinCenter(2),'g+','MarkerSize',10);
hold on;
    
%% Path finding
% Discretize workspace and run Astar.
% Set Grid Size
gridSizeX = 30;
gridSizeY = 30;
gridBase = zeros(round(height/gridSizeY),round(width/gridSizeX));
% gridBase = zeros(20, 40);

% Iterate through the image and check whethe the region of interest contains
% the target or coin, if so make grid empty, if grid contains bounding box
% then fill grid with binary 1.
figure(6);
for x = 0:(round(width/gridSizeX)-1)
    for y = 0:(round(height/gridSizeY)-1)
        bbox1 = [x * gridSizeX, y * gridSizeY , gridSizeX, gridSizeY];
        rectangle('Position', [x * gridSizeX, y * gridSizeY , gridSizeX, gridSizeY],...
            'EdgeColor','g','LineWidth',1);
        hold on;
        %Check if Target is in current region of interest
        if (targetCenter(1) > (gridSizeX*x) && targetCenter(1) < (gridSizeX*(1+x))) && ...
                 (targetCenter(2) > (gridSizeY*y) && targetCenter(2) < (gridSizeY*(1+y)))
            gridBase((y+1),(x+1)) = 0;
            targetGridX = y+1;
            targetGridY = x+1;
            rectangle('Position', [x *  gridSizeX, y * gridSizeY , gridSizeX, gridSizeY],...
                'EdgeColor','c','LineWidth',3);
            continue;
        end
        %Check if Coin is in current region of interest
        if (coinCenter(1) > (gridSizeX*x) && coinCenter(1) < (gridSizeX*(1+x))) && ...
                 (coinCenter(2) > (gridSizeY*y) && coinCenter(2) < (gridSizeY*(1+y)))
            gridBase((y+1),(x+1)) = 0;
            coinGridX = y+1;
            coinGridY = x+1;
            rectangle('Position', [x *  gridSizeX, y * gridSizeY , gridSizeX, gridSizeY],...
                'EdgeColor','c','LineWidth',3);
            continue;
        end
        
        %Check whether grid is occuied with clutter.
        if clutterExist
            for clutterMatInd = 1:size(clutterBox,1)
                bbox2 = clutterBox(clutterMatInd,:);
                ratio = bboxOverlapRatio(bbox1, bbox2);
                if ratio > 0 
                   gridBase(y+1,x+1) = 1;
                   rectangle('Position', [x * gridSizeX, y * gridSizeY , gridSizeX, gridSizeY],...
                        'EdgeColor','w','LineWidth',3);
                   hold on;
                   break;
                else 
                    gridBase(y+1,x+1) = 0;
                end
            end
        end
    end
end

% Run Astar search algorithm to find the path
figure(2);
pathToTarget = pathFind(gridBase, coinGridX, coinGridY, targetGridX, targetGridY);
camroll(-90);

disp(pathToTarget);

% Calculate and add offsets to match the physical model. dx & dy are
% related to the coin's centre while dx1 & dy1 are for the target centre.
% Note that change the arm lengths, the camera or other parameters might
% significantly affect those offset values.
if (coinCenter(1)>350) && (coinCenter(2)>130)
    dx = 5+0.1*coinCenter(2);
    dy = 0.05*coinCenter(2);
elseif (coinCenter(1)>350) && (coinCenter(2)<=130) && (coinCenter(2)>60)
    dx = 5+0.006*coinCenter(2);
    dy = 0.15*coinCenter(2);
elseif (coinCenter(1)>350) && (coinCenter(2)<=60)
    dx = 16+0.006*coinCenter(2);
    dy = 0.2*coinCenter(2);
elseif (coinCenter(1)>50) && (coinCenter(1)<=350) && (coinCenter(2)<=130)
    dx = -0.0052*coinCenter(1)+23+0.006*coinCenter(2);
    dy = 0.11*coinCenter(2);
elseif (coinCenter(1)<=50) && (coinCenter(2)<=130)
    dx = -0.0052*coinCenter(1)+27+0.006*coinCenter(2);
    dy = 0.35*coinCenter(2);
else
    dx = -0.0052*coinCenter(1)+5+0.006*coinCenter(2);
    dy = 0.03*coinCenter(2);
end

if (targetCenter(1)>350) && (targetCenter(2)>130)
    dx1 = 5+0.1*targetCenter(2);
    dy1 = 0.05*targetCenter(2);
elseif (targetCenter(1)>350) && (targetCenter(2)<=130) && (targetCenter(2)>60)
    dx1 = 5+0.006*targetCenter(2);
    dy1 = 0.15*targetCenter(2);
elseif (targetCenter(1)>350) && (targetCenter(2)<=60)
    dx1 = 16+0.006*targetCenter(2);
    dy1 = 0.2*targetCenter(2);
elseif (targetCenter(1)>50) && (targetCenter(1)<=350) && (targetCenter(2)<=130)
    dx1 = -0.0052*targetCenter(1)+23+0.006*targetCenter(2);
    dy1 = 0.11*targetCenter(2);
elseif (targetCenter(1)<=50) && (targetCenter(2)<=130)
    dx1 = -0.0052*targetCenter(1)+27+0.006*targetCenter(2);
    dy1 = 0.35*targetCenter(2);
else
    dx1 = -0.0052*targetCenter(1)+5+0.006*targetCenter(2);
    dy1 = 0.03*targetCenter(2);
end

figure(3);
angles = SimMoveGrid(pathToTarget, (300 - coinCenter(1) + dx), coinCenter(2) + dy, ...
    (300 - targetCenter(1) + dx1), targetCenter(2) + dy1, 0, dx ,dy);

% Find the valid entrance to the workspace, starting from the left edge (in
% the camera's view), if not available try the top edge instead
figure(4);
startPath = [-1, -1];   % Initiate start path to be invalid
for i = 2 : 10
    if gridBase(i, 1) == 0
        startPath = pathFind(gridBase, i, 1, coinGridX, coinGridY);
        if startPath(1,1) == -1    % Check whether valid path
            continue;
        else
            break;
        end
    end
end
camroll(-90);

if startPath(1,1) ~= -1        % Check whether a valid start path was found
    figure(3);
    startAngles = SimMoveGrid(startPath, 0, 0, (300 - coinCenter(1) + dx), ... 
        coinCenter(2) + dy, 1, dx, dy);
    camroll(180);
else
    figure(4);
    for i = 1 : 20
        if gridBase(1, i) == 0
            startPath = pathFind(gridBase, 1, i, coinGridX, coinGridY);
            if startPath(1,1) == -1    % Check whether valid path
                continue;
            else
                break;
            end
        end
    end
    camroll(-90);
    if startPath(1,1) ~= -1
        figure(3);
        startAngles = SimMoveGrid(startPath, 0, 0, (300 - coinCenter(1) + dx), ... 
            coinCenter(2) + dy, 1, dx, dy);
        camroll(180);
    else
        error('No entrance to the grid was found!');
    end
end


%}

%% Shape detection for triangular and rectangular clutters via corners
% can try detectMinEigenFeatures
corners = detectHarrisFeatures(E2,'MinQuality',0.37,'FilterSize',9);
if exist('corners','var')
    cornerPosn = corners.Location;
    numCorner = corners.Count;
    % cornerIntersect = zeros(numCorner,2);

    validCornerMatInd = 1;
    validCornerIndexes = zeros(numCorner,1);

    for cornerInd = 1:numCorner
        validVar = 1;
        if cylinderExist
            for cylinderMatInd = 1:size(cylinderCenters,1)
                if pdist([cornerPosn(cornerInd,:); cylinderCenters(cylinderMatInd,:)]) < 25
                    validVar = 0;
                end
            end
        

            for clutterMatInd = 1:size(clutterCentroid,1)
                if pdist([cornerPosn(cornerInd,:); clutterCentroid(clutterMatInd,:)]) < 5
                    validVar = 0;
                end
            end
        end
        if validVar
            validCornerIndexes(validCornerMatInd) = cornerInd;
            validCornerMatInd = validCornerMatInd + 1;
        end
    end    

    for cornerInd = 1:size(validCornerIndexes,1)
        if validCornerIndexes(cornerInd) ~= 0
            validCornerPosn(cornerInd,:) = cornerPosn(validCornerIndexes(cornerInd),:);
        end
    end
    
    if exist('validCornerPosn','var') && clutterExist
        for cornerInd = 1:size(validCornerPosn,1)
            for cornerInd1 = 1:size(validCornerPosn,1)
                if pdist([validCornerPosn(cornerInd,:); validCornerPosn(cornerInd1,:)]) < 18
                    validCornerPosn(cornerInd1,:)=validCornerPosn(cornerInd,:);
                end
            end
        end
        validCornerPosn = unique(validCornerPosn,'rows');
        
        % Shapes are determined by counting the number of corners in each
        % bounding box
        boxCornerCount = zeros(size(clutterBox,1),1);
        for clutterMatInd = 1:size(clutterBox,1)
            dx = 5;
            dy = 0;
            xv = [clutterBox(clutterMatInd,1)-dx,clutterBox(clutterMatInd,1)+clutterBox(clutterMatInd,3),...
                clutterBox(clutterMatInd,1)+clutterBox(clutterMatInd,3),...
                clutterBox(clutterMatInd,1)-dx,clutterBox(clutterMatInd,1)-dx];
            yv = [clutterBox(clutterMatInd,2),clutterBox(clutterMatInd,2),...
                clutterBox(clutterMatInd,2)+clutterBox(clutterMatInd,4)+dy,...
                clutterBox(clutterMatInd,2)+clutterBox(clutterMatInd,4)+dy,...
                clutterBox(clutterMatInd,2)];

            validVar = 1;
            
            if validVar
                for cornerInd = 1:size(validCornerPosn,1)
                    if inpolygon(validCornerPosn(cornerInd,1),validCornerPosn(cornerInd,2),xv,yv)
                        boxCornerCount(clutterMatInd) = boxCornerCount(clutterMatInd) + 1;
                    end
                end
            end
        end

        % Record the bounding boxes around the cubes and the triangular prisms
        trigBoxInd = 1;
        cubeBoxInd = 1;
        for clutterMatInd = 1:size(boxCornerCount,1)
            if boxCornerCount(clutterMatInd) == 3
                trigBox(trigBoxInd,:) = clutterBox(clutterMatInd,:);
                trigBoxInd = trigBoxInd + 1;
            elseif boxCornerCount(clutterMatInd) >= 4
                cubeBox(cubeBoxInd,:) = clutterBox(clutterMatInd,:);
                cubeBoxInd = cubeBoxInd + 1;
            end
        end

        % Plot the valid corners
        figure(1);
        figure(6);
        plot(validCornerPosn(:,1),validCornerPosn(:,2),'c*');
        hold on;

        % Label the cubes and the triangular prisms
        if exist('trigBox','var')
            for trigBoxInd=1:size(trigBox,1)
                I = insertText(I,[trigBox(trigBoxInd,1) trigBox(trigBoxInd,2)],...
                    'triangular prism','BoxColor','white');
            end
        end

        if exist('cubeBox','var')
            for cubeBoxInd=1:size(cubeBox,1)
                I = insertText(I,[cubeBox(cubeBoxInd,1) cubeBox(cubeBoxInd,2)],...
                    'cube','BoxColor','white');
            end
        end

        if cylinderExist
            for cirInd=1:size(cylinderCenters,1)
                I = insertText(I,[cylinderCenters(cirInd,1) cylinderCenters(cirInd,2)],...
                    'cylinder','BoxColor','white');
            end
        end

        % Plot the valid corners and label the shapes
        figure(1);
        imshow(I);
        figure(6);
        plot(validCornerPosn(:,1),validCornerPosn(:,2),'c*');
        hold on;
    end
end


%% Coin & Target Orientation Detections
% Plot Image of Coin
figure(5);
subplot(2,3,1)
coinImg = imcrop(I,[coinCenter(1)-30, coinCenter(2)-30, 60, 60]);
imshow(coinImg)

% Plot Image of Coin, edge applied
threshold2 = 0.13;
E3 = imgaussfilt(Igf);
E3 = imgaussfilt(E3);
E3 = imgaussfilt(E3);
E3 = edge(E3,'canny',threshold2);
E3 = bwareaopen(E3, 65);
subplot(2,3,2)
coinImgf = imcrop(E3,[coinCenter(1)-30, coinCenter(2)-30, 60, 60]);
imshow(coinImgf)

% Plot image of coin centre
subplot(2,3,3)
coinImgfC = imcrop(E3,[coinCenter(1)-17, coinCenter(2)-17, 34, 34]);
%coinImgfC = bwareaopen(coinImgfC, 10);
imshow(coinImgfC)

%Apply Hough Line transform and plot strongest line
[Hc,Tc,Rc] = hough(coinImgfC);
Pc = houghpeaks(Hc);
linesC = houghlines(coinImgfC,Tc,Rc,Pc,'FillGap',3,'MinLength',1);
hold on
max_lenc = 15*sqrt(2);
% Force point 1 to be the centre of the coin
for k = 1:size(linesC,2)
    if pdist([17, 17; linesC(k).point2])<pdist([17, 17; linesC(k).point1])
        linePointVar(1,:) = linesC(k).point2;
        linesC(k).point2 = linesC(k).point1;
        linesC(k).point1 = linePointVar(1,:);
    end
    pointCDist = pdist([17, 17; linesC(k).point1]);
    if pointCDist<max_lenc
        lineCIndex = k;
        max_lenc = pointCDist;
    end
end

xyc = [linesC(lineCIndex).point1; linesC(lineCIndex).point2];
plot(xyc(:,1),xyc(:,2),'LineWidth',2,'Color','green');

% Plot beginnings and ends of lines
plot(xyc(1,1),xyc(1,2),'x','LineWidth',2,'Color','yellow');
plot(xyc(2,1),xyc(2,2),'x','LineWidth',2,'Color','red');

%Plot Target Image
subplot(2,3,4)
targetImg = imcrop(I,[targetCenter(1)-30, targetCenter(2)-30, 60, 60]);
imshow(targetImg)

%Plot Target Image edge filtering applied
threshold3 = 0.7;
E4 = edge(E3,'canny',threshold3);
E4 = bwareaopen(E4, 80);
subplot(2,3,5)
targetImgf = imcrop(E4,[targetCenter(1)-30, targetCenter(2)-30, 60, 60]);
imshow(targetImgf)

%Plot target image centre
subplot(2,3,6)
targetImgfC = imcrop(E4,[targetCenter(1)-20, targetCenter(2)-20, 40, 40]);
targetImgfC = bwareaopen(targetImgfC, 70);
imshow(targetImgfC)

%Apply Hough Lines Transform and plot
[Ht,Tt,Rt] = hough(targetImgfC);
Pt = houghpeaks(Ht);
linesT = houghlines(targetImgfC,Tt,Rt,Pt,'FillGap',5,'MinLength',1);
hold on
max_lent = 20*sqrt(2);

% Force point 1 to be the centre of the target
for k = 1:size(linesT,2)
    if pdist([20, 20; linesT(k).point2])<pdist([20, 20; linesT(k).point1])
        linePointVar(1,:) = linesT(k).point2;
        linesT(k).point2 = linesT(k).point1;
        linesT(k).point1 = linePointVar(1,:);
    end
    pointTDist = pdist([20, 20; linesT(k).point1]);
    if pointTDist<max_lent
        lineTIndex = k;
        max_lent = pointTDist;
    end
end

xyt = [linesT(lineTIndex).point1; linesT(lineTIndex).point2];
plot(xyt(:,1),xyt(:,2),'LineWidth',2,'Color','green');

% Plot beginnings and ends of lines
plot(xyt(1,1),xyt(1,2),'x','LineWidth',2,'Color','yellow');
plot(xyt(2,1),xyt(2,2),'x','LineWidth',2,'Color','red');

% Check if the line is at the top half or the bottom half and calculate the
% ideal angle difference (without considering motors 1 & 2 rotations)
angle4Diff = linesT(lineTIndex).theta - linesC(lineCIndex).theta;
if ((linesT(lineTIndex).point2(2)<=linesT(lineTIndex).point1(2))&&...
        (linesC(lineCIndex).point2(2)>linesC(lineCIndex).point1(2)))||...
        ((linesT(lineTIndex).point2(2)>linesT(lineTIndex).point1(2))&&...
        (linesC(lineCIndex).point2(2)<=linesC(lineCIndex).point1(2)))
    angle4Diff = angle4Diff - 180;
end
if angle4Diff > 180
    angle4Diff = angle4Diff - 360;
elseif angle4Diff < -180
    angle4Diff = angle4Diff + 360;
end

% Title the figures
figure(1);
hold on;
title('Original Image Noted');
figure(2);
hold on;
title('Path from Coin to Target');
figure(3);
hold on;
title('Arm Kinematics Simulation');
figure(4);
hold on;
title('Path entering the Workspace to the Coin');
figure(5);
subplot(2,3,2);
hold on;
title('Coin & Target Orientations');
figure(6);
hold on;
title('Edge, Corner & Grid');

%% Motor execution
o = setupMotors(3); % Input COM number

initSpeed = 4;
gain = 15;  % A scalar to the actual gain calculated from the angle differece between every two angle steps
tic;    % start recording time
actuate(o, 1, startAngles, initSpeed,gain, 0);  % Implement the starting path
pause(1);
actuate(o, 0, angles, initSpeed,gain, angle4Diff);  % Implement the path to the target
duration = toc; % stop recording time
disp(duration);
pause(2);
resetArms(o);   % Drive the arm back to the position out of the workspace
o.Exit();
clear o;
%}