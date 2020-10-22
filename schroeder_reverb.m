function y = schroeder_reverb(x,fs,Tr,fc,t0,g,type,y_length)
% Adds artificial reverberation to the input signal x using 
% Schroeder's algorithm
% For details, see
% Mark Kahrs. Applications of digital signal processing to audio and acoustics. 
% Kluwer, 1. edition, 1998. ISBN 0792381300.
%
% y = schroeder_reverb(x,fs,Tr,fc,t0,g,type,y_length)
% where
% x:         input signal
% fs:        sampling frequency
% Tr:        reverberatation time
% fc:        lp-filter corner frequency
% m0:        pre-delay length
% g:         reverberation level
% type:      either 'plain' or 'lp' where lp refers to low-pass
% y_length:  desired length of output signal
% y:         output signal with length y_length

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting up parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pre-delay length
m0 = round(t0*fs)              ; % convert from time to samples
%Comb filter delays
m1 = round(0.031*fs)           ; % reference: Kahrs
m2 = round(0.037*fs)           ; % reference: Kahrs
m3 = round(0.041*fs)           ; % reference: Kahrs
m4 = round(0.043*fs)           ; % reference: Kahrs
%Comb filter gains
g1 = 10^(-3*m1/(Tr*fs))        ; % reference: Kahrs
g2 = 10^(-3*m2/(Tr*fs))        ; % reference: Kahrs
g3 = 10^(-3*m3/(Tr*fs))        ; % reference: Kahrs
g4 = 10^(-3*m4/(Tr*fs))        ; % reference: Kahrs
%Low pass filter coefficients
[b,a] = butter(1,2*fc/fs)      ;
a_lp = a(2)                    ;
b_lp = b(2)                    ;
%Allpass filter delays
m5 = round(0.005*fs)           ; % reference: Kahrs
m6 = round(0.0017*fs)          ; % reference: Kahrs
%Allpass filter gains
g5 = 0.7                       ; % reference: Kahrs
g6 = 0.7                       ; % reference: Kahrs
%setting up different temporary variables
diff = y_length - length(x)    ;
if diff > 0
    x = [x;zeros(diff,1)]      ; % zero padding of x 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computing the output signal of the
% reverberator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pre-delay
w0 = [zeros(m0,1);x]           ;
x = [x;zeros(m0,1)]            ;
%comb filters
if strcmp(type,'plain') == 1
  w1 = comb(w0,g1,m1)          ;
  w2 = comb(w0,g2,m2)          ;
  w3 = comb(w0,g3,m3)          ;
  w4 = comb(w0,g4,m4)          ;
else
  w1 = comb_lp(w0,g1,m1,a_lp,b_lp);
  w2 = comb_lp(w0,g2,m2,a_lp,b_lp);
  w3 = comb_lp(w0,g3,m3,a_lp,b_lp);
  w4 = comb_lp(w0,g4,m4,a_lp,b_lp);
end
%sum of comb filter output signals
ws = w1 + w2 + w3 + w4         ;
%allpass filters
w5 = allpass(ws,g5,m5)         ;
w6 = allpass(w5,g6,m6)         ;
y = g*w6 + x                   ;


%plain comb filter
function y = comb(x,g,m)
    y = x                      ;
    for n=(m+1):length(x)
        y(n) = x(n)+g*y(n-m)   ;
    end

%comb filter with low-pass filtering
function y = comb_lp(x,g,m,a,b)
    y = x                      ;
    w1 = zeros(length(x),1)    ;
    w2 = zeros(length(x),1)    ;
    for n=(m+1):length(x)
        y(n) = x(n)+g*w2(n-m)  ;
        w1(n) = y(n-m)-a*w1(n-1);
        w2(n) = b*(w1(n)+w1(n-1));
    end

%allpass filter
function y = allpass(x,g,m)
    y = zeros(length(x),1)     ;
    w = x                      ;
    y(1:m,1) = -g*x(1:m,1)     ;
    for n=(m+1):length(x)
        w(n) = x(n)+w(n-m)*g   ;
        y(n) = w(n-m)-g*w(n)   ;
    end