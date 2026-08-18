clear all
close all
clc

% getting FOU data from D3D-FM fou file
% D. Pierce

%% folders
folders = { ...
     'P:\11207654-internship-pierce-2026\03_Model\15_T0_fou_Apr18\output\',...
    'P:\11207654-internship-pierce-2026\03_Model\16_T1_fou_Apr18\output\';
};
name = {
        'FOU_T0'; 
        'FOU_T1'
};

sigma_layers = [2 3 5 8 10 12 15 15 15 15];
zCCperc = sigma_layers/2 + [0 cumsum(sigma_layers(1:end-1))];

%% map file- & fou file
for k = 1:numel(folders)
    clear DataU DataV gridInfo; 

    currentFolder = folders{k}; % Code clarity helper
    mapFile = fullfile(currentFolder, 'WS_0000_map.nc');

    % select time
    t0 = '22-Apr-2018';
    tend = '24-Apr-2018'; 

    % load grid info (XY coordinates) 
    if isfile(mapFile)
        gridInfo = EHY_getGridInfo(mapFile, {'face_nodes_xy'});
    end

    % load velocity residuals (layer 0 = depth-averaged / residual)
    fouFile = fullfile(currentFolder, 'WS_0000_fou.nc'); 
    % if ~isfile(fouFile)
    %     % try to find any _fou.nc
    %     ncList = dir(fullfile(currentFolder, '*fou*.nc')); 
    %     if isempty(ncList)
    %         warning('No fou file found in %s. Skipping velocities.', currentFolder);
    %         DataU = []; DataV = [];
    %     else
    %         fouFile = fullfile(currentFolder, ncList(1).name);
    %     end
    % end

    % Load data if file exists
    if isfile(fouFile)
        Tbelow06 = EHY_getMapModelData(fouFile, 'varName', 'mesh2d_time_018_below', 't0', t0, 'tend', tend, 'layer', '0');
        maxvel = EHY_getMapModelData(fouFile, 'varName', 'mesh2d_fourier005_max', 't0', t0, 'tend', tend, 'layer', '0');
    end

    % prepare output struct and save
    out = struct(); % Reset struct every iteration
    out.gridInfo = gridInfo;
    out.sigma_layers = sigma_layers;
    if exist('Tbelow06','var') && ~isempty(Tbelow06); out.Tbelow06 = Tbelow06; end
    if exist('maxvel','var') && ~isempty(maxvel); out.maxvel = maxvel; end

    % FIX: Changed 'names(k)' to 'name{k}' and altered '%g' to '%s'
    nameVal = name{k}; 
    matName = sprintf('%s.mat', nameVal); 

    try
        save(matName, '-struct', 'out');
        fprintf('Successfully saved: %s\n', matName);
    catch ME
        warning('Failed to save %s: %s', matName, ME.message);
    end
end

%% plot bottom leyer (1) of maxvel 
% Extract the bottom layer of maxvel for plotting
bottomLayerMaxVel = maxvel(:, :, 1); 

% Create a figure for the plot
figure;
plot(bottomLayerMaxVel);
xlabel('Index');
ylabel('Max Velocity (m/s)');
title(sprintf('Max Velocity at Bottom Layer for %s', nameVal));
grid on;