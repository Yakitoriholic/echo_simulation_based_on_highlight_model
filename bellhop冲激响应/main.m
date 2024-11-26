clear; close all; clc; 
%% 这里设置采样频率为1600kHz；发射中心频率为160kHz，发射声源级为185dB，带宽为8kHz。这里通过.arr文件获取单位冲激响应。具体方式请参考本人编写的使用说明书。
%采样率
sampling_rate=1600e3;

%发射机中心频率
%该值和计算噪声有关
fc=160e3;

radio=sampling_rate/fc  %采样率与中心频率的比值
%发射机参数
sl_db=185;  %发射机声源级
bw=8e3;     %带宽

%通过Actup的arr文件获取所需的幅值和时延（单位冲激响应）
 %BELLHOP run ID
 env_id='';
 %read BELLHOP arr file:
 [ amp1, delay1, SrcAngle, RcvrAngle, NumTopBnc, NumBotBnc, narrmat, Pos ] = read_arrivals_asc( [env_id '.arr'] ) ;
 [m,n]=size(amp1);
 amp=amp1(m,:);
 delay=delay1(m,:);
load delay
load amp
%风力等级
windspeed=5;
%% 设置发射数据。这里设置发送数据和通信速率，并加以采样得到采样后的波形。
%Step 1: 创建任意波形（这里以正弦波为例）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_Serial_Signal=[zeros(1,1),ones(1,1),zeros(1,10)];  %待发送串行数据
Signal_L=length(F_Serial_Signal);                    %发送数据长度
communication_rate=40e3;                       %通信速率 
Communication_radio= sampling_rate/communication_rate; %采样倍数
signal=repmat(F_Serial_Signal,Communication_radio,1);
signal2=reshape(signal,1,Signal_L*Communication_radio);      %调整后的数据
signal_length=length(signal2);                 %数据长度
t=0:1/sampling_rate:(signal_length-1)/sampling_rate;      %时间
modulation_signal=cos(2*pi()*fc*t);            %载波信号
tx_source=signal2.*modulation_signal;          %发送

%%  加入噪声和多径干扰。首先对由.arr文件获得的单位冲激响应进行采样，并计算噪声级和接收端接收信号的信噪比。其次，加入多径干扰（与单位冲激响应卷积）和噪声。
%Step 2:加入噪声和多径影响
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Narrmx=10; %limit ourselves to use the first Narrmax paths

%对单位冲激响应进行采样
ir_vec=bharr2ir(delay, amp, sampling_rate);
%strongest tap in dB
maxamp_db=20*log10(max(abs(amp)))+sl_db;%声源级（dB）加由于信道衰减的能量（dB），表示接收到的信号的能量

%噪声级
[npsd_db]=ambientnoise_psd(windspeed, fc);%npsd_db是噪声的能量谱密度（单位频带内的能量）转换成dB，
nv_db=npsd_db+10*log10(bw);%相当于能量谱密度乘以带宽，即该频带内的噪声的能量
% maxamp_db和nv_db的差值应该为信噪比
disp(['Strongest tap strength=' num2str(maxamp_db,'%.1f') ' dB; Noise variance=' num2str(nv_db,'%.1f') 'dB']);

%考虑多径和噪声影响后的接收信号响应
[rx_signal, adj_ir_vec]=uw_isi(ir_vec, maxamp_db, tx_source, nv_db);
%% 得到经调整后的冲激响应
est_ir_vec=signal_mf(rx_signal, tx_source, length(ir_vec));

%绘制
x_vec=(0: length(ir_vec)-1)/sampling_rate*1000;
x_vec2=(0: length(est_ir_vec)-1)/sampling_rate*1000;

figure(1), 
plot(x_vec, abs(adj_ir_vec), 'r-', x_vec2, abs(est_ir_vec), 'b-', 'Linewidth', 2); grid on; hold on;
xlabel('Arrival time (ms)')
ylabel('Abs Amp.');
legend('BELLHOP', 'Estimate')
title('Impulse responses: BELLHOP versus Estimate');