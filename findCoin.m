function findCoin(imageTarget, imageScene)
%Function uses feature detection methods to find an Australian 20 cent coin
%Parameters - image to process and the example image. This function uses
%extensive use of the Mathworks feature matching example, reference can be
%seen here;
% 
%Uses SURF feature detection

%Read in images 
imTarget = imread(imageTarget);
imScene = imread(imageScene);

imTarget = rgb2gray(imTarget);
imScene = rgb2gray(imScene);

%detect the surf features
targetPoints = detectSURFFeatures(imTarget);
scenePoints = detectSURFFeatures(imScene);

[targetFeatures, targetPoints] = extractFeatures(imTarget, targetPoints);
[sceneFeatures, scenePoints] = extractFeatures(imScene, scenePoints);

pairs = matchFeatures(targetFeatures, sceneFeatures);


matchedTrgtPoints = targetPoints(pairs(:, 1), :);
matchedScenePoints = scenePoints(pairs(:, 2), :);

[tform, inlierTrgtPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedTrgtPoints, matchedScenePoints, 'affine');
figure;

showMatchedFeatures(imTarget, imScene, inlierTrgtPoints, inlierScenePoints,... 
    'montage');

bbox = [1, 1;...
    size(imTarget, 2), 1;...
    size(imTarget, 2), size(imTarget, 1);...
    1, size(imTarget, 1);...
    1, 1];

newBoxPolygon = transformPointsForward(tform, bbox);

figure;
imshow(imScene);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');
