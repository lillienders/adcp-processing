%{
- Look at attitude parameters (check heading, pitch, roll) 
- Save ensembles of attitude parameters and free surface

Last Edit: June 15 2022
Set Up For: March 2018 Sig 500 Deployment
%}
%%
clear all
close all
clc
%%
% Path to ENU Files
fpath = ['~Desktop/ADCP/MAR-18/ENU/'];

fs = 2; %Sampling frequency in Hz

% Initialize variables to save
heading=[];
pitch=[];
roll=[];
timeall=[]; %One for the burst
timeallI=[]; %One for the IBurst
pressure=[];
power=[];
battery = [];
VelUp = [];
VelEast = [];
VelNorth = [];
TrueEast = [];
TrueNorth = [];

% Load Data
Nf = 15; % Number of files (.mat)
for filenumber=1:Nf
    load([fpath 'FAST_3_1' int2str(filenumber) '.mat']); 
    [Nt5 Nbin] = size(Data2.IBurst_VelBeam5);
    [Nt Nbin] = size(Data2.Burst_VelBeam1);
    z=Data2.IBurst_Range;
    
    time=Data2.Burst_MatlabTimeStamp;
    timeI=Data2.IBurst_MatlabTimeStamp;
    
    % Concatenating variables, check cat function if you want
    
    heading=[heading; Data2.Burst_Heading];    
    pitch=[pitch; Data2.Burst_Pitch];
    roll=[roll; Data2.Burst_Roll];
    power=[power; Data2.Burst_Battery];
    timeall=[timeall; time];    
    timeallI=[timeallI; timeI];    
    pressure=[pressure; Data2.Burst_Pressure];
    battery = [battery; Data2.Burst_Battery];
    VelUp = [VelUp; Data2.Burst_VelUp];
    VelEast = [VelEast; Data2.Burst_VelEast];
    VelNorth = [VelNorth; Data2.Burst_VelNorth];
    
    % Create vector w true north and true east 
    
    alpha = -16.89; % From NOAA
    TrueEast = VelEast*cos(alpha)+VelNorth*sin(alpha);
    TrueNorth = VelNorth*cos(alpha)-VelEast*sin(alpha);
end

%% Save Concatenated attitude params
savepath = ('~/Desktop/ADCP/MAR-18/DATA/');
save([savefile 'AttituteParametersFast.mat'],'heading','pitch','roll','battery','pressure','timeall','timeallI');
date=datevec(timeall);
day0=datenum(2018,01,01,0,0,0); %Change day to start date of deployment
yd=timeall-day0+1;
%% Figures using date (East/North Plots) 
figure(1)
scatter(VelEast,VelNorth)
ylabel('North Velocity')
xlabel('East Velocity')
ax=gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

figure(2)
scatter(TrueEast,TrueNorth)
ylabel('North Velocity')
xlabel('East Velocity')
ax=gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

figure(3)
subplot(3,1,1)
plot(yd,VelUp)
ylabel('Up Velocity')
set(gca,'FontSize',16)

subplot(3,1,2)
plot(yd,VelEast)
ylabel('East Velocity')
set(gca,'FontSize',16)

subplot(3,1,3)
plot(yd,VelNorth)
ylabel('North Velocity')
set(gca,'FontSize',16)
%% Figures for Attitude Params (Using Year Day)
figure(4)
plot(yd,battery)
ylabel('Battery')
xlabel('Year day 2018')
set(gca,'FontSize',20,'fontname','times')

figure(5)
subplot(3,1,1)
plot(yd,heading,'k','LineWidth',1.5)
ylabel('Heading (º)')
set(gca,'FontSize',16,'fontname','times')
subplot(3,1,2)
plot(yd,pitch,'k','LineWidth',1.5)
ylabel('Pitch (º)')
set(gca,'FontSize',16,'fontname','times')
subplot(3,1,3)
plot(yd,roll,'k','LineWidth',1.5)
ylabel('Roll (º)')
xlabel('Year day 2018')
set(gca,'FontSize',16,'fontname','times')

figure(6)
plot(yd,pressure*10^4/(1032*9.81),'.')
xlabel('Year day 2018')
ylabel('Pressure')
%% Stats on attitude parameters after deployment stabilizes
% Look on the plot when do the attitude parameter stabilize
% Sometimes the instrument goes underwater after it began measuring
% So some measurements occurred before it went in the water
% We can learn that from the attitude parameters
% Insert here that date
m9=datenum(2018,01,01,0,0,0);
gd=find(timeall>m9);

