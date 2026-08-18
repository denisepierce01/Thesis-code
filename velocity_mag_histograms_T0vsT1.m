% Compare T0 and T1 ADCP observations of velocity in space and time (DEPTH_AVG)
% D. Pierce

clear all
close all
clc

%% Load measurement data
load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')

%% get Zbed from ADCPs
% Load  data 
siteFields = fieldnames(ADCP.BATH.T0);
% Exclude non-station fields if any (assume station fields contain 'MP' or similar)
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
nStations = length(stationNames);

% Preallocate cell arrays to hold magnitude
z0 = cell(size(stationNames));
z1 = cell(size(stationNames));

for k = 1:nStations
    s = stationNames{k};

    % --- Process T0 ---
    if isfield(ADCP.BATH.T0, s) && isfield(ADCP.BATH.T0.(s).META, 'ZBED')
       tempData0 = ADCP.BATH.T0.(s).META;
       % Remove NaNs: "Keep tempData0 where it is NOT NaN"
       z0{k} = tempData0(~isnan(tempData0));
    end

    % --- Process T1 ---
    if isfield(ADCP.BATH.T1, s) && isfield(ADCP.BATH.T1.(s).META, 'ZBED')
        tempData1 = ADCP.BATH.T1.(s).META;
        % Remove NaNs
        z1{k} = tempData1(~isnan(tempData1));
    end
end

% %% ADCP Observations Zimm
% % Load  data 
% siteFields = fieldnames(ADCP.ZIMMERMAN.T0);
% % Exclude non-station fields if any (assume station fields contain 'MP' or similar)
% isStation = contains(siteFields, 'MP');
% stationNames = siteFields(isStation);
% nStations = length(stationNames);
% 
% % Preallocate cell arrays to hold magnitude
% vel0_da = cell(size(stationNames));
% vel1_da = cell(size(stationNames));
% 
% bins = 0:0.1:1;
% 
% for k = 1:nStations
%     s = stationNames{k};
% 
%     % --- Process T0 ---
%     if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'Umag_da')
%        tempData0 = ADCP.ZIMMERMAN.T0.(s).Umag_da(1,:);
%        % Remove NaNs: "Keep tempData0 where it is NOT NaN"
%        vel0_da{k} = tempData0(~isnan(tempData0));
%     end
% 
%     % --- Process T1 ---
%     if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'Umag_da')
%         tempData1 = ADCP.ZIMMERMAN.T1.(s).Umag_da(1,:);
%         % Remove NaNs
%         vel1_da{k} = tempData1(~isnan(tempData1));
%     end
%     % %--plot--
%     % figure()
%     % % Use {k} instead of (s)
%     % histogram(vel0_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5); 
%     % hold on;
%     % histogram(vel1_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5, 'FaceColor', 'r'); 
%     % 
%     % xlabel('Velocity Magnitude (m/s)');
%     % ylabel('Frequency');
%     % % Dynamic title using the station name string
%     % title(['Bath Velocity Histogram for Station: ' s]); 
%     % legend('T0', 'T1');
%     % hold off;
% 
%     %---for probability--
%     figure()
%     % Use 'Normalization', 'probability' to change the y-axis
%     histogram(vel0_da{k}, 'BinEdges', bins, ...
%         'Normalization', 'probability', ...
%         'FaceAlpha', 0.5, 'FaceColor', 'b'); 
% 
%     hold on;
% 
%     histogram(vel1_da{k}, 'BinEdges', bins, ...
%         'Normalization', 'probability', ...
%         'FaceAlpha', 0.5, 'FaceColor', 'r');
% 
%     xlabel('Velocity Magnitude (m/s)');
%     ylabel('Probability'); % Updated label
%     title(['Velocity Distribution: ' s]);
%     legend('T0', 'T1');
%     hold off;
% end

%% ADCP Observations Zimm - Unified Visualization
siteFields = fieldnames(ADCP.ZIMMERMAN.T0);
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
nStations = length(stationNames);

% Preallocate
vel0_da = cell(size(stationNames));
vel1_da = cell(size(stationNames));
bins = 0:0.2:1;

% Create a large figure for the tiled layout
figure('Units', 'normalized', 'Position', [0.05, 0.05, 0.9, 0.85], ...
       'Name', 'Velocity Histogram Zimm', ... % Added quotes here
       'NumberTitle', 'off', ...               % Removes "Figure 1:" prefix
       'Color', 'w'); 
tlo = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');

