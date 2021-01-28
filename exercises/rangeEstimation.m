%% Range Estimation Exercise
% Using the following MATLAB code sample, complete the TODOs to calculate the range in meters of four targets with respective measured beat frequencies [0 MHz, 1.1 MHz, 13 MHz, 24 MHz].
% 
% You can use the following parameter values:
% 
% The radar maximum range = 300m
% The range resolution = 1m
% The speed of light c = 3*10^8
% Note : The sweep time can be computed based on the time needed for the signal to travel the maximum range. In general, for an FMCW radar system, the sweep time should be at least 5 to 6 times the round trip time. This example uses a factor of 5.5:
% 
% T_chirp=5.5⋅2⋅Rmax/c

% Given
Rmax = 300;
Rres = 1;
c = 3*10^8;

% TODO : Find the Bsweep of chirp for 1 m resolution
Bsweep = c/(2*Rres);

% TODO : Calculate the chirp time based on the Radar's Max Range
Tchirp =5.5*2*Rmax/c;

% TODO : define the frequency shifts 
Fb = [0e6, 1.1e6 , 13e6 , 24e6 ];

% TODO: calculate the ranges
calculated_range = c*Tchirp*Fb/(2*Bsweep);

% Display the calculated range
disp(calculated_range);