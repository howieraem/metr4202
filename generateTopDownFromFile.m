%% Script for METR4202 PS3 Generating Top-down View
% Assuming that the calibration image and the scene image are taken by the
% same camera and have the same setup.

function topDownImage = generateTopDownFromFile(filename,movingPoints,movingPoints1,fixedPoints)
load('cameraParams.mat');
% movingPoints = [];
% movingPoints1 = [];
% fixedPoints = [];
% load('movingPoints.mat');
% load('movingPoints1.mat');
% load('fixedPoints.mat');
Ic = imread(filename);
undistortedImage = undistortImage(Ic, cameraParams);
% New corresponding matlab functions of cp2tform and imtransform may not work
tform = cp2tform(movingPoints,fixedPoints,'projective');
outputImage = imtransform(undistortedImage,tform);
topDownImage = imcrop(outputImage,[movingPoints1(1,1) movingPoints1(1,2) abs(movingPoints1(2,1)-movingPoints1(1,1)) abs(movingPoints1(1,2)-movingPoints1(4,2))]);
%imshow(topDownImage);
end