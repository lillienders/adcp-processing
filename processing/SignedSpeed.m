%{ 
- Short code that gets the true east and north velocities produced by the 
  above code and estimates a signed speed using Brian Polagye’s code for principal direction.
- Saves the signed speed and direction.

Last Edit: Oct 12 2021
Set Up For: March 2018 Sig 500 Deployment (FORCE)
Dependencies: sign_speed.m, dir_PrincipalAxis.m, principalaxis.m
%}
%%
clc
clear all
close all
%%
% Path to QC files
fpath = ['~/Desktop/ADCP/MAR-18/QC/']; %Sequential name of files

% Load Data (only time and one velocity component)
filenumber=1;
load([fpath 'MAR18_' int2str(filenumber) '_QC.mat']);
z=Data.IBurst_Range;
Nz=length(z);
%%
% Load time
load('~/Desktop/ADCP/MAR-18/DATA/Concatenated/time_all.mat')
% Load true east and true north velocities
load('~/Desktop/ADCP/MAR-18/DATA/Concatenated/ueast_true.mat')
load('~/Desktop/ADCP/MAR-18/DATA/Concatenated/vnorth_true.mat')
%%
date=datevec(timeall);
day0=datenum(2018,0,0,0,0,0);
yd=timeall-day0+1;
%% Principal Direction and signed_speed
s=sqrt(u_true.^2+v_true.^2);
d=atan2(u_true,v_true)*180/pi;
flood_heading=90; % Here add a more or less flood heading
flood_heading = flood_heading + [-90, +90];

[s_signed] = sign_speed(u_true, v_true, s, d, flood_heading);
[PA_fld, PA_ebb, PA_all, d_PA] = dir_PrincipalAxis(d, s_signed, 0.1, u_true, v_true);
[PA, varxp_PA] = principal_axis(u_true,v_true);

%% Calculate along/across stream velocities (be careful about angle) 
along=u_true.*cosd(PA)-v_true.*sind(PA);
across=v_true.*cosd(PA)+u_true.*sind(PA);
%% Plot along and across stream velocities
figure(1)
subplot(2,1,1)
plot(yd,along(:,20),'k','LineWidth',1);
ylabel('Along Stream Velocity (m/s)')
xlim([-15 50])
ylim([-8 8])
set(gca,'FontSize',20,'fontname','times')
set(gcf,'PaperPositionMode','auto')

subplot(2,1,2)
plot(yd,across(:,20),'r','LineWidth',1);
ylabel('Across Stream Velocity (m/s)')
xlabel('Year Day 2018')
xlim([-15 50])
ylim([-8 8])
set(gca,'FontSize',20,'fontname','times')
set(gcf,'PaperPositionMode','auto')
%% Save Signed Speed, Along and Across Stream Velocities, and Principal Direction/Axis
save('s_signed_sigma.mat','s_signed','-v7.3')
save('Principal_direction.mat','PA_fld', 'PA_ebb', 'PA_all')
save('principal_axis.mat','PA', 'varxp_PA')
save('along_stream.mat','along','-v7.3')
save('across_stream.mat','across','-v7.3')