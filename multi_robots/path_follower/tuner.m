
%%
rosshutdown
rosinit('192.168.1.7')

robotBgoalspub = rospublisher("/Bgoals","std_msgs/Int32MultiArray","DataFormat","struct");
robotBgoalspubms = rosmessage(robotBgoalspub);



    robotBgoalspubms.Data = int32([2,3]);
    send(robotBgoalspub,robotBgoalspubms);
    pause(0.01);
    %%
    rosshutdown
rosinit('192.168.1.7')

robotBgoalspub = rospublisher("/Agoals","std_msgs/Int32MultiArray","DataFormat","struct");
robotBgoalspubms = rosmessage(robotBgoalspub);



    robotBgoalspubms.Data = int32([5,4,3]);
%         robotBgoalspubms.Data = int32([3]);

    send(robotBgoalspub,robotBgoalspubms);
    pause(0.01);