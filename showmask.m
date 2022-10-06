function showmask(im)
    mask1 = sepRed(im);
    mask3 = sepBlue(im);
    mask2 = sepGreen(im);
    mask4 = sepYellow(im);
    figure(11);
    subplot(3,2,1), imshow(im);
    title('orig')
    subplot(3,2,2), imshow(mask1);
    title('r');
    subplot(3,2,3), imshow(mask2);
    title('g');
    subplot(3,2,4), imshow(mask3);
    title('b');
    subplot(3,2,5), imshow(mask4);
    title('y');



end