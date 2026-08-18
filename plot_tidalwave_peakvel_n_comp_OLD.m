clear all
close all
clc

%% Compare velocities for different runs

% Load measurement data
load('P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
load("P:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat")

% Load DFMs and store within ModelData(#)
load('P:\11207654-internship-pierce-2026\03_Model\04_bathy_j18_groynes_j18_runperiod_nov18\output\DFM.mat')    % n=0.026
ModelData(1).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n025\output\DFM.mat')  % n=0.025
ModelData(2).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n024\output\DFM.mat')  % n=0.024
ModelData(3).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n023\output\DFM.mat')  % n=0.023
ModelData(4).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n022\output\DFM.mat')  % n=0.022
ModelData(5).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n021\output\DFM.mat')  % n=0.021
ModelData(6).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n020\output\DFM.mat')  % n=0.020
ModelData(7).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n019\output\DFM.mat')  % n=0.019
ModelData(8).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n018\output\DFM.mat')  % n=0.018
ModelData(9).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\bathy_j18_groynes_j18_runperiod_nov18_n017\output\DFM.mat')  % n=0.017
ModelData(10).DFM = DFM;
load('P:\11207654-internship-pierce-2026\03_Model\0_manning_roughness\1_bathy_j18_groynes_j18_runperiod_nov18_n015\output\DFM.mat') %n= 0.015
ModelData(11).DFM = DFM;

% Create a folders cell array matching ModelData entries for plotting/legend use
folders = { ...
    'n=026', ...
    'n=025', ...
    'n=024', ...
    'n=023', ...
    'n=022', ...
    'n=021', ...
    'n=020', ...
    'n=019', ...
    'n=018', ...
    'n=017', ...
    'n=015' ...
    };

% Location to save the .png
png_dir = 'p:\11207654-internship-pierce-2026\03_Model\ModelOutput\DP_n_comparison\'; % Location of png's
% png_name = '026_017n_HW_tidalwave';
% png_dir = [png_dir png_name filesep 'TR_peakVel' filesep]; if ~exist(png_dir,'dir'); mkdir (png_dir); end

% Names of measurement stations
idx_load = find(~strcmp({S(:).name}, 'Boat') & strcmp({S(:).t}, 'T0'));  %CHANGE T0/T1
stations_vel = cell(size(idx_load));
for ii = 1:length(idx_load)
    stations_vel{ii} = [S(idx_load(ii)).area '_' S(idx_load(ii)).t '_' S(idx_load(ii)).name];
end

% Sigma layer definition
sigma_layers = [2 3 5 8 10 12 15 15 15 15];

% %% Load model data
% 
% for ii = 1:length(folders)
%     load([folders{ii} '\output\DFM.mat'], 'DFM')
%     ModelData(ii).DFM = DFM;
% end

%% Plot peak velocity vs TR

cmap = interp1(linspace(0,1,11), jet(11), linspace(0,1,length(folders)));

% Analyse model data
for ss = setdiff(1:length(stations_vel), 19:40) %removed OSSENISSE stations
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
    
        [Model.TR_ebb, Model.TR_flood, Model.velMaxEbb, Model.velMaxFl] = determine_TR_peakVel(dtSeries, wlSeries, uvSeries);
        
        % Plot
        ax1 = subplot(1,2,1); hold on; grid on; box on;
        scatter(Model.TR_ebb, Model.velMaxEbb, 20, cmap(ii,:), 'filled', 'DisplayName', folders{ii});
        ax2 = subplot(1,2,2); hold on; grid on; box on;
        scatter(Model.TR_flood, Model.velMaxFl, 20, cmap(ii,:), 'filled', 'DisplayName', folders{ii});
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
    
    [Meas.TR_ebb, Meas.TR_flood, Meas.velMaxEbb, Meas.velMaxFl] = determine_TR_peakVel(dtSeries, wlSeries, uvSeries);
    
    % Plot
    subplot(1,2,1);
    scatter(Meas.TR_ebb, Meas.velMaxEbb, 70, 'k', 'x', 'LineWidth', 2, 'DisplayName','Observation')
    ylabel('\bf{\it{Maximum velocity [m/s]}}', 'FontSize', 16)
    xlabel('\bf{\it{Tidal wave [m]}}', 'FontSize', 16)
        title('Ebb','FontSize',20)
    subplot(1,2,2);
    scatter(Meas.TR_flood, Meas.velMaxFl, 70, 'k', 'x', 'LineWidth', 2, 'DisplayName','Observation')
    ylabel('\bf{\it{Maximum velocity [m/s]}}', 'FontSize', 16)
    xlabel('\bf{\it{Tidal wave [m]}}', 'FontSize', 16)
    title('Flood','FontSize',20)

    % Fit simple linear trends for flood and ebb 
    p_flood = polyfit(Meas.TR_flood(:), Meas.velMaxFl(:), 1);
    p_ebb   = polyfit(Meas.TR_ebb(:),   Meas.velMaxEbb(:), 1);

    % Generate prediction lines across combined TR range for consistent x-axis
    all_TRs = [Meas.TR_flood(:); Meas.TR_ebb(:)];
    xplot = linspace(min(all_TRs), max(all_TRs), 100);

    y_pred_flood = polyval(p_flood, xplot);
    y_pred_ebb   = polyval(p_ebb,   xplot);

    % Plot both prediction lines on both subplots for comparison
    subplot(1,2,1); % Ebb subplot
    plot(xplot, y_pred_ebb,  'Color', [0 0 0], 'LineWidth', 2, 'DisplayName','Obs trend');

    subplot(1,2,2); % Flood subplot
    plot(xplot, y_pred_flood,'Color', [0 0 0], 'LineWidth', 2, 'DisplayName','Obs trend');

    % set(gca, 'FontSize', 12)
    sgtitle(stations_vel{ss}, 'Interpreter', 'none')
    % Legend
    legend(ax1, 'FontSize', 12, 'location', 'northwest')

    % Set ylim for both axes the same
    ylims1 = get(ax1, 'YLim'); ylims2 = get(ax2, 'YLim');
    ylimMax = max([ylims1(2), ylims2(2)]);
    ylim(ax1, [0 ylimMax]); ylim(ax2, [0 ylimMax]);

    % % Export figure
    % exportgraphics(gcf, [png_dir stations_vel{ss} '.png'])

    % Compute R^2 for observation trendlines (p_flood and p_ebb) [slope intercept] from polyfit of Meas data
        R2_flood = NaN;
        if exist('p_flood','var') && ~isempty(p_flood) && ~all(isnan(Meas.TR_flood)) && ~all(isnan(Meas.velMaxFl))
            validF = ~isnan(Meas.TR_flood) & ~isnan(Meas.velMaxFl);
            if sum(validF) >= 2
                y_obs = Meas.velMaxFl(validF);
                y_fit = polyval(p_flood, Meas.TR_flood(validF));
                ss_res = sum((y_obs - y_fit).^2);
                ss_tot = sum((y_obs - mean(y_obs)).^2);
                R2_flood = 1 - ss_res/ss_tot;
            end
        end

        R2_ebb = NaN;
        if exist('p_ebb','var') && ~isempty(p_ebb) && ~all(isnan(Meas.TR_ebb)) && ~all(isnan(Meas.velMaxEbb))
            validE = ~isnan(Meas.TR_ebb) & ~isnan(Meas.velMaxEbb);
            if sum(validE) >= 2
                y_obs = Meas.velMaxEbb(validE);
                y_fit = polyval(p_ebb, Meas.TR_ebb(validE));
                ss_res = sum((y_obs - y_fit).^2);
                ss_tot = sum((y_obs - mean(y_obs)).^2);
                R2_ebb = 1 - ss_res/ss_tot;
            end
        end

        % % Compute RMSE between each ModelData run and the observation trendlines
        % nRuns = length(ModelData);
        % rmse_flood_matrix = nan(nRuns,1);
        % rmse_ebb_matrix   = nan(nRuns,1);
        % 
        % for ii = 1:nRuns
        %     % find model entry matching current station name
        %     idx_model = strcmp({ModelData(ii).DFM.vel(:).station_name}, stations_vel{ss});
        %     if ~any(idx_model)
        %         continue
        %     end
        %     % extract model TR and peak velocities for this station (assume determined earlier in commented block)
        %     dtSeries_m = ModelData(ii).DFM.vel(idx_model).time;
        %     % select wl series index as used above
        %     if contains(ModelData(ii).DFM.vel(idx_model).station_name, 'BATH')
        %         idx_wl = 15;
        %     elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'ZIMMERMAN')
        %         idx_wl = 12;
        %     elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'OSSENISSE')
        %         idx_wl = 11;
        %     else
        %         idx_wl = 1;
        %     end
        %     wlSeries_m = ModelData(ii).DFM.wl(idx_wl).val;
        %     uvSeries_m = squeeze(ModelData(ii).DFM.vel(idx_model).vel_mag)*sigma_layers.'./100;
        %     [ModelRun.TR_ebb, ModelRun.TR_flood, ModelRun.velMaxEbb, ModelRun.velMaxFl] = determine_TR_peakVel(dtSeries_m, wlSeries_m, uvSeries_m);
        % 
        %     % Flood RMSE: use p_flood = [slope, intercept] where polyval expects [slope intercept]
        %     if ~isempty(ModelRun.TR_flood) && ~isempty(ModelRun.velMaxFl) && ~isempty(p_flood)
        %         % predicted by observation trendline for each model TR_flood
        %         pred_flood = polyval(p_flood, ModelRun.TR_flood);
        %         if numel(pred_flood) == numel(ModelRun.velMaxFl)
        %             rmse_flood_matrix(ii) = sqrt(mean((ModelRun.velMaxFl - pred_flood).^2));
        %         else
        %             % If lengths differ, try matching by nearest TR within tolerance
        %             tol = 0.1;
        %             [C, ia_m, ia_meas] = intersect(round(ModelRun.TR_flood/tol)*tol, round(Meas.TR_flood/tol)*tol);
        %             if ~isempty(C)
        %                 pred_match = polyval(p_flood, ModelRun.TR_flood(ia_m));
        %                 rmse_flood_matrix(ii) = sqrt(mean((ModelRun.velMaxFl(ia_m) - pred_match).^2));
        %             end
        %         end
        %     end
        % 
        %     % Ebb RMSE: use p_ebb = [slope, intercept]
        %     if ~isempty(ModelRun.TR_ebb) && ~isempty(ModelRun.velMaxEbb) && ~isempty(p_ebb)
        %         pred_ebb = polyval(p_ebb, ModelRun.TR_ebb);
        %         if numel(pred_ebb) == numel(ModelRun.velMaxEbb)
        %             rmse_ebb_matrix(ii) = sqrt(mean((ModelRun.velMaxEbb - pred_ebb).^2));
        %         else
        %             tol = 0.1;
        %             [C, ia_m, ia_meas] = intersect(round(ModelRun.TR_ebb/tol)*tol, round(Meas.TR_ebb/tol)*tol);
        %             if ~isempty(C)
        %                 pred_match = polyval(p_ebb, ModelRun.TR_ebb(ia_m));
        %                 rmse_ebb_matrix(ii) = sqrt(mean((ModelRun.velMaxEbb(ia_m) - pred_match).^2));
        %             end
        %         end
        %     end
        % end
        % 
        % % store into provided matrices if names expected (ii,ss indexing from surrounding code)
        % if exist('rmse_flood_matrix_all','var')
        %     rmse_flood_matrix_all(:,ss) = rmse_flood_matrix;
        %     rmse_ebb_matrix_all(:,ss)   = rmse_ebb_matrix;
        % end
