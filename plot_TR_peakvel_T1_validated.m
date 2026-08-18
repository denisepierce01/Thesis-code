clear all
close all
clc

%% Compare velocities for different runs

% Load measurement data
load('p:\11207654-bathosszimm\04_Data\ADCP\Structures\ADCP.mat')
load('p:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat')

% Load DFMs
load('P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\DFM.mat')  
ModelData(1).DFM = DFM;


% Create a folders cell array matching ModelData entries for plotting/legend use
folders = { 'T1'};

% % Location to save the .png
png_dir = 'P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\PNGs\'; % Location of png's
% png_dir = [png_dir png_name filesep 'TR_peakVel' filesep]; if ~exist(png_dir,'dir'); mkdir (png_dir); end

% Names of measurement stations
idx_load = find(~strcmp({S(:).name}, 'Boat') & strcmp({S(:).t}, 'T1'));  %CHANGE T0/T1
stations_vel = cell(size(idx_load));

% % Remove stations with indices 39:60 from idx_load
% remove_idx = 61:71; % THIS IS THE OSSENISSE STATIONS T1
% keep_mask = true(size(idx_load));
% for k = remove_idx
%     pos = find(idx_load==k,1);
%     if ~isempty(pos)
%         keep_mask(pos) = false;
%     end
% end
% idx_load = idx_load(keep_mask);
% stations_vel = cell(size(idx_load));
for ii = 1:length(idx_load)
    stations_vel{ii} = [S(idx_load(ii)).area '_' S(idx_load(ii)).t '_' S(idx_load(ii)).name];
end
for ii = 1:length(idx_load)
    stations_title{ii} = [S(idx_load(ii)).area(1:min(4,end)) ' ' S(idx_load(ii)).t ' ' S(idx_load(ii)).name];
end
for ii = 1:length(idx_load)
    stations_title{ii} = [S(idx_load(ii)).name];
end

for ii = 1:length(idx_load)
    % Extract only numeric characters from the station name
    numChars = regexp(S(idx_load(ii)).name, '\d', 'match');
    if isempty(numChars)
        stations_title_number{ii} = '';
    else
        stations_title_number{ii} = strjoin(numChars, '');
    end
end

% Sigma layer definition
sigma_layers = [2 3 5 8 10 12 15 15 15 15];


%% Plot peak velocity vs TR (individually)
cmap = interp1(linspace(0,1,size(jet,1)), jet(), linspace(0,1,max(1,length(folders))));
baseOrange = [0.8500 0.3250 0.0980];

nRuns = length(folders);
nStations = length(stations_vel);
rmse_matrix = NaN(nRuns, nStations);

