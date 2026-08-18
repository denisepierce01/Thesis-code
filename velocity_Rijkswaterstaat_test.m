close all
clear all
clc

% plotting velocity magnitudes and directions over one flood-ebb cycle
% based on ADCP data. (recreating rijkswaterstaat figure)

% D. Pierce

%% --- 1. Load your data ---
load("P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat");

png_dir = 'P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\depth-varying';

%% Cyclic colormap: 4 equal-length sections with transitions between them
% nColors = 360;
% angles = (0:nColors-1)';
% 
% % Section length is fixed by construction: 360/4 = 90°
% sectionLength = 360 / 4;
% 
% colorBlue   = [0.00 0.45 0.74];   % section 1
% colorTrans1 = [1.00 1.00 1.00];   % section 2 (white)
% colorOrange = [0.85 0.33 0.10];   % section 3
% colorTrans2 = [0.10 0.10 0.10];   % section 4 (black)
% 
% colors  = [colorBlue; colorTrans1; colorOrange; colorTrans2];
% 
% % Section centers, evenly spaced 90° apart
% centers = 75 + (0:3)*sectionLength;   % -> [75 165 255 345]
% 
% % --- Transition width: degrees of blend centered on each boundary ---
% % Boundaries sit exactly between adjacent centers (i.e., at 30,120,210,300...
% % here at centers(k)+sectionLength/2). transitionWidth must be < sectionLength
% % to leave any flat color left in the middle of each section.
% transitionWidth = 40;   % increase to widen blends, decrease to sharpen them
% 
% plateauHalf = (sectionLength - transitionWidth) / 2;
% 
% nCenters = numel(centers);
% anchorAngles = [];
% anchorColors = [];
% for k = 1:nCenters
%     c = centers(k);
%     anchorAngles = [anchorAngles; c - plateauHalf; c + plateauHalf]; %#ok<AGROW>
%     anchorColors = [anchorColors; colors(k,:); colors(k,:)];         %#ok<AGROW>
% end
% 
% % Close the cycle by wrapping the first anchor +360
% anchorAngles = [anchorAngles; anchorAngles(1) + 360];
% anchorColors = [anchorColors; anchorColors(1,:)];
% 
% % Shift query angles into the anchor range
% queryAngles = angles;
% wrapPoint = anchorAngles(1);
% queryAngles(queryAngles < wrapPoint) = queryAngles(queryAngles < wrapPoint) + 360;