end
% 
% close all
% 
% % %% RMSE
% % % Determine RMSE for modeled peak velocities vs measurements across runs
% % % For each measurement station choose the best of the 3 ModelData runs (lowest RMSE)
% % nRuns = length(ModelData);
% % nStations = length(stations_vel);
% % 
% % bestRunPerStation = zeros(nStations,1);
% % rmsePerStation = nan(nStations,1);
% % ubrmsePerStation = nan(nStations,1);
% % biasPerStation = nan(nStations,1);
% % 
% % for ss = 1:nStations
% %     % get measurement peaks for this station (from previously computed Meas struct)
% %     % Recompute Meas for this station as done above
% %     splitName = split(stations_vel{ss}, '_');
% %     if strcmp(splitName{1}, 'OSSENISSE') & strcmp(splitName{2}, 'T0')
% %         splitName{2} = 'T0a';
% %     end
% %     wlSeries_meas = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
% %     dtSeries_meas = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
% %     uvSeries_meas = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;
% %     if sum(isnan(wlSeries_meas)) > 0
% %         [~, wl_astro] = t_tide(wlSeries_meas, 'interval', 10/60, 'start time', datenum(dtSeries_meas(1)), 'latitude', 52, 'error', 'wboot');
% %         wlSeries_meas(isnan(wlSeries_meas)) = wl_astro(isnan(wlSeries_meas));
% %     end
% %     [Meas.TR_ebb, Meas.TR_flood, Meas.velMaxEbb, Meas.velMaxFl] = determine_TR_peakVel(dtSeries_meas, wlSeries_meas, uvSeries_meas);
% %     % combine measurement peak velocities (ebb & flood) into one vector and TRs into one vector
% %     meas_peaks = [Meas.velMaxEbb(:); Meas.velMaxFl(:)];
% %     meas_TRs = [Meas.TR_ebb(:); Meas.TR_flood(:)]; %#ok<NASGU>
% % 
% %     rmse_runs = nan(nRuns,1);
% %     bias_runs = nan(nRuns,1);
% %     ubrmse_runs = nan(nRuns,1);
% % 
% %     for ii = 1:nRuns
% %         idx_model = strcmp({ModelData(ii).DFM.vel(:).station_name}, stations_vel{ss});
% %         if ~any(idx_model)
% %             rmse_runs(ii) = NaN;
% %             continue
% %         end
% %         dtSeries_model = ModelData(ii).DFM.vel(idx_model).time;
% %         % select corresponding wl series as in plotting section
% %         if contains(ModelData(ii).DFM.vel(idx_model).station_name, 'BATH')
% %             idx_wl = 15;
% %         elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'ZIMMERMAN')
% %             idx_wl = 12;
% %         elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'OSSENISSE')
% %             idx_wl = 11;
% %         else
% %             idx_wl = 1;
% %         end
% %         wlSeries_model = ModelData(ii).DFM.wl(idx_wl).val;
% %         uvSeries_model = squeeze(ModelData(ii).DFM.vel(idx_model).vel_mag)*sigma_layers.'./100;
% %         [ModelRun.TR_ebb, ModelRun.TR_flood, ModelRun.velMaxEbb, ModelRun.velMaxFl] = determine_TR_peakVel(dtSeries_model, wlSeries_model, uvSeries_model);
% %         model_peaks = [ModelRun.velMaxEbb(:); ModelRun.velMaxFl(:)];
% %         % Align model and measurement peak counts by using minimum length
% %         nPairs = min(length(meas_peaks), length(model_peaks));
% %         if nPairs == 0
% %             rmse_runs(ii) = NaN;
% %             continue
% %         end
% %         residuals = model_peaks(1:nPairs) - meas_peaks(1:nPairs);
% %         rmse_runs(ii) = sqrt(mean(residuals.^2));
% %         bias_runs(ii) = mean(residuals);
% %         ubrmse_runs(ii) = sqrt(max(rmse_runs(ii)^2 - bias_runs(ii)^2, 0));
% %     end
% % 
% %     % pick best run (lowest RMSE) for this station
% %     [minRMSE, minIdx] = min(rmse_runs);
% %     bestRunPerStation(ss) = minIdx;
% %     rmsePerStation(ss) = minRMSE;
% %     biasPerStation(ss) = bias_runs(minIdx);
% %     ubrmsePerStation(ss) = ubrmse_runs(minIdx);
% % end
% % 
% % % Overall statistics (combined ebb+flood with best run per station)
% % valid = ~isnan(rmsePerStation);
% % overall_rmse = sqrt(mean(rmsePerStation(valid).^2));
% % overall_bias = mean(biasPerStation(valid));
% % overall_ubrmse = sqrt(max(overall_rmse^2 - overall_bias^2, 0));
% % 
% % fprintf('Per-station best runs (index into ModelData):\n');
% % disp(bestRunPerStation')
% % fprintf('Mean RMSE across stations (best runs): %.3f m/s\n', nanmean(rmsePerStation));
% % fprintf('Overall RMSE (rms of station RMSEs): %.3f m/s\n', overall_rmse);
% % fprintf('Overall bias (mean of station biases): %.3f m/s\n', overall_bias);
% % fprintf('Overall ubRMSE: %.3f m/s\n', overall_ubrmse);
% 
% %% Split per station, include TW vs velocity, split per n value by model run
% 
% (Model.TR_ebb, Model.velMaxEbb)    VERSUS   (Meas.TR_ebb, Meas.velMaxEbb)
% (Model.TR_flood, Model.velMaxFl)  VERSUS   (Meas.TR_flood, Meas.velMaxFl)
% 

% %% RMSE for Zimmerman (stations 41:51) and Bath (stations 1:18)
% 
% nRuns = length(ModelData);
% nStations = length(stations_vel);
% 
% % RMSE for all runs
% rmse_matrix = nan(nStations, nRuns); 
% 
% for ss = 1:nStations
%     % get measurement peaks for this station (as above)
%     splitName = split(stations_vel{ss}, '_');
%     if strcmp(splitName{1}, 'OSSENISSE') && strcmp(splitName{2}, 'T0')
%         splitName{2} = 'T0a';
%     end
%     wlSeries_meas = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).WL_from_external_source;
%     dtSeries_meas = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).t_CET;
%     uvSeries_meas = ADCP.(splitName{1}).(splitName{2}).(splitName{3}).Umag_da;
%     if sum(isnan(wlSeries_meas)) > 0
%         [~, wl_astro] = t_tide(wlSeries_meas, 'interval', 10/60, 'start time', datenum(dtSeries_meas(1)), 'latitude', 52, 'error', 'wboot');
%         wlSeries_meas(isnan(wlSeries_meas)) = wl_astro(isnan(wlSeries_meas));
%     end
%     [Meas.TR_ebb, Meas.TR_flood, Meas.velMaxEbb, Meas.velMaxFl] = determine_TR_peakVel(dtSeries_meas, wlSeries_meas, uvSeries_meas);
% 
%     % Build measurement datasets for ebb and flood (time vs peak velocity)
%     meas_ebb_x = Meas.TR_ebb(:);
%     meas_ebb_y = Meas.velMaxEbb(:);
%     meas_flood_x = Meas.TR_flood(:);
%     meas_flood_y = Meas.velMaxFl(:);
% 
%     % If no measurement peaks at all, skip station
%     if isempty(Meas.TR_ebb(:)) && isempty(Meas.TR_flood(:))
%         rmse_matrix(ss,:) = NaN;
%         continue
%     end
% 
%     % Fit lines to measurement ebb and flood points using RMSE-minimizing fit
%     % That is equivalent to linear regression minimizing squared vertical residuals.
%     meas_ebb_fit = [];
%     meas_flood_fit = [];
%     % Ebb fit if at least 2 points
%     valid_ebb = ~isnan(Meas.TR_ebb(:)) & ~isnan(Meas.velMaxEbb(:));
%     if sum(valid_ebb) >= 2
%         x = Meas.TR_ebb(:);
%         y = Meas.velMaxEbb(:);
%         x = x(valid_ebb);
%         y = y(valid_ebb);
%         % Solve linear least squares for [a; b] in y = a*x + b
%         A = [x ones(size(x))];
%         coeff = A \ y;
%         meas_ebb_fit = coeff(:).'; % [a b]
%     end
%     % Flood fit if at least 2 points
%     valid_flood = ~isnan(Meas.TR_flood(:)) & ~isnan(Meas.velMaxFl(:));
%     if sum(valid_flood) >= 2
%         x = Meas.TR_flood(:);
%         y = Meas.velMaxFl(:);
%         x = x(valid_flood);
%         y = y(valid_flood);
%         A = [x ones(size(x))];
%         coeff = A \ y;
%         meas_flood_fit = coeff(:).'; % [a b]
%     end
% 
%     for ii = 1:nRuns
%         idx_model = strcmp({ModelData(ii).DFM.vel(:).station_name}, stations_vel{ss});
%         if ~any(idx_model)
%             rmse_matrix(ss,ii) = NaN;
%             continue
%         end
%         dtSeries_model = ModelData(ii).DFM.vel(idx_model).time;
%         % select corresponding wl series as in plotting section
%         if contains(ModelData(ii).DFM.vel(idx_model).station_name, 'BATH')
%             idx_wl = 15;
%         elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'ZIMMERMAN')
%             idx_wl = 12;
%         elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'OSSENISSE')
%             idx_wl = 11;
%         else
%             idx_wl = 1;
%         end
%         wlSeries_model = ModelData(ii).DFM.wl(idx_wl).val;
%         uvSeries_model = squeeze(ModelData(ii).DFM.vel(idx_model).vel_mag)*sigma_layers.'./100;
%         % Determine peaks for model run
%         [ModelRun.TR_ebb, ModelRun.TR_flood, ModelRun.velMaxEbb, ModelRun.velMaxFl] = determine_TR_peakVel(dtSeries_model, wlSeries_model, uvSeries_model);
%         model_ebb_x = ModelRun.TR_ebb(:);
%         model_ebb_y = ModelRun.velMaxEbb(:);
%         model_flood_x = ModelRun.TR_flood(:);
%         model_flood_y = ModelRun.velMaxFl(:);
% 
%         % Compute distance of model points to measurement fit lines (ebb and flood)
%         dist_all = [];
% 
%         % For ebb: if measurement fit exists and model has ebb points
%         if ~isempty(meas_ebb_fit) && ~isempty(model_ebb_x)
%             a = meas_ebb_fit(1); b = meas_ebb_fit(2);
%             % For each model point, compute vertical residual to fit line
%             y_pred_ebb = a * model_ebb_x + b;
%             valid = ~isnan(model_ebb_y) & ~isnan(y_pred_ebb);
%             if any(valid)
%                 res = model_ebb_y(valid) - y_pred_ebb(valid);
%                 dist_all = [dist_all; res(:)];
%             end
%         end
% 
%         % For flood: likewise
%         if ~isempty(meas_flood_fit) && ~isempty(model_flood_x)
%             a = meas_flood_fit(1); b = meas_flood_fit(2);
%             y_pred_flood = a * model_flood_x + b;
%             valid = ~isnan(model_flood_y) & ~isnan(y_pred_flood);
%             if any(valid)
%                 res = model_flood_y(valid) - y_pred_flood(valid);
%                 dist_all = [dist_all; res(:)];
%             end
%         end
% 
%         % If no comparable points, set NaN
%         if isempty(dist_all)
%             rmse_matrix(ss,ii) = NaN;
%             continue
%         end
% 
%         % Compute RMSE of vertical residuals as measure of closeness to measurement fit
%         rmse_matrix(ss,ii) = sqrt(mean(dist_all.^2));
%     end
% end
% 
% graph 

