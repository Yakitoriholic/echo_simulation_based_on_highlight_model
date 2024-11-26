function est_ir_vec=signal_mf(rx_signal, tx_source, cir_length)

ttl_samples=length(tx_source);

%generate matched-filter from the source signal
txsig_flip=conj(tx_source(end:-1:1));

%matched-filtering
%division by ttl_samples is necessary for normalization
est_ir_vec=conv(txsig_flip, rx_signal)/ttl_samples;
est_ir_vec=est