%%
close all;
clear ;
clc ;
%%
file_path = './data.log';
%% 
fileID = fopen(file_path,'r');

line = fgetl(fileID);
result = textscan(line,'%s',-1);

data = result{1};

fclose(fileID); 

[rise,fall,dist,rssi] = A1(data);

% dist(7847) = dist(1);
% dist(7846) = dist(1);

% figure
% hist(dist)
% 
% mean_d = mean(dist);
% std_d  = std(dist);

%%
close all
pulse  = fall - rise;

NN = length(fall);

PPP = 0.05;
MMM = ceil(270/PPP);

L = floor(NN/MMM);



MM = MMM-1;
MM_OFF = floor(45/PPP);    
PP     = floor(360/PPP);   

for l=1:L
    n=0:MM;
    tar_angle = [0,360];
    
    x = (n-MM_OFF)./PP *2*pi;
    m=n+1 + (l-1)*MMM;
    
    figure
    polarplot(x,dist(m),'.');
%     rlim([0,16000]);
    thetalim(tar_angle);
    title("雷达原始距离：单位1mm");
end
%%
figure
polarplot(x,rise(m),'.');
% thetalim(tar_angle)
title("前沿：单位7.6ps");
figure
polarplot(x,pulse(m),'.');
title("脉宽：单位7.6ps");
% thetalim(tar_angle) 
figure
polarplot(x,rssi(m),'.');
% thetalim(tar_angle)
title("雷达反射率：单位1");
figure
polarplot(x,dist(m),'.');
% thetalim(tar_angle);
title("雷达原始距离：单位1mm");

analys_Data = [dist , rise ,pulse,rssi];

%%
N =length(rise);

if N > 2751
    N = 2751;
end

cal_dist = zeros(N,1);
pulse_index = zeros(N,1);
rise_index  = zeros(N,1);
cal_rssi    = zeros(N,1);

for n=1:N
    if n==1320
        tar  =1;
    end
   [cal_dist(n),pulse_index(n), rise_index(n),cal_rssi(n)] = H1_calculate_distance(rise(n),pulse(n),Rxi,qyfd,Wxi,DisX,Ow3,Ow4) ;
end

% % [cal_dist(n),pulse_index(n), rise_index(n),cal_rssi(n)] = C2_calculate_distance(rise(n),pulse(n),RRxi,Rxi,Wxi,DisX,Ow3,Ow4) ;
% end
figure
polarplot(x,cal_rssi(m),'.');
thetalim([60 110]);

% rlim([0,1000]);
% % thetalim(tar_angle);
% title("H1youhua_030421v0 雷达优化低反系数后距离：单位1mm");
% 
% figure
% polarplot(x,cal_rssi(m),'.');
% % rlim([0,200]);
% % thetalim(tar_angle);
% title("calc rssi");
% dis_tar = [dist, cal_dist,fall-rise];
%%
%H1_calculate_distance(380,3192,Rxi,qyfd,Wxi,DisX)
% tar_data = [dist,rssi];
% 
% writematrix(tar_data,'./sim_one_cycle_data.txt');

%%
% file_filter_sim = "D:\project\temp\h100_fpga_24010311\H100_FPGA\source\testbench\sim_one_cycle_data_0421_3600mm_filter.log";
% sim_data =load(file_filter_sim);
% 
% angle = (sim_data(:,1)-450)./3600  *2*pi;
% figure
% polarplot(angle,sim_data(:,2),'.');
% rlim([0,4000]);
% thetalim(tar_angle);
% title("雷达拖尾滤波仿真结果：单位1mm");