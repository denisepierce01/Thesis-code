close all
clear all
clc

%% ADCP data
load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')

%% ADCP Observations
% Load  data 
f0 = {};
f1 = {};
if isfield(ADCP, 'ZIMMERMAN') && isstruct(ADCP.ZIMMERMAN)
    if isfield(ADCP.ZIMMERMAN, 'T0') && isstruct(ADCP.ZIMMERMAN.T0)
        f0 = fieldnames(ADCP.ZIMMERMAN.T0);
    end
    if isfield(ADCP.ZIMMERMAN, 'T1') && isstruct(ADCP.ZIMMERMAN.T1)
        f1 = fieldnames(ADCP.ZIMMERMAN.T1);
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
vel0_da = cell(size(stationNames));
dir0_da = cell(size(stationNames));
RDx_T0 = cell(size(stationNames));
RDy_T0 = cell(size(stationNames));

% Initialize time1, vel1_da, dir1_da in case missing
time1 = cell(size(stationNames));
vel1_da = cell(size(stationNames));
dir1_da = cell(size(stationNames));
RDx_T1 = cell(size(stationNames));
RDy_T1 = cell(size(stationNames));

for k = 1:nStations
    s = stationNames{k};
    % Safely access fields; if a field or subfield is missing, set empty
    if isfield(ADCP.ZIMMERMAN.T0, s) && ...
       isfield(ADCP.ZIMMERMAN.T0.(s), 't_CET') && ...
       isfield(ADCP.ZIMMERMAN.T0.(s), 'Umag_da') && ...
       isfield(ADCP.ZIMMERMAN.T0.(s), 'Udir_da') && ...
       isfield(ADCP.ZIMMERMAN.T0.(s).META, 'RDX' ) && ...
       isfield(ADCP.ZIMMERMAN.T0.(s).META, 'RDY' ) 
        % Read all available columns
        time0{k} = ADCP.ZIMMERMAN.T0.(s).t_CET;
        vel0_da{k} = ADCP.ZIMMERMAN.T0.(s).Umag_da;
        dir0_da{k} = ADCP.ZIMMERMAN.T0.(s).Udir_da;
        RDx_T0{k} = ADCP.ZIMMERMAN.T0.(s).META.RDX;
        RDy_T0{k} = ADCP.ZIMMERMAN.T0.(s).META.RDY;
        % Apply sign convention: directions 20-200 => positive (flood),
        % all other directions => negative
        if ~isempty(dir0_da{k}) && ~isempty(vel0_da{k})
            % Ensure vectors same length; operate elementwise
            n0 = min(numel(dir0_da{k}), numel(vel0_da{k}));
            dirs = dir0_da{k}(:);
            vels = vel0_da{k}(:);
            % Truncate if lengths differ
            dirs = dirs(1:n0);
            vels = vels(1:n0);
            signFactor = -ones(n0,1); % default negative
            % Set positive for directions in [20,200] (inclusive)
            signFactor(dirs >= 20 & dirs <= 200) = 1;
            vel0_da{k} = (vels .* signFactor);
            % If original arrays were longer, preserve remaining values as-is
            if numel(ADCP.ZIMMERMAN.T0.(s).Umag_da) > n0
                vel0_da{k} = [vel0_da{k}; ADCP.ZIMMERMAN.T0.(s).Umag_da(n0+1:end)];
            end
        end
    else
        time0{k} = [];
        vel0_da{k} = [];
        dir0_da{k} = [];
    end
end

% Process T1 stations (safely) - read all columns
for k = 1:numel(stationNames)
    s = stationNames{k};
    if isfield(ADCP.ZIMMERMAN.T1, s) && ...
       isfield(ADCP.ZIMMERMAN.T1.(s), 't_CET') && ...
       isfield(ADCP.ZIMMERMAN.T1.(s), 'Umag_da') && ...
       isfield(ADCP.ZIMMERMAN.T1.(s), 'Udir_da') && ...
       isfield(ADCP.ZIMMERMAN.T1.(s).META, 'RDX' ) && ...
       isfield(ADCP.ZIMMERMAN.T1.(s).META, 'RDY' ) 
        time1{k} = ADCP.ZIMMERMAN.T1.(s).t_CET;
        vel1_da{k} = ADCP.ZIMMERMAN.T1.(s).Umag_da;
        dir1_da{k} = ADCP.ZIMMERMAN.T1.(s).Udir_da;
        RDx_T1{k} = ADCP.ZIMMERMAN.T1.(s).META.RDX;
        RDy_T1{k} = ADCP.ZIMMERMAN.T1.(s).META.RDY;
        % Apply sign convention: directions 20-200 => positive (flood),
        % all other directions => negative
        if ~isempty(dir1_da{k}) && ~isempty(vel1_da{k})
            n1 = min(numel(dir1_da{k}), numel(vel1_da{k}));
            dirs = dir1_da{k}(:);
            vels = vel1_da{k}(:);
            dirs = dirs(1:n1);
            vels = vels(1:n1);
            signFactor = -ones(n1,1);
            signFactor(dirs >= 20 & dirs <= 200) = 1;
            vel1_da{k} = (vels .* signFactor);
            if numel(ADCP.ZIMMERMAN.T1.(s).Umag_da) > n1
                vel1_da{k} = [vel1_da{k}; ADCP.ZIMMERMAN.T1.(s).Umag_da(n1+1:end)];
            end
        end
    else
        time1{k} = [];
        vel1_da{k} = [];
        dir1_da{k} = [];
    end
end

%% water level Zimm
WL_Zimm =  ADCP.ZIMMERMAN.T0.MP0104.WL_from_external_source;
WL_Zimm_time =  ADCP.ZIMMERMAN.T0.MP0104.t_CET;
WL_Zimm1 =  ADCP.ZIMMERMAN.T1.MP0104.WL_from_external_source;
WL_Zimm_time1 =  ADCP.ZIMMERMAN.T1.MP0104.t_CET;

%% creating loop - collect WL per station for T0 and T1
% Initialize as cell arrays sized to stationNames
nStations = numel(stationNames);
WL_Zimm = []; WL_Zimm_time = [];
WL_Zimm_cell = repmat({[]}, 1, nStations);
WL_Zimm_time_cell = repmat({[]}, 1, nStations);
WL_Zimm1 = repmat({[]}, 1, nStations);
WL_Zimm_time1 = repmat({[]}, 1, nStations);

for k = 1:nStations
    s = stationNames{k};
    % T0
    if isfield(ADCP.ZIMMERMAN, 'T0') && isfield(ADCP.ZIMMERMAN.T0, s) ...
            && isfield(ADCP.ZIMMERMAN.T0.(s), 'WL_from_external_source') ...
            && isfield(ADCP.ZIMMERMAN.T0.(s), 't_CET')
        WLtmp = ADCP.ZIMMERMAN.T0.(s).WL_from_external_source;
        WLttmp = ADCP.ZIMMERMAN.T0.(s).t_CET;
        if ~isempty(WLtmp), WLtmp = WLtmp(:); end
        if ~isempty(WLttmp), WLttmp = WLttmp(:); end
        WL_Zimm_cell{k} = WLtmp;
        WL_Zimm_time_cell{k} = WLttmp;
        % also append to overall vectors for T0
        if ~isempty(WLtmp)
            WL_Zimm = [WL_Zimm; WLtmp];
        end
        if ~isempty(WLttmp)
            WL_Zimm_time = [WL_Zimm_time; WLttmp];
        end
    else
        WL_Zimm_cell{k} = [];
        WL_Zimm_time_cell{k} = [];
    end

    % T1
    if isfield(ADCP.ZIMMERMAN, 'T1') && isfield(ADCP.ZIMMERMAN.T1, s) ...
            && isfield(ADCP.ZIMMERMAN.T1.(s), 'WL_from_external_source') ...
            && isfield(ADCP.ZIMMERMAN.T1.(s), 't_CET')
        WLtmp1 = ADCP.ZIMMERMAN.T1.(s).WL_from_external_source;
        WLttmp1 = ADCP.ZIMMERMAN.T1.(s).t_CET;
        if ~isempty(WLtmp1), WLtmp1 = WLtmp1(:); end
        if ~isempty(WLttmp1), WLttmp1 = WLttmp1(:); end
        WL_Zimm1{k} = WLtmp1;
        WL_Zimm_time1{k} = WLttmp1;
    else
        WL_Zimm1{k} = [];
        WL_Zimm_time1{k} = [];
    end
end

% Provide non-cell fallback variables expected later in the script
% (keep original scalar names for compatibility)
WL_Zimm = WL_Zimm;            % vector concatenation for T0 (may be empty)
WL_Zimm_time = WL_Zimm_time;  % vector concatenation for T0 times
WL_Zimm = WL_Zimm_cell;       % per-station cell array for T0 (overwrite name to cells)
WL_Zimm_time = WL_Zimm_time_cell;

%% Plot High Water versus velocity (tiled format)
%setting up tile format
nStations = numel(stationNames);
nRows = 4;
nCols = 4;

% figure with A4 Vertical proportions
fig = figure('Name', 'High Water Velocities Tiled', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 18, 22]; % Width=18cm, Height=25cm fits well on A4

% title plot
t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');

