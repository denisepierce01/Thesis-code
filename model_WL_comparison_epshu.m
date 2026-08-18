clear all
close all
clc

% Graph Walsoorden and Bath WL versus model WL. RMSE for each
% D. Pierce

%% Load measurement data
load("P:\11207654-internship-pierce-2026\02_Data\Waterlevels\WL.mat");
% load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
% load('p:\11210344-001-bathosszimm\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat')

%% Load model data
load('P:\11207654-internship-pierce-2026\03_Model\04_bathy_j18_groynes_j18_runperiod_nov18\output\DFM.mat');         % hdry = 0.05m
ModelData(1).DFM = DFM;
load('p:\11207654-internship-pierce-2026\03_Model\002_bathy_j18_groynes_j18_runperiod_nov18_hdry01\output\DFM.mat');  % hdry = 0.01m
ModelData(2).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\5_T0bathy_T0groynes_n021_hdry001\output\DFM.mat');                 % hdry = 0.001m
ModelData(3).DFM = DFM;
load('p:\11207654-internship-pierce-2026\03_Model\001_bathy_j18_groynes_j18_runperiod_nov18_hdry\output\DFM.mat');   % hdry = 0.0001m
ModelData(4).DFM = DFM;

% Create a folders cell array matching ModelData entries for plotting/legend use
folders = { ...
    'h=0.05m', ...
    'h=0.01m', ...
    'h=0.001m', ...
    'h=0.0001m', ...
    };

%% viewing WL stations observed
obs_t_bath_datenum = WL.Time.BATH;
obs_t_wals_datenum = WL.Time.WALS;

% Convert datetime
obs_t_bath = datetime(WL.Time.BATH, 'ConvertFrom', 'datenum', 'Format', 'dd-MM-yyyy HH:mm');
obs_t_wals = datetime(WL.Time.WALS, 'ConvertFrom', 'datenum', 'Format', 'dd-MM-yyyy HH:mm');

obs_WL_bath = WL.Values.BATH/100 ; % now in meters
obs_WL_wals = WL.Values.WALS/100 ; % now in meters

% figure
% plot(obs_t_bath, WL.Values.BATH);
% 
% figure
% plot(obs_t_wals, WL.Values.WALS);

