clear all
close all
clc

% Graph Walsoorden and Bath WL versus model WL. RMSE for each
% D. Pierce

%% Load measurement data
load("P:\11207654-internship-pierce-2026\02_Data\Waterlevels\WL.mat");
% load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
% load("P:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat")

%% Load model data
load("P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\output\DFM.mat")    % T0 Apr-May 2018
ModelData(1).DFM = DFM;
% load("P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\DFM.mat");         % T1 apr-may 2018
% ModelData(2).DFM = DFM ;

% Create a folders cell array matching ModelData entries for plotting/legend use
folders = { ...
    'T0'
    % 'T1'
    };

% n026 = load('p:\11207654-internship-pierce-2026\03_Model\04_bathy_j18_groynes_j18_runperiod_nov18\output\WL_nov18_026.mat');    % n = 0.026
% n020 = load('p:\11207654-internship-pierce-2026\03_Model\bathy_j18_groynes_j18_runperiod_nov18_n020\output\WL_dec2018.mat');    % n = 0.020
% n017 = load('p:\11207654-internship-pierce-2026\03_Model\bathy_j18_groynes_j18_runperiod_nov18_lown\output\WL_dec2018.mat');    % n = 0.017
% 
% % Model directories
% folders = {'p:\11207654-internship-pierce-2026\03_Model\Model Output\DP_n_comparison\'};
% 
% %% Define model velocities & times
% % Extract velocity data at specific site via column=
% WL_n026 = n026.WL.val(:,82);  %72:82 Zimmerman T0
% WL_n020 = n020.WL.val(:,82); %?
% WL_n017 = n017.WL.val(:,82); %?
% 
% % bring in time. convert from datenumb to DD-MM-YYYY HH:MM
% % convert model datenums to datetime with format 'dd-MM-yyyy HH:mm'
% t_n026 = datetime(n026.WL.times(:,1),'ConvertFrom','datenum','Format','dd-MM-yyyy HH:mm');
% % t_n020 = datetime(n020.WL.times(:,1),'ConvertFrom','datenum','Format','dd-MM-yyyy HH:mm');
% % t_n017 = datetime(n017.WL.times(:,1),'ConvertFrom','datenum','Format','dd-MM-yyyy HH:mm');
% 
% 
% % Prepare the time vector for plotting
% timeVector = ADCP.ZIMMERMAN.T0.MP0103.t_CET; 
% 
% %% define ADCP data
% WL_obs = ADCP.ZIMMERMAN.T0.MP0103.WL_from_external_source      %T0 at Zimm MP0302 % same time vector
% 
% %% Plot velocities on same graph
% figure;
% hold on;
% plot(timeVector,WL_obs, 'LineStyle','--', 'DisplayName', 'Observed');
% plot(t_n026, WL_n026, 'r', 'DisplayName', 'n = 0.026');
% plot(t_n026, WL_n020, 'g', 'DisplayName', 'n = 0.020');
% plot(t_n026, WL_n017, 'b', 'DisplayName', 'n = 0.017');
% 
% xlabel('Time');
% ylabel('Water Level NAP (n)');
% title('Model Water Levels for Manning n Comparison');
% legend show;
% hold off;
% 
% %% Best fit
% % Ensure vectors align in time: find common time range between observation and model (using t_n026 as model time reference)
% % Interpolate observed WL onto model time points (t_n026)
% WL_obs_interp = interp1(datenum(timeVector), WL_obs, datenum(t_n026), 'linear');
% 
% % Remove NaNs (where observation or model is NaN)
% valid_idx = ~isnan(WL_obs_interp) & ~isnan(WL_n026) & ~isnan(WL_n020) & ~isnan(WL_n017);
% 
% obs = WL_obs_interp(valid_idx);
% m026 = WL_n026(valid_idx);
% m020 = WL_n020(valid_idx);
% m017 = WL_n017(valid_idx);
% 
% % Compute RMSE for each model
% rmse = @(x,y) sqrt(mean((x-y).^2));
% RMSE.n026 = rmse(m026, obs);
% RMSE.n020 = rmse(m020, obs);
% RMSE.n017 = rmse(m017, obs);
% 
% % Compute median absolute error and RMSD as additional metrics
% MAE.n026 = median(abs(m026-obs));
% MAE.n020 = median(abs(m020-obs));
% MAE.n017 = median(abs(m017-obs));
% 
% RMSD.n026 = sqrt(sum((m026-obs).^2)/numel(obs));
% RMSD.n020 = sqrt(sum((m020-obs).^2)/numel(obs));
% RMSD.n017 = sqrt(sum((m017-obs).^2)/numel(obs));
% 
% % Compute quantile-based distance (e.g., compare 10th,50th,90th percentiles)
% q = [0.1 0.5 0.9];
% q_obs = quantile(obs, q);
% q026 = quantile(m026, q);
% q020 = quantile(m020, q);
% q017 = quantile(m017, q);
% qdist.n026 = norm(q026 - q_obs);
% qdist.n020 = norm(q020 - q_obs);
% qdist.n017 = norm(q017 - q_obs);
% 
% % Summarize results in a table for easy comparison
% Model = {'n=0.026'; 'n=0.020'; 'n=0.017'};
% RMSE_vals = [RMSE.n026; RMSE.n020; RMSE.n017];
% MAE_vals  = [MAE.n026;  MAE.n020;  MAE.n017];
% RMSD_vals = [RMSD.n026; RMSD.n020; RMSD.n017];
% Qdist_vals = [qdist.n026; qdist.n020; qdist.n017];
% resultsTable = table(Model, RMSE_vals, RMSD_vals, MAE_vals, Qdist_vals)
% 
% % Determine best model by RMSE (primary), then by quantile distance as tie-breaker
% [~,best_idx] = min(RMSE_vals);
% best_model = Model{best_idx};
% 
% % Display best model
% fprintf('Best match by RMSE: %s (RMSE = %.4f)\n', best_model, RMSE_vals(best_idx));

%% viewing WL stations observed
obs_t_bath_datenum = WL.Time.BATH;
obs_t_wals_datenum = WL.Time.WALS;

% Convert datetime
obs_t_bath = datetime(WL.Time.BATH, 'ConvertFrom', 'datenum', 'Format', 'dd-MM-yyyy HH:mm');
obs_t_wals = datetime(WL.Time.WALS, 'ConvertFrom', 'datenum', 'Format', 'dd-MM-yyyy HH:mm');

obs_WL_bath = WL.Values.BATH/100 ; % now in meters
obs_WL_wals = WL.Values.WALS/100 ; % now in meters

figure
plot(obs_t_bath, WL.Values.BATH);

figure
plot(obs_t_wals, WL.Values.WALS);

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

    wl_bath_interp = interp1(t_bath, wl_bath, obs_t_bath); % align model onto obs timestamps
    Bath_error = obs_WL_bath - wl_bath_interp;
  
    wl_wals_interp = interp1(t_wals, wl_wals, obs_t_wals); % align model onto obs timestamps
    Wals_error = obs_WL_wals - wl_wals_interp;

    t = tiledlayout(4,1, 'TileSpacing', 'compact', 'Padding', 'compact');

    %--- plot Bath WL ---
    nexttile;
    hold on
    plot(obs_t_bath, obs_WL_bath, '-b', 'LineWidth', 2.0,'DisplayName', 'Observed Water Level');
    plot(t_bath, wl_bath, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Model Water Level');
    hold off
    set(gca, 'FontSize', 14, 'XTickLabel', []);
    xlim([t_bath(1) t_bath(end)])
    title('Bath', 'FontSize', 14, 'FontWeight', 'normal', 'FontAngle', 'italic');
    
    %--- plot Bath error ---
    nexttile;
    hold on
    plot(obs_t_bath, Bath_error, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'DisplayName', 'Error');
    yline(0, 'k-', 'LineWidth', 1, 'HandleVisibility', 'off');
    hold off
    set(gca, 'FontSize', 14, 'XTickLabel', []);
    xlim([t_wals(1) t_wals(end)]);
    title('Error', 'FontSize', 14, 'FontWeight', 'normal', 'FontAngle', 'italic');
    
    %--- plot Walsoorden WL ---
    nexttile;
    hold on
    plot(obs_t_wals, obs_WL_wals, '-b', 'LineWidth', 2.0,'DisplayName', 'Observed Water Level');
    plot(t_wals, wl_wals, 'r-', 'LineWidth', 1.5,'DisplayName', 'Model Water Level');
    hold off
    set(gca, 'FontSize', 14, 'XTickLabel', []);
    xlim([t_wals(1) t_wals(end)]);
    title('Walsoorden', 'FontSize', 14, 'FontWeight', 'normal', 'FontAngle', 'italic');
    legend('show', 'Location', 'southeast', 'FontSize', 10, 'TextColor', 'k');
    
    %--- plot Walsoorden error ---
    nexttile;
    hold on
    plot(obs_t_wals, Wals_error, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'DisplayName', 'Error (obs-model)');
    yline(0, 'k-', 'LineWidth', 1, 'HandleVisibility', 'off');
    hold off
    set(gca, 'FontSize', 14);
    xlim([t_wals(1) t_wals(end)]);
    title('Error', 'FontSize', 14, 'FontWeight', 'normal', 'FontAngle', 'italic');
    legend('show', 'Location', 'northeast', 'FontSize', 10, 'TextColor', 'k');
    
    % Single shared axis labels for the whole tiled layout
    xlabel(t, 'Time', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel(t, 'Water Level [m NAP]', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Add one large centered title for the entire figure
    % sgtitle(sprintf('Model Water Level Performance T1', folders{ii}), 'FontSize', 16, 'FontWeight', 'bold');
end

    %% Reduce observed WL to fixed date window for both Bath and Wals
    % Define fixed window as datetimes (dd-MM-yyyy)
    fixed_start = datetime('22-04-2018','InputFormat','dd-MM-yyyy');
    fixed_end   = datetime('23-05-2018','InputFormat','dd-MM-yyyy');

    % Constrain observed Bath to fixed window
    in_fixed_bath = obs_t_bath >= fixed_start & obs_t_bath <= fixed_end;
    obs_t_bath = obs_t_bath(in_fixed_bath);
    obs_WL_bath = obs_WL_bath(in_fixed_bath);

    % Constrain observed Wals to the same fixed window
    in_fixed_wals = obs_t_wals >= fixed_start & obs_t_wals <= fixed_end;
    obs_t_wals = obs_t_wals(in_fixed_wals);
    obs_WL_wals = obs_WL_wals(in_fixed_wals);

%% import grid
FOU = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\FOU_Apr22-24_T0T1.mat'); %T0 and T1

for i = 1
    gridX = FOU.FOU(i).data.grid.face_nodes_x;
    gridY = FOU.FOU(i).data.grid.face_nodes_y;
end

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

%% Add vales of Bath and walsoorden together such that there is one RMSE, bias, and uRMSE for each model (ii)
% Combine Bath and Wals metrics into single per-model metrics (sum of values)
% Create combined vectors if not already present
COMBINED_RMSE = NaN(nModels,1);
COMBINED_BIAS = NaN(nModels,1);
COMBINED_UBRMSE = NaN(nModels,1);

% Use elementwise sum where values exist; if one site is NaN use the other,
% if both NaN result is NaN.
for k = 1:nModels
    rb = RMSE_BATH(k);
    rw = RMSE_WALS(k);
    bb = BIAS_BATH(k);
    bw = BIAS_WALS(k);
    ub = UBRMSE_BATH(k);
    uw = UBRMSE_WALS(k);

        % RMSE: sum if both valid, otherwise take the valid one (or NaN)
    if ~isnan(rb) && ~isnan(rw)
        COMBINED_RMSE(k) = (rb + rw) /2;
    elseif ~isnan(rb)
        COMBINED_RMSE(k) = rb;
    elseif ~isnan(rw)
        COMBINED_RMSE(k) = rw;
    else
        COMBINED_RMSE(k) = NaN;
    end

    % Bias: sum biases (model minus obs) similarly
    if ~isnan(bb) && ~isnan(bw)
        COMBINED_BIAS(k) = (bb + bw) /2;
    elseif ~isnan(bb)
        COMBINED_BIAS(k) = bb;
    elseif ~isnan(bw)
        COMBINED_BIAS(k) = bw;
    else
        COMBINED_BIAS(k) = NaN;
    end

    % Unbiased RMSE: sum if both valid, otherwise take the valid one
    if ~isnan(ub) && ~isnan(uw)
        COMBINED_UBRMSE(k) = (ub + uw) /2;
    elseif ~isnan(ub)
        COMBINED_UBRMSE(k) = ub;
    elseif ~isnan(uw)
        COMBINED_UBRMSE(k) = uw;
    else
        COMBINED_UBRMSE(k) = NaN;
    end
end

% Also store indices of best models based on combined metrics
[minCOMB_RMSE, idx_comb_rmse] = min(COMBINED_RMSE);
[minCOMB_ABSBIAS, idx_comb_bias] = min(abs(COMBINED_BIAS));
[minCOMB_UBRMSE, idx_comb_ubrmse] = min(COMBINED_UBRMSE);

fprintf('COMBINED - Lowest RMSE: %.5f (Model %s)\n', minCOMB_RMSE, folders{idx_comb_rmse});
fprintf('COMBINED - Smallest |Bias|: %.5f (Model %s) [bias = %.4f]\n', abs(COMBINED_BIAS(idx_comb_bias)), folders{idx_comb_bias}, COMBINED_BIAS(idx_comb_bias));
fprintf('COMBINED - Lowest Unbiased RMSE: %.5f (Model %s)\n', minCOMB_UBRMSE, folders{idx_comb_ubrmse});


% %% calcaulate tidal range for bath and walsoordenvbased on observations
% % Definition: largest vertical distance between a consecutive high water and low water.
% % local maxima/minima (peaks/troughs) and then find consecutive differences
% 
% % Ensure time series are non-empty
% tidal_range_bath = NaN;
% tidal_range_wals = NaN;
% 
% if ~isempty(obs_WL_bath) && numel(obs_WL_bath) >= 3
%     % use findpeaks on WL to get highs and lows
%     [pks_b, locs_p_b] = findpeaks(obs_WL_bath);
%     [trs_b, locs_t_b] = findpeaks(-obs_WL_bath);
%     trs_b = -trs_b; % restore trough values
% 
%     % combine and sort extrema by time index to get sequence
%     locs_b = [locs_p_b(:); locs_t_b(:)];
%     vals_b = [pks_b(:); trs_b(:)];
%     [locs_b, order_b] = sort(locs_b);
%     vals_b = vals_b(order_b);
% 
%     % require at least one peak and one trough and consecutive differences
%     if numel(vals_b) >= 2
%         diffs_b = abs(diff(vals_b));            % consecutive vertical differences
%         tidal_range_bath = max(diffs_b);       % largest consecutive peak-trough
%     end
% end
% 
% if ~isempty(obs_WL_wals) && numel(obs_WL_wals) >= 3
%     [pks_w, locs_p_w] = findpeaks(obs_WL_wals);
%     [trs_w, locs_t_w] = findpeaks(-obs_WL_wals);
%     trs_w = -trs_w;
% 
%     locs_w = [locs_p_w(:); locs_t_w(:)];
%     vals_w = [pks_w(:); trs_w(:)];
%     [locs_w, order_w] = sort(locs_w);
%     vals_w = vals_w(order_w);
% 
%     if numel(vals_w) >= 2
%         diffs_w = abs(diff(vals_w));
%         tidal_range_wals = max(diffs_w);
%     end
% end
% 
% % If no extrema detected (flat or noisy), fall back to global max-min as a safe estimate
% if isnan(tidal_range_bath) && ~isempty(obs_WL_bath)
%     tidal_range_bath = max(obs_WL_bath) - min(obs_WL_bath);
% end
% if isnan(tidal_range_wals) && ~isempty(obs_WL_wals)
%     tidal_range_wals = max(obs_WL_wals) - min(obs_WL_wals);
% end
% 
% fprintf('Observed tidal range (Bath): %.4f m\n', tidal_range_bath);
% fprintf('Observed tidal range (Walsoorden): %.4f m\n', tidal_range_wals);
