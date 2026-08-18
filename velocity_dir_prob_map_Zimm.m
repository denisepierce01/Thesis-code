% Compare T0 and T1 ADCP observations of velocity in space and time
% (DEPTH_AVG)
% D. Pierce

clear all
close all
clc

%% importing KML boundaries
dirs.figures = 'p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\Bath_flow';

% *** BATHYMETRY ***
load('p:\11207654-bathosszimm\04_Data\Bathymetrie\VAKL23_LIDAR23_AHN4.mat');

% *** POLYGONS ***
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Boundary_polygoon\Buitendijks_polygoon_Bath_Ossenisse_Zimmerman.kml');
for ki = 1:length(KML)
    [POL_x{ki},POL_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

% *** BATHYMETRY ***
load('p:\11207654-bathosszimm\04_Data\Bathymetrie\VAKL23_LIDAR23_AHN4.mat');

% *** KMLs ***
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\7_1_2026\Aangepast.kml');
for ki = 1:length(KML)
    [Aangepast_x{ki},Aangepast_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\7_1_2026\Nieuw.kml');
for ki = 1:length(KML)
    [Nieuw_x{ki},Nieuw_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\7_1_2026\HVP.kml');
for ki = 1:length(KML)
    [HVP_x{ki},HVP_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\7_1_2026\Bestaand.kml');
for ki = 1:length(KML)
    [Bestaand_x{ki},Bestaand_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

%% Load measurement data
load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')

%% ADCP Observations
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

% siteFields = fieldnames(ADCP.ZIMMERMAN.T0);
% Exclude non-station fields if any (assume station fields contain 'MP' or similar)
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
% Create station names for titles without the 'MP' prefix if present
stationNames_title = stationNames;
for i = 1:numel(stationNames_title)
    stationNames_title{i} = regexprep(stationNames_title{i}, '^MP', '');
end
nStations = length(stationNames);

% Preallocate cell arrays to hold time, magnitude and direction for each station
time0 = cell(size(stationNames));
vel0_da = cell(size(stationNames));
dir0_da = cell(size(stationNames));
RDx0 = cell(size(stationNames));
RDy0 = cell(size(stationNames));

% Initialize time1, vel1_da, dir1_da in case missing
time1 = cell(size(stationNames));
vel1_da = cell(size(stationNames));
dir1_da = cell(size(stationNames));
RDx1 = cell(size(stationNames));
RDy1 = cell(size(stationNames));

for k = 1:nStations
    s = stationNames{k};
    % Default empty
    time0{k} = [];
    vel0_da{k} = [];
    dir0_da{k} = [];
    RDx0{k} = [];
    RDy0{k} = [];
    % Check existence of station and required fields
    if isfield(ADCP.ZIMMERMAN.T0, s)
        fld = ADCP.ZIMMERMAN.T0.(s);
        % Try to read variables if they exist
        if isfield(fld, 't_CET'), t0 = fld.t_CET; else t0 = []; end
        if isfield(fld, 'Umag_da'), v0 = fld.Umag_da; else v0 = []; end
        if isfield(fld, 'Udir_da'), d0 = fld.Udir_da; else d0 = []; end
        if isfield(fld, 'META') && isfield(fld.META, 'RDX'), rdx0 = fld.META.RDX; else rdx0 = []; end
        if isfield(fld, 'META') && isfield(fld.META, 'RDY'), rdy0 = fld.META.RDY; else rdy0 = []; end

        % Ensure column vector for time
        if ~isempty(t0), t0 = t0(:); end

        % Remove rows (observations) where all relevant vars are NaN or mismatched
        % If v0 or d0 are matrices with same number of rows as t0, treat rows as observations
        if ~isempty(t0)
            nObs = numel(t0);
            mask = true(nObs,1);
            if ~isempty(v0) && size(v0,1)==nObs
                mask = mask & any(~isnan(v0),2);
            elseif ~isempty(v0) && isvector(v0)
                v0 = v0(:);
                if numel(v0)==nObs
                    mask = mask & ~isnan(v0);
                end
            end
            if ~isempty(d0) && size(d0,1)==nObs
                mask = mask & any(~isnan(d0),2);
            elseif ~isempty(d0) && isvector(d0)
                d0 = d0(:);
                if numel(d0)==nObs
                    mask = mask & ~isnan(d0);
                end
            end
            % Apply mask where appropriate
            t0 = t0(mask,:);
            if ~isempty(v0) && size(v0,1)==nObs, v0 = v0(mask,:); elseif ~isempty(v0) && numel(v0)==nObs, v0 = v0(mask); end
            if ~isempty(d0) && size(d0,1)==nObs, d0 = d0(mask,:); elseif ~isempty(d0) && numel(d0)==nObs, d0 = d0(mask); end
            % If RDx/RDy are per-observation vectors, mask them too
            if ~isempty(rdx0) && numel(rdx0)==nObs, rdx0 = rdx0(mask); end
            if ~isempty(rdy0) && numel(rdy0)==nObs, rdy0 = rdy0(mask); end
        else
            % If no time, just remove NaNs within v0/d0 individually
            if ~isempty(v0), v0 = v0(~all(isnan(v0),2),:); end
            if ~isempty(d0), d0 = d0(~all(isnan(d0),2),:); end
        end

        % If still empty arrays because of shape, convert empty to []
        if isempty(t0), t0 = []; end
        if isempty(v0), v0 = []; end
        if isempty(d0), d0 = []; end
        if isempty(rdx0), rdx0 = []; end
        if isempty(rdy0), rdy0 = []; end

        time0{k} = t0;
        vel0_da{k} = v0;
        dir0_da{k} = d0;
        RDx0{k} = rdx0;
        RDy0{k} = rdy0;
    else
        % ensure cells are empty if station missing
        RDx0{k} = [];
        RDy0{k} = [];
    end
end

% Process T1 stations similarly
for k = 1:nStations
    s = stationNames{k};
    time1{k} = [];
    vel1_da{k} = [];
    dir1_da{k} = [];
    RDx1{k} = [];
    RDy1{k} = [];
    if isfield(ADCP.ZIMMERMAN.T1, s)
        fld = ADCP.ZIMMERMAN.T1.(s);
        if isfield(fld, 't_CET'), t1 = fld.t_CET; else t1 = []; end
        if isfield(fld, 'Umag_da'), v1 = fld.Umag_da; else v1 = []; end
        if isfield(fld, 'Udir_da'), d1 = fld.Udir_da; else d1 = []; end
        if isfield(fld, 'META') && isfield(fld.META, 'RDX'), rdx1 = fld.META.RDX; else rdx1 = []; end
        if isfield(fld, 'META') && isfield(fld.META, 'RDY'), rdy1 = fld.META.RDY; else rdy1 = []; end

        if ~isempty(t1), t1 = t1(:); end

        if ~isempty(t1)
            nObs = numel(t1);
            mask = true(nObs,1);
            if ~isempty(v1) && size(v1,1)==nObs
                mask = mask & any(~isnan(v1),2);
            elseif ~isempty(v1) && isvector(v1)
                v1 = v1(:);
                if numel(v1)==nObs
                    mask = mask & ~isnan(v1);
                end
            end
            if ~isempty(d1) && size(d1,1)==nObs
                mask = mask & any(~isnan(d1),2);
            elseif ~isempty(d1) && isvector(d1)
                d1 = d1(:);
                if numel(d1)==nObs
                    mask = mask & ~isnan(d1);
                end
            end
            t1 = t1(mask,:);
            if ~isempty(v1) && size(v1,1)==nObs, v1 = v1(mask,:); elseif ~isempty(v1) && numel(v1)==nObs, v1 = v1(mask); end
            if ~isempty(d1) && size(d1,1)==nObs, d1 = d1(mask,:); elseif ~isempty(d1) && numel(d1)==nObs, d1 = d1(mask); end
            if ~isempty(rdx1) && numel(rdx1)==nObs, rdx1 = rdx1(mask); end
            if ~isempty(rdy1) && numel(rdy1)==nObs, rdy1 = rdy1(mask); end
        else
            if ~isempty(v1), v1 = v1(~all(isnan(v1),2),:); end
            if ~isempty(d1), d1 = d1(~all(isnan(d1),2),:); end
        end

        if isempty(t1), t1 = []; end
        if isempty(v1), v1 = []; end
        if isempty(d1), d1 = []; end
        if isempty(rdx1), rdx1 = []; end
        if isempty(rdy1), rdy1 = []; end

        time1{k} = t1;
        vel1_da{k} = v1;
        dir1_da{k} = d1;
        RDx1{k} = rdx1;
        RDy1{k} = rdy1;
    else
        RDx1{k} = [];
        RDy1{k} = [];
    end
end


%% -----------------histogram plotting--------------------
% --- Configuration ---
bins = 0:10:360; 
binCentersDeg = bins(1:end-1) + diff(bins)/2;
nBins = length(binCentersDeg);

% Use the larger of the two counts to avoid indexing errors
maxK = max(numel(dir0_da), numel(dir1_da));

for k = 1:maxK
    % Get data for both scenarios
    D0 = []; if k <= numel(dir0_da), D0 = dir0_da{k}; end
    D1 = []; if k <= numel(dir1_da), D1 = dir1_da{k}; end
    
    % Skip if both are empty
    if isempty(D0) && isempty(D1), continue; end
    
    % Setup Figure
    figName = sprintf('Direction_Hist_ZIMMERMAN_%d', k);
    figure('Name', figName, 'NumberTitle', 'off', 'Color', 'w', 'Position', [100, 100, 800, 400]);
    hold on;
    
    % Process and Plot T0
    if ~isempty(D0)
        if max(abs(D0)) <= 2*pi, D0 = rad2deg(D0); end
        D0 = mod(D0, 360);
        counts0 = histcounts(D0, bins);
        probs0  = counts0 / sum(counts0);
        
        bar(binCentersDeg, probs0, 1, 'FaceColor', [0 0.447 0.741], 'FaceAlpha', 0.5, 'DisplayName', 'T0');
    end
    
    % Process and Plot T1
    if ~isempty(D1)
        if max(abs(D1)) <= 2*pi, D1 = rad2deg(D1); end
        D1 = mod(D1, 360);
        counts1 = histcounts(D1, bins);
        probs1  = counts1 / sum(counts1);
        
        bar(binCentersDeg, probs1, 1, 'FaceColor', [0.85 0.325 0.098], 'FaceAlpha', 0.5, 'DisplayName', 'T1');
    end
    
    % Formatting
    xlim([0 360]);
    xticks(0:60:360);
    ax = gca;
    ax.FontSize = 16; 
    grid on;
    xlabel('Direction (deg)', 'FontSize', 20);
    ylabel('Probability', 'FontSize', 20);
    legend('Location', 'northeast', 'FontSize', 18);
    
    stnName = 'Unknown';
    if k <= numel(stationNames), stnName = stationNames_title{k}; end
    title(['Current Direction Distributions: ', stnName], 'FontSize', 28);
    
    hold off;
end

% % Export figures as PNGs
% outDir = fullfile('P:','11207654-internship-pierce-2026','02_Data','Velocity_data_ADCP','Figures','ZIMMERMAN_T0T1_histogram');
% if ~exist(outDir,'dir')
%     mkdir(outDir);
% end
% 
% % Find all open figures created above (named per station)
% figHandles = findall(0,'Type','figure');
% 
% for i = 1:numel(figHandles)
%     fig = figHandles(i);
%     % Try to get station name from figure Name property; fallback to figure number
%     fnameBase = fig.Name;
%     if isempty(fnameBase)
%         fnameBase = sprintf('Figure_%d', fig.Number);
%     end
%     % sanitize filename: remove or replace illegal chars
%     fnameBase = regexprep(fnameBase, '[\/\\:\*\?"<>\|]', '_');
%     fname = fullfile(outDir, [fnameBase, '.png']);
%     try
%         % Ensure we don't invert colors when saving
%         fig.InvertHardcopy = 'off';
%         exportgraphics(fig, fname, 'BackgroundColor', 'white', 'Resolution', 300);
%     catch
%         % fallback to saveas if exportgraphics unavailable
%         saveas(fig, fname);
%     end
% end 

% % Create figure with equal axes umag and udir T0 vs T1
%     fig = figure('Color','w','Name',stationNames{min(sIdx,numel(stationNames))}, 'NumberTitle','off', 'Position',[200 200 1000 420]);
%     % LEFT: T0
%     ax1 = subplot(1,2,1, polaraxes); hold(ax1,'on');
%     if n0 > 0
%         cmap0 = jet(n0);
%         for i = 1:n0
%             polarplot(ax1, [D0(i), D0(i)], [0, V0(i)], 'Color', cmap0(i,:), 'LineWidth', 2);
%         end
%         ax1.CLim = [1, n0];
%         colormap(ax1, jet(n0));
%         cb1 = colorbar(ax1);
%         if exist('startTime0','var') && exist('endTime0','var')
%             set(cb1, 'Ticks', [1, n0], 'TickLabels', {startTime0, endTime0});
%         end
%     end
%     title(ax1, 'T0');
%     ax1.ThetaDir = 'clockwise';
%     ax1.ThetaZeroLocation = 'top';
%     ax1.RAxis.Label.String = 'velocity (m/s)';
%     % RIGHT: T1 (plot probabilities instead of velocities)
%     ax2 = subplot(1,2,2, polaraxes); hold(ax2,'on');
%     if n1 > 0
%         % Assume V1 currently holds velocities; convert to probabilities in [0,1]
%         % If probabilities are already provided in V1, this is harmless.
%         probs = V1;
%         % If any values >1, normalize by the maximum to get relative probabilities
%         if any(probs > 1)
%             maxp = max(probs);
%             if maxp > 0
%                 probs = probs ./ maxp;
%             else
%                 probs = zeros(size(probs));
%             end
%         end
%         % Scale probabilities to a sensible radial range (0 to rMax will be set later)
%         % Here we keep them in [0,1] and rely on later code to set radial limits.
%         cmap1 = parula(n1);
%         for i = 1:n1
%             % Use probability as radial length (0..1)
%             polarplot(ax2, [D1(i), D1(i)], [0, probs(i)], 'Color', cmap1(i,:), 'LineWidth', 2);
%         end
%         % Use color to indicate sample order; set CLim accordingly
%         ax2.CLim = [1, n1];
%         colormap(ax2, parula(n1));
%         cb2 = colorbar(ax2);
%         if exist('startTime1','var') && exist('endTime1','var')
%             set(cb2, 'Ticks', [1, n1], 'TickLabels', {startTime1, endTime1});
%         end
%         % Label radial axis to indicate probabilities
%         ax2.RAxis.Label.String = 'probability (scaled)';
%     end
%     title(ax2, 'T1');
%     ax2.ThetaDir = 'clockwise';
%     ax2.ThetaZeroLocation = 'top';
%     ax2.RAxis.Label.String = 'velocity (m/s)';
%     % Ensure both polar axes use identical radial limits and ticks based on
%     % the combined data so velocity intervals match between plots
%     allV = [];
%     if exist('V0','var') && ~isempty(V0), allV = [allV; V0(:)]; end
%     if exist('V1','var') && ~isempty(V1), allV = [allV; V1(:)]; end
%     if isempty(allV)
%         rMax = 1;
%     else
%         rMax = max(allV);
%         if rMax == 0, rMax = 1; end
%     end
%     % Choose a sensible number of radial ticks (up to 5) and round nicely
%     nTicks = min(5, max(2, ceil(rMax))); % at least 2 ticks, up to 5
%     tickStep = ceil(rMax / nTicks * 10) / 10; % round step to 0.1
%     rTicks = 0:tickStep:(tickStep * nTicks);
%     if rTicks(end) < rMax, rTicks = [rTicks, rMax]; end
%     rTicks = unique(rTicks);
%     % Apply to both axes
%     ax1.RLim = [0, max(rTicks)];
%     ax2.RLim = [0, max(rTicks)];
%     ax1.RTick = rTicks;
%     ax2.RTick = rTicks;
%     % Central title with station name
%     nameStr = stationNames{min(sIdx,numel(stationNames))};
%     if isstring(nameStr), nameStr = char(nameStr); end
%     sgtitle(sprintf('ZIMMERMAN %s', nameStr), 'FontSize', 16, 'FontWeight', 'bold');
%     drawnow;
%     end

%% --------probaility but no velocity magnitudes---------
for k = 1:nStations
    %----T0 (LEFT)----

    fig_k = figure('Name', sprintf('Station %d - %s', k, stationNames{k}), ...
                   'NumberTitle', 'off', 'Color', 'w', 'Position', get(0,'DefaultFigurePosition'));
    ax = polaraxes(fig_k); hold(ax, 'on');
    % plot polar histogram for this station (convert degrees to radians)
    if ~isempty(dir0_da) && numel(dir0_da) >= k && ~isempty(dir0_da{k})
        ph = polarhistogram(ax, deg2rad(dir0_da{k}(:)), 18, 'BinLimits', [0 2*pi], ...
            'Normalization', 'probability', ...
            'FaceAlpha', 0.5, ...
            'EdgeColor', 'none', ...
            'DisplayName', 'T0');
    end
    if ~isempty(dir1_da) && numel(dir1_da) >= k && ~isempty(dir1_da{k})
        ph = polarhistogram(ax, deg2rad(dir1_da{k}(:)), 18, 'BinLimits', [0 2*pi], ...
            'Normalization', 'probability', ...
            'FaceAlpha', 0.5, ...
            'EdgeColor', 'none', ...
            'DisplayName', 'T1');
    end
    ax.ThetaZeroLocation = 'top';
    ax.ThetaDir = 'clockwise';
    ax.RAxis.Label.String = 'Probability';
    ax.RAxis.Label.FontSize = 14;
    ax.RAxis.FontSize = 12;
    ax.ThetaAxis.FontSize = 16;
    title(ax, sprintf('%s', stationNames_title{k}), 'FontSize', 20);
end

% %% Plot dir1_da spatial map with1st and 2nd highest (declustered) probability
% % 1. Initialize Spatial Arrays for all nStations (based on dir1_da)
% nStations = numel(dir1_da);
% plot_X = nan(nStations, 1);
% plot_Y = nan(nStations, 1);
% plot_ZBED = nan(nStations, 1);
% 
% % Primary Peak Vectors (T1 direction, scaled by Max T1 prob)
% plot_U1 = zeros(nStations, 1);
% plot_V1 = zeros(nStations, 1);
% arrow_length1 = zeros(nStations, 1);
% 
% % Secondary Peak Vectors (Declustered T1 direction, scaled by 2nd Max T1 prob)
% plot_U2 = zeros(nStations, 1);
% plot_V2 = zeros(nStations, 1);
% arrow_length2 = zeros(nStations, 1);
% 
% % Define the bins (36 bins between 0 and 2*pi, each bin is 10 degrees)
% num_bins = 36;
% bin_edges = linspace(0, 2*pi, num_bins + 1);
% bin_centers = movmean(bin_edges, 2, 'Endpoints', 'discard');
% 
% % Pre-allocate probability tracking matrices for T1
% probs1 = nan(nStations, num_bins);
% 
% for k = 1:nStations
%     % Safe Coordinate Fetch from RDx1/RDy1 to prevent array bound errors
%     if exist('RDx1','var') && exist('RDy1','var') && ...
%        (~isempty(RDx1) && ~isempty(RDy1)) && ...
%        (iscell(RDx1) && k <= numel(RDx1) || ~iscell(RDx1) && k <= size(RDx1, 2))
% 
%         if iscell(RDx1), xk = RDx1{k}; else xk = RDx1(:,k); end
%         if iscell(RDy1), yk = RDy1{k}; else yk = RDy1(:,k); end
% 
%         if isscalar(xk), plot_X(k) = xk; else plot_X(k) = xk(1); end
%         if isscalar(yk), plot_Y(k) = yk; else plot_Y(k) = yk(1); end
%     else
%         plot_X(k) = NaN; plot_Y(k) = NaN;
%     end
% 
%     if isempty(dir1_da{k}) || isnan(plot_X(k))
%         continue;
%     end
% 
%     % =====================================================================
%     % --- DECLUSTERING LOGIC FOR TWO HIGHEST PROBABILITIES (T1 only) ---
%     % =====================================================================
%     probs1_temp = probs1(k, :);
%     if ~all(isnan(probs1_temp)) && sum(probs1_temp) > 0
%         % --- 1st Peak (Highest Probability) ---
%         [max_prob1, max_idx1] = max(probs1_temp);
%         best_dir1 = bin_centers(max_idx1);
%         plot_U1(k) = sin(best_dir1);
%         plot_V1(k) = cos(best_dir1);
% 
%         % --- Apply Declustering Mask (Clear everything within 90 degrees) ---
%         ang_dist = abs(bin_centers - best_dir1);
%         ang_dist = min(ang_dist, 2*pi - ang_dist); 
%         decluster_mask = ang_dist < (pi / 2);
%         probs1_temp(decluster_mask) = 0; 
% 
%         % --- 2nd Peak (Highest remaining after declustering) ---
%         if sum(probs1_temp) > 0
%             [max_prob2, max_idx2] = max(probs1_temp);
%             best_dir2 = bin_centers(max_idx2);
%             plot_U2(k) = sin(best_dir2);
%             plot_V2(k) = cos(best_dir2);
%         else
%             max_idx2 = NaN;
%             max_prob2 = NaN;
%         end
% 
%         % --- DEFINE ARROW LENGTHS BASED ON probs1 BIN MATCHES ---
%         arrow_length1(k) = max_prob1;
%         if ~isnan(max_idx2)
%             arrow_length2(k) = max_prob2;
%         else
%             arrow_length2(k) = 0;
%         end
%     else
%         arrow_length1(k) = 0;
%         arrow_length2(k) = 0;
%     end
% end
% 
% % Ensure arrow lengths reflect the actual probabilities stored in probs1 (if available)
% if ~all(isnan(probs1(k, :)))
%     % Use the probability values at the selected bin indices where available
%     if exist('max_idx1','var') && ~isempty(max_idx1) && ~isnan(max_idx1)
%         arrow_length1(k) = probs1(k, max_idx1);
%     else
%         arrow_length1(k) = arrow_length1(k); % keep previously set value
%     end
%     if exist('max_idx2','var') && ~isempty(max_idx2) && ~isnan(max_idx2)
%         arrow_length2(k) = probs1(k, max_idx2);
%     else
%         % if second index missing, ensure length is zero
%         arrow_length2(k) = 0;
%     end
% else
%     arrow_length1(k) = 0;
%     arrow_length2(k) = 0;
% end
% 
% 
% % 2. Generate Map Plot
% figure('Color', 'w');
% hold on;
% 
% % Step A: Plot Station markers
% plot(plot_X, plot_Y, 'ko', 'MarkerFaceColor', [.5 .5 .5], 'MarkerSize', 6, 'DisplayName', 'Stations');
% 
% % Step B: Scale vectors manually
% spatial_scale_factor = 1; % Set this up or down based on your map axes scale
% 
% scaled_U1 = plot_U1 .* arrow_length1 * spatial_scale_factor;
% scaled_V1 = plot_V1 .* arrow_length1 * spatial_scale_factor;
% scaled_U2 = plot_U2 .* arrow_length2 * spatial_scale_factor;
% scaled_V2 = plot_V2 .* arrow_length2 * spatial_scale_factor;
% 
% % Step C: Add Quivers (setting autoscale parameter to 0 to preserve relative length proportions)
% q1 = quiver(plot_X, plot_Y, scaled_U1, scaled_V1, 0.3, ...
%            'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Primary Flow');
% q1.MaxHeadSize = 0.5;
% 
% q2 = quiver(plot_X, plot_Y, scaled_U2, scaled_V2, 0.3, ...
%            'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-', 'DisplayName', 'Secondary Flow');
% q2.MaxHeadSize = 0.5;
% 
% % 3. Format the Map View
% xlabel('RDx [km]', 'FontWeight', 'bold', 'FontSize', 28);
% ylabel('RDy [km]', 'FontWeight', 'bold', 'FontSize', 28);
% title('Flow Directions: T1', 'FontWeight', 'bold', 'FontSize', 40);
% axis equal; 
% 
% % --- Tick labels: convert to km (divide by 1000) and set font size 16 ---
% axTicksX = get(gca, 'XTick');
% axTicksY = get(gca, 'YTick');
% 
% % Divide tick values by 1000 for display (create labels)
% xTickLabels = arrayfun(@(v) sprintf('%.1f', v/1000), axTicksX, 'UniformOutput', false);
% yTickLabels = arrayfun(@(v) sprintf('%.1f', v/1000), axTicksY, 'UniformOutput', false);
% 
% set(gca, 'XTickLabel', xTickLabels, 'YTickLabel', yTickLabels, 'FontSize', 16);
% 
% % Also update axis labels to indicate units in km
% xlabel_str = get(get(gca,'XLabel'),'String');
% ylabel_str = get(get(gca,'YLabel'),'String');
% if isempty(strfind(xlabel_str, '[km]'))
%     xlabel([xlabel_str ' [km]'], 'FontWeight', 'bold', 'FontSize', 28);
% end
% if isempty(strfind(ylabel_str, '[km]'))
%     ylabel([ylabel_str ' [km]'], 'FontWeight', 'bold', 'FontSize', 28);
% end
% 
% lgd = legend('Location', 'best');
% set(lgd, 'Color', 'none', 'EdgeColor', 'none');
% 
% hold off;


% %% Plot T1 Spatial Map Directly Over Streamed Aerial Imagery (WGS84 Transformation)
% 
% % 1. Initialize Spatial Arrays for all nStations (based on dir1_da)
% nStations = numel(dir1_da);
% plot_X = nan(nStations, 1);
% plot_Y = nan(nStations, 1);
% plot_ZBED = nan(nStations, 1);
% 
% % Primary Peak Vectors (T1 direction, scaled by Max T1 prob)
% plot_U1 = zeros(nStations, 1);
% plot_V1 = zeros(nStations, 1);
% arrow_length1 = zeros(nStations, 1);
% 
% % Secondary Peak Vectors (Declustered T1 direction, scaled by 2nd Max T1 prob)
% plot_U2 = zeros(nStations, 1);
% plot_V2 = zeros(nStations, 1);
% arrow_length2 = zeros(nStations, 1);
% 
% % Define the bins (36 bins between 0 and 2*pi, each bin is 10 degrees)
% num_bins = 36;
% bin_edges = linspace(0, 2*pi, num_bins + 1);
% bin_centers = movmean(bin_edges, 2, 'Endpoints', 'discard');
% 
% % Pre-allocate probability tracking matrices for T1
% probs1 = nan(nStations, num_bins);
% 
% for k = 1:nStations
%     if ismember(k, [8, 12, 13, 18])
%         % skip these stations entirely
%         plot_X(k) = NaN; plot_Y(k) = NaN; plot_ZBED(k) = NaN;
%         plot_U1(k) = 0; plot_V1(k) = 0; arrow_length1(k) = 0;
%         plot_U2(k) = 0; plot_V2(k) = 0; arrow_length2(k) = 0;
%         probs1(k, :) = NaN;
%         continue;
%     end
%     % Safe Coordinate Fetch from RDx1/RDy1 to prevent array bound errors
%     if exist('RDx1','var') && exist('RDy1','var') && ...
%        (~isempty(RDx1) && ~isempty(RDy1)) && ...
%        (iscell(RDx1) && k <= numel(RDx1) || ~iscell(RDx1) && k <= size(RDx1, 2))
% 
%         if iscell(RDx1), xk = RDx1{k}; else xk = RDx1(:,k); end
%         if iscell(RDy1), yk = RDy1{k}; else yk = RDy1(:,k); end
% 
%         if isscalar(xk), plot_X(k) = xk; else plot_X(k) = xk(1); end
%         if isscalar(yk), plot_Y(k) = yk; else plot_Y(k) = yk(1); end
%     else
%         plot_X(k) = NaN; plot_Y(k) = NaN;
%     end
% 
%     if isempty(dir1_da{k}) || isnan(plot_X(k))
%         continue;
%     end
% 
%     % %-- bed level --
%     % try
%     %     if exist('ADCP','var') && isfield(ADCP, LOCS{1})
%     %         Ts_fields = fieldnames(ADCP.(LOCS{1}));
%     %         Inst_fields = fieldnames(ADCP.(LOCS{1}).(Ts_fields{1}));
%     %         if k <= numel(Inst_fields)
%     %             plot_ZBED(k) = ADCP.(LOCS{1}).(Ts_fields{1}).(Inst_fields{k}).META.ZBED;
%     %         end
%     %     end
%     % catch
%     %     plot_ZBED(k) = NaN;
%     % end
% 
%     % --- PROCESS T1 DIRECTIONS & PROBABILITIES (only T1 used) ---
%     D1k = dir1_da{k}(:);
%     if any(abs(D1k) > 2*pi), D1k = deg2rad(D1k); end
%     D1k = mod(D1k, 2*pi);
% 
%     counts1 = histcounts(D1k, bin_edges);
%     if sum(counts1) > 0
%         probs1(k, :) = counts1 / sum(counts1);
%     else
%         continue;
%     end
% 
%     % =====================================================================
%     % --- DECLUSTERING LOGIC FOR TWO HIGHEST PROBABILITIES (T1 only) ---
%     % =====================================================================
%     probs1_temp = probs1(k, :);
%     if ~all(isnan(probs1_temp)) && sum(probs1_temp) > 0
%         % --- 1st Peak (Highest Probability) ---
%         [max_prob1, max_idx1] = max(probs1_temp);
%         best_dir1 = bin_centers(max_idx1);
%         plot_U1(k) = sin(best_dir1);
%         plot_V1(k) = cos(best_dir1);
% 
%         % --- Apply Declustering Mask (Clear everything within 90 degrees) ---
%         ang_dist = abs(bin_centers - best_dir1);
%         ang_dist = min(ang_dist, 2*pi - ang_dist); 
%         decluster_mask = ang_dist < (pi / 2);
%         probs1_temp(decluster_mask) = 0; 
% 
%         % --- 2nd Peak (Highest remaining after declustering) ---
%         if sum(probs1_temp) > 0
%             [max_prob2, max_idx2] = max(probs1_temp);
%             best_dir2 = bin_centers(max_idx2);
%             plot_U2(k) = sin(best_dir2);
%             plot_V2(k) = cos(best_dir2);
%         else
%             max_idx2 = NaN;
%             max_prob2 = NaN;
%         end
% 
%         % --- DEFINE ARROW LENGTHS BASED ON probs1 BIN MATCHES ---
%         arrow_length1(k) = max_prob1;
%         if ~isnan(max_idx2)
%             arrow_length2(k) = max_prob2;
%         else
%             arrow_length2(k) = 0;
%         end
%     else
%         arrow_length1(k) = 0;
%         arrow_length2(k) = 0;
%     end
% end
% 
% % =====================================================================
% % 2. GEOGRAPHIC COORDINATE TRANSFORMATION (RD NEW TO WGS84)
% % =====================================================================
% % Initialize projection transformation configurations
% crs_rd = projcrs(28992);    % Amersfoort / RD New
% crs_wgs84 = geocrs(4326);   % WGS84 Latitude/Longitude
% 
% % Define target boundary windows in RD New meters
% xlims = [70500 71800];
% ylims = [378300 380600];
% 
% % Shift aerial footprint down by 100 m in RD New (translate in Y)
% y_shift = -100; % negative moves the aerial imagery south (down) by 100 m
% ylims_shifted = ylims + y_shift;
% 
% % Inverse project the bounding limits to discover Lat/Lon window coordinates
% [LatLimits, LonLimits] = projinv(crs_rd, xlims, ylims_shifted);
% 
% % Project individual measurements station coordinates safely
% % If plot_X/Y are in RD New, apply same shift so stations align relative to shifted aerial
% if exist('plot_X','var') && exist('plot_Y','var')
%     station_X = plot_X;
%     station_Y = plot_Y + y_shift;
%     [station_Lat, station_Lon] = projinv(crs_rd, station_X, station_Y);
% else
%     station_Lat = [];
%     station_Lon = [];
% end
% % =====================================================================
% % 3. GENERATE GEOGRAPHIC MAP PLOT OVER AERIAL TILES (PDOK SEAMLESS BACKGROUND)
% % =====================================================================
% % 1. Define the seamless, color-corrected Dutch national mosaic layer (25cm resolution)
% name = 'pdok_luchtfoto';
% url = 'https://service.pdok.nl/hwh/luchtfotorgb/wmts/v1_0/Actueel_ortho25/EPSG:3857/${z}/${x}/${y}.jpeg';
% attribution = 'Background: © PDOK / Kadaster';
% 
% % 2. Register the clean, seamless Dutch server
% addCustomBasemap(name, url, 'Attribution', attribution);
% 
% % 3. Spin up the figure using our clean backdrop
% figure('Color', 'w');
% gx = geoaxes('Basemap', name); 
% hold(gx, 'on');
% 
% % Set map viewport coordinates (using your transformed Lat/Lon windows)
% geolimits(gx, LatLimits, LonLimits);
% 
% % --- PLOT STATION VECTOR DATA ---
% geoplot(gx, station_Lat, station_Lon, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 7, 'DisplayName', 'Stations');
% 
% % Create handles for arrows so we can add a custom scale entry representing probability.
% probScaleValue = 0.2; % representative probability (0..1) to display in legend
% scaleArrowLengthLat = probScaleValue * mean(abs(arrow_length1(~isnan(arrow_length1))) + eps) * 0.01; % small geographic offset
% scaleArrowLengthLon = scaleArrowLengthLat;
% 
% % Use geoquiver for arrows; if unavailable, gracefully fallback to manual plotting
% if exist('geoquiver', 'file') == 2
%     q1 = geoquiver(gx, station_Lat, station_Lon, scaled_V1, scaled_U1, 0, ...
%                   'LineWidth', 2.5, 'Color', 'b', 'DisplayName', 'Ebb');
%     q2 = geoquiver(gx, station_Lat, station_Lon, scaled_V2, scaled_U2, 0, ...
%                   'LineWidth', 1.8, 'Color', 'r', 'LineStyle', '-', 'DisplayName', 'Flood');
% else
%     % Fallback: draw arrows manually using geoplot with triangular tips
%     endLat1 = station_Lat + scaled_V1;
%     endLon1 = station_Lon + scaled_U1;
%     for i = 1:numel(station_Lat)
%         % ONLY give a DisplayName to the first station line
%         if i == 1
%             geoplot(gx, [station_Lat(i), endLat1(i)], [station_Lon(i), endLon1(i)], '-', ...
%                     'Color', 'b', 'LineWidth', 2.5, 'DisplayName', 'Ebb');
%         else
%             geoplot(gx, [station_Lat(i), endLat1(i)], [station_Lon(i), endLon1(i)], '-', ...
%                     'Color', 'b', 'LineWidth', 2.5, 'HandleVisibility', 'off');
%         end
%         % Arrow heads are always hidden from the legend
%         geoplot(gx, endLat1(i), endLon1(i), '^', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'MarkerSize', 7, 'HandleVisibility', 'off');
%     end
% 
%     endLat2 = station_Lat + scaled_V2;
%     endLon2 = station_Lon + scaled_U2;
%     for i = 1:numel(station_Lat)
%         % ONLY give a DisplayName to the first station line
%         if i == 1
%             geoplot(gx, [station_Lat(i), endLat2(i)], [station_Lon(i), endLon2(i)], '-', ...
%                     'Color', 'r', 'LineWidth', 1.8, 'DisplayName', 'Flood');
%         else
%             geoplot(gx, [station_Lat(i), endLat2(i)], [station_Lon(i), endLon2(i)], '-', ...
%                     'Color', 'r', 'LineWidth', 1.8, 'HandleVisibility', 'off');
%         end
%         % Arrow heads are always hidden from the legend
%         geoplot(gx, endLat2(i), endLon2(i), '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerSize', 6, 'HandleVisibility', 'off');
%     end
% 
%     % Clean up old legacy clean-up lines that are no longer needed
%     q1 = []; q2 = [];
% end
% 
% % --- ADD PROBABILITY SCALE ENTRY TO LEGEND ---
% hProb = line(nan, nan, 'LineWidth', 2, 'Color', [0 0 0], 'Marker', '>', ...
%              'MarkerSize', 8, 'MarkerFaceColor', [0.3 0.3 0.3], 'DisplayName', sprintf('Probability: %.0f%%', probScaleValue*100));
% 
% % Formatting Text Layout Properties
% gx.FontSize = 14;
% title(gx, 'Flow Directions: T1', 'FontWeight', 'bold', 'FontSize', 30);
% lgd = legend(gx, 'Location', 'best', 'FontSize', 20);
% set(lgd, 'Color', 'none', 'EdgeColor', 'none');
% grid('off')
% hold(gx, 'off');

% %% export transparently
% fig = gcf;
% set(fig, 'Color', 'none');
% set(gca, 'Color', 'none');
% set(fig, 'InvertHardcopy', 'off');
% 
% outDir = fullfile('P:\11207654-internship-pierce-2026','02_Data','Velocity_data_ADCP','Figures','Bath_flow');
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% 
% outFile = fullfile(outDir, 'flow_transparent.png');
% print(fig, outFile, '-dpng', '-r300');


% %% trying with quiver and geomap
% % 1. Initialize Spatial Arrays for all nStations (based on dir1_da)
% nStations = numel(dir1_da);
% plot_X = nan(nStations, 1);
% plot_Y = nan(nStations, 1);
% plot_ZBED = nan(nStations, 1);
% 
% % Primary Peak Vectors (T1 direction, scaled by Max T1 prob)
% plot_U1 = zeros(nStations, 1);
% plot_V1 = zeros(nStations, 1);
% arrow_length1 = zeros(nStations, 1);
% 
% % Secondary Peak Vectors (Declustered T1 direction, scaled by 2nd Max T1 prob)
% plot_U2 = zeros(nStations, 1);
% plot_V2 = zeros(nStations, 1);
% arrow_length2 = zeros(nStations, 1);
% 
% % Define the bins (36 bins between 0 and 2*pi, each bin is 10 degrees)
% num_bins = 36;
% bin_edges = linspace(0, 2*pi, num_bins + 1);
% bin_centers = movmean(bin_edges, 2, 'Endpoints', 'discard');
% 
% % Pre-allocate probability tracking matrices for T1
% probs1 = nan(nStations, num_bins);
% 
% for k = 1:nStations
%     if ismember(k, [8, 12, 13, 18])
%         % skip these stations entirely
%         plot_X(k) = NaN; plot_Y(k) = NaN; plot_ZBED(k) = NaN;
%         plot_U1(k) = 0; plot_V1(k) = 0; arrow_length1(k) = 0;
%         plot_U2(k) = 0; plot_V2(k) = 0; arrow_length2(k) = 0;
%         probs1(k, :) = NaN;
%         continue;
%     end
% 
%     % Safe Coordinate Fetch from RDx1/RDy1 to prevent array bound errors
%     if exist('RDx1','var') && exist('RDy1','var') && ...
%        (~isempty(RDx1) && ~isempty(RDy1)) && ...
%        (iscell(RDx1) && k <= numel(RDx1) || ~iscell(RDx1) && k <= size(RDx1, 2))
% 
%         if iscell(RDx1), xk = RDx1{k}; else xk = RDx1(:,k); end
%         if iscell(RDy1), yk = RDy1{k}; else yk = RDy1(:,k); end
% 
%         if isscalar(xk), plot_X(k) = xk; else plot_X(k) = xk(1); end
%         if isscalar(yk), plot_Y(k) = yk; else plot_Y(k) = yk(1); end
%     else
%         plot_X(k) = NaN; plot_Y(k) = NaN;
%     end
% 
%     if isempty(dir1_da{k}) || isnan(plot_X(k))
%         continue;
%     end
% 
%     % --- PROCESS T1 DIRECTIONS & PROBABILITIES (only T1 used) ---
%     D1k = dir1_da{k}(:);
%     if any(abs(D1k) > 2*pi), D1k = deg2rad(D1k); end
%     D1k = mod(D1k, 2*pi);
% 
%     counts1 = histcounts(D1k, bin_edges);
%     if sum(counts1) > 0
%         probs1(k, :) = counts1 / sum(counts1);
%     else
%         continue;
%     end
% 
%     % =====================================================================
%     % --- DECLUSTERING LOGIC FOR TWO HIGHEST PROBABILITIES (T1 only) ---
%     % =====================================================================
%     probs1_temp = probs1(k, :);
%     if ~all(isnan(probs1_temp)) && sum(probs1_temp) > 0
%         % --- 1st Peak (Highest Probability) ---
%         [max_prob1, max_idx1] = max(probs1_temp);
%         best_dir1 = bin_centers(max_idx1);
%         plot_U1(k) = sin(best_dir1);
%         plot_V1(k) = cos(best_dir1);
% 
%         % --- Apply Declustering Mask (Clear everything within 90 degrees) ---
%         ang_dist = abs(bin_centers - best_dir1);
%         ang_dist = min(ang_dist, 2*pi - ang_dist); 
%         decluster_mask = ang_dist < (pi / 2);
%         probs1_temp(decluster_mask) = 0; 
% 
%         % --- 2nd Peak (Highest remaining after declustering) ---
%         if sum(probs1_temp) > 0
%             [max_prob2, max_idx2] = max(probs1_temp);
%             best_dir2 = bin_centers(max_idx2);
%             plot_U2(k) = sin(best_dir2);
%             plot_V2(k) = cos(best_dir2);
%         else
%             max_idx2 = NaN;
%             max_prob2 = NaN;
%         end
% 
%         % --- DEFINE ARROW LENGTHS BASED ON probs1 BIN MATCHES ---
%         arrow_length1(k) = max_prob1;
%         if ~isnan(max_idx2)
%             arrow_length2(k) = max_prob2;
%         else
%             arrow_length2(k) = 0;
%         end
%     else
%         arrow_length1(k) = 0;
%         arrow_length2(k) = 0;
%     end
% end
% 
% % =====================================================================
% % 2. GEOGRAPHIC COORDINATE TRANSFORMATION (RD NEW TO WGS84)
% % =====================================================================
% % Initialize projection transformation configurations
% crs_rd = projcrs(28992);    % Amersfoort / RD New
% crs_wgs84 = geocrs(4326);   % WGS84 Latitude/Longitude
% 
% % Define target boundary windows in RD New meters
% xlims = [70500 71800];
% ylims = [378300 380600];
% 
% % Shift aerial footprint down by 100 m in RD New (translate in Y)
% y_shift = -100; 
% ylims_shifted = ylims + y_shift;
% 
% % Inverse project the bounding limits to discover Lat/Lon window coordinates
% [LatLimits, LonLimits] = projinv(crs_rd, xlims, ylims_shifted);
% 
% % Project individual measurements station coordinates safely
% if exist('plot_X','var') && exist('plot_Y','var')
%     station_X = plot_X;
%     station_Y = plot_Y + y_shift;
%     [station_Lat, station_Lon] = projinv(crs_rd, station_X, station_Y);
% else
%     station_Lat = [];
%     station_Lon = [];
% end
% 
% % =====================================================================
% % 3. GENERATE GEOGRAPHIC MAP PLOT OVER AERIAL TILES (PDOK SEAMLESS)
% % =====================================================================
% name = 'pdok_luchtfoto';
% url = 'https://service.pdok.nl/hwh/luchtfotorgb/wmts/v1_0/Actueel_ortho25/EPSG:3857/${z}/${x}/${y}.jpeg';
% attribution = 'Background: © PDOK / Kadaster';
% 
% % % Register the clean, seamless Dutch server
% % if ~ismember(name, custombasemaps)
% %     addCustomBasemap(name, url, 'Attribution', attribution);
% % end
% 
% % Spin up the figure using our clean backdrop
% figure('Color', 'w');
% gx = geoaxes('Basemap', name); 
% hold(gx, 'on');
% 
% % Set map viewport coordinates
% geolimits(gx, LatLimits, LonLimits);

%% -------- Tiled Polar Probability Histograms ---------
nStations = numel(stationNames);
nRows = 4;
nCols = 4;

% 1. Create figure with A4 Vertical proportions
fig = figure('Name', 'Directional Probability Tiled Figure', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 18, 19.5]; % Width=18cm, Height=25cm fits well on A4

% 2. Initialize Layout - use compact spacing but reserve space for the title
t = tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');

% Create a title that fits by using an annotation textbox above the tiled layout.
% This avoids overlapping the top row of tiles when exporting or displaying.
titleStr = 'Flow Directions: ZIMMERMAN';
fig.Units = 'normalized';
figPos = fig.Position;
% Reserve a bit of space at the top by increasing top padding via TileSpacing/Position adjustments
topMargin = 0.09; % fraction of figure height reserved for title

% Adjust tiled layout position to leave space for the title
t.Units = 'normalized';
% Left margin = 0.04, Width = 0.92 (leaves 4% buffer on both left and right edges)
t.Position = [0.04, 0.01, 0.92, 1 - topMargin];

% Create a textbox above the tiled layout for the title (centred, no box)
annotation(fig, 'textbox', [0.05, 1 - topMargin + 0.01, 0.9, topMargin - 0.02], ...
    'String', titleStr, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 20, ...
    'FontWeight', 'bold', ...
    'LineStyle', 'none', ...
    'Interpreter', 'none');

for k = 1:min(nStations, nRows*nCols)
    ax = polaraxes(t); 
    ax.Layout.Tile = k; 
    hold(ax, 'on');
    
    % ---- Plot T0 ----
    if k <= numel(dir0_da) && ~isempty(dir0_da{k})
        D0 = dir0_da{k}(:);
        % Convert to radians if data is in degrees
        if max(abs(D0)) > 2*pi, D0 = deg2rad(D0); end
        
        polarhistogram(ax, D0, 18, 'BinLimits', [0 2*pi], ...
            'Normalization', 'probability', ...
            'FaceColor',  [0 0.447 0.741], ...
            'FaceAlpha', 0.5, ...
            'EdgeColor', 'none', ...
            'DisplayName', 'T0');
    end
    
    % ---- Plot T1 ----
    if k <= numel(dir1_da) && ~isempty(dir1_da{k})
        D1 = dir1_da{k}(:);
        % Convert to radians if data is in degrees
        if max(abs(D1)) > 2*pi, D1 = deg2rad(D1); end
        
        polarhistogram(ax, D1, 18, 'BinLimits', [0 2*pi], ...
            'Normalization', 'probability', ...
            'FaceColor', [0.85 0.325 0.098], ...
            'FaceAlpha', 0.5, ...
            'EdgeColor', 'none', ...
            'DisplayName', 'T1');
    end
    % Format for Maximum Density
    ax.GridAlpha = 0.2;
    ax.ThetaZeroLocation = 'top';
    ax.ThetaDir = 'clockwise';
    % Show radial axis and label it 'Probability' with ticks and numeric labels
    ax.RAxis.Visible = 'on';
    ax.RAxis.Label.String = 'Probability';
    ax.RAxis.Label.FontSize = 8;
    ax.RAxis.FontSize = 8;
    % Set fixed radial limits for consistency across tiles and define ticks
    rlim(ax, [0 0.6]);
    ax.RTick = 0:0.3:0.6;
    ax.RTickLabel = {'', '0.3', '0.6'};
    % Reduce grid/line prominence for compact layout
    ax.GridAlpha = 0.15;

    % Cardinal labels only (keeps horizontal width narrow)
    ax.ThetaTick = 0:45:315;
    ax.ThetaTickLabel = {'', '', 'E','', 'S', '','W',''};
    % ax.ThetaAxis.LabelSide = 'inside';
    ax.ThetaAxis.FontSize = 8;
    % Keep title outside the polar axes (above the tile) to avoid overlap in tight layout
    if k <= numel(stationNames)
        % Place a small text object above the polar axes within the tile
        txtPos = [0.5, 1.02]; % normalized position just above the axes
        tTitle = text(ax, txtPos(1), txtPos(2), stationNames_title{k}, ...
            'Units', 'normalized', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'Interpreter', 'none');
        % % Ensure the text does not clip when exporting
        % tTitle.Clipping = 'off';
    end
end


% ==========================================
%  Legend (Select Tile)
% ==========================================
nexttile(15);
axis off;
hAx = gca;
hAx.Visible = 'off';

% Create invisible dummy plot objects that match the appearance of the

leg_T0 = patch(nan, nan, [0 0.4470 0.7410], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'Visible', 'on');
leg_T1 = patch(nan, nan, [0.8500 0.3250 0.0980], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'Visible', 'on');

% Make markers/patches not affect axis limits or visibility
set([leg_T0, leg_T1], 'HandleVisibility', 'on');

% Build legend using the dummy patches. Use 'Units' normalized afterwards to position if desired.
lgd = legend([leg_T0, leg_T1], {'T0 flow direction (depth-averaged)','T1 flow direction (depth-averaged)'}, ...
    'Location', 'west', ...
    'FontSize', 10, ...
    'Box', 'off', ...
    'Interpreter', 'none');

lgd.Units = 'normalized';

% export clear
% Export current figure (the tiled comparison) as a clean PNG
try
    fig = gcf;
    % Ensure white background and no inversion
    fig.Color = 'white';
    fig.InvertHardcopy = 'off';
    % Build output directory and filename
    outDir = fullfile('P:','11207654-internship-pierce-2026','02_Data','Velocity_data_ADCP','Figures','ZIMMERMAN_direction');
    if ~exist(outDir,'dir'), mkdir(outDir); end
    fname = fullfile(outDir, 'Flow-Direction.png');
    % Use exportgraphics if available for better fidelity
    if exist('exportgraphics','file') == 2
        exportgraphics(fig, fname, 'BackgroundColor', 'white', 'Resolution', 300);
    else
        % Fallback
        saveas(fig, fname);
    end
catch ME
    warning('Failed to export figure to PNG: %s', ME.message);
end


% %% Export figures as PNGs
% outDir = fullfile('P:','11207654-internship-pierce-2026','02_Data','Velocity_data_ADCP','Figures','ZIMMERMAN_T0T1_histogram');
% if ~exist(outDir,'dir')
%     mkdir(outDir);
% end
% 
% % Find all open figures created above (named per station)
% figHandles = findall(0,'Type','figure');
% 
% for i = 1:numel(figHandles)
%     fig = figHandles(i);
%     % Try to get station name from figure Name property; fallback to figure number
%     fnameBase = fig.Name;
%     if isempty(fnameBase)
%         fnameBase = sprintf('Figure_%d_1', fig.Number);
%     end
%     % sanitize filename: remove or replace illegal chars
%     fnameBase = regexprep(fnameBase, '[\/\\:\*\?"<>\|]', '_');
%     fname = fullfile(outDir, [fnameBase, '.png']);
%     try
%         % Ensure we don't invert colors when saving
%         fig.InvertHardcopy = 'off';
%         exportgraphics(fig, fname, 'BackgroundColor', 'white', 'Resolution', 300);
%     catch
%         % fallback to saveas if exportgraphics unavailable
%         saveas(fig, fname);
%     end
% end 

% %% ---tiled layout histogram to optimize space---
% % --- Configuration ---
% bins = 0:20:360; 
% binCentersDeg = bins(1:end-1) + diff(bins)/2;
% maxK = max(numel(dir0_da), numel(dir1_da));
% 
% % Create one large figure for the tiled layout
% figure('Name', 'Station Direction Comparison Grid', 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
% t = tiledlayout(5, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
% title(t, 'Comparison of Directional Distributions (T0 vs T1)', 'FontSize', 14, 'FontWeight', 'bold');
% 
% for k = 1:maxK
%     % Move to the next tile
%     nexttile;
%     hold on;
% 
%     % --- Process T0 ---
%     if k <= numel(dir0_da) && ~isempty(dir0_da{k})
%         D0 = dir0_da{k};
%         if max(abs(D0)) <= 2*pi, D0 = rad2deg(D0); end
%         D0 = mod(D0, 360);
%         counts0 = histcounts(D0, bins);
%         probs0  = counts0 / sum(counts0);
% 
%         bar(binCentersDeg, probs0, 1, 'FaceColor', [0.2 0.4 0.6], 'FaceAlpha', 0.5, 'DisplayName', 'T0');
%     end
% 
%     % --- Process T1 ---
%     if k <= numel(dir1_da) && ~isempty(dir1_da{k})
%         D1 = dir1_da{k};
%         if max(abs(D1)) <= 2*pi, D1 = rad2deg(D1); end
%         D1 = mod(D1, 360);
%         counts1 = histcounts(D1, bins);
%         probs1  = counts1 / sum(counts1);
% 
%         bar(binCentersDeg, probs1, 1, 'FaceColor', [0.8 0.3 0.3], 'FaceAlpha', 0.5, 'DisplayName', 'T1');
%     end
% 
%     % --- Formatting each tile ---
%     xlim([0 360]);
%     ylim([0 1]); % Standardize Y-axis to compare stations easily
%     xticks(0:180:360); % Reduced ticks for cleaner look in small tiles
%     grid on;
% 
%     % Station Name as Subtitle
%     if k <= numel(stationNames)
%         title(stationNames{k}, 'FontSize', 10);
%     else
%         title(sprintf('Station %d', k));
%     end
% 
%     % Only show labels on the outer edges to save space
%     if mod(k-1, 4) == 0, ylabel('Prob.'); end
%     if k > 16, xlabel('Deg.'); end
% end
% 
% % Add a single shared legend for the whole grid
% lgd = legend('Orientation', 'horizontal');
% lgd.Layout.Tile = 'south';
% 

%% GRAPHED CORRECT FROM ORIGIN AS LINES! ----LEFT: T0----
    % ax1 = subplot(1,2,1, polaraxes); hold(ax1,'on');
    % if n0 > 0
    %     % Compute probability of each magnitude value in V0 (fraction of occurrences)
    %     % If V0 contains continuous values, bin them first so probabilities make sense.
    %     % Use unique magnitudes if discrete, otherwise bin into up to 20 bins.
    %     uniqueVals = unique(V0);
    %     if numel(uniqueVals) <= 20
    %         edges = [uniqueVals(:).' - eps; uniqueVals(:).' + eps]; % tiny bins around unique values
    %         edges = sort([uniqueVals(:).' - 1e-6, uniqueVals(:).' + 1e-6]); % create paired edges
    %         % Build edges properly: halfway between consecutive uniques
    %         if numel(uniqueVals) > 1
    %             mid = (uniqueVals(1:end-1) + uniqueVals(2:end))/2;
    %             edges = [uniqueVals(1)- (mid(1)-uniqueVals(1)), mid, uniqueVals(end)+(uniqueVals(end)-mid(end))];
    %         else
    %             edges = [uniqueVals-1e-6, uniqueVals+1e-6];
    %         end
    %     else
    %         % For many distinct values, bin into 20 bins spanning [0, max(V0)]
    %         edges = linspace(min(V0), max(V0), 21);
    %     end
    %     % Histogram counts per bin
    %     [counts, ~, binIdx] = histcounts(V0, edges);
    %     % Probability for each sample equals count(bin)/total samples
    %     % Build sample probabilities avoiding NaNs from binIdx==0
    %     valid = binIdx > 0;
    %     P0 = zeros(1, n0);
    %     if any(valid)
    %         % counts(binIdx(valid)) gives counts per sample; divide by total samples
    %         P0(valid) = counts(binIdx(valid)) ./ numel(V0);
    %     end
    %     % For plotting we want one radial bar per sample direction (same length for samples in same bin)
    %     % Create discrete colormap corresponding to bins
    %     nBins = numel(counts);
    %     cmap0 = jet(nBins);
    %     % Plot each sample as a radial line with color mapped to its magnitude bin
    %     for i = 1:n0
    %         b = binIdx(i);
    %         if b == 0, continue; end
    %         polarplot(ax1, [D0(i), D0(i)], [0, P0(i)], 'Color', cmap0(b,:), 'LineWidth', 2);
    %     end
    %     % Set color limits and discrete colorbar ticks at bin centers with labels showing bin ranges
    %     ax1.CLim = [1, nBins];
    %     colormap(ax1, cmap0);
    %     cb1 = colorbar(ax1, 'Ticks', linspace(1, nBins, min(nBins,10)));
    %     % Prepare tick labels for the colorbar (show representative magnitude for each bin)
    %     % Use bin centers
    %     if nBins > 0
    %         edgesFull = edges;
    %         binCenters = (edgesFull(1:end-1) + edgesFull(2:end))/2;
    %         % Limit number of tick labels to avoid overcrowding
    %         tickIdx = round(linspace(1, nBins, min(nBins,10)));
    %         tickLabels = arrayfun(@(v) sprintf('%.2f', v), binCenters(tickIdx), 'UniformOutput', false);
    %         set(cb1, 'Ticks', tickIdx, 'TickLabels', tickLabels);
    %     end
    %     if exist('startTime0','var') && exist('endTime0','var')
    %         % Also show overall time span in title of colorbar (optional)
    %         % Append as label below colorbar
    %         cb1.Label.String = sprintf('Magnitude bins\n%s - %s', startTime0, endTime0);
    %     end
    % end
    % title(ax1, 'T0');
    % ax1.ThetaDir = 'clockwise';
    % ax1.ThetaZeroLocation = 'top';
    % ax1.RAxis.Label.String = 'Probability';
    % 
    % % ----RIGHT: T1----
    % ax2 = subplot(1,2,2, polaraxes); hold(ax2,'on');
    % if exist('n1','var') && n1 > 0
    %     % Compute probability of each magnitude value in V1 (fraction of occurrences)
    %     uniqueVals = unique(V1);
    %     if numel(uniqueVals) <= 20
    %         % Build small bins around unique values, or midpoints between uniques
    %         if numel(uniqueVals) > 1
    %             mid = (uniqueVals(1:end-1) + uniqueVals(2:end))/2;
    %             edges = [uniqueVals(1) - (mid(1)-uniqueVals(1)), mid, uniqueVals(end) + (uniqueVals(end)-mid(end))];
    %         else
    %             edges = [uniqueVals-1e-6, uniqueVals+1e-6];
    %         end
    %     else
    %         edges = linspace(min(V1), max(V1), 21);
    %     end
    %     [counts1, ~, binIdx1] = histcounts(V1, edges);
    %     valid1 = binIdx1 > 0;
    %     P1 = zeros(1, n1);
    %     if any(valid1)
    %         P1(valid1) = counts1(binIdx1(valid1)) ./ numel(V1);
    %     end
    %     nBins1 = numel(counts1);
    %     cmap1 = jet(nBins1);
    %     for i = 1:n1
    %         b = binIdx1(i);
    %         if b == 0, continue; end
    %         polarplot(ax2, [D1(i), D1(i)], [0, P1(i)], 'Color', cmap1(b,:), 'LineWidth', 2);
    %     end
    %     ax2.CLim = [1, nBins1];
    %     colormap(ax2, cmap1);
    %     cb2 = colorbar(ax2, 'Ticks', linspace(1, nBins1, min(nBins1,10)));
    %     if nBins1 > 0
    %         binCenters1 = (edges(1:end-1) + edges(2:end))/2;
    %         tickIdx1 = round(linspace(1, nBins1, min(nBins1,10)));
    %         tickLabels1 = arrayfun(@(v) sprintf('%.2f', v), binCenters1(tickIdx1), 'UniformOutput', false);
    %         set(cb2, 'Ticks', tickIdx1, 'TickLabels', tickLabels1);
    %     end
    %     if exist('startTime1','var') && exist('endTime1','var')
    %         cb2.Label.String = sprintf('Magnitude bins\n%s - %s', startTime1, endTime1);
    %     end
    % end

%% clean verion
% Plot dir0_da spatial map with 1st and 2nd highest (declustered) probability
% 1. Initialize Spatial Arrays for all nStations (based on dir1_da)
nStations = numel(dir1_da);
plot_X = nan(nStations, 1);
plot_Y = nan(nStations, 1);
plot_ZBED = nan(nStations, 1);

% Primary Peak Vectors (T1 direction, scaled by Max T1 prob)
plot_U1 = zeros(nStations, 1);
plot_V1 = zeros(nStations, 1);
arrow_length1 = zeros(nStations, 1);

% Secondary Peak Vectors (Declustered T1 direction, scaled by 2nd Max T1 prob)
plot_U2 = zeros(nStations, 1);
plot_V2 = zeros(nStations, 1);
arrow_length2 = zeros(nStations, 1);

% Define the bins (36 bins between 0 and 2*pi, each bin is 10 degrees)
num_bins = 36;
bin_edges = linspace(0, 2*pi, num_bins + 1);
bin_centers = movmean(bin_edges, 2, 'Endpoints', 'discard');

% Pre-allocate probability tracking matrices for T1
probs1 = nan(nStations, num_bins);

for k = 1:nStations
    if ismember(k, [11, 12, 13])
        % skip these stations entirely
        plot_X(k) = NaN; plot_Y(k) = NaN; plot_ZBED(k) = NaN;
        plot_U1(k) = 0; plot_V1(k) = 0; arrow_length1(k) = 0;
        plot_U2(k) = 0; plot_V2(k) = 0; arrow_length2(k) = 0;
        probs1(k, :) = NaN;
        continue;
    end
    
    % Safe Coordinate Fetch from RDx1/RDy1 to prevent array bound errors
    if exist('RDx1','var') && exist('RDy1','var') && ...
       (~isempty(RDx1) && ~isempty(RDy1)) && ...
       (iscell(RDx1) && k <= numel(RDx1) || ~iscell(RDx1) && k <= size(RDx1, 2))
       
        if iscell(RDx1), xk = RDx1{k}; else xk = RDx1(:,k); end
        if iscell(RDy1), yk = RDy1{k}; else yk = RDy1(:,k); end
        
        if isscalar(xk), plot_X(k) = xk; else plot_X(k) = xk(1); end
        if isscalar(yk), plot_Y(k) = yk; else plot_Y(k) = yk(1); end
    else
        plot_X(k) = NaN; plot_Y(k) = NaN;
    end
    
    if isempty(dir1_da{k}) || isnan(plot_X(k))
        continue;
    end
    
    % --- PROCESS T1 DIRECTIONS & PROBABILITIES (only T1 used) ---
    D1k = dir1_da{k}(:);
    if any(abs(D1k) > 2*pi), D1k = deg2rad(D1k); end
    D1k = mod(D1k, 2*pi);
    
    counts1 = histcounts(D1k, bin_edges);
    if sum(counts1) > 0
        probs1(k, :) = counts1 / sum(counts1);
    else
        continue;
    end
    
    % =====================================================================
    % --- DECLUSTERING LOGIC FOR TWO HIGHEST PROBABILITIES (T1 only) ---
    % =====================================================================
    probs1_temp = probs1(k, :);
    if ~all(isnan(probs1_temp)) && sum(probs1_temp) > 0
        % --- 1st Peak (Highest Probability) ---
        [max_prob1, max_idx1] = max(probs1_temp);
        best_dir1 = bin_centers(max_idx1);
        plot_U1(k) = sin(best_dir1);
        plot_V1(k) = cos(best_dir1);
        
        % --- Apply Declustering Mask (Clear everything within 90 degrees) ---
        ang_dist = abs(bin_centers - best_dir1);
        ang_dist = min(ang_dist, 2*pi - ang_dist); 
        decluster_mask = ang_dist < (pi / 2);
        probs1_temp(decluster_mask) = 0; 
        
        % --- 2nd Peak (Highest remaining after declustering) ---
        if sum(probs1_temp) > 0
            [max_prob2, max_idx2] = max(probs1_temp);
            best_dir2 = bin_centers(max_idx2);
            plot_U2(k) = sin(best_dir2);
            plot_V2(k) = cos(best_dir2);
        else
            max_idx2 = NaN;
            max_prob2 = NaN;
        end
        
        % --- DEFINE ARROW LENGTHS BASED ON probs1 BIN MATCHES ---
        arrow_length1(k) = max_prob1;
        if ~isnan(max_idx2)
            arrow_length2(k) = max_prob2;
        else
            arrow_length2(k) = 0;
        end
    else
        arrow_length1(k) = 0;
        arrow_length2(k) = 0;
    end
end
% =====================================================================
% 2. ESTABLISH NATIVE RD NEW GRAPHICS CANVAS & IMAGERY BACKDROP
% =====================================================================
figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 1300, 850]);
ax = axes('NextPlot', 'add');

% Set your explicit target boundary dimensions in RD New meters
xlims = [64450 67800];
ylims = [378700 381000];
y_shift = -100; 
ylims_shifted = ylims + y_shift;

% Set 1:1 isometric aspect ratio so flow vectors remain geometrically true
axis(ax, [xlims ylims_shifted], 'equal');

% --- WMS STATIC TEXTURE MAP FETCH ---
% We construct a direct query bound to your exact RD coordinate limits (EPSG:28992)
img_w = 1400; img_h = 900;
static_url = sprintf(...
    'https://service.pdok.nl/hwh/luchtfotorgb/wms/v1_0?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=Actueel_ortho25&STYLES=&CRS=EPSG:28992&BBOX=%d,%d,%d,%d&WIDTH=%d&HEIGHT=%d&FORMAT=image/jpeg', ...
    xlims(1), ylims_shifted(1), xlims(2), ylims_shifted(2), img_w, img_h);

try
    % Read the high-resolution aerial layout from the server pipeline
    aerial_img = webread(static_url);
    
    % Display image flat beneath vectors, stretching it to coordinates
    h_bg = imagesc(ax, xlims, ylims_shifted, flipud(aerial_img));
    
    % Push the image background below the grid layer
    uistack(h_bg, 'bottom');
catch ME
    warning('PDOK backdrop pipeline unavailable (%s). Using neutral workspace.', ME.message);
    set(ax, 'Color', [0.93 0.93 0.93]); 
end

probScaleValue = 0.25;
% =====================================================================
% 3. PLOT STATIONS & PREMIUM NATIVE QUIVER ARROWS
% =====================================================================
% Align stations relative to the shifted coordinate transformation matrix
station_X = plot_X;
station_Y = plot_Y + y_shift;

% Cleanly drop missing coordinates
valid = ~isnan(station_X) & ~isnan(station_Y);

% Plot station node targets (White border helps black dots pop over dark imagery)
plot(ax, station_X(valid), station_Y(valid), 'o', ...
     'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', ...
     'MarkerSize', 7, 'LineWidth', 1.2, 'DisplayName', 'ADCP Stations');

% --- CALCULATE METRIC VELOCITY VECTOR FIELDS ---
% Convert the probabilities into real linear grid extensions (Max length = 350 meters)
spatial_scale_factor = 650; 

scaled_U1 = plot_U1 .* arrow_length1 * spatial_scale_factor;
scaled_V1 = plot_V1 .* arrow_length1 * spatial_scale_factor;
scaled_U2 = plot_U2 .* arrow_length2 * spatial_scale_factor;
scaled_V2 = plot_V2 .* arrow_length2 * spatial_scale_factor;

% --- PLOT FLOW ARROWS USING CORE NATIVE QUIVER ---
% Core quiver handles rotation and clean, professional arrowhead shapes natively
q1 = quiver(ax, station_X(valid), station_Y(valid), scaled_U1(valid), scaled_V1(valid), 0, ...
            'LineWidth', 2.8, 'Color', 'b', 'Autoscale', 'off', 'DisplayName', 'Ebb');

q2 = quiver(ax, station_X(valid), station_Y(valid), scaled_U2(valid), scaled_V2(valid), 0, ...
            'LineWidth', 2.0, 'Color', 'r', 'LineStyle', '-', 'Autoscale', 'off', 'DisplayName', 'Flood');

% =====================================================================
% 4. PREMIUM CARTOGRAPHIC KILOMETER SCALE FORMATTING
% =====================================================================
% Set distinct tick windows across your specific boundaries
ax.XTick = 65000:1000:67000;
ax.YTick = 379000:1000:381000;

% Effortlessly rewrite the tick metrics to represent clean Kilometer units (font size 20)
ax.XTickLabel = arrayfun(@(v) sprintf('%.0f', v/1000), ax.XTick, 'UniformOutput', false);
ax.YTickLabel = arrayfun(@(v) sprintf('%.0f', v/1000), ax.YTick, 'UniformOutput', false);

% --- ADD PROBABILITY SCALE REFERENCE TO LEGEND ---
hProb = line(nan, nan, 'LineWidth', 2.5, 'Color', [0.3 0.3 0.3], 'Marker', '>', ...
             'MarkerSize', 7, 'MarkerFaceColor', [0.3 0.3 0.3], ...
             'DisplayName', sprintf('Probability Ref Vector (%.0f%%)', probScaleValue*100));

% High-contrast layout properties
ax.FontSize = 20;
grid(ax, 'off');
ax.GridColor = [1 1 1]; 
ax.GridAlpha = 0.35;

% Text elements
title(ax, 'Flow Directions: Zimmerman T_1', 'FontWeight', 'bold', 'FontSize', 30, 'Color', [0.1 0.1 0.1]);
xlabel(ax, 'RDx [km]', 'FontWeight', 'bold', 'FontSize', 22);
ylabel(ax, 'RDy [km]', 'FontWeight', 'bold', 'FontSize', 22);

% Semitransparent polished legend box
lgd = legend(ax, 'Location', 'southeast', 'FontSize', 16);
set(lgd, 'Color', [1 1 1 0.85], 'EdgeColor', [0.85 0.85 0.85]);

% =====================================================================
% 5. ADD NORTH ARROW (UNICODE METHOD)
% =====================================================================
% Calculate position coordinates (Top Right with a 3% inset margin)
x_north = xlims(2) - (xlims(2) - xlims(1)) * 0.05;
y_north = ylims_shifted(2) - (ylims_shifted(2) - ylims_shifted(1)) * 0.08;

% Plot a high-visibility text-based north arrow
text(ax, x_north, y_north, sprintf('▲\nN'), ...
    'FontSize', 30, ...
    'FontWeight', 'bold', ...
    'Color', 'w', ...            % White text to pop over dark aerial image
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'BackgroundColor', [0 0 0 0.0], ... % Semi-transparent dark background pod
    'Margin', 6);
hold(ax, 'off');


% export
PNG_dir = 'P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\Flow_directions_map';
if ~exist(PNG_dir, 'dir')
    mkdir(PNG_dir);
end
file_name_PNG = fullfile(PNG_dir, 'ZimmT1_ebb-flood_dir.png');

% Ensure the current figure handle is available
fig_handle = gcf;
% Set renderer for consistent output
set(fig_handle, 'Renderer', 'painters');

% Export at 300 DPI
print(fig_handle, file_name_PNG, '-dpng', '-r300');