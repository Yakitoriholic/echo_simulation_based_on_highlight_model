function pve_B = beamscp(ksc, P_r, theta, phi)
%�ú�������Ϊ��������Ԫλ�á����䷽��ǣ����������Ӧ����
v_s = - [cosd(phi)* sind(theta), cosd(phi)* cosd(theta), ones(length(theta),1)*sind(phi)].';
kve = v_s*ksc.';
pve_B = exp(-1j * kve.' * P_r).';
end