% time = ADCP.ZIMMERMAN.T0.MP0504.t_CET(:,1695:1770);
% depth = ADCP.ZIMMERMAN.T0.MP0504.zCellCenters;
% vel = ADCP.ZIMMERMAN.T0.MP0504.Umag(1695:1770, :);
% 
% time = ADCP.BATH.T1.MP0502.t_CET(:,1530:1580); 
% depth = ADCP.BATH.T1.MP0502.zCellCenters;
% vel = ADCP.BATH.T1.MP0502.Umag(1530:1580, :);
% 
% time = ADCP.BATH.T0.MP0403.t_CET(:,3130:3150); 
% depth = ADCP.BATH.T0.MP0403.zCellCenters;
% vel = ADCP.BATH.T0.MP0403.Umag(3130:3150, :);
% 
% waterLevelT0 = ADCP.BATH.T1.MP0502.WL_from_external_source(:,1530:1580);
% waterLevelT1 = ADCP.ZIMMERMAN.T1.MP0504.WL_from_external_source(:,351:426);
% 
% [D, T] = meshgrid(depth, time);
% 
% disp(size(time));
% disp(size(depth));
% disp(size(vel.'));
% 
% --- 2. Create the Velocity Plot ---
% figure('Color', 'w');
% hold on;
% 
% Use pcolor for the colored grid
% Exclude the first depth row from the plotted data
% pc = pcolor(time, depth(2:end), vel(:,2:end).', 'HandleVisibility', 'off');
% set(pc, 'EdgeColor', 'none');
% shading flat; % Or 'interp' for smooth transitions
% 
% Waterleveldiff = waterLevelT1-waterLevelT0
% 
% --- 3. Add the Water Level Curve ---
% plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'DisplayName', 'Water Level');
% plot(time, waterLevelT1, 'r--', 'LineWidth', 2, 'DisplayName', 'Water Level T1 (NAP)');
% plot(time, Waterleveldiff)
% legend('show','Box','off')
% hold off
% 
% --- 4. Matching the Aesthetic ---
% colormap(parula(7)); % Custom discrete colormap to match the 10-step legend
% caxis([0 0.7]);
% cb = colorbar('Location','eastoutside'); 
% Raise the colorbar slightly to visually raise the elevation of its label
% cb.Position(2) = cb.Position(2) + 0.12; % shift upward (adjust value as needed)
% cb.Position(4) = cb.Position(4) * 0.7; 
% ylabel(cb, 'Velocity [m/s]', 'FontWeight', 'bold');
% %
% % % % Setup grid and axes
% % % grid off;
% % % set(gca, 'Layer', 'top', 'GridColor', [0.3 0.3 0.3]);
% % % 
% ylabel('Elevation NAP [m]', 'FontSize', 24, 'FontWeight', 'bold');
% xlabel('Time', 'FontSize', 24, 'FontWeight', 'bold');
% title('Velocity Time-Depth Profile over Tidal Cycle: Bath T1 0502', 'FontSize', 32, 'FontWeight', 'bold');
% ylim([min(depth)-0.2 max(depth)+0.2]);
% % 
% Increase tick label font sizes for both axes
% ax = gca;
% ax.FontSize = 20; % adjust numeric value as desired
% ax.TickLabelInterpreter = 'none'; % keep plain formatting
% 
% If you want to increase colorbar tick labels separately:
% cb.FontSize = 20;
% % xticklabels(time)
% % 
% % Format the X-axis for dates
% % datetick('x', 'HH', 'keeplimits');

% %% --- plot velocity ---
% 
% % time = ADCP.ZIMMERMAN.T0.MP0504.t_CET(:,1695:1770);
% % depth = ADCP.ZIMMERMAN.T0.MP0504.zCellCenters;
% % vel = ADCP.ZIMMERMAN.T0.MP0504.Umag(1695:1770, :);
% 
% time = ADCP.BATH.T1.MP0502.t_CET(:,1530:1580); 
% depth = ADCP.BATH.T1.MP0502.zCellCenters;
% vel = ADCP.BATH.T1.MP0502.Udir(1530:1580, :);
% 
% % time = ADCP.BATH.T0.MP0403.t_CET(:,3130:3150); 
% % depth = ADCP.BATH.T0.MP0403.zCellCenters;
% % vel = ADCP.BATH.T0.MP0403.Umag(3130:3150, :);
% 
% waterLevelT0 = ADCP.BATH.T1.MP0502.WL_from_external_source(:,1530:1580);
% % waterLevelT1 = ADCP.ZIMMERMAN.T1.MP0504.WL_from_external_source(:,351:426);
% 
% [D, T] = meshgrid(depth, time);
% 
% disp(size(time));
% disp(size(depth));
% disp(size(vel.'));
% 
% % --- 2. Create the Velocity Plot ---
% figure('Color', 'w');
% hold on;
% 
% % Use pcolor for the colored grid
% % Exclude the first depth row from the plotted data
% pc = pcolor(time, depth(2:end), vel(:,2:end).', 'HandleVisibility', 'off');
% set(pc, 'EdgeColor', 'none');
% shading flat; % Or 'interp' for smooth transitions
% 
% % Waterleveldiff = waterLevelT1-waterLevelT0
% 
% % --- 3. Add the Water Level Curve ---
% plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'DisplayName', 'Water Level');
% % plot(time, waterLevelT1, 'r--', 'LineWidth', 2, 'DisplayName', 'Water Level T1 (NAP)');
% % plot(time, Waterleveldiff)
% legend('show','Box','off')
% hold off
% 
% % --- 4. Matching the Aesthetic ---
% colormap(customCmap); % Custom discrete colormap to match the 10-step legend
% caxis([0 360]);
% cb = colorbar('Location','eastoutside'); 
% % Raise the colorbar slightly to visually raise the elevation of its label
% cb.Position(2) = cb.Position(2) + 0.12; % shift upward (adjust value as needed)
% cb.Position(4) = cb.Position(4) * 0.7; 
% cb.Label.String = 'Flow Direction [\circ]';
% cb.Ticks = 0:45:360;
% cb.FontSize = 14;
% % cb.FontWeight = 'bold';
% 
% ylabel('Elevation NAP [m]', 'FontSize', 24, 'FontWeight', 'bold');
% xlabel('Time', 'FontSize', 24, 'FontWeight', 'bold');
% title('Velocity Time-Depth Profile over Tidal Cycle: Bath T1 0502', 'FontSize', 32, 'FontWeight', 'bold');
% ylim([min(depth)-0.2 max(depth)+0.2]);
% 
% ax = gca;
% ax.FontSize = 20; 
% ax.TickLabelInterpreter = 'none';
% 
% cb.FontSize = 20;
% % xticklabels(time)

% %% plotting side by side velicity magnitude and velocity direction
% fig = figure('Color', 'w', 'Position', [100 100 1500 400]);
% 
% % time = ADCP.BATH.T1.MP0502.t_CET(:,1530:1580); 
% % depth = ADCP.BATH.T1.MP0502.zCellCenters;
% % vel = ADCP.BATH.T1.MP0502.Umag(1530:1580, :);
% % waterLevelT0 = ADCP.BATH.T1.MP0502.WL_from_external_source(:,1530:1580);
% % vel_dir = ADCP.BATH.T1.MP0502.Udir(1530:1580, :);
% 
% % time = ADCP.BATH.T1.MP0403.t_CET(:,1560:1590); 
% % depth = ADCP.BATH.T1.MP0403.zCellCenters;
% % vel = ADCP.BATH.T1.MP0403.Umag(1560:1590, :);
% % waterLevelT0 = ADCP.BATH.T1.MP0403.WL_from_external_source(:,1560:1590);
% % vel_dir = ADCP.BATH.T1.MP0403.Udir(1560:1590, :);
% 
% % time = ADCP.BATH.T1.MP0101.t_CET(:,1515:1595); 
% % depth = ADCP.BATH.T1.MP0101.zCellCenters;
% % vel = ADCP.BATH.T1.MP0101.Umag(1515:1595, :);
% % waterLevelT0 = ADCP.BATH.T1.MP0101.WL_from_external_source(:,1515:1595);
% % vel_dir = ADCP.BATH.T1.MP0101.Udir(1515:1595, :);
% 
% time = ADCP.ZIMMERMAN.T1.MP0104.t_CET(:,1560:1600); 
% depth = ADCP.ZIMMERMAN.T1.MP0104.zCellCenters;
% vel = ADCP.ZIMMERMAN.T1.MP0104.Umag(1560:1600, :);
% waterLevelT0 = ADCP.ZIMMERMAN.T1.MP0104.WL_from_external_source(:,1560:1600);
% vel_dir = ADCP.ZIMMERMAN.T1.MP0104.Udir(1560:1600, :);
% 
% 
% %--- Subplot 1: Velocity magnitude ---
% subplot(1,2,1);
% hold on;
% 
% %--- Shared overall title ---
% sgtitle('\itZimmerman T1 0104', 'FontSize', 16);
% 
% pc = pcolor(time, depth(2:end), vel(:,2:end).', 'HandleVisibility', 'off');
% set(pc, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
% shading flat;
% 
% plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'HandleVisibility', 'off');
% legend('show','Box','off')
% hold off;
% 
% colormap(gca, parula(7)); % colormap applied to this axes only
% caxis([0 0.7]);
% cb1 = colorbar('Location','eastoutside');
% cb1.Position(1) = cb1.Position(1) + 0.04;
% cb1.Position(2) = cb1.Position(2) + 0.12;
% cb1.Position(4) = cb1.Position(4) * 0.7;
% ylabel(cb1, 'Velocity [m/s]', 'FontWeight', 'bold');
% cb1.FontSize = 14;
% 
% ylabel('Elevation NAP [m]', 'FontSize', 22, 'FontWeight', 'bold');
% xlabel('Time', 'FontSize', 22, 'FontWeight', 'bold');
% % title('Velocity Magnitude', 'FontSize', 22, 'FontWeight', 'bold');
% ylim([min(depth)-0.2 max(depth)+0.2]);
% 
% ax1 = gca;
% ax1.FontSize = 14;
% ax1.TickLabelInterpreter = 'none';
% 
% %--- Subplot 2: Flow direction ---
% subplot(1,2,2);
% hold on;
% 
% pc2 = pcolor(time, depth(2:end), vel_dir(:,2:end).', 'HandleVisibility', 'off');
% set(pc2, 'EdgeColor', 'none');
% shading flat;
% 
% plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'DisplayName', 'Water Level');
% legend('show','Box','off')
% hold off;
% 
% colormap(gca, hsv); % colormap applied to this axes only
% caxis([0 360]);
% cb2 = colorbar('Location','eastoutside');
% cb2.Position(1) = cb2.Position(1) + 0.04;
% cb2.Position(2) = cb2.Position(2) + 0.12;
% cb2.Position(4) = cb2.Position(4) * 0.7;
% % cb2.Label.String = 'Flow Direction [\circ]';
% cb2.Ticks = 0:45:360;
% cb2.FontSize = 14;
% ylabel(cb2, 'Flow Direction [\circ]', 'FontWeight', 'bold');
% 
% 
% % ylabel('Elevation NAP [m]', 'FontSize', 18, 'FontWeight', 'bold');
% xlabel('Time', 'FontSize', 22, 'FontWeight', 'bold');
% % title('Flow Direction', 'FontSize', 22, 'FontWeight', 'bold');
% ylim([min(depth)-0.2 max(depth)+0.2]);
% 
% ax2 = gca;
% ax2.FontSize = 14;
% ax2.TickLabelInterpreter = 'none';
% 
% 
% % export
% png_dir = 'P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\depth-varying';
% pngName = fullfile(png_dir, sprintf('vel_mag_dir_ZimmT10104'));
% 
% % Save figure at 300 DPI
% set(fig, 'PaperPositionMode', 'auto');
% print(fig, pngName, '-dpng', '-r300');

%% ============ SITE CONFIGURATION ============
% ADD ALL SITES?!? 
% LOOK SPECIFICALLY AT SPRING OR NEAP
% make cbar right a wheel?

sites = struct( ...
    'group',    {'BATH','BATH','BATH','BATH','BATH','BATH','BATH','BATH','BATH','BATH','BATH','BATH','ZIMMERMAN', 'ZIMMERMAN','ZIMMERMAN','ZIMMERMAN'}, ...
    'mp',       {'MP0403','MP0403','MP0403','MP0403','MP0502','MP0502','MP1002','MP0903','MP0502','MP0403','MP0101','MP0101','MP0104','MP0104', 'MP0302', 'MP0302'}, ...
    'idxRange', {1188:1212, 1860:1880, 1786:1804,2900:2915, 2850:2915,1755:1805, 1565:1612, 1553:1583, 1530:1580, 1560:1590, 1745:1825,2860:2940, 2910:2930, 1790:1805, 3010:3075, 1670:1733}, ...
    'dispName', {'Bath T0 0403 (Spring)','Bath T0 0403 (Neap)','Bath T1 0403 (Spring)','Bath T1 0403 (Neap)','Bath T1 0502 (Neap)', 'Bath T1 0502 (Spring)', 'Bath T1 1002','Bath T1 0903', 'Bath T1 0502','Bath T1 0403','Bath T1 0101 (Spring)','Bath T1 0101 (Neap)','Zimmerman T1 0104 (Neap)', 'Zimmerman T1 0104 (Spring)' 'Zimmerman T1 0302 (Neap)', 'Zimmerman T1 0302 (Spring)'} ...
);

siteIdx = 2;
s = sites(siteIdx);
grp = s.group;
mp  = s.mp;
idx = s.idxRange;

% --- Choose which site to plot (change just this number) ---
% for siteIdx = 1:numel(sites)
%     s = sites(siteIdx);
%     grp = s.group;
%     mp  = s.mp;
%     idx = s.idxRange;
    
    % ============ PULL DATA ============
    site = ADCP.(grp).T0.(mp);   % dynamic field access
    
    time         = site.t_CET(:, idx);
    depth        = site.zCellCenters;
    vel          = site.Umag(idx, :);
    waterLevelT0 = site.WL_from_external_source(:, idx);
    vel_dir      = site.Udir(idx, :);
    
    titleStr   = s.dispName;                              % e.g. 'Zimmerman T1 0104'
    fileTag    = regexprep(titleStr, '\s+', '');           % e.g. 'ZimmermanT10104'
    pngName    = fullfile(png_dir, sprintf('vel_mag_dir_%s', fileTag));
    
    % ============ PLOTTING ============
    fig = figure('Color', 'w', 'Position', [100 100 1200 400]);
    sgtitle(['\it' titleStr], 'FontSize', 16);
    
    subplot(1,2,1);
    hold on;
    pc = pcolor(time, depth(2:end), vel(:,2:end).', 'HandleVisibility', 'off');
    set(pc, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
    shading flat;
    % plot(time, waterLevelT0, 'b-', 'LineWidth', 2, 'HandleVisibility', 'off');
    legend('show','Box','off');
    hold off;
    colormap(gca, parula(7));
    caxis([0 0.7]);
    cb1 = colorbar('Location','eastoutside');
    cb1.Position(1) = cb1.Position(1) + 0.04;
    cb1.Position(2) = cb1.Position(2) + 0.12;
    cb1.Position(4) = cb1.Position(4) * 0.7;
    ylabel(cb1, 'Velocity [m/s]', 'FontWeight', 'bold');
    cb1.FontSize = 12;
    ylim([min(depth)-0.2 max(depth)+0.2]);
    ax1 = gca; ax1.FontSize = 14; ax1.TickLabelInterpreter = 'none';
    xlabel('Time', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Elevation [m  NAP]', 'FontSize', 16, 'FontWeight', 'bold');
    
    subplot(1,2,2);
    hold on;
    pc2 = pcolor(time, depth(2:end), vel_dir(:,2:end).', 'HandleVisibility', 'off');
    set(pc2, 'EdgeColor', 'none');
    shading flat;
    % plot(time, waterLevelT0, 'b-', 'LineWidth', 2, 'DisplayName', 'Water Level');
    % legend('show','Box','off');
    hold off;
    colormap(gca, hsv);
    caxis([0 360]);
    ax2 = gca; ax2.FontSize = 14; ax2.TickLabelInterpreter = 'none';
    % cb2 = colorbar('Location','eastoutside');
    % cb2.Position(1) = cb2.Position(1) + 0.04;
    % cb2.Position(2) = cb2.Position(2) + 0.12;
    % cb2.Position(4) = cb2.Position(4) * 0.7;
    % cb2.Ticks = 0:45:360;
    % cb2.FontSize = 14;

    % ylabel(cb2, 'Flow Direction [\circ]', 'FontWeight', 'bold');
    xlabel('Time', 'FontSize', 16, 'FontWeight', 'bold');
    ylim([min(depth)-0.2 max(depth)+0.2]);

    % --- Color wheel ---
    set(ax2, 'Position', [0.57 0.15 0.30 0.75])
    wheelSize = 0.18;
    wheelPos = [0.57+0.30, 0.2+0.75/2-wheelSize/2, wheelSize, wheelSize];
    drawDirectionWheel(wheelPos);
    
    % ============ EXPORT (name auto-derived, no manual edits) ============
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, pngName, '-dpng', '-r300');
    % close(fig); 
% end

%% Load  data
% load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
% load('P:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat')
% 
% % define names for 92 combinations of Bath Oss Zimm, T0/T1
% t_cells    = {S.t};    
% name_cells = {S.name}; %Site MP0101
% area_cells = {S.area}; %BATH, OSS, ZIMM
% t_str    = string(t_cells);
% name_str = string(name_cells);
% area_str = string(area_cells);
% 
% % 3. Combine them (Result is 1x92 string array)
% names = area_str + "_" + t_str + "_" + name_str;
% 
% idx_load = 92;
% 
% % names = cell(size(idx_load));
% for ii = 1:length(idx_load)
%     names{ii} = [S(idx_load(ii)).area '_' S(idx_load(ii)).t '_' S(idx_load(ii)).name];
% end
% 
% for ii = 1:length(idx_load)
%     time         = site.t_CET(:, idx);
%     depth        = site.zCellCenters;
%     vel          = site.Umag(idx, :);
%     waterLevelT0 = site.WL_from_external_source(:, idx);
%     vel_dir      = site.Udir(idx, :);
% end
% 
% %% ============ LOAD DATA ============
% load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
% load('P:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat')
% 
% png_dir = 'P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\depth-varying';
% 
% if ~exist(png_dir, 'dir')
%     mkdir(png_dir);
% end
% 
% colorBlue = [0 0.4470 0.7410];   % keep consistent with previous script; adjust if defined elsewhere
% 
% nSites = numel(S);

% %% ============ LOOP OVER ALL 92 SITES ============
% for ii = 1:nSites
% 
%     grp = S(ii).area;   % BATH, OSS, ZIMM
%     tst = S(ii).t;       % T0 or T1
%     mp  = S(ii).name;    % e.g. MP0101
% 
%     titleStr = sprintf('%s %s %s', grp, tst, mp);
% 
%     % --- Guard: skip sites missing from ADCP structure ---
%     if ~isfield(ADCP, grp) || ~isfield(ADCP.(grp), tst) || ~isfield(ADCP.(grp).(tst), mp)
%         warning('Skipping %s - field not found in ADCP structure.', titleStr);
%         continue
%     end
% 
%     site = ADCP.(grp).(tst).(mp);
% 
%     % --- Guard: skip sites missing required data fields ---
%     requiredFields = {'t_CET','zCellCenters','Umag','WL_from_external_source','Udir'};
%     if any(~isfield(site, requiredFields))
%         warning('Skipping %s - missing one or more required data fields.', titleStr);
%         continue
%     end
% 
%     %% ============ PULL DATA ============
%     % full time series is used. 
%     % idx = find(site.t_CET >= startDate & site.t_CET <= endDate);
%     idx = 1:size(site.t_CET, 2);
% 
%     time         = site.t_CET(:, idx);
%     depth        = site.zCellCenters;
%     vel          = site.Umag(idx, :);
%     waterLevelT0 = site.WL_from_external_source(:, idx);
%     vel_dir      = site.Udir(idx, :);
% 
%     fileTag = regexprep(titleStr, '\s+', '');
%     pngName = fullfile(png_dir, sprintf('vel_mag_dir_%s', fileTag));
% 
%     %% ============ PLOTTING  ============
%     fig = figure('Color', 'w', 'Position', [100 100 1500 400]);
%     sgtitle(['\it' titleStr], 'FontSize', 16);
% 
%     subplot(1,2,1);
%     hold on;
%     pc = pcolor(time, depth(2:end), vel(:,2:end).', 'HandleVisibility', 'off');
%     set(pc, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
%     shading flat;
%     plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'HandleVisibility', 'off');
%     legend('show','Box','off');
%     hold off;
%     colormap(gca, parula(7));
%     caxis([0 0.7]);
%     cb1 = colorbar('Location','eastoutside');
%     cb1.Position(1) = cb1.Position(1) + 0.04;
%     cb1.Position(2) = cb1.Position(2) + 0.12;
%     cb1.Position(4) = cb1.Position(4) * 0.7;
%     ylabel(cb1, 'Velocity [m/s]', 'FontWeight', 'bold');
%     cb1.FontSize = 12;
%     ylabel('Elevation NAP [m]', 'FontSize', 22, 'FontWeight', 'bold');
%     xlabel('Time', 'FontSize', 22, 'FontWeight', 'bold');
%     ylim([min(depth)-0.2 max(depth)+0.2]);
%     ax1 = gca; ax1.FontSize = 14; ax1.TickLabelInterpreter = 'none';
% 
%     subplot(1,2,2);
%     hold on;
%     pc2 = pcolor(time, depth(2:end), vel_dir(:,2:end).', 'HandleVisibility', 'off');
%     set(pc2, 'EdgeColor', 'none');
%     shading flat;
%     plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'DisplayName', 'Water Level');
%     legend('show','Box','off');
%     hold off;
%     colormap(gca, hsv);
%     caxis([0 360]);
%     cb2 = colorbar('Location','eastoutside');
%     cb2.Position(1) = cb2.Position(1) + 0.04;
%     cb2.Position(2) = cb2.Position(2) + 0.12;
%     cb2.Position(4) = cb2.Position(4) * 0.7;
%     cb2.Ticks = 0:45:360;
%     cb2.FontSize = 14;
%     ylabel(cb2, 'Flow Direction [\circ]', 'FontWeight', 'bold');
%     xlabel('Time', 'FontSize', 22, 'FontWeight', 'bold');
%     ylim([min(depth)-0.2 max(depth)+0.2]);
%     ax2 = gca; ax2.FontSize = 14; ax2.TickLabelInterpreter = 'none';
% 
%     %% ============ EXPORT ============
%     % set(fig, 'PaperPositionMode', 'auto');
%     % print(fig, pngName, '-dpng', '-r300');
%     % 
%     % close(fig);
%     % 
%     % fprintf('Saved %d/%d: %s\n', ii, nSites, titleStr);
% end

% %% ============ PULL DATA: ISOLATE MAX & MIN TIDAL RANGE WINDOWS ============
% 
% timeFull = site.t_CET(:).';
% wlFull   = site.WL_from_external_source(:).';
% depth    = site.zCellCenters;
% 
% halfWindow = hours(8);   % window plotted around each identified event
%                           % (increase e.g. to hours(6) to show a fuller flood/ebb cycle)
% 
% % --- Find all high-water crests and low-water troughs ---
% [hiPks, hiLocs] = findpeaks(wlFull, timeFull, 'MinPeakDistance', hours(12));
% [loPks, loLocs] = findpeaks(-wlFull, timeFull, 'MinPeakDistance', hours(12));
% loPks = -loPks;
% 
% if numel(hiPks) < 2 || numel(loPks) < 2
%     warning('%s - not enough high/low extrema found to compute tidal range.', titleStr);
%     return   % or "continue" if this sits inside a for-loop
% end
% 
% % --- Merge highs & lows in time order, then take TR between consecutive extrema ---
% allTimes = [hiLocs(:); loLocs(:)];
% allVals  = [hiPks(:);  loPks(:)];
% [sortedTimes, order] = sort(allTimes);
% sortedVals = allVals(order);
% 
% TR     = abs(diff(sortedVals));                       % tidal range per half-cycle (high-to-low or low-to-high)
% TRtime = sortedTimes(1:end-1) + diff(sortedTimes)/2;   % midpoint of each pair -> used as the event center
% 
% % Alternative: if you'd rather center each window on the HIGH-WATER peak of
% % the pair instead of the midpoint, use this instead of TRtime:
% %   isHighFirst = ismember(sortedTimes(1:end-1), hiLocs);
% %   centerTime = sortedTimes(1:end-1);
% %   centerTime(~isHighFirst) = sortedTimes(2:end);   % use the second extremum when it's the high
% centerTime = TRtime;
% 
% [~, springI] = max(TR);   % largest tidal range  -> spring cycle
% [~, neapI]   = min(TR);   % smallest tidal range -> neap cycle
% 
% events = struct( ...
%     'label',    {'spring','neap'}, ...
%     'evTime',   {centerTime(springI), centerTime(neapI)}, ...
%     'TR',       {TR(springI), TR(neapI)} ...
% );
% 
% %% ============ PLOT +/- WINDOW AROUND EACH EVENT ============
% for e = 1:numel(events)
%     evLabel = events(e).label;
%     evTime  = events(e).evTime;
% 
%     winMask = timeFull >= (evTime - halfWindow) & timeFull <= (evTime + halfWindow);
% 
%     if nnz(winMask) < 2
%         warning('%s (%s) - insufficient data in window.', titleStr, evLabel);
%         continue
%     end
% 
%     time         = timeFull(winMask);
%     vel          = site.Umag(winMask, :);
%     waterLevelT0 = wlFull(winMask);
%     vel_dir      = site.Udir(winMask, :);
% 
%     evTitleStr = sprintf('%s (%s cycle, TR=%.2fm)', titleStr, evLabel, events(e).TR);
%     fileTag    = regexprep(sprintf('%s_%s', titleStr, evLabel), '\s+', '');
%     pngName    = fullfile(png_dir, sprintf('vel_mag_dir_%s', fileTag));
% 
%     %% ============ PLOTTING ============
%     fig = figure('Color', 'w', 'Position', [100 100 1500 400]);
%     sgtitle(['\it' evTitleStr], 'FontSize', 16);
% 
%     subplot(1,2,1);
%     hold on;
%     pc = pcolor(time, depth(2:end), vel(:,2:end).', 'HandleVisibility', 'off');
%     set(pc, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
%     shading flat;
%     % plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'HandleVisibility', 'off');
%     legend('show','Box','off');
%     hold off;
%     colormap(gca, parula(7));
%     caxis([0 0.7]);
%     cb1 = colorbar('Location','eastoutside');
%     ylabel(cb1, 'Velocity [m/s]', 'FontWeight', 'bold');
%     ylabel('Elevation NAP [m]', 'FontSize', 22, 'FontWeight', 'bold');
%     xlabel('Time', 'FontSize', 22, 'FontWeight', 'bold');
%     ylim([min(depth)-0.2 max(depth)+0.2]);
%     ax1 = gca; ax1.FontSize = 14; ax1.TickLabelInterpreter = 'none';
% 
%     subplot(1,2,2);
%     hold on;
%     pc2 = pcolor(time, depth(2:end), vel_dir(:,2:end).', 'HandleVisibility', 'off');
%     set(pc2, 'EdgeColor', 'none');
%     shading flat;
%     % plot(time, waterLevelT0, 'Color', colorBlue, 'LineWidth', 2, 'DisplayName', 'Water Level');
%     legend('show','Box','off');
%     hold off;
%     colormap(gca, hsv);
%     caxis([0 360]);
% 
%     % --- Circular hue wheel instead of a linear colorbar ---
%     pos2 = ax2.Position;                     % [left bottom width height], normalized figure units
%     wheelSize = 0.11;                        % adjust to taste
%     wheelPos = [pos2(1)+pos2(3)+0.005, pos2(2)+pos2(4)/2-wheelSize/2, wheelSize, wheelSize];
%     drawDirectionWheel(wheelPos);
%     % cb2 = colorbar('Location','eastoutside');
%     % cb2.Ticks = 0:45:360;
% 
%     ylabel(cb2, 'Flow Direction [\circ]', 'FontWeight', 'bold');
%     xlabel('Time', 'FontSize', 22, 'FontWeight', 'bold');
%     ylim([min(depth)-0.2 max(depth)+0.2]);
%     ax2 = gca; ax2.FontSize = 14; ax2.TickLabelInterpreter = 'none';
% 
%     % set(fig, 'PaperPositionMode', 'auto');
%     % print(fig, pngName, '-dpng', '-r300');
%     % close(fig);
% end

%% ============ HELPER: DRAW CIRCULAR HSV DIRECTION WHEEL ============
function drawDirectionWheel(pos)
    % pos = [left bottom width height] in normalized FIGURE units.
    % Draws a ring colored by hsv, with 0 deg (compass North) at the top
    % and angle increasing clockwise, matching typical flow-direction convention.

    axWheel = axes('Position', pos);

    dirDeg = linspace(0, 360, 361);         % compass direction, matches caxis([0 360]) on main plot
    mathRad = deg2rad(90 - dirDeg);         % convert compass angle -> standard math angle for plotting

    rInner = 0;
    rOuter = 1.5;
    [Th, R] = meshgrid(mathRad, [rInner rOuter]);
    X = R .* cos(Th);
    Y = R .* sin(Th);
    C = repmat(dirDeg, 2, 1);               % color driven by compass direction, not plotting angle

    pcolor(axWheel, X, Y, C);
    shading(axWheel, 'flat');
    colormap(axWheel, hsv);
    caxis(axWheel, [0 360]);
    axis(axWheel, 'equal', 'off');
    hold(axWheel, 'on');

    % Cardinal direction labels
    labelR = rOuter + 0.8;
    dirs = {'N','E','S','W'};
    angs = [0 90 180 270];   % compass degrees
    for k = 1:4
        a = deg2rad(90 - angs(k));
        text(axWheel, labelR*cos(a), labelR*sin(a), dirs{k}, ...
             'HorizontalAlignment','center','VerticalAlignment','middle', ...
             'FontWeight','bold','FontSize',12);
    end

    lim = (labelR + 0.15);
    xlim(axWheel, [-lim lim]);
    ylim(axWheel, [-lim lim]);
    hold(axWheel, 'off');
end

%% comparing WL on tidal flat
figure;
hold on;

wl_T0 = ADCP.BATH.T0.MP0403.WaterLevel_not_corrected_at_all(end,:);
wl_T1 = ADCP.BATH.T1.MP0403.WaterLevel_not_corrected_at_all(end,:);

wlReal_T0 = ADCP.BATH.T0.MP0403.WL_from_external_source(end,:);
wlReal_T1 = ADCP.BATH.T1.MP0403.WL_from_external_source(end,:);

% plot(wl_T0, 'YDataSource', 'wl_T0', 'DisplayName', 'T0');
plot(wl_T1, 'YDataSource', 'wl_T1', 'DisplayName', 'T1');
% plot(wlReal_T0, 'YDataSource', 'wlReal_T0', 'DisplayName', 'Real T0');
plot(wlReal_T1, 'YDataSource', 'wlReal_T1', 'DisplayName', 'Real T1');

linkdata on;
ylabel('WaterLevel');
title('ADCP.BATH.MP0403.Water Level', 'Interpreter', 'none');
legend('show');

%% ---- 1. Load / align data ----
wl = ADCP.BATH.T1.MP0403.WL_from_external_source(end,:);
wl = wl(:);                     % force column vector
t  = (0:numel(wl)-1)' ;         % replace with real datetime vector if available
% t = ADCP.BATH.T0.MP0403.Time;  % <-- use this if you have timestamps

fs_min = 10;                    % sample interval in minutes (EDIT to your actual rate)
dt_days = fs_min/60/24;

%% ---- 2. Basic level statistics ----
MWL   = mean(wl,'omitnan');     % Mean Water Level
HWL   = max(wl);                % Highest recorded water level
LWL   = min(wl);                % Lowest recorded water level

fprintf('Mean Water Level (MWL): %.2f\n', MWL);
fprintf('Max recorded level:     %.2f\n', HWL);
fprintf('Min recorded level:     %.2f\n', LWL);

%% ---- 3. Detect individual high and low tides ----
minSep_samples = round((6*60)/fs_min);   % ~6 hr min separation between successive HW/LW

[hwVals, hwLoc] = findpeaks(wl,  'MinPeakDistance', minSep_samples);
[lwVals, lwLoc] = findpeaks(-wl, 'MinPeakDistance', minSep_samples);
lwVals = -lwVals;

figure; hold on;
plot(t, wl, 'k');
plot(t(hwLoc), hwVals, 'r^', 'DisplayName','High Water');
plot(t(lwLoc), lwVals, 'bv', 'DisplayName','Low Water');
yline(MWL,'--','MWL');
legend show;
title('Detected High/Low Waters', 'Interpreter','none');

%% ---- 4. Pair consecutive HW/LW to get individual tidal ranges ----
% Merge and sort all extrema chronologically
ext_loc = [hwLoc; lwLoc];
ext_val = [hwVals; lwVals];
ext_type = [ones(size(hwLoc)); -ones(size(lwLoc))];  % 1=HW, -1=LW
[ext_loc, sortIdx] = sort(ext_loc);
ext_val  = ext_val(sortIdx);
ext_type = ext_type(sortIdx);

ranges = [];
rangeTimes = [];
for k = 1:numel(ext_loc)-1
    if ext_type(k) ~= ext_type(k+1)   % alternating HW-LW or LW-HW pair
        ranges(end+1,1)     = abs(ext_val(k+1) - ext_val(k)); 
        rangeTimes(end+1,1) = mean([t(ext_loc(k)) t(ext_loc(k+1))]); 
    end
end

MeanTidalRange = mean(ranges,'omitnan');
fprintf('Mean Tidal Range: %.2f\n', MeanTidalRange);

%% ---- 5. Spring / Neap range via envelope over spring-neap cycle (~14.77 days) ----
% Smooth the range series with a running max/min over one spring-neap cycle
cyc_days = 14.77;
win_pts  = max(3, round(cyc_days ./ (mean(diff(rangeTimes)))));  % window in # of tidal cycles

SpringRange = mean(maxk(ranges, max(3,round(numel(ranges)*0.1)))); % top ~10% of ranges
NeapRange   = mean(mink(ranges, max(3,round(numel(ranges)*0.1)))); % bottom ~10% of ranges

fprintf('Spring Tide Range (approx): %.2f\n', SpringRange);
fprintf('Neap Tide Range (approx):   %.2f\n', NeapRange);

figure; hold on;
plot(rangeTimes, ranges, '-o');
yline(SpringRange,'r--','Spring');
yline(NeapRange,'b--','Neap');
yline(MeanTidalRange,'k:','Mean');
ylabel('Tidal Range'); title('Individual Tidal Ranges Over Time','Interpreter','none');

%% ---- 6. Datum levels commonly used in coastal engineering ----
MHW  = mean(hwVals,'omitnan');   % Mean High Water
MLW  = mean(lwVals,'omitnan');   % Mean Low Water
MHWS = mean(maxk(hwVals, round(numel(hwVals)*0.1))); % Mean High Water Springs
MLWS = mean(mink(lwVals, round(numel(lwVals)*0.1))); % Mean Low Water Springs
MHWN = mean(mink(hwVals, round(numel(hwVals)*0.1))); % Mean High Water Neaps (lower highs = neap)
MLWN = mean(maxk(lwVals, round(numel(lwVals)*0.1))); % Mean Low Water Neaps  (higher lows = neap)

fprintf('\n--- Datum Summary ---\n');
fprintf('MHWS: %.2f | MHW: %.2f | MHWN: %.32\n', MHWS, MHW, MHWN);
fprintf('MWL:  %.2f\n', MWL);
fprintf('MLWN: %.2f | MLW: %.2f | MLWS: %.32\n', MLWN, MLW, MLWS);

%% ---- 7. Tidal range classification (Davies, 1964) ----
if MeanTidalRange < 2
    tideClass = 'Microtidal';
elseif MeanTidalRange <= 4
    tideClass = 'Mesotidal';
else
    tideClass = 'Macrotidal';
end
fprintf('\nTidal Range Classification: %s\n', tideClass);

%% ---- 1. Load / align data for both sources ----
wl_T0 = ADCP.BATH.T0.MP0902.WL_from_external_source(end,:); wl_T0 = wl_T0(:);
wl_T1 = ADCP.BATH.T1.MP0902.WL_from_external_source(end,:); wl_T1 = wl_T1(:);

n = min(numel(wl_T0), numel(wl_T1));   % guard against length mismatch
wl_T0 = wl_T0(1:n);
wl_T1 = wl_T1(1:n);

t = (0:n-1)';                    % replace with real datetime vector if available
% t = ADCP.BATH.T0.MP0403.Time;  % <-- use this if you have timestamps

fs_min  = 10;                    % sample interval in minutes (EDIT to your actual rate)
minSep_samples = round((6*60)/fs_min);   % ~6 hr min separation between successive HW/LW

sources = struct('name', {'T0','T1'}, 'wl', {wl_T0, wl_T1});
results = struct();

%% ---- 2. Compute parametrics for each source ----
for i = 1:numel(sources)
    name = sources(i).name;
    wl   = sources(i).wl;

    % --- basic level stats ---
    MWL = mean(wl,'omitnan');
    HWL = max(wl);
    LWL = min(wl);

    % --- detect high/low waters ---
    [hwVals, hwLoc] = findpeaks(wl,  'MinPeakDistance', minSep_samples);
    [lwVals, lwLoc] = findpeaks(-wl, 'MinPeakDistance', minSep_samples);
    lwVals = -lwVals;

    % --- pair consecutive extrema to get individual tidal ranges ---
    ext_loc  = [hwLoc; lwLoc];
    ext_val  = [hwVals; lwVals];
    ext_type = [ones(size(hwLoc)); -ones(size(lwLoc))];
    [ext_loc, sortIdx] = sort(ext_loc);
    ext_val  = ext_val(sortIdx);
    ext_type = ext_type(sortIdx);

    ranges = []; rangeTimes = [];
    for k = 1:numel(ext_loc)-1
        if ext_type(k) ~= ext_type(k+1)
            ranges(end+1,1)     = abs(ext_val(k+1) - ext_val(k)); %#ok<AGROW>
            rangeTimes(end+1,1) = mean([t(ext_loc(k)) t(ext_loc(k+1))]); %#ok<AGROW>
        end
    end

    MeanTidalRange = mean(ranges,'omitnan');
    SpringRange = mean(maxk(ranges, max(3,round(numel(ranges)*0.1))));
    NeapRange   = mean(mink(ranges, max(3,round(numel(ranges)*0.1))));

    % --- datum levels ---
    MHW  = mean(hwVals,'omitnan');
    MLW  = mean(lwVals,'omitnan');
    MHWS = mean(maxk(hwVals, round(numel(hwVals)*0.1)));
    MLWS = mean(mink(lwVals, round(numel(lwVals)*0.1)));
    MHWN = mean(mink(hwVals, round(numel(hwVals)*0.1)));
    MLWN = mean(maxk(lwVals, round(numel(lwVals)*0.1)));

    % --- Davies (1964) classification (using spring range) ---
    if SpringRange < 2
        tideClass = 'Microtidal';
    elseif SpringRange <= 4
        tideClass = 'Mesotidal';
    else
        tideClass = 'Macrotidal';
    end

    % --- store ---
    results.(name) = struct( ...
        'MWL', MWL, 'HWL', HWL, 'LWL', LWL, ...
        'hwVals', hwVals, 'hwLoc', hwLoc, ...
        'lwVals', lwVals, 'lwLoc', lwLoc, ...
        'ranges', ranges, 'rangeTimes', rangeTimes, ...
        'MeanTidalRange', MeanTidalRange, ...
        'SpringRange', SpringRange, 'NeapRange', NeapRange, ...
        'MHW', MHW, 'MLW', MLW, ...
        'MHWS', MHWS, 'MLWS', MLWS, ...
        'MHWN', MHWN, 'MLWN', MLWN, ...
        'tideClass', tideClass);
end

%% ---- 3. Print side-by-side comparison table ----
fprintf('\n%-18s %12s %12s %12s\n', 'Parameter', 'T0', 'T1', 'Diff (T1-T0)');
fields = {'MWL','HWL','LWL','MeanTidalRange','SpringRange','NeapRange', ...
          'MHWS','MHW','MHWN','MLWN','MLW','MLWS'};
for f = 1:numel(fields)
    v0 = results.T0.(fields{f});
    v1 = results.T1.(fields{f});
    fprintf('%-18s %12.3f %12.3f %12.3f\n', fields{f}, v0, v1, v1-v0);
end
fprintf('%-18s %12s %12s\n', 'Tide Class', results.T0.tideClass, results.T1.tideClass);

%% ---- 4. Overlay plot of raw time series ----
figure; hold on;
plot(t, wl_T0, 'DisplayName', 'T0');
plot(t, wl_T1, 'DisplayName', 'T1');
yline(results.T0.MWL, '--', 'MWL T0', 'Color', [0 0.4 1]);
yline(results.T1.MWL, '--', 'MWL T1', 'Color', [1 0.4 0]);
ylabel('WaterLevel');
title('T0 vs T1 - WL from external source', 'Interpreter', 'none');
legend('show');

%% ---- 5. Overlay plot of tidal range time series ----
figure; hold on;
plot(results.T0.rangeTimes, results.T0.ranges, '-o', 'DisplayName', 'T0 Range');
plot(results.T1.rangeTimes, results.T1.ranges, '-o', 'DisplayName', 'T1 Range');
yline(results.T0.SpringRange, '--', 'Spring T0', 'Color', [0 0.4 1]);
yline(results.T1.SpringRange, '--', 'Spring T1', 'Color', [1 0.4 0]);
yline(results.T0.NeapRange, ':', 'Neap T0', 'Color', [0 0.4 1]);
yline(results.T1.NeapRange, ':', 'Neap T1', 'Color', [1 0.4 0]);
ylabel('Tidal Range');
title('Individual Tidal Ranges: T0 vs T1', 'Interpreter', 'none');
legend('show');

%% ---- 6. Overlay plot of detected HW/LW markers per source ----
figure;
subplot(2,1,1); hold on;
plot(t, wl_T0, 'k');
plot(t(results.T0.hwLoc), results.T0.hwVals, 'r^', 'DisplayName','High Water');
plot(t(results.T0.lwLoc), results.T0.lwVals, 'bv', 'DisplayName','Low Water');
title('T0: Detected High/Low Waters', 'Interpreter','none'); legend show;

subplot(2,1,2); hold on;
plot(t, wl_T1, 'k');
plot(t(results.T1.hwLoc), results.T1.hwVals, 'r^', 'DisplayName','High Water');
plot(t(results.T1.lwLoc), results.T1.lwVals, 'bv', 'DisplayName','Low Water');
title('T1: Detected High/Low Waters', 'Interpreter','none'); legend show;