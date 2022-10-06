while 1
    k = input('angle=: ');
    if strcmp(k,'q')
        break;
    end
    o.writeAngle('id',5,'deg',k);
    o.writeAngle('id',8,'deg',k);
end