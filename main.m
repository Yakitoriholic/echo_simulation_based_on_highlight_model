clc;clear;close all;
%% 发射信号_线性调频信号 -----------------------------------------------------------------------

% 信号参数
T = 4e-3; % 脉冲宽度 4ms
f1 = 1.5e3; % 频率下限 1.5kHz
f2 = 2.5e3; % 频率上限 2.5kHz
fs = 20e3; % 采样频率 20kHz
t = 0:1/fs:T - 1/fs; % 时间序列
N = length(t);
new_t = 0:1/fs:0.8-1/fs;%显示到0.8s

% 计算调频斜率
k = (f2 - f1) / T;

% 生成线性调频信号
%s_t =  exp(1j*2*pi*(f1*t + 0.5*k*t.^2)); % 按照线性调频信号公式生成
%new_s_t =[ s_t,zeros(1,length(new_t)-length(s_t))]; % 使用chirp函数生成线性调频信号
%生成CW信号  中心频率1.5kHz
s_t =  exp(1j*2*pi*(f1*t)); 
new_s_t =[ s_t,zeros(1,length(new_t)-length(s_t))];
% 绘制信号波形
figure(1)
subplot(2,1,1)
plot(new_t, real(new_s_t)) ;% 绘制实部
title('CW信号波形');xlabel('时间(s)');ylabel('幅度');grid on;axis([0,0.005,-1.2,1.2])

% 绘制信号频谱
N = length(s_t);
f = (-fs/2:fs/N:fs/2 - fs/N);
S_f = fftshift(fft(s_t));
subplot(2,1,2)
plot(f, abs(S_f))
title('CW信号频谱');xlabel('频率(Hz)');ylabel('幅度谱');grid on;
%% 目标散射函数


% 找到与时间点对应的索引（假设时间序列是均匀采样的）
index_068 = round((0.68 - new_t(1)) / (new_t(2) - new_t(1)));
index_0705 = round((0.705 - new_t(1)) / (new_t(2) - new_t(1)));
index_072 = round((0.72 - new_t(1)) / (new_t(2) - new_t(1)));
index_075 = round((0.75 - new_t(1)) / (new_t(2) - new_t(1)));
index_076 = round((0.76 - new_t(1)) / (new_t(2) - new_t(1)));

f_scatt = zeros(1, length(new_t));
f_scatt(index_068) = 0.6;
f_scatt(index_0705) = 0.4;
f_scatt(index_072) = 0.8;
f_scatt(index_075) = 0.3;
f_scatt(index_076) = 0.6;

y_0 = conv(f_scatt, s_t,'same');
noise_level = 0.02; % 噪声强度，可以根据实际情况调整
white_noise = noise_level*(randn(size(y_0))+j*randn(size(y_0)));
y_0 = y_0 + white_noise;

figure(2);
plot(new_t, real(y_0)); % 绘制实部
title('基于5亮点的主动声纳时域回波信号');
xlabel('时间(s)');
ylabel('幅度');grid on;
axis([0.65,0.8,-inf ,inf]);
%% 绘制声速刨面
z = 0:200:5000;
c0 = 1500;
e = 0.57e-2;
B = 1000;
z0 = 1000;
a = 2*(z - z0)/B;
c = c0*(1 + e*(exp(-a)-(1 - a)));
figure(3)
plot(c,z);grid on;
xlabel('声速/(m·s⁻¹)');ylabel('深度/m');title('深海声道');
set(gca,'YDir','reverse');

%% 绘制声线轨迹
bellhopM( 'test_ray' ) %figure4

%% 绘制脉冲响应 此处存在问题

bellhopM( 'test' )
load test.mat
%%单位冲激响应
[p,m,n]=size(DelArr);
delay=reshape(DelArr,m,n);
amp1=reshape(AArr,m,n);
amp = abs(amp1); %取模  
x = delay(m,:); %获取第50个接收机的时延和幅值
y = amp(m,:);
figure(5)
stem(x,y)
grid on
xlabel('相对时延/s')
ylabel('幅度')
title('单位冲激响应')

