%{
- Take a quick look at the data, no real processing

Last Edit: June 15 2022
Set Up For: March 2018 Sig 500 Deployment
%}
%%
clear all
close all
clc
%%
% Path to raw data
fpath = '~/Desktop/ADCP/MAR-18/Raw-Data/'; % Folder containing ADCP files in ENU coordinates 

% Save Files
prefix = ['MAR18']; %Sequential name of files
savepath = ['~/ADCP/MAR-18/ENU/'];

%% Raw Data
% Modify based on format of files - if there are multiple files, we run a cycle
k=1; 
for ad2cpN=7:7 %1-7 how the ADCP stores the data
    for fnumber =1:13 %1-17 from splitting up ADCP files into .mat
        fname = ['MAR18_' int2str(ad2cpN) '.mat'];
        load([ fpath '/' fname ])
        
        % Plot time series of along-beam velocity
        % Estimate year day for plots
        dates=datevec(Data.Burst_MatlabTimeStamp);
        yM=dates(1,1);
        day0=datenum(yM,1,1,0,0,0);
        yd=Data.Burst_MatlabTimeStamp-day0+1;
        ydI=Data.IBurst_MatlabTimeStamp-day0+1;
        
        figure(1)
        for i = 1:4
            ax(i) = subplot(5,1,i);
            set(gca,'FontSize',16)
            pcolor(yd, double(Data.Burst_Range), double(eval(['Data.Burst_VelBeam' num2str(i)]))' ),
            shading flat
            
            ylabel('z (m)')
            cb=colorbar;
            ylabel(cb,['Vel Beam ' num2str(i)])
            caxis([-0.5 0.5])   
        end
        
        ax(5) = subplot(5,1,5);
        set(gca,'FontSize',16)
        pcolor(ydI, double(Data.IBurst_Range), double(Data.IBurst_VelBeam5)' ),
        shading flat,
        hold on
        plot(ydI,Data.IBurst_Pressure,'k')
        hold off
        caxis([-0.2 0.2])
        cb=colorbar;
        ylabel(cb,['Vel Beam 5'])
        xlabel('Year day')
        
        % Check Amplitudes
        figure(2)
        
        for i = 1:4
            
            ax(i) = subplot(5,1,i);
            set(gca,'FontSize',16)
            pcolor(yd, double(Data.Burst_Range), double(eval(['Data.Burst_AmpBeam' num2str(i)]))' ),
            shading flat
            cb=colorbar;
            ylabel(cb,['Amp. Beam ' num2str(i)])
            %       set(gca,'FontSize',16)
        end
        
        ax(5) = subplot(5,1,5);
        
        pcolor(ydI, double(Data.IBurst_Range), double(Data.IBurst_AmpBeam5)' ),
        shading flat
        cb=colorbar;
        ylabel(cb,['Amp. Beam 5'])
        ylabel('z (m)')
        xlabel('Year day')
        
        %% Convert to ENU coordinates
        % Need to add this to the Config structure if data were exported using Sig
        
        Config.BeamCfg1_theta=25;
        Config.BeamCfg2_theta=25;
        Config.BeamCfg3_theta=25;
        Config.BeamCfg4_theta=25;
        
        
        Config.BeamCfg1_phi=0;
        Config.BeamCfg2_phi=-90;
        Config.BeamCfg3_phi=180;
        Config.BeamCfg4_phi=90;
        
        Config.BeamCfg5_theta=0;
        Config.BeamCfg5_phi=0;
        
        % Run Nortek code to convert to XYZ, and ENU velocities
        [ Data2, Config2, T_beam2xyz ]=signatureAD2CP_beam2xyz_enu(Data,Config,'burst');
        
        % Save data with ENU coordinates
        savefile=[savepath '/' prefix int2str(ad2cpN) '.mat'];
        save(savefile, '-mat', 'Data2');
        
        
        %% ENU Data
        
        figure(3)
        ax(1) = subplot(3,1,1);
        
        pcolor(yd, double(Data2.Burst_Range), double(Data2.Burst_VelEast)' ),
        hold on
        plot(yd,Data.Burst_Pressure,'k')
        hold off
        shading flat,
        ylabel('z (m)')
        caxis([-1 1])
        cb=colorbar;
        ylabel(cb,['Vel East'])
        
        ax(2) = subplot(3,1,2);
        pcolor(yd, double(Data2.Burst_Range), double(Data2.Burst_VelNorth)' ),
        shading flat,
        hold on
        plot(yd,Data.Burst_Pressure,'k')
        hold off
        ylabel('z (m)')
        caxis([-3 3])
        cb=colorbar;
        ylabel(cb,['Vel North'])
        
        ax(3) = subplot(3,1,3);
        pcolor(yd, double(Data2.Burst_Range), double(Data2.Burst_VelUp)' ),
        shading flat
        hold on
        plot(yd,Data.Burst_Pressure,'k')
        hold off
        caxis([-0.1 0.1])
        cb=colorbar;
        ylabel(cb,['Vel Up'])
        
    end
end




