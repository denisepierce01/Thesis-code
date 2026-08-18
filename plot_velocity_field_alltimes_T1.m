close all
clear all
clc

%plot velocity fields and save as PNGs


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
    hPol(end+1) = plot(POL_x.BATH, POL_y.BATH, 'k-', 'LineWidth', 1.5);
end
if isfield(POL_x,'ZIM') && ~isempty(POL_x.ZIM)
    hPol(end+1) = plot(POL_x.ZIM, POL_y.ZIM, 'm-', 'LineWidth', 1.5);
end

% plot Nieuw, Aangepast, Bestaand (cell arrays of polygons)
for k = 1:numel(Nieuw_x)
    if ~isempty(Nieuw_x{k})
        hPol(end+1) = plot(Nieuw_x{k}, Nieuw_y{k}, 'b-', 'LineWidth', 1);
    end
end
for k = 1:numel(Aangepast_x)
    if ~isempty(Aangepast_x{k})
        hPol(end+1) = plot(Aangepast_x{k}, Aangepast_y{k}, 'g--', 'LineWidth', 1); 
    end
end
for k = 1:numel(Bestaand_x)
    if ~isempty(Bestaand_x{k})
        hPol(end+1) = plot(Bestaand_x{k}, Bestaand_y{k}, 'r-.', 'LineWidth', 1);
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
    if exist('flowfield_arrows','var') && ~isempty(flowfield_arrows); legendEntries{end+1} = 'Flowfield arrows'; end
    legend(hPol, legendEntries, 'Location', 'bestoutside');
end
axis equal;
hold off;

%% import models
folders = { ...
    % 'P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\' , ...
    'P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\output\',
    % 'P:\11207654-internship-pierce-2026\03_Model\14_T0bathy_T1groynes_Apr18\output\'...
};

% Names for the titles (Viscosity values) & save to mat files
names = { 'T0'};

% load model data for velocity field (velocities and gridinfo)
% D. Pierce

for i = 1:length(folders)
    ncFile = fullfile(folders{i}, 'WS_0000_map.nc');

    % choose date range depending on i
    if i == 1
        t0 = '9-May-2018 16:00:00';
        tend = '9-May-2018 17:00:00'; %to 01-Apr-2018 requires 2 hours to load outupt and is larger than 2 GB so cant be saved to mat file
    end

    % read map/model data and grid info for this folder
    DataXY{i} = EHY_getMapModelData(ncFile, 'varName', 'mesh2d_ucxa', 't0', t0, 'tend', tend, 'layer', '0');
    % Extract the timestamps directly if the companion variable exists
    TimeOfMax = EHY_getMapModelData("P:\11207654-internship-pierce-2026\03_Model\FOU model\16_T1_fou_Apr18\output\WS_0001_fou.nc",...
    'varName','mesh2d_fourier005_max_time','layer','0');

    % save per-run DataXY
    nameVal = names(i);
    if isnumeric(nameVal)
        nameStr = sprintf('%g', names);
        nameStr = strrep(nameStr, '.', 'p'); % replace dot with 'p' for filenames
    else
        nameStr = matlab.lang.makeValidName(char(nameVal));
    end
    % save DataXY and gridInfo for this folder using the constructed name
    outName = fullfile(pwd, ['T1_May10' nameStr '.mat']);
    velData = DataXY{i}; 
    save(outName, 'DataXY');
end

%% load .mat
load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\T0_dec23-26_T0.mat');               %T0
% load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\T1_May1T1.mat');    %T1
% T1_nogroynes = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\model_mat_files\velField_bathyT1groynesT0.mat');

% velData = {T0, T1, T1_nogroynes};
% velData = DataXY;

%% model WL from dfm
load("P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\output\DFM.mat")    % T0 Apr-May 2018
ModelData(1).DFM = DFM;
% load("P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\DFM.mat");         % T1 apr-may 2018
% ModelData(1).DFM = DFM ;

