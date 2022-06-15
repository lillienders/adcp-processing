function [yd_sigma,u_sigma,u_std,sigma_norm] = to_sigma(path_to_fs,path_to_QC,yd,u_depth)
%to_sigma: takes in ensemble data in depth coordinates and converts in to
%normalized terrain following (sigma) coordinates. Currently set up to
%interpolate data to 40 sigma layers

%inputs: path_to_fs - path to file containing a measurement of free surface (from
%vertical beam or from pressure), path to quality control file which must have a 
%measurement of ADCP range (z), yd (or other measure of time), velocity data in depth
%coordinates

%outputs: yd in sigma coordinates (yd_sigma), velocity in sigma coordinates
%(u_sigma), standard deviation in sigma coordinates (u_std), sigma layer
%coordinates (sigma_norm)
%%
load(path_to_fs);
load(path_to_QC);
Nz= 45;
z=Data.IBurst_Range;
z=z(1:Nz)';
%% Convert free surface from pressure to height
P = FreeSurface.top_z_mean;
rho = 1030; % kg/m3
g = 9.81; %m/s2
h = 100*P/rho*g; %m - water height
h_ADCP = 0.5; %m - height of ADCP from seabed (from metadata)
d = h + h_ADCP; %m - total water depth (function of t)
Nens = length(d);
%% Flip coords from top down
gamma = zeros(Nz,Nens);
sigma = zeros(Nz,Nens); 
for k=1:Nens
    for j=1:Nz
    gamma(j,k) = d(1,k)-z(j,1);
    sigma(j,k) = -gamma(j,k)/d(1,k);
    end
end
%% Interpolate to sigma layers
num_layers = 39; 
yd_sigma = yd(1:(num_layers+1),:);
dsigma = d/(num_layers);
sigma_layers = zeros(num_layers+1,Nens);
sigma_norm = zeros(num_layers+1,Nens);
u_sigma = zeros(num_layers+1,Nens);
u_std = zeros(num_layers+1,Nens);
for k = 1:Nens
    sigma_layers(:,k) = [0:dsigma(k):d(k)]';
    sigma_norm(:,k) = sigma_layers(:,k)/d(1,k);
    if sum(isnan(u_depth))== Nz
        u_sigma(:,1) = u_depth;
    end
 u_sigma(:,k) = interp1(gamma(:,k),u_depth(:,k),sigma_layers(:,k),'linear');
end
end