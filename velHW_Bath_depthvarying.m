close all
clear all
clc

%% ADCP data
load("P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat")

%% ADCP Observations
% Load  data 
f0 = {};
f1 = {};
if isfield(ADCP, 'BATH') && isstruct(ADCP.BATH)
    if isfield(ADCP.BATH, 'T0') && isstruct(ADCP.BATH.T0)
        f0 = fieldnames(ADCP.BATH.T0);
    end
    if isfield(ADCP.BATH, 'T1') && isstruct(ADCP.BATH.T1)
        f1 = fieldnames(ADCP.BATH.T1);
    end
end
siteFields = unique([f0; f1]);
% Exclude non-station fields if any (assume station fields contain 'MP' or similar)
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
% create a title-friendly version of station names by removing any occurrence of 'MP'
stationNames_title = regexprep(stationNames, 'MP', '');
nStations = length(stationNames);

% Preallocate cell arrays to hold time, magnitude and direction for each station
time0 = cell(size(stationNames));
vel0 = cell(size(stationNames));
dir0 = cell(size(stationNames));
RDx_T0 = cell(size(stationNames));
RDy_T0 = cell(size(stationNames));

% Initialize time1, vel1, dir1 in case missing
time1 = cell(size(stationNames));
vel1 = cell(size(stationNames));
dir1 = cell(size(stationNames));
RDx_T1 = cell(size(stationNames));
RDy_T1 = cell(size(stationNames));

for k = 1:nStations
    s = stationNames{k};
    % Safely access fields; if a field or subfield is missing, set empty
    if isfield(ADCP.BATH.T0, s) && ...
       isfield(ADCP.BATH.T0.(s), 't_CET') && ...
       isfield(ADCP.BATH.T0.(s), 'Umag') && ...
       isfield(ADCP.BATH.T0.(s), 'Udir') && ...
       isfield(ADCP.BATH.T0.(s).META, 'RDX' ) && ...
       isfield(ADCP.BATH.T0.(s).META, 'RDY' ) && ...
       isfield(ADCP.BATH.T0.(s), 'zCellCenters' ) && ...
       isfield(ADCP.BATH.T0.(s).META, 'ZBED' ) && ...
       isfield(ADCP.BATH.T0.(s), 'WL_from_external_source' )
   
        % Read all available columns
        time0{k} = ADCP.BATH.T0.(s).t_CET;
        vel0{k} = ADCP.BATH.T0.(s).Umag;
        dir0{k} = ADCP.BATH.T0.(s).Udir;
        RDx_T0{k} = ADCP.BATH.T0.(s).META.RDX;
        RDy_T0{k} = ADCP.BATH.T0.(s).META.RDY;
        Zcell_T0{k} = ADCP.BATH.T0.(s).zCellCenters;
        WL_T0{k} = ADCP.BATH.T0.(s).WL_from_external_source;
        zbedT0{k} = ADCP.BATH.T0.(s).META.ZBED;
        % Apply sign convention: directions 20-200 => positive (flood),
        % all other directions => negative
        if ~isempty(dir0{k}) && ~isempty(vel0{k})
            dirs = dir0{k};
            vels = vel0{k};
            
            if isvector(vels)
                % Vector Fallback Logic
                dirs = dirs(:); vels = vels(:);
                n = min(numel(dirs), numel(vels));
                signFactor = -ones(n,1);
                signMatrix((dirs >= 345 & dirs <= 360) | (dirs >= 0 & dirs <= 165)) = 1;
                vels(1:n) = vels(1:n) .* signFactor;
                vel0{k} = vels;
            else
                % Matrix Logic: Match row-by-row and column-by-column
                % Truncate sizes if time or depth dimensions don't perfectly match
                nRows = min(size(dirs, 1), size(vels, 1));
                nCols = min(size(dirs, 2), size(vels, 2));
                
                dirs = dirs(1:nRows, 1:nCols);
                vels = vels(1:nRows, 1:nCols);
                
                % Create a matrix of signs matching the exact shape of your data
                signMatrix = -ones(size(dirs));
                % Positive (flood) for directions from 345 through 360 and 0 through 165
                signMatrix((dirs >= 345 & dirs <= 360) | (dirs >= 0 & dirs <= 165)) = 1;
                
                % Element-wise multiplication keeps depth masks independent!
                vel0{k} = vels .* signMatrix; 
            end
        end
    else
        time0{k} = [];
        vel0{k} = [];
        dir0{k} = [];
    end
end

for k = 1:nStations
    s = stationNames{k};
    % Safely access fields; if a field or subfield is missing, set empty
    if isfield(ADCP.BATH.T1, s) && ...
       isfield(ADCP.BATH.T1.(s), 't_CET') && ...
       isfield(ADCP.BATH.T1.(s), 'Umag') && ...
       isfield(ADCP.BATH.T1.(s), 'Udir') && ...
       isfield(ADCP.BATH.T1.(s).META, 'RDX' ) && ...
       isfield(ADCP.BATH.T1.(s).META, 'RDY' ) && ...
       isfield(ADCP.BATH.T1.(s), 'zCellCenters' ) && ...
       isfield(ADCP.BATH.T1.(s).META, 'ZBED' ) && ...
       isfield(ADCP.BATH.T1.(s), 'WL_from_external_source' )
   
        % Read all available columns
        time1{k} = ADCP.BATH.T1.(s).t_CET;
        vel1{k} = ADCP.BATH.T1.(s).Umag;
        dir1{k} = ADCP.BATH.T1.(s).Udir;
        RDx_T1{k} = ADCP.BATH.T1.(s).META.RDX;
        RDy_T1{k} = ADCP.BATH.T1.(s).META.RDY;
        Zcell_T1{k} = ADCP.BATH.T1.(s).zCellCenters;
        WL_T1{k} = ADCP.BATH.T1.(s).WL_from_external_source;
        zbedT1{k} = ADCP.BATH.T1.(s).META.ZBED;
        
        if ~isempty(dir1{k}) && ~isempty(vel1{k})
            dirs = dir1{k};
            vels = vel1{k};
            
            if isvector(vels)
                % Vector Fallback Logic
                dirs = dirs(:); vels = vels(:);
                n = min(numel(dirs), numel(vels));
                signFactor = -ones(n,1);
                signMatrix((dirs >= 345 & dirs <= 360) | (dirs >= 0 & dirs <= 165)) = 1;
                vels(1:n) = vels(1:n) .* signFactor;
                vel1{k} = vels;
            else
                % Matrix Logic: Match row-by-row and column-by-column
                % Truncate sizes if time dimensions don't perfectly match
                nRows = min(size(dirs, 1), size(vels, 1));
                nCols = min(size(dirs, 2), size(vels, 2));
                
                dirs = dirs(1:nRows, 1:nCols);
                vels = vels(1:nRows, 1:nCols);
                
                % Create a matrix of signs matching the exact shape of your data
                signMatrix = -ones(size(dirs));
                 signMatrix((dirs >= 345 & dirs <= 360) | (dirs >= 0 & dirs <= 165)) = 1;
                
                % Element-wise multiplication keeps depth masks independent!
                vel1{k} = vels .* signMatrix; 
            end
        end
    end
end

% % water level Bath
WL_Bath =  ADCP.BATH.T0.MP0702.WL_from_external_source;
WL_Bath_time = ADCP.BATH.T0.MP0702.t_CET;
WL_Bath1 =  ADCP.BATH.T1.MP0103.WL_from_external_source; %phase 1
WL_Bath_time1 = ADCP.BATH.T1.MP0103.t_CET;
WL_Bath2 =  ADCP.BATH.T1.MP0703.WL_from_external_source; %phase 2
WL_Bath_time2 = ADCP.BATH.T1.MP0703.t_CET;
% Collect WL_Bath and WL_Bath_time for all stations for T0 and T1

%% collect WL per station for T0 and T1
% Initialize as cell arrays sized to stationNames
nStations = numel(stationNames);
WL_Bath = []; WL_Bath_time = [];
WL_Bath_cell = repmat({[]}, 1, nStations);
WL_Bath_time_cell = repmat({[]}, 1, nStations);
WL_Bath1 = repmat({[]}, 1, nStations);
WL_Bath_time1 = repmat({[]}, 1, nStations);

for k = 1:nStations
    s = stationNames{k};
    % T0
    if isfield(ADCP.BATH, 'T0') && isfield(ADCP.BATH.T0, s) ...
            && isfield(ADCP.BATH.T0.(s), 'WL_from_external_source') ...
            && isfield(ADCP.BATH.T0.(s), 't_CET')
        WLtmp = ADCP.BATH.T0.(s).WL_from_external_source;
        WLttmp = ADCP.BATH.T0.(s).t_CET;
        if ~isempty(WLtmp), WLtmp = WLtmp(:); end
        if ~isempty(WLttmp), WLttmp = WLttmp(:); end
        WL_Bath_cell{k} = WLtmp;
        WL_Bath_time_cell{k} = WLttmp;
        % also append to overall vectors for T0
        if ~isempty(WLtmp)
            WL_Bath = [WL_Bath; WLtmp];
        end
        if ~isempty(WLttmp)
            WL_Bath_time = [WL_Bath_time; WLttmp];
        end
    else
        WL_Bath_cell{k} = [];
        WL_Bath_time_cell{k} = [];
    end

    % T1
    if isfield(ADCP.BATH, 'T1') && isfield(ADCP.BATH.T1, s) ...
            && isfield(ADCP.BATH.T1.(s), 'WL_from_external_source') ...
            && isfield(ADCP.BATH.T1.(s), 't_CET')
        WLtmp1 = ADCP.BATH.T1.(s).WL_from_external_source;
        WLttmp1 = ADCP.BATH.T1.(s).t_CET;
        if ~isempty(WLtmp1), WLtmp1 = WLtmp1(:); end
        if ~isempty(WLttmp1), WLttmp1 = WLttmp1(:); end
        WL_Bath1{k} = WLtmp1;
        WL_Bath_time1{k} = WLttmp1;
    else
        WL_Bath1{k} = [];
        WL_Bath_time1{k} = [];
    end
