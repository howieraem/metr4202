% color separation functions
% returns the binary image for color mask
% takes in coloured rgb image
function mask = sepRed(im)
    gbDif = 50;
    rThres = 100;
    gbThres = 120;
    rgDif = 50;
    mask = zeros(size(im,1),size(im,2));
    for row = 1:size(im,1) % rows;
        for col = 1:size(im,2)
            r = im(row,col,1);
            g = im(row,col,2);
            b = im(row,col,3);
            if(r > rThres) && g < gbThres && b < gbThres
                if abs(g - b) < gbDif
                    if abs(r - (g+b)/2) > rgDif
                        mask(row,col) = 1;
                    end
                end
            end
        end
        
    end
    mask = imfill(mask,'holes');
    
    mask = bwareaopen(mask, 30);
    %{
    figure(1), imshow(mask);
    r = im;
    r(:,:,2:3) = 0;
    figure(3), imshow(r);
    %}
end
