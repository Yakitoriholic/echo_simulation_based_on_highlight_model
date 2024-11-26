%与单位冲激响应函数卷积并加入噪声的函数如下：
function [y, adj_ir_vec]=uw_isi(ir_vec, sl_db, tx_source, nv_db)
%y=uw_isi(ir_vec, sl_db, tx_source, nv) simulate underwater ISI channel
%effects from multipath and ambient noisee
%
%Input: 
%   ir_vec is the channel impulse response (in baseband)    
%   sl_db is the source level in dB
%   tx_source is the source signal (in baseband)
%   nv_db is the noise level in dB
%
%Output: 
%   y is the channel output
%   adj_ir_vec is the source level adjusted impulse response
%
%
%发送信号与信道冲激响应进行卷积
tx_sig=conv(tx_source, ir_vec);

%接收信号信噪比
SNR=sl_db-nv_db;

%信道输出
y=awgn(tx_sig,SNR);
adj_ir_vec=ir_vec;