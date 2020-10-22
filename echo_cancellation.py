import numpy as np
import soundfile as sf
import librosa.display as display

def lms(un,wn,dn,mu):
    en = dn - un.transpose().dot(wn)
    return wn + mu*un*en, en

M = 2000
mu = 0.001

# mu < 2/(trace(Ru)), we say mu = 1/(trace(Ru)) 
def compute_mu(un):
    #return 1/np.dot(un.transpose(),un)
    return 0.001

def load_signal_samples(signal, n, M):
    return signal[n:n+M]

un = np.zeros((M,1))
wn = np.zeros((M,1))
#wn = wn2
dn = 0

reverb_signal_awgn, Fs = sf.read('./audio/perceived_B_with_noise.wav')
reverb_signal_awgn = np.array(reverb_signal_awgn).reshape((len(reverb_signal_awgn), 1))


clear_signal, Fs = sf.read('./audio/perceived_B.wav')
clear_signal = np.array(clear_signal).reshape((len(clear_signal), 1))
clear_signal_len = len(clear_signal)
clear_signal = np.concatenate((np.zeros((M-1,1)), clear_signal), axis=0)


en = np.zeros((clear_signal_len, 1))

for i in range(clear_signal_len):
    dn = reverb_signal_awgn[i]
    un = load_signal_samples(clear_signal, i, M)
    wn, en[i] = lms(un, wn, dn, mu)

#wn2 = wn

#display.waveplot(reverb_signal_awgn.reshape(len(reverb_signal_awgn)))
#display.waveplot(clear_signal.reshape(len(clear_signal)))
display.waveplot(en.reshape(len(en)))
    
sf.write('output.wav', en.tolist(), Fs)