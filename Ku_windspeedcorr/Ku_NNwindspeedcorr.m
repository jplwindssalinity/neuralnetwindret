function [wind_speed,X]=Ku_NNwindspeedcorr(TbH,spdMLE,s0HHfore,s0HHaft,ctd,s0VVfore,s0VVaft,platform_name)
% function [wind_speed]=Ku_NNwindspeedcorr(TbH,spdMLE,s0HHfore,s0HHaft,ctd,s0VVfore,s0VVaft,platform_name)
% Routine that uses a neural network to correct Ku-band wind speeds for rain contamination 
% Currently works for QuikSCAT and ScatSAT1 platforms.
% The output wind_speed is the 10-m neutral equivalent wind speed in m/s.
% For quality control one can use the difference between the output and
% input (spdMLE) wind speeds based upon the assumption that a larger
% correction implies a less precise correction.
% Values of -9999 are used to denote invalid pixels in input or output
% arrays.
%
% Inputs
% TbH: an M by N array of H polarization brightness temperatures in Kelvin where M is the 
% cross track dimension and N is the along track dimension. 
%
% spdMLE: a coregistered M by N array of uncorrected MLE (max likelihod estimation)
% retrieved wind speeds in m/s.
% 
% s0HHfore: a coregistered M by N array of linear scale (unitless) HH-polarized fore-looking 
% normalized radar cross section (sigma0) values.
%
% s0HHaft: a coregistered M by N array of linear scale (unitless) HH-polarized aft-looking    
% normalized radar cross section (sigma0) values.
%
% ctd: a coregistered M by N or M by 1 array of cross track distance in km from
% the nadir track of the spacecraft. 
%
% s0VVfore: a coregistered M by N array of linear scale (unitless) VV-polarized fore-looking 
% normalized radar cross section (sigma0) values.
%
% s0VVaft: a coregistered M by N array of linear scale (unitless) VV-polarized aft-looking    
% normalized radar cross section (sigma0) values.
% platform_name: A string which must be either 'QuikSCAT' or 'SCATSAT1'



sz=size(spdMLE); % compute input array size
M=sz(1);
N=sz(2);


% check sizes of arrays 
if(size(TbH,1)~=M | size(TbH,2)~=N | ...
   size(s0HHfore,1)~=M | size(s0HHfore,2)~=N | ...
   size(s0HHaft,1)~=M | size(s0HHaft,2)~=N | ...
   size(s0VVfore,1)~=M | size(s0VVfore,2)~=N | ...
   size(s0VVaft,1)~=M | size(s0VVaft,2)~=N | ...
   size(ctd,1)~=M | (size(ctd,2)~=N & size(ctd,2)~=1))
   
   fprintf('Input Array Size Mismatch')
   wind_speed=[];
   return;
end   

% if ctd is a vector expand to an M by N array
if(size(ctd,2)==1)
    ctd=ctd*ones(1,N);
end

%%% Determine which pixels are valid
isgood=(TbH>-9000 & spdMLE>-9000 & s0HHfore>-9000 & s0HHaft>-9000 ...
    & s0VVfore>-9000 & s0VVaft>-9000 & ctd > -9000);

% if platform_name is QuikSCAT transform inputs to match SCATSAT1
if(strcmp('QuikSCAT',platform_name))
    load windspeedcorr_input_transform_QuikSCAT.mat x_tbh x_hhfore x_hhaft ...
        x_vvfore x_vvaft y_tbh y_hhfore y_hhaft y_vvfore y_vvaft;

    TbH(:)=interp1(x_tbh,y_tbh,TbH(:),'linear','extrap');
    s0HHfore(:)=interp1(x_hhfore,y_hhfore,s0HHfore(:),'linear','extrap');
    s0HHaft(:)=interp1(x_hhaft,y_hhaft,s0HHaft(:),'linear','extrap');
    s0VVfore(:)=interp1(x_vvfore,y_vvfore,s0VVfore(:),'linear','extrap');
    s0VVaft(:)=interp1(x_vvaft,y_vvaft,s0VVaft(:),'linear','extrap');

% if platform_name is SCATSAT1 transformation is not necessary
% but if it is any other platform fail because transformation is unknown
elseif(~strcmp('SCATSAT1',platform_name))
   fprintf('Platform_name %s is unknown', platform_name);
   fprintf('Valid platform names are SCATSAT1 or QuikSCAT. Case matters.');
   wind_speed=[];
   return;
end

%%% Construct neural network inputs array
X(:,1)=TbH(:);
X(:,2)=spdMLE(:);
X(:,3)=s0HHfore(:);
X(:,4)=s0HHaft(:);
X(:,5)=ctd(:);
X(:,6)=s0VVfore(:);
X(:,7)=s0VVaft(:);    


%%% Load neural network parameter file
%%% from MATLAB save file swot_windspeed_corr_net.mat
%%% (needs to be in MATLAB working directory)
load('scatsat1_windspeed_corr_net.mat', 'net');


%%% Apply neural network to compute wind speed
wind_speed=sim(net,X')';

%%% Reshape output of network to be the same size as input arrays 
wind_speed=reshape(wind_speed,sz);

%%% Undo correction for uncorrected wind speeds < 2 m/s.
ii=find(spdMLE<2);
wind_speed(ii)=spdMLE(ii);

% do linear combination of corrected and not corrected for uncorrected speeds from 2-3 m/s
i1=find(spdMLE>=2.0 & spdMLE<3.0);
w=3-spdMLE(i1);
wind_speed(i1)=w.*spdMLE(i1)+(1-w).*wind_speed(i1);

% set output to -9999 fill value for invalid inputs

wind_speed(find(~isgood))=-9999;

end

