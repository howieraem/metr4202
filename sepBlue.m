function mask = sepBlue(im)
    rgDif = 80;
    bThres = 90;
    rgThres = 220;
    brDif = 30;
    mask = zeros(size(im,1),size(im,2));
    for row = 1:size(im,1) % rows;
        for col = 1:size(im,2)
            r = im(row,col,1);
            g = im(row,col,2);
            b = im(row,col,3);
            if(b > bThres) && r < rgThres && g < rgThres
                if abs(r - g) < rgDif
                    if abs(b - (r+g)/2) > brDif
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
    g(:,:,[1,2]) = 0;
    figure(2), imshow(g);
    %}
end