folders = { ...
    'T0'
    % 'T1'
    };

%% Extract time and WL (val) from each ModelData entry and plot (13 figures)
nModels = numel(ModelData);
for ii = 1:nModels
    figure;
    % Bath (index 15) and Wals (index 12)
    t_bath = ModelData(ii).DFM.wl(15).time; %BATH
    wl_bath = ModelData(ii).DFM.wl(15).val;
    % t_wals = ModelData(ii).DFM.wl(12).time; %WALS
    % wl_wals = ModelData(ii).DFM.wl(12).val;

    % datetime to datenum
    t_bath_num = datenum(t_bath);
    % t_wals_num = datenum(t_wals);

    %--- plot Bath WL ---
    figure()
    hold on
    plot(t_bath, wl_bath, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Model Water Level');
    xlabel('Time', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Water Level [m NAP]', 'FontSize', 16, 'FontWeight', 'bold');
    xlim([t_bath(1) t_bath(end)]);
end


%% time
% convert datenums in DataX.times to strings 'dd-mm-yyyy HH-MM'
time = cell(length(DataXY),1);
for i = 1:length(DataXY)
    if isempty(DataXY{i})
        time{i} = '';
        continue;
    end
    % obtain times from DataXY{i}; support either field DataX or direct struct
    if isfield(DataXY{i}, 'DataX')
        timesVal = DataXY{i}.DataX.times;
    elseif isfield(DataXY{i}, 'times')
        timesVal = DataXY{i}.times;
    else
        error('DataXY{%d} does not contain a ''times'' field.', i);
    end

    % convert numeric datenums or convertible values to datetime strings
    if isnumeric(timesVal)
        dt = datetime(timesVal, 'ConvertFrom', 'datenum');
        time_date{i} = cellstr(datestr(dt, 'dd-mm-yyyy HH-MM'));
    else
    end
end

%% bring in grid rom another mat file
FOU = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_Apr22-24_T0T1.mat"); %T0 and T1
% data1  = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\FOU_Apr22_T0wGroynes.mat'); % T0wGroynes
% timebelow = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\FOU_T0_T0wG_T1.mat'); %T0 and T0wGroynes and T1
% sigma_layers = [2 3 5 8 10 12 15 15 15 15];

for i = 1
    gridX = FOU.FOU(i).data.grid.face_nodes_x;
    gridY = FOU.FOU(i).data.grid.face_nodes_y;
end

% %% plot 3 different models
% nRows = 2;
% nCols = 2;
% nRuns = min(numel(velData), 3); % Maximum of 3 models will plot
% 
% % Create clean layout grid
% fig = figure();
% t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
% 
% % Setup clean figure scale
% fig.Units = 'centimeters';
% fig.Position(3:4) = [24 20]; % Width x Height optimized for 2x2 presentation
% 
% % Big Title Setup (Forced safely on the figure parent layout)
% title(t, 'Velocity Field Overviews', 'FontSize', 24, 'FontWeight', 'bold');
% 
% for i = 1:nRuns
%     tix = 18; % Evaluation timestep
% 
%     % Extract arrays safely
%     if iscell(velData)
%         DataX_run = velData{i}.DataX;
%         if isfield(velData{i}, 'gridInfo')
%             gridInfo_run = velData{i}.gridInfo;
%         else
%             gridInfo_run = gridInfo;
%         end
%     else
%         DataX_run = DataX;
%         gridInfo_run = gridInfo;
%     end
% 
%     % Compute hydro-mesh cell center geometry
%     if size(gridInfo_run.face_nodes_x,1) == 4
%         cx_run = mean(gridInfo_run.face_nodes_x,1);
%         cy_run = mean(gridInfo_run.face_nodes_y,1);
%     else
%         cx_run = mean(gridInfo_run.face_nodes_x,2).';
%         cy_run = mean(gridInfo_run.face_nodes_y,2).';
%     end
% 
%     if tix > size(DataX_run.vel_x,1)
%         error('Requested timestep t=%d exceeds data limits for run %d.', tix, i);
%     end
% 
%     u = DataX_run.vel_x(tix,:);
%     v = DataX_run.vel_y(tix,:);
%     if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
%     if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
%     speed = sqrt(u.^2 + v.^2);
% 
%     % Subplot allocation
%     ax = nexttile; 
%     hold(ax, 'on');
% 
%     % Render Delft3D Flexible Mesh cells using patches
%     if size(gridInfo_run.face_nodes_x,1) == 4
%         patch(gridInfo_run.face_nodes_x, gridInfo_run.face_nodes_y, speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%     else
%         patch(gridInfo_run.face_nodes_x', gridInfo_run.face_nodes_y', speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%     end
% 
% 
% 
%     % ---plot strekdammen nieuw + aangepast + bestaand--- (only for i == 2)
%     if i == 2
%         for k = 1:numel(Nieuw_x)
%             if ~isempty(Nieuw_x{k})
%                 hPol(end+1) = plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 4); %#ok<SAGROW>
%             end
%         end
%         hPol(3) = plot(ax, nan, nan, 'k-', 'LineWidth', 2); % placeholder for legend
%     end
% 
%     for ki = 1:numel(Aangepast_x)
%         if ~isempty(Aangepast_x{ki})
%         hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, 'r--','LineWidth', 4); %#ok<SAGROW>
%         end
%     end
%     hPol(1) = plot(nan, nan, 'r--', 'LineWidth', 2); % to use in
% 
%     for ki = 1:numel(Bestaand_x)
%         if ~isempty(Bestaand_x{ki})
%         hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 4); %#ok<SAGROW>
%         end
%     end
%     hPol(2) = hLine2;
% 
%     % Plot structures overlay
%     % hLine2 = [];
%     % if i == 2
%     %     for ki = 1:numel(Bestaand_x)
%     %         if ~isempty(Bestaand_x{ki})
%     %             hLine2 = plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 3); 
%     %         end
%     %     end
%     % end
% 
%     % Vector Field Optimization (Vectorized direction plotting)
%     nVectors = numel(cx_run);
%     maxArrows = 4000; % Reduced down from 8000 to prevent layout cluttering
%     if nVectors > maxArrows
%         idx = round(linspace(1, nVectors, maxArrows));
%     else
%         idx = 1:nVectors;
%     end
% 
%     ux = u(idx); uy = v(idx);
%     mag = hypot(ux, uy);
%     zeroMask = mag == 0;
%     mag(zeroMask) = 1; 
% 
%     % Normalized vector length translation
%     dx = (ux ./ mag) * 100; 
%     dy = (uy ./ mag) * 100; 
% 
%     x0 = cx_run(idx); y0 = cy_run(idx);
%     quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.5);
% 
%     %========= Map geographic viewport=========
%     % %Bath
%     % xlim(ax, [69600 72900]);
%     % ylim(ax, [378900 380600]);
% 
%     % %Bath ZOOM
%     % xlim(ax, [70500 72000]);
%     % ylim(ax, [379300 380600]);
% 
%     % Set geographic viewport (use real-world units and keep aspect ratio)
%     % Zimm
%     xlim(ax, [64300 67200]);   % RDx in meters
%     ylim(ax, [379300 380900]); % RDy in meters
% 
%     % %Zimm Zoom
%     % xlim(ax, [65200 67600]);
%     % ylim(ax, [379300 380400]);
% 
%     % Format Axes labels into uniform Kilometers units
%     xlabel(ax, 'RDx (km)', 'FontSize', 14);
%     ylabel(ax, 'RDy (km)', 'FontSize', 14);
% 
%      % Ensure axis uses equal scaling so distances in x/y are true (preserves aspect)
%     daspect(ax, [1 1 1]);
% 
%     % Convert axis tick labels from meters to kilometers for readability,
%     % but keep tick positions in meters so geometry remains accurate.
%     xl = xlim(ax); yl = ylim(ax);
%     xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
%     yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
%     xk = (xk_min : 1.0 : xk_max);            
%     yk = (yk_min : 0.5 : yk_max);            
%     set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
%     set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%            'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
% 
%     % Title handling per sub-panel
%     if exist('names','var') && numel(names) >= i
%         nameStr = char(names(i));
%     else
%         nameStr = sprintf('Model Variant %d', i);
%     end
%     title(ax, nameStr, 'FontSize', 16, 'FontWeight', 'bold');
% 
%     % Enforce local colorbar scaling boundaries uniformly
%     clim(ax, [0 1]); 
%     hold(ax, 'off');
% end  
% 
% % ========================================================
% % COMPONENT ROUTING TO EMPTY TILE 4 (Legend & Colorbar)
% % ========================================================
% axLeg = nexttile(t, 4); % Jump to remaining open grid tile
% axis(axLeg, 'off');
% hold(axLeg, 'on');
% 
% % Populate dummy items onto hidden tile workspace for uniform display
% dummy_EXGroyne = plot(axLeg, NaN, NaN, 'r-', 'LineWidth', 3, 'DisplayName', 'Existing Groynes');
% % Ensure groyne line appears in legend by giving it a DisplayName (and visible handle)
% hPol(3) = plot(axLeg, nan, nan, 'k-', 'LineWidth', 2, 'DisplayName', 'New Groyne');
% dummyFlow   = quiver(axLeg, NaN, NaN, NaN, NaN, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.5, 'DisplayName', 'Flow Direction');
% 
% % Display global metadata components inside panel 4
% lgd = legend(axLeg, [dummyGroyne, dummyFlow], 'Location', 'south', 'FontSize', 14);
% set(lgd, 'Box', 'off');
% 
% % Append global domain Colorbar directly into the final block space
% cb = colorbar(axLeg, 'Location', 'north');
% cb.Label.String = 'Residual Velocity (m/s)';
% cb.Label.FontSize = 14;
% cb.FontSize = 12;
% clim(axLeg, [0 1]);
% 
%     % %% --- export----
%     % outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\viscosity\velocity_field';
%     % fig = gcf;
%     % filename = fullfile(outDir, 'vel_field_zimm');
%     % % save as FIG and PNG for convenience, use high resolution for PNG
%     % savefig(fig, [filename, '.fig']);
%     % print(fig, [filename, '.png'], '-dpng', '-r300');
% 
% 

