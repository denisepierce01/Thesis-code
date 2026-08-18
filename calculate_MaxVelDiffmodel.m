close all
clear al
clc

%plot max velocity difference: TwGroynes - T0

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

% flats (Bath, Zimm)
KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_flats_bath.kml');
for ki = 1:length(KML)
    [Bathflats_x{ki},Bathflats_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_flats_zimm.kml');
for ki = 1:length(KML)
    [Zimmflats_x{ki},Zimmflats_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

Opgehoogd_x{1} = [];
Opgehoogd_y{1} = [];

% % Plot all imported polygons
% hold on;
% hPol = [];
% 
% % plot boundaries
% if isfield(POL_x,'BATH') && ~isempty(POL_x.BATH)
%     hPol(end+1) = plot(POL_x.BATH, POL_y.BATH, 'k-', 'LineWidth', 1.5);
% end
% if isfield(POL_x,'ZIM') && ~isempty(POL_x.ZIM)
%     hPol(end+1) = plot(POL_x.ZIM, POL_y.ZIM, 'm-', 'LineWidth', 1.5);
% end
% if exist('Bathflats_x','var') && ~all(cellfun(@isempty,Bathflats_x))
%     for k = 1:numel(Bathflats_x)
%         if ~isempty(Bathflats_x{k})
%             hPol(end+1) = plot(Bathflats_x{k}, Bathflats_y{k}, 'w-', 'LineWidth', 1.5);
%         end
%     end
% end
% if exist('Zimmflats_x','var') && ~all(cellfun(@isempty,Zimmflats_x))
%     for k = 1:numel(Zimmflats_x)
%         if ~isempty(Zimmflats_x{k})
%             hPol(end+1) = plot(Zimmflats_x{k}, Zimmflats_y{k}, 'w-', 'LineWidth', 1.5);
%         end
%     end
% end
% 
% % plot Nieuw, Aangepast, Bestaand (cell arrays of polygons)
% for k = 1:numel(Nieuw_x)
%     if ~isempty(Nieuw_x{k})
%         hPol(end+1) = plot(Nieuw_x{k}, Nieuw_y{k}, 'b-', 'LineWidth', 1);
%     end
% end
% for k = 1:numel(Aangepast_x)
%     if ~isempty(Aangepast_x{k})
%         hPol(end+1) = plot(Aangepast_x{k}, Aangepast_y{k}, 'g--', 'LineWidth', 1); 
%     end
% end
% for k = 1:numel(Bestaand_x)
%     if ~isempty(Bestaand_x{k})
%         hPol(end+1) = plot(Bestaand_x{k}, Bestaand_y{k}, 'r-.', 'LineWidth', 1);
%     end
% end
% 
% % optionally add legend and formatting if any handles were created
% if ~isempty(hPol)
%     legendEntries = {};
%     if exist('POL_x','var') && isfield(POL_x,'BATH'); legendEntries{end+1} = 'Bath boundary'; end
%     if exist('POL_x','var') && isfield(POL_x,'ZIM');  legendEntries{end+1} = 'Zimmerman boundary'; end
%     if exist('Nieuw_x','var') && any(cellfun(@(c)~isempty(c), Nieuw_x)); legendEntries{end+1} = 'Nieuw'; end
%     if exist('Aangepast_x','var') && any(cellfun(@(c)~isempty(c), Aangepast_x)); legendEntries{end+1} = 'Aangepast'; end
%     if exist('Bestaand_x','var') && any(cellfun(@(c)~isempty(c), Bestaand_x)); legendEntries{end+1} = 'Bestaand'; end
%     if exist('Bathflats_x','var') && any(cellfun(@(c)~isempty(c), Bathflats_x)); legendEntries{end+1} = 'Bath flats boundary'; end
%     if exist('Zimmflats_x','var') && any(cellfun(@(c)~isempty(c), Zimmflats_x)); legendEntries{end+1} = 'Zimmerman flats boundary'; end
%     legend(hPol, legendEntries, 'Location', 'bestoutside');
% end
% axis equal;
% hold off;

%% import models
folders = { ...
    'P:\11207654-internship-pierce-2026\03_Model\15_T0_fou_Apr18\output\' , ...
    'P:\11207654-internship-pierce-2026\03_Model\17_T0bathy_T1groynes_fou_Apr18\output\' , ...
    'P:\11207654-internship-pierce-2026\03_Model\16_T1_fou_Apr18\output\',
};

% Names for the titles (Viscosity values) & save to mat files
% names = {'T0', 'T0wGroynes'};
names = {'T0', 'T0wGroynes', 'T1'};

% %% Extracting info from FOU files
% sigma_layers = [2 3 5 8 10 12 15 15 15 15];
% sigma_weights = reshape(sigma_layers, 1, 1, 10);
% 
% for i = 1:length(folders)
%     ncFile = fullfile(folders{i}, 'WS_0000_fou.nc');
% 
%     % choose date range depending on i
%     if i == 1
%         t0 = '22-Apr-2018';
%         tend = '23-May-2018'; 
%     end
% 
%     % read map/model data and grid info for this folder
%     DataXY{i} = EHY_getMapModelData(ncFile, 'varName', 'mesh2d_fourier005_max', 't0', t0, 'tend', tend, 'layer', '0'); %load all layers
%     DataXY{i}.val = sum(DataXY{i}.val .* (sigma_weights / 100), 3); % depth averaged
% 
%     % save per-run DataXY using descriptive names array
%     nameVal = names(i);
%     if isnumeric(nameVal)
%         nameStr = sprintf('%g', names);
%         nameStr = strrep(nameStr, '.', 'p'); % replace dot with 'p' for filenames
%     else
%         nameStr = matlab.lang.makeValidName(char(nameVal));
%     end
%     % save DataXY
%     outName = fullfile(pwd, ['MaxVel' nameStr '.mat']);
%     velData = DataXY{i}; 
%     save(outName, 'DataXY');
% end

%% load .mat
% MAXIMUM
% vel = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\maxvelT1.mat'); 
FOU = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_Apr22-24_T0T1.mat'); %T0 and T1
% data1  = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_Apr22_T0wGroynes.mat"); % T0wGroynes
% timebelow = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_T0_T0wG_T1.mat"); %T0 and T0wGroynes and T1
% sigma_layers = [2 3 5 8 10 12 15 15 15 15];

for i =1
    gridX = FOU.FOU(i).data.grid.face_nodes_x;
    gridY = FOU.FOU(i).data.grid.face_nodes_y;
end

% 95 percentile velocities
T0 = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel95pct_T0.mat');
T0wG = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel95pct_T0wG.mat');
T1 = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel95pct_T1.mat');
vel.DataXY = [T0; T0wG; T1];

% % 50 percentile velocities
% T0 = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel50pct_T0.mat');
% T0wG = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel50pct_T0wG.mat');
% T1 = load('P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel50pct_T1.mat');
% vel.DataXY = [T0; T0wG; T1];


% %% time below 0.6 m/s (including dry time) yields high percentages
% time_percent_all = []; 
% 
% for i = 1:length(folders) % T0, T0 w Groynes, T1
%     time_sec = timebelow.FOU(i).data.tau.valTimeBelow_DA(:, 13); % time in seconds per cell
%     total_time = max(time_sec);
% 
%     % Store the result directly into column 'i' of your workspace matrix
%     time_percent_all(:, i) = time_sec ./ total_time;
% end
% 
% % for i = 1:length(folders) %T0
%     time_sec = timebelow.FOU(i).data.tau.valTimeBelow_DA(:, 13); % time in seconds per cell
%     total_time = max(time_sec);
%     time_percent = time_sec ./ total_time;
% end 
% % T0 with Groynes
% time_sec0groyne = data1.FOU.data.tau.valTimeBelow_DA(:,13);
% time_percent0groyne = time_sec0groyne ./ total_time;
% 
% for i=2 % T1
%     time_sec1 = timebelow.FOU(i).data.tau.valTimeBelow(:, 13); % time in seconds per cell
%     total_time = max(time_sec1);
%     time_percent1 = time_sec1 ./ total_time;
% end  

%% plotting max velocities
viewports(1).name = 'Bath';
viewports(1).xlim = [68900 72900];
viewports(1).ylim = [378750 380400];
viewports(2).name = 'Zimmerman';
viewports(2).xlim = [64000 68100];
viewports(2).ylim = [379000 380800];

% one figure with tiles
% figName = sprintf('%s\n', nameStr);
figName = sprintf('95th Percentile Velocity: T0 with Groynes - T0\n');
fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [100, 150, 1400, 600]);
t = tiledlayout(1, 2, 'Parent', fig, 'TileSpacing', 'compact', 'Padding', 'compact');

% Initialize arrays to store values for terminal readout
axHandles = [];
areaResults = struct('Bath', 0, 'Zimmerman', 0);

% Loop over both geographical locations to build tiles
for loc = 1:numel(viewports)
    currentLoc = viewports(loc).name;
    
    % Move to the next available tile
    ax = nexttile(t);
    axHandles(loc) = ax; 
    
    % Compute hydro-mesh cell center geometry
    cx_run = mean(gridX,1);
    cy_run = mean(gridY,1);
    
    % for i = 1:length(folders)
        speed = vel.DataXY(2).speed_90pct - vel.DataXY(1).speed_90pct; % CHANGE HERE TO COMPARE T0, T0 w Groynes, T1
       
        % Plot mesh patches
        if size(gridX,1) == 4
            patch(gridX, gridY, speed(:)', ...
                  'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
        else
            patch(gridX', gridY', speed(:)', ...
                  'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
        end
        hold(ax, 'on');
                
         % --- Plot structures ---
        for ki = 1:numel(Nieuw_x)
            if ~isempty(Nieuw_x{ki})
                plot(ax, Nieuw_x{ki}, Nieuw_y{ki}, 'k-', 'LineWidth', 3);
            end
        end
        
        for ki = 1:numel(Aangepast_x)
            if ~isempty(Aangepast_x{ki})
                plot(ax, Aangepast_x{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 3);
            end
        end
        for ki = 1:numel(Aangepast_x)
            if ~isempty(Aangepast_x{ki})
                plot(ax, Aangepast_x{ki}, Aangepast_y{ki}, 'k--','LineWidth', 2);
            end
        end
        
        
        for ki = 1:numel(Bestaand_x)
            if ~isempty(Bestaand_x{ki})
                 plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 3);
            end
        end
        
        for ki = 1
            plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'k--','LineWidth', 1.5);
        end
  
    
    %========= Viewport Limits & Data Aspect Ratio =========
    xlim(ax, viewports(loc).xlim);
    ylim(ax, viewports(loc).ylim);
    daspect(ax, [1 1 1]);
    
    % Setup Ticks in Kilometers
    xl = xlim(ax); yl = ylim(ax);
    xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
    yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
    xk = (xk_min : 1.0 : xk_max);            
    yk = (yk_min : 0.5 : yk_max);            
    set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
    set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
           'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
    
    % colorbar: blue -> white -> red diverging colormap
    blue  = [0.05, 0.30, 0.65]; % Deep Blue
    white = [1.00, 1.00, 1.00]; % white center
    red   = [0.70, 0.05, 0.10]; % deep red

    % Interpolate 128 points from blue to white, and 128 from white to red
    n = 5;
    blue_to_white = [linspace(blue(1), white(1), n)', linspace(blue(2), white(2), n)', linspace(blue(3), white(3), n)'];
    white_to_red   = [linspace(white(1), red(1), n)',   linspace(white(2), red(2), n)',   linspace(white(3), red(3), n)'];

    % ---------------------------------------------------------------------
    % Discrete Diverging Colormap: Green (neg) -> White (center) -> Red (pos)
    % Bins of width 0.10, white band fixed at [-0.05, 0.05]
    % Colorbar limits: [-0.45, 0.45]
    % ---------------------------------------------------------------------
    climLo = -0.45;
    climHi =  0.45;
    binWidth = 0.10;
    
    % Bin edges: -0.45, -0.35, -0.25, -0.15, -0.05, 0.05, 0.15, 0.25, 0.35, 0.45
    edges = climLo:binWidth:climHi;
    nBins = numel(edges) - 1;   % 9 bins
    
    % Bin centers, used to decide each bin's color
    centers = edges(1:end-1) + binWidth/2;
    
    % Build one color per bin: white for the bin centered on 0,
    % blue shades for negative bins, red shades for positive bins
    cmap = zeros(nBins, 3);
    negBins = centers < 0;
    posBins = centers > 0;
    zeroBin = abs(centers) < 1e-9;   % the [-0.05, 0.05] bin
    
    nNeg = sum(negBins);
    nPos = sum(posBins);
    
    if nNeg > 0
        negShades = [linspace(blue(1), white(1), nNeg+1)', ...
                     linspace(blue(2), white(2), nNeg+1)', ...
                     linspace(blue(3), white(3), nNeg+1)'];
        cmap(negBins, :) = negShades(1:nNeg, :);   % darkest blue -> lighter, excluding pure white
    end
    
    if nPos > 0
        posShades = [linspace(white(1), red(1), nPos+1)', ...
                     linspace(white(2), red(2), nPos+1)', ...
                     linspace(white(3), red(3), nPos+1)'];
        cmap(posBins, :) = posShades(2:end, :);    % excluding pure white, up to full red
    end
    
    cmap(zeroBin, :) = white;   % force the central bin to pure white
    
    colormap(ax, cmap);
    clim(ax, [climLo climHi]);

    % Only label 0, +/-0.25, +/-0.45 (independent of bin edges)
    cb_tick_vals = [-0.45, -0.25, 0, 0.25, 0.45];
    cb_tick_labels = {'-0.45', '-0.25', '0', '0.25', '0.45'};
    setappdata(ax, 'CustomColorbarTicks', cb_tick_vals);
    setappdata(ax, 'CustomColorbarTickLabels', cb_tick_labels);
        
    % % Discrete-looking colorbar with ticks at bin edges
    % cb_tick_vals = edges;
    % cb_tick_labels = arrayfun(@(v) sprintf('%.2f', v), edges, 'UniformOutput', false);
    % setappdata(ax, 'CustomColorbarTicks', cb_tick_vals);
    % setappdata(ax, 'CustomColorbarTickLabels', cb_tick_labels);
    
    % Colorbar Details
    if loc == 2
        cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
        cb.Position = [0.62, 0.09, 0.25, 0.03];  % [x y width height]
        cb.Ticks = cb_tick_vals;
        cb.TickLabels = cb_tick_labels;
        % cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
    end
    
    set(ax, 'Layer', 'top');
    hold(ax, 'off');
end

% LEGEND 
lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.10, 0.2, 0.05]);
% h_target = patch(lgdAxes, NaN, NaN, [0, 0, 1], 'FaceAlpha', 0.7, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
hold(lgdAxes, 'on');

h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'New Groyne');
h_groyne_ch = plot(lgdAxes, NaN, NaN, 'k--', 'LineWidth', 3, 'DisplayName', 'Modified');
h_groyne_ex = plot(lgdAxes, NaN, NaN,  '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 3, 'DisplayName', 'Existing Groyne');
lgd = legend(lgdAxes, [h_groyne, h_groyne_ch, h_groyne_ex], 'Location', 'southwest', 'Orientation', 'vertical');
set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 

% LABELS
for loc = 1:numel(axHandles)
    thisAx = axHandles(loc);
    set(thisAx, 'FontSize', 12, 'LineWidth', 1.2);
    xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
    if loc == 1
        ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
    end
    texTitle = sprintf('\\bf{\\it{%s}}', viewports(loc).name);
    title(thisAx, texTitle, 'FontSize', 22);
end

title(t, figName, 'FontSize', 24, 'FontWeight', 'bold');

% colorbar properties
if exist('cb', 'var') && isgraphics(cb)
    cb.FontSize = 14;               
    cb.Label.String = '\bf{Difference in 95th percentile velocity [m/s]}';
    cb.Label.FontSize = 14;
    stored_ticks = getappdata(axHandles(2), 'CustomColorbarTicks');
    stored_labels = getappdata(axHandles(2), 'CustomColorbarTickLabels');
    
    if ~isempty(stored_ticks) && ~isempty(stored_labels)
        cb.Ticks = stored_ticks;
        cb.TickLabels = stored_labels;
    end
end

%% single viewport for overview
viewports(1).name = 'Overview';
viewports(1).xlim = [63900 73000];
viewports(1).ylim = [377600 380950];

% One figure with a single clean tile layout
fig = figure('Name', 'Low Dynamic Time Overview', 'NumberTitle', 'off', 'Position', [100, 150, 1100, 700]);
t = tiledlayout(1, 1, 'Parent', fig, 'TileSpacing', 'compact', 'Padding', 'compact');

% ax = nexttile(t);
axHandles = ax; 

% Compute hydro-mesh cell center geometry (handle both orientations)
cx_run = mean(gridX,1);
cy_run = mean(gridY,1);

 % ===satellite image=======
fig2 = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 1300, 850]);
ax = axes('NextPlot', 'add');

% Set your explicit target boundary dimensions in RD New meters
xlims = [63000 73500];
ylims = [376800 381300];
y_shift = -100; 
ylims_shifted = ylims + y_shift;

% Set 1:1 isometric aspect ratio so flow vectors remain geometrically true
axis(ax, [xlims ylims_shifted], 'equal');

% construct a query bound to RD coordinate limits (EPSG:28992)
img_w = 2400; img_h = 1000;
static_url = sprintf(...
    'https://service.pdok.nl/hwh/luchtfotorgb/wms/v1_0?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=Actueel_ortho25&STYLES=&CRS=EPSG:28992&BBOX=%d,%d,%d,%d&WIDTH=%d&HEIGHT=%d&FORMAT=image/jpeg', ...
    xlims(1), ylims_shifted(1), xlims(2), ylims_shifted(2), img_w, img_h);

% Read the high-resolution aerial layout from the server pipeline
aerial_img = webread(static_url);

% Display image flat beneath vectors, stretching it to coordinates
h_bg = imagesc(ax, xlims, ylims_shifted, flipud(aerial_img));

% Push the image background below the grid layer
uistack(h_bg, 'bottom');

probScaleValue = 0.25;

%===plotting speed=====
speed = vel.DataXY(2).speed_90pct - vel.DataXY(1).speed_90pct; % CHANGE HERE TO COMPARE T0, T0 w Groynes, T1
plotSpeed = speed;
plotSpeed(plotSpeed >= -0.04 & plotSpeed <= 0.04) = NaN; %range of values to mask since otherwise plotted as white

patch(gridX, gridY, plotSpeed(:)', 'EdgeColor', 'none', 'FaceColor', 'flat', 'FaceAlpha', 0.6, 'Parent', ax);

hold(ax, 'on');
        
 % --- Plot structures ---
for ki = 1:numel(Nieuw_x)
    if ~isempty(Nieuw_x{ki})
        plot(ax, Nieuw_x{ki}, Nieuw_y{ki}, 'k-', 'LineWidth', 3);
    end
end

for ki = 1:numel(Aangepast_x)
    if ~isempty(Aangepast_x{ki})
        plot(ax, Aangepast_x{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 3);
    end
end
for ki = 1:numel(Aangepast_x)
    if ~isempty(Aangepast_x{ki})
        plot(ax, Aangepast_x{ki}, Aangepast_y{ki}, 'k--','LineWidth', 2);
    end
end


for ki = 1:numel(Bestaand_x)
    if ~isempty(Bestaand_x{ki})
         plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 3);
    end
end

for ki = 1
    plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'k--','LineWidth', 1.5);
end

%========= Viewport Limits & Data Aspect Ratio =========
xlim(ax, viewports(1).xlim);
ylim(ax, viewports(1).ylim);
daspect(ax, [1 1 1]);

% Setup Ticks in Kilometers
xl = xlim(ax); yl = ylim(ax);
xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
yk_min = floor(yl(1)/1000);
yk_max = ceil(yl(2)/1000);
xk = (xk_min : 2.0 : xk_max);            
yk = (yk_min : 1.0 : yk_max);            
set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
       'YTickLabel', arrayfun(@(v) sprintf('%.0f', v), yk, 'UniformOutput', false), ...
       'FontSize', 16);

%========= Colorbar Setup =========
% blue = [0.00, 0.60, 0.00]; % medium blue
white = [1.00, 1.00, 1.00]; % white center
red   = [0.70, 0.05, 0.10]; % deep red

n = 128;
blue_to_white = [linspace(blue(1), white(1), n)', linspace(blue(2), white(2), n)', linspace(blue(3), white(3), n)'];
white_to_red   = [linspace(white(1), red(1), n)',   linspace(white(2), red(2), n)',   linspace(white(3), red(3), n)'];


% Colorbar 
cmap = [blue_to_white; white_to_red(2:end, :)];
colormap(ax, cmap);
clim(ax, [-0.30, 0.30]); 

cb_tick_vals = [-0.3, -0.2, -0.1, 0.0, 0.1, 0.2, 0.3];             
cb_tick_labels = {'-0.3','-0.2', '-0.1', '0', '0.1', '0.2','0.3'}; 
cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
hold(ax, 'off');

%========= Legend Setup =========
lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.09, 0.2, 0.05]);
hold(lgdAxes, 'on');
h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'New Groyne');
h_groyne_ch = plot(lgdAxes, NaN, NaN, 'k--', 'LineWidth', 3, 'DisplayName', 'Modified');
h_groyne_ex = plot(lgdAxes, NaN, NaN,  '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 2.5, 'DisplayName', 'Existing Groyne');
% lgd = legend(lgdAxes, [h_groyne, h_groyne_ch, h_groyne_ex], 'Location', 'southwest', 'Orientation', 'vertical');
% set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
% set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 

lgd = legend(ax, [h_groyne, h_groyne_ch, h_groyne_ex], 'Orientation', 'vertical');
set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
lgd.Position = [0.22, 0.15, 0.20, 0.0];  %[left, bottom, width, height]

% %========= Labels for Viewports =========
% for loc = 1:numel(axHandles)
%     thisAx = axHandles(loc);
%     set(thisAx, 'FontSize', 12, 'LineWidth', 1.2);
%     xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
%     if loc == 1
%         ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
%     end
%     texTitle = sprintf('\\bf{\\it{%s}}', viewports(loc).name);
%     title(thisAx, texTitle, 'FontSize', 22);
% end

%========= Colorbar Properties Post-Processing =========
if exist('cb', 'var') && isgraphics(cb)
    cb.FontSize = 14;               
    cb.Label.String = '\bf{Difference in percentile velocity  [m/s]}';
    cb.Label.FontSize = 15;
    cb.Ticks = cb_tick_vals;
    cb.TickLabels = cb_tick_labels;
    cb.Position = [0.55, 0.15, 0.30, 0.03];  
end

%========= Formatting Labels & Main Title =========
set(ax, 'Layer', 'top');
set(ax, 'FontSize', 16, 'LineWidth', 1.2);
xlabel(ax, '\bf{RDx [km]}', 'FontSize', 18);
ylabel(ax, '\bf{RDy [km]}', 'FontSize', 18);
title(ax, '\bf{95th Percentile}', 'FontSize', 20);

% %% export
% exportFileName = 'OverviewXXpctVel2.png';
% exportgraphics(fig2, exportFileName, 'Resolution', 300);