% %% -- interpret RMSE matrix---
% % Sum each column (ignoring NaNs) and find column with lowest sum
% col_sums = nansum(rmse_matrix, 1);
% % If all entries in a column are NaN, nansum returns 0; detect such columns and set to Inf
% all_nan_cols = all(isnan(rmse_matrix), 1);
% col_sums(all_nan_cols) = Inf;
% [~, bestCol] = min(col_sums);
% 
% fprintf('Best fit is column %d with sum %.4g\n', bestCol, col_sums(bestCol));

%% --plotting linear best fit on graphs---
cmap = interp1(linspace(0,1,11), jet(11), linspace(0,1,length(folders)));

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
    
        [Model.TR_ebb, Model.TR_flood, Model.velMaxEbb, Model.velMaxFl] = determine_TR_peakVel(dtSeries, wlSeries, uvSeries);
        
        % Plot
        ax1 = subplot(1,2,1); hold on; grid on; box on;
        scatter(Model.TR_ebb, Model.velMaxEbb, 20, cmap(ii,:), 'filled', 'DisplayName', folders{ii});
        ax2 = subplot(1,2,2); hold on; grid on; box on;
        scatter(Model.TR_flood, Model.velMaxFl, 20, cmap(ii,:), 'filled', 'DisplayName', folders{ii});
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
    
    [Meas.TR_ebb, Meas.TR_flood, Meas.velMaxEbb, Meas.velMaxFl] = determine_TR_peakVel(dtSeries, wlSeries, uvSeries);
 
        %creating trendlines for observations
        %ebb trendline
        if ~isempty(Meas.TR_ebb) && ~all(isnan(Meas.TR_ebb)) && ~all(isnan(Meas.velMaxEbb))
            valid = ~isnan(Meas.TR_ebb) & ~isnan(Meas.velMaxEbb);
            if sum(valid) >= 2
                p_ebb = polyfit(Meas.TR_ebb(valid), Meas.velMaxEbb(valid), 1);
                model_ebb_x = linspace(min(Meas.TR_ebb(valid)), max(Meas.TR_ebb(valid)), 100);
                y_pred_ebb = polyval(p_ebb, model_ebb_x);
                
            end
        end
        
        % Flood trendline (prepare variables used later)
        model_flood_x = [];
        y_pred_flood = [];
        if ~isempty(Meas.TR_flood) && ~all(isnan(Meas.TR_flood)) && ~all(isnan(Meas.velMaxFl))
            validF = ~isnan(Meas.TR_flood) & ~isnan(Meas.velMaxFl);
            if sum(validF) >= 2
                p_flood = polyfit(Meas.TR_flood(validF), Meas.velMaxFl(validF), 1);
                model_flood_x = linspace(min(Meas.TR_flood(validF)), max(Meas.TR_flood(validF)), 100);
                y_pred_flood = polyval(p_flood, model_flood_x);
            end
        end
    % Plot
    subplot(1,2,1);
    % Ebb subplot
    scatter(Meas.TR_ebb, Meas.velMaxEbb, 70, 'k', 'x', 'LineWidth', 2, 'DisplayName','Observation')
    if exist('model_ebb_x','var') && exist('y_pred_ebb','var') && ~isempty(model_ebb_x) && ~isempty(y_pred_ebb)
        % Only plot trendline if at least 2 valid observation points were used to compute it
        valid_ebb_pts = ~isnan(Meas.TR_ebb) & ~isnan(Meas.velMaxEbb);
        if sum(valid_ebb_pts) >= 2
            obs_ebb_x = linspace(min(Meas.TR_ebb(valid_ebb_pts)), max(Meas.TR_ebb(valid_ebb_pts)), 100);
            plot(obs_ebb_x, interp1(model_ebb_x, y_pred_ebb, obs_ebb_x, 'linear', 'extrap'), 'LineWidth', 2, 'Color', [0 0 0], 'DisplayName', 'Obs trendline');
        end
    end
    ylabel('\bf{\it{Maximum velocity [m/s]}}', 'FontSize', 16)
    xlabel('\bf{\it{Tidal wave [m]}}', 'FontSize', 16)
    title('Ebb','FontSize',20)

    % Flood subplot
    subplot(1,2,2);
    scatter(Meas.TR_flood, Meas.velMaxFl, 70, 'k', 'x', 'LineWidth', 2, 'DisplayName','Observation')
    if exist('model_flood_x','var') && exist('y_pred_flood','var') && ~isempty(model_flood_x) && ~isempty(y_pred_flood)
        valid_flood_pts = ~isnan(Meas.TR_flood) & ~isnan(Meas.velMaxFl);
        if sum(valid_flood_pts) >= 2
            obs_flood_x = linspace(min(Meas.TR_flood(valid_flood_pts)), max(Meas.TR_flood(valid_flood_pts)), 100);
            plot(obs_flood_x, y_pred_flood, 'LineWidth', 2, 'Color', [0 0 0], 'DisplayName','Obs trendline')
        end
    end
    ylabel('\bf{\it{Maximum velocity [m/s]}}', 'FontSize', 16)
    xlabel('\bf{\it{Tidal wave [m]}}', 'FontSize', 16)
    title('Flood','FontSize',20)

    % set(gca, 'FontSize', 12)
    sgtitle(stations_vel{ss}, 'Interpreter', 'none')
    % Legend
    legend(ax1, 'FontSize', 11, 'location', 'northwest')

    % Set ylim for both axes the same
    ylims1 = get(ax1, 'YLim'); ylims2 = get(ax2, 'YLim');
    ylimMax = max([ylims1(2), ylims2(2)]);
    ylim(ax1, [0 ylimMax]); ylim(ax2, [0 ylimMax]);

    % % Export figure
    % exportgraphics(gcf, [png_dir stations_vel{ss} '.png'])

    %---R^2---
    % Compute R^2 for observation trendlines (p_flood and p_ebb)
    % p_flood and p_ebb are [slope intercept] from polyfit of Meas data
        R2_flood = NaN;
        if exist('p_flood','var') && ~isempty(p_flood) && ~all(isnan(Meas.TR_flood)) && ~all(isnan(Meas.velMaxFl))
            validF = ~isnan(Meas.TR_flood) & ~isnan(Meas.velMaxFl);
            if sum(validF) >= 2
                y_obs = Meas.velMaxFl(validF);
                y_fit = polyval(p_flood, Meas.TR_flood(validF));
                ss_res = sum((y_obs - y_fit).^2);
                ss_tot = sum((y_obs - mean(y_obs)).^2);
                R2_flood = 1 - ss_res/ss_tot;
            end
        end

        R2_ebb = NaN;
        if exist('p_ebb','var') && ~isempty(p_ebb) && ~all(isnan(Meas.TR_ebb)) && ~all(isnan(Meas.velMaxEbb))
            validE = ~isnan(Meas.TR_ebb) & ~isnan(Meas.velMaxEbb);
            if sum(validE) >= 2
                y_obs = Meas.velMaxEbb(validE);
                y_fit = polyval(p_ebb, Meas.TR_ebb(validE));
                ss_res = sum((y_obs - y_fit).^2);
                ss_tot = sum((y_obs - mean(y_obs)).^2);
                R2_ebb = 1 - ss_res/ss_tot;
            end
        end

        % Compute RMSE between each ModelData run and the observation trendlines
        nRuns = length(ModelData);
        rmse_flood_matrix = nan(nRuns,1);
        rmse_ebb_matrix   = nan(nRuns,1);
        
        for ii = 1:nRuns
            % find model entry matching current station name
            idx_model = strcmp({ModelData(ii).DFM.vel(:).station_name}, stations_vel{ss});
            if ~any(idx_model)
                continue
            end
            % extract model TR and peak velocities for this station (assume determined earlier in commented block)
            dtSeries_m = ModelData(ii).DFM.vel(idx_model).time;
            % select wl series index as used above
            if contains(ModelData(ii).DFM.vel(idx_model).station_name, 'BATH')
                idx_wl = 15;
            elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'ZIMMERMAN')
                idx_wl = 12;
            elseif contains(ModelData(ii).DFM.vel(idx_model).station_name, 'OSSENISSE')
                idx_wl = 11;
            else
                idx_wl = 1;
            end
            wlSeries_m = ModelData(ii).DFM.wl(idx_wl).val;
            uvSeries_m = squeeze(ModelData(ii).DFM.vel(idx_model).vel_mag)*sigma_layers.'./100;
            [ModelRun.TR_ebb, ModelRun.TR_flood, ModelRun.velMaxEbb, ModelRun.velMaxFl] = determine_TR_peakVel(dtSeries_m, wlSeries_m, uvSeries_m);
        
            % Flood RMSE: use p_flood = [slope, intercept] where polyval expects [slope intercept]
            if ~isempty(ModelRun.TR_flood) && ~isempty(ModelRun.velMaxFl) && ~isempty(p_flood)
                % predicted by observation trendline for each model TR_flood
                pred_flood = polyval(p_flood, ModelRun.TR_flood);
                if numel(pred_flood) == numel(ModelRun.velMaxFl)
                    rmse_flood_matrix(ii) = sqrt(mean((ModelRun.velMaxFl - pred_flood).^2));
                else
                    % If lengths differ, try matching by nearest TR within tolerance
                    tol = 0.1;
                    [C, ia_m, ia_meas] = intersect(round(ModelRun.TR_flood/tol)*tol, round(Meas.TR_flood/tol)*tol);
                    if ~isempty(C)
                        pred_match = polyval(p_flood, ModelRun.TR_flood(ia_m));
                        rmse_flood_matrix(ii) = sqrt(mean((ModelRun.velMaxFl(ia_m) - pred_match).^2));
                    end
                end
            end
        
            % Ebb RMSE: use p_ebb = [slope, intercept]
            if ~isempty(ModelRun.TR_ebb) && ~isempty(ModelRun.velMaxEbb) && ~isempty(p_ebb)
                pred_ebb = polyval(p_ebb, ModelRun.TR_ebb);
                if numel(pred_ebb) == numel(ModelRun.velMaxEbb)
                    rmse_ebb_matrix(ii) = sqrt(mean((ModelRun.velMaxEbb - pred_ebb).^2));
                else
                    tol = 0.1;
                    [C, ia_m, ia_meas] = intersect(round(ModelRun.TR_ebb/tol)*tol, round(Meas.TR_ebb/tol)*tol);
                    if ~isempty(C)
                        pred_match = polyval(p_ebb, ModelRun.TR_ebb(ia_m));
                        rmse_ebb_matrix(ii) = sqrt(mean((ModelRun.velMaxEbb(ia_m) - pred_match).^2));
                    end
                end
            end
        end
        
        % store into provided matrices if names expected (ii,ss indexing from surrounding code)
        if exist('rmse_flood_matrix_all','var')
            rmse_flood_matrix_all(:,ss) = rmse_flood_matrix;
            rmse_ebb_matrix_all(:,ss)   = rmse_ebb_matrix;
        end