% Analyse model data
for ss = 1:length(stations_vel)
    figure()
    % plot model data
    for ii = 1:length(folders)
        idx_model = strcmp({ModelData(ii).DFM.vel(:).station_name}, stations_vel{ss});
        disp(['Comparing measurement station: ' stations_vel{ss} ' with model station: ' ModelData(ii).DFM.vel(idx_model).station_name])
        splitName = split(stations_vel{ss}, '_');

        dtSeries = ModelData(ii).DFM.vel(idx_model).time;
        if contains(ModelData(ii).DFM.vel(idx_model).station_name, 'BATH')
            idx_wl = 15; % Bath;
        elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'ZIMMERMAN')
            idx_wl = 12; % Walsoorden
        elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'OSSENISSE')
            idx_wl = 11; % Hansweert
        end
        disp(['Using water levels from: ' ModelData(ii).DFM.wl(idx_wl).station_longname])
        wlSeries = ModelData(ii).DFM.wl(idx_wl).val;
        uvSeries = squeeze(ModelData(ii).DFM.vel(idx_model).vel_mag)*sigma_layers.'./100; % Make depth average by multiplying layer thickness and deviding by 100 [%]

        [Model.TR, Model.peakVel, Model.peakTime] = determine_TR_12hrpeakVel_time(dtSeries, wlSeries, uvSeries);

        % creating trendlines for model and save p_model for later RMSE comparison
        x_model = [];
        y_model = [];
        p_model = [];
        if ~isempty(Model.TR) && ~all(isnan(Model.TR)) && ~all(isnan(Model.peakVel))
            valid = ~isnan(Model.TR) & ~isnan(Model.peakVel);
            if sum(valid) >= 2
                p_model = polyfit(Model.TR(valid), Model.peakVel(valid), 1);
                x_model = linspace(min(Model.TR(valid)), max(Model.TR(valid)), 100);
                y_model = polyval(p_model, x_model);
            end
        end 

        % Ensure ModelSlopes is initialized as a cell array with one cell per model
        if ~exist('ModelSlopes', 'var') || ~iscell(ModelSlopes)
            ModelSlopes = cell(1, length(folders));
        end
        % Ensure inner cell exists for this model
        if isempty(ModelSlopes{ii})
            ModelSlopes{ii} = cell(1, length(stations_vel));
        elseif length(ModelSlopes{ii}) < length(stations_vel)
            ModelSlopes{ii}(length(ModelSlopes{ii})+1:length(stations_vel)) = {[]};
        end

        % Store p_model (including empty) for this model ii and station ss
        ModelSlopes{ii}{ss} = p_model;

        % -- Analyse measurement data  %TURN ON FOR T0
        if strcmp(splitName{1}, 'OSSENISSE') & strcmp(splitName{2}, 'T0')
            splitName{2} = 'T0a';
        end

        % Er moet data aanwezig zijn
        wlSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
        dtSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
        uvSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;

        % Sometimes wl is partly missing --> determine_TR_peakVel does not work
        % then. Fill values using astronomical tide
        if sum(isnan(wlSeries)) > 0
            [~, wl_astro] = t_tide(wlSeries, 'interval', 10/60, 'start time', datenum(dtSeries(1)), 'latitude', 52, 'error', 'wboot');
            wlSeries(isnan(wlSeries)) = wl_astro(isnan(wlSeries));
        end

        [Meas.TR, Meas.peakVel, Meas.peakTime] = determine_TR_12hrpeakVel_time(dtSeries, wlSeries, uvSeries);

         % Plot model points
        hold on;
        % scatter(Model.TR, Model.peakVel, 80, cmap(ii,:), 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', folders{ii});     
        scatter(Model.TR, Model.peakVel, 80, baseOrange, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', folders{ii});     
        % plot(x_model, y_model, 'Color', cmap(ii,:), 'LineWidth', 1, ...
        %          'DisplayName', sprintf('%s model trend (slope=%.3f)', folders{ii}, p_model(1)));
    end
   % -- Analyse measurement data  %TURN ON FOR T0
    if strcmp(splitName{1}, 'OSSENISSE') & strcmp(splitName{2}, 'T0')
        splitName{2} = 'T0a';
    end

    % Er moet data aanwezig zijn
    wlSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
    dtSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
    uvSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;

    % Sometimes wl is partly missing --> determine_TR_peakVel does not work
    % then. Fill values using astronomical tide
    if sum(isnan(wlSeries)) > 0
        [~, wl_astro] = t_tide(wlSeries, 'interval', 10/60, 'start time', datenum(dtSeries(1)), 'latitude', 52, 'error', 'wboot');
        wlSeries(isnan(wlSeries)) = wl_astro(isnan(wlSeries));
    end

    % creating trendlines for observations and store p_obs for this station
    x_obs = [];
    y_obs = [];
    p_obs = [];
    if ~isempty(Meas.TR) && ~all(isnan(Meas.TR)) && ~all(isnan(Meas.peakVel))
        valid = ~isnan(Meas.TR) & ~isnan(Meas.peakVel);
        if sum(valid) >= 2
            p_obs = polyfit(Meas.TR(valid), Meas.peakVel(valid), 1);
            x_obs = linspace(min(Meas.TR(valid)), max(Meas.TR(valid)), 100);
            y_obs = polyval(p_obs, x_obs);
        end
    end

    % Store observation trend coefficients per station for later RMSE comparison
    if ~exist('ObsSlopes', 'var') || ~iscell(ObsSlopes)
        ObsSlopes = cell(1, length(stations_vel));
    end
    if length(ObsSlopes) < length(stations_vel)
        ObsSlopes{length(stations_vel)} = []; % expand if needed
    end
    ObsSlopes{ss} = p_obs;

    % Plot measurements
    scatter(Meas.TR, Meas.peakVel, 200, 'k', 'x', 'LineWidth', 2.5, 'DisplayName','Observations')
    % % Plot observation trendline if available
    % plot(x_obs, y_obs, 'k-', 'LineWidth', 2, 'DisplayName','Observations trend line')

    ylabel('\bf{\it{Peak velocity [m/s]}}', 'FontSize', 30)
    set(gca, 'FontSize', 18)
    xlabel('\bf{\it{Tidal wave [m]}}', 'FontSize', 30)
    set(gca, 'FontSize', 24);
    hold off;
    % title('Ebb','FontSize',20)

    % set(gca, 'FontSize', 12)
    sgtitle(['\bf Peak Velocity versus Tidal Wave: ' stations_title{ss}], 'Interpreter', 'tex', 'FontSize', 40);
    % Add a small space below the suptitle so it doesn't overlap the subplots
    t = get(gcf, 'Children');
    if ~isempty(t)
        % Increase top margin slightly by adjusting 'OuterPosition' of the top axes
        outer = get(gca, 'OuterPosition');
        outer(2) = outer(2) - 0.01;       % move down by 0.02
        outer(4) = outer(4) - 0.01;       % reduce height to keep layout consistent
        set(gca, 'OuterPosition', outer);
    end
    % Legend with two columns
    [lg, icons] = legend('FontSize', 24, 'Location', 'best');

    % 3. Find the 'x' marker in the legend icons
    p = findobj(icons, 'Type', 'Scatter', '-or', 'Type', 'Patch');

    % 4. Set the new marker size
    set(p,'LineWidth', 2, 'MarkerSize', 10); % Try this first
% 
%     % % Export figure
%     % exportgraphics(gcf, [png_dir stations_vel{ss} '.png'])
% 
      %---R^2---Compute for observation trendlines and store per station
        R2_obs = NaN;
        if exist('p_obs','var') && ~isempty(p_obs) && ~all(isnan(Meas.TR)) && ~all(isnan(Meas.peakVel))
            validE = ~isnan(Meas.TR) & ~isnan(Meas.peakVel);
            if sum(validE) >= 2
                y_obs = Meas.peakVel(validE);
                y_fit = polyval(p_obs, Meas.TR(validE));
                ss_res = sum((y_obs - y_fit).^2);
                ss_tot = sum((y_obs - mean(y_obs)).^2);
                if ss_tot > 0
                    R2_obs = 1 - ss_res/ss_tot;
                else
                    R2_obs = NaN;
                end
            end
        end

        % Initialize container for R2 per station if not existing
        if ~exist('R2_per_station', 'var') || ~isnumeric(R2_per_station)
            R2_per_station = NaN(1, length(stations_vel));
        elseif numel(R2_per_station) < length(stations_vel)
            R2_per_station(length(stations_vel)) = NaN; % expand if needed
        end
        R2_per_station(ss) = R2_obs;

        % After loop over stations (when ss is last), compute average R2 excluding NaNs
        if ss == length(stations_vel)
            validR2 = ~isnan(R2_per_station);
            if any(validR2)
                avg_R2_all_stations = mean(R2_per_station(validR2));
            else
                avg_R2_all_stations = NaN;
            end
            % store in workspace variable rmse_matrix or separate summary variable
            % (choose to create/append to a summary struct)
            summaryMetrics.avg_R2_all_stations = avg_R2_all_stations;
        end

      %---RMSE, bias, and uRMSE---between p_model and p_obs trendlines
        p_obs = ObsSlopes{ss}; % [slope, intercept] for observations

        % Only proceed if observations have a valid trendline
        if ~isempty(p_obs)
            for ii = 1:nRuns
                p_model = ModelSlopes{ii}{ss}; % [slope, intercept] for model ii

                if ~isempty(p_model)
                    % 1. Define a common TR range to evaluate the fit (use observation range if available)
                    tr_min = 2; tr_max = 5.5;
                    tr_eval = linspace(tr_min, tr_max, 100);

                    % 2. Calculate predicted velocities from both trendlines
                    vel_fit_obs = polyval(p_obs, tr_eval);
                    vel_fit_model = polyval(p_model, tr_eval);

                    % 3. Calculate error metrics between the two lines and store in matrices
                    diff = vel_fit_model - vel_fit_obs;
                    rmse_matrix(ii, ss) = sqrt(mean(diff.^2));                 % RMSE
                    bias_matrix(ii, ss) = mean(diff);                          % Bias (model - obs)
                    % unbiased RMSE (uRMSE): remove mean bias first
                    uRMSE_matrix(ii, ss) = sqrt(mean((diff - mean(diff)).^2)); % uRMSE
                else
                    % initialize matrices if they don't exist
                    if ~exist('rmse_matrix','var')
                        rmse_matrix = NaN(nRuns, nStations);
                    end
                    if ~exist('bias_matrix','var')
                        bias_matrix = NaN(nRuns, nStations);
                    end
                    if ~exist('uRMSE_matrix','var')
                        uRMSE_matrix = NaN(nRuns, nStations);
                    end
                    % leave entries as NaN (or previous values) when p_model empty
                end
            end
        else
            % Ensure matrices exist even if p_obs empty so downstream code doesn't error
            if ~exist('rmse_matrix','var')
                rmse_matrix = NaN(nRuns, nStations);
            end
            if ~exist('bias_matrix','var')
                bias_matrix = NaN(nRuns, nStations);
            end
            if ~exist('uRMSE_matrix','var')
                uRMSE_matrix = NaN(nRuns, nStations);
            end
        end
end
% %% best rmse, bias, and uRMSE runs
% Ensure matrices exist
if ~exist('rmse_matrix','var') || ~exist('bias_matrix','var') || ~exist('uRMSE_matrix','var')
    error('Error: rmse_matrix, bias_matrix, and uRMSE_matrix must exist before computing best runs.');
end

% Compute mean metrics per run (ignore NaNs)
mean_rmse_per_run = mean(rmse_matrix, 2, 'omitnan');
mean_bias_per_run = mean(bias_matrix, 2, 'omitnan');
mean_uRMSE_per_run = mean(uRMSE_matrix, 2, 'omitnan');

% Find minima (for bias, choose smallest absolute mean bias)
[min_rmse_val, best_rmse_idx] = min(mean_rmse_per_run);
[min_uRMSE_val, best_uRMSE_idx] = min(mean_uRMSE_per_run);
[min_absbias_val, best_bias_idx] = min(abs(mean_bias_per_run));

% Helper to get run name or index
getName = @(idx) (idx <= numel(folders) && ~isempty(folders{idx})).*1;
% Print best RMSE runs (handle ties)
best_rmse_runs = find(abs(mean_rmse_per_run - min_rmse_val) <= eps(max(1,abs(min_rmse_val))));
if numel(best_rmse_runs) > 1
    fprintf('Best simulations by RMSE (tie) with average RMSE = %.4f:\n', min_rmse_val);
    for k = 1:numel(best_rmse_runs)
        idx = best_rmse_runs(k);
        if idx <= numel(folders)
            fprintf('  %d: %s\n', idx, folders{idx});
        else
            fprintf('  %d: (run %d)\n', idx, idx);
        end
    end
else
    if best_rmse_idx <= numel(folders)
        fprintf('The best simulation by RMSE is %s with an average RMSE of %.4f\n', folders{best_rmse_idx}, min_rmse_val);
    else
        fprintf('The best simulation by RMSE is run %d with an average RMSE of %.4f\n', best_rmse_idx, min_rmse_val);
    end
end

% Print best uRMSE runs (handle ties)
best_uRMSE_runs = find(abs(mean_uRMSE_per_run - min_uRMSE_val) <= eps(max(1,abs(min_uRMSE_val))));
if numel(best_uRMSE_runs) > 1
    fprintf('Best simulations by uRMSE (tie) with average uRMSE = %.4f:\n', min_uRMSE_val);
    for k = 1:numel(best_uRMSE_runs)
        idx = best_uRMSE_runs(k);
        if idx <= numel(folders)
            fprintf('  %d: %s\n', idx, folders{idx});
        else
            fprintf('  %d: (run %d)\n', idx, idx);
        end
    end
else
    if best_uRMSE_idx <= numel(folders)
        fprintf('The best simulation by uRMSE is %s with an average uRMSE of %.4f\n', folders{best_uRMSE_idx}, min_uRMSE_val);
    else
        fprintf('The best simulation by uRMSE is run %d with an average uRMSE of %.4f\n', best_uRMSE_idx, min_uRMSE_val);
    end
end

% Print best (absolute) bias runs (handle ties)
best_bias_runs = find(abs(abs(mean_bias_per_run) - abs(min_absbias_val)) <= eps(max(1,abs(min_absbias_val))));
if numel(best_bias_runs) > 1
    fprintf('Best simulations by absolute mean bias (tie) with |bias| = %.4f:\n', abs(min_absbias_val));
    for k = 1:numel(best_bias_runs)
        idx = best_bias_runs(k);
        if idx <= numel(folders)
            fprintf('  %d: %s (mean bias = %.4f)\n', idx, folders{idx}, mean_bias_per_run(idx));
        else
            fprintf('  %d: (run %d) (mean bias = %.4f)\n', idx, idx, mean_bias_per_run(idx));
        end
    end
else
    if best_bias_idx <= numel(folders)
        fprintf('The best simulation by absolute mean bias is %s with mean bias = %.4f\n', folders{best_bias_idx}, mean_bias_per_run(best_bias_idx));
    else
        fprintf('The best simulation by absolute mean bias is run %d with mean bias = %.4f\n', best_bias_idx, mean_bias_per_run(best_bias_idx));
    end
end

% Store summary metrics
summaryMetrics.mean_rmse_per_run = mean_rmse_per_run;
summaryMetrics.mean_bias_per_run = mean_bias_per_run;
summaryMetrics.mean_uRMSE_per_run = mean_uRMSE_per_run;
summaryMetrics.best_rmse_runs = best_rmse_runs;
summaryMetrics.best_uRMSE_runs = best_uRMSE_runs;
summaryMetrics.best_bias_runs = best_bias_runs;

%% Plot tiled format
 baseOrange = [0.8500 0.3250 0.0980];
fig = figure();
% fig.Position = [100, 100, 1200, 900]; 

% 2. Create the layout and assign it to a variable 'tl'
tl = tiledlayout(4, 4, 'TileSpacing', 'loose', 'Padding', 'compact');
fig.Units = 'centimeters';
fig.Position(3:4) = [18 22]; % width x height in cm

% 3. Apply labels directly to your layout variable 'tl'
title(tl, 'Bath T1 Validation', 'FontSize', 24, 'FontWeight', 'bold');
xlabel(tl, 'Tidal Range [m]', 'FontSize', 18, 'FontWeight', 'bold');
ylabel(tl, 'Peak Velocity (Depth-Averaged) [m/s]', 'FontSize', 18, 'FontWeight', 'bold');

% tiled group: Bath
for ss = 1:18
    if any(ss == [8, 12, 13])
        continue; % do not plot
    end
    nexttile;
    hold on;
    % plot model data
    for ii = 1:length(folders)
        idx_model = strcmp({ModelData(ii).DFM.vel(:).station_name}, stations_vel{ss});
        disp(['Comparing measurement station: ' stations_vel{ss} ' with model station: ' ModelData(ii).DFM.vel(idx_model).station_name])
        splitName = split(stations_vel{ss}, '_');

        dtSeries = ModelData(ii).DFM.vel(idx_model).time;
        if contains(ModelData(ii).DFM.vel(idx_model).station_name, 'BATH')
            idx_wl = 15; % Bath;
        elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'ZIMMERMAN')
            idx_wl = 12; % Walsoorden
        elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'OSSENISSE')
            idx_wl = 11; % Hansweert
        end
        disp(['Using water levels from: ' ModelData(ii).DFM.wl(idx_wl).station_longname])
        wlSeries = ModelData(ii).DFM.wl(idx_wl).val;
        uvSeries = squeeze(ModelData(ii).DFM.vel(idx_model).vel_mag)*sigma_layers.'./100; % Make depth average by multiplying layer thickness and deviding by 100 [%]

        [Model.TR, Model.peakVel, Model.peakTime] = determine_TR_12hrpeakVel_time(dtSeries, wlSeries, uvSeries);

        % -- Analyse measurement data  %TURN ON FOR T0
        if strcmp(splitName{1}, 'OSSENISSE') & strcmp(splitName{2}, 'T0')
            splitName{2} = 'T0a';
        end

        % Er moet data aanwezig zijn
        wlSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
        dtSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
        uvSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;

        % Sometimes wl is partly missing --> determine_TR_peakVel does not work
        % then. Fill values using astronomical tide
        if sum(isnan(wlSeries)) > 0
            [~, wl_astro] = t_tide(wlSeries, 'interval', 10/60, 'start time', datenum(dtSeries(1)), 'latitude', 52, 'error', 'wboot');
            wlSeries(isnan(wlSeries)) = wl_astro(isnan(wlSeries));
        end

        [Meas.TR, Meas.peakVel, Meas.peakTime] = determine_TR_12hrpeakVel_time(dtSeries, wlSeries, uvSeries);

        % Plot model points
        hold on;
        scatter(Model.TR, Model.peakVel, 20, baseOrange, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', folders{ii});
    end

    % -- Analyse measurement data  %TURN ON FOR T0
    if strcmp(splitName{1}, 'OSSENISSE') & strcmp(splitName{2}, 'T0')
        splitName{2} = 'T0a';
    end

    % Er moet data aanwezig zijn
    wlSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
    dtSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
    uvSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;

    % Sometimes wl is partly missing --> determine_TR_peakVel does not work
    % then. Fill values using astronomical tide
    if sum(isnan(wlSeries)) > 0
        [~, wl_astro] = t_tide(wlSeries, 'interval', 10/60, 'start time', datenum(dtSeries(1)), 'latitude', 52, 'error', 'wboot');
        wlSeries(isnan(wlSeries)) = wl_astro(isnan(wlSeries));
    end

    % Plot measurements
    scatter(Meas.TR, Meas.peakVel, 50, 'k', 'x', 'LineWidth', 1, 'DisplayName','Observations');
    yticks([0.3 0.6 0.9 1.2]);
    yticklabels({'0.3','0.6','0.9','1.2'});
    xlim([3.25 6.25]);
    ylim([0 1.35]);
    title(stations_title_number{ss}, 'Interpreter', 'tex', 'FontSize', 14, 'FontWeight','bold');
    hold off;

end 

% LEGEND BLOCK 
axLeg = nexttile(tl, 16);    
axis(axLeg, 'off');       
hold(axLeg, 'on');

% Create dummy plot points on the invisible axes 
obs = scatter(axLeg, NaN, NaN, 100, 'k', 'x', 'LineWidth', 1.25, 'DisplayName', 'Observations');
model = scatter(axLeg, NaN, NaN, 50, baseOrange, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', 'Model');

% Call the legend explicitly targeting the hidden axes
lgd = legend(axLeg, [obs, model], 'Location', 'east', 'FontSize', 14);
set(lgd, 'Box', 'off');


%================================================
% figure for Zimmerman 
%================================================
fig = figure();
% create tiled layout and set figure size to 18x18 cm
tl = tiledlayout(3, 4, 'TileSpacing', 'loose', 'Padding', 'compact');
fig.Units = 'centimeters';
fig.Position(3:4) = [20 18]; % width x height in cm

% axes & labels
title(tl, 'Zimmerman T1 Validation', 'FontSize', 24, 'FontWeight', 'bold');
xlabel(tl, 'Tidal Range [m]', 'FontSize', 18, 'FontWeight', 'bold');
ylabel(tl, 'Peak Velocity (Depth-Averaged) [m/s]', 'FontSize', 18, 'FontWeight', 'bold');

for ss = 19:28
    nexttile;
    hold on;
    % plot model data
    for ii = 1:length(folders)
        idx_model = strcmp({ModelData(ii).DFM.vel(:).station_name}, stations_vel{ss});
        disp(['Comparing measurement station: ' stations_vel{ss} ' with model station: ' ModelData(ii).DFM.vel(idx_model).station_name])
        splitName = split(stations_vel{ss}, '_');

        dtSeries = ModelData(ii).DFM.vel(idx_model).time;
        if contains(ModelData(ii).DFM.vel(idx_model).station_name, 'BATH')
            idx_wl = 15; % Bath;
        elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'ZIMMERMAN')
            idx_wl = 12; % Walsoorden
        elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'OSSENISSE')
            idx_wl = 11; % Hansweert
        end
        disp(['Using water levels from: ' ModelData(ii).DFM.wl(idx_wl).station_longname])
        wlSeries = ModelData(ii).DFM.wl(idx_wl).val;
        uvSeries = squeeze(ModelData(ii).DFM.vel(idx_model).vel_mag)*sigma_layers.'./100; % Make depth average by multiplying layer thickness and deviding by 100 [%]

        [Model.TR, Model.peakVel, Model.peakTime] = determine_TR_12hrpeakVel_time(dtSeries, wlSeries, uvSeries);

        % -- Analyse measurement data  %TURN ON FOR T0
        if strcmp(splitName{1}, 'OSSENISSE') & strcmp(splitName{2}, 'T0')
            splitName{2} = 'T0a';
        end

        % Er moet data aanwezig zijn
        wlSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
        dtSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
        uvSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;

        % Sometimes wl is partly missing --> determine_TR_peakVel does not work
        % then. Fill values using astronomical tide
        if sum(isnan(wlSeries)) > 0
            [~, wl_astro] = t_tide(wlSeries, 'interval', 10/60, 'start time', datenum(dtSeries(1)), 'latitude', 52, 'error', 'wboot');
            wlSeries(isnan(wlSeries)) = wl_astro(isnan(wlSeries));
        end

        [Meas.TR, Meas.peakVel, Meas.peakTime] = determine_TR_12hrpeakVel_time(dtSeries, wlSeries, uvSeries);

        % Plot model points
        hold on;
        scatter(Model.TR, Model.peakVel, 20, baseOrange, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', folders{ii});
    end

    % -- Analyse measurement data  %TURN ON FOR T0
    if strcmp(splitName{1}, 'OSSENISSE') & strcmp(splitName{2}, 'T0')
        splitName{2} = 'T0a';
    end

    % Er moet data aanwezig zijn
    wlSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
    dtSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
    uvSeries = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;

    % Sometimes wl is partly missing --> determine_TR_peakVel does not work
    % then. Fill values using astronomical tide
    if sum(isnan(wlSeries)) > 0
        [~, wl_astro] = t_tide(wlSeries, 'interval', 10/60, 'start time', datenum(dtSeries(1)), 'latitude', 52, 'error', 'wboot');
        wlSeries(isnan(wlSeries)) = wl_astro(isnan(wlSeries));
    end

    % Plot measurements
    scatter(Meas.TR, Meas.peakVel, 50, 'k', 'x', 'LineWidth', 1, 'DisplayName','Observations');
    yticks([0.3 0.6 0.9 1.2]);
    yticklabels({'0.3','0.6','0.9','1.2'});
    xlim([3 5.5]);
    ylim([0 1.2]);
    title(stations_title_number{ss}, 'Interpreter', 'tex', 'FontSize', 14, 'FontWeight','bold');
    hold off;
end

% LEGEND BLOCK 
axLeg = nexttile(tl, 11);    
axis(axLeg, 'off');       
hold(axLeg, 'on');

% Create dummy plot points on the invisible axes 
obs = scatter(axLeg, NaN, NaN, 100, 'k', 'x', 'LineWidth', 1.25, 'DisplayName', 'Observations');
model = scatter(axLeg, NaN, NaN, 50, baseOrange, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', 'Model');

% Call the legend explicitly targeting the hidden axes
lgd = legend(axLeg, [obs, model], 'Location', 'east', 'FontSize', 14);
set(lgd, 'Box', 'off');

% %% export to PNG
% % export figures to png_dir
% if ~exist('png_dir', 'var') || isempty(png_dir)
%     png_dir = fullfile(pwd, 'figures_png');
% end
% if ~exist(png_dir, 'dir')
%     mkdir(png_dir);
% end
% 
% % find all open figure objects
% figHandles = findall(0, 'Type', 'figure');
% for k = 1:numel(figHandles)
%     fig = figHandles(k);
%     % create a safe filename using figure name or number
%     figName = get(fig, 'Name');
%     if isempty(figName)
%         filename = sprintf('figure_%d.png', fig.Number);
%     else
%         % replace illegal filename chars
%         safeName = regexprep(figName, '[^a-zA-Z0-9_\- ]', '_');
%         safeName = strtrim(safeName);
%         if isempty(safeName)
%             filename = sprintf('figure_%d.png', fig.Number);
%         else
%             filename = sprintf('%s.png', safeName);
%         end
%     end
%     outpath = fullfile(png_dir, filename);
%     % set renderer and export at 300 DPI
%     originalUnits = fig.Units;
%     fig.Units = 'pixels';
%     try
%         exportgraphics(fig, outpath, 'BackgroundColor','white','Resolution',300);
%     catch
%         % fallback to saveas if exportgraphics unavailable
%         saveas(fig, outpath);
%     end
%     fig.Units = originalUnits;
% end