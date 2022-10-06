function image = takePhoto()
vid = videoinput('gentl', 1, 'BGRA8Packed');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;

% preview(vid);

% Camera parameters
src.AEAGEnable = 'True';
src.BadpixelCorrection = 'True';
src.BalanceWhiteAuto = 'Continuous';
src.AEAGLevel = 20;
src.GammaY = 0.663829028606415;
src.GammaC = 0.493826985359192;
src.AEAGExpLim = 100000;
src.Gain = 10.2016000747681;
src.Sharpness = 4;

start(vid);

% closepreview;

milliPause(500);

%stoppreview(vid);

image = getdata(vid);
end

