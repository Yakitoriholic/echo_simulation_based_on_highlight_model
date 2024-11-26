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

bellhopM( 'test' )
load test.mat
%%单位冲激响应
[p,m,n]=size(DelArr);
delay=reshape(DelArr,m,n);
amp1=reshape(AArr,m,n);
amp = abs(amp1); %取模  
x = delay(m,:); %获取第50个接收机的时延和幅值
y = amp(m,:);
figure(3)
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
figure(4)
stem(normDelay,normAmp,'^')
grid on
xlabel('相对时延/s')
ylabel('归一化幅度')
title('归一化冲激响应')

