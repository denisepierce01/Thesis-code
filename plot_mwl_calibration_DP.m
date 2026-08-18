%% Plot bias & RMSE in bar plots for selected folders for water level & velocity stations

% feb-2024 - v01 - Tim de Wilde
% aug-2024 - v02 - Carlijn Meijers - aangepast voor modelvalidatie
% morfologisch model obv 6de generatie model
% feb-2025 - v03 - Tim de Wilde - update voor nieuw WS model (en extra
% stations
% mar-2025 - v04 - Carlijn Meijers - bar plots toegevoegd
% mei-2025 - v05 - Carlijn Meijers - time indexing aangepast (fouten eruit die optraden bij modellen met verschillende runtimes)
% okt-2025 - v06 - Carlijn Meijers - Update en opschonen obv nieuw basisscript (DFM als input)

clear all; close all; clc;

%% Paths & settings

datadir = 'p:\1204421-kpp-benokust\2025\06-Westerschelde\01_data\';
folders = { 
    'P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18', ...
    'P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18'
 }; 

% Name of simulation (for legend entry)
names = {'Calibration'; 'Validation'};  % Length of names should match length of folders!

% Location to save the .png
png_dir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\water level\'; % Location of png's
png_name = 'WL_calib_valid';
png_dir = [png_dir png_name filesep]; if ~exist(png_dir,'dir'); mkdir (png_dir); end

for ii = 1:length(folders)
    folders{ii} = [folders{ii} '\output\'];
end

% Define start and end time of simulation
t0   = datetime('22-Apr-2018','InputFormat','dd-MMM-yyyy');
tend = datetime('23-May-2018','InputFormat','dd-MMM-yyyy');
year = 2018;

% Specify which stations to use:
stations_wl = {'Wandelaar','Bol van Heist','Scheur Wielingen','Vlissingen','Terneuzen','Overloop van Hansweert','Hansweert','Walsoorden','Baalhoek','Bath','Liefkenshoek'}; 

% Labels of stations (same order as stations in data.mat; probably alphabetically)
station_names_all = {'BAA', 'BAT', 'BOR', 'BRE', 'BSA', 'CAD', 'HAN','LIE','WAN', 'BvH', 'SWI', 'WES', ...
    'OvH', 'SvN', 'TER', 'VLI', 'VR', 'WAL','WKP'};
dx_station_all = [2.5,  2.5, 0, 3, 0, 0,  0,   -3,  0,  0,   0, 0,  1, -1,   0,  0, 0,  3, 0]; 
dy_station_all = [-1,   0,   0, 0, 0, -2, 2.5, 0,  -2, -2, 2.5, 0, -2,  2, -2.5, 2, -2, 0, 0];

%%% Write folder names to .txt file in output folder

fid = fopen([png_dir 'runs.txt'], 'w');
for ii = 1:length(folders)
    fprintf(fid, '%s\n', folders{ii});
end
fclose(fid);

%% =========================================================================
%% STEP 1: LOAD & TIME-WINDOW DISTINCT DATASETS FOR EACH INDIVIDUAL RUN
%% =========================================================================
% Pre-allocate structure handles to hold separate time periods
Data = struct();
MeasDataPeriod = cell(1, length(folders));
station_names = cell(1, length(stations_wl));

for ii = 1:length(folders)
    
    % Dynamically define specific time domains inside the run loop
    if ii == 1
        t0   = datetime('22-Apr-2018','InputFormat','dd-MMM-yyyy');
        tend = datetime('23-May-2018','InputFormat','dd-MMM-yyyy');
        run_year = 2018;

    end
    
    % Store temporal definitions for figure rendering later
    Data(ii).t0 = t0;
    Data(ii).tend = tend;
    
    % --- LOAD AND FILTER OBSERVATION TIMEFRAMES ---
    if run_year == 2018
        meas_struct = load([datadir '2018\02_waterstanden\wlData.mat'],'data');
    else
        error('Invalid year context or no measurement data found!');
    end
    run_data = meas_struct.data;
    
    idx_st = zeros(1, length(stations_wl));
    for st = 1:length(stations_wl)
        for jj = 1:length(run_data)
            if strcmp(run_data(jj).naam, stations_wl{st}) 
                idx_st(st) = jj;
                
                % Slice out dates outside this run's specific active window
                idx_t = run_data(jj).time < t0 | run_data(jj).time > tend; 
                run_data(jj).wl(idx_t) = [];
                run_data(jj).time(idx_t) = [];
            end
        end
    end
    
    % Isolate active stations for this period group
    measdata = run_data(idx_st); 
    MeasDataPeriod{ii} = measdata; % Save to run-specific tracking cell
    
    % Map station short-names securely on the initial pass
    if ii == 1
        dx_station = dx_station_all(idx_st);
        dy_station = dy_station_all(idx_st);
        for kk = 1:length(idx_st)
            station_names{kk} = station_names_all{idx_st(kk)};
        end
    end
    
    % --- LOAD AND FILTER THE DFM MODEL TIMEFRAMES ---
    model_file = [folders{ii} 'DFM.mat'];
    if ~exist(model_file, 'file')
        error('Could not find DFM output file at: %s', model_file);
    end
    load(model_file, 'DFM');
    
    idx_st_mod = zeros(1, length(stations_wl));
    for st = 1:length(stations_wl)
        for jj = 1:length(DFM.wl)
            if strcmp(DFM.wl(jj).station_longname, stations_wl{st}) 
                idx_st_mod(st) = jj;
                
                % Slice out model data outside this specific timeline window
                idx_t = DFM.wl(jj).time < t0 | DFM.wl(jj).time > tend; 
                DFM.wl(jj).val(idx_t) = [];
                DFM.wl(jj).time(idx_t) = [];
            end
        end
    end
    DFM.wl = DFM.wl(idx_st_mod);
    
    % Clean up model channel grids
    for jj = 1:length(DFM.wl_channel)
        idx_t = DFM.wl_channel(jj).time < t0 | DFM.wl_channel(jj).time > tend; 
        DFM.wl_channel(jj).val(idx_t) = [];
        DFM.wl_channel(jj).time(idx_t) = [];
    end
    
    % Synchronize Measurement NaNs with Model Data
    for jj = 1:length(measdata)
        idx_NaN = isnan(measdata(jj).wl);
        dt_NaN = measdata(jj).time(idx_NaN);
        idx_NaN_Times = ismember(DFM.wl(jj).time, dt_NaN);
        DFM.wl(jj).val(idx_NaN_Times) = NaN;
    end
    
    Data(ii).WL = DFM.wl;
    Data(ii).WL_channel = DFM.wl_channel;
end

%% =========================================================================
%% STEP 2: CALCULATE AGGREGATED METRICS ACCROSS INTERSECTING DATASETS
%% =========================================================================

[xz, yz] = landboundary('read', [datadir 'zeeland.ldb']);
cmap = lines(length(folders)); 
xlims = [-15 85]; ylims_small = [365 390];
b_width = 1;

RDx_ch = [Data(1).WL_channel.RDx]; 
RDy_ch = [Data(1).WL_channel.RDy]; 
L = [0, cumsum(sqrt(diff(RDx_ch).^2 + diff(RDy_ch).^2))]./1000; 
kms = 9:10:L(end); 
idx_10 = zeros(size(kms));
for ii = 1:length(kms); idx_10(ii) = find(L>=kms(ii),1); end

% Extract observational coordinates and establish distance metrics
ref_meas = MeasDataPeriod{1}; 
for ii = 1:length(Data(1).WL)
    [~, idx_obs_L(ii)] = min(abs(sqrt((Data(1).WL(ii).RDx - [Data(1).WL_channel.RDx]).^2 + (Data(1).WL(ii).RDy  - [Data(1).WL_channel.RDy]).^2)));
end
L_obs = L(idx_obs_L); 
[L_sorted, idxobs] = sort(L_obs); 

for ii = 1:length(ref_meas)
    [~, idx_meas_L(ii)] = min(abs(sqrt((ref_meas(ii).RDx - [Data(1).WL_channel.RDx]).^2 + (ref_meas(ii).RDy - [Data(1).WL_channel.RDy]).^2)));
end
L_meas = L(idx_meas_L);

% Allocate and compute dynamic comparative matrix grids
mwl = zeros(length(folders), length(L_obs));
v = zeros(length(folders), length(L_obs));
mwl_meas = zeros(length(folders), length(L_obs));
v_meas = zeros(length(folders), length(L_obs));

for ii = 1:length(folders)
    mwl(ii,:) = mean([Data(ii).WL.val], 1, 'omitnan');
    v(ii,:) = var([Data(ii).WL.val], 1, 'omitnan');
    
    % Read time-matched metrics for this individual period frame
    current_meas = MeasDataPeriod{ii};
    mwl_meas(ii,:) = mean([current_meas.wl], 1, 'omitnan');
    v_meas(ii,:) = var([current_meas.wl], 1, 'omitnan');
end

% Compute differential structures relative to their matching periods
mwldif = mwl - mwl_meas;
vdif = v - v_meas;

%% =========================================================================
%% STEP 3: GRAPH GENERATION & COMPARATIVE PLOTTING
%% =========================================================================

for version = 1:3 
    figure('Position', [800 200 925 780])
    
    % ----- Plot 1: Station Overview Map -----
    subplot(3,1,1); 
    hold on; grid on; box on; axis equal
    
    plot(xz./1000, yz./1000, 'k-', 'Linewidth', 1, 'HandleVisibility','off');  
    plot(RDx_ch./1000, RDy_ch./1000, '-o', 'Color', 'r', 'MarkerSize', 2, 'DisplayName', 'Stations channel (model)', 'MarkerFaceColor', 'r');
    scatter(RDx_ch(idx_10)./1000, RDy_ch(idx_10)./1000, 20, 'filled', 'Color', 'r', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
    scatter([ref_meas.RDx]./1000, [ref_meas.RDy]./1000, 50, 'filled', 'Marker', 'diamond', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.3 .3 .3], 'DisplayName', 'Observation stations (meas.)');
    
    for ii = 1:length(idx_10) 
        dx = 1; dy = 0.3;
        rc = (RDy_ch(idx_10(ii)) - RDy_ch(idx_10(ii)-1)) / (RDx_ch(idx_10(ii)) - RDx_ch(idx_10(ii)-1));
        if rc>1; rc = 1; elseif rc< -1; rc = -1; end
        if  rc > 0
            text(RDx_ch(idx_10(ii))./1000 - dx*rc, RDy_ch(idx_10(ii))./1000 + dy, num2str(kms(ii)+1), 'HorizontalAlignment','center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'BackgroundColor', 'w', 'Margin', 0.1, 'Color', 'r')
        else
            text(RDx_ch(idx_10(ii))./1000 + dx*rc, RDy_ch(idx_10(ii))./1000 - dy, num2str(kms(ii)+1), 'HorizontalAlignment','center', 'VerticalAlignment', 'top', 'FontSize', 8, 'BackgroundColor', 'w', 'Margin', 0.1, 'Color', 'r')
        end
    end
    
    for ii = 1:length(station_names) 
       text(ref_meas(ii).RDx./1000 + dx_station(ii), ref_meas(ii).RDy./1000 + dy_station(ii), station_names{ii}, 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize', 8, 'BackgroundColor', 'w', 'Margin', 0.1)
    end
    
    xlabel('X [km]', 'FontAngle', 'italic')
    ylabel('Y [km]', 'FontAngle', 'italic')
    xlim(xlims); ylim(ylims_small)
    legend('Location', 'southwest');
    title(sprintf('Multi-Period Water Level Comparison\nRun 1: %s | Run 2: %s', datestr(Data(1).t0, 'dd-mmm'), datestr(Data(2).t0, 'dd-mmm')));
    
    % ----- Plot 2: Long-Channel Profile -----
    subplot(3,1,2); 
    hold on; grid on; box on;
    
    if (version == 1) || (version == 2)
        for ii = 1:length(folders) 
            plot(L, mean([Data(ii).WL_channel.val],1, 'omitnan'), 'Color', cmap(ii,:), 'LineWidth', 1.5, 'DisplayName', names{ii}) 
            plot(L_sorted, mwl_meas(ii, idxobs), '--', 'Color', cmap(ii,:)*0.6, 'LineWidth', 1.2, 'DisplayName', ['Meas: ' names{ii}])
        end
        
        for i = 1:length(L_obs) 
            xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
            b = bar(xGroup, mwl(:,i), 'FaceColor', 'flat', 'EdgeColor', 'None', 'HandleVisibility', 'Off');
            b.CData = cmap;
            
            % Draw matching observation points for each campaign
            scatter(xGroup, mwl_meas(:,i), 40, cmap*0.5, 'diamond', 'filled', 'HandleVisibility', 'off');
        end
        ylabel('Mean water level [m]', 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
        
    elseif version == 3
        for ii = 1:length(folders) 
            plot(L, var([Data(ii).WL_channel.val],1, 'omitnan'), 'Color', cmap(ii,:), 'LineWidth', 1.5, 'DisplayName', names{ii}) 
            plot(L_sorted, v_meas(ii, idxobs), '--', 'Color', cmap(ii,:)*0.6, 'LineWidth', 1.2, 'DisplayName', ['Meas: ' names{ii}])
        end
        
        for i = 1:length(L_obs) 
            xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
            b = bar(xGroup, v(:,i), 'FaceColor', 'flat', 'EdgeColor', 'None', 'HandleVisibility', 'Off');
            b.CData = cmap;
            scatter(xGroup, v_meas(:,i), 40, cmap*0.5, 'diamond', 'filled', 'HandleVisibility', 'off');
        end
        ylabel('Water level variance [m]', 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
    end
    
    yLims = get(gca, 'YLim'); 
    for ii = 1:length(L_meas)
        xline(L_meas(ii), 'k-.','HandleVisibility','Off')
        text(L_meas(ii), 1.05*(yLims(2)-yLims(1))+yLims(1), station_names{ii}, 'HorizontalAlignment','center', 'FontSize',9)
    end
    xlim([0 max([L_obs,L])+1])
    legend('location', 'northwest', 'FontSize', 8)
    
    % ----- Plot 3: Differentials -----
    subplot(3,1,3); 
    hold on; grid on; box on;
    
    if version == 1
        for ii = 1:length(folders) 
            plot(L, var([Data(ii).WL_channel.val],1, 'omitnan'), 'Color', cmap(ii,:), 'DisplayName', names{ii}) 
            plot(L_sorted, v_meas(ii, idxobs), '--', 'Color', cmap(ii,:)*0.6, 'HandleVisibility', 'off')
        end
        for i = 1:length(L_obs) 
            xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
            b = bar(xGroup, v(:,i), 'FaceColor', 'flat', 'EdgeColor', 'None', 'HandleVisibility', 'Off');
            b.CData = cmap;
            scatter(xGroup, v_meas(:,i), 40, cmap*0.5, 'diamond', 'filled', 'HandleVisibility', 'off');
        end
        ylabel('Water level variance [m]', 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
        
    elseif version == 2        
        for i = 1:length(L_obs) 
            xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
            b = bar(xGroup, mwldif(:,i), 'FaceColor', 'flat', 'EdgeColor', 'None', 'HandleVisibility', 'Off');
            b.CData = cmap;
        end
        ylabel({'MWL error [m]','model - matching meas'}, 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
        
    elseif version == 3
        for i = 1:length(L_obs) 
            xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
            b = bar(xGroup, vdif(:,i), 'FaceColor', 'flat', 'EdgeColor', 'None', 'HandleVisibility', 'Off');
            b.CData = cmap;
        end
        ylabel({'Variance error [m]','model - matching meas'}, 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
    end
    
    yLims = get(gca, 'YLim'); 
    for ii = 1:length(L_meas)
        xline(L_meas(ii), 'k-.','HandleVisibility','Off')
        text(L_meas(ii), 1.05*(yLims(2)-yLims(1))+yLims(1), station_names{ii}, 'HorizontalAlignment','center', 'FontSize',9)
    end
    
    xlim([0 max([L_obs,L])+1])
    xlabel('Transect length [km]', 'FontAngle', 'italic')
    
    if version == 1
        exportgraphics(gcf, [png_dir 'MWL_Var_' png_name '.png'], 'Resolution', 400)
    elseif version == 2
        exportgraphics(gcf, [png_dir 'MWL_dif_' png_name '.png'], 'Resolution', 400)
    elseif version == 3
        exportgraphics(gcf, [png_dir 'Var_dif_' png_name '.png'], 'Resolution', 400)
    end
end
% %% Load measurement data
% 
% if year == 2018
%     load([datadir '2018\02_waterstanden\wlData.mat'],'data')
% elseif year == 2019
%     load([datadir '2019\01_waterstanden\wlData.mat'],'data')
% elseif year == 2025 
%     error ('No measurement data for 2025 stored yet')
% else
%     error ('Verkeerde jaar, pannenkoek!')
% end
% 
% for st = 1:length(stations_wl)
%     for ii = 1:length(data)
% 
%         % Delete meas data outside t0 and tend
%         idx_t = data(ii).time < t0 | data(ii).time > tend; 
%         data(ii).wl(idx_t) = [];
%         data(ii).time(idx_t) = [];
% 
%         if strcmp(data(ii).naam,stations_wl{st}) % Find index (& volgorde) matching stations
%             idx_st(st) = ii;
%         end
%     end
% end
% measdata = data(idx_st); 
% dx_station = dx_station(idx_st);
% dy_station = dy_station(idx_st);
% for ii = 1:length(idx_st)
%     station_names{ii} = station_names_all{idx_st(ii)};
% end
% clear idx_st
% 
% %% Load model data
% 
% for ii = 1:length(folders)
%     load([folders{ii} 'DFM.mat'], 'DFM')
% 
%     for st = 1:length(stations_wl)
%         for jj = 1:length(DFM.wl)
% 
%             % Delete model data outside t0 and tend
%             idx_t = DFM.wl(jj).time < t0 | DFM.wl(jj).time > tend; 
%             DFM.wl(jj).val(idx_t) = [];
%             DFM.wl(jj).time(idx_t) = [];
% 
%             if strcmp(DFM.wl(jj).station_longname,stations_wl{st}) % Find index (& volgorde) matching stations
%                 idx_st(st) = jj;
%             end
%         end
%     end
%     DFM.wl = DFM.wl(idx_st);  clear idx_st
% 
%     for jj = 1:length(DFM.wl_channel)
%             idx_t = DFM.wl_channel(jj).time < t0 | DFM.wl_channel(jj).time > tend; 
%             DFM.wl_channel(jj).val(idx_t) = [];
%             DFM.wl_channel(jj).time(idx_t) = [];
%     end
% 
%     for jj = 1:length(measdata)
%         idx_NaN = isnan(measdata(jj).wl);
%         dt_NaN = measdata(jj).time(idx_NaN);
%         disp(['Measurement station: ' measdata(jj).naam{1} ' compared with model station: ' DFM.wl(jj).station_longname])
%         disp(['Sum nans: ' num2str(sum(idx_NaN))])
%         idx_NaN_Times = ismember(DFM.wl(jj).time,dt_NaN);
%         DFM.wl(jj).val(idx_NaN_Times) = NaN;
%         disp(['Sum nans model: ' num2str(sum(isnan(DFM.wl(jj).val(idx_NaN_Times))))])      
%     end
% 
%     Data(ii).WL = DFM.wl;
%     Data(ii).WL_channel = DFM.wl_channel;
% end
% 
% %% Figure settings
% 
% [xz,yz] = landboundary('read',[datadir 'zeeland.ldb']);
% 
% cmap = lines(length(folders)); 
% xlims = [-15 85]; ylims = [355 395]; ylims_small = [365 390];
% b_width = 1;
% 
% % Indicate each 10th KM in plot
% RDx_ch = [Data(1).WL_channel.RDx]; 
% RDy_ch = [Data(1).WL_channel.RDy]; 
% L= [0, cumsum(sqrt(diff(RDx_ch).^2 + diff(RDy_ch).^2))]./1000; %m to km
% kms = 9:10:L(end); 
% idx_10 = zeros(size(kms));
% for ii = 1:length(kms); idx_10(ii) = find(L>=kms(ii),1); end
% 
% % Find nearest transect location for each obs location 
% for ii = 1:length(Data(1).WL) % Model
%     [~, idx_obs_L(ii)] = min(abs(sqrt((Data(1).WL(ii).RDx - [Data(1).WL_channel.RDx]).^2 + (Data(1).WL(ii).RDy  - [Data(1).WL_channel.RDy]).^2)));
% end
% L_obs = L(idx_obs_L); 
% [L_sorted, idxobs] = sort(L_obs); 
% 
% for ii = 1:length(measdata) % Meas
%     [~, idx_meas_L(ii)] = min(abs(sqrt((measdata(ii).RDx - [Data(1).WL_channel.RDx]).^2 + (measdata(ii).RDy - [Data(1).WL_channel.RDy]).^2)));
% end
% L_meas = L(idx_meas_L);
% 
% % Fill array with model data to enable bar plot
% mwl = zeros(length(folders),length(L_obs));
% v = zeros(length(folders),length(L_obs));
% 
% for ii = 1:length(folders)
%     mwl(ii,:) = mean([Data(ii).WL.val],1, 'omitnan');
%     v(ii,:) = var([Data(ii).WL.val],1, 'omitnan');
% end
% 
% % Fill array with measurement data to enable bar plot
% mwl_meas = mean([measdata.wl],1,'omitnan');
% v_meas = var([measdata.wl],1,'omitnan');
% 
% % Fill array with difference model - measurement data for bar plot
% vdif = v(1:length(folders),:) - repmat(v_meas,length(folders),1);
% mwldif = mwl(1:length(folders),:) - repmat(mwl_meas,length(folders),1);
% 
% %%  --------------------  Plot - MWL + Var  --------------------
% 
% for version = 1:3 % Plot 3x --> MWL + Var | MWL + MWL dif | Var + Var dif
%     figure('Position', [800 200 925 780])
% 
%     %  ----- Plot 1: overview of locations -----
%     subplot(3,1,1); 
%     hold on; grid on; box on; axis equal
% 
%     plot(xz./1000, yz./1000, 'k-', 'Linewidth', 1, 'HandleVisibility','off');  % Landboundary
%     plot(RDx_ch./1000, RDy_ch./1000, '-o', 'Color', 'r', 'MarkerSize', 2, 'DisplayName', 'Stations channel (model)', 'MarkerFaceColor', 'r');
%     scatter(RDx_ch(idx_10)./1000, RDy_ch(idx_10)./1000, 20, 'filled', 'Color', 'r', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
%     scatter([measdata.RDx]./1000, [measdata.RDy]./1000, 50, 'filled', 'Marker', 'diamond', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.3 .3 .3], 'DisplayName', 'Observation stations (meas.)');
% 
%     for ii = 1:length(idx_10) % Indicate transect length every 10 kilometer
%         dx = 1; dy = 0.3;
%         rc = (RDy_ch(idx_10(ii)) - RDy_ch(idx_10(ii)-1)) / (RDx_ch(idx_10(ii)) - RDx_ch(idx_10(ii)-1));
%         if rc>1; rc = 1; elseif rc< -1; rc = -1; end
%         if  rc > 0
%             text(RDx_ch(idx_10(ii))./1000 - dx*rc, RDy_ch(idx_10(ii))./1000 + dy, num2str(kms(ii)+1), 'HorizontalAlignment','center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'BackgroundColor', 'w', 'Margin', 0.1, 'Color', 'r')
%         else
%             text(RDx_ch(idx_10(ii))./1000 + dx*rc, RDy_ch(idx_10(ii))./1000 - dy, num2str(kms(ii)+1), 'HorizontalAlignment','center', 'VerticalAlignment', 'top', 'FontSize', 8, 'BackgroundColor', 'w', 'Margin', 0.1, 'Color', 'r')
%         end
%     end
% 
%     for ii = 1:length(station_names) % Show name of measurement stations
%        text(measdata(ii).RDx./1000 + dx_station(ii), measdata(ii).RDy./1000 + dy_station(ii), station_names{ii}, 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize', 8, 'BackgroundColor', 'w', 'Margin', 0.1)
%     end
% 
%     xlabel('X [km]', 'FontAngle', 'italic')
%     ylabel('Y [km]', 'FontAngle', 'italic')
%     xlim(xlims); ylim(ylims_small)
%     legend('Location', 'southwest');
%     title(['Water level analysis '  datestr(t0), ' to ' datestr(tend)])
% 
%     % ---------- Plot 2 ----------
%     subplot(3,1,2); 
%     hold on; grid on; box on;
% 
%     if (version == 1) || (version == 2)
%         for ii = 1:length(folders) % Lines for channel
%             plot(L, mean([Data(ii).WL_channel.val],1, 'omitnan'), 'Color', cmap(ii,:), 'DisplayName', names{ii}) 
%         end
%         plot(L_sorted,mwl_meas(idxobs),'--','Color',[0.3 0.3 0.3],'DisplayName','Measurement')
% 
%         for i = 1:length(L_obs) % Bars for observation stations
%             xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
%             b = bar(xGroup,mwl(:,i),'FaceColor','flat','EdgeColor','None','HandleVisibility','Off');
%             b.CData = cmap;
%         end
%         scatter(L_obs, mwl_meas, 50, 'filled', 'Marker', 'diamond', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0.3 0.3 0.3], 'HandleVisibility', 'off')
%         ylabel('Mean water level [m]', 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
% 
%     elseif version == 3
%         for ii = 1:length(folders) % Lines for channel
%             plot(L, var([Data(ii).WL_channel.val],1, 'omitnan'), 'Color', cmap(ii,:), 'DisplayName', names{ii}) 
%         end
%         plot(L_sorted,v_meas(idxobs),'--','Color',[0.3 0.3 0.3],'DisplayName','Measurement')
% 
%         for i = 1:length(L_obs) % Bars for observation stations
%             xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
%             b = bar(xGroup,v(:,i),'FaceColor','flat','EdgeColor','None','HandleVisibility','Off');
%             b.CData = cmap;
%         end
%         scatter(L_obs, v_meas, 50, 'filled', 'Marker', 'diamond', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0.3 0.3 0.3], 'HandleVisibility', 'off')
%         ylabel('Water level variance [m]', 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
%     end
% 
% 
%     yLims = get(gca, 'YLim'); % Plot locations of measurements
%     for ii = 1:length(L_meas)
%         xline(L_meas(ii), 'k-.','HandleVisibility','Off')
%         text(L_meas(ii), 1.1*(yLims(2)-yLims(1))+yLims(1), station_names{ii}, 'HorizontalAlignment','center', 'FontSize',9)
%     end
% 
%     % Plot settings
%     xlim([0 max([L_obs,L])+1])
%     legend('location', 'northwest')
% 
%     % ----- Plot 3: Variance -----
%     subplot(3,1,3); 
%     hold on; grid on; box on;
% 
%     if version == 1
%         for ii = 1:length(folders) % Lines for channel
%             plot(L, var([Data(ii).WL_channel.val],1, 'omitnan'), 'Color', cmap(ii,:), 'DisplayName', names{ii}) 
%         end
%         plot(L_sorted,v_meas(idxobs),'--','Color',[0.3 0.3 0.3],'DisplayName','Measurement')
% 
%         for i = 1:length(L_obs) % Bars for observation stations
%             xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
%             b = bar(xGroup,v(:,i),'FaceColor','flat','EdgeColor','None','HandleVisibility','Off');
%             b.CData = cmap;
%         end
%         scatter(L_obs, v_meas, 50, 'filled', 'Marker', 'diamond', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0.3 0.3 0.3], 'HandleVisibility', 'off')
%         ylabel('Water level variance [m]', 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
% 
%     elseif version == 2        
%         for i = 1:length(L_obs) % Bars for observation stations
%             xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
%             b = bar(xGroup,mwldif(:,i),'FaceColor','flat','EdgeColor','None','HandleVisibility','Off');
%             b.CData = cmap;
%         end
%         ylabel({'MWL error [m]','model - meas'}, 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
% 
%     elseif version == 3
%         for i = 1:length(L_obs) % Bars for observation stations
%             xGroup = linspace(L_obs(i) - b_width, L_obs(i) + b_width, length(folders));
%             b = bar(xGroup,vdif(:,i),'FaceColor','flat','EdgeColor','None','HandleVisibility','Off');
%             b.CData = cmap;
%         end
%         ylabel({'Variance error [m]','model - meas'}, 'FontWeight', 'bold', 'FontAngle', 'italic'); ytickformat('%0.2f')
%     end
% 
%     yLims = get(gca, 'YLim'); % Plot locations of measurements
%     for ii = 1:length(L_meas)
%         xline(L_meas(ii), 'k-.','HandleVisibility','Off')
%         text(L_meas(ii), 1.1*(yLims(2)-yLims(1))+yLims(1), station_names{ii}, 'HorizontalAlignment','center', 'FontSize',9)
%     end
% 
%     % Plot settings
%     xlim([0 max([L_obs,L])+1])
%     xlabel('Transect length [km]', 'FontAngle', 'italic')
% 
%     if version == 1
%         exportgraphics(gcf, [png_dir 'MWL_Var_' png_name '.png'], 'Resolution', 400)
%     elseif version == 2
%         exportgraphics(gcf, [png_dir 'MWL_dif_' png_name '.png'], 'Resolution', 400)
%     elseif version == 3
%         exportgraphics(gcf, [png_dir 'Var_dif_' png_name '.png'], 'Resolution', 400)
%     end
% end