end


% %% -- interpret RMSE matrix---
% % Sum each column (ignoring NaNs) and find column with lowest sum
% col_sums = nansum(rmse_matrix, 1);
% % If all entries in a column are NaN, nansum returns 0; detect such columns and set to Inf
% all_nan_cols = all(isnan(rmse_matrix), 1);
% col_sums(all_nan_cols) = Inf;
% [~, bestCol] = min(col_sums);
% 
% fprintf('Best fit is column %d with sum %.4g\n', bestCol, col_sums(bestCol));




%         % Filter model peaks to only those exceeding 0.6 m/s
%         high_idx = find(model_peaks > 0.6);
%         if isempty(high_idx)
%             % No model peaks above threshold -> cannot compute RMSE meaningfully
%             rmse_matrix(ss,ii) = NaN;
%             continue
%         end
% 
%         % Align number of pairs: only compare up to min number of available high model peaks
%         % and available measurement peaks. We select the first nPairs in each.
%         meas_sel = meas_peaks;
%         model_sel = model_peaks(high_idx);
%         nPairs = min(length(meas_sel), length(model_sel));
%         if nPairs == 0
%             rmse_matrix(ss,ii) = NaN;
%             continue
%         end
%         residuals = model_sel(1:nPairs) - meas_sel(1:nPairs);
%         rmse_matrix(ss,ii) = sqrt(mean(residuals.^2));
%     end
% end
% 
% % Define station groups (ensure indices inside range)
% % bath_idx = intersect(1:16, 1:nStations);
% % Zimmermann station indices: originally intended 50:51 but exclude specific indices if out of range
% exclude = [17:40];
% % zimmer_idx = setdiff(intersect(41:51, 1:nStations), intersect(exclude, 1:nStations));
% bathzimm_idx = setdiff(intersect(1:51, 1:nStations), intersect(exclude, 1:nStations));
% 
% % Compute mean RMSE across stations within each group for each run
% % mean_rmse_bath = nan(1,nRuns);
% % mean_rmse_zimmer = nan(1,nRuns);
% mean_rmse_bathzimm = nan(1,nRuns);
% for ii = 1:nRuns
%     % vals_bath = rmse_matrix(bath_idx, ii);
%     % vals_zim = rmse_matrix(zimmer_idx, ii);
%     vals_bathzimm = rmse_matrix(bathzimm_idx, ii);
%     % if any(~isnan(vals_bath))
%     %     mean_rmse_bath(ii) = mean(vals_bath(~isnan(vals_bath)));
%     % end
%     % if any(~isnan(vals_zim))
%     %     mean_rmse_zimmer(ii) = mean(vals_zim(~isnan(vals_zim)));
%     % end
%     if any(~isnan(vals_bathzimm))
%         mean_rmse_bathzimm(ii) = mean(vals_bathzimm(~isnan(vals_bathzimm)));
%     end
% end
% 
% % Select best run (minimum mean RMSE) for each group
% % [~, bestRunBath] = min(mean_rmse_bath);
% % [~, bestRunZimmer] = min(mean_rmse_zimmer);
% [~, bestRunBathZimm] = min(mean_rmse_bathzimm);
% 
% % If all NaN (no data), set to NaN
% % if all(isnan(mean_rmse_bath)); bestRunBath = NaN; end
% % if all(isnan(mean_rmse_zimmer)); bestRunZimmer = NaN; end
% if all(isnan(mean_rmse_bathzimm)); bestRunBathZimm = NaN; end
% 
% % fprintf('Best run for Bath: %s (run index %s)\n', ...
% %     ternary(~isnan(bestRunBath), num2str(bestRunBath), 'N/A'));
% % fprintf('Best run for Zimmerman: %s (run index %s)\n', ...
% %     ternary(~isnan(bestRunZimmer), num2str(bestRunZimmer), 'N/A'));
% fprintf('Best run for BathZimm pol: %s (run index %s)\n', ...
%     ternary(~isnan(bestRunBathZimm), num2str(bestRunBathZimm), 'N/A'));
% 
% % local ternary helper
% function out = ternary(cond, a, b)
%     if cond, out = a; else out = b; end
% end