%% Extract time and WL (val) from each ModelData entry and plot (13 figures)
nModels = numel(ModelData);
for ii = 1:nModels
    figure;
    % Bath (index 15) and Wals (index 12)
    t_bath = ModelData(ii).DFM.wl(15).time;
    wl_bath = ModelData(ii).DFM.wl(15).val;
    t_wals = ModelData(ii).DFM.wl(12).time;
    wl_wals = ModelData(ii).DFM.wl(12).val;

    % datetime to datenum
    t_bath_num = datenum(t_bath);
    t_wals_num = datenum(t_wals);

    %--- plot Bath WL ---
    subplot(2,1,1);
    hold on
    plot(obs_t_bath, obs_WL_bath, '-b', 'LineWidth', 2.5,'DisplayName', 'Observed WL');
    plot(t_bath, wl_bath, '-r', 'LineWidth', 2.5, 'DisplayName', 'Model WL');
    hold off
    xlabel('Time', 'FontSize', 16);
    ylabel('Water Level NAP (m)', 'FontSize', 16);
    set(gca, 'FontSize', 18);
    xlim([t_bath(1) t_bath(end)])
    % title('Bath');
    title(sprintf('Bath: Model %s', folders{ii}), 'FontSize', 18, 'FontWeight', 'bold');
    legend('show', 'FontSize', 18, 'TextColor', 'k');
    
    %--- plot Walsoorden WL ---
    subplot(2,1,2);
    hold on
    plot(obs_t_wals, obs_WL_wals, '-b', 'LineWidth', 2.5,'DisplayName', 'Observed WL');
    plot(t_wals, wl_wals, '-r', 'LineWidth', 2.5,'DisplayName', 'Model WL');
    hold off
    xlabel('Time', 'FontSize', 16);
    ylabel('Water Level NAP (m)', 'FontSize', 16);
    set(gca, 'FontSize', 18);
    xlim([t_wals(1) t_wals(end)]);
    % title('Walsoorden');
    title(sprintf('Walsoorden: Model %s', folders{ii}), 'FontSize', 18, 'FontWeight', 'bold');
    legend('show', 'FontSize', 18, 'TextColor', 'k');

    % Add one large centered title for the entire figure
    sgtitle(sprintf('Model vs Observed Water Level', folders{ii}), 'FontSize', 24, 'FontWeight', 'bold');

    %% Reduce observed WL to fixed date window for both Bath and Wals
    % Define fixed window as datetimes (dd-MM-yyyy)
    fixed_start = datetime('20-11-2018','InputFormat','dd-MM-yyyy');
    fixed_end   = datetime('30-12-2018','InputFormat','dd-MM-yyyy');

    % Constrain observed Bath to fixed window
    in_fixed_bath = obs_t_bath >= fixed_start & obs_t_bath <= fixed_end;
    obs_t_bath = obs_t_bath(in_fixed_bath);
    obs_WL_bath = obs_WL_bath(in_fixed_bath);

    % Constrain observed Wals to the same fixed window
    in_fixed_wals = obs_t_wals >= fixed_start & obs_t_wals <= fixed_end;
    obs_t_wals = obs_t_wals(in_fixed_wals);
    obs_WL_wals = obs_WL_wals(in_fixed_wals);

    %% RMSE, bias, and unbiased RMSE for each (compute after matching times)
    % Interpolate model WL onto observed reduced time vectors to ensure alignment
    if ~isempty(obs_t_bath) && ~isempty(wl_bath)
        wl_bath_on_obs = interp1(datenum(t_bath), wl_bath, datenum(obs_t_bath), 'linear');
        valid_bath = ~isnan(wl_bath_on_obs) & ~isnan(obs_WL_bath);
        if any(valid_bath)
            diff_bath = wl_bath_on_obs(valid_bath) - obs_WL_bath(valid_bath); % model - obs
            bias_bath = mean(diff_bath);                                     % mean error (model minus obs)
            rmse_bath = sqrt(mean(diff_bath.^2));                           % standard RMSE
            % unbiased RMSE (remove bias first)
            diff_bath_unbiased = diff_bath - bias_bath;
            ubrmse_bath = sqrt(mean(diff_bath_unbiased.^2));
        else
            bias_bath = NaN;
            rmse_bath = NaN;
            ubrmse_bath = NaN;
        end
    else
        bias_bath = NaN;
        rmse_bath = NaN;
        ubrmse_bath = NaN;
    end

    if ~isempty(obs_t_wals) && ~isempty(wl_wals)
        wl_wals_on_obs = interp1(datenum(t_wals), wl_wals, datenum(obs_t_wals), 'linear');
        valid_wals = ~isnan(wl_wals_on_obs) & ~isnan(obs_WL_wals);
        if any(valid_wals)
            diff_wals = wl_wals_on_obs(valid_wals) - obs_WL_wals(valid_wals); % model - obs
            bias_wals = mean(diff_wals);
            rmse_wals = sqrt(mean(diff_wals.^2));
            diff_wals_unbiased = diff_wals - bias_wals;
            ubrmse_wals = sqrt(mean(diff_wals_unbiased.^2));
        else
            bias_wals = NaN;
            rmse_wals = NaN;
            ubrmse_wals = NaN;
        end
    else
        bias_wals = NaN;
        rmse_wals = NaN;
        ubrmse_wals = NaN;
    end

    % Store metrics per model in arrays for later comparison
    if ii == 1
        RMSE_BATH = NaN(nModels,1);
        RMSE_WALS = NaN(nModels,1);
        BIAS_BATH = NaN(nModels,1);
        BIAS_WALS = NaN(nModels,1);
        UBRMSE_BATH = NaN(nModels,1);
        UBRMSE_WALS = NaN(nModels,1);
    end
    RMSE_BATH(ii) = rmse_bath;
    RMSE_WALS(ii) = rmse_wals;
    BIAS_BATH(ii) = bias_bath;
    BIAS_WALS(ii) = bias_wals;
    UBRMSE_BATH(ii) = ubrmse_bath;
    UBRMSE_WALS(ii) = ubrmse_wals;

end

