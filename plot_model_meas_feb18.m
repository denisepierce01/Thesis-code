clear all
close all
clc

% Compare model results with measurements
% T. de Wilde

%% Load measurement data

load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
load('p:\11207654-internship-pierce-2026\03_Model\Model Output\ADCP_overview.mat')

%% Load model data

% Model directories
folders = { ...
    'p:\11207654-internship-pierce-2026\03_Model\bathy_j18_groynes_j18_runperiod_feb18\'
};

% Names of measurement stations
%Startdatetime                     = 20180210000000 (yyyymmddhhmmss)
% Stopdatetime                     = 20180401000000
all_t = [S.tstart];
idx_load = find([S(:).tstart] > datetime(2018,2,21) & [S(:).tstart] < datetime(2018,3,14)); %YYYY,MM,DD,HH,MM,SS

% define names for 92 combinations of Bath Oss Zimm, T0/T1
t_cells    = {S.t};    
name_cells = {S.name}; %Site MP0101
area_cells = {S.area}; %BATH, OSS, ZIMM
t_str    = string(t_cells);
name_str = string(name_cells);
area_str = string(area_cells);

% 3. Combine them (Result is 1x92 string array)
names = area_str + "_" + t_str + "_" + name_str;

% names = cell(size(idx_load));
for ii = 1:length(idx_load)
    names{ii} = [S(idx_load(ii)).area '_' S(idx_load(ii)).t '_' S(idx_load(ii)).name];
end

% Settings for loading model data
t0 = datenum(2018,2,21);
tend = datenum(2018,3,14);

