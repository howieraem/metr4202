
function mask = sepGreen(im)
    rbDif = 70;
    gThres = 80;
    rbThres = 210;
    grDif = 30;
    mask = zeros(size(im,1),size(im,2));
    for row = 1:size(im,1) % rows;
        for col = 1:size(im,2)
            r = im(row,col,1);
            g = im(row,col,2);
            b = im(row,col,3);
            if(g > gThres) && r < rbThres && b < rbThres
                if abs(r - b) < rbDif
                    if abs(g - (r+b)/2) > grDif
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
    g = im;
    g(:,:,[1,3]) = 0;
    figure(2), imshow(g);
    %}
end