%% best run based on rmse, bias, and unbiased RMSE
% BATH
[minRMSE_BATH, idx_rmse_bath] = min(RMSE_BATH);
[minBIAS_BATH, idx_bias_bath] = min(abs(BIAS_BATH)); % smallest absolute bias
[minUBRMSE_BATH, idx_ubrmse_bath] = min(UBRMSE_BATH);

fprintf('BATH - Lowest RMSE: %.5f (Model %s)\n', minRMSE_BATH, folders{idx_rmse_bath});
fprintf('BATH - Smallest |Bias|: %.5f (Model %s) [bias = %.4f]\n', abs(BIAS_BATH(idx_bias_bath)), folders{idx_bias_bath}, BIAS_BATH(idx_bias_bath));
fprintf('BATH - Lowest Unbiased RMSE: %.5f (Model %s)\n', minUBRMSE_BATH, folders{idx_ubrmse_bath});

% WALS
[minRMSE_WALS, idx_rmse_wals] = min(RMSE_WALS);
[minBIAS_WALS, idx_bias_wals] = min(abs(BIAS_WALS)); % smallest absolute bias
[minUBRMSE_WALS, idx_ubrmse_wals] = min(UBRMSE_WALS);

fprintf('WALS - Lowest RMSE: %.5f (Model %s)\n', minRMSE_WALS, folders{idx_rmse_wals});
fprintf('WALS - Smallest |Bias|: %.5f (Model %s) [bias = %.4f]\n', abs(BIAS_WALS(idx_bias_wals)), folders{idx_bias_wals}, BIAS_WALS(idx_bias_wals));
fprintf('WALS - Lowest Unbiased RMSE: %.5f (Model %s)\n', minUBRMSE_WALS, folders{idx_ubrmse_wals});

%% calcaulate tidal range for bath and walsoordenvbased on observations
% Definition: largest vertical distance between a consecutive high water and low water.
% local maxima/minima (peaks/troughs) and then find consecutive differences

% Ensure time series are non-empty
tidal_range_bath = NaN;
tidal_range_wals = NaN;

if ~isempty(obs_WL_bath) && numel(obs_WL_bath) >= 3
    % use findpeaks on WL to get highs and lows
    [pks_b, locs_p_b] = findpeaks(obs_WL_bath);
    [trs_b, locs_t_b] = findpeaks(-obs_WL_bath);
    trs_b = -trs_b; % restore trough values

    % combine and sort extrema by time index to get sequence
    locs_b = [locs_p_b(:); locs_t_b(:)];
    vals_b = [pks_b(:); trs_b(:)];
    [locs_b, order_b] = sort(locs_b);
    vals_b = vals_b(order_b);

    % require at least one peak and one trough and consecutive differences
    if numel(vals_b) >= 2
        diffs_b = abs(diff(vals_b));            % consecutive vertical differences
        tidal_range_bath = max(diffs_b);       % largest consecutive peak-trough
    end
end

if ~isempty(obs_WL_wals) && numel(obs_WL_wals) >= 3
    [pks_w, locs_p_w] = findpeaks(obs_WL_wals);
    [trs_w, locs_t_w] = findpeaks(-obs_WL_wals);
    trs_w = -trs_w;

    locs_w = [locs_p_w(:); locs_t_w(:)];
    vals_w = [pks_w(:); trs_w(:)];
    [locs_w, order_w] = sort(locs_w);
    vals_w = vals_w(order_w);

    if numel(vals_w) >= 2
        diffs_w = abs(diff(vals_w));
        tidal_range_wals = max(diffs_w);
    end
end

% If no extrema detected (flat or noisy), fall back to global max-min as a safe estimate
if isnan(tidal_range_bath) && ~isempty(obs_WL_bath)
    tidal_range_bath = max(obs_WL_bath) - min(obs_WL_bath);
end
if isnan(tidal_range_wals) && ~isempty(obs_WL_wals)
    tidal_range_wals = max(obs_WL_wals) - min(obs_WL_wals);
end

fprintf('Observed tidal range (Bath): %.4f m\n', tidal_range_bath);
fprintf('Observed tidal range (Walsoorden): %.4f m\n', tidal_range_wals);
