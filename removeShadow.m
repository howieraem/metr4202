function image = removeShadow(inImage)
    % removes shadow from image using median color
    % which is expected to be the background color of workspace
    % inImage = image matrix
    
    threshold = 60; % threshold of color filtering
    R = median(median(inImage(:,:,1)));
    G = median(median(inImage(:,:,2)));
    B = median(median(inImage(:,:,3)));
    medianColor = [R,G,B];
    imageSize = size(inImage(:,:,1));
    image = inImage;
    for i = 1:imageSize(1)
        for j = 1:imageSize(2)
            pixel = [inImage(i,j,1),inImage(i,j,2),inImage(i,j,3)];
            comparison = double(pixel) - double(medianColor);
            if abs(comparison(1)-comparison(2)) < threshold && ...
                    abs(comparison(2)-comparison(3)) < threshold && ...
                    abs(comparison(1)-comparison(3)) < threshold
                image(i,j,1) = R;
                image(i,j,2) = G;
                image(i,j,3) = B;
            
            end
        end
    end





end