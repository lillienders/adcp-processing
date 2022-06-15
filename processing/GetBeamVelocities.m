%{
- Gets along-beam velocities and puts the time series together
- Saves each beam velocity into a single file
- Plots some examples of velocities 

Last Edit: June 15 2022
Set Up For: March 2018 Sig 500 Deployment
%}
%%
clear all
close all
clc
%%
minamp=30;
mincor=50;

% Path to QC Files
fpath = ['~/Desktop/ADCP/MAR-18/QC/'];
fs=2; % Sampling frequency in Hz

% Initialize variables to save
v1=[];
v2=[];
v3=[];
v4=[];
v5=[];
v1Amp=[]; 
v1Cor=[];
v2Amp=[]; 
v2Cor=[];
v3Amp=[]; 
v3Cor=[];
v4Amp=[]; 
v4Cor=[];
v5Amp=[];  
v5Cor=[];  
timeall=[];
timeallV5=[];

% Load Data
for filenumber=1:59 %Change file numbers and names

    load([fpath 'MAR18_' int2str(filenumber) '_QC.mat']);
    
    [Nt5 Nbin] = size(Data.IBurst_VelBeam5);
    [Nt Nbin] = size(Data.Burst_VelBeam1);
    z=Data.IBurst_Range;
    
    time=Data.Burst_MatlabTimeStamp;    
    timeI=Data.IBurst_MatlabTimeStamp;
    tend=Data.Burst_MatlabTimeStamp(end);
    
    v1=[v1; Data.Burst_VelBeam1];
    v2=[v2; Data.Burst_VelBeam2];
    v3=[v3; Data.Burst_VelBeam3];
    v4=[v4; Data.Burst_VelBeam4];
    v1Amp=[v1Amp; Data.Burst_AmpBeam1];  
    v1Cor=[v1Cor; Data.Burst_CorBeam1]; 
    v2Amp=[v2Amp; Data.Burst_AmpBeam2];  
    v2Cor=[v2Cor; Data.Burst_CorBeam2];
    v3Amp=[v3Amp; Data.Burst_AmpBeam3];  
    v3Cor=[v3Cor; Data.Burst_CorBeam3];
    v4Amp=[v4Amp; Data.Burst_AmpBeam4];  
    v4Cor=[v4Cor; Data.Burst_CorBeam4];  
    
    timeall=[timeall; time];
    
    v5=[v5; Data.IBurst_VelBeam5];
    v5Amp=[v5Amp; Data.IBurst_AmpBeam5];  
    v5Cor=[v5Cor; Data.IBurst_CorBeam5];  
    timeallV5=[timeallV5; timeI];
    
    clear time;
    filenumber;
end

% Save velocities in a single file
save('v1.mat','v1','-v7.3')
save('v2.mat','v2','-v7.3')
save('v3.mat','v3','-v7.3')
save('v4.mat','v4','-v7.3')
save('v5.mat','v5','-v7.3')
save('v1Amp.mat','v1Amp','-v7.3')
save('v1Cor.mat','v1Cor','-v7.3')
save('v2Amp.mat','v2Amp','-v7.3')
save('v2Cor.mat','v2Cor','-v7.3')
save('v3Amp.mat','v3Amp','-v7.3')
save('v3Cor.mat','v3Cor','-v7.3')
save('v4Amp.mat','v4Amp','-v7.3')
save('v4Cor.mat','v4Cor','-v7.3')
save('v5Amp.mat','v5Amp','-v7.3')
save('v5Cor.mat','v5Cor','-v7.3')

%% Velocity Plots
figure(1)
subplot(3,1,1)
plot(timeall,v1(:,5)) 
datetick('x')
ylabel('V1 (m/s)')
subplot(3,1,2)
plot(timeall,v3(:,5)) 
datetick('x')
ylabel('V2 (m/s)')

subplot(3,1,3)
plot(timeallV5,v5(:,5)) 
datetick('x')
ylabel('V5 (m/s)')
    
figure(2)
pcolor(timeall, z, (u_true)' ), 
shading flat,
datetick('x','keepticks')
ylabel(['u (ms^{-1})'])
colorbar
caxis([-3 3])
set(gca,'FontSize',16)

figure(3)
pcolor(timeall, z, (v_true)' ), 
shading flat,
datetick('x','keepticks')
ylabel(['v (ms^{-1})'])
colorbar
caxis([-2 2])
set(gca,'FontSize',16)


figure(4)
pcolor(timeall, z, (w)' ), 
shading flat,
datetick('x','keepticks')
ylabel(['w (ms^{-1})'])
colorbar
caxis([-1 1])
set(gca,'FontSize',16)

figure(5)
pcolor(timeallV5, z, (v5)' ), 
shading flat,
datetick('x','keepticks')
ylabel(['v5 (ms^{-1})'])
colorbar
caxis([-1 1])
set(gca,'FontSize',16)
 
