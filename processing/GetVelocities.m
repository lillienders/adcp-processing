%{
- Gets ENU velocities and puts the time series together
- Applies conversion to true north
- Saves each velocity component into a single file
- Plots some examples of velocities

Last Edit: June 15 2022
Set Up For: March 2018 Sig 500 Deployment (FORCE)
%}
%%
clear all
close all
clc
%%
minamp=30;
mincor=50;

% CHANGE - Path to QC Files
fpath = ['~/ADCP/MAR-18/QC/'];

% Initialize variables
u=[];
v=[];
w=[];
top_raw=[];
top_bin=[];
top_z=[];
v5=[];
timeall=[];
timeallV5=[];

% Load Data
for filenumber = 1:59 % Number of QC files (change for ADCP) 
    load([fpath 'MAR18_' int2str(filenumber) '_QC.mat']); % Update file extension ('MAR18_x')
    
    Data=Data2;
    clear Data2

    [Nt5 Nbin] = size(Data.IBurst_VelBeam5);
    [Nt Nbin] = size(Data.Burst_VelBeam1);
    z=Data.IBurst_Range;
    
    time=Data.Burst_MatlabTimeStamp;
    itime=Data.IBurst_MatlabTimeStamp;
    
    % Concatenate velocities
    u=[u; Data.Burst_VelEast];
    v=[v; Data.Burst_VelNorth];
    w=[w; Data.Burst_VelUp];
    top_raw=[top_raw,Data.Top_raw ];
    top_bin=[top_bin,Data.Top_bin];
    top_z=[top_z,Data.Top_z];
    timeall=[timeall; time];  
    timeallV5=[timeallV5; itime];
    clear time gtime
    filenumber;
end

% Convert to true north: Change to the right angle for deployment lat/lon
md=16.87; % Degrees west from north (From NOAA)

u_true=u.*cosd(md)-v.*sind(md);
v_true=v.*cosd(md)+u.*sind(md);

%Save velocity components in a single file
save('ueast_true.mat','u_true','-v7.3')
save('vnorth_true.mat','v_true','-v7.3')
save('wup.mat','w','-v7.3')
save('FreeSurface.mat','top_raw','top_bin','top_z','-v7.3')
save('top_bin.mat','top_bin','-v7.3')
save('top_z.mat','top_z','-v7.3')
save('time_all.mat','timeall','timeallV5','-v7.3')
%% Velocities: Conversion to True North (scatter)
figure(1)
plot(u(:,16),v(:,16),'.')
hold on
plot(u_true(:,16),v_true(:,16),'.')
hold off
axis([-6 6 -6 6])
ylabel('North Velocity (m/s)')
xlabel('East Velocity (m/s)')
legend('True')
set(gca,'FontSize',16)
%% Velocities: Corrected and Uncorrected
yd0=datenum(2018,0,0,0,0,1);
ydall=timeall-yd0+1;
figure(2)
clf
subplot(2,1,1)
plot(ydall,u_true(:,5),'.','MarkerSize', 8) 
yline(0,'k','LineWidth',6)
hold on
plot(yd,ueast,'.','MarkerSize', 10,'color','k') 
hold off
datetick('x')
ylabel('East Velocity (m/s)')
set(gca,'FontSize',16,'fontname','times')

subplot(2,1,2)
plot(ydall,v_true(:,5),'.','MarkerSize', 8) 
yline(0,'k','LineWidth',6)
hold on
plot(yd,vnorth,'k','LineWidth',2) 
hold off
datetick('x')
ylabel('North Velocity (m/s)')
set(gca,'FontSize',16,'fontname','times')

subplot(3,1,3)
plot(ydall,w(:,5),'.') 
%datetick('x')
ylabel('Up Velocity (m/s)')
xlabel('Year Day 2018')
set(gca,'FontSize',16,'fontname','times')

%% Velocities: Scatter of u and v (true)
figure(3)
clf
plot(u_true(:,16),v_true(:,16),'.')
ylabel('v (m/s)')
xlabel('u (m/s)')
set(gca,'FontSize',16,'fontname','times')
grid on