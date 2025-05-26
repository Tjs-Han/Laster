clc;
close all;
clear ;
%% �޸��ļ�����Ϊ UTF-8
file_path = 'D:\Project\H100_FPGA\Bit\matable\data.txt';
fileID = fopen(file_path, 'r');
% ���ж�ȡ����
data = {};

line = fgetl(fileID);
result = textscan(line, '%s',-1);

data = result{1};

return_data = cell2mat(data);
% �ر��ļ�
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
% title("ֱ������ϵ:ǰ��");
% figure
% plot(pulse(m).*cos(x)',pulse(m).*sin(x)','.');
% title("ֱ������ϵ:����");
% figure
% plot(fall(m).*cos(x)',fall(m).*sin(x)','.');
% title("ֱ������ϵ:����");
% figure
% plot(dist(m).*cos(x)',dist(m).*sin(x)','.');
% title("ֱ������ϵ:����");

figure
polarplot(x,rise(m),'.');
title("������ϵ:ǰ��");
figure
polarplot(x,pulse(m),'.');
title("������ϵ:����");
figure
polarplot(x,fall(m),'.');
title("������ϵ:����");
figure
polarplot(x,dist(m),'.');
title("������ϵ:����");
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