% %% plot all time steps of same model and use subplots
% nTimes = length(DataXY{1,1}.times);
% 
% for k = 1:nTimes
%     figure();
%     tix = k;
%     % Compute hydro-mesh cell center geometry
%     if size(gridInfo.face_nodes_x,1) == 4
%         cx_run = mean(gridInfo.face_nodes_x,1);
%         cy_run = mean(gridInfo.face_nodes_y,1);
%     else
%         cx_run = mean(gridInfo.face_nodes_x,2).';
%         cy_run = mean(gridInfo.face_nodes_y,2).';
%     end
% 
%     u = DataXY{k}.vel_x(tix,:);
%     v = DataXY{k}.vel_y(tix,:);
% 
%     if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
%     if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
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
%         % ---plot strekdammen nieuw + aangepast + bestaand--- (only for i == 2)
%     if i == 1
%         for k = 1:numel(Nieuw_x)
%             if ~isempty(Nieuw_x{k})
%                 hPol(end+1) = plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 4); %#ok<SAGROW>
%             end
%         end
%     end
%     hPol(3) = plot(ax, nan, nan, 'k-', 'LineWidth', 2); % placeholder for legend
% 
%     % for ki = 1:numel(Aangepast_x)
%     %     if ~isempty(Aangepast_x{ki})
%     %     hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, 'r--','LineWidth', 4); %#ok<SAGROW>
%     %     end
%     % end
%     % hPol(1) = plot(nan, nan, 'r--', 'LineWidth', 2); % to use in
% 
%     for ki = 1:numel(Bestaand_x)
%         if ~isempty(Bestaand_x{ki})
%         hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 4); %#ok<SAGROW>
%         end
%     end
%     hPol(2) = hLine2;
% 
%     % Plot structures overlay
%     % hLine2 = [];
%     % if i == 2
%     %     for ki = 1:numel(Bestaand_x)
%     %         if ~isempty(Bestaand_x{ki})
%     %             hLine2 = plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 3); 
%     %         end
%     %     end
%     % end
% 
% 
%     % Set geographic viewport
%     % Zimm
%     xlim(ax, [64300 67200]);   % RDx in meters
%     ylim(ax, [379300 380900]); % RDy in meters
% 
%     % arrows: subsample for clarity
%     nVectors = numel(cx_run);
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
%     x0 = cx_run(idx); y0 = cy_run(idx);
%     dx = u(idx) * vecScale; dy = v(idx) * vecScale;
%     quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.2, 'MaxHeadSize', 0.2);
% 
%     % Format Axes labels into uniform Kilometers units
%     xlabel(ax, 'RDx (km)', 'FontSize', 14);
%     ylabel(ax, 'RDy (km)', 'FontSize', 14);
% 
%      % Ensure axis uses equal scaling so distances in x/y are true (preserves aspect)
%     daspect(ax, [1 1 1]);
% 
%     % Convert axis tick labels from meters to kilometers for readability,
%     % but keep tick positions in meters so geometry remains accurate.
%     xl = xlim(ax); yl = ylim(ax);
%     xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
%     yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
%     xk = (xk_min : 1.0 : xk_max);            
%     yk = (yk_min : 0.5 : yk_max);            
%     set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
%     set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%            'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
% 
%     % Title handling per sub-panel
%     if exist('names','var') && numel(names) >= i
%         nameStr = char(names(i));
%     else
%         nameStr = sprintf('Model Variant %d', i);
%     end
%     title(ax, nameStr, 'FontSize', 16, 'FontWeight', 'bold');
% 
%     % Enforce local colorbar scaling boundaries uniformly
%     clim(ax, [0 1]); 
%     hold(ax, 'off');
% 
%     % add colorbar to first subplot only to avoid clutter
%     if k == 1
%         cb = colorbar(ax);
%         cb.Label.String = 'Speed';
%     end
% end  
% 

