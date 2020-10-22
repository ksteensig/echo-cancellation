[u,Fs] = audioread('perceived_B.wav');
[d,Fs] = audioread('perceived_B_with_noise.wav');

u(length(u)+1:length(d)) = 0;

v_car = audioread('audio/inside_car.wav');
v_car = resample(v_car, 8000, 44100);
v_car = v_car(1:length(d));

v_peter = audioread('audio/houston_problem.wav');
v_peter = v_peter(:,1);
v_peter = resample(v_peter, 8000, 11025);

pos = 8000*4.5;

zeroed = zeros(length(d),1);
zeroed(pos:pos+length(v_peter)-1) = v_peter;
v_peter = zeroed;

% filter taps
M = 2000;
lms = dsp.LMSFilter(M,'StepSizeSource','Input port');

% higher step size makes it unstable
mu = 0.001;
[y_lms, e_lms, w_lms] = lms(u, d, mu);

% default step size 1
apf = dsp.AffineProjectionFilter(M);
[y_apf,e_apf] = apf(u,d);


%% Q3

[u,Fs] = audioread('perceived_B.wav');

u_pad = u;
u_pad(length(u)+1:length(d)) = 0;

z = z/rms(z);
v_tot = (v_car+v_peter)/(rms(v_car+v_peter));

% filter taps
M = 2000;
apf = dsp.AffineProjectionFilter(M);

pre_delay = 0:0.01:0.3;
E = zeros(length(pre_delay),1);

for i=1:length(pre_delay)
    i
    z = schroeder_reverb(u,Fs,0,1000,pre_delay(i),0.5,'lp',length(u_pad)-pre_delay(i)*Fs);
    [y_apf,e_apf] = apf(u_pad,z+v_tot*db2pow(-10));
    E(i) = rms(e_apf);
end

figure(1)
plot(pre_delay, E)
xlabel('Pre-delay in seconds')
ylabel('RMSE')
title('e(n) with noise attenuation of 10dB')

%%



z = schroeder_reverb(u,Fs,0,1000,0.2,0.5,'lp',length(u_pad)-0.2*Fs);

SNR = 0:30;
E = zeros(length(pre_delay),1);

z = z/rms(z);
v_tot = (v_car+v_peter)/(rms(v_car+v_peter));

for i=1:length(SNR)
    i
    s = db2pow(-i+1);
    [y_apf,e_apf] = apf(u_pad,z+v_tot*s);
    E(i) = rms(e_apf);
end

figure(2)
plot(flip(SNR), flip(E))
xlabel('Attenuation of noise in dB')
ylabel('RMSE')
title('e(n) with pre-delay of 0.2s')