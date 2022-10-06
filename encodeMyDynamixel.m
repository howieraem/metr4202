if exist('MyDynamixel.p','file')
    fprintf('Deleting files...\n');
    pause(0.25);
    delete 'MyDynamixel.p'
    fprintf('Deleted\n');
    
end
fprintf('Creating Library...\n');
pcode MyDynamixel.m
fprintf('Created...\n');
x = pwd;
des = 'C:\DATA\matlab\lib\bin';
copyfile('MyDynamixel.p',des);