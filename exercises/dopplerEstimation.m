%% Doppler estimation exercise
% Using the following MATLAB code sample, complete the TODOs to calculate thevelocity in m/s of four targets with following doppler frequency shifts: [3 KHz, 4.5 KHz, 11 KHz, -3 KHz].
% 
% You can use the following parameter values:
% 
% The radar's operating frequency = 77 GHz
% The speed of light c = 3*10^8

% Doppler Velocity Calculation
c = 3*10^8;         %speed of light
frequency = 77e9;   %frequency in Hz

% TODO : Calculate the wavelength
lambda = c/frequency;

% TODO : Define the doppler shifts in Hz using the information from above 
Fd = [3e3 ,4.5e3,11e3,-3e3];

% TODO : Calculate the velocity of the targets  fd = 2*vr/lambda
Vr = Fd*lambda/2;


% TODO: Display results
disp(Vr);