%% Plot all time steps flow field 
nTimes = length(DataXY{1,1}.times);
% nTimes = length(DataXY{1,1}.times(71:105,:));

for k = 1:nTimes
    time_date = DataXY{1,1}.times(k);
    figName = sprintf('Flow Field: %s', datestr(time_date, 'dd-mm-yyyy HH:MM'));
    fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [200, 200, 800, 600]);
    
    % Use axes instead of subplot so it occupies the full window
    ax = axes('Parent', fig);
    tix = k; 
    
    % Compute hydro-mesh cell center geometry
    if size(gridX,1) == 4
        cx_run = mean(gridX,1);
        cy_run = mean(gridY,1);
    end

    % Extract velocity components
    u = DataXY{1}.vel_x(tix,:); 
    v = DataXY{1}.vel_y(tix,:);

    if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
    if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
    speed = sqrt(u.^2 + v.^2);

    % Plot mesh patches
     patch(gridX, gridY, speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
    hold(ax, 'on');
    
    % ---plot strekdammen nieuw + aangepast + bestaand--- (only for i == 2)
    if i == 1
        for k = 1:numel(Nieuw_x)
            if ~isempty(Nieuw_x{k})
                hPol(end+1) = plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 4); %#ok<SAGROW>
            end
        end
    end
    hPol(3) = plot(ax, nan, nan, 'k-', 'LineWidth', 2); % placeholder for legend

    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
        hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, 'r-','LineWidth', 4); %#ok<SAGROW>
        end
    end
    hPol(1) = plot(nan, nan, 'r-', 'LineWidth', 2); % to use in

    for ki = 1:numel(Bestaand_x)
        if ~isempty(Bestaand_x{ki})
        hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 4); %#ok<SAGROW>
        end
    end
    hPol(2) = hLine2;

    %========= Map geographic viewport=========
    % %Bath
    % xlim(ax, [69600 72900]);
    % ylim(ax, [378900 380600]);

    %Bath peak vel
    xlim(ax, [70000 71500]);
    ylim(ax, [379000 380000]);

    % %Bath ZOOM
    % xlim(ax, [70500 71600]);
    % ylim(ax, [379450 380100]);

    % Zimm
    % xlim(ax, [64300 67200]);   % RDx in meters
    % ylim(ax, [379300 380900]); % RDy in meters

    % %Zimm Zoom
    % xlim(ax, [65200 67600]);
    % ylim(ax, [379300 380400]);

    
    % % ========= Map uniform 50m quiver arrows =========
    % % 1. Get the current axis limits to grid only the visible viewport
    % xl = xlim(ax);
    % yl = ylim(ax);
    % 
    % % 2. Create a regular grid with exactly 50-meter spacing
    % [x0, y0] = meshgrid(xl(1):50:xl(2), yl(1):50:yl(2));
    % 
    % % 3. Interpolate unstructured velocity field onto the 50m grid
    % % 'none' prevents extrapolation of vectors outside your hydrodynamic domain boundaries
    % F = scatteredInterpolant(cx_run(:), cy_run(:), u(:), 'linear', 'none');
    % u_grid = F(x0, y0);
    % F.Values = v(:); % Efficiently reuse the triangulation structure for the v-component
    % v_grid = F(x0, y0);
    % 
    % % 4. Scale vectors consistently based on axis width
    % vecScale = 0.8 * mean(diff(xl)) / sqrt(nanmean(u_grid(:).^2) + nanmean(v_grid(:).^2)) / 50;
    % dx = u_grid * vecScale; 
    % dy = v_grid * vecScale;
    % 
    % % 5. Plot the regularized quiver arrows
    % quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);
    % % ==========================================================
   
    % ========= Map uniform 50m quiver arrows (Uniform Length) =========
    % 1. Get the current axis limits to grid only the visible viewport
    xl = xlim(ax);
    yl = ylim(ax);
    
    % 2. Create a regular grid with exactly 50-meter spacing
    [x0, y0] = meshgrid(xl(1):100:xl(2), yl(1):100:yl(2));
    
    % 3. Filter out any NaN or Inf coordinates and velocities
    isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & ...
              isfinite(u(:))      & isfinite(v(:));
          
    cx_valid = cx_run(isValid);
    cy_valid = cy_run(isValid);
    u_valid  = u(isValid);
    v_valid  = v(isValid);
    
    % 4. Interpolant using only finite data points
    if ~isempty(cx_valid)
        F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
        u_grid = F(x0, y0);
        
        F.Values = v_valid(:); % Reuse structure for v-component
        v_grid = F(x0, y0);
        
        % 5. Normalize the grid vectors to unit length (Magnitude = 1)
        grid_speed = sqrt(u_grid.^2 + v_grid.^2);
        u_norm = u_grid ./ grid_speed;
        v_norm = v_grid ./ grid_speed;
        
        % 6. Define a fixed arrow length in meters (e.g., 15 meters long)
        arrow_length_meters = 60; 
        
        dx = u_norm * arrow_length_meters; 
        dy = v_norm * arrow_length_meters;
        
        % 7. Plot the uniform-length quiver arrows
        % We pass 0 as the final scaling argument so MATLAB doesn't auto-scale them
        quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.9, 'MaxHeadSize', 0.7);
    end
    % ==================================================================

  % % ========= Map uniform 50m quiver arrows inside KML boundary =========
  %   xl = xlim(ax);
  %   yl = ylim(ax);
  % 
  %   % Create a regular grid with exactly 50-meter spacing
  %   [x0, y0] = meshgrid(xl(1):50:xl(2), yl(1):50:yl(2));
  % 
  %   % Filter out any NaN or Inf coordinates and velocities
  %   isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & ...
  %             isfinite(u(:))      & isfinite(v(:));
  % 
  %   cx_valid = cx_run(isValid);
  %   cy_valid = cy_run(isValid);
  %   u_valid  = u(isValid);
  %   v_valid  = v(isValid);
  % 
  %   if ~isempty(cx_valid)
  %       F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
  %       u_grid = F(x0, y0);
  % 
  %       F.Values = v_valid(:); 
  %       v_grid = F(x0, y0);
  % 
  %       % --- Mask using our converted RD coordinates ---
  %       isInsideKML = inpolygon(x0, y0, poly_x, poly_y);
  %       u_grid(~isInsideKML) = NaN;
  %       v_grid(~isInsideKML) = NaN;
  % 
  %       % Normalize the grid vectors to unit length
  %       grid_speed = sqrt(u_grid.^2 + v_grid.^2);
  %       u_norm = u_grid ./ grid_speed;
  %       v_norm = v_grid ./ grid_speed;
  % 
  %       % Define a fixed arrow length in meters
  %       arrow_length_meters = 35; 
  %       dx = u_norm * arrow_length_meters; 
  %       dy = v_norm * arrow_length_meters;
  % 
  %       % Plot the uniform-length quiver arrows
  %       quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);
  % 
  %       % OPTIONAL: Plot the KML boundary line itself so you can see it
  %       hold(ax, 'on');
  %       plot(ax, poly_x, poly_y, 'g--', 'LineWidth', 1.5); 
  %   end

    % % Arrows: subsample for clarity
    % nVectors = numel(cx_run);
    % maxArrows = 4000;
    % if nVectors > maxArrows
    %     idx = round(linspace(1, nVectors, maxArrows));
    % else
    %     idx = 1:nVectors;
    % end
    % 
    % % Scale vectors consistently based on axis width (increase arrow length)
    % axUnits = get(ax, 'Units'); set(ax, 'Units', 'normalized');
    % axPos = get(ax, 'Position'); set(ax, 'Units', axUnits);
    % % Use a larger base multiplier to increase arrow lengths (was 0.2)
    % vecScale = 0.8 * mean(diff(xlim)) / sqrt(nanmean(u(idx).^2)+nanmean(v(idx).^2)) / 50;
    % 
    % x0 = cx_run(idx); y0 = cy_run(idx);
    % dx = u(idx) * vecScale; dy = v(idx) * vecScale;
    % % Slightly increase linewidth for visibility
    % quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);

    % Format Axes labels into uniform Kilometers units
    xlabel(ax, 'RDx (km)', 'FontSize', 12);
    ylabel(ax, 'RDy (km)', 'FontSize', 12);
    daspect(ax, [1 1 1]);

    % Keep tick positions in meters but label in kilometers
    xl = xlim(ax); yl = ylim(ax);
    xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
    yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
    xk = (xk_min : 1.0 : xk_max);            
    yk = (yk_min : 0.5 : yk_max);            
    set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
    set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
           'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));

    % Plot Title
    title(ax, figName, 'FontSize', 14, 'FontWeight', 'bold');

    % Use discrete colormap levels for color consistency
    nLevels = 12;
    cmap = parula(nLevels);
    colormap(ax, cmap);
    % Define color limits to span [0,1] as before
    clim(ax, [0 1.2]);
    % Force patch face colors to use discrete bins by mapping data to integer indices
    ch = findobj(ax, '-property', 'CData');
    for c = 1:numel(ch)
        C = get(ch(c), 'CData');
        if isnumeric(C)
            % Normalize to [0,1], clamp, then map to 1:nLevels
            Cnorm = (C - 0) ./ (1 - 0);
            Cnorm = min(max(Cnorm, 0), 1);
            Cidx = round(Cnorm * (nLevels-1)) + 1;
            % Set CData to indexed colors via surface-like coloring:
            % Replace numeric scalar per-face with RGB triplets
            if isvector(Cidx)
                rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
                % For patch with FaceColor 'flat', set CData to indices and set FaceVertexCData
                try
                    set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
                catch
                    % Fallback: set CData to original normalized values (colormap still enforces discrete steps)
                    set(ch(c), 'CData', Cnorm);
                end
            else
                set(ch(c), 'CData', Cnorm);
            end
        end
    end
    hold(ax, 'off');

    % colobar
    cb = colorbar(ax);
    cb.Label.String = 'Speed (m/s)';
