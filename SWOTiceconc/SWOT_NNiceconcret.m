function [ice_conc]=SWOT_NNiceconcret(swotl2file,is_version_D_or_later)
% function [ice_conc]=SWOT_NNiceconcet(swotl2file,is_version_D_or_later)
% Routine that uses a neural network to retrieve autonomous SWOT ice
% concentration as a percentage for each 2-km pixel and output into the ice_conc array. 
%
% Inputs
% swotl2file: the name of a SWOT Level 2 Low Rate (Ocean) Expert file 
%  (e.g. SWOT_L2_LR_SSH_Expert_009_015_20240104T153441_20240104T162609_PIC0_01.nc) 
%
% 
% is_version_D_or_later: a Boolean which is true if the SWOT data is version D or later
%      the 'C' in the 'PIC0' tag in the above example SWOT filename indicates it is an earlier version for which the
%      boolean should be set to false.  
%      Currently an error message is returned if true, because of
%      complicated recalibration of the volumentric correlation data for version D


%%%----------- Read in data from SWOT file and put into input array
sigma0=ncread(swotl2file,'sig0_karin_2'); % read radar backscatter linear scale from SWOT file
sigma0=10*log10(abs(sigma0));  % convert backscatter to dB ignoring extremely rare negative cases
ctd=ncread(swotl2file,'cross_track_distance'); % read cross track distance form SWOT file
scalt=ncread(swotl2file,'sc_altitude'); % read spacecraft altitude from SWOT file
scalt=ones(69,1)*(scalt'); % the same scalt applies to every SWOT cross track bin
volcorr=ncread(swotl2file,'volumetric_correlation'); % read volumetric correlation from SWOT file

%%%------------Compute incidence angle
inc_corr=(ctd/40075000)*360;  
inc=asind(abs(ctd./scalt))+abs(inc_corr);

%%%------------ Undo version D absolute calibration to match neural network training data
%%%------------ if necessary
if(is_version_D_or_later)
   fprintf('Not yet implemented for version D or later')
   ice_conc=[];
   return;
end

sz=size(ctd); % compute input array size



%%% Construct neural network inputs array
X(:,1)=inc(:);
X(:,2)=sigma0(:);
X(:,3)=volcorr(:);
X(:,4)=compute_var2(sigma0(:),3);
X(:,5)=compute_var2(volcorr(:),3);


%%% Load neural network parameter file
%%% from MATLAB save file swot_windret_net_cyc007-011_s0IncSSTSWH_20240607.mat
%%% (needs to be in MATLAB working directory)
load('swot_ice_conc_net2_20240511.mat', 'net');


%%% Apply neural network to compute wind speed
ice_conc=sim(net,X')';

%%% Reshape output of network to be the same size as input arrays 
ice_conc=reshape(ice_conc,sz);

%%% Force value to be in range
ice_conc(find(ice_conc<0))=0;
ice_conc(find(ice_conc>100))=100;

end

