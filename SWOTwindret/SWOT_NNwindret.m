function [wind_speed]=SWOT_NNwindret(swotl2file,sst,is_version_D_or_later)
% function [wind_speed]=SWOT_NNwindret(swotl2file,sst,is_version_D_or_later)
% Routine that uses a neural network to retrieve SWOT wind speeds in m/s 
% corrected for SST for each 2-km SWOT pixel and output them into the wind_speed array. 
% For quality control use the flags that came with your source of SST and the 
% wind_speed_karin_2_qual flag in the SWOT data product.
% The output ice concentration values are primarily useful as a flag.
% Values above 50% are almost certainly ice contaminated.
% Values less than 10% are unlikely to be significantly ice contaminated.
% Latitude and SST were not used to create the flag, so erroneous
% concentrations greater than 0 can and do occur in lower latitudes where
% sea ice is not possible. 
%
% Inputs
% swotl2file: the name of a SWOT Level 2 Low Rate (Ocean) Expert file 
%  (e.g. SWOT_L2_LR_SSH_Expert_009_015_20240104T153441_20240104T162609_PIC0_01.nc) 
%
% sst: an array of sea surface temperatures in degrees Celsius that has been coregistered with the SWOT 2-km swath
% 
% is_version_D_or_later: a Boolean which is true if the SWOT data is version D or later
%      the 'C' in the 'PIC0' tag in the above example SWOT filename indicates it is an earlier version for which the
%      boolean should be set to false.   
%  


%%%----------- Read in data from SWOT file and put into input array
sigma0=ncread(swotl2file,'sig0_karin_2'); % read radar backscatter linear scale from SWOT file
sigma0=10*log10(abs(sigma0));  % convert backscatter to dB ignoring extremely rare negative cases
ctd=ncread(swotl2file,'cross_track_distance'); % read cross track distance form SWOT file
scalt=ncread(swotl2file,'sc_altitude'); % read spacecraft altitude from SWOT file
scalt=ones(69,1)*(scalt'); % the same scalt applies to every SWT cross track bin
swh=ncread(swotl2file,'swh_model'); % read significant wave height from SWT file

%%%------------Compute incidence angle
inc_corr=(ctd/40075000)*360;  
inc=asind(abs(ctd./scalt))+abs(inc_corr);

%%%------------ Undo version D absolute calibration to match neural network training data
%%%------------ if necessary
if(is_version_D_or_later)
sigma0=sigma0+2.5;
end

sz=size(ctd); % compute input array size



%%% Construct neural network inputs array
X(:,1)=sigma0(:);
X(:,2)=inc(:);
X(:,3)=swh(:);
X(:,4)=sst(:);

%%% Load neural network parameter file
%%% from MATLAB save file swot_windret_net_cyc007-011_s0IncSSTSWH_20240607.mat
%%% (needs to be in MATLAB working directory)
load('swot_windret_net_cyc007-011_s0IncSSTSWH_20240607.mat', 'net');


%%% Apply neural network to compute wind speed
wind_speed=sim(net,X')';

%%% Reshape output of network to be the same size as input arrays 
wind_speed=reshape(wind_speed,sz);

end