for k = 1:nStations
    s = stationNames{k};
    
    station_title = strrep(s, 'MP', '');
    % --- 1. Data Extraction & Cleaning ---
    v0 = []; v1 = []; 
    
    if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'Umag_da')
       temp0 = ADCP.ZIMMERMAN.T0.(s).Umag_da(1,:);
       v0 = temp0(~isnan(temp0));
       vel0_da{k} = v0;
    end
    
    if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'Umag_da')
        temp1 = ADCP.ZIMMERMAN.T1.(s).Umag_da(1,:);
        v1 = temp1(~isnan(temp1));
        vel1_da{k} = v1;
    end
    % --- 1b. Extract ZBED metadata if present ---
    zbed0 = []; zbed1 = [];
    if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'META') && isfield(ADCP.ZIMMERMAN.T0.(s).META, 'ZBED')
        tempMeta0 = ADCP.ZIMMERMAN.T0.(s).META.ZBED;
        % Ensure numeric and remove NaNs
        zbed0 = tempMeta0(~isnan(tempMeta0));
    end
    if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'META') && isfield(ADCP.ZIMMERMAN.T1.(s).META, 'ZBED')
        tempMeta1 = ADCP.ZIMMERMAN.T1.(s).META.ZBED;
        zbed1 = tempMeta1(~isnan(tempMeta1));
    end

    % --- 2. Create Tile for each Station ---
    nexttile;
    
    if ~isempty(v0) || ~isempty(v1)
       % Plot T0
    histogram(v0, 'BinEdges', bins, 'Normalization', 'probability', ...
        'FaceAlpha', 0.4, 'FaceColor', [0 0.447 0.741], 'EdgeColor', 'b');
    hold on;
    
    % Plot T1
    histogram(v1, 'BinEdges', bins, 'Normalization', 'probability', ...
        'FaceAlpha', 0.4, 'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'r');
        
        % Formatting individual tile
        title(station_title, 'FontSize', 40);
        grid on;
        set(gca, 'XTick', [0.2, 0.4, 0.6, 0.8, 1], 'TickDir', 'in', 'FontSize', 17);
        
        % Fix Y-axis limits for better comparison across tiles (Optional)
        ylim([0 0.55]); 
    end
end

% --- 3. Global Labels and Legend ---
xlabel(tlo, 'Velocity Magnitude (m/s)', 'FontSize', 20, 'FontWeight', 'bold');
ylabel(tlo, 'Probability', 'FontSize', 20, 'FontWeight', 'bold');
title(tlo, 'Zimmerman: Velocity Magnitude Probability Distributions', 'FontSize', 28,  'FontWeight', 'bold');

% Shared Legend at the bottom
lg = legend({'T0', 'T1'}, 'Orientation', 'horizontal', 'FontSize', 20);
lg.Layout.Tile = 16;

%% ADCP Observations Bath
% Load  data 
siteFields = fieldnames(ADCP.BATH.T0);
% Exclude non-station fields if any (assume station fields contain 'MP' or similar)
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
nStations = length(stationNames);

% Preallocate cell arrays to hold magnitude
vel0_da = cell(size(stationNames));
vel1_da = cell(size(stationNames));

bins = 0:0.2:1;

% for k = 1:nStations
%     s = stationNames{k};
% 
%     % --- Process T0 ---
%     if isfield(ADCP.BATH.T0, s) && isfield(ADCP.BATH.T0.(s), 'Umag_da')
%        tempData0 = ADCP.BATH.T0.(s).Umag_da(1,:);
%        % Remove NaNs: "Keep tempData0 where it is NOT NaN"
%        vel0_da{k} = tempData0(~isnan(tempData0));
%     end
% 
%     % --- Process T1 ---
%     if isfield(ADCP.BATH.T1, s) && isfield(ADCP.BATH.T1.(s), 'Umag_da')
%         tempData1 = ADCP.BATH.T1.(s).Umag_da(1,:);
%         % Remove NaNs
%         vel1_da{k} = tempData1(~isnan(tempData1));
%     end
%     % %--plot--
%     % figure()
%     % % Use {k} instead of (s)
%     % histogram(vel0_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5); 
%     % hold on;
%     % histogram(vel1_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5, 'FaceColor', 'r'); 
%     % 
%     % xlabel('Velocity Magnitude (m/s)');
%     % ylabel('Frequency');
%     % % Dynamic title using the station name string
%     % title(['Bath Velocity Histogram for Station: ' s]); 
%     % legend('T0', 'T1');
%     % hold off;
% 
%     % %---for probability--
%     % figure()
%     % % Use 'Normalization', 'probability' to change the y-axis
%     % histogram(vel0_da{k}, 'BinEdges', bins, ...
%     %     'Normalization', 'probability', ...
%     %     'FaceAlpha', 0.5, 'FaceColor', 'b'); 
%     % 
%     % hold on;
%     % 
%     % histogram(vel1_da{k}, 'BinEdges', bins, ...
%     %     'Normalization', 'probability', ...
%     %     'FaceAlpha', 0.5, 'FaceColor', 'r');
%     % 
%     % xlabel('Velocity Magnitude (m/s)', 'FontSize', 18);
%     % ylabel('Probability', 'FontSize', 18);
%     % title(['Velocity Distribution: ' s], 'FontSize', 24);
%     % 
%     % % 2. Increase Legend size
%     % legend('T0', 'T1', 'FontSize', 16);
%     % 
%     % % 3. Increase Tick Label size (the numbers on the axes)
%     % set(gca, 'FontSize', 14);
%     %     legend('T0', 'T1');
%     %     hold off;
% % end
% 
%     % --- Setup ---
% 
% end 
    % Create one large figure for all stations
    % figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8], 'Name', Vel_Histogram_Bath); 
    figure('Units', 'normalized', ...
       'Position', [0.3, 0.05, 0.6, 0.9], ... %[Left, Bottom, Width, Height]
       'Name', 'Velocity Histogram Bath', ... % Added quotes here
       'NumberTitle', 'off', ...               % Removes "Figure 1:" prefix
       'Color', 'w');                          % Optional: sets background to white
    tlo = tiledlayout(5, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    for k = 1:nStations
        s = stationNames{k};
        station_title = strrep(s, 'MP', '');
        
        % --- 1. Data Extraction & Cleaning ---
        v0 = []; v1 = []; % Initialize empty for this station
        
        if isfield(ADCP.BATH.T0, s) && isfield(ADCP.BATH.T0.(s), 'Umag_da')
           temp0 = ADCP.BATH.T0.(s).Umag_da(1,:);
           v0 = temp0(~isnan(temp0));
        end
        
        if isfield(ADCP.BATH.T1, s) && isfield(ADCP.BATH.T1.(s), 'Umag_da')
            temp1 = ADCP.BATH.T1.(s).Umag_da(1,:);
            v1 = temp1(~isnan(temp1));
        end
        
        % --- 2. Plotting (One Tile per Station) ---
        nexttile;
        
        if ~isempty(v0) || ~isempty(v1)
            % Plot T0
            histogram(v0, 'BinEdges', bins, 'Normalization', 'probability', ...
                'FaceAlpha', 0.4, 'FaceColor', [0 0.447 0.741], 'EdgeColor', 'b');
            hold on;
            
            % Plot T1
            histogram(v1, 'BinEdges', bins, 'Normalization', 'probability', ...
                'FaceAlpha', 0.4, 'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'r');
            
            % Formatting individual tile
             title(station_title, 'FontSize', 16);
           set(gca, 'XTick', [0.2, 0.4, 0.6, 0.8, 1], 'TickDir', 'in', 'FontSize', 12);
           % Automatically scale and add 10% breathing room at the top
            axis tight; 
            yl = ylim; 
            ylim([0, yl(2) * 1.1]);
            grid on;
        end
    end
    
    % --- 3. Global Labels (Shared across all tiles) ---
    xlabel(tlo, 'Velocity Magnitude (m/s)', 'FontSize', 18, 'FontWeight', 'bold');
    ylabel(tlo, 'Probability', 'FontSize', 18, 'FontWeight', 'bold');
    title(tlo, 'Bath: Velocity Magnitude Probability Distributions', 'FontSize', 22,  'FontWeight', 'bold');
    
    % Shared Legend (Placed at the bottom or east of the tiles)
    lg = legend({'T0', 'T1'}, 'Orientation', 'horizontal', 'FontSize', 14);
    lg.Layout.Tile = 20;
    % lg.Layout.Tile = 'south';

% %% 1. Define the directory
% png_dir = "P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\";
% 
% % 2. Ensure the directory exists (prevents error if folder is missing)
% if ~exist(png_dir, 'dir')
%     mkdir(png_dir);
% end
% 
% % 3. Define the filename (e.g., using the figure name)
% figName = "Velocity_Histogram_Zimm"; 
% fullPath = fullfile(png_dir, figName + ".png");
% 
% % 4. Export with high resolution (300 DPI is standard for reports)
% exportgraphics(gcf, fullPath, 'Resolution', 300);