% Global Title, X-Label, and Y-Label to the layout (t), not individual plots
title(t, 'Velocity vs Water Level: Zimmerman', 'FontSize', 20, 'FontWeight', 'bold');
xlabel(t, 'Velocity (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 14, 'FontWeight', 'bold');

% % Title textbox above the tiled layout
% titleStr = 'Velocity vs Water Level';
% topMargin = 0.10; % fraction of figure height reserved for title
% t.Units = 'normalized';
% t.Position = [0, 0, 1, 1 - topMargin];
% annotation(fig, 'textbox', [0.05, 1 - topMargin + 0.01, 0.9, topMargin - 0.02], ...
%     'String', titleStr, ...
%     'HorizontalAlignment', 'center', ...
%     'VerticalAlignment', 'middle', ...
%     'FontSize', 16, ...
%     'FontWeight', 'bold', ...
%     'LineStyle', 'none', ...
%     'Interpreter', 'none');

% Loop stations and plot into tiles (limit to number of tiles available)
maxTiles = nRows * nCols;
nToPlot = min(nStations, maxTiles);
for k = 1:nToPlot

    % Prepare T0 data (use WL_Zimm for T0)
    if exist('WL_Zimm','var') && exist('WL_Zimm_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        % WL_Zimm and WL_Zimm_time are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Zimm) && numel(WL_Zimm) >= k
            zWL_cell = WL_Zimm{k};
            twl_cell = WL_Zimm_time{k};
        else
            zWL_cell = WL_Zimm;
            twl_cell = WL_Zimm_time;
        end
        tWL = twl_cell(:);
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0 = vel0_da{k}(:);
        if isdatetime(tWL)
            twl_num = datenum(tWL);
        else
            twl_num = tWL;
        end
        if isdatetime(tV0)
            tv0_num = datenum(tV0);
        else
            tv0_num = tV0;
        end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
            valid0 = ~isnan(z0_at_v) & ~isnan(v0);
        else
            valid0 = false(size(v0));
            z0_at_v = NaN(size(v0));
        end
    else
        v0 = [];
        z0_at_v = [];
        valid0 = [];
    end

    % Prepare T1 data (use WL_Zimm1 for T1)
    if exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        % WL_Zimm1 and WL_Zimm_time1 are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
            zWL1_cell = WL_Zimm1{k};
            twl1_cell = WL_Zimm_time1{k};
        else
            zWL1_cell = WL_Zimm1;
            twl1_cell = WL_Zimm_time1;
        end
        tWL1 = twl1_cell(:);
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1 = vel1_da{k}(:);
        if isdatetime(tWL1)
            twl1_num = datenum(tWL1);
        else
            twl1_num = tWL1;
        end
        if isdatetime(tV1)
            tv1_num = datenum(tV1);
        else
            tv1_num = tV1;
        end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
            valid1 = ~isnan(z1_at_v) & ~isnan(v1);
        else
            valid1 = false(size(v1));
            z1_at_v = NaN(size(v1));
        end
    else
        v1 = [];
        z1_at_v = [];
        valid1 = [];
    end

    % ===PLOTTING===
    nexttile;
    hold on;
    y_line = [-4 4.5];
    plot([0 0], y_line, 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5, 'HandleVisibility', 'off');
    hasData = false;
    if ~isempty(valid0) && any(valid0(:))
        plot(v0(valid0), z0_at_v(valid0), '-','LineWidth',1.0, 'Color', [0 0.4470 0.7410], 'DisplayName', 'T0');
        hasData = true;
    end
    if ~isempty(valid1) && any(valid1(:))
        plot(v1(valid1), z1_at_v(valid1), '-','LineWidth',1.0, 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'T1');
        hasData = true;
    end
    if ~hasData
        % no data: show station name and note
        text(0.5, 0.5, 'No valid data', 'Units', 'normalized', 'HorizontalAlignment', 'center', 'FontSize', 10);
    % else
    %     legend('show', 'Location', 'best');
    end

    set(gca, 'FontSize', 11);
    grid on;
    ylim([-2 4]);
    xlim([-1.7 1.7]);
    titleStrStation = stationNames_title{k};
    % legend('show', 'Location', 'best');
    title(titleStrStation, 'Interpreter', 'none', 'FontSize', 14);
    hold off;
end

% If there are remaining tiles (when nStations < maxTiles), fill them empty to keep layout consistent
for k = (nToPlot+1):maxTiles
    nexttile;
    axis off;
end

% Put legend in 12th tile
nexttile(14);
axis off;
% Create an invisible axes to host the legend centered within the tile
hAx = gca;
hAx.Visible = 'off';

% Create legend entries without plotting new graphics by using line objects with NaN data
hLine1 = line(nan, nan, 'LineWidth', 2.5, 'Color', [0 0.4470 0.7410]);
hLine2 = line(nan, nan, 'LineWidth', 2.5, 'Color', [0.8500 0.3250 0.0980]);

lgd = legend([hLine1, hLine2], {'T0','T1'}, ...
    'Location', 'west', ...
    'FontSize', 14, ...
    'Box', 'off', ...
    'Interpreter', 'none');

% Ensure legend is placed inside the tile and does not affect other tiles
lgd.Units = 'normalized';
lgd.Position(1:2) = max(min(lgd.Position(1:2), 1), 0);

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
%     if exist('WL_Zimm','var') && exist('WL_Zimm_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
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
%         v0 = vel0_da{k}(:);
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
%     if exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
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
%         v1 = vel1_da{k}(:);
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

%% Binning velocities and plotting 95% interval
% High Water versus velocity (tiled format)
nStations = numel(stationNames);
nRows = 3;
nCols = 5;
% figure with A4 Vertical proportions
fig = figure('Name', 'High Water Velocities Tiled Bins 95%', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 18, 14]; % Width=18cm, Height=23cm fits well on A4

% title plot
t = tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');

% Global Title, X-Label, and Y-Label to the layout (t), not individual plots
% title(t, 'Velocity vs Water Level: Zimmerman', 'FontSize', 20, 'FontWeight', 'bold');
xlabel(t, 'Depth Averaged Velocity (m/s)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 13, 'FontWeight', 'bold');

% --- Binning Settings ---
z_edges = -3:0.2:4.5; % 0.2m bins
z_centers = z_edges(1:end-1) + 0.1;
v_edges = -1.4:0.1:1.4; % 0.1m bins

% Colors defined globally before the loop to prevent reference errors
royalBlue  = [65, 105, 225] / 255;
baseOrange = [0.8500 0.3250 0.0980];

maxTiles = nRows * nCols;
nToPlot = min(nStations, maxTiles);
for k = 1:nToPlot
    % Prepare T0 data (use WL_Zimm for T0)
    if exist('WL_Zimm','var') && exist('WL_Zimm_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        if iscell(WL_Zimm) && numel(WL_Zimm) >= k
            zWL_cell = WL_Zimm{k};
            twl_cell = WL_Zimm_time{k};
        else
            zWL_cell = WL_Zimm;
            twl_cell = WL_Zimm_time;
        end
        tWL = twl_cell(:);
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0 = vel0_da{k}(:);
        if isdatetime(tWL)
            twl_num = datenum(tWL);
        else
            twl_num = tWL;
        end
        if isdatetime(tV0)
            tv0_num = datenum(tV0);
        else
            tv0_num = tV0;
        end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
            valid0 = ~isnan(z0_at_v) & ~isnan(v0);
        else
            valid0 = false(size(v0));
            z0_at_v = NaN(size(v0));
        end
    else
        v0 = [];
        z0_at_v = [];
        valid0 = [];
    end
    
    % Prepare T1 data (use WL_Zimm1 for T1)
    if exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
            zWL1_cell = WL_Zimm1{k};
            twl1_cell = WL_Zimm_time1{k};
        else
            zWL1_cell = WL_Zimm1;
            twl1_cell = WL_Zimm_time1;
        end
        tWL1 = twl1_cell(:);
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1 = vel1_da{k}(:);
        if isdatetime(tWL1)
            twl1_num = datenum(tWL1);
        else
            twl1_num = tWL1;
        end
        if isdatetime(tV1)
            tv1_num = datenum(tV1);
        else
            tv1_num = tV1;
        end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
            valid1 = ~isnan(z1_at_v) & ~isnan(v1);
        else
            valid1 = false(size(v1));
            z1_at_v = NaN(size(v1));
        end
    else
        v1 = [];
        z1_at_v = [];
        valid1 = [];
    end
    
    % Select target tile sequentially
    ax = nexttile(k);
    hold(ax, 'on');
    
    pctiles = [5 50 95];
    nPct = numel(pctiles);
    
    % --- Binning Logic for T0 ---
    if ~isempty(valid0) && any(valid0)
        v0_raw = v0(valid0);
        z0_raw = z0_at_v(valid0);
        
        v0_eb_pct = NaN(numel(z_centers), nPct);
        v0_fl_pct = NaN(numel(z_centers), nPct);
        
        for b = 1:numel(z_centers)
            idx_bin = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
            if any(idx_bin)
                v_bin = v0_raw(idx_bin);
                v_ebb = v_bin(v_bin < 0);
                v_flood = v_bin(v_bin >= 0);
                
                if ~isempty(v_ebb),   v0_eb_pct(b,:) = prctile(v_ebb, pctiles); end
                if ~isempty(v_flood), v0_fl_pct(b,:) = prctile(v_flood, pctiles); end
            end
        end
        
        % Plot T0 Ebb Envelope & Median
        idx_eb = ~isnan(v0_eb_pct(:,1));
        if any(idx_eb)
            x_patch_eb = [v0_eb_pct(idx_eb,1); flipud(v0_eb_pct(idx_eb,3))];
            y_patch_eb = [z_centers(idx_eb)'; flipud(z_centers(idx_eb)')];
            fill(ax, x_patch_eb, y_patch_eb, royalBlue, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_eb_pct(idx_eb,2), z_centers(idx_eb), 'LineWidth', 2, 'Color', royalBlue);
        end
        
        % Plot T0 Flood Envelope & Median
        idx_fl = ~isnan(v0_fl_pct(:,1));
        if any(idx_fl)
            x_patch_fl = [v0_fl_pct(idx_fl,1); flipud(v0_fl_pct(idx_fl,3))];
            y_patch_fl = [z_centers(idx_fl)'; flipud(z_centers(idx_fl)')];
            fill(ax, x_patch_fl, y_patch_fl, royalBlue, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_fl_pct(idx_fl,2), z_centers(idx_fl), 'LineWidth', 2, 'Color', royalBlue);
        end
    end
    
    % --- Binning Logic for T1 ---
    if ~isempty(valid1) && any(valid1)
        v1_raw = v1(valid1);
        z1_raw = z1_at_v(valid1);
        
        v1_eb_pct = NaN(numel(z_centers), nPct);
        v1_fl_pct = NaN(numel(z_centers), nPct);
        
        for b = 1:numel(z_centers)
            idx_bin = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
            if any(idx_bin)
                v_bin = v1_raw(idx_bin);
                v_ebb1   = v_bin(v_bin < 0);
                v_flood1 = v_bin(v_bin >= 0);
                
                if ~isempty(v_ebb1),   v1_eb_pct(b,:) = prctile(v_ebb1, pctiles); end
                if ~isempty(v_flood1), v1_fl_pct(b,:) = prctile(v_flood1, pctiles); end
            end
        end
        
        % Plot T1 Ebb Envelope & Median
        idx_eb1 = ~isnan(v1_eb_pct(:,1)) & ~isnan(v1_eb_pct(:,2)) & ~isnan(v1_eb_pct(:,3));
        if any(idx_eb1)
            z_sub_eb1 = z_centers(idx_eb1);
            x_patch_eb1 = [v1_eb_pct(idx_eb1,1); flipud(v1_eb_pct(idx_eb1,3))];
            y_patch_eb1 = [z_sub_eb1(:); flipud(z_sub_eb1(:))];
            fill(ax, x_patch_eb1, y_patch_eb1, baseOrange, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v1_eb_pct(idx_eb1,2), z_sub_eb1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);
        end
        
        % Plot T1 Flood Envelope & Median
        idx_fl1 = ~isnan(v1_fl_pct(:,1)) & ~isnan(v1_fl_pct(:,2)) & ~isnan(v1_fl_pct(:,3));
        if any(idx_fl1)
            z_sub_fl1 = z_centers(idx_fl1);
            x_patch_fl1 = [v1_fl_pct(idx_fl1,1); flipud(v1_fl_pct(idx_fl1,3))];
            y_patch_fl1 = [z_sub_fl1(:); flipud(z_sub_fl1(:))];
            fill(ax, x_patch_fl1, y_patch_fl1, baseOrange, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v1_fl_pct(idx_fl1,2), z_sub_fl1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);
        end
    end
    
    % --- Formatting Axis Window ---
    ax.XTick = [-1 0 1];
    ax.XTickLabel = {}; 
    ax.YTickLabel = {};
    if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end 
    % Show XTick labels on bottom row
    if k > (nRows-1)*nCols
        ax.XTickLabelMode = 'auto';
    end

    % Show YTick labels for specific panels k = 10,11,12,13
    if ismember(k, [9,10,11,12,13])
        ax.XTickLabelMode = 'auto';
    else
        ax.XTickLabelMode = 'manual';
    end
    
    ax.GridAlpha = 0.1;
    ax.FontSize = 11;
    grid on;
    ylim([-2 4]);
    xlim([-1.7 1.7]);
    title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 13);
    
    % --- Text Labels for Ebb / Flood ---
    xLimits = xlim(ax);
    yLimits = ylim(ax);
    xPadding = 0.03 * range(xLimits);
    yPadding = 0.02 * range(yLimits);

    text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);

    text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7]);

    % Reference Line
    line([0 0], [-3 4], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off');
    
    % --- Groyne Gray Rectangles Configuration (Restored & Fixed Layering) ---
    valid_k = [1,2,3,5,6];
    if ismember(k, valid_k)
        y1 = []; y2 = [];
        if k == 1,   y1 = [-0.18 0.82];                      end
        if k == 2,   y1 = [0.12 1.12]; y2 = [-1.21 -0.21]; end
        if k == 3,   y1 = [0.64 1.64]; y2 = [0.35 1.35];     end
        if k == 5,  y1 = [-1.73 -0.73];                      end
        if k == 6,  y1 = [1.32  2.32];                       end

        rect_width = 0.06 * range(xLimits);
        rect_color = [0.4 0.4 0.4]; %  gray
        rect_alpha = 0.3;            % Solid presence

        xl = xLimits(1); xr = xLimits(2);
        left_rect_x = [xl, xl + rect_width];
        right_rect_x = [xr - rect_width, xr];
        y_min_ax = yLimits(1); y_max_ax = yLimits(2);

        % Draw Left Groyne Patch
        if ~isempty(y1)
            yl_left = max(min(y1(1), y_max_ax), y_min_ax);
            yh_left = max(min(y1(2), y_max_ax), y_min_ax);
            if yh_left > yl_left
                x_poly_left = [left_rect_x(1), left_rect_x(2), left_rect_x(2), left_rect_x(1)];
                y_poly_left = [yl_left, yl_left, yh_left, yh_left];
                hGroyneL = fill(ax, x_poly_left, y_poly_left, rect_color, 'FaceAlpha', rect_alpha, ...
                    'EdgeColor', 'none', 'HandleVisibility', 'off');
                uistack(hGroyneL, 'top'); % Force on top of blue/orange patches
            end
        end

        % Draw Right Groyne Patch
        if ~isempty(y2)
            yl_right = max(min(y2(1), y_max_ax), y_min_ax);
            yh_right = max(min(y2(2), y_max_ax), y_min_ax);
            if yh_right > yl_right
                x_poly_right = [right_rect_x(1), right_rect_x(2), right_rect_x(2), right_rect_x(1)];
                y_poly_right = [yl_right, yl_right, yh_right, yh_right];
                hGroyneR = fill(ax, x_poly_right, y_poly_right, rect_color, 'FaceAlpha', rect_alpha, ...
                    'EdgeColor', 'none', 'HandleVisibility', 'off');
                uistack(hGroyneR, 'top'); % Force on top of blue/orange patches
            end
        end
    end
    hold(ax, 'off');
end 

% Fill empty remaining tiles if any
for empty_idx = (nToPlot+1):(maxTiles-1)
    ax_emp = nexttile(empty_idx);
    axis(ax_emp, 'off');
end

% --- Build Unified Legend in the final Tile (Tile 16) ---
axLeg = nexttile(14); 
axis(axLeg, 'off'); 

hT0_patch = patch(axLeg, nan(1,4), nan(1,4), royalBlue, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
hT1_patch = patch(axLeg, nan(1,4), nan(1,4), baseOrange, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
hT1_med   = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);
hT0_med   = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', royalBlue);
hGroyne_patch = patch(axLeg, nan(1,4), nan(1,4), [0.5 0.5 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');

% Safe color clamping
for hh = [hT1_patch, hT0_patch, hT1_med, hT0_med, hGroyne_patch]
    if isprop(hh, 'FaceColor')
        c = get(hh, 'FaceColor');
        if ~isempty(c) && ~any(isnan(c)), set(hh, 'FaceColor', min(max(c,0),1)); end
    end
    if isprop(hh, 'Color')
        c = get(hh, 'Color');
        if ~isempty(c) && ~any(isnan(c)), set(hh, 'Color', min(max(c,0),1)); end
    end
end

lgd = legend(axLeg, [hT0_med, hT1_med, hT0_patch, hT1_patch, hGroyne_patch], ...
    {'T0 - median', 'T1 - median', 'T0 - 95% interval', 'T1 - 95% interval', 'Groynes'}, ...
    'Location', 'west', 'FontSize', 11, 'Box', 'off');

%% reorganizing channel, low flats, high flats
group_channels   = {'0201','0302','0502','0702'};
group_low_flats  = {'0102','0303','0503','0504','0703'};
group_high_flats = {'0103','0104','0304','0704'};

groupDefs = { ...
    'Channels',   group_channels; ...
    'Low Flats',  group_low_flats; ...
    'High Flats', group_high_flats};

nCols = 5;

% --- Build ordered plot list [{gLabel, stationName, originalIndex}] ---
plotList = {};
for g = 1:size(groupDefs,1)
    gLabel = groupDefs{g,1};
    gNames = groupDefs{g,2};
    for s = 1:numel(gNames)
        sName = gNames{s};
        idx = find(strcmp(stationNames, sName), 1);
        if isempty(idx)
            idx = find(strcmp(stationNames_title, sName), 1);
        end
        plotList{end+1} = {gLabel, sName, idx};
    end
end

% --- Layout dimensions ---
% Channels:   5 → 1 full row
% Low Flats:  4 → 1 row (1 spare → legend)
% High Flats: 4 → 1 row (1 spare → empty)
nRows = 3;

% --- Binning Settings ---
z_edges   = -3:0.2:4.5;
z_centers = z_edges(1:end-1) + 0.1;
v_edges   = -1.4:0.1:1.4; %#ok<NASGU>
pctiles   = [5 50 95];
nPct      = numel(pctiles);

royalBlue  = [65, 105, 225] / 255;
baseOrange = [0.8500 0.3250 0.0980];

% --- Groyne definitions (keyed by ORIGINAL station index k) ---
valid_k   = [1, 2, 3, 5, 6];
groyne_y1 = containers.Map('KeyType','int32','ValueType','any');
groyne_y2 = containers.Map('KeyType','int32','ValueType','any');
groyne_y1(1) = [-0.18  0.82];
groyne_y1(2) = [ 0.12  1.12]; groyne_y2(2) = [-1.21 -0.21];
groyne_y1(3) = [ 0.64  1.64]; groyne_y2(3) = [ 0.35  1.35];
groyne_y1(5) = [-1.73 -0.73];
groyne_y1(6) = [ 1.32  2.32];

rect_color = [0.4 0.4 0.4];
rect_alpha = 0.3;

% --- Figure & Layout ---
fig = figure('Name','High Water Velocities Tiled Bins 95%','Color','w');
fig.Units    = 'centimeters';
fig.Position = [1, 1, 20, 16];

t = tiledlayout(nRows, nCols, 'TileSpacing','compact','Padding','compact');
xlabel(t, 'Depth Averaged Velocity [m/s]', 'FontSize',13,'FontWeight','bold');
ylabel(t, 'Water Level [m NAP]',            'FontSize',13,'FontWeight','bold');

% --- State tracking ---
groupFirstAxes = {};   % {gLabel, ax} for annotation
currentGroup   = '';
colInRow       = 0;
tileIdx        = 0;
legendPlaced   = false;
g              = 0;

% =========================================================
% Main loop
% =========================================================
for p = 1:numel(plotList)
    entry  = plotList{p};
    gLabel = entry{1};
    sName  = entry{2};
    k      = entry{3};   % original station index (for data + groynes)

    % --- On group change: pad remaining columns ---
    if ~strcmp(gLabel, currentGroup)
        while colInRow > 0 && colInRow < nCols
            axE = nexttile(t); axis(axE,'off');
            tileIdx  = tileIdx + 1;
            colInRow = colInRow + 1;
            if colInRow == nCols, colInRow = 0; end
        end
        currentGroup = gLabel;
        colInRow = 0;
        g = g + 1;
    end

    % --- Create tile ---
    ax       = nexttile(t);
    tileIdx  = tileIdx + 1;
    colInRow = colInRow + 1;
    if colInRow == nCols, colInRow = 0; end

    isLeftCol = (mod(tileIdx-1, nCols) == 0);

    % Record first axes per group (for group label annotation)
    if numel(groupFirstAxes) < g
        groupFirstAxes{g} = {gLabel, ax};
    end

    hold(ax,'on');

    % ---- Prepare T0 data ----------------------------------------
    v0 = []; z0_at_v = []; valid0 = false(0);
    if ~isempty(k) && exist('WL_Zimm','var') && exist('WL_Zimm_time','var') ...
            && numel(time0) >= k && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        if iscell(WL_Zimm) && numel(WL_Zimm) >= k
            zWL = WL_Zimm{k}(:);      tWL = WL_Zimm_time{k}(:);
        else
            zWL = WL_Zimm(:);         tWL = WL_Zimm_time(:);
        end
        tV0 = time0{k}(:); v0 = vel0_da{k}(:);
        twl_num = local_datenum(tWL);
        tv0_num = local_datenum(tV0);
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            z0_at_v = interp1(twl_num(validWL), zWL(validWL), tv0_num,'linear',NaN);
        else
            z0_at_v = NaN(size(v0));
        end
        valid0 = ~isnan(z0_at_v) & ~isnan(v0);
    end

    % ---- Prepare T1 data ----------------------------------------
    v1 = []; z1_at_v = []; valid1 = false(0);
    if ~isempty(k) && exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') ...
            && numel(time1) >= k && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
            zWL1 = WL_Zimm1{k}(:);    tWL1 = WL_Zimm_time1{k}(:);
        else
            zWL1 = WL_Zimm1(:);       tWL1 = WL_Zimm_time1(:);
        end
        tV1 = time1{k}(:); v1 = vel1_da{k}(:);
        twl1_num = local_datenum(tWL1);
        tv1_num  = local_datenum(tV1);
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            z1_at_v = interp1(twl1_num(validWL1), zWL1(validWL1), tv1_num,'linear',NaN);
        else
            z1_at_v = NaN(size(v1));
        end
        valid1 = ~isnan(z1_at_v) & ~isnan(v1);
    end

    % ---- Bin & plot T0 ------------------------------------------
    if any(valid0)
        v0r = v0(valid0); z0r = z0_at_v(valid0);
        v0_eb = NaN(numel(z_centers),nPct);
        v0_fl = NaN(numel(z_centers),nPct);
        for b = 1:numel(z_centers)
            ib = z0r >= z_edges(b) & z0r < z_edges(b+1);
            if any(ib)
                vb = v0r(ib);
                ve = vb(vb <  0); if ~isempty(ve), v0_eb(b,:) = prctile(ve,pctiles); end
                vf = vb(vb >= 0); if ~isempty(vf), v0_fl(b,:) = prctile(vf,pctiles); end
            end
        end
        local_plotEnv(ax, v0_eb, z_centers, royalBlue,  0.4, 2.0);
        local_plotEnv(ax, v0_fl, z_centers, royalBlue,  0.4, 2.0);
    end

    % ---- Bin & plot T1 ------------------------------------------
    if any(valid1)
        v1r = v1(valid1); z1r = z1_at_v(valid1);
        v1_eb = NaN(numel(z_centers),nPct);
        v1_fl = NaN(numel(z_centers),nPct);
        for b = 1:numel(z_centers)
            ib = z1r >= z_edges(b) & z1r < z_edges(b+1);
            if any(ib)
                vb = v1r(ib);
                ve = vb(vb <  0); if ~isempty(ve), v1_eb(b,:) = prctile(ve,pctiles); end
                vf = vb(vb >= 0); if ~isempty(vf), v1_fl(b,:) = prctile(vf,pctiles); end
            end
        end
        local_plotEnv(ax, v1_eb, z_centers, baseOrange, 0.4, 2.5);
        local_plotEnv(ax, v1_fl, z_centers, baseOrange, 0.4, 2.5);
    end

    % ---- Axis formatting ----------------------------------------
    xLimits = [-1.7 1.7]; yLimits = [-2 4];
    xlim(ax, xLimits); ylim(ax, yLimits);
    ax.XTick = [-1 0 1];
    if ismember(tileIdx, 10:14)
        ax.XTickLabelMode = 'auto';
    else
        ax.XTickLabelMode = 'manual';
        ax.XTickLabel = {};
    end
    ax.YTickLabel = {};
    if isLeftCol, ax.YTickLabelMode = 'auto'; end
    grid(ax,'on');
    ax.GridAlpha = 0.1;
    ax.FontSize  = 12;
    title(ax, sName,'Interpreter','none','FontSize',12);

    % Ebb / Flood corner text
    xp = 0.03*range(xLimits); yp = 0.02*range(yLimits);
    text(ax, xLimits(1)+xp, yLimits(1)+yp, 'ebb',  ...
        'HorizontalAlignment','left', 'VerticalAlignment','bottom', ...
        'FontSize',10,'FontWeight','bold','Color',[0.7 0.7 0.7]);
    text(ax, xLimits(2)-xp, yLimits(1)+yp, 'flood', ...
        'HorizontalAlignment','right','VerticalAlignment','bottom', ...
        'FontSize',10,'FontWeight','bold','Color',[0.7 0.7 0.7]);

    % Zero reference line
    line(ax,[0 0],[-3 4],'Color',[0.3 0.3 0.3],'LineWidth',0.5,'HandleVisibility','off');

    % ---- Groynes ------------------------------------------------
    if ~isempty(k) && ismember(k, valid_k)
        rw = 0.06*range(xLimits);
        if isKey(groyne_y1, int32(k))
            hGL = local_drawRect(ax, [xLimits(1) xLimits(1)+rw], ...
                groyne_y1(int32(k)), rect_color, rect_alpha, yLimits);
            if ~isempty(hGL), uistack(hGL,'top'); end
        end
        if isKey(groyne_y2, int32(k))
            hGR = local_drawRect(ax, [xLimits(2)-rw xLimits(2)], ...
                groyne_y2(int32(k)), rect_color, rect_alpha, yLimits);
            if ~isempty(hGR), uistack(hGR,'top'); end
        end
    end

    hold(ax,'off');
end

% --- Pad final row with empty tiles ---
while colInRow > 0 && colInRow < nCols
    axE = nexttile(t); axis(axE,'off');
    tileIdx  = tileIdx + 1;
    colInRow = colInRow + 1;
    if colInRow == nCols, colInRow = 0; end
end

% Place legend explicitly in tile 15
axLeg = nexttile(t, 15);
axis(axLeg,'off');
buildLegend(axLeg, royalBlue, baseOrange);

% --- Group label annotations (rotated 90°, left of each group's first row) ---
drawnow;
t.Padding     = 'compact';
t.TileSpacing = 'compact';
t.OuterPosition = [0, 0, 1, 0.98]; % [left bottom width height]
drawnow;

% =========================================================
% Local helper functions — place at bottom of script file
% =========================================================
function buildLegend(axLeg, royalBlue, baseOrange)
    hT0_med   = line(axLeg, nan, nan, 'LineWidth',2.5,'Color',royalBlue);
    hT1_med   = line(axLeg, nan, nan, 'LineWidth',2.5,'Color',baseOrange);
    hT0_patch = patch(axLeg, nan(1,4),nan(1,4), royalBlue,    'FaceAlpha',0.4,'EdgeColor','none');
    hT1_patch = patch(axLeg, nan(1,4),nan(1,4), baseOrange,   'FaceAlpha',0.4,'EdgeColor','none');
    hGroyne   = patch(axLeg, nan(1,4),nan(1,4), [0.5 0.5 0.5],'FaceAlpha',0.3,'EdgeColor','none');
    for hh = [hT0_patch, hT1_patch, hGroyne]
        c = get(hh,'FaceColor');
        if ~isempty(c) && ~any(isnan(c)), set(hh,'FaceColor',min(max(c,0),1)); end
    end
    for hh = [hT0_med, hT1_med]
        c = get(hh,'Color');
        if ~isempty(c) && ~any(isnan(c)), set(hh,'Color',min(max(c,0),1)); end
    end
    legend(axLeg, [hT0_med,hT1_med,hT0_patch,hT1_patch,hGroyne], ...
        {'T0 - median','T1 - median','T0 - 95% interval','T1 - 95% interval','Groynes'}, ...
        'Location','west','FontSize',11,'Box','off');
end

function local_plotEnv(ax, pct_mat, z_centers, clr, alpha, lw)
    idx = ~isnan(pct_mat(:,1)) & ~isnan(pct_mat(:,2)) & ~isnan(pct_mat(:,3));
    if ~any(idx), return; end
    z_sub = z_centers(idx);
    fill(ax, [pct_mat(idx,1); flipud(pct_mat(idx,3))], ...
             [z_sub(:); flipud(z_sub(:))], ...
        clr,'FaceAlpha',alpha,'EdgeColor','none','HandleVisibility','off');
    plot(ax, pct_mat(idx,2), z_sub,'LineWidth',lw,'Color',clr,'HandleVisibility','off');
end

function h = local_drawRect(ax, x_range, y_range, clr, alpha, yLimits)
    h = [];
    yl = max(min(y_range(1), yLimits(2)), yLimits(1));
    yh = max(min(y_range(2), yLimits(2)), yLimits(1));
    if yh <= yl, return; end
    h = fill(ax, [x_range(1) x_range(2) x_range(2) x_range(1)], ...
                 [yl yl yh yh], ...
        clr,'FaceAlpha',alpha,'EdgeColor','none','HandleVisibility','off');
end

function n = local_datenum(t)
    if isdatetime(t), n = datenum(t); else, n = double(t); end
end

groupTileRanges = {
    'Channel',   [1  5];
    'Low Flats',  [6  10];
    'High Flats', [11 14];
};

labelColor = [0.2 0.2 0.2];

for g = 1:size(groupTileRanges, 1)
    label     = groupTileRanges{g,1};
    tileRange = groupTileRanges{g,2};

    % Get position of first and last tile in group
    axFirst  = nexttile(t, tileRange(1));
    axLast   = nexttile(t, tileRange(2));
    posFirst = axFirst.Position;
    posLast  = axLast.Position;

    % x: left edge of first tile, y: just above top edge
    xLabel = max(posFirst(1) - 0.023, 0);
    yLabel = min(posFirst(2) + posFirst(4) + 0.009, 0.98);
    wLabel = (posLast(1) + posLast(3)) - posFirst(1);

    % Clamp to stay within [0,1]
    xLabel = max(min(xLabel, 1 - wLabel), 0);
    yLabel = max(min(yLabel, 0.98), 0);

    annotation(fig, 'textbox', [xLabel, yLabel, wLabel, 0.02], ...
        'String',              label, ...
        'FontSize',            12, ...
        'FontAngle',           'italic', ...
        'Color',               labelColor, ...
        'EdgeColor',           'none', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment',   'bottom', ...
        'FitBoxToText',        'off', ...
        'Interpreter',         'none');
end

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

%% calculate difference at HW = 2 and HW=3 between max velocities an print result on each figure in text
% High Water versus velocity (tiled format)
nStations = numel(stationNames);
nRows = 3;
nCols = 4;

% figure with A4 Vertical proportions
fig = figure('Name', 'High Water Velocities Tiled', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 18, 16]; % Width=18cm, Height=25cm fits well on A4

% title plot
t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');

% Global Title, X-Label, and Y-Label to the layout (t), not individual plots
title(t, 'Velocity vs Water Level: Zimmerman', 'FontSize', 20, 'FontWeight', 'bold');
xlabel(t, 'Velocity (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 14, 'FontWeight', 'bold');

% --- Binning Settings ---
z_edges = -3:0.2:4.5; % 0.2m bins
z_centers = z_edges(1:end-1) + 0.1;
v_edges = -1.4:0.1:1.4; % 0.1m bins

% Loop stations and plot into tiles (limit to number of tiles available)
maxTiles = nRows * nCols;
nToPlot = min(nStations, maxTiles);
for k = 1:nToPlot

    % Prepare T0 data (use WL_Zimm for T0)
    if exist('WL_Zimm','var') && exist('WL_Zimm_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        % WL_Zimm and WL_Zimm_time are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Zimm) && numel(WL_Zimm) >= k
            zWL_cell = WL_Zimm{k};
            twl_cell = WL_Zimm_time{k};
        else
            zWL_cell = WL_Zimm;
            twl_cell = WL_Zimm_time;
        end
        tWL = twl_cell(:);
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0 = vel0_da{k}(:);
        if isdatetime(tWL)
            twl_num = datenum(tWL);
        else
            twl_num = tWL;
        end
        if isdatetime(tV0)
            tv0_num = datenum(tV0);
        else
            tv0_num = tV0;
        end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
            valid0 = ~isnan(z0_at_v) & ~isnan(v0);
        else
            valid0 = false(size(v0));
            z0_at_v = NaN(size(v0));
        end
    else
        v0 = [];
        z0_at_v = [];
        valid0 = [];
    end

    % Prepare T1 data (use WL_Zimm1 for T1)
    if exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        % WL_Zimm1 and WL_Zimm_time1 are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
            zWL1_cell = WL_Zimm1{k};
            twl1_cell = WL_Zimm_time1{k};
        else
            zWL1_cell = WL_Zimm1;
            twl1_cell = WL_Zimm_time1;
        end
        tWL1 = twl1_cell(:);
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1 = vel1_da{k}(:);
        if isdatetime(tWL1)
            twl1_num = datenum(tWL1);
        else
            twl1_num = tWL1;
        end
        if isdatetime(tV1)
            tv1_num = datenum(tV1);
        else
            tv1_num = tV1;
        end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
            valid1 = ~isnan(z1_at_v) & ~isnan(v1);
        else
            valid1 = false(size(v1));
            z1_at_v = NaN(size(v1));
        end
    else
        v1 = [];
        z1_at_v = [];
        valid1 = [];
    end

    ax = nexttile;
    hold on;
    
        % --- Binning Logic for T0: compute 5th, 50th, 95th percentiles per flood/ebb velocity ---
        pctiles = [5 50 95];
        nPct = numel(pctiles);
        % colors for T0 (blue): single shade for 5 & 95, solid for 50 (slightly lighter)
        royalBlue = [65, 105, 225] / 255;
        lightBlue = [173, 216, 230] / 255;
        color_edge0 = royalBlue;
        color_med0 = lightBlue;
    
        if ~isempty(valid0) && any(valid0)
            v0_raw = v0(valid0);
            z0_raw = z0_at_v(valid0);
        end
        % Initialize separate matrices for Ebb (<0) and Flood (>0)
        v0_eb_pct = NaN(numel(z_centers), nPct);
        v0_fl_pct = NaN(numel(z_centers), nPct);
        
        for b = 1:numel(z_centers)
            idx_bin = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
            if any(idx_bin)
                v_bin = v0_raw(idx_bin);
                
                % Split into ebb and flood components
                v_ebb = v_bin(v_bin < 0);
                v_flood = v_bin(v_bin >= 0);
                
                if ~isempty(v_ebb),   v0_eb_pct(b,:) = prctile(v_ebb, pctiles); end
                if ~isempty(v_flood), v0_fl_pct(b,:) = prctile(v_flood, pctiles); end
            end
        end
        
        % --- Plot Ebb Envelope & Median ---
        baseOrange = [0.8500 0.3250 0.0980];
        idx_eb = ~isnan(v0_eb_pct(:,1));
        if any(idx_eb)
            x_patch_eb = [v0_eb_pct(idx_eb,1); flipud(v0_eb_pct(idx_eb,3))];
            y_patch_eb = [z_centers(idx_eb)'; flipud(z_centers(idx_eb)')];
            fill(ax, x_patch_eb, y_patch_eb, royalBlue, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_eb_pct(idx_eb,2), z_centers(idx_eb), 'LineWidth', 2, 'Color', royalBlue);
        end
        
        % --- Plot Flood Envelope & Median ---
        idx_fl = ~isnan(v0_fl_pct(:,1));
        if any(idx_fl)
            x_patch_fl = [v0_fl_pct(idx_fl,1); flipud(v0_fl_pct(idx_fl,3))];
            y_patch_fl = [z_centers(idx_fl)'; flipud(z_centers(idx_fl)')];
            fill(ax, x_patch_fl, y_patch_fl, royalBlue, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_fl_pct(idx_fl,2), z_centers(idx_fl), 'LineWidth', 2, 'Color', royalBlue);
        end

        % --- Binning Logic for T1: compute 5th, 50th, 95th percentiles per WL bin ---
        if ~isempty(valid1) && any(valid1)
            v1_raw = v1(valid1);
            z1_raw = z1_at_v(valid1);
            
            % Initialize separate matrices for Ebb (<0) and Flood (>=0)
            v1_eb_pct = NaN(numel(z_centers), nPct);
            v1_fl_pct = NaN(numel(z_centers), nPct);
            
            for b = 1:numel(z_centers)
                idx_bin = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
                if any(idx_bin)
                    v_bin = v1_raw(idx_bin);
                    
                    % Split into ebb and flood components
                    v_ebb1   = v_bin(v_bin < 0);
                    v_flood1 = v_bin(v_bin >= 0);
                    
                    if ~isempty(v_ebb1),   v1_eb_pct(b,:) = prctile(v_ebb1, pctiles); end
                    if ~isempty(v_flood1), v1_fl_pct(b,:) = prctile(v_flood1, pctiles); end
                end
            end
            
            % --- Plot T1 Ebb Envelope & Median (Orange) ---
            idx_eb1 = ~isnan(v1_eb_pct(:,1)) & ~isnan(v1_eb_pct(:,2)) & ~isnan(v1_eb_pct(:,3));
            if any(idx_eb1)
                z_sub_eb1 = z_centers(idx_eb1);
                x_patch_eb1 = [v1_eb_pct(idx_eb1,1); flipud(v1_eb_pct(idx_eb1,3))];
                y_patch_eb1 = [z_sub_eb1(:); flipud(z_sub_eb1(:))];
                
                fill(ax, x_patch_eb1, y_patch_eb1, baseOrange, ...
                    'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, v1_eb_pct(idx_eb1,2), z_sub_eb1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
                    'DisplayName', 'T1 Ebb Median');
            end
            
            % --- Plot T1 Flood Envelope & Median (Orange) ---
            idx_fl1 = ~isnan(v1_fl_pct(:,1)) & ~isnan(v1_fl_pct(:,2)) & ~isnan(v1_fl_pct(:,3));
            if any(idx_fl1)
                z_sub_fl1 = z_centers(idx_fl1);
                x_patch_fl1 = [v1_fl_pct(idx_fl1,1); flipud(v1_fl_pct(idx_fl1,3))];
                y_patch_fl1 = [z_sub_fl1(:); flipud(z_sub_fl1(:))];
                
                fill(ax, x_patch_fl1, y_patch_fl1, baseOrange, ...
                    'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, v1_fl_pct(idx_fl1,2), z_sub_fl1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
                    'DisplayName', 'T1 Flood Median');
            end
        end
        
        % difference in 95% at HW = 3 and HW = 2
        % Apply for current station k: ensure indices exist and use safe indexing.
        % Determine bin indices corresponding to HW ~2 and HW ~3 based on z_centers.
        % Use nearest-bin approach to find indices for HW=2 and HW=3.
        [~, idx_HW2] = min(abs(z_centers - 2));
        [~, idx_HW3] = min(abs(z_centers - 3));

        % Initialize outputs (NaN if not available)
        % Ensure outputs exist for saving outside the loop by using cell arrays indexed by k
        if ~exist('fl_HW2_95diff_all', 'var')
            fl_HW2_95diff_all = nan(nStations,1);
            fl_HW3_95diff_all = nan(nStations,1);
            eb_HW2_95diff_all = nan(nStations,1);
            eb_HW3_95diff_all = nan(nStations,1);
        end

        % Initialize current-values (NaN by default)
        fl_HW2_95diff = NaN;
        fl_HW3_95diff = NaN;
        eb_HW2_95diff = NaN;
        eb_HW3_95diff = NaN;

        % Compute flood differences if percentiles exist
        if exist('v1_fl_pct','var') && exist('v0_fl_pct','var')
            if idx_HW2 >= 1 && idx_HW2 <= size(v1_fl_pct,1) && idx_HW2 <= size(v0_fl_pct,1)
                if ~isnan(v1_fl_pct(idx_HW2,3)) && ~isnan(v0_fl_pct(idx_HW2,3))
                    fl_HW2_95diff = v1_fl_pct(idx_HW2,3) - v0_fl_pct(idx_HW2,3);
                end
            end
            if idx_HW3 >= 1 && idx_HW3 <= size(v1_fl_pct,1) && idx_HW3 <= size(v0_fl_pct,1)
                if ~isnan(v1_fl_pct(idx_HW3,3)) && ~isnan(v0_fl_pct(idx_HW3,3))
                    fl_HW3_95diff = v1_fl_pct(idx_HW3,3) - v0_fl_pct(idx_HW3,3);
                end
            end
        end

        % Compute ebb differences if percentiles exist
        if exist('v1_eb_pct','var') && exist('v0_eb_pct','var')
            if idx_HW2 >= 1 && idx_HW2 <= size(v1_eb_pct,1) && idx_HW2 <= size(v0_eb_pct,1)
                if ~isnan(v1_eb_pct(idx_HW2,3)) && ~isnan(v0_eb_pct(idx_HW2,3))
                    eb_HW2_95diff = v1_eb_pct(idx_HW2,3) - v0_eb_pct(idx_HW2,3);
                end
            end
            if idx_HW3 >= 1 && idx_HW3 <= size(v1_eb_pct,1) && idx_HW3 <= size(v0_eb_pct,1)
                if ~isnan(v1_eb_pct(idx_HW3,3)) && ~isnan(v0_eb_pct(idx_HW3,3))
                    eb_HW3_95diff = v1_eb_pct(idx_HW3,3) - v0_eb_pct(idx_HW3,3);
                end
            end
        end

        % Save current station results into arrays for use outside the loop
        % Assume loop index is k and total stations is nStations (predefined)
        if exist('k','var')
            fl_HW2_95diff_all(k) = fl_HW2_95diff;
            fl_HW3_95diff_all(k) = fl_HW3_95diff;
            eb_HW2_95diff_all(k) = eb_HW2_95diff;
            eb_HW3_95diff_all(k) = eb_HW3_95diff;
        end

        %--plotting HW text (no helper functions)--
        % Prepare formatted strings safely handling NaN values
        if isnan(eb_HW_3_95diff)
            s_eb_HW3 = 'ebb HW=3 95% diff: N/A';
        else
            s_eb_HW3 = ['ebb HW=3 95% diff: ' num2str(eb_HW_3_95diff)];
        end

        if isnan(eb_HW_2_95diff)
            s_eb_HW2 = 'ebb HW=2 95% diff: N/A';
        else
            s_eb_HW2 = ['ebb HW=2 95% diff: ' num2str(eb_HW_2_95diff)];
        end

        if isnan(fl_HW3_95diff)
            s_fl_HW3 = 'fld HW=3 95% diff: N/A';
        else
            s_fl_HW3 = ['fld HW=3 95% diff: ' num2str(fl_HW3_95diff)];
        end

        if isnan(fl_HW2_95diff)
            s_fl_HW2 = 'fld HW=2 95% diff: N/A';
        else
            s_fl_HW2 = ['fld HW=2 95% diff: ' num2str(fl_HW2_95diff)];
        end

        % Choose positions in normalized axes units (top-left block)
        % Place as text inside the axis near the top-left corner
        xLimits = xlim(ax); yLimits = ylim(ax);
        xText = xLimits(1) + 0.03*range(xLimits);
        yTop = yLimits(2) - 0.05*range(yLimits);

        text(xText, yTop, s_eb_HW3, 'Parent', ax, 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');
        text(xText, yTop - 0.12*range(yLimits), s_eb_HW2, 'Parent', ax, 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');
        text(xText, yTop - 0.24*range(yLimits), s_fl_HW3, 'Parent', ax, 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');
        text(xText, yTop - 0.36*range(yLimits), s_fl_HW2, 'Parent', ax, 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', 'FontSize', 9, 'Color', [0.2 0.2 0.2], 'Interpreter', 'none');

        % --- Formatting ---
        ax.XTick = [-1 0 1];
        ax.XTickLabel = {}; 
        ax.YTickLabel = {};
        if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end % Show left column
        if k > (nRows-1)*nCols, ax.XTickLabelMode = 'auto'; end   % Show bottom row
        ax.GridAlpha = 0.1;
        ax.FontSize = 12;
 
        set(gca, 'FontSize', 11);
        grid on;
        ylim([-1.6 4]);
        xlim([-1.5 1.5]);
        title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 13);
        % legend('show', 'Location', 'best');
        
        hold off;

        % --text for flood and ebb--
        % add text for "flood" and "ebb" on each tile at bottom
        xLimits = xlim(ax);
        yLimits = ylim(ax);
        xPadding = 0.03 * range(xLimits);
        yPadding = 0.02 * range(yLimits);
    
        % Left-bottom (flood)
        text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7], ...
            'Interpreter', 'none');
    
        % Right-bottom (ebb)
        text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7], ...
            'Interpreter', 'none');
    
    % Reference line
    line([0 0], [-3 4], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off')

    % Put legend in 12th tile (tile index 12 in a 4x3 layout)
    nexttile(12);
    axis off;
    % Create an invisible axes to host the legend centered within the tile
    hAx = gca;
    hAx.Visible = 'off';
    
end 

axLeg = nexttile(t, 12); 
axis(axLeg, 'off'); % Hide the axes box

% Create dummy legend entries matching the shaded region + median line for T1
hT0_patch = patch(axLeg, nan(1,4), nan(1,4), royalBlue, 'FaceAlpha', 0.2, ...
    'EdgeColor', 'none');
hT1_patch = patch(axLeg, nan(1,4), nan(1,4), baseOrange, 'FaceAlpha', 0.2, ...
    'EdgeColor', 'none');

% Median line (50th) for T1
hT1_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);

% Also create corresponding dummy entries for T0 style if desired (kept from original pattern)
hT0_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', royalBlue);

% Ensure colors are clipped to [0,1]
for hh = [hT1_patch, hT0_patch, hT1_med, hT0_med]
    if isprop(hh, 'FaceColor')
        c = get(hh, 'FaceColor');
        if ~isempty(c) && ~any(isnan(c))
            c = min(max(c,0),1);
            set(hh, 'FaceColor', c);
        end
    end
    if isprop(hh, 'Color')
        c = get(hh, 'Color');
        if ~isempty(c) && ~any(isnan(c))
            c = min(max(c,0),1);
            set(hh, 'Color', c);
        end
    end
end

% Build legend using the patch handle for the shaded region and the median line
lgd = legend(axLeg, [hT0_med, hT1_med, hT0_patch, hT1_patch], ...
    {'T0 - median', 'T1 - median', 'T0 - 95% interval', 'T1 - 95% interval'}, ...
    'Location', 'west', 'FontSize', 10, 'Box', 'off', 'FontWeight', 'bold');

% 5. Optional: Final layout tightening
t.Padding = 'compact';
t.TileSpacing = 'compact';

% %% export figure 
% outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% fname = fullfile(outDir, sprintf('Zimmpctshaded_HW_vel.png'));
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

%% spatial changes
% Plot fl_HW2_95diff_all as markers on the current figure using specified style.
hold on;

% Define plotting style (from request)
colors = {'k','r'};
shapes = {'o','s'};
locations = {'Bottom','Top'};

figure();
% Build color scale bounds from eb_HW3_95diff_all if available, otherwise fallback
CS = [1e9 -1e9];
if exist('eb_HW3_95diff_all','var')
    % eb_HW3_95diff_all might be cell/struct/numeric; handle common cases
    if iscell(eb_HW3_95diff_all)
        for i = 1:numel(eb_HW3_95diff_all)
            v = eb_HW3_95diff_all{i};
            if isempty(v), continue; end
            if isstruct(v)
                fn1 = fieldnames(v);
                for fn1i = 1:numel(fn1)
                    fn2 = fieldnames(v.(fn1{fn1i}));
                    for fn2i = 1:numel(fn2)
                        vv = v.(fn1{fn1i}).(fn2{fn2i});
                        if isnumeric(vv) && ~isempty(vv)
                            CS(1) = min(CS(1), min(vv(:)));
                            CS(2) = max(CS(2), max(vv(:)));
                        end
                    end
                end
            elseif isnumeric(v)
                CS(1) = min(CS(1), min(v(:)));
                CS(2) = max(CS(2), max(v(:)));
            end
        end
    elseif isstruct(eb_HW3_95diff_all)
        fn1 = fieldnames(eb_HW3_95diff_all);
        for fn1i = 1:numel(fn1)
            fn2 = fieldnames(eb_HW3_95diff_all.(fn1{fn1i}));
            for fn2i = 1:numel(fn2)
                v = eb_HW3_95diff_all.(fn1{fn1i}).(fn2{fn2i});
                if isnumeric(v) && ~isempty(v)
                    CS(1) = min(CS(1), min(v(:)));
                    CS(2) = max(CS(2), max(v(:)));
                end
            end
        end
    elseif isnumeric(eb_HW3_95diff_all)
        CS(1) = min(CS(1), min(eb_HW3_95diff_all(:)));
        CS(2) = max(CS(2), max(eb_HW3_95diff_all(:)));
    end

    if isfinite(CS(1)) && isfinite(CS(2))
        % Round to nice ticks (nearest 0.1 if small range, otherwise nearest integer/10)
        rangeVal = CS(2) - CS(1);
        if rangeVal <= 1
            CS = [floor(CS(1)*10)/10, ceil(CS(2)*10)/10];
        else
            CS = [floor(CS(1)), ceil(CS(2))];
        end
    else
        CS = [-0.5 0.5];
    end
else
    CS = [-0.5 0.5];
end

% Define bin edges and corresponding colormap as in request
CS_binedges = -0.5:0.1:0.5;
CS_abs_max = max(abs(CS_binedges));
CS_stepsz = unique(diff(CS_binedges));
% CS_range = -CS_abs_max:CS_stepsz:CS_abs_max;

% Use diverging map and prepare marker colors
cm_full = fliplr(cbrewer('div','RdYlBu',length(CS_range))')';
cm_markers = cm_full;
% clamp to [0,1]
cm_markers = min(max(cm_markers,0),1);

% Remove excess colors to match requested behaviour
index = find(~ismember(CS_range,CS_binedges));
c1 = 0; c2 = 0;
% for i = 1:length(index)
%     if ~mod(i,2)
%         cm_markers(end-c1,:) = [];
%         c1 = c1+1;
%     else
%         cm_markers(1+c2,:) = [];
%         c2 = c2+1;
%     end
% end

% Set color for zero bin to white
[~, zeroIndex] = min(abs(CS_binedges));
if zeroIndex <= size(cm_markers,1)
    cm_markers(zeroIndex,:) = [1 1 1];
end
% remove last color so ticks/blocks match per original pattern
if ~isempty(cm_markers)
    cm_markers(end,:) = [];
end

% Determine number of points (robust to cell / numeric inputs)
nPoints = max([numel(RDx_T0), numel(RDx_T1), numel(fl_HW2_95diff_all)]);
X = nan(nPoints,1);
Y = nan(nPoints,1);
C = nan(nPoints,1);

% Fill positions and color values (color from fl_HW2_95diff_all if available)
for s = 1:nPoints
    % Position: prefer T0, fallback to T1
    if numel(RDx_T0) >= s && ~isempty(RDx_T0{s}) && ~any(isnan(RDx_T0{s}))
        rx = RDx_T0{s}; ry = RDy_T0{s};
        if numel(rx) > 1, rx = rx(1); end
        if numel(ry) > 1, ry = ry(1); end
        X(s) = rx; Y(s) = ry;
    elseif numel(RDx_T1) >= s && ~isempty(RDx_T1{s}) && ~any(isnan(RDx_T1{s}))
        rx = RDx_T1{s}; ry = RDy_T1{s};
        if numel(rx) > 1, rx = rx(1); end
        if numel(ry) > 1, ry = ry(1); end
        X(s) = rx; Y(s) = ry;
    else
        X(s) = NaN; Y(s) = NaN;
    end

    % Assign color value C(s) from available variables, robust to multiple possible names
    % Prefer fl_HW2_95diff_all; fall back to FL_HW2_95diff_all, fl_hw2_95diff_all, or DELTA_U entry if present.
    val = NaN;
    % try common variants
    if exist('fl_HW2_95diff_all','var')
        if iscell(fl_HW2_95diff_all) && numel(fl_HW2_95diff_all) >= s
            v = fl_HW2_95diff_all{s};
            if isnumeric(v) && ~isempty(v)
                val = v(1);
            end
        elseif isnumeric(fl_HW2_95diff_all) && numel(fl_HW2_95diff_all) >= s
            val = fl_HW2_95diff_all(s);
        end
    end
    if isnan(val) && exist('FL_HW2_95diff_all','var')
        if iscell(FL_HW2_95diff_all) && numel(FL_HW2_95diff_all) >= s
            v = FL_HW2_95diff_all{s};
            if isnumeric(v) && ~isempty(v)
                val = v(1);
            end
        elseif isnumeric(FL_HW2_95diff_all) && numel(FL_HW2_95diff_all) >= s
            val = FL_HW2_95diff_all(s);
        end
    end
    if isnan(val) && exist('fl_hw2_95diff_all','var')
        if iscell(fl_hw2_95diff_all) && numel(fl_hw2_95diff_all) >= s
            v = fl_hw2_95diff_all{s};
            if isnumeric(v) && ~isempty(v)
                val = v(1);
            end
        elseif isnumeric(fl_hw2_95diff_all) && numel(fl_hw2_95diff_all) >= s
            val = fl_hw2_95diff_all(s);
        end
    end

    % Final fallback: try DELTA_U structure (use first numeric field found)
    if isnan(val) && exist('DELTA_U','var') && iscell(DELTA_U) && numel(DELTA_U) >= 2
        fn1 = fieldnames(DELTA_U{2});
        for fn1i = 1:length(fn1)
            fn2 = fieldnames(DELTA_U{2}.(fn1{fn1i}));
            for fn2i = 1:length(fn2)
                v = DELTA_U{2}.(fn1{fn1i}).(fn2{fn2i});
                if isnumeric(v) && ~isempty(v)
                    if numel(v) >= s
                        val = v(min(s,end));
                        break;
                    else
                        val = v(1);
                        break;
                    end
                end
            end
            if ~isnan(val), break; end
        end
    end

    if ~isnumeric(val) || isempty(val)
        C(s) = NaN;
    else
        C(s) = val;
    end
end

% Map color values C to discrete bins CS_binedges and then to cm_markers
valid = ~isnan(X) & ~isnan(Y) & ~isnan(C);
if any(valid)
    % compute bin indices for each valid C
    [~,~,binIdx] = histcounts(C(valid), [-inf, CS_binedges(1:end-1)+diff(CS_binedges)/2, inf]);
    % guard binIdx range against cm_markers size
    nColors = size(cm_markers,1);
    binIdx(binIdx < 1) = 1;
    binIdx(binIdx > nColors) = nColors;

    % Plot each point using mapped color and requested shape (use shapes{1} and colors{1} per request)
    for ii = 1:sum(valid)
        xi = X(valid); yi = Y(valid); ci = binIdx;
        col = cm_markers(ci(ii),:);
        scatter(xi(ii), yi(ii), 60, 'Marker', shapes{1}, 'MarkerEdgeColor', colors{1}, ...
            'MarkerFaceColor', col, 'LineWidth', 0.5);
    end

    % Create colorbar matching CS_binedges
    colormap(cm_markers);
    cb = colorbar('Ticks', linspace(0,1,length(CS_binedges)), ...
        'TickLabels', arrayfun(@num2str, CS_binedges, 'UniformOutput', false));
    cb.Label.String = 'fl\_HW2\_95diff\_all';
    cb.FontSize = 12;
end

hold off;

%% %% plotting profile and velocity side by side (modified to include GeoTIFF subplot)
figure();

% Subplot 1: Aerial with box of interest (GeoTIFF + lines)
subplot(1,3,1);
imshow(I);

% Subplot 2: Cross Shore Profile (elevation vs distance)
subplot(1,3,2);
hold on;
plot(xdist*20, vals1, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 4, 'HandleVisibility', 'off');
plot(84, -1, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor',  'b', 'DisplayName', '0702');
plot(270, 1.4, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'DisplayName', '0703');
% plot(40, -1.160, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor',  'b', 'DisplayName', '0902');
% plot(305, 1.0, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'DisplayName', '0903');
legend('show');
% hLeg = legend;
% set(hLeg, 'FontSize', 16);
hold off;
% xlim([0 600]);
ylim([-2.5 5]);
xlabel('Distance (m)', 'FontSize', 18);
ylabel('Elevation NAP (m)', 'FontSize', 18);
title('Profile', 'FontSize', 28);
set(gca, 'FontSize', 20);

% Subplot 3: Velocity vs Water Level for stations 
subplot(1,3,3);
hold on;
for k = 1:nStations
    % check station name matches (robust to stationNames content)
    if ischar(stationNames{k}) || isstring(stationNames{k})
        name = char(stationNames{k});
    else
        continue
    end
    if contains(name, '0702') || contains(name, '0703')
        % Prepare T0 data
        if isempty(time0{k}) || isempty(vel0_da{k}) || isempty(WL_Zimm_time) || isempty(WL_Zimm)
            v0 = [];
            z0_at_v = [];
            valid0 = false(0,1);
        else
            tV0 = time0{k}(:);
            v0 = vel0_da{k}(:);
            tWL = WL_Zimm_time(:);
            zWL = WL_Zimm(:);
            if isdatetime(tWL)
                twl_num = datenum(tWL);
            else
                twl_num = tWL;
            end
            if isdatetime(tV0)
                tv0_num = datenum(tV0);
            else
                tv0_num = tV0;
            end
            validWL = ~isnan(zWL) & ~isnan(twl_num);
            if sum(validWL) >= 2
                zWL_valid = zWL(validWL);
                twl_valid = twl_num(validWL);
                z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
                valid0 = ~isnan(z0_at_v) & ~isnan(v0);
            else
                v0 = [];
                z0_at_v = [];
                valid0 = false(size(v0));
            end
        end

        % Prepare T1 data (use WL_Zimm_time1 / WL_Zimm1 if available)
        if isempty(time1{k}) || isempty(vel1_da{k}) || isempty(WL_Zimm_time1) || isempty(WL_Zimm1)
            v1 = [];
            z1_at_v = [];
            valid1 = false(0,1);
        else
            tV1 = time1{k}(:);
            v1 = vel1_da{k}(:);
            tWL1 = WL_Zimm_time1(:);
            zWL1 = WL_Zimm1(:);
            if isdatetime(tWL1)
                twl1_num = datenum(tWL1);
            else
                twl1_num = tWL1;
            end
            if isdatetime(tV1)
                tv1_num = datenum(tV1);
            else
                tv1_num = tV1;
            end
            validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
            if sum(validWL1) >= 2
                zWL1_valid = zWL1(validWL1);
                twl1_valid = twl1_num(validWL1);
                z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
                valid1 = ~isnan(z1_at_v) & ~isnan(v1);
            else
                v1 = [];
                z1_at_v = [];
                valid1 = false(size(v1));
            end
        end

        % If neither has valid data, skip
        if (~any(valid0(:)) && ~any(valid1(:)))
            continue;
        end

        % plot with specific colors for 0902 (blue) and 0903 (red), include T0 and T1
        if contains(name, '0702')
            colT0 = 'b'; %dark blue
            colT1 = [0.3010 0.7450 0.9330]; %light blue
        else % 0903
            colT0 = 'r';    % red
            colT1 = [1.0 0.6 0.6];    % lighter red (pinkish)
        end
        plotted = false;
        if any(valid0(:))
            plot(v0(valid0), z0_at_v(valid0), 'o-','LineWidth',1.2, 'Color', colT0, 'DisplayName', sprintf('%s T0', stationNames_title{k}));
            plotted = true;
        end
        % if any(valid1(:))
        %     plot(v1(valid1), z1_at_v(valid1), 's-','LineWidth',1.2, 'Color', colT1, 'DisplayName', sprintf('%s T1', stationNames_title{k}));
        %     plotted = true;
        % end
        if ~plotted
            continue;
        end
    end
end
ylabel('Water Level NAP (m)', 'FontSize', 18);
xlabel('Velocity (m/s)', 'FontSize', 18);
title('Velocity vs Water Level', 'FontSize', 20);
set(gca, 'FontSize', 20);
ylim([-2.5 5]);
legend('show');
hLeg = legend;
set(hLeg, 'FontSize', 16, 'Location', 'best');
hold off;

% Add one large centered title for the entire figure (suptitle-like)
sgtitle('Zimm (0702 & 0703) Velocities on Cross Shore Profile', 'FontSize', 26, 'FontWeight', 'bold');

%% Reorganized figure: Channels / Low Flats / High Flats — Zimmerman, 5 columns
% --- Group definitions ---
group_channels   = {'201','102','302','5502','702'};
group_low_flats  = {'103','303','503','703'};
group_high_flats = {'104','304','504','704'};

groupDefs = { ...
    'Channel',   group_channels; ...
    'Low Flats',  group_low_flats; ...
    'High Flats', group_high_flats};

nCols = 5;

% --- Build ordered plot list [{gLabel, stationName, originalIndex}] ---
plotList = {};
for g = 1:size(groupDefs,1)
    gLabel = groupDefs{g,1};
    gNames = groupDefs{g,2};
    for s = 1:numel(gNames)
        sName = gNames{s};
        idx = find(strcmp(stationNames, sName), 1);
        if isempty(idx)
            idx = find(strcmp(stationNames_title, sName), 1);
        end
        plotList{end+1} = {gLabel, sName, idx};
    end
end

% --- Layout dimensions ---
% Channels:   5 → 1 full row
% Low Flats:  4 → 1 row (1 spare → legend)
% High Flats: 4 → 1 row (1 spare → empty)
nRows = 3;

% --- Binning Settings ---
z_edges   = -3:0.2:4.5;
z_centers = z_edges(1:end-1) + 0.1;
v_edges   = -1.4:0.1:1.4; %#ok<NASGU>
pctiles   = [5 50 95];
nPct      = numel(pctiles);

royalBlue  = [65, 105, 225] / 255;
baseOrange = [0.8500 0.3250 0.0980];

% --- Groyne definitions (keyed by ORIGINAL station index k) ---
valid_k   = [1, 2, 3, 5, 6];
groyne_y1 = containers.Map('KeyType','int32','ValueType','any');
groyne_y2 = containers.Map('KeyType','int32','ValueType','any');
groyne_y1(1) = [-0.18  0.82];
groyne_y1(2) = [ 0.12  1.12]; groyne_y2(2) = [-1.21 -0.21];
groyne_y1(3) = [ 0.64  1.64]; groyne_y2(3) = [ 0.35  1.35];
groyne_y1(5) = [-1.73 -0.73];
groyne_y1(6) = [ 1.32  2.32];

rect_color = [0.4 0.4 0.4];
rect_alpha = 0.3;

% --- Figure & Layout ---
fig = figure('Name','High Water Velocities Tiled Bins 95%','Color','w');
fig.Units    = 'centimeters';
fig.Position = [1 1 27 nRows*5.5];

t = tiledlayout(nRows, nCols, 'TileSpacing','compact','Padding','compact');
xlabel(t, 'Depth Averaged Velocity [m/s]', 'FontSize',13,'FontWeight','bold');
ylabel(t, 'Water Level [m NAP]', 'FontSize',13,'FontWeight','bold');

% --- State tracking ---
groupFirstAxes = {};   % {gLabel, ax} for annotation
currentGroup   = '';
colInRow       = 0;
tileIdx        = 0;
legendPlaced   = false;
g              = 0;

% =========================================================
% Main loop
% =========================================================
for p = 1:numel(plotList)
    entry  = plotList{p};
    gLabel = entry{1};
    sName  = entry{2};
    k      = entry{3};   % original station index (for data + groynes)

    % --- On group change: pad remaining columns ---
    if ~strcmp(gLabel, currentGroup)
        while colInRow > 0 && colInRow < nCols
            if ~legendPlaced
                axLeg = nexttile(t);
                axis(axLeg,'off');
                buildLegend(axLeg, royalBlue, baseOrange);
                legendPlaced = true;
            else
                axE = nexttile(t); axis(axE,'off');
            end
            tileIdx  = tileIdx + 1;
            colInRow = colInRow + 1;
            if colInRow == nCols, colInRow = 0; end
        end
        currentGroup = gLabel;
        colInRow = 0;
        g = g + 1;
    end

    % --- Create tile ---
    ax       = nexttile(t);
    tileIdx  = tileIdx + 1;
    colInRow = colInRow + 1;
    if colInRow == nCols, colInRow = 0; end

    isLeftCol = (mod(tileIdx-1, nCols) == 0);

    % Record first axes per group (for group label annotation)
    if numel(groupFirstAxes) < g
        groupFirstAxes{g} = {gLabel, ax};
    end

    hold(ax,'on');

    % ---- Prepare T0 data ----------------------------------------
    v0 = []; z0_at_v = []; valid0 = false(0);
    if ~isempty(k) && exist('WL_Zimm','var') && exist('WL_Zimm_time','var') ...
            && numel(time0) >= k && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        if iscell(WL_Zimm) && numel(WL_Zimm) >= k
            zWL = WL_Zimm{k}(:);      tWL = WL_Zimm_time{k}(:);
        else
            zWL = WL_Zimm(:);         tWL = WL_Zimm_time(:);
        end
        tV0 = time0{k}(:); v0 = vel0_da{k}(:);
        twl_num = local_datenum(tWL);
        tv0_num = local_datenum(tV0);
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            z0_at_v = interp1(twl_num(validWL), zWL(validWL), tv0_num,'linear',NaN);
        else
            z0_at_v = NaN(size(v0));
        end
        valid0 = ~isnan(z0_at_v) & ~isnan(v0);
    end

    % ---- Prepare T1 data ----------------------------------------
    v1 = []; z1_at_v = []; valid1 = false(0);
    if ~isempty(k) && exist('WL_Zimm1','var') && exist('WL_Zimm_time1','var') ...
            && numel(time1) >= k && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        if iscell(WL_Zimm1) && numel(WL_Zimm1) >= k
            zWL1 = WL_Zimm1{k}(:);    tWL1 = WL_Zimm_time1{k}(:);
        else
            zWL1 = WL_Zimm1(:);       tWL1 = WL_Zimm_time1(:);
        end
        tV1 = time1{k}(:); v1 = vel1_da{k}(:);
        twl1_num = local_datenum(tWL1);
        tv1_num  = local_datenum(tV1);
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            z1_at_v = interp1(twl1_num(validWL1), zWL1(validWL1), tv1_num,'linear',NaN);
        else
            z1_at_v = NaN(size(v1));
        end
        valid1 = ~isnan(z1_at_v) & ~isnan(v1);
    end

    % ---- Bin & plot T0 ------------------------------------------
    if any(valid0)
        v0r = v0(valid0); z0r = z0_at_v(valid0);
        v0_eb = NaN(numel(z_centers),nPct);
        v0_fl = NaN(numel(z_centers),nPct);
        for b = 1:numel(z_centers)
            ib = z0r >= z_edges(b) & z0r < z_edges(b+1);
            if any(ib)
                vb = v0r(ib);
                ve = vb(vb <  0); if ~isempty(ve), v0_eb(b,:) = prctile(ve,pctiles); end
                vf = vb(vb >= 0); if ~isempty(vf), v0_fl(b,:) = prctile(vf,pctiles); end
            end
        end
        local_plotEnv(ax, v0_eb, z_centers, royalBlue,  0.4, 2.0);
        local_plotEnv(ax, v0_fl, z_centers, royalBlue,  0.4, 2.0);
    end

    % ---- Bin & plot T1 ------------------------------------------
    if any(valid1)
        v1r = v1(valid1); z1r = z1_at_v(valid1);
        v1_eb = NaN(numel(z_centers),nPct);
        v1_fl = NaN(numel(z_centers),nPct);
        for b = 1:numel(z_centers)
            ib = z1r >= z_edges(b) & z1r < z_edges(b+1);
            if any(ib)
                vb = v1r(ib);
                ve = vb(vb <  0); if ~isempty(ve), v1_eb(b,:) = prctile(ve,pctiles); end
                vf = vb(vb >= 0); if ~isempty(vf), v1_fl(b,:) = prctile(vf,pctiles); end
            end
        end
        local_plotEnv(ax, v1_eb, z_centers, baseOrange, 0.4, 2.5);
        local_plotEnv(ax, v1_fl, z_centers, baseOrange, 0.4, 2.5);
    end

    % ---- Axis formatting ----------------------------------------
    xLimits = [-1.7 1.7]; yLimits = [-2 4];
    xlim(ax, xLimits); ylim(ax, yLimits);
    ax.XTick = [-1 0 1];
    ax.XTickLabelMode = 'auto';
    ax.YTickLabel = {};
    if isLeftCol, ax.YTickLabelMode = 'auto'; end
    grid(ax,'on');
    ax.GridAlpha = 0.1;
    ax.FontSize  = 11;
    title(ax, sName,'Interpreter','none','FontSize',13);

    % Ebb / Flood corner text
    xp = 0.03*range(xLimits); yp = 0.02*range(yLimits);
    text(ax, xLimits(1)+xp, yLimits(1)+yp, 'ebb',  ...
        'HorizontalAlignment','left', 'VerticalAlignment','bottom', ...
        'FontSize',10,'FontWeight','bold','Color',[0.7 0.7 0.7]);
    text(ax, xLimits(2)-xp, yLimits(1)+yp, 'flood', ...
        'HorizontalAlignment','right','VerticalAlignment','bottom', ...
        'FontSize',10,'FontWeight','bold','Color',[0.7 0.7 0.7]);

    % Zero reference line
    line(ax,[0 0],[-3 4],'Color',[0.3 0.3 0.3],'LineWidth',0.5,'HandleVisibility','off');

    % ---- Groynes ------------------------------------------------
    if ~isempty(k) && ismember(k, valid_k)
        rw = 0.06*range(xLimits);
        if isKey(groyne_y1, int32(k))
            hGL = local_drawRect(ax, [xLimits(1) xLimits(1)+rw], ...
                groyne_y1(int32(k)), rect_color, rect_alpha, yLimits);
            if ~isempty(hGL), uistack(hGL,'top'); end
        end
        if isKey(groyne_y2, int32(k))
            hGR = local_drawRect(ax, [xLimits(2)-rw xLimits(2)], ...
                groyne_y2(int32(k)), rect_color, rect_alpha, yLimits);
            if ~isempty(hGR), uistack(hGR,'top'); end
        end
    end

    hold(ax,'off');
end



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