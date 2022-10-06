function currentAngles = readAngles(o)
currentAngles = cell(1,4);
for i = 1:4
    posnValue=calllib('dynamixel','dxl_read_word',o.Devices(i).id,ControlTable.PresentPos_L);
    if i == 1
        currentAngles(1,i) = num2cell(240-(posnValue/1023*300));
    elseif i == 2
        currentAngles(1,i) = num2cell(posnValue/1023*300-150);
    elseif i == 3
        currentAngles(1,i) = num2cell(posnValue/1023*300-150);
    else
        currentAngles(1,i) = num2cell(posnValue/4095*360-150);
    end
end
currentAngles = cell2mat(currentAngles);
end