for ii = 1:length(folders)
    outputFolder = [folders{ii} '\output\'];
    matFile = [outputFolder 'UV_mar2018.mat'];
    hisFiles = dir([outputFolder '*_his.nc']);

    if false %isfile(matFile)
        load(matFile)
    else
        UV_mar2018 = EHY_getmodeldata([hisFiles(1).folder filesep hisFiles(1).name], names, 'dfm', 'varName', 'uv', 't0', t0, 'tend', tend);
        BL = EHY_getmodeldata([hisFiles(1).folder filesep hisFiles(1).name], names, 'dfm', 'varName', 'bl');
        WL = EHY_getmodeldata([hisFiles(1).folder filesep hisFiles(1).name], names, 'dfm', 'varName', 'wl', 't0', t0, 'tend', tend);
        save(matFile, "UV_mar2018", "BL", "WL")
    end
    ModelData(ii).UV_mar2018 = UV_mar2018;
    ModelData(ii).WL = WL;
    ModelData(ii).BL = BL;
end

sigma_layers = [2 3 5 8 10 12 15 15 15 15];
zCCperc = sigma_layers/2 + [0 cumsum(sigma_layers(1:end-1))];

%% Plot measurement vs model result

for ii = 1:length(ModelData)
    outputFolder = [folders{ii} 'output\vel_mar2018\']; mkdir(outputFolder);
    figFolder = [outputFolder 'fig']; mkdir(figFolder);

    for jj = 1:length(ModelData(ii).UV_mar2018.requestedStations)
        name = ModelData(ii).UV_mar2018.requestedStations{jj};
        parts = split(name, '_');
        if strcmp(parts{1}, 'OSSENISSE')
           parts{2} = [parts{2} 'a']; 
        end
        % if strcmp(parts{1}, 'OSSENISSE') && strcmp(parts{2}, 'T0')
        %      parts{2} = [parts{2} 'a']; % Only T0 becomes T0a
        % end
       try
         % Access the time data
          t_vec = ADCP.(parts{1}).(parts{2}).(parts{3}).t_CET;
          tstart = dateshift(t_vec(1), 'start', 'day');
          tend   = dateshift(t_vec(end), 'end', 'day');
       catch ME
          fprintf('Skipping %s: Could not find in ADCP struct (%s)\n', name, ME.message);
       end

        % tstart = dateshift(ADCP.(parts{1}).(parts{2}).(parts{3}).t_CET(1), 'start', 'day');
        % tend   = dateshift(ADCP.(parts{1}).(parts{2}).(parts{3}).t_CET(end), 'end', 'day')

         % Get correct model time stamps
        idx_dt = ModelData(ii).UV_mar2018.times >= datenum(tstart) & ModelData(ii).UV_mar2018.times <= datenum(tend);

        % Get time, model data and measurement data for comparison
        dt = datetime(ModelData(ii).UV_mar2018.times(idx_dt), 'ConvertFrom', 'datenum');
        model = squeeze(ModelData(ii).UV_mar2018.vel_mag(idx_dt,jj,:))*sigma_layers.'./100; % Make depth average by multiplying layer thickness and deviding by 100 [%]
        meas = interp1(ADCP.(parts{1}).(parts{2}).(parts{3}).t_CET, ADCP.(parts{1}).(parts{2}).(parts{3}).Umag_da, dt);

        pngFile = [outputFolder name '.png'];
        plot_model_meas_nl(dt, model, meas, name, pngFile, 'velocity [m/s]');

        % %% Plot how 3D profile changes over the depth
        % % Find model idx when there is data from measurements
        % wet_cells_vel = ADCP.(parts{1}).(parts{2}).(parts{3}).Umag .* ADCP.(parts{1}).(parts{2}).(parts{3}).WetMask;
        % 
        % % Determine properties of vertical profile of measurements
        % prc50 = quantile(wet_cells_vel, 0.50, 1);
        % prc25 = quantile(wet_cells_vel, 0.25, 1);
        % prc75 = quantile(wet_cells_vel, 0.75, 1);
        % % prc10 = quantile(wet_cells_vel, 0.1, 1);
        % % prc90 = quantile(wet_cells_vel, 0.9, 1);
        % 
        % % Plot vertical profile of measurements
        % figure;
        % subplot(1,2,1); hold on; grid on;
        % % fill([prc90(~isnan(prc90)) fliplr(prc10(~isnan(prc10)))], ...
        % %     [ADCP.(parts{1}).(parts{2}).(parts{3}).zCellCenters(~isnan(prc90)) fliplr(ADCP.(parts{1}).(parts{2}).(parts{3}).zCellCenters(~isnan(prc10)))], ...
        % %     'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none')
        % for tt = round(linspace(1,size(wet_cells_vel,1),100))
        %     plot(wet_cells_vel(tt,:), ADCP.(parts{1}).(parts{2}).(parts{3}).zCellCenters, 'Color', [0.8 0.8 0.8])
        % end
        % yline(ADCP.(parts{1}).(parts{2}).(parts{3}).META.ZBED, 'k-', 'LineWidth',2)
        % yline(ADCP.(parts{1}).(parts{2}).(parts{3}).META.ZSENSOR, 'k-', 'LineWidth',2)
        % plot(prc50, ADCP.(parts{1}).(parts{2}).(parts{3}).zCellCenters, 'k-', 'LineWidth',2)
        % plot(prc25, ADCP.(parts{1}).(parts{2}).(parts{3}).zCellCenters, 'k-', 'LineWidth',1)
        % plot(prc75, ADCP.(parts{1}).(parts{2}).(parts{3}).zCellCenters, 'k-', 'LineWidth',1)
        % ylims1 = get(gca, 'YLim'); xlims1 = get(gca, 'XLim');
        % 
        % % Find model times when there are measurements
        % measTimes =  ADCP.(parts{1}).(parts{2}).(parts{3}).t_CET(~isnan(ADCP.(parts{1}).(parts{2}).(parts{3}).Umag_da));
        % [~, idx_dtModel, ~] = intersect(datetime(ModelData(ii).UV_mar2018.times, 'ConvertFrom', 'datenum'), measTimes);
        % 
        % % Determine vertical profile of model
        % zCC = ModelData(ii).BL.val(jj) + zCCperc./100.*(ModelData(ii).WL.val(idx_dtModel,jj) - ModelData(ii).BL.val(jj));
        % zCCmin = min(zCC, [], 'all');
        % zCCmax = max(zCC, [], 'all');
        % dZ = zCCmin:0.1:zCCmax;
        % 
        % vel_mag = squeeze(ModelData(ii).UV_mar2018.vel_mag(idx_dtModel,jj,:));
        % vel_mag_interp = NaN(size(zCC,1), length(dZ));
        % for tt = 1:size(zCC,1)
        %     vel_mag_interp(tt,:) = interp1(zCC(tt,:), vel_mag(tt,:), dZ);
        % end
        % 
        % % Determine properties of vertical profile of model
        % prc50 = quantile(vel_mag_interp, 0.50, 1);
        % prc25 = quantile(vel_mag_interp, 0.25, 1);
        % prc75 = quantile(vel_mag_interp, 0.75, 1);
        % prc10 = quantile(vel_mag_interp, 0.1, 1);
        % prc90 = quantile(vel_mag_interp, 0.9, 1);
        % 
        % subplot(1,2,2); hold on; grid on;
        % for tt = round(linspace(1,size(vel_mag,1),100))
        %     plot(vel_mag(tt,:), zCC(tt,:), 'Color', [0.8 0.8 0.8])
        % end
        % yline(ModelData(ii).BL.val(jj), 'r-', 'LineWidth',2)
        % plot(prc50, dZ, 'r-', 'LineWidth',2)
        % plot(prc25, dZ, 'r-', 'LineWidth',1)
        % plot(prc75, dZ, 'r-', 'LineWidth',1)
        % % fill([prc90 fliplr(prc10)], [dZ fliplr(dZ)], ...
        % %    'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none') 
        % ylims2 = get(gca, 'YLim'); xlims2 = get(gca, 'XLim');
        % 
        % % Set limits equal
        % subplot(1,2,1)
        % xlim([min([xlims1 xlims2]) max([xlims1 xlims2])])
        % ylim([min([ylims1 ylims2]) max([ylims1 ylims2])])
        % ylabel('\bf{\it{Elevation [m NAP]}}'); 
        % xlabel('\bf{\it{velocity [m/s]}}'); box on;
        % subplot(1,2,2)
        % xlim([min([xlims1 xlims2]) max([xlims1 xlims2])])
        % ylim([min([ylims1 ylims2]) max([ylims1 ylims2])])
        % xlabel('\bf{\it{velocity [m/s]}}'); box on;
        % sgtitle(name, 'Interpreter', 'none')
        % 
        % pngFile = [outputFolder name '_3D_profile.png'];
        % exportgraphics(gcf, pngFile)
        % 
        % % close all

        % % Plot spatial velocities
        % 
        % figure
        % Ux = ADCP.(parts{1}).(parts{2}).(parts{3}).Umag_da .* sin(deg2rad(ADCP.(parts{1}).(parts{2}).(parts{3}).Udir_da));
        % Uy = ADCP.(parts{1}).(parts{2}).(parts{3}).Umag_da .* cos(deg2rad(ADCP.(parts{1}).(parts{2}).(parts{3}).Udir_da));
        % scatter(Ux, Uy, 5, 'k', 'filled', 'DisplayName','observations'); grid on;
        % 
        % hold on;
        % Ux = squeeze(ModelData(ii).UV_mar2018.vel_x(idx_dt,jj,:))*sigma_layers.'./100;
        % Uy = squeeze(ModelData(ii).UV_mar2018.vel_y(idx_dt,jj,:))*sigma_layers.'./100;
        % scatter(Ux, Uy, 5, 'r', 'filled', 'DisplayName','model'); grid on;
        % 
        % ylabel('\bf{\it{velocity N-S [m/s]}}'); 
        % xlabel('\bf{\it{velocity E-W [m/s]}}'); box on;
        % axis equal; xt = get(gca, 'XTick'); yticks(xt);
        % yline(0, 'k-', 'LineWidth',1, 'DisplayName', 'none'); xline(0, 'k-', 'LineWidth',1, 'DisplayName', 'none');
        % sgtitle(name, 'Interpreter', 'none');
        % legend('show')
        % 
        % pngFile = [outputFolder name '_Uxy_dg.png'];
        % exportgraphics(gcf, pngFile)

    end
end

