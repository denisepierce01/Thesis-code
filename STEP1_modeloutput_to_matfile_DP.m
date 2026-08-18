% HYDRODYNAMIC CALIBRATION STEP 1
% Process dfm/d3d output and save data as DFM.mat file

% Adapted from sediment transport capaciteiten

clear all; close all; clc;

%% Paths & settings 
load("P:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat");
% Folder of his file (not his file itself)
mainDir = 'P:\11207654-internship-pierce-2026\03_Model\13_T1bathy_T0groynes_Apr18';
dirs = dir(mainDir);
% dirs = dirs([10]); 

% % Specify folder of _his.nc file
% for ii = 1:length(dirs)
%     folders{ii} = [dirs(ii).folder filesep dirs(ii).name '\output\'];
% end
% 
% for ii = 1:length(folders)
%     outputFolder = [folders{ii} '\output\'];
%     % matFile = [outputFolder 'Udir.mat'];
%     hisFiles = dir([outputFolder '*_his.nc']);
% end

outputFolder = fullfile(mainDir, 'output', filesep);
folders = {outputFolder};

% (Optional) verify the expected his file exists, else warn
hisPath = fullfile(folders{1}, 'WS_0000_his.nc');
if ~isfile(hisPath)
    warning('Expected his file not found: %s', hisPath);
end

% Start and end time of simulation
t0 = '22-Apr-2018';
tend = '23-May-2018';

%% Stations and cross-sections to read

% Channel stations
nr_channel = [34:154]; % specify which channel stations to read
stations_ch = {};
for ii = 1:length(nr_channel)
    if nr_channel(ii) < 100
        stations_ch{ii} = ['Channel_0' num2str(nr_channel(ii))];
    else
        stations_ch{ii} = ['Channel_' num2str(nr_channel(ii))];
    end
end

% Waterlevel stations
stations_wl = {'MP0 - Wandelaar', 'MP3 - Bol van Heist', 'MP4 - Scheur Wielingen', ...
    'VR - Vlakte van de Raan', 'WKAP','CADZ', 'VLIS', 'BRES', 'TERN', 'OVHA', 'HANS', ...
    'WALS', 'BAAL','SVDN', 'BATH','Prosperpolder','LIEF','Antwerpen','Oosterweel-Boven'};
stations_wl_longnames = {'Wandelaar', 'Bol van Heist', 'Scheur Wielingen', ...
    'Vlakte van de Raan', 'Westkapelle','Cadzand', 'Vlissingen', 'Breskens', 'Terneuzen', 'Overloop van Hansweert', 'Hansweert', ...
    'Walsoorden', 'Baalhoek','Schaar van de Noord', 'Bath','Prosperpolder','Liefkenshoek','Antwerpen','Oosterweel-Boven'};

% Velocity stations BathOssZimm
load('P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
% Names of measurement stations
idx_load = find(~strcmp({S(:).name}, 'Boat'));
stations_vel = cell(size(idx_load));
for ii = 1:length(idx_load)
    stations_vel{ii} = [S(idx_load(ii)).area '_' S(idx_load(ii)).t '_' S(idx_load(ii)).name];
end

% Sigma layer information
sigma_layers = [2 3 5 8 10 12 15 15 15 15];
zCCperc = sigma_layers/2 + [0 cumsum(sigma_layers(1:end-1))];

%% Load model data and store as .mat file

for ii = 1:length(folders)

    his_file = dir([folders{ii} '*_his.nc']);

    % Water level channel
    data = EHY_getmodeldata([folders{ii} his_file(1).name], stations_ch,'dfm','varName','waterlevel','t0', t0, 'tend', tend);
    for st = 1:length(stations_ch)
        DFM.wl_channel(st).station_name = data.requestedStations{st};
        DFM.wl_channel(st).time = datetime(data.times,'ConvertFrom','datenum');
        DFM.wl_channel(st).val = data.val(:,st);
        DFM.wl_channel(st).RDx = data.location(st,1);
        DFM.wl_channel(st).RDy = data.location(st,2);
    end

    % Water level observation stations
    data = EHY_getmodeldata([folders{ii}  his_file(1).name], stations_wl,'dfm','varName','waterlevel','t0', t0, 'tend', tend);
    for st = 1:length(stations_wl)
        DFM.wl(st).station_name = data.requestedStations{st};
        DFM.wl(st).station_longname = stations_wl_longnames{st};
        DFM.wl(st).time = datetime(data.times,'ConvertFrom','datenum');
        DFM.wl(st).val = data.val(:,st);
        [DFM.wl(st).TIDESTRUC, DFM.wl(st).val_astro] = t_tide(DFM.wl(st).val, 'interval', 10/60, 'start time', datenum(t0), 'latitude', 52, 'error', 'wboot');
        DFM.wl(st).RDx = data.location(st,1);
        DFM.wl(st).RDy = data.location(st,2);
    end
    
    % Velocity stations BathOssZimm
    UV = EHY_getmodeldata([folders{ii} his_file(1).name], stations_vel, 'dfm', 'varName', 'uv', 't0', t0, 'tend', tend);
    BL = EHY_getmodeldata([folders{ii} his_file(1).name], stations_vel, 'dfm', 'varName', 'bl');
    WL = EHY_getmodeldata([folders{ii} his_file(1).name], stations_vel, 'dfm', 'varName', 'wl', 't0', t0, 'tend', tend);
    for st = 1:length(stations_vel)
        DFM.vel(st).station_name = UV.requestedStations{st};
        DFM.vel(st).station_longname = UV.requestedStations{st};
        DFM.vel(st).time = datetime(UV.times,'ConvertFrom','datenum');
        DFM.vel(st).vel_x = UV.vel_x(:,st,:);
        DFM.vel(st).vel_y = UV.vel_y(:,st,:);
        DFM.vel(st).vel_mag = UV.vel_mag(:,st,:);
        DFM.vel(st).vel_dir = UV.vel_dir(:,st,:);
        DFM.vel(st).wl = WL.val(:,st);
        DFM.vel(st).bl = BL.val(st);
        DFM.vel(st).zCC = BL.val(st) + zCCperc./100.*(WL.val(:,st) - BL.val(st));
        DFM.vel(st).RDx = WL.location(st,1);
        DFM.vel(st).RDy = WL.location(st,2);
    end

    % Store as .mat file
    save([folders{ii} 'DFM.mat'], "DFM")
    disp(['Finished run ' num2str(ii) ' of ' num2str(length(folders))])
end