end

% Provide non-cell fallback variables expected later in the script
% (keep original scalar names for compatibility)
WL_Bath = WL_Bath;            % vector concatenation for T0 (may be empty)
WL_Bath_time = WL_Bath_time;  % vector concatenation for T0 times
WL_Bath = WL_Bath_cell;       % per-station cell array for T0 (overwrite name to cells)
WL_Bath_time = WL_Bath_time_cell;

%% Plot High Water versus velocity (tiled format - Multi-depth capable)
% setting up tile format
nStations = numel(stationNames);
nRows = 5;
nCols = 4;
maxTiles = nRows * nCols;

% Leave the final tile (Tile 16) open for a clean layout legend
nToPlot = min(nStations, maxTiles - 1);

% figure with A4 Vertical proportions
fig = figure('Name', 'High Water Velocities Tiled Depths', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 18, 25]; % Width=18cm, Height=25cm fits well on A4

% title plot
t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');

% Global Title, X-Label, and Y-Label to the layout (t), not individual plots
title(t, 'Velocity vs Water Level: Bath', 'FontSize', 20, 'FontWeight', 'bold');
xlabel(t, 'Velocity (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 14, 'FontWeight', 'bold');

% Loop stations and plot into tiles 
for k = 1:nToPlot
    % ==========================================
    % Prepare T0 Data (Depth-varying or Vector)
    % ==========================================
    if exist('WL_Bath','var') && exist('WL_Bath_time','var') && ~isempty(time0{k}) && ~isempty(vel0{k})
        if iscell(WL_Bath) && numel(WL_Bath) >= k
            zWL_cell = WL_Bath{k};
            twl_cell = WL_Bath_time{k};
        else
            zWL_cell = WL_Bath;
            twl_cell = WL_Bath_time;
        end
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0_all = vel0{k};
        zCell_all0 = Zcell_T0{k}; % Matrix (Time x Depths) tracking distance upward from bed
        
        if isdatetime(twl_cell), twl_num = datenum(twl_cell(:)); else, twl_num = twl_cell(:); end
        if isdatetime(tV0),       tv0_num = datenum(tV0);       else, tv0_num = tV0;       end
        
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            
            if ismatrix(v0_all) && size(v0_all,1) == numel(tv0_num)
                nDepths0 = size(v0_all,2);
                z0_at_v = NaN(size(v0_all)); 
                valid0 = false(size(v0_all));
                
                % 1. Interpolate surface water level (NAP) to ADCP timestamps
                z_surface_interp = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
              
                % Absolute Y-Axis = Bed Level + Zcell
                for d = 1:nDepths0
                    % This shifts the absolute upward distance into true NAP coordinate space
                    z0_at_v(:,d) = zbedT0{k} + zCell_all0(:,d); 
                    valid0(:,d) = ~isnan(z0_at_v(:,d)) & ~isnan(v0_all(:,d));
                end
            end
        end
    else
        v0_all = []; z0_at_v = []; valid0 = [];
    end
    % ==========================================
    % Prepare T1 Data (Depth-varying or Vector)
    % ==========================================
    if exist('WL_Bath1','var') && exist('WL_Bath_time1','var') && ~isempty(time1{k}) && ~isempty(vel1{k})
        if iscell(WL_Bath1) && numel(WL_Bath1) >= k
            zWL1_cell = WL_Bath1{k};
            twl1_cell = WL_Bath_time1{k};
        else
            zWL1_cell = WL_Bath1;
            twl1_cell = WL_Bath_time1;
        end
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1_all = vel1{k};
        zCell_all1 = Zcell_T1{k}; % Matrix (Time x Depths) tracking distance upward from bed
        
        if isdatetime(twl1_cell), twl1_num = datenum(twl1_cell(:)); else, twl1_num = twl1_cell(:); end
        if isdatetime(tV1),        tv1_num = datenum(tV1);        else, tv1_num = tV1;        end
        
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            
            if ismatrix(v1_all) && size(v1_all,1) == numel(tv1_num)
                nDepths1 = size(v1_all,2);
                z1_at_v = NaN(size(v1_all)); 
                valid1 = false(size(v1_all));
                
                % 1. Interpolate surface water level (NAP) to ADCP timestamps
                z_surface_interp1 = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
              
                % Absolute Y-Axis = Bed Level + Zcell
                for d = 1:nDepths1
                    % This shifts the absolute upward distance into true NAP coordinate space
                    z1_at_v(:,d) = zbedT1{k} + zCell_all1(:,d); 
                    valid1(:,d) = ~isnan(z1_at_v(:,d)) & ~isnan(v1_all(:,d));
                end
            end
        end
    else
        v1_all = []; z1_at_v = []; valid1 = [];
    end
    % ==========================================
    % PLOTTING
    % ==========================================
    nexttile(k);
    hold on;
    
    % Zero Reference Velocity Line
    y_line = [-4 4.5];
    plot([0 0], y_line, 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5, 'HandleVisibility', 'off');
    
    hasData = false;
    
    % Plot T0 Channels (Loops through every depth profile column dynamically)
    if ~isempty(valid0) && any(valid0(:))
        nColsD0 = size(v0_all, 2);
        for d = 1:nColsD0
            v_curr = v0_all(:, d);
            z_curr = z0_at_v(:, d);
            val_curr = valid0(:, d);
            if any(val_curr)
                plot(v_curr(val_curr), z_curr(val_curr), '-', 'LineWidth', 1.0, ...
                     'Color', [0 0.4470 0.7410], 'DisplayName', 'T0');
                hasData = true;
            end
        end
    end
    
    % Plot T1 Channels (Loops through every depth profile column dynamically)
    if ~isempty(valid1) && any(valid1(:))
        nColsD1 = size(v1_all, 2);
        for d = 1:nColsD1
            v_curr = v1_all(:, d);
            z_curr = z1_at_v(:, d);
            val_curr = valid1(:, d);
            if any(val_curr)
                plot(v_curr(val_curr), z_curr(val_curr), '-', 'LineWidth', 1.0, ...
                     'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'T1');
                hasData = true;
            end
        end
    end
    
    if ~hasData
        text(0.5, 0.5, 'No valid data', 'Units', 'normalized', 'HorizontalAlignment', 'center', 'FontSize', 10);
    end
    
    % Formatting cleanups per window
    set(gca, 'FontSize', 11);
    grid on;
    ylim([-2 4]);
    xlim([-1.7 1.7]);
    
    titleStrStation = stationNames_title{k};
    title(titleStrStation, 'Interpreter', 'none', 'FontSize', 14);
    hold off;
end

% Clear residual layout tiles leaving the final index open for layout alignment
for blank_tile = (nToPlot+1):(maxTiles-1)
    nexttile(blank_tile);
    axis off;
end

% ==========================================
% Master Global Legend Structure (Tile)
% ==========================================
nexttile(maxTiles-1);
axis off;
hAx = gca;
hAx.Visible = 'off';

% Fake lines to keep the clean single-key mapping without messy multiplicity
hLine1 = line(nan, nan, 'LineWidth', 2.5, 'Color', [0 0.4470 0.7410]);
hLine2 = line(nan, nan, 'LineWidth', 2.5, 'Color', [0.8500 0.3250 0.0980]);

lgd = legend([hLine1, hLine2], {'T0 Velocity (Depth Varying)','T1 Velocity (Depth Varying)'}, ...
    'Location', 'west', ...
    'FontSize', 14, ...
    'Box', 'off', ...
    'Interpreter', 'none');

lgd.Units = 'normalized';

% %% Residual Velocity
% nStations = numel(stationNames);
% nRows = 3; nCols = 4;
% maxTiles = nRows * nCols; % Total slots = 20
% 
% fig = figure('Name', 'Residual Velocities Tiled Bins', 'Color', 'w');
% fig.Units = 'centimeters';
% fig.Position = [1, 1, 17, 17]; 
% 
% t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');
% title(t, 'Residual Velocity vs Water Level: Zimmerman', 'FontSize', 20, 'FontWeight', 'bold');
% xlabel(t, 'Velocity (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
% ylabel(t, 'Water Level NAP (m)', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % --- Binning Settings ---
% z_edges = -3:0.2:4.5; % 0.2m bins
% z_centers = z_edges(1:end-1) + 0.1;
% v_edges = -1.4:0.1:1.4; % 0.1m bins
% 
% % Plot max 19 stations to leave the 20th tile for the legend
% nToPlot = min(nStations, maxTiles - 1);
% 
% for k = 1:nToPlot
%    % Prepare T0 data (use WL for T0)
%     if exist('WL_Zimm','var') && exist('WL_Zimm_time','var') && ~isempty(time0{k}) && ~isempty(vel0{k})
%         % WL_Bath and WL_Bath_time are per-station cell arrays from earlier;
%         % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
%         if iscell(WL_Zimm) && numel(WL_Zimm) >= k
%             zWL_cell = WL_Zimm{k};
%             twl_cell = WL_Zimm_time{k};
%         else
%             zWL_cell = WL_Zimm;
%             twl_cell = WL_Zimm_time;
%         end
%         tWL = twl_cell(:);
%         zWL = zWL_cell(:);
%         tV0 = time0{k}(:);
%         v0 = vel0{k}(:);
%         if isdatetime(tWL)
%             twl_num = datenum(tWL);
%         else
%             twl_num = tWL;
%         end
%         if isdatetime(tV0)
%             tv0_num = datenum(tV0);
%         else
%             tv0_num = tV0;
%         end
%         validWL = ~isnan(zWL) & ~isnan(twl_num);
%         if sum(validWL) >= 2
%             zWL_valid = zWL(validWL);
%             twl_valid = twl_num(validWL);
%             z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
%             valid0 = ~isnan(z0_at_v) & ~isnan(v0);
%         else
%             valid0 = false(size(v0));
%             z0_at_v = NaN(size(v0));
%         end
%     else
%         v0 = [];
%         z0_at_v = [];
%         valid0 = [];
%     end
% 
%     % Prepare T1 data (use WL_Zimm1 for T1)
%     if exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') && ~isempty(time1{k}) && ~isempty(vel1{k})
%         % WL_Zimm1 and WL_Zimm_time1 are per-station cell arrays from earlier;
%         % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
%         if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
%             zWL1_cell = WL_Zimm1{k};
%             twl1_cell = WL_Zimm_time1{k};
%         else
%             zWL1_cell = WL_Zimm1;
%             twl1_cell = WL_Zimm_time1;
%         end
%         tWL1 = twl1_cell(:);
%         zWL1 = zWL1_cell(:);
%         tV1 = time1{k}(:);
%         v1 = vel1{k}(:);
%         if isdatetime(tWL1)
%             twl1_num = datenum(tWL1);
%         else
%             twl1_num = tWL1;
%         end
%         if isdatetime(tV1)
%             tv1_num = datenum(tV1);
%         else
%             tv1_num = tV1;
%         end
%         validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
%         if sum(validWL1) >= 2
%             zWL1_valid = zWL1(validWL1);
%             twl1_valid = twl1_num(validWL1);
%             z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
%             valid1 = ~isnan(z1_at_v) & ~isnan(v1);
%         else
%             valid1 = false(size(v1));
%             z1_at_v = NaN(size(v1));
%         end
%     else
%         v1 = [];
%         z1_at_v = [];
%         valid1 = [];
%     end
% 
%     ax = nexttile;
%     hold on;
% 
%     % --- Binning Logic for T0 ---
%     if ~isempty(valid0) && any(valid0)
%         v0_raw = v0(valid0);
%         z0_raw = z0_at_v(valid0);
% 
%         v0_binned = NaN(size(z_centers));
%         for b = 1:numel(z_centers)
%             % Find indices where water level falls into the current bin
%             idx = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
%             if any(idx)
%                 v0_binned(b) = mean(v0_raw(idx)); % Calculate average velocity for this WL bin
%             end
%         end
%         % Plot binned T0
%         plot(v0_binned, z_centers, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, ...
%             'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410], 'DisplayName', 'T0');
%     end
% 
%     % --- Binning Logic for T1 ---
%     if ~isempty(valid1) && any(valid1)
%         v1_raw = v1(valid1);
%         z1_raw = z1_at_v(valid1);
% 
%         v1_binned = NaN(size(z_centers));
%         for b = 1:numel(z_centers)
%             idx = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
%             if any(idx)
%                 v1_binned(b) = mean(v1_raw(idx));
%             end
%         end
%         % Plot binned T1
%         plot(v1_binned, z_centers, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, ...
%             'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'DisplayName', 'T1');
%     end
% 
%     % --- Formatting ---
%     ax.XTick = [-0.2 0 0.2];
%     ax.XTickLabel = {}; 
%     ax.YTickLabel = {};
%     if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end % Show left column
%     if k > (nRows-1)*nCols, ax.XTickLabelMode = 'auto'; end   % Show bottom row
%     grid on; 
%     ax.GridAlpha = 0.1;
%     ax.FontSize = 12;
%     ylim([-1.6 4]); 
%     xlim([-0.4 0.4]);
%     title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 12);
% 
%     % --text for flood and ebb--
%     % add text for "flood" and "ebb" on each tile at bottom
%     % Place 'flood' at left-bottom and 'ebb' at right-bottom of each tile
%     xLimits = xlim(ax);
%     yLimits = ylim(ax);
%     xPadding = 0.03 * range(xLimits);
%     yPadding = 0.02 * range(yLimits);
% 
%     % Left-bottom (flood)
%     text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
%         'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
%         'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7], ...
%         'Interpreter', 'none');
% 
%     % Right-bottom (ebb)
%     text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
%         'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
%         'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7], ...
%         'Interpreter', 'none');
% 
%     % Reference line
%     line([0 0], [-3 4], 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5, 'HandleVisibility', 'off');
% end
% 
% % Put legend in 12th tile
% try
%     tlayout = gca;
%     % If current axes is not a tile, attempt to get tiledlayout parent
%     if ~isa(tlayout.Parent, 'matlab.graphics.layout.TiledChartLayout')
%         % Find the tiledlayout in the figure
%         tlay = findall(gcf, 'Type', 'tiledlayout');
%         if ~isempty(tlay)
%             tlayout = tlay(1);
%         else
%             tlayout = [];
%         end
%     else
%         tlayout = tilayout.Parent;
%     end
% catch
%     tlayout = [];
% end
% 
% % Safely select tile 20 if layout exists and has enough tiles
% if exist('tlayout','var') && ~isempty(tlayout)
%     try
%         nexttile(20);
%     catch
%         % If tile 20 doesn't exist, use the last tile
%         tiles = findall(gcf, 'Type', 'axes');
%         if ~isempty(tiles)
%             axes(tiles(end));
%             cla;
%         else
%             axes;
%         end
%     end
% else
%     % No tiledlayout found; create a new invisible axes for legend
%     axes('Position',[0 0 1 1],'Visible','off');
% end
% 
% axLeg = nexttile(t, 12); 
% axis(axLeg, 'off'); % Hide the axes box
% 
% % 3. Create dummy lines that match the binned plot style
% hT0 = line(axLeg, nan, nan, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5, ...
%     'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0 0.4470 0.7410], 'LineStyle', '-');
% hT1 = line(axLeg, nan, nan, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5, ...
%     'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'LineStyle', '-');
% 
% % 4. Generate the legend
% lgd = legend(axLeg, [hT0, hT1], {'T0', 'T1'}, ...
%     'Location', 'west', ...
%     'FontSize', 16, ...
%     'Box', 'off', ...
%     'FontWeight', 'bold');
% 
% % 5. Optional: Final layout tightening
% t.Padding = 'compact';
% t.TileSpacing = 'compact';

% %% export 
% outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% fname = fullfile(outDir, sprintf('Zimm_residual_HW_vel.png'));
% % Save current figure as PNG with good resolution
% try
%     exportgraphics(gcf, fname, 'Resolution', 300);
% catch
%     % fallback to print if exportgraphics unavailable
%     try
%         print(gcf, fname, '-dpng', '-r300');
%     catch
%         % final fallback
%         saveas(gcf, fname);
%     end
% end

% %% Binning velocities and plotting 95% interval
% % High Water versus velocity (tiled format)
% nStations = numel(stationNames);
% nRows = 4;
% nCols = 4;
% % figure with A4 Vertical proportions
% fig = figure('Name', 'High Water Velocities Tiled Bins 95%', 'Color', 'w');
% fig.Units = 'centimeters';
% fig.Position = [1, 1, 18, 23]; % Width=18cm, Height=23cm fits well on A4
% 
% % title plot
% t = tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
% 
% % Global Title, X-Label, and Y-Label to the layout (t), not individual plots
% title(t, 'Velocity vs Water Level: Zimmerman', 'FontSize', 20, 'FontWeight', 'bold');
% xlabel(t, 'Velocity (m/s)', 'FontSize', 16, 'FontWeight', 'bold');
% ylabel(t, 'Water Level NAP (m)', 'FontSize', 16, 'FontWeight', 'bold');
% 
% % --- Binning Settings ---
% z_edges = -3:0.2:4.5; % 0.2m bins
% z_centers = z_edges(1:end-1) + 0.1;
% v_edges = -1.5:0.1:1.5; % 0.1m bins
% 
% % Colors defined globally before the loop to prevent reference errors
% royalBlue  = [65, 105, 225] / 255;
% baseOrange = [0.8500 0.3250 0.0980];
% 
% maxTiles = nRows * nCols;
% nToPlot = min(nStations, maxTiles);
% for k = 1:nToPlot
%     % Prepare T0 data (use WL_Zimm for T0)
%     if exist('WL_Zimm','var') && exist('WL_Zimm_time','var') && ~isempty(time0{k}) && ~isempty(vel0{k})
%         if iscell(WL_Zimm) && numel(WL_Zimm) >= k
%             zWL_cell = WL_Zimm{k};
%             twl_cell = WL_Zimm_time{k};
%         else
%             zWL_cell = WL_Zimm;
%             twl_cell = WL_Zimm_time;
%         end
%         tWL = twl_cell(:);
%         zWL = zWL_cell(:);
%         tV0 = time0{k}(:);
%         v0 = vel0{k}(:);
%         if isdatetime(tWL)
%             twl_num = datenum(tWL);
%         else
%             twl_num = tWL;
%         end
%         if isdatetime(tV0)
%             tv0_num = datenum(tV0);
%         else
%             tv0_num = tV0;
%         end
%         validWL = ~isnan(zWL) & ~isnan(twl_num);
%         if sum(validWL) >= 2
%             zWL_valid = zWL(validWL);
%             twl_valid = twl_num(validWL);
%             z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
%             % Ensure z0_at_v and v0 are column vectors
%             z0_at_v = z0_at_v(:);
%             v0 = v0(:);
%             if numel(z0_at_v) == numel(v0)
%                 valid0 = ~isnan(z0_at_v) & ~isnan(v0);
%             else
%                 % If lengths differ, align by using the shorter length
%                 nmin = min(numel(z0_at_v), numel(v0));
%                 valid0 = ~isnan(z0_at_v(1:nmin)) & ~isnan(v0(1:nmin));
%                 % Truncate for subsequent use
%                 z0_at_v = z0_at_v(1:nmin);
%                 v0 = v0(1:nmin);
%             end
%         else
%             valid0 = false(size(v0));
%             z0_at_v = NaN(size(v0));
%         end
%     else
%         v0 = [];
%         z0_at_v = [];
%         valid0 = [];
%     end
% 
%     % Prepare T1 data (use WL_Zimm1 for T1)
%     if exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') && ~isempty(time1{k}) && ~isempty(vel1{k})
%         if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
%             zWL1_cell = WL_Zimm1{k};
%             twl1_cell = WL_Zimm_time1{k};
%         else
%             zWL1_cell = WL_Zimm1;
%             twl1_cell = WL_Zimm_time1;
%         end
%         tWL1 = twl1_cell(:);
%         zWL1 = zWL1_cell(:);
%         tV1 = time1{k}(:);
%         v1 = vel1{k}(:);
%         if isdatetime(tWL1)
%             twl1_num = datenum(tWL1);
%         else
%             twl1_num = tWL1;
%         end
%         if isdatetime(tV1)
%             tv1_num = datenum(tV1);
%         else
%             tv1_num = tV1;
%         end
%         validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
%         if sum(validWL1) >= 2
%             zWL1_valid = zWL1(validWL1);
%             twl1_valid = twl1_num(validWL1);
%             z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
%             % Ensure z1_at_v and v1 are column vectors of the same length before logical AND
%             z1_at_v = z1_at_v(:);
%             v1 = v1(:);
%             if numel(z1_at_v) == numel(v1)
%                 valid1 = ~isnan(z1_at_v) & ~isnan(v1);
%             else
%                 % If lengths differ, attempt to align by using the shorter length
%                 nmin = min(numel(z1_at_v), numel(v1));
%                 valid1 = ~isnan(z1_at_v(1:nmin)) & ~isnan(v1(1:nmin));
%                 % Truncate z1_at_v and v1 to the aligned length for subsequent use
%                 z1_at_v = z1_at_v(1:nmin);
%                 v1 = v1(1:nmin);
%             end
%         else
%             valid1 = false(size(v1));
%             z1_at_v = NaN(size(v1));
%         end
%     else
%         v1 = [];
%         z1_at_v = [];
%         valid1 = [];
%     end
% 
%     % Select target tile sequentially
%     ax = nexttile(k);
%     hold(ax, 'on');
% 
%     pctiles = [0 50 100];
%     nPct = numel(pctiles);
% 
%     % --- Binning Logic for T0 ---
%     if ~isempty(valid0) && any(valid0)
%         v0_raw = v0(valid0);
%         z0_raw = z0_at_v(valid0);
% 
%         v0_eb_pct = NaN(numel(z_centers), nPct);
%         v0_fl_pct = NaN(numel(z_centers), nPct);
% 
%         for b = 1:numel(z_centers)
%             idx_bin = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
%             if any(idx_bin)
%                 v_bin = v0_raw(idx_bin);
%                 v_ebb = v_bin(v_bin < 0);
%                 v_flood = v_bin(v_bin >= 0);
% 
%                 if ~isempty(v_ebb),   v0_eb_pct(b,:) = prctile(v_ebb, pctiles); end
%                 if ~isempty(v_flood), v0_fl_pct(b,:) = prctile(v_flood, pctiles); end
%             end
%         end
% 
%         % Plot T0 Ebb Envelope & Median
%         idx_eb = ~isnan(v0_eb_pct(:,1));
%         if any(idx_eb)
%             x_patch_eb = [v0_eb_pct(idx_eb,1); flipud(v0_eb_pct(idx_eb,3))];
%             y_patch_eb = [z_centers(idx_eb)'; flipud(z_centers(idx_eb)')];
%             fill(ax, x_patch_eb, y_patch_eb, royalBlue, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%             plot(ax, v0_eb_pct(idx_eb,2), z_centers(idx_eb), 'LineWidth', 2, 'Color', royalBlue);
%         end
% 
%         % Plot T0 Flood Envelope & Median
%         idx_fl = ~isnan(v0_fl_pct(:,1));
%         if any(idx_fl)
%             x_patch_fl = [v0_fl_pct(idx_fl,1); flipud(v0_fl_pct(idx_fl,3))];
%             y_patch_fl = [z_centers(idx_fl)'; flipud(z_centers(idx_fl)')];
%             fill(ax, x_patch_fl, y_patch_fl, royalBlue, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%             plot(ax, v0_fl_pct(idx_fl,2), z_centers(idx_fl), 'LineWidth', 2, 'Color', royalBlue);
%         end
%     end
% 
%     % --- Binning Logic for T1 ---
%     if ~isempty(valid1) && any(valid1)
%         v1_raw = v1(valid1);
%         z1_raw = z1_at_v(valid1);
% 
%         v1_eb_pct = NaN(numel(z_centers), nPct);
%         v1_fl_pct = NaN(numel(z_centers), nPct);
% 
%         for b = 1:numel(z_centers)
%             idx_bin = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
%             if any(idx_bin)
%                 v_bin = v1_raw(idx_bin);
%                 v_ebb1   = v_bin(v_bin < 0);
%                 v_flood1 = v_bin(v_bin >= 0);
% 
%                 if ~isempty(v_ebb1),   v1_eb_pct(b,:) = prctile(v_ebb1, pctiles); end
%                 if ~isempty(v_flood1), v1_fl_pct(b,:) = prctile(v_flood1, pctiles); end
%             end
%         end
% 
%         % Plot T1 Ebb Envelope & Median
%         idx_eb1 = ~isnan(v1_eb_pct(:,1)) & ~isnan(v1_eb_pct(:,2)) & ~isnan(v1_eb_pct(:,3));
%         if any(idx_eb1)
%             z_sub_eb1 = z_centers(idx_eb1);
%             x_patch_eb1 = [v1_eb_pct(idx_eb1,1); flipud(v1_eb_pct(idx_eb1,3))];
%             y_patch_eb1 = [z_sub_eb1(:); flipud(z_sub_eb1(:))];
%             fill(ax, x_patch_eb1, y_patch_eb1, baseOrange, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%             plot(ax, v1_eb_pct(idx_eb1,2), z_sub_eb1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);
%         end
% 
%         % Plot T1 Flood Envelope & Median
%         idx_fl1 = ~isnan(v1_fl_pct(:,1)) & ~isnan(v1_fl_pct(:,2)) & ~isnan(v1_fl_pct(:,3));
%         if any(idx_fl1)
%             z_sub_fl1 = z_centers(idx_fl1);
%             x_patch_fl1 = [v1_fl_pct(idx_fl1,1); flipud(v1_fl_pct(idx_fl1,3))];
%             y_patch_fl1 = [z_sub_fl1(:); flipud(z_sub_fl1(:))];
%             fill(ax, x_patch_fl1, y_patch_fl1, baseOrange, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%             plot(ax, v1_fl_pct(idx_fl1,2), z_sub_fl1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);
%         end
%     end
% 
%     % --- Formatting Axis Window ---
%     ax.XTick = [-1 0 1];
%     ax.XTickLabel = {}; 
%     ax.YTickLabel = {};
%     if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end 
%     % Show XTick labels on bottom row
%     if k > (nRows-1)*nCols
%         ax.XTickLabelMode = 'auto';
%     end
% 
%     % Show YTick labels for specific panels k = 10,11,12,13
%     if ismember(k, [10,11,12,13])
%         ax.XTickLabelMode = 'auto';
%     else
%         ax.XTickLabelMode = 'manual';
%     end
% 
%     ax.GridAlpha = 0.1;
%     ax.FontSize = 12;
%     grid on;
%     ylim([-2 4]);
%     xlim([-1.7 1.7]);
%     title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 13);
% 
%     % --- Text Labels for Ebb / Flood ---
%     xLimits = xlim(ax);
%     yLimits = ylim(ax);
%     xPadding = 0.03 * range(xLimits);
%     yPadding = 0.02 * range(yLimits);
% 
%     text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
%         'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
%         'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
% 
%     text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
%         'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
%         'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7]);
% 
%     % Reference Line
%     line([0 0], [-3 4], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off');
% 
%     % --- Groyne Gray Rectangles Configuration (Restored & Fixed Layering) ---
%     valid_k = [1,2,3,5,6];
%     if ismember(k, valid_k)
%         y1 = []; y2 = [];
%         if k == 1,   y1 = [-0.18 0.82];                      end
%         if k == 2,   y1 = [0.12 1.12]; y2 = [-1.21 -0.21]; end
%         if k == 3,   y1 = [0.64 1.64]; y2 = [0.35 1.35];     end
%         if k == 5,  y1 = [-1.73 -0.73];                      end
%         if k == 6,  y1 = [1.32  2.32];                       end
% 
%         rect_width = 0.06 * range(xLimits);
%         rect_color = [0.4 0.4 0.4]; %  gray
%         rect_alpha = 0.3;            % Solid presence
% 
%         xl = xLimits(1); xr = xLimits(2);
%         left_rect_x = [xl, xl + rect_width];
%         right_rect_x = [xr - rect_width, xr];
%         y_min_ax = yLimits(1); y_max_ax = yLimits(2);
% 
%         % Draw Left Groyne Patch
%         if ~isempty(y1)
%             yl_left = max(min(y1(1), y_max_ax), y_min_ax);
%             yh_left = max(min(y1(2), y_max_ax), y_min_ax);
%             if yh_left > yl_left
%                 x_poly_left = [left_rect_x(1), left_rect_x(2), left_rect_x(2), left_rect_x(1)];
%                 y_poly_left = [yl_left, yl_left, yh_left, yh_left];
%                 hGroyneL = fill(ax, x_poly_left, y_poly_left, rect_color, 'FaceAlpha', rect_alpha, ...
%                     'EdgeColor', 'none', 'HandleVisibility', 'off');
%                 uistack(hGroyneL, 'top'); % Force on top of blue/orange patches
%             end
%         end
% 
%         % Draw Right Groyne Patch
%         if ~isempty(y2)
%             yl_right = max(min(y2(1), y_max_ax), y_min_ax);
%             yh_right = max(min(y2(2), y_max_ax), y_min_ax);
%             if yh_right > yl_right
%                 x_poly_right = [right_rect_x(1), right_rect_x(2), right_rect_x(2), right_rect_x(1)];
%                 y_poly_right = [yl_right, yl_right, yh_right, yh_right];
%                 hGroyneR = fill(ax, x_poly_right, y_poly_right, rect_color, 'FaceAlpha', rect_alpha, ...
%                     'EdgeColor', 'none', 'HandleVisibility', 'off');
%                 uistack(hGroyneR, 'top'); % Force on top of blue/orange patches
%             end
%         end
%     end
%     hold(ax, 'off');
% end 
% 
% % Fill empty remaining tiles if any
% for empty_idx = (nToPlot+1):(maxTiles-1)
%     ax_emp = nexttile(empty_idx);
%     axis(ax_emp, 'off');
% end
% 
% % --- Build Unified Legend in the final Tile (Tile 16) ---
% axLeg = nexttile(14); 
% axis(axLeg, 'off'); 
% 
% hT0_patch = patch(axLeg, nan(1,4), nan(1,4), royalBlue, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
% hT1_patch = patch(axLeg, nan(1,4), nan(1,4), baseOrange, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
% hT1_med   = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);
% hT0_med   = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', royalBlue);
% hGroyne_patch = patch(axLeg, nan(1,4), nan(1,4), [0.5 0.5 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
% 
% % Safe color clamping
% for hh = [hT1_patch, hT0_patch, hT1_med, hT0_med, hGroyne_patch]
%     if isprop(hh, 'FaceColor')
%         c = get(hh, 'FaceColor');
%         if ~isempty(c) && ~any(isnan(c)), set(hh, 'FaceColor', min(max(c,0),1)); end
%     end
%     if isprop(hh, 'Color')
%         c = get(hh, 'Color');
%         if ~isempty(c) && ~any(isnan(c)), set(hh, 'Color', min(max(c,0),1)); end
%     end
% end
% 
% lgd = legend(axLeg, [hT0_med, hT1_med, hT0_patch, hT1_patch, hGroyne_patch], ...
%     {'T0 - median', 'T1 - median', 'T0 - 95% interval', 'T1 - 95% interval', 'Groyne'}, ...
%     'Location', 'west', 'FontSize', 12, 'Box', 'off', 'FontWeight', 'bold');
% 
% % export 
% outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% fname = fullfile(outDir, sprintf('Zimm_HW_vel_wGroynes.png'));
% % Save current figure as PNG with good resolution
% try
%     exportgraphics(gcf, fname, 'Resolution', 300);
% catch
%     % fallback to print if exportgraphics unavailable
%     try
%         print(gcf, fname, '-dpng', '-r300');
%     catch
%         % final fallback
%         saveas(gcf, fname);
%     end
% end
% 
% %% calculate difference at HW = 2 and HW=3 between max velocities an print result on each figure in text
% % High Water versus velocity (tiled format)
% nStations = numel(stationNames);
% nRows = 3;
% nCols = 4;
% 
% % figure with A4 Vertical proportions
% fig = figure('Name', 'High Water Velocities Tiled', 'Color', 'w');
% fig.Units = 'centimeters';
% fig.Position = [1, 1, 18, 18]; % Width=18cm, Height=25cm fits well on A4
% 
% % title plot
% t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');
% 
% % Global Title, X-Label, and Y-Label to the layout (t), not individual plots
% title(t, 'Velocity vs Water Level: Zimmerman', 'FontSize', 20, 'FontWeight', 'bold');
% xlabel(t, 'Velocity (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
% ylabel(t, 'Water Level NAP (m)', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % --- Binning Settings ---
% z_edges = -3:0.2:4.5; % 0.2m bins
% z_centers = z_edges(1:end-1) + 0.1;
% v_edges = -1.4:0.1:1.4; % 0.1m bins
% 
% % Loop stations and plot into tiles (limit to number of tiles available)
% maxTiles = nRows * nCols;
% nToPlot = min(nStations, maxTiles);
% for k = 1:nToPlot
% 
%     % Prepare T0 data (use WL_Zimm for T0)
%     if exist('WL_Zimm','var') && exist('WL_Zimm_time','var') && ~isempty(time0{k}) && ~isempty(vel0{k})
%         % WL_Zimm and WL_Zimm_time are per-station cell arrays from earlier;
%         % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
%         if iscell(WL_Zimm) && numel(WL_Zimm) >= k
%             zWL_cell = WL_Zimm{k};
%             twl_cell = WL_Zimm_time{k};
%         else
%             zWL_cell = WL_Zimm;
%             twl_cell = WL_Zimm_time;
%         end
%         tWL = twl_cell(:);
%         zWL = zWL_cell(:);
%         tV0 = time0{k}(:);
%         v0 = vel0{k}(:);
%         if isdatetime(tWL)
%             twl_num = datenum(tWL);
%         else
%             twl_num = tWL;
%         end
%         if isdatetime(tV0)
%             tv0_num = datenum(tV0);
%         else
%             tv0_num = tV0;
%         end
%         validWL = ~isnan(zWL) & ~isnan(twl_num);
%         if sum(validWL) >= 2
%             zWL_valid = zWL(validWL);
%             twl_valid = twl_num(validWL);
%             z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
%             valid0 = ~isnan(z0_at_v) & ~isnan(v0);
%         else
%             valid0 = false(size(v0));
%             z0_at_v = NaN(size(v0));
%         end
%     else
%         v0 = [];
%         z0_at_v = [];
%         valid0 = [];
%     end
% 
%     % Prepare T1 data (use WL_Zimm1 for T1)
%     if exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') && ~isempty(time1{k}) && ~isempty(vel1{k})
%         % WL_Zimm1 and WL_Zimm_time1 are per-station cell arrays from earlier;
%         % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
%         if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
%             zWL1_cell = WL_Zimm1{k};
%             twl1_cell = WL_Zimm_time1{k};
%         else
%             zWL1_cell = WL_Zimm1;
%             twl1_cell = WL_Zimm_time1;
%         end
%         tWL1 = twl1_cell(:);
%         zWL1 = zWL1_cell(:);
%         tV1 = time1{k}(:);
%         v1 = vel1{k}(:);
%         if isdatetime(tWL1)
%             twl1_num = datenum(tWL1);
%         else
%             twl1_num = tWL1;
%         end
%         if isdatetime(tV1)
%             tv1_num = datenum(tV1);
%         else
%             tv1_num = tV1;
%         end
%         validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
%         if sum(validWL1) >= 2
%             zWL1_valid = zWL1(validWL1);
%             twl1_valid = twl1_num(validWL1);
%             z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
%             valid1 = ~isnan(z1_at_v) & ~isnan(v1);
%         else
%             valid1 = false(size(v1));
%             z1_at_v = NaN(size(v1));
%         end
%     else
%         v1 = [];
%         z1_at_v = [];
%         valid1 = [];
%     end
% 
%     ax = nexttile;
%     hold on;
% 
%         % --- Binning Logic for T0: compute 5th, 50th, 95th percentiles per flood/ebb velocity ---
%         pctiles = [5 50 95];
%         nPct = numel(pctiles);
%         % colors for T0 (blue): single shade for 5 & 95, solid for 50 (slightly lighter)
%         royalBlue = [65, 105, 225] / 255;
%         lightBlue = [173, 216, 230] / 255;
%         color_edge0 = royalBlue;
%         color_med0 = lightBlue;
% 
%         if ~isempty(valid0) && any(valid0)
%             v0_raw = v0(valid0);
%             z0_raw = z0_at_v(valid0);
%         end
%         % Initialize separate matrices for Ebb (<0) and Flood (>0)
%         v0_eb_pct = NaN(numel(z_centers), nPct);
%         v0_fl_pct = NaN(numel(z_centers), nPct);
% 
%         for b = 1:numel(z_centers)
%             idx_bin = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
%             if any(idx_bin)
%                 v_bin = v0_raw(idx_bin);
% 
%                 % Split into ebb and flood components
%                 v_ebb = v_bin(v_bin < 0);
%                 v_flood = v_bin(v_bin >= 0);
% 
%                 if ~isempty(v_ebb),   v0_eb_pct(b,:) = prctile(v_ebb, pctiles); end
%                 if ~isempty(v_flood), v0_fl_pct(b,:) = prctile(v_flood, pctiles); end
%             end
%         end
% 
%         % --- Plot Ebb Envelope & Median ---
%         baseOrange = [0.8500 0.3250 0.0980];
%         idx_eb = ~isnan(v0_eb_pct(:,1));
%         if any(idx_eb)
%             x_patch_eb = [v0_eb_pct(idx_eb,1); flipud(v0_eb_pct(idx_eb,3))];
%             y_patch_eb = [z_centers(idx_eb)'; flipud(z_centers(idx_eb)')];
%             fill(ax, x_patch_eb, y_patch_eb, royalBlue, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%             plot(ax, v0_eb_pct(idx_eb,2), z_centers(idx_eb), 'LineWidth', 2, 'Color', royalBlue);
%         end
% 
%         % --- Plot Flood Envelope & Median ---
%         idx_fl = ~isnan(v0_fl_pct(:,1));
%         if any(idx_fl)
%             x_patch_fl = [v0_fl_pct(idx_fl,1); flipud(v0_fl_pct(idx_fl,3))];
%             y_patch_fl = [z_centers(idx_fl)'; flipud(z_centers(idx_fl)')];
%             fill(ax, x_patch_fl, y_patch_fl, royalBlue, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%             plot(ax, v0_fl_pct(idx_fl,2), z_centers(idx_fl), 'LineWidth', 2, 'Color', royalBlue);
%         end
% 
%         % --- Binning Logic for T1: compute 5th, 50th, 95th percentiles per WL bin ---
%         if ~isempty(valid1) && any(valid1)
%             v1_raw = v1(valid1);
%             z1_raw = z1_at_v(valid1);
% 
%             % Initialize separate matrices for Ebb (<0) and Flood (>=0)
%             v1_eb_pct = NaN(numel(z_centers), nPct);
%             v1_fl_pct = NaN(numel(z_centers), nPct);
% 
%             for b = 1:numel(z_centers)
%                 idx_bin = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
%                 if any(idx_bin)
%                     v_bin = v1_raw(idx_bin);
% 
%                     % Split into ebb and flood components
%                     v_ebb1   = v_bin(v_bin < 0);
%                     v_flood1 = v_bin(v_bin >= 0);
% 
%                     if ~isempty(v_ebb1),   v1_eb_pct(b,:) = prctile(v_ebb1, pctiles); end
%                     if ~isempty(v_flood1), v1_fl_pct(b,:) = prctile(v_flood1, pctiles); end
%                 end
%             end
% 
%             % --- Plot T1 Ebb Envelope & Median (Orange) ---
%             idx_eb1 = ~isnan(v1_eb_pct(:,1)) & ~isnan(v1_eb_pct(:,2)) & ~isnan(v1_eb_pct(:,3));
%             if any(idx_eb1)
%                 z_sub_eb1 = z_centers(idx_eb1);
%                 x_patch_eb1 = [v1_eb_pct(idx_eb1,1); flipud(v1_eb_pct(idx_eb1,3))];
%                 y_patch_eb1 = [z_sub_eb1(:); flipud(z_sub_eb1(:))];
% 
%                 fill(ax, x_patch_eb1, y_patch_eb1, baseOrange, ...
%                     'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%                 plot(ax, v1_eb_pct(idx_eb1,2), z_sub_eb1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
%                     'DisplayName', 'T1 Ebb Median');
%             end
% 
%             % --- Plot T1 Flood Envelope & Median (Orange) ---
%             idx_fl1 = ~isnan(v1_fl_pct(:,1)) & ~isnan(v1_fl_pct(:,2)) & ~isnan(v1_fl_pct(:,3));
%             if any(idx_fl1)
%                 z_sub_fl1 = z_centers(idx_fl1);
%                 x_patch_fl1 = [v1_fl_pct(idx_fl1,1); flipud(v1_fl_pct(idx_fl1,3))];
%                 y_patch_fl1 = [z_sub_fl1(:); flipud(z_sub_fl1(:))];
% 
%                 fill(ax, x_patch_fl1, y_patch_fl1, baseOrange, ...
%                     'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
%                 plot(ax, v1_fl_pct(idx_fl1,2), z_sub_fl1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
%                     'DisplayName', 'T1 Flood Median');
%             end
%         end
% 
%         % difference in 95% at HW = 3 and HW = 2
%         % Apply for current station k: ensure indices exist and use safe indexing.
%         % Determine bin indices corresponding to HW ~2 and HW ~3 based on z_centers.
%         % Use nearest-bin approach to find indices for HW=2 and HW=3.
%         [~, idx_HW2] = min(abs(z_centers - 2));
%         [~, idx_HW3] = min(abs(z_centers - 3));
% 
%         % Initialize outputs (NaN if not available)
%         % Ensure outputs exist for saving outside the loop by using cell arrays indexed by k
%         if ~exist('fl_HW2_95diff_all', 'var')
%             fl_HW2_95diff_all = nan(nStations,1);
%             fl_HW3_95diff_all = nan(nStations,1);
%             eb_HW2_95diff_all = nan(nStations,1);
%             eb_HW3_95diff_all = nan(nStations,1);
%         end
% 
%         % Initialize current-values (NaN by default)
%         fl_HW2_95diff = NaN;
%         fl_HW3_95diff = NaN;
%         eb_HW2_95diff = NaN;
%         eb_HW3_95diff = NaN;
% 
%         % Compute flood differences if percentiles exist
%         if exist('v1_fl_pct','var') && exist('v0_fl_pct','var')
%             if idx_HW2 >= 1 && idx_HW2 <= size(v1_fl_pct,1) && idx_HW2 <= size(v0_fl_pct,1)
%                 if ~isnan(v1_fl_pct(idx_HW2,3)) && ~isnan(v0_fl_pct(idx_HW2,3))
%                     fl_HW2_95diff = v1_fl_pct(idx_HW2,3) - v0_fl_pct(idx_HW2,3);
%                 end
%             end
%             if idx_HW3 >= 1 && idx_HW3 <= size(v1_fl_pct,1) && idx_HW3 <= size(v0_fl_pct,1)
%                 if ~isnan(v1_fl_pct(idx_HW3,3)) && ~isnan(v0_fl_pct(idx_HW3,3))
%                     fl_HW3_95diff = v1_fl_pct(idx_HW3,3) - v0_fl_pct(idx_HW3,3);
%                 end
%             end
%         end
% 
%         % Compute ebb differences if percentiles exist
%         if exist('v1_eb_pct','var') && exist('v0_eb_pct','var')
%             if idx_HW2 >= 1 && idx_HW2 <= size(v1_eb_pct,1) && idx_HW2 <= size(v0_eb_pct,1)
%                 if ~isnan(v1_eb_pct(idx_HW2,3)) && ~isnan(v0_eb_pct(idx_HW2,3))
%                     eb_HW2_95diff = v1_eb_pct(idx_HW2,3) - v0_eb_pct(idx_HW2,3);
%                 end
%             end
%             if idx_HW3 >= 1 && idx_HW3 <= size(v1_eb_pct,1) && idx_HW3 <= size(v0_eb_pct,1)
%                 if ~isnan(v1_eb_pct(idx_HW3,3)) && ~isnan(v0_eb_pct(idx_HW3,3))
%                     eb_HW3_95diff = v1_eb_pct(idx_HW3,3) - v0_eb_pct(idx_HW3,3);
%                 end
%             end
%         end
% 
%         % Save current station results into arrays for use outside the loop
%         % Assume loop index is k and total stations is nStations (predefined)
%         if exist('k','var')
%             fl_HW2_95diff_all(k) = fl_HW2_95diff;
%             fl_HW3_95diff_all(k) = fl_HW3_95diff;
%             eb_HW2_95diff_all(k) = eb_HW2_95diff;
%             eb_HW3_95diff_all(k) = eb_HW3_95diff;
%         end
% 
%         %--plotting HW text (no helper functions)--
%         % Prepare formatted strings safely handling NaN values
%         if isnan(eb_HW_3_95diff)
%             s_eb_HW3 = 'ebb HW=3 95% diff: N/A';
%         else
%             s_eb_HW3 = ['ebb HW=3 95% diff: ' num2str(eb_HW_3_95diff)];
%         end
% 
%         if isnan(eb_HW_2_95diff)
%             s_eb_HW2 = 'ebb HW=2 95% diff: N/A';
%         else
%             s_eb_HW2 = ['ebb HW=2 95% diff: ' num2str(eb_HW_2_95diff)];
%         end
% 
%         if isnan(fl_HW3_95diff)
%             s_fl_HW3 = 'fld HW=3 95% diff: N/A';
%         else
%             s_fl_HW3 = ['fld HW=3 95% diff: ' num2str(fl_HW3_95diff)];
%         end
% 
%         if isnan(fl_HW2_95diff)
%             s_fl_HW2 = 'fld HW=2 95% diff: N/A';
%         else
%             s_fl_HW2 = ['fld HW=2 95% diff: ' num2str(fl_HW2_95diff)];
%         end
% 
%         % Choose positions in normalized axes units (top-left block)
%         % Place as text inside the axis near the top-left corner
%         xLimits = xlim(ax); yLimits = ylim(ax);
%         xText = xLimits(1) + 0.03*range(xLimits);
%         yTop = yLimits(2) - 0.05*range(yLimits);
% 
%         text(xText, yTop, s_eb_HW3, 'Parent', ax, 'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');
%         text(xText, yTop - 0.12*range(yLimits), s_eb_HW2, 'Parent', ax, 'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');
%         text(xText, yTop - 0.24*range(yLimits), s_fl_HW3, 'Parent', ax, 'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');
%         text(xText, yTop - 0.36*range(yLimits), s_fl_HW2, 'Parent', ax, 'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');
% 
%         % --- Formatting ---
%         ax.XTick = [-1 0 1];
%         ax.XTickLabel = {}; 
%         ax.YTickLabel = {};
%         if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end % Show left column
%         if k > (nRows-1)*nCols, ax.XTickLabelMode = 'auto'; end   % Show bottom row
%         ax.GridAlpha = 0.1;
%         ax.FontSize = 12;
% 
%         set(gca, 'FontSize', 11);
%         grid on;
%         ylim([-1.6 4]);
%         xlim([-1.5 1.5]);
%         title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 13);
%         % legend('show', 'Location', 'best');
% 
%         hold off;
% 
%         % --text for flood and ebb--
%         % add text for "flood" and "ebb" on each tile at bottom
%         xLimits = xlim(ax);
%         yLimits = ylim(ax);
%         xPadding = 0.03 * range(xLimits);
%         yPadding = 0.02 * range(yLimits);
% 
%         % Left-bottom (flood)
%         text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
%             'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
%             'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7], ...
%             'Interpreter', 'none');
% 
%         % Right-bottom (ebb)
%         text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
%             'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
%             'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7], ...
%             'Interpreter', 'none');
% 
%     % Reference line
%     line([0 0], [-3 4], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off')
% 
%     % Put legend in 12th tile (tile index 12 in a 4x3 layout)
%     nexttile(12);
%     axis off;
%     % Create an invisible axes to host the legend centered within the tile
%     hAx = gca;
%     hAx.Visible = 'off';
% 
% end 
% 
% axLeg = nexttile(t, 12); 
% axis(axLeg, 'off'); % Hide the axes box
% 
% % Create dummy legend entries matching the shaded region + median line for T1
% hT0_patch = patch(axLeg, nan(1,4), nan(1,4), royalBlue, 'FaceAlpha', 0.2, ...
%     'EdgeColor', 'none');
% hT1_patch = patch(axLeg, nan(1,4), nan(1,4), baseOrange, 'FaceAlpha', 0.2, ...
%     'EdgeColor', 'none');
% 
% % Median line (50th) for T1
% hT1_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);
% 
% % Also create corresponding dummy entries for T0 style if desired (kept from original pattern)
% hT0_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', royalBlue);
% 
% % Ensure colors are clipped to [0,1]
% for hh = [hT1_patch, hT0_patch, hT1_med, hT0_med]
%     if isprop(hh, 'FaceColor')
%         c = get(hh, 'FaceColor');
%         if ~isempty(c) && ~any(isnan(c))
%             c = min(max(c,0),1);
%             set(hh, 'FaceColor', c);
%         end
%     end
%     if isprop(hh, 'Color')
%         c = get(hh, 'Color');
%         if ~isempty(c) && ~any(isnan(c))
%             c = min(max(c,0),1);
%             set(hh, 'Color', c);
%         end
%     end
% end
% 
% % Build legend using the patch handle for the shaded region and the median line
% lgd = legend(axLeg, [hT0_med, hT1_med, hT0_patch, hT1_patch], ...
%     {'T0 - median', 'T1 - median', 'T0 - 95% interval', 'T1 - 95% interval'}, ...
%     'Location', 'west', 'FontSize', 10, 'Box', 'off', 'FontWeight', 'bold');
% 
% % 5. Optional: Final layout tightening
% t.Padding = 'compact';
% t.TileSpacing = 'compact';
% 
% % %% export figure 
% % outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% % if ~exist(outDir, 'dir')
% %     mkdir(outDir);
% % end
% % fname = fullfile(outDir, sprintf('Zimmpctshaded_HW_vel.png'));
% % % Save current figure as PNG with good resolution
% % try
% %     exportgraphics(gcf, fname, 'Resolution', 300);
% % catch
% %     % fallback to print if exportgraphics unavailable
% %     try
% %         print(gcf, fname, '-dpng', '-r300');
% %     catch
% %         % final fallback
% %         saveas(gcf, fname);
% %     end
% % end
% 
% %% spatial changes
% % Plot fl_HW2_95diff_all as markers on the current figure using specified style.
% hold on;
% 
% % Define plotting style (from request)
% colors = {'k','r'};
% shapes = {'o','s'};
% locations = {'Bottom','Top'};
% 
% figure();
% % Build color scale bounds from eb_HW3_95diff_all if available, otherwise fallback
% CS = [1e9 -1e9];
% if exist('eb_HW3_95diff_all','var')
%     % eb_HW3_95diff_all might be cell/struct/numeric; handle common cases
%     if iscell(eb_HW3_95diff_all)
%         for i = 1:numel(eb_HW3_95diff_all)
%             v = eb_HW3_95diff_all{i};
%             if isempty(v), continue; end
%             if isstruct(v)
%                 fn1 = fieldnames(v);
%                 for fn1i = 1:numel(fn1)
%                     fn2 = fieldnames(v.(fn1{fn1i}));
%                     for fn2i = 1:numel(fn2)
%                         vv = v.(fn1{fn1i}).(fn2{fn2i});
%                         if isnumeric(vv) && ~isempty(vv)
%                             CS(1) = min(CS(1), min(vv(:)));
%                             CS(2) = max(CS(2), max(vv(:)));
%                         end
%                     end
%                 end
%             elseif isnumeric(v)
%                 CS(1) = min(CS(1), min(v(:)));
%                 CS(2) = max(CS(2), max(v(:)));
%             end
%         end
%     elseif isstruct(eb_HW3_95diff_all)
%         fn1 = fieldnames(eb_HW3_95diff_all);
%         for fn1i = 1:numel(fn1)
%             fn2 = fieldnames(eb_HW3_95diff_all.(fn1{fn1i}));
%             for fn2i = 1:numel(fn2)
%                 v = eb_HW3_95diff_all.(fn1{fn1i}).(fn2{fn2i});
%                 if isnumeric(v) && ~isempty(v)
%                     CS(1) = min(CS(1), min(v(:)));
%                     CS(2) = max(CS(2), max(v(:)));
%                 end
%             end
%         end
%     elseif isnumeric(eb_HW3_95diff_all)
%         CS(1) = min(CS(1), min(eb_HW3_95diff_all(:)));
%         CS(2) = max(CS(2), max(eb_HW3_95diff_all(:)));
%     end
% 
%     if isfinite(CS(1)) && isfinite(CS(2))
%         % Round to nice ticks (nearest 0.1 if small range, otherwise nearest integer/10)
%         rangeVal = CS(2) - CS(1);
%         if rangeVal <= 1
%             CS = [floor(CS(1)*10)/10, ceil(CS(2)*10)/10];
%         else
%             CS = [floor(CS(1)), ceil(CS(2))];
%         end
%     else
%         CS = [-0.5 0.5];
%     end
% else
%     CS = [-0.5 0.5];
% end
% 
% % Define bin edges and corresponding colormap as in request
% CS_binedges = -0.5:0.1:0.5;
% CS_abs_max = max(abs(CS_binedges));
% CS_stepsz = unique(diff(CS_binedges));
% % CS_range = -CS_abs_max:CS_stepsz:CS_abs_max;
% 
% % Use diverging map and prepare marker colors
% cm_full = fliplr(cbrewer('div','RdYlBu',length(CS_range))')';
% cm_markers = cm_full;
% % clamp to [0,1]
% cm_markers = min(max(cm_markers,0),1);
% 
% % Remove excess colors to match requested behaviour
% index = find(~ismember(CS_range,CS_binedges));
% c1 = 0; c2 = 0;
% % for i = 1:length(index)
% %     if ~mod(i,2)
% %         cm_markers(end-c1,:) = [];
% %         c1 = c1+1;
% %     else
% %         cm_markers(1+c2,:) = [];
% %         c2 = c2+1;
% %     end
% % end
% 
% % Set color for zero bin to white
% [~, zeroIndex] = min(abs(CS_binedges));
% if zeroIndex <= size(cm_markers,1)
%     cm_markers(zeroIndex,:) = [1 1 1];
% end
% % remove last color so ticks/blocks match per original pattern
% if ~isempty(cm_markers)
%     cm_markers(end,:) = [];
% end
% 
% % Determine number of points (robust to cell / numeric inputs)
% nPoints = max([numel(RDx_T0), numel(RDx_T1), numel(fl_HW2_95diff_all)]);
% X = nan(nPoints,1);
% Y = nan(nPoints,1);
% C = nan(nPoints,1);
% 
% % Fill positions and color values (color from fl_HW2_95diff_all if available)
% for s = 1:nPoints
%     % Position: prefer T0, fallback to T1
%     if numel(RDx_T0) >= s && ~isempty(RDx_T0{s}) && ~any(isnan(RDx_T0{s}))
%         rx = RDx_T0{s}; ry = RDy_T0{s};
%         if numel(rx) > 1, rx = rx(1); end
%         if numel(ry) > 1, ry = ry(1); end
%         X(s) = rx; Y(s) = ry;
%     elseif numel(RDx_T1) >= s && ~isempty(RDx_T1{s}) && ~any(isnan(RDx_T1{s}))
%         rx = RDx_T1{s}; ry = RDy_T1{s};
%         if numel(rx) > 1, rx = rx(1); end
%         if numel(ry) > 1, ry = ry(1); end
%         X(s) = rx; Y(s) = ry;
%     else
%         X(s) = NaN; Y(s) = NaN;
%     end
% 
%     % Assign color value C(s) from available variables, robust to multiple possible names
%     % Prefer fl_HW2_95diff_all; fall back to FL_HW2_95diff_all, fl_hw2_95diff_all, or DELTA_U entry if present.
%     val = NaN;
%     % try common variants
%     if exist('fl_HW2_95diff_all','var')
%         if iscell(fl_HW2_95diff_all) && numel(fl_HW2_95diff_all) >= s
%             v = fl_HW2_95diff_all{s};
%             if isnumeric(v) && ~isempty(v)
%                 val = v(1);
%             end
%         elseif isnumeric(fl_HW2_95diff_all) && numel(fl_HW2_95diff_all) >= s
%             val = fl_HW2_95diff_all(s);
%         end
%     end
%     if isnan(val) && exist('FL_HW2_95diff_all','var')
%         if iscell(FL_HW2_95diff_all) && numel(FL_HW2_95diff_all) >= s
%             v = FL_HW2_95diff_all{s};
%             if isnumeric(v) && ~isempty(v)
%                 val = v(1);
%             end
%         elseif isnumeric(FL_HW2_95diff_all) && numel(FL_HW2_95diff_all) >= s
%             val = FL_HW2_95diff_all(s);
%         end
%     end
%     if isnan(val) && exist('fl_hw2_95diff_all','var')
%         if iscell(fl_hw2_95diff_all) && numel(fl_hw2_95diff_all) >= s
%             v = fl_hw2_95diff_all{s};
%             if isnumeric(v) && ~isempty(v)
%                 val = v(1);
%             end
%         elseif isnumeric(fl_hw2_95diff_all) && numel(fl_hw2_95diff_all) >= s
%             val = fl_hw2_95diff_all(s);
%         end
%     end
% 
%     % Final fallback: try DELTA_U structure (use first numeric field found)
%     if isnan(val) && exist('DELTA_U','var') && iscell(DELTA_U) && numel(DELTA_U) >= 2
%         fn1 = fieldnames(DELTA_U{2});
%         for fn1i = 1:length(fn1)
%             fn2 = fieldnames(DELTA_U{2}.(fn1{fn1i}));
%             for fn2i = 1:length(fn2)
%                 v = DELTA_U{2}.(fn1{fn1i}).(fn2{fn2i});
%                 if isnumeric(v) && ~isempty(v)
%                     if numel(v) >= s
%                         val = v(min(s,end));
%                         break;
%                     else
%                         val = v(1);
%                         break;
%                     end
%                 end
%             end
%             if ~isnan(val), break; end
%         end
%     end
% 
%     if ~isnumeric(val) || isempty(val)
%         C(s) = NaN;
%     else
%         C(s) = val;
%     end
% end
% 
% % Map color values C to discrete bins CS_binedges and then to cm_markers
% valid = ~isnan(X) & ~isnan(Y) & ~isnan(C);
% if any(valid)
%     % compute bin indices for each valid C
%     [~,~,binIdx] = histcounts(C(valid), [-inf, CS_binedges(1:end-1)+diff(CS_binedges)/2, inf]);
%     % guard binIdx range against cm_markers size
%     nColors = size(cm_markers,1);
%     binIdx(binIdx < 1) = 1;
%     binIdx(binIdx > nColors) = nColors;
% 
%     % Plot each point using mapped color and requested shape (use shapes{1} and colors{1} per request)
%     for ii = 1:sum(valid)
%         xi = X(valid); yi = Y(valid); ci = binIdx;
%         col = cm_markers(ci(ii),:);
%         scatter(xi(ii), yi(ii), 60, 'Marker', shapes{1}, 'MarkerEdgeColor', colors{1}, ...
%             'MarkerFaceColor', col, 'LineWidth', 0.5);
%     end
% 
%     % Create colorbar matching CS_binedges
%     colormap(cm_markers);
%     cb = colorbar('Ticks', linspace(0,1,length(CS_binedges)), ...
%         'TickLabels', arrayfun(@num2str, CS_binedges, 'UniformOutput', false));
%     cb.Label.String = 'fl\_HW2\_95diff\_all';
%     cb.FontSize = 12;
% end
% 
% hold off;
% %% %% plotting profile and velocity side by side (modified to include GeoTIFF subplot)
% figure();
% 
% % Subplot 1: Aerial with box of interest (GeoTIFF + lines)
% subplot(1,3,1);
% imshow(I);
% 
% % Subplot 2: Cross Shore Profile (elevation vs distance)
% subplot(1,3,2);
% hold on;
% plot(xdist*20, vals1, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 4, 'HandleVisibility', 'off');
% plot(84, -1, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor',  'b', 'DisplayName', '0702');
% plot(270, 1.4, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'DisplayName', '0703');
% % plot(40, -1.160, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor',  'b', 'DisplayName', '0902');
% % plot(305, 1.0, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'DisplayName', '0903');
% legend('show');
% % hLeg = legend;
% % set(hLeg, 'FontSize', 16);
% hold off;
% % xlim([0 600]);
% ylim([-2.5 5]);
% xlabel('Distance (m)', 'FontSize', 18);
% ylabel('Elevation NAP (m)', 'FontSize', 18);
% title('Profile', 'FontSize', 28);
% set(gca, 'FontSize', 20);
% 
% % Subplot 3: Velocity vs Water Level for stations 
% subplot(1,3,3);
% hold on;
% for k = 1:nStations
%     % check station name matches (robust to stationNames content)
%     if ischar(stationNames{k}) || isstring(stationNames{k})
%         name = char(stationNames{k});
%     else
%         continue
%     end
%     if contains(name, '0702') || contains(name, '0703')
%         % Prepare T0 data
%         if isempty(time0{k}) || isempty(vel0{k}) || isempty(WL_Zimm_time) || isempty(WL_Zimm)
%             v0 = [];
%             z0_at_v = [];
%             valid0 = false(0,1);
%         else
%             tV0 = time0{k}(:);
%             v0 = vel0{k}(:);
%             tWL = WL_Zimm_time(:);
%             zWL = WL_Zimm(:);
%             if isdatetime(tWL)
%                 twl_num = datenum(tWL);
%             else
%                 twl_num = tWL;
%             end
%             if isdatetime(tV0)
%                 tv0_num = datenum(tV0);
%             else
%                 tv0_num = tV0;
%             end
%             validWL = ~isnan(zWL) & ~isnan(twl_num);
%             if sum(validWL) >= 2
%                 zWL_valid = zWL(validWL);
%                 twl_valid = twl_num(validWL);
%                 z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
%                 valid0 = ~isnan(z0_at_v) & ~isnan(v0);
%             else
%                 v0 = [];
%                 z0_at_v = [];
%                 valid0 = false(size(v0));
%             end
%         end
% 
%         % Prepare T1 data (use WL_Zimm_time1 / WL_Zimm1 if available)
%         if isempty(time1{k}) || isempty(vel1{k}) || isempty(WL_Zimm_time1) || isempty(WL_Zimm1)
%             v1 = [];
%             z1_at_v = [];
%             valid1 = false(0,1);
%         else
%             tV1 = time1{k}(:);
%             v1 = vel1{k}(:);
%             tWL1 = WL_Zimm_time1(:);
%             zWL1 = WL_Zimm1(:);
%             if isdatetime(tWL1)
%                 twl1_num = datenum(tWL1);
%             else
%                 twl1_num = tWL1;
%             end
%             if isdatetime(tV1)
%                 tv1_num = datenum(tV1);
%             else
%                 tv1_num = tV1;
%             end
%             validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
%             if sum(validWL1) >= 2
%                 zWL1_valid = zWL1(validWL1);
%                 twl1_valid = twl1_num(validWL1);
%                 z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
%                 valid1 = ~isnan(z1_at_v) & ~isnan(v1);
%             else
%                 v1 = [];
%                 z1_at_v = [];
%                 valid1 = false(size(v1));
%             end
%         end
% 
%         % If neither has valid data, skip
%         if (~any(valid0(:)) && ~any(valid1(:)))
%             continue;
%         end
% 
%         % plot with specific colors for 0902 (blue) and 0903 (red), include T0 and T1
%         if contains(name, '0702')
%             colT0 = 'b'; %dark blue
%             colT1 = [0.3010 0.7450 0.9330]; %light blue
%         else % 0903
%             colT0 = 'r';    % red
%             colT1 = [1.0 0.6 0.6];    % lighter red (pinkish)
%         end
%         plotted = false;
%         if any(valid0(:))
%             plot(v0(valid0), z0_at_v(valid0), 'o-','LineWidth',1.2, 'Color', colT0, 'DisplayName', sprintf('%s T0', stationNames_title{k}));
%             plotted = true;
%         end
%         % if any(valid1(:))
%         %     plot(v1(valid1), z1_at_v(valid1), 's-','LineWidth',1.2, 'Color', colT1, 'DisplayName', sprintf('%s T1', stationNames_title{k}));
%         %     plotted = true;
%         % end
%         if ~plotted
%             continue;
%         end
%     end
% end
% ylabel('Water Level NAP (m)', 'FontSize', 18);
% xlabel('Velocity (m/s)', 'FontSize', 18);
% title('Velocity vs Water Level', 'FontSize', 20);
% set(gca, 'FontSize', 20);
% ylim([-2.5 5]);
% legend('show');
% hLeg = legend;
% set(hLeg, 'FontSize', 16, 'Location', 'best');
% hold off;
% 
% % Add one large centered title for the entire figure (suptitle-like)
% sgtitle('Zimm (0702 & 0703) Velocities on Cross Shore Profile', 'FontSize', 26, 'FontWeight', 'bold');

% %% export figure (optional, commented out)
% 
% outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% % build a safe filename from station name
% safeName = matlab.lang.makeValidName(stationNames{k});
% % timestamp to avoid overwriting (optional)
% % timestamp = datestr(now,'yyyymmdd_HHMMSS');
% fname = fullfile(outDir, sprintf('%s_XS_VelvsWL.png', safeName));
% % Save current figure as PNG with good resolution
% try
%     exportgraphics(gcf, fname, 'Resolution', 300);
% catch
%     % fallback to print if exportgraphics unavailable
%     try
%         print(gcf, fname, '-dpng', '-r300');
%     catch
%         % final fallback
%         saveas(gcf, fname);
%     end
% end