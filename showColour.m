function im = showColour(clutterObj, cMat, im)
    for i = 1:size(cMat, 1)
        boxes = clutterObj(i).BoundingBox;
        if cMat(i) == 1
            im = insertText(im, [boxes(1) + 30, boxes(2) + 50], 'Red','BoxColor',...
                'red');
        elseif cMat(i) == 2
            im = insertText(im, [boxes(1) + 30, boxes(2) + 50], 'Blue','BoxColor',...
                'blue');
        elseif cMat(i) == 3
            im = insertText(im, [boxes(1) + 30, boxes(2) + 50], 'Green','BoxColor',...
                'green');
        elseif cMat(i) == 4
            im = insertText(im, [boxes(1) + 30, boxes(2) + 50], 'Yellow','BoxColor',...
                'yellow');
        end
    end
end