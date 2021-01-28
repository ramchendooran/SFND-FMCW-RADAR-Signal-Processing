% Signal parameters.
Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 1500;             % Length of signal
t = (0:L-1)*T;        % Time vector
f1 = 77;              % Signal 1 frequency
A1 = 0.7;             % Signal 1 Amplitude
f2 = 43;              % Signal 2 frequency
A2 = 2;               % Signal 2 frequency

% Define a signal. In this case (amplitude = A, frequency = f)
signal1 = A1*cos(2*pi*f1*t);
signal2 = A2*cos(2*pi*f2*t);
signal = signal1 + signal2;

% TODO: Form a signal containing a 77 Hz sinusoid of amplitude 0.7 and a 43Hz sinusoid of amplitude 2.
S = signal;

% Corrupt the signal with noise 
X = S + 2*randn(size(t));

% Plot the noisy signal in the time domain. It is difficult to identify the frequency components by looking at the signal X(t). 
figure(1);
plot(1000*t(1:50) ,X(1:50))
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('t (milliseconds)')
ylabel('X(t)')

% TODO : Compute the Fourier transform of the signal. 
% Run the fft for the signal using MATLAB fft function for dimension of samples N.
signal_fft = fft(signal,length(S));

% TODO : Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
% The output of FFT processing of a signal is a complex number (a+jb). Since, we just care about the magnitude we take the absolute value (sqrt(a^2+b^2)) of the complex number.
signal_fft = abs(signal_fft/L);
P2 = signal_fft;
% FFT output generates a mirror image of the signal. But we are only interested in the positive half of signal length L, since it is the replica of negative half and has all the information we need.
signal_fft  = signal_fft(1:L/2+1);
P1 = signal_fft;

% Plotting
f = Fs*(0:(L/2))/L;
figure(2);
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')