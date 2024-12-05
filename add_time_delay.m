function  output = add_time_delay(input,delay,fs) 


N = length(input); % 获取输入信号的点数
f = (-fs/2 : fs/N : fs/2 - fs/N); % 生成从 -fs/2 到 fs/2 - fs/N 的等间隔频率向量，间隔为 fs/N

y1 = input;

Y1 =fftshift(fft(y1));

% Y1 = fftshift(Y1);

tao = delay;

Y2 = Y1.*exp(-1i*2*pi*f*tao);

s2 = ifft(Y2);

output = s2;

end