%%归一化冲激响应
Amp_Delay = [x;y];
Amp_Delay(:,all(Amp_Delay==0,1))=[]; %去掉0值
Amp_Delay=sortrows(Amp_Delay',1);  %按照时延从小到大排序
normDelay = Amp_Delay(:,1)-Amp_Delay(1,1);%归一化时延
normAmp = Amp_Delay(:,2)/Amp_Delay(1,2);%归一化幅度
figure(6)
stem(normDelay,normAmp,'^')
grid on
xlabel('相对时延/s')
ylabel('归一化幅度')
title('归一化冲激响应')

%% 目标回波
%%亮点参数
%参考文献：一种水下多亮点目标模拟器的设计 宋绪栋,刘鹏仲
a = 70 ;    %a表示潜艇长轴
b = 6 ;    %b表示潜艇短轴
c = 1500;
r = 200;%离潜艇中心点 200 m 处
%theta = linspace(1,180,180);
theta = 90;
%阵元A
%阵元A的参数

A1 = 0.4*0.2* a/sqrt(  (1+a.*a./(b*r))*(1+b/r) );
tau1 = a.*cos(theta*pi/180)/c;
phi1 = pi/4;

%阵元F
A6 = 0.4*0.2* a/sqrt(  (1+a.*a./(b*r))*(1+b/r) );
tau6 = -a.*cos(theta*pi/180)/c;
phi6 = pi/4;

%阵元C
h = 6;d = 10;e = 3;
l = 10;%舰桥中心与 艇体中心相距 10 m
A3 = h*d*e*sqrt(l/pi)./(2* (e.^2 .* (sin(theta*pi/180).^2) + d.^2.*(cos(theta*pi/180).^2)).^(3/4)  );
tau3 = (l.*cos(theta*pi/180) + sqrt(e.^2 .* (sin(theta*pi/180).^2) + d.^2 .* (cos(theta*pi/180).^2)) )/ c;
phi3 = 0;

%阵元B、D、E
A2 = (a.^2.*(sin(theta*pi/180).^2)  + b.^2.*(cos(theta*pi/180).^2) )/2*a;
tau2 = -sqrt(a.^2.*(cos(theta*pi/180).^2) + b.^2.*(sin(theta*pi/180).^2))/c;
phi2 = 0;

A4 = (a.^2.*(sin(theta*pi/180).^2)  + b.^2.*(cos(theta*pi/180).^2) )/2*a;
tau4 = -sqrt(a.^2.*(cos(theta*pi/180).^2)+ b.^2.*(sin(theta*pi/180).^2))/c;
phi4 = 0;

A5 = (a.^2.*(sin(theta*pi/180).^2)  + b.^2.*(cos(theta*pi/180).^2) )/2*a;
tau5 = -sqrt(a.^2.*(cos(theta*pi/180).^2)+ b.^2.*(sin(theta*pi/180).^2))/c;
phi5 = 0;

%% 信号频率为 30 kHz,脉宽为 1.25 ms的CW信号
% 定义参数
fs = 100000; % 采样频率，可根据需要调整，这里设置为100kHz
t = 0:1/fs:1.25e-3; % 时间向量，对应脉宽1.25ms
fc = 30000; % 信号频率为30kHz

t_scale = 0:1/fs:0.2-1/fs;

% 生成CW脉冲信号
cw_pulse = 3*cos(2*pi*fc*t);
cw_pulse = [cw_pulse zeros(1,length(t_scale)-length(t))];
% 绘制信号波形
figure(7)
plot(t_scale, cw_pulse);
xlabel('时间 (s)');ylabel('幅度');title('CW脉冲信号波形');grid on;axis([0,0.2,-50,50]);

%% 回波信号
%阵元A
delay1_n = round(tau1/(1/fs)); %亮点A造成的延迟
CW_1 = A1.*3*cos(2*pi*fc*t+phi1);%亮点A造成的幅度变化
CW_1 = [zeros(1,delay1_n) , CW_1, zeros(1,length(t_scale)-length(t)-delay1_n)];
figure(8)
plot(t_scale*1000, CW_1);
xlabel('时间/ms');ylabel('幅度');title('反射的回波信号');grid on;axis([0,200,-50,50]);

%阵元B
delay2_n = round(tau2/(1/fs)); %亮点B造成的延迟
CW_2 = A2.*3.*cos(2*pi*fc*t+phi2);%亮点B造成的幅度变化
CW_2 = [zeros(1,delay2_n) , CW_2, zeros(1,length(t_scale)-length(t)-delay2_n)];


%阵元C
delay3_n = round(tau3/(1/fs)); 
CW_3 = A3.*3.*cos(2*pi*fc*t+phi3);
CW_3 = [zeros(1,delay3_n) , CW_3, zeros(1,length(t_scale)-length(t)-delay3_n)];
figure
plot(t_scale, CW_3);
xlabel('时间 (s)');ylabel('幅度');title('反射的回波信号');grid on;axis([0,0.2,-50,50]);

%阵元D
delay4_n = round(tau4/(1/fs)); 
CW_4 = A4.*3.*cos(2*pi*fc*t+phi4);
CW_4 = [zeros(1,delay4_n) , CW_4, zeros(1,length(t_scale)-length(t)-delay4_n)];

%阵元E
delay5_n = round(tau5/(1/fs)); 
CW_5 = A5.*3.*cos(2*pi*fc*t+phi5);
CW_5 = [zeros(1,delay5_n) , CW_5, zeros(1,length(t_scale)-length(t)-delay5_n)];

%阵元F
delay6_n = round(tau6/(1/fs)); 
CW_6 = A6.*3.*cos(2*pi*fc*t+phi6);
CW_6 = [zeros(1,abs(delay6_n)) , CW_6, zeros(1,length(t_scale)-length(t)-abs(delay6_n))];
% figure
% plot(t_scale, CW_6);
% xlabel('时间 (s)');ylabel('幅度');title('反射的回波信号');grid on;axis([0,0.2,-50,50]);




