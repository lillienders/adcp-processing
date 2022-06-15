%{
- Runs quality control, finds free-surface and removes data with low amplitude and low correlations.
- Uses the vertical beam amplitudes to find the free-surface. 

Last Edit: June 15 2022
Set Up For: March 2018 Sig 500 Deployment (FORCE)
%}
%%
clear all
close all
clc
%% Set Min Amp/Corr 
minamp=30;
mincor=50;
%% Location of files with ENU velocities and where to save the QC files
fpath = ['~/ADCP/MAR-18/ENU/']; % Folder containing ADCP files in ENU coordinates 
savepath = ['~/ADCP/MAR-18/QC/']; % Destination folder for ADCP QC files

% Loop through number of ENU files
for filenumber=1:59 % Number of ENU files (change for ADCP) 
    
    load([fpath 'MAR18_x' int2str(filenumber) '.mat']); % Update file extension ('MAR18_x')
    
    Data=Data2; % Sometimes saves as Data2 in ENU
    clear Data2
    
    [Nt5 Nbin] = size(Data.IBurst_VelBeam5);
    [Nt Nbin] = size(Data.Burst_VelBeam1);
    z=Data.IBurst_Range;
    time=Data.Burst_MatlabTimeStamp;
    date=datevec(time);
    
    %% Quick Look: Plot velocities
     figure(1)
     subplot(3,1,1)
     plot(Data.Burst_MatlabTimeStamp,Data.Burst_VelEast(:,10))
     datetick('x')
     ylabel('U (m/s)')
     set(gca,'FontSize',16,'fontname','times')
     
     subplot(3,1,2)
     plot(Data.Burst_MatlabTimeStamp,Data.Burst_VelNorth(:,10))
     datetick('x')
     ylabel('V (m/s)')
     set(gca,'FontSize',16,'fontname','times')
     
     subplot(3,1,3)
     plot(Data.IBurst_MatlabTimeStamp,Data.IBurst_VelBeam5(:,10))
     datetick('x')
     ylabel('W (m/s)') 
     set(gca,'FontSize',16,'fontname','times')
    %% Detect Free Surface Using Fifth Beam Amp
    figure(2)
    pcolor(Data.IBurst_MatlabTimeStamp, double(Data.IBurst_Range), double(Data.IBurst_AmpBeam5)'),
    shading flat
    datetick('x')
    ylabel(['Beam 5 Amp (dB)'])
    xlabel('Time')
    colorbar
    set(gca,'FontSize',16,'fontname','times')
        
    for j=1:Nt5
        A5_aux=Data.IBurst_AmpBeam5(j,32:43)'; 
        
        A5max(j)=max(A5_aux);
        max_i=find(A5_aux==A5max(j));
        if length(max_i)>1
            A5max_i(j)=max_i(1)+30;
        else
            A5max_i(j)=max_i+30;
        end
        Data.Top_raw(j)=Data.IBurst_Range(A5max_i(j));
        Data.Top_bin(j)=A5max_i(j);
        Data.Top_z(j)=Data.IBurst_Range(A5max_i(j));
    end
    %% Quality Control (Remove Low Amp & Corr) 
    
    c1=Data.Burst_CorBeam1;
    c2=Data.Burst_CorBeam2;
    c3=Data.Burst_CorBeam3;
    c4=Data.Burst_CorBeam4;
    c5=Data.IBurst_CorBeam5;
    
    a1=Data.Burst_AmpBeam1;
    a2=Data.Burst_AmpBeam2;
    a3=Data.Burst_AmpBeam3;
    a4=Data.Burst_AmpBeam4;
    a5=Data.IBurst_AmpBeam5;
    
    bad = find( c1 < mincor | c2 < mincor | c3 < mincor | c4 < mincor | ... %c5 < mincor |...
        a1 < minamp | a2 < minamp | a3 < minamp | a4 < minamp); %| a5 < minamp);
    bad5 = find( c5 < mincor | a5 < minamp);

    % Clean velocities only
    fields = fieldnames(Data);
    
    % Check which fields are velocities and set to NaN data with low
    % correlation and low amplitude

    % Here look at the fields variable to find which ones are velocities
    % (either ENU or along-beam) and change below for the "k" to change.
    
    for k=[124:1:129]
        
       S1=getfield(Data,fields{k});
       S1(bad)=NaN;
       Data=setfield(Data,fields{k},S1);
       clear S1
    end
  
    %% Save clean data, change name to the names you are already using!
    
    save([savepath 'MAR18_' int2str(filenumber) '_QC.mat'],'Data')
    
    clearvars -except fpath savepath mincor minamp filenumber
end