function im = allMask(im)

mask1 = sepRed(im);
mask2 = sepBlue(im);
mask3 = sepGreen(im);
mask4 = sepYellow(im);
im = mask1 | mask2 | mask3 | mask4;

end