end

% % ========================================================
% % COMPONENT ROUTING TO EMPTY TILE 4 (Legend & Colorbar)
% % ========================================================
% 
% % Create invisible axes in current figure for legend & colorbar placement
% axLeg = axes('Visible', 'off', 'Units', 'normalized', 'Position', [0.75 0.05 0.2 0.15]);
% 
% % Populate dummy items onto hidden axes for uniform display (use consistent DisplayName)
% dummyGroyne = plot(axLeg, NaN, NaN, 'r-', 'LineWidth', 3, 'DisplayName', 'Existing Groynes');
% dummyNew = plot(axLeg, NaN, NaN, 'k-', 'LineWidth', 2, 'DisplayName', 'New Groyne');
% dummyFlow = quiver(axLeg, NaN, NaN, NaN, NaN, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.5, 'DisplayName', 'Flow Direction');
% 
% % Create legend on the invisible axes
% lgd = legend(axLeg, [dummyGroyne, dummyNew, dummyFlow], 'Location', 'southoutside', 'FontSize', 12);
% 
% % Ensure legend background is not opaque black: set box off and set color to none
% set(lgd, 'Box', 'off', 'Interpreter', 'none', 'Color', 'none', 'TextColor', 'k');
% 
% % Also ensure legend items use line-based preview (prevents patch fill showing as black)
% set(lgd, 'ItemTokenSize', [30 18]);
% 
% % Append global domain Colorbar into the same (invisible) axes area
% cb = colorbar(axLeg, 'Location', 'northoutside');
% cb.Label.String = 'Depth-Average Velocity (m/s)';
% cb.Label.FontSize = 12;
% cb.FontSize = 10;
% 
% % Ensure consistent color scaling in the main axes (if variable 'ax' exists)
% if exist('ax','var') && isgraphics(ax)
%     clim(ax, [0 1]);
% end


% %% --- export all open figures ---
% outDir = 'P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\PNGs\flow_field';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% 
% figHandles = findall(0, 'Type', 'figure');
% if isempty(figHandles)
%     warning('No open figures to export.');
% else
%     for fi = 1:numel(figHandles)
%         fig = figHandles(fi);
%         % Attempt to get a meaningful name from the figure; fall back to number
%         figName = get(fig, 'Name');
%         if isempty(figName)
%             figName = sprintf('figure_%d', fig.Number);
%         end
%         % Make filename filesystem-safe
%         safeName = regexprep(figName, '[<>:"/\\|?*]', '_');
%         filename = fullfile(outDir, sprintf('%s.png', safeName));
%         try
%             set(fig, 'PaperPositionMode', 'auto');
%             print(fig, filename, '-dpng', '-r300');
%         catch ME
%             warning('Failed to save figure "%s": %s', figName, ME.message);
%         end
%     end
% end