Heading_mean=mean(heading(gd),'omitnan');
Heading_std=std(heading(gd),'omitnan');
Pitch_mean=mean(pitch(gd),'omitnan');
Pitch_std=std(pitch(gd),'omitnan');
Roll_mean=mean(roll(gd),'omitnan');
Roll_std=std(roll(gd),'omitnan');

save('AttituteParametersFastStats.mat','Heading_mean','Heading_std','Pitch_mean','Pitch_std','Roll_mean','Roll_std') 
%% Create 5 min ensembles or 600 samples ensembles

fs=2; %Hz
MinEns=5;
dt=1/fs;
timeall_sec=(timeall-timeall(1))*3600*24;
Ens_sec=find(diff(timeall_sec)>100); % or Ens==find(diff(timeall)>1/24/60) %1 minute in days
Ens=find(diff(timeall)>1/24/60); % or 0.001 also works, I used plus 1 min
NEns=length(Ens); % How many ensembles
sizeens=diff(Ens);
index_1=zeros(NEns,1);
index_end=zeros(NEns,1);
index_1(1,1)=1;

for j = 1:length(Ens)-1
    index_end(j,1)=Ens(j);
    index_1(j+1,1)=Ens(j)+1;
    size_ens(j,1)=index_end(j,1)-index_1(j,1)+1; % Just to check the size
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
k = 1;
% Now for the data:
for j=1:NEns    
    % we can make things easier by considering only the 5 min ensembles
    if size_ens(j)==600 %Save data
         AttitudeEns.heading_ens(:,k)=heading(index_1(j,1):index_end(j,1));
         AttitudeEns.pitch_ens(:,k)=pitch(index_1(j,1):index_end(j,1));
         AttitudeEns.roll_ens(:,k)=roll(index_1(j,1):index_end(j,1));
         AttitudeEns.power_ens(:,k)=power(index_1(j,1):index_end(j,1));
         AttitudeEns.pressure_ens(:,k)=pressure(index_1(j,1):index_end(j,1));
         
         FreeSurface.top_bin_ens(:,k)=top_bin(index_1(j,1):index_end(j,1));
         FreeSurface.top_z_ens(:,k)=top_bin(index_1(j,1):index_end(j,1));
         FreeSurface.top_raw_ens(:,k)=top_bin(index_1(j,1):index_end(j,1));
         k=k+1;
    end
end

FreeSurface.time_ens=time_ens;
FreeSurface.time_ens_sec=time_ens_sec;
FreeSurface.time_ens_mean=mean(FreeSurface.time_ens,1,'omitnan');
FreeSurface.top_bin_mean=mean(FreeSurface.top_bin_ens,1,'omitnan');
FreeSurface.top_bin_std=std(FreeSurface.top_bin_ens,0,1,'omitnan');
FreeSurface.top_raw_mean=mean(FreeSurface.top_raw_ens,1,'omitnan');
FreeSurface.top_raw_std=std(FreeSurface.top_raw_ens,0,1,'omitnan');
FreeSurface.top_z_mean=mean(FreeSurface.top_z_ens,1,'omitnan');
FreeSurface.top_z_std=std(FreeSurface.top_z_ens,0,1,'omitnan');

AttitudeEns.heading_mean=mean(AttitudeEns.heading_ens);
AttitudeEns.pitch_mean=mean(AttitudeEns.pitch_ens);
AttitudeEns.roll_mean=mean(AttitudeEns.roll_ens);
AttitudeEns.time_ens = time_ens;
AttitudeEns.time_ens_mean=mean(time_ens);
%% Attitude Parameter Plots (Ensembles)
figure(7)
clf
subplot(3,1,1)
plot(yd,AttitudeEns.heading_mean)
ylabel('Heading (º)')
set(gca,'FontSize',16)

subplot(3,1,2)
plot(yd,AttitudeEns.pitch_mean)
ylabel('Pitch (º)')
set(gca,'FontSize',16)

subplot(3,1,3)
plot(yd,AttitudeEns.roll_mean)
ylabel('Roll (º)')
xlabel('Ensemble #')
set(gca,'FontSize',16)

%% Save the ensembles
save('~/Desktop/FreeSurfaceEnsembles.mat','FreeSurface')
save('~/Desktop/AttitudeEns.mat','AttitudeEns')

