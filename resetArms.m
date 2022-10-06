function resetArms(o)
% The zero degree position for AX-12A's is set to the centre
o.setSpeed('id',o.Devices(1).id,'RPM',3);
o.setSpeed('id',o.Devices(2).id,'RPM',3);
o.setSpeed('id',o.Devices(3).id,'RPM',2);
o.writeAngle('id',o.Devices(3).id,'deg',-80);
pause(1.5);
o.setSpeed('id',o.Devices(3).id,'RPM',8);
o.writeAngle('id',o.Devices(3).id,'deg',-30);
pause(2);
o.writeAngle('id',o.Devices(1).id,'deg',240);
o.writeAngle('id',o.Devices(2).id,'deg',60);
end