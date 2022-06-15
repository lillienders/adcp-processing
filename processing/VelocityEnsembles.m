%{
- Ensemble averages and variances
- Do for true u,v,w, and along/across stream velocities (one at a time)
- Get data for each bin, and construct 5 minute ensembles

Last Edit: June 15 2022
Set Up For: March 2018 Sig 500 Deployment (FORCE)
%}
%%
clear all
close all
clc
%%
fs = 2; % Sampling frequency in Hz
noise = 0.1421; % Beam precision in m/s
noisevar=noise^2; 
%%
fpath = ['/Users/lillienders/Desktop/ADCP/MAR-18/QC/']; %Sequential name of files

% Load Data
% Load only time and velocity component
filenumber=1;
load([fpath 'MAR18_' int2str(filenumber) '_QC.mat']);
z=Data.IBurst_Range;
Nz=length(z);

%%
Beam5=0; %Process beam 5
load('/Users/lillienders/Desktop/along_stream.mat')
load('/Users/lillienders/Desktop/ADCP/MAR-18/DATA/Concatenated/time_all.mat') % Load time
vel=along; %Change to the name of the variable accoringly: ueast_true.mat has u_true, v1.mat has v1, etc.

if Beam5==1
    time=timeallV5;
else
    time=timeall;
end

savefile=['~/Desktop/ADCP/MAR-18/DATA/Ensembles/along_ens.mat']; % Save file (change to variable of interest

%% Create 5 min ensembles or 1200 samples ensembles

fs=2; %Hz
MinEns=5;
dt=1/fs;

timeall_sec=(timeall-timeall(1))*3600*24;

Ens_sec=find(diff(timeall_sec)>100); % or Ens==find(diff(timeall)>1/24/60) %1 minute in days
Ens=find(diff(timeall)>1/24/60); % or 0.001 also works, I used plus 1 min

NEns=length(Ens); % How many ensembles

sizeens=diff(Ens); %Size of each ensembles

index_1=zeros(NEns,1);
index_end=zeros(NEns,1);
index_1(1,1)=1;

for j = 1:length(Ens)-1
    index_end(j,1)=Ens(j);
    index_1(j+1,1)=Ens(j)+1;
    size_ens(j,1)=index_end(j,1)-index_1(j,1)+1; 
end

lastEnssize=length(timeall)-index_end(end);
index_end(NEns,1)=length(timeall);
size_ens(NEns,1)=index_end(NEns,1)-index_1(NEns,1)+1;

k=1;
for j=1:NEns
    % we can make things easier by considering only the 5 min ensembles
    if size_ens(j)==600 %Save data
        time_ens(:,k)=timeall(index_1(j,1):index_end(j,1));
        k=k+1;
    end
end

GEns=size(time_ens,2); %How many good ensembles are there?
for j=1:GEns
    time_ens_sec(:,j)=(time_ens(:,j)-time_ens(1,j))*3600*24;
end
 
% Now for the data:
k=1;
for j=1:NEns  
    if size_ens(j)==600 %Save data
        vel_ens=vel(index_1(j,1):index_end(j,1),:); %Here I grab all z values to make it faster
        vel_mean(k,:)=mean(vel_ens,1,'omitnan');
        vel_var(k,:)=var(vel_ens,1,1,'omitnan');        
        vel_skew(k,:) = (sum((vel_ens-vel_mean(k,:)).^3)./1200)./(vel_var(k,:).^1.5);
        vel_kurt(k,:) = (sum((vel_ens-vel_mean(k,:)).^4)./1200)./(vel_var(k,:).^2);
        vel_std(k,:)=std(vel_ens,1,1,'omitnan');
        k=k+1;
    end
end

for k=1:Nz
    Profile(k).time_ens=time_ens;
    Profile(k).time_ens_sec=time_ens_sec;
    Profile(k).time_ens_mean=mean(time_ens,1,'omitnan');
    Profile(k).vel_mean=vel_mean(:,k);
    Profile(k).vel_var=vel_var(:,k);
    Profile(k).vel_std=vel_std(:,k);
    Profile(k).vel_var=vel_skew(:,k);
    Profile(k).vel_std=vel_kurt(:,k);
end
%%
save(savefile,'Profile','-v7.3')