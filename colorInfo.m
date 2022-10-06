function info = colorInfo(im)
    %returns color info of each pixel in a rgb image
    % 0: none
    % 1: red
    % 2: blue
    % 3: green
    % 4: yellow
    rmask = sepRed(im);
    bmask = sepBlue(im);
    gmask = sepGreen(im);
    ymask = sepYellow(im);
    info = zeros(size(im,1), size(im,2));
    for i = 1:size(info,1)
        for j = 1:size(info,2)
            if rmask(i,j) == 1
                info(i,j) = 1;
            elseif bmask(i,j) == 1
                    info(i,j) = 2;
            elseif gmask(i,j) == 1
                info(i,j) = 3;
            elseif ymask(i,j) == 1
                info(i,j) = 4;
            end
        end
    end
end