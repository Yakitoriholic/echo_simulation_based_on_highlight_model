clc;clear;close all;
fs = 30000;
t = 0:1/fs:0.14 - 1/fs; % 时间向量，这里生成0到0.14秒的时间序列，采样间隔为1/fs
Ts = 1/fs;
fc = 500;
c = 1500;
% 定义梯形脉冲参数
A = 1; % 幅度为1V
width = 32e-3; % 宽度为32ms
rise_time = 11e-3; % 上升时间设为11ms
fall_time = 11e-3; % 下降时间设为11ms
% 生成梯形脉冲
a = zeros(size(t));
for i = 1:length(t)
    if t(i) >= 0 && t(i) < rise_time
        a(i) = A * t(i) / rise_time;
    elseif t(i) >= rise_time && t(i) < rise_time + width
        a(i) = A;
    elseif t(i) >= rise_time + width && t(i) < rise_time + width + fall_time
        a(i) = A - A * (t(i) - (rise_time + width))/fall_time;
    end
end
wc = 2*pi*fc;
P = a.*exp(j*wc*t);

v = 4.116;%潜艇运动速度8海里/h
global theta;
wd = 2*wc*v*cos(theta*pi/180)/c;%多普勒角频率

PWithDoplar = P.*exp(1j*wd*t);


tau = zeros(6,1);
L = zeros(6,1);  %L存放亮点与艇艇的距离
L = [76,  %A
     60,  %B
     45,  %C
     30,  %D
     16,  %E
     0];  %F
R = 1000;    %两者的距离
c = 1500;    %声速1500m/s

 for j = 1:6
      term1 = (R + L(j)*cos(theta*pi/180)).^2;
      term2 = (L(j)*sin(theta))^2;
      numerator = 2*sqrt(term1 + term2);
      tau(j) = numerator/c;
 end

 % 定义距离和反射系数
L = [76, 60, 45, 30, 16, 0];
b = [0.4, 0.3, 1.0, 0.3, 0.3, 0.5];
r = [7,7,8,7,7,7];

L_ij = zeros(6,6);
h_ji = zeros(6,6);
S_ij = zeros(6,6);

for i =1:6
    for j = 1:6
        L_ij(i,j) = L(j) - L(i);
        h_ij(i,j) = (L_ij(i,j) - r(i)./sin(theta*pi/180) ).*sin(theta*pi/180);
        alpha = acos(h_ij(i,j)/r(i));
        S_ij(i,j) = r(i)/2.*(2*alpha) - h_ij(i,j)*sqrt(r(i).^2 - h_ij(i,j).^2);

      %  C_ij(i,j) = S_ij(i,j)./(pi*r(i).^2);
    end
end

% 计算隐蔽系数
C_ij = zeros(6,6);
for i = 1:6
    for j = 1:6
        if ( abs(L(i)-L(j)).*cos(theta*pi/180) ) < r(i) + r(j)   %传播方向上的投影长度小于亮点半径之和
            C_ij(i, j) = S_ij(i,j)./(pi*r(i).^2); % 由于没有S_ij数据，这里设为0
        else
            C_ij(i, j) = 0;
        end
    end
end

% 计算每个亮点的实际反射系数
B = zeros(1, 6);
for i = 1:6
    C(i) = max(C_ij(i, :));
    B(i) = b(i) * (1 - C(i));
    % 计算目标强度
    TS(i) = 10 * log10(r(i).^2 / 4) + 10 * log10(B(i));
    
    % 计算亮点子回波幅度
    A(i) = 10.^(TS(i) / 20);
end


phi = pi;%假设相位跳变180°
Phi = (wc + wd).*t + phi;
discDelay = round(tau./Ts);
t = 0:1/fs:2 - 1/fs; % 时间向量，这里生成0到2秒的时间序列，采样间隔为1/fs
dotNum = length(a);
dotNumNew = length(t);

aWithDelay = zeros(6,length(t));
for i =1:6
    aWithDelay(i,:) = [zeros(1,discDelay(i)), a , zeros(1,dotNumNew-discDelay(i)-dotNum)];
end

PWithDoplarAndDelay = zeros(6,length(t));
for i =1:6
    PWithDoplarAndDelay(i,:) = [zeros(1,discDelay(i)), PWithDoplar , zeros(1,dotNumNew-discDelay(i)-dotNum)];
end

e = zeros(6,dotNumNew);
for i = 1:6
    e(i,:) = A(i).*aWithDelay(i,:).*PWithDoplarAndDelay(i,:).*exp(1j*phi);
end

echo = sum(e,1);

%计算回波脉宽
start_index_echo = find(abs(echo) > 0, 1, 'first');%应该设置一个阈值
end_index_echo = find(abs(echo) > 0, 1, 'last');
W_echo = (t(end_index_echo) - t(start_index_echo));

TS_submarine = 10*log10(  ( sum(real(echo).^2)/W_echo ) /     (  sum(real(P).^2)/width  )     );
fprintf('角度%d完成\n',theta);