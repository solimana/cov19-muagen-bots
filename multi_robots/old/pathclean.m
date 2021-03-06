%%
rosshutdown
    clear
    clc 

    close all
    
rosinit('192.168.1.7')


%%
% robposB

robotposeB = rossubscriber("/pos_robB","DataFormat","struct");
   
[msg2] = receive(robotposeB,10);
robposB = double(msg2.Data); 
 
robotposeB_or = rossubscriber("/qualisys/robotB/pose","DataFormat","struct");
       
[msg2] = receive(robotposeB_or,10);
robotposeB_orv = double([msg2.Pose.Orientation.X msg2.Pose.Orientation.Y msg2.Pose.Orientation.Z msg2.Pose.Orientation.W]);
robotposeB_orv = rad2deg(quat2eul(robotposeB_orv,'XYZ'));
   
initialOrientation = deg2rad(robotposeB_orv(2)+90);
C_Robot_Pos = [robposB(3) robposB(1)];
C_Robot_Angr = initialOrientation;
% initialOrientation = deg2rad(90);

goal = 1;
goals = ["/pos_st1";"/pos_st2";"/pos_st3";"/pos_st4";"/pos_st5"];

goalpose = rossubscriber(goals(1),"DataFormat","struct");
   [msg2] = receive(goalpose,10);
   goalposed = double(msg2.Data); 
   

pause(1);


robotBpub = rospublisher("/motorsB","std_msgs/Int32MultiArray","DataFormat","struct");
robotBmsg = rosmessage(robotBpub);



drawbotn([C_Robot_Pos C_Robot_Angr], .1, 1);
hold on

D_Robot_Pos = [goalposed(3) goalposed(1)];
D_Robot_Angr = 0;
drawbotn([D_Robot_Pos D_Robot_Angr], .1, 1);

% P controller gains
k_rho = 1;                           %should be larger than 0, i.e, k_rho > 0
k_alpha = 25;                          %k_alpha - k_rho > 0
k_beta = -0.008;                        %should be smaller than 0, i.e, k_beta < 0


d = 0.122;                                 %robot's distance
dt = .1;                                %timestep between driving and collecting sensor data

    robotBpub = rospublisher("/motorsB","std_msgs/Int32MultiArray","DataFormat","struct");
robotBmsg = rosmessage(robotBpub);

%% 
%for vel_data vector count

goalRadius = 0.3;
distanceToGoal = norm(C_Robot_Pos - D_Robot_Pos);

while( distanceToGoal > goalRadius )

    delta_x = D_Robot_Pos(1) - C_Robot_Pos(1);
    delta_y = D_Robot_Pos(2) - C_Robot_Pos(2);
    rho = sqrt(delta_x^2+delta_y^2);    %distance between the center of the robot's wheel axle and the goal position.
    alpha = -C_Robot_Angr+atan2(delta_y,delta_x); %angle between the robot's current direction and the vector connecting the center of the axle of the sheels with the final position.
    
    %limit alpha range from -180 degree to +180
    if rad2deg(alpha) > 180
        temp_alpha = rad2deg(alpha) - 360;
        alpha = deg2rad(temp_alpha);
    elseif rad2deg(alpha) < -180
        temp_alpha = rad2deg(alpha) + 360;
        alpha = deg2rad(temp_alpha);
    end
    
    beta = -C_Robot_Angr-alpha;
    
    % P controller
    v = k_rho*rho;
    w = k_alpha*alpha + k_beta*beta;
    vL = v + d/2*w;
    vR = v - d/2*w;
    
    vl_command = (floor(vL*800));
    vr_command = (floor(vR*800));
    robotBmsg.Data = int32([vl_command,vr_command]);
    
    send(robotBpub,robotBmsg);
    
    
    
        
   [msg2] = receive(robotposeB,10);
   robposB = double(msg2.Data);
      
    [msg2] = receive(robotposeB_or,10);
   robotposeB_orv = double([msg2.Pose.Orientation.X msg2.Pose.Orientation.Y msg2.Pose.Orientation.Z msg2.Pose.Orientation.W]);
   robotposeB_orv = rad2deg(quat2eul(robotposeB_orv,'XYZ'));
   corientation = deg2rad(robotposeB_orv(2)+90);
   
   posr = [robposB(3);robposB(1);corientation];
    
%     posr = [C_Robot_Pos C_Robot_Angr];
%     posr = drive(posr, d, vL, vR, dt, posr(3)); %determine new position
    drawbotn(posr, .1, 1);
    C_Robot_Pos = [posr(1) posr(2)];
    C_Robot_Angr = corientation;
    pause(0.01); % if you notice any lagging, try to increase pause time a bit, e.g., 0.05 -> 0.1
    
       distanceToGoal = norm(C_Robot_Pos(:) - D_Robot_Pos(:));

end

    robotBmsg.Data = int32([0,0]);
    
    send(robotBpub,robotBmsg);
%%
% %for velocity plot
% figure
% plot(vel_data);
% title('Velocities of Two Wheels');
