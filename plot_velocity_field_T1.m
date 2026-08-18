close all
clear all
clc

%plot velocity fields of 
% T0 (calibration) 
% T1 (validation)
% T1 bathymetry with T0 groynes

%% import KMLs for strekdammen and plot them
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Bath_buitendijks_polygoon.kml');
[POL_x.BATH,POL_y.BATH] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);

KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Zimmerman_buitendijks_polygoon3.kml');
[POL_x.ZIM,POL_y.ZIM] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);

KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\7_1_2026\Nieuw.kml');
for ki = 1:length(KML)
    [Nieuw_x{ki},Nieuw_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\7_1_2026\Aangepast.kml');
for ki = 1:length(KML)
    [Aangepast_x{ki},Aangepast_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\7_1_2026\Bestaand.kml');
for ki = 1:length(KML)
    [Bestaand_x{ki},Bestaand_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

Opgehoogd_x{1} = [];
Opgehoogd_y{1} = [];

% Plot all imported polygons on current figure/axes
hold on;
hPol = [];
% plot boundaries
if isfield(POL_x,'BATH') && ~isempty(POL_x.BATH)
    hPol(end+1) = plot(POL_x.BATH, POL_y.BATH, 'k-', 'LineWidth', 1.5); %#ok<SAGROW>
end
if isfield(POL_x,'ZIM') && ~isempty(POL_x.ZIM)
    hPol(end+1) = plot(POL_x.ZIM, POL_y.ZIM, 'm-', 'LineWidth', 1.5); %#ok<SAGROW>
end

% plot Nieuw, Aangepast, Bestaand (cell arrays of polygons)
for k = 1:numel(Nieuw_x)
    if ~isempty(Nieuw_x{k})
        hPol(end+1) = plot(Nieuw_x{k}, Nieuw_y{k}, 'b-', 'LineWidth', 1); %#ok<SAGROW>
    end
end
for k = 1:numel(Aangepast_x)
    if ~isempty(Aangepast_x{k})
        hPol(end+1) = plot(Aangepast_x{k}, Aangepast_y{k}, 'g--', 'LineWidth', 1); %#ok<SAGROW>
    end
end
for k = 1:numel(Bestaand_x)
    if ~isempty(Bestaand_x{k})
        hPol(end+1) = plot(Bestaand_x{k}, Bestaand_y{k}, 'r-.', 'LineWidth', 1); %#ok<SAGROW>
    end
end

% optionally add legend and formatting if any handles were created
if ~isempty(hPol)
    legendEntries = {};
    if exist('POL_x','var') && isfield(POL_x,'BATH'); legendEntries{end+1} = 'Bath boundary'; end
    if exist('POL_x','var') && isfield(POL_x,'ZIM');  legendEntries{end+1} = 'Zimmerman boundary'; end
    if exist('Nieuw_x','var') && any(cellfun(@(c)~isempty(c), Nieuw_x)); legendEntries{end+1} = 'Nieuw'; end
    if exist('Aangepast_x','var') && any(cellfun(@(c)~isempty(c), Aangepast_x)); legendEntries{end+1} = 'Aangepast'; end
    if exist('Bestaand_x','var') && any(cellfun(@(c)~isempty(c), Bestaand_x)); legendEntries{end+1} = 'Bestaand'; end
    legend(hPol, legendEntries, 'Location', 'bestoutside');
end
axis equal;
hold off;
%% import models
% folders = { ...
%     'P:\11207654-internship-pierce-2026\03_Model\8_T0bathy_T0groynes_manning_transition\output\' , ...
%     'P:\11207654-internship-pierce-2026\03_Model\9_T1bathy_T1_groynes\output\', ...
%     'P:\11207654-internship-pierce-2026\03_Model\10_T1bathy_T0groynes\output\'
% };
% 
% % Names for the titles (Viscosity values) & save to mat files
% names = {'T0', 'T1', 'bathyT1groynesT0'};
% 
% % load model data for velocity field (velocities and gridinfo)
% % D. Pierce
% 
% for i = 1:length(folders)
%     ncFile = fullfile(folders{i}, 'WS_0000_map.nc');
% 
%     % choose date range depending on i
%     if i == 1
%         t0 = '23-Nov-2018';
%         tend = '24-Nov-2018';
%     else
%         t0 = '20-Feb-2018';
%         tend = '21-Feb-2018';
%     end
% 
%     % read map/model data and grid info for this folder
%     DataXY{i} = EHY_getMapModelData(ncFile, 'varName', 'mesh2d_ucxa', 't0', t0, 'tend', tend, 'layer', '0');
%     % obtain gridInfo for this folder (use a single struct, not a cell array, to avoid brace-indexing errors later)
%     if i == 1
%         gridInfo = EHY_getGridInfo(ncFile, 'face_nodes_xy');
%         else
%     end 
% 
%     % save per-run DataXY using descriptive names array
%     % construct variable name safe for filenames from viscosity value
%     nameVal = names(i);
%     if isnumeric(nameVal)
%         nameStr = sprintf('%g', names);
%         nameStr = strrep(nameStr, '.', 'p'); % replace dot with 'p' for filenames
%     else
%         nameStr = matlab.lang.makeValidName(char(nameVal));
%     end
%     % save DataXY and gridInfo for this folder using the constructed name
%     outName = fullfile(pwd, ['velField_' nameStr '.mat']);
%     DataX = DataXY{i}; 
%     save(outName, 'DataX', 'gridInfo');
% end

%% load .mat
% load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\velField_feb2018.mat');

T0 = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\model_mat_files\velField_T0.mat');
T1 = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\model_mat_files\velField_T1.mat');
T1_nogroynes = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\model_mat_files\velField_bathyT1groynesT0.mat');

velData = {T0, T1, T1_nogroynes};

%% time
% convert datenums in DataX.times to strings 'dd-mm-yyyy HH-MM'
% build a cell array 'time' of formatted time strings from velData entries
time = cell(length(velData),1);
for i = 1:length(velData)
    % each velData{i} contains a struct with DataX; accept numeric datenums or convertible values
    if isfield(velData{i}, 'DataX') && isfield(velData{i}.DataX, 'times')
        timesVal = velData{i}.DataX.times;
        if isnumeric(timesVal)
            time{i} = datestr(timesVal, 'dd-mm-yyyy');
        else
            % try converting non-numeric times to datenums first
            try
                dn = datenum(timesVal);
                time{i} = datestr(dn, 'dd-mm-yyyy');
            catch
                error('velData{%d}.DataX.times must be numeric datenums or convertible to datenums.', i);
            end
        end
    else
        error('velData{%d} does not contain DataX.times.', i);
    end
end
% if a single combined time array is desired (e.g., from the first dataset), convert to char array
if ~isempty(time)
    time = char(time{1});
end

% else
%     % try to convert non-numeric times (e.g., cell array of strings) to datenum first
%     try
%         dn = datenum(DataX.times);
%         time = datestr(dn, 'dd-mm-yyyy HH-MM');
%     catch
%         error('DataX.times must be numeric datenums or convertible to datenums.');
%     end
% end

% %% grid nodes to match velocity
%     % compute cell centers from the 4 face node coordinates (assumes NaN-free quads)
% for i = 1:length(velData)
%     % obtain DataX and gridInfo for this run (allow velData entries to be structs containing DataX and gridInfo)
%     if isfield(velData{i}, 'DataX')
%         DataX_run = velData{i}.DataX;
%     elseif isfield(velData{i}, 'DataX') % redundant check kept minimal for clarity
%         DataX_run = velData{i}.DataX;
%     else
%         error('velData{%d} does not contain DataX.', i);
%     end
%     % gridInfo is expected from the earlier loaded gridInfo (same for all runs) or inside velData
%     if isfield(velData{i}, 'gridInfo')
%         gridInfo_run = velData{i}.gridInfo;
%     else
%         gridInfo_run = gridInfo; % fallback to outer gridInfo
%     end
% 
%     % compute cell centers from face node coordinates
%     if size(gridInfo_run.face_nodes_x,1) == 4
%         cx = mean(gridInfo_run.face_nodes_x,1);
%         cy = mean(gridInfo_run.face_nodes_y,1);
%     else
%         cx = mean(gridInfo_run.face_nodes_x,2).';
%         cy = mean(gridInfo_run.face_nodes_y,2).';
%     end
% 
%     % choose a timestep (ensure within range)
%     t = 2;
%     if t > size(DataX_run.vel_x,1)
%         error('Requested timestep t=%d exceeds available timesteps for velData{%d}.', t, i);
%     end
% 
%     % extract and shape velocities
%     u = DataX_run.vel_x(t,:);
%     v = DataX_run.vel_y(t,:);
%     if numel(u) ~= numel(cx); u = reshape(u,1,[]); end
%     if numel(v) ~= numel(cx); v = reshape(v,1,[]); end
% 
%     % calculate speed
%     speed = sqrt(u.^2 + v.^2);
% 
%     figure;
%     if size(gridInfo_run.face_nodes_x,1) == 4
%         patch(gridInfo_run.face_nodes_x, gridInfo_run.face_nodes_y, speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat');
%     else
%         patch(gridInfo_run.face_nodes_x', gridInfo_run.face_nodes_y', speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat');
%     end
%     hold on;
% 
%     % plot strekdammen + aangepast
%     %    for k = 1:numel(Nieuw_x)
%     %     if ~isempty(Nieuw_x{k})
%     %         hPol(end+1) = plot(Nieuw_x{k}, Nieuw_y{k}, 'b-', 'LineWidth', 1); %#ok<SAGROW>
%     %     end
%     % end
%     for k = 1:numel(Aangepast_x)
%         if ~isempty(Aangepast_x{k})
%             hPol(end+1) = plot(Aangepast_x{k}, Aangepast_y{k}, 'r-', 'LineWidth', 3); %#ok<SAGROW>
%         end
%     end
%     for k = 1:numel(Bestaand_x)
%         if ~isempty(Bestaand_x{k})
%             hPol(end+1) = plot(Bestaand_x{k}, Bestaand_y{k}, 'r--', 'LineWidth', 3); %#ok<SAGROW>
%         end
%     end
% 
%     % % optionally add legend and formatting if any handles were created
%     % if ~isempty(hPol)
%     %     legendEntries = {};
%     %     if exist('Nieuw_x','var') && any(cellfun(@(c)~isempty(c), Nieuw_x)); legendEntries{end+1} = 'Nieuw'; end
%     %     if exist('Aangepast_x','var') && any(cellfun(@(c)~isempty(c), Aangepast_x)); legendEntries{end+1} = 'Aangepast'; end
%     %     if exist('Bestaand_x','var') && any(cellfun(@(c)~isempty(c), Bestaand_x)); legendEntries{end+1} = 'Bestaand'; end
%     %     legend(hPol, legendEntries, 'Location', 'bestoutside');
%     % end
% 
%     % arrows: subsample for clarity
%     nVectors = numel(cx);
%     maxArrows = 1000;
%     if nVectors > maxArrows
%         idx = round(linspace(1, nVectors, maxArrows));
%     else
%         idx = 1:nVectors;
%     end
% 
%     % scale vectors for display (guard against zero mean)
%     denom = sqrt(nanmean(u(idx).^2) + nanmean(v(idx).^2));
%     if denom == 0
%         vecScale = 1;
%     else
%         ax = gca;
%         % approximate axis width in data units
%         originalUnits = get(ax, 'Units'); set(ax, 'Units', 'normalized');
%         axPos = get(ax, 'Position'); set(ax, 'Units', originalUnits);
%         axWidth = axPos(3);
%         vecScale = 0.1 * mean(diff(xlim)) / denom / 50;
%     end
% 
%     x0 = cx(idx); y0 = cy(idx);
%     dx = u(idx) * vecScale; dy = v(idx) * vecScale;
%     quiver(x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.2, 'MaxHeadSize', 0.2);
% 
%     xlim([63600 72900]);
%     ylim([378900 380900]);
%     xlabel('X Coordinate');
%     ylabel('Y Coordinate');
% 
%     % title uses names array if available, else use run index
%     if exist('names', 'var') && numel(names) >= i
%         nameVal = names(i);
%         if isnumeric(nameVal)
%             nameStr = sprintf('visc_%g', nameVal);
%             nameStr = strrep(nameStr, '.', 'p');
%         else
%             nameStr = matlab.lang.makeValidName(char(nameVal));
%         end
%         title(sprintf('Run %d (%s) - Velocity Magnitude %s', i, nameStr, time(t,:)));
%     else
%         title(sprintf('Run %d - Velocity Magnitude %s', i, time(t,:)));
%     end
% 
%     hold off;
% end

%% plot 3 different models
nRows = 2;
nCols = 2;
nRuns = min(numel(velData), 3); % Maximum of 3 models will plot

% Create clean layout grid
fig = figure();
t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Setup clean figure scale
fig.Units = 'centimeters';
fig.Position(3:4) = [24 20]; % Width x Height optimized for 2x2 presentation

% Big Title Setup (Forced safely on the figure parent layout)
title(t, 'Velocity Field Overviews', 'FontSize', 24, 'FontWeight', 'bold');

for i = 1:nRuns
    S = velData{i};
    tix = 18; % Evaluation timestep
    
    % Extract arrays safely
    if iscell(velData)
        DataX_run = velData{i}.DataX;
        if isfield(velData{i}, 'gridInfo')
            gridInfo_run = velData{i}.gridInfo;
        else
            gridInfo_run = gridInfo;
        end
    else
        DataX_run = DataX;
        gridInfo_run = gridInfo;
    end
    
    % Compute hydro-mesh cell center geometry
    if size(gridInfo_run.face_nodes_x,1) == 4
        cx_run = mean(gridInfo_run.face_nodes_x,1);
        cy_run = mean(gridInfo_run.face_nodes_y,1);
    else
        cx_run = mean(gridInfo_run.face_nodes_x,2).';
        cy_run = mean(gridInfo_run.face_nodes_y,2).';
    end
    
    if tix > size(DataX_run.vel_x,1)
        error('Requested timestep t=%d exceeds data limits for run %d.', tix, i);
    end
    
    u = DataX_run.vel_x(tix,:);
    v = DataX_run.vel_y(tix,:);
    if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
    if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
    speed = sqrt(u.^2 + v.^2);
    
    % Subplot allocation
    ax = nexttile; 
    hold(ax, 'on');
    
    % Render Delft3D Flexible Mesh cells using patches
    if size(gridInfo_run.face_nodes_x,1) == 4
        patch(gridInfo_run.face_nodes_x, gridInfo_run.face_nodes_y, speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
    else
        patch(gridInfo_run.face_nodes_x', gridInfo_run.face_nodes_y', speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
    end
    
   

    % ---plot strekdammen nieuw + aangepast + bestaand--- (only for i == 2)
    if i == 2
        for k = 1:numel(Nieuw_x)
            if ~isempty(Nieuw_x{k})
                hPol(end+1) = plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 4); %#ok<SAGROW>
            end
        end
        hPol(3) = plot(ax, nan, nan, 'k-', 'LineWidth', 2); % placeholder for legend
    end
    
    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
        hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, 'r--','LineWidth', 4); %#ok<SAGROW>
        end
    end
    hPol(1) = plot(nan, nan, 'r--', 'LineWidth', 2); % to use in

    for ki = 1:numel(Bestaand_x)
        if ~isempty(Bestaand_x{ki})
        hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 4); %#ok<SAGROW>
        end
    end
    hPol(2) = hLine2;

    % Plot structures overlay
    % hLine2 = [];
    % if i == 2
    %     for ki = 1:numel(Bestaand_x)
    %         if ~isempty(Bestaand_x{ki})
    %             hLine2 = plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 3); 
    %         end
    %     end
    % end
    
    % Vector Field Optimization (Vectorized direction plotting)
    nVectors = numel(cx_run);
    maxArrows = 4000; % Reduced down from 8000 to prevent layout cluttering
    if nVectors > maxArrows
        idx = round(linspace(1, nVectors, maxArrows));
    else
        idx = 1:nVectors;
    end
    
    ux = u(idx); uy = v(idx);
    mag = hypot(ux, uy);
    zeroMask = mag == 0;
    mag(zeroMask) = 1; 
    
    % Normalized vector length translation
    dx = (ux ./ mag) * 100; 
    dy = (uy ./ mag) * 100; 
    
    x0 = cx_run(idx); y0 = cy_run(idx);
    quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.5);
    
    %========= Map geographic viewport=========
    % %Bath
    % xlim(ax, [69600 72900]);
    % ylim(ax, [378900 380600]);

    % %Bath ZOOM
    % xlim(ax, [70500 72000]);
    % ylim(ax, [379300 380600]);
    
    % Set geographic viewport (use real-world units and keep aspect ratio)
    % Zimm
    xlim(ax, [64300 67200]);   % RDx in meters
    ylim(ax, [379300 380900]); % RDy in meters
   
    % %Zimm Zoom
    % xlim(ax, [65200 67600]);
    % ylim(ax, [379300 380400]);
    
    % Format Axes labels into uniform Kilometers units
    xlabel(ax, 'RDx (km)', 'FontSize', 14);
    ylabel(ax, 'RDy (km)', 'FontSize', 14);
    
     % Ensure axis uses equal scaling so distances in x/y are true (preserves aspect)
    daspect(ax, [1 1 1]);

    % Convert axis tick labels from meters to kilometers for readability,
    % but keep tick positions in meters so geometry remains accurate.
    xl = xlim(ax); yl = ylim(ax);
    xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
    yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
    xk = (xk_min : 1.0 : xk_max);            
    yk = (yk_min : 0.5 : yk_max);            
    set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
    set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
           'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));

    % Title handling per sub-panel
    if exist('names','var') && numel(names) >= i
        nameStr = char(names(i));
    else
        nameStr = sprintf('Model Variant %d', i);
    end
    title(ax, nameStr, 'FontSize', 16, 'FontWeight', 'bold');
    
    % Enforce local colorbar scaling boundaries uniformly
    clim(ax, [0 1]); 
    hold(ax, 'off');
end  

% ========================================================
% COMPONENT ROUTING TO EMPTY TILE 4 (Legend & Colorbar)
% ========================================================
axLeg = nexttile(t, 4); % Jump to remaining open grid tile
axis(axLeg, 'off');
hold(axLeg, 'on');

% Populate dummy items onto hidden tile workspace for uniform display
dummy_EXGroyne = plot(axLeg, NaN, NaN, 'r-', 'LineWidth', 3, 'DisplayName', 'Existing Groynes');
% Ensure groyne line appears in legend by giving it a DisplayName (and visible handle)
hPol(3) = plot(axLeg, nan, nan, 'k-', 'LineWidth', 2, 'DisplayName', 'New Groyne');
dummyFlow   = quiver(axLeg, NaN, NaN, NaN, NaN, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.5, 'DisplayName', 'Flow Direction');

% Display global metadata components inside panel 4
lgd = legend(axLeg, [dummyGroyne, dummyFlow], 'Location', 'south', 'FontSize', 14);
set(lgd, 'Box', 'off');

% Append global domain Colorbar directly into the final block space
cb = colorbar(axLeg, 'Location', 'north');
cb.Label.String = 'Residual Velocity (m/s)';
cb.Label.FontSize = 14;
cb.FontSize = 12;
clim(axLeg, [0 1]);

    % %% --- export----
    % outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\viscosity\velocity_field';
    % fig = gcf;
    % filename = fullfile(outDir, 'vel_field_zimm');
    % % save as FIG and PNG for convenience, use high resolution for PNG
    % savefig(fig, [filename, '.fig']);
    % print(fig, [filename, '.png'], '-dpng', '-r300');



% %% export all open figures as PNGs with names based on their figure numbers and timestep (if available)
% outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\viscosity\velocity_field';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% 
% figHandles = findall(0, 'Type', 'figure');
% for f = 1:numel(figHandles)
%     fig = figHandles(f);
%     % try to find an axes and associated tix and time string
%     axChild = findobj(fig, 'Type', 'axes', '-not', 'Tag', 'legend');
%     if ~isempty(axChild)
%         axUse = axChild(1);
%     else
%         axUse = ancestor(fig, 'axes');
%     end
% 
%     % determine timestep string if variable tix and time exist in workspace
%     tStr = sprintf('fig%d', fig.Number);
%     if exist('tix','var') && exist('time','var')
%         try
%             ts = strtrim(time(tix,:));
%             ts = regexprep(ts, '[\s:]', '_');
%             tStr = sprintf('t%02d_%s', tix, ts);
%         catch
%             % fallback to figure number only
%             tStr = sprintf('fig%d', fig.Number);
%         end
%     end
% 
%     % build filename and export
%     fname = fullfile(outDir, sprintf('velocity_field_%s_fig%d.png', tStr, fig.Number));
%     try
%         exportgraphics(fig, fname, 'Resolution', 300);
%     catch
%         % fallback: saveas if exportgraphics fails
%         saveas(fig, fname);
%     end
% end

% %% plot 4 time steps of same model and use subplots
% % plot timesteps in a 2x2 subplot grid
% ts = 8:11;
% nT = numel(ts);
% nRows = 2; nCols = 2;
% 
% figure;
% for k = 1:nT
%     tix = ts(k);
%     % extract and shape velocities for this timestep
%     u = DataX.vel_x(tix,:);
%     v = DataX.vel_y(tix,:);
%     if numel(u) ~= numel(cx); u = reshape(u,1,[]); end
%     if numel(v) ~= numel(cx); v = reshape(v,1,[]); end
%     speed = sqrt(u.^2 + v.^2);
% 
%     ax = subplot(nRows, nCols, k);
%     if size(gridInfo.face_nodes_x,1) == 4
%         patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%     else
%         patch(gridInfo.face_nodes_x', gridInfo.face_nodes_y', speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%     end
%     hold(ax, 'on');
% 
%     % arrows: subsample for clarity
%     nVectors = numel(cx);
%     maxArrows = 600;
%     if nVectors > maxArrows
%         idx = round(linspace(1, nVectors, maxArrows));
%     else
%         idx = 1:nVectors;
%     end
%     % scale vectors consistently across subplots based on axis width
%     axUnits = get(ax, 'Units'); set(ax, 'Units', 'normalized');
%     axPos = get(ax, 'Position'); set(ax, 'Units', axUnits);
%     axWidth = axPos(3);
%     vecScale = 0.2 * mean(diff(xlim)) / sqrt(nanmean(u(idx).^2)+nanmean(v(idx).^2)) / 50;
% 
%     x0 = cx(idx); y0 = cy(idx);
%     dx = u(idx) * vecScale; dy = v(idx) * vecScale;
%     quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.2, 'MaxHeadSize', 0.2);
% 
%     xlim(ax, [63600 72900]);
%     ylim(ax, [378900 380900]);
%     xlabel(ax, 'X Coordinate');
%     ylabel(ax, 'Y Coordinate');
%     title(ax, sprintf('%s', time(tix,:)));
%     hold(ax, 'off');
% 
%     % add colorbar to first subplot only to avoid clutter
%     if k == 1
%         cb = colorbar(ax);
%         cb.Label.String = 'Speed';
%     end
% end