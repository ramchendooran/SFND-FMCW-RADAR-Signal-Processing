clear;
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%speed of light = 3e8
%% User Defined Range and Velocity of target
% *%TODO* :
% define the target's initial position and velocity. Note : Velocity
% remains contant
tarPos = 110;
tarVel = -30;

%% FMCW Waveform Generation

% *%TODO* :
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

%speed of light
c = 3e8;
% Max Range
Rmax = 200;
% Range Resolution
Rres = 1;

% Calculate Bandwidth (B)
B = c/(2*Rres);

% Calculate Tchirp
Tchirp = 5.5*2*Rmax/c;

% Calculate slope
slope = B/Tchirp;

%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq

                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples

%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i=1:length(t)         
    
    
    % *%TODO* :
    %For each time stamp update the Range of the Target for constant velocity. 
    tarPosT = tarPos + tarVel*t(i);
    
    % *%TODO* :
    %For each time sample we need update the transmitted and
    %received signal.
    
    % Transmitted signal
    Tx(i) = cos(2*pi*(fc*t(i) + (slope/2)*t(i)^2));
    
    % Time delay
    Tau = 2*tarPosT/c;
    
    % Recieved signal
    Rx(i) = cos(2*pi*(fc*(t(i) - Tau) + (slope/2)*(t(i) - Tau)^2));
    
    % *%TODO* :
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    Mix(i) = Tx(i)*Rx(i);
    
end

%% RANGE MEASUREMENT


 % *%TODO* :
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
reshape(Mix, [Nr, Nd]);

 % *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.
signal_fft = fft(Mix,Nr)/Nr;

 % *%TODO* :
% Take the absolute value of FFT output
signal_fft = abs(signal_fft);

 % *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
signal_fft = signal_fft(1:Nr/2+1);

%plotting the range
figure ('Name','Range from First FFT')

% *%TODO* :
% plot FFT output

% Sampling frequency
Fs = Nr/Tchirp;
% frequency axis
f = Fs*(0:(Nr/2))/Nr;
% Scale frequency to range
rangeAx = c*Tchirp*f/(2*B);

plot(rangeAx,signal_fft);
xlabel('range (m)');
ylabel('signal strength');
title('Range from 1st FFT');
axis ([0 200 0 1]);


%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM


% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure,surf(doppler_axis,range_axis,RDM);
xlabel('Doppler velocity (m/s)');
ylabel('range (m)');
title('2D FFT Range Doppler Response');
%% CFAR implementation

%Slide Window through the complete Range Doppler Map

% *%TODO* :
%Select the number of Training Cells in both the dimensions.
Tr = 5;
Td = 15;
% *%TODO* :
%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation
Gr = 1;
Gd = 5;
% *%TODO* :
% offset the threshold by SNR value in dB
offset=8;

% *%TODO* :
% Prepare a mask to extrack training cells
noise_mask = ones(2*Tr+2*Gr+1, 2*Td+2*Gd+1);
Cr = ceil(size(noise_mask,1)/2);
Cd = ceil(size(noise_mask,2)/2);
noise_mask(Cr-Gr:Cr+Gr, Cd-Gd:Cd+Gd) = 0;
% Convert noise mask to logical
noise_mask = logical(noise_mask);
% Preallocate for speed
threshold_cfar = zeros(size(RDM,1), size(RDM,2));
signal_cfar = zeros(size(RDM,1), size(RDM,2));

% *%TODO* :
%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.

for i = 1+Gr+Tr:(size(RDM,1)-(Gr+Tr))     
    for j = 1+Gd+Td:(size(RDM,2)-(Gd+Td))
        
        % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
        % CFAR
        % Average noise in window
        % Extract the cells of interest
        noise_values = RDM(i-Gr-Tr:i+Gr+Tr,j-Gd-Td:j+Gd+Td);
        % Extract the training cells
        noise_values = noise_values(noise_mask);
        % Convert to linear scale
        noise_values_lin = db2pow(noise_values);
        % Calculate average
        noise_average_lin = sum(sum(noise_values_lin))/(size(noise_values_lin,1)*size(noise_values_lin,2));
        % Convert to db
        noise_average_db = pow2db(noise_average_lin);
        % Add offset
        noiseThreshold = noise_average_db + offset;
        % Store current threshold in matrix
        threshold_cfar(i,j) = noiseThreshold;
        
        % Thresholding
        if (RDM(i,j) > noiseThreshold)
            signal_cfar(i,j) = 1;
        end
    end
end

% *%TODO* :
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.
figure,surf(doppler_axis,range_axis,signal_cfar);
xlabel('range (m)');
ylabel('signal strength');
title('2D CFAR Applied to range Doppler map');
colorbar;


 
 