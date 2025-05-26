clc;
close all;
clear ;
%% 修改文件编码为 UTF-8
file_path = 'D:\Project\H100_FPGA\Bit\matable\data.txt';
fileID = fopen(file_path, 'r');
% 逐行读取数据
data = {};

line = fgetl(fileID);
result = textscan(line, '%s',-1);

data = result{1};

return_data = cell2mat(data);
% 关闭文件
fclose(fileID);
%%
close all;
% [rise,fall,dist,rssi] = A1(data); 
[rise,fall,dist] = A1(data);

pulse = fall - rise;

n = 0:5400 ;
x = (n )./5401 * 2*pi;
m = n+1 ;


% figure
% plot(rise(m).*cos(x)',rise(m).*sin(x)','.');
% title("直角坐标系:前沿");
% figure
% plot(pulse(m).*cos(x)',pulse(m).*sin(x)','.');
% title("直角坐标系:脉宽");
% figure
% plot(fall(m).*cos(x)',fall(m).*sin(x)','.');
% title("直角坐标系:后沿");
% figure
% plot(dist(m).*cos(x)',dist(m).*sin(x)','.');
% title("直角坐标系:距离");

figure
polarplot(x,rise(m),'.');
title("极坐标系:前沿");
figure
polarplot(x,pulse(m),'.');
title("极坐标系:脉宽");
figure
polarplot(x,fall(m),'.');
title("极坐标系:后沿");
figure
polarplot(x,dist(m),'.');
title("极坐标系:距离");
%%
% N= length(data);
% point_N = N/4;
% rise = zeros(point_N,1);
% fall = zeros(point_N,1);
% for n= 1:point_N
%     rise(n) = hex2dec(data(4*(n-1)+4,:)) *2^8   + hex2dec(data(4*(n-1)+3,:));
%     fall(n) = hex2dec(data(4*(n-1)+2,:)) *2^8   + hex2dec(data(4*(n-1)+1,:));
% end
% 

