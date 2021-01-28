% Implement 1D CFAR using lagging cells on the given noise and target scenario.

% Close and delete all currently open figures
close all;

% Data_points
Ns = 1000;

% Generate random noise
s=randn(Ns,1);

%Targets location. Assigning bin 100, 200, 300 and 700 as Targets with the amplitudes of 8, 9, 4, 11.
s([100 ,200, 300, 700])=[8 9 4 11];

%plot the output
plot(s);

% TODO: Apply CFAR to detect the targets by filtering the noise.

% 1. Define the following:
% 1a. Training Cells
T = 4;
% 1b. Guard Cells 
G = 1;

% Offset : Adding room above noise threshold for desired SNR 
offset=3.7;

% Vector to hold threshold values 
threshold_cfar = [];

%Vector to hold final signal after thresholding
signal_cfar = [];

threshold_cfar = zeros(Ns,1);
signal_cfar = zeros(Ns,1);
% 2. Slide window across the signal length
for i = 1+G+T:(Ns-(G+T))     
    
    % Average noise in window
    noiseThreshold = (sum(s(i-G-T:i-G-1)) + sum(s(i+G+1:i+G+T)))/(2*T) + offset;
    threshold_cfar(i) = noiseThreshold;
    
    % Thresholding
    if (s(i) > noiseThreshold)
        signal_cfar(i) = s(i);
    end
    
end

% plot the filtered signal
plot (signal_cfar,'g--');

% plot original sig, threshold and filtered signal within the same figure.
figure,plot(s);
hold on,plot(threshold_cfar,'r--','LineWidth',2)
hold on, plot (signal_cfar,'g--','LineWidth',4);
legend('Signal','CFAR Threshold','detection')