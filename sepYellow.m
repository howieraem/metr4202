function mask = sepYellow(im)
    Dif1 = 70;
    Thres1 = 100;
    %Thres2 = 200;
    Dif2 = 45;
    mask = zeros(size(im,1),size(im,2));
    for row = 1:size(im,1) % rows;
        for col = 1:size(im,2)
            r = im(row,col,1);
            g = im(row,col,2);
            b = im(row,col,3);
            if r > Thres1 && g > Thres1
                if abs(r - g) < Dif1
                    if r - b > Dif2 && g-b > Dif2
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
    %figure(2), imshow(g);
    %}
end