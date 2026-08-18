
close all
clear all
clc

% plot flow field from model and water level synchronously
% D. Pierce

%% import KMLs for strekdammen
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

% KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\flowfieldarrows_boundary_enlarged.kml');
% for ki = 1:length(KML)
%     [flowfield_x{ki},flowfield_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
% end

KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_Zimm.kml');
for ki = 1:length(KML)
    [flowfield_x{ki},flowfield_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

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

% %% looking for peaks in ADCPS from model
% Data = EHY_getmodeldata('P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\output\WS_0000_his.nc',{'BATH_T0_MP0103','BATH_T0_MP0104','BATH_T0_MP0202','BATH_T0_MP0203','BATH_T0_MP0602','BATH_T0_MP0502','BATH_T0_MP0403','BATH_T0_MP0402','BATH_T0_MP0302','BATH_T0_MP0702'},'dfm','varName','velocity_magnitude','t0','22-Apr-2018','tend','23-May-2018','layer','10');
% time = Data.times;
% vel_toplayer = Data.val;
% % Ensure Data.requestedStations is a cell array of names; create legend entries accordingly
% if ischar(Data.requestedStations) || isstring(Data.requestedStations)
%     names = cellstr(Data.requestedStations);
% elseif iscell(Data.requestedStations)
%     names = Data.requestedStations;
% else
%     % Fallback: convert to cell array of strings
%     names = cellfun(@char, num2cell(Data.requestedStations), 'UniformOutput', false);
% end
% 
% % Convert numeric/serial time to datetime with day-month format for x-axis labels
% % If time is already datetime, leave as-is; otherwise try to interpret as datenum or POSIX time
% if isa(time, 'datetime')
%     time_dt = time;
% elseif isnumeric(time)
%     % Heuristic: if values are large (>1e5) treat as datenum, else treat as POSIX seconds
%     if all(time > 1e5)
%         time_dt = datetime(time, 'ConvertFrom', 'datenum');
%     else
%         time_dt = datetime(time, 'ConvertFrom', 'posixtime');
%     end
% else
%     % Fallback: attempt to parse strings
%     time_dt = datetime(time);
% end
% % Create formatted labels using day-month (e.g., 22-Apr)
% time_labels = datestr(time_dt, 'dd-mmm');
% 
% % Plot each station's timeseries (assume vel_toplayer columns correspond to stations)
% figure;
% nSeries = size(vel_toplayer, 2);
% cols = turbo(max(10, nSeries)); % ensure at least 10 distinct colors
% hold on;
% 
% % Use time_dt for plotting and set x-axis tick labels to day-month
% % set(gca, 'XTick', time_dt(1):ceil(max(1, numel(time_dt)/8)):time_dt(end));
% % xticks_vals = get(gca, 'XTick');
% % set(gca, 'XTickLabel', cellstr(datestr(xticks_vals, 'dd-mmm')));
% for k = 1:nSeries
%     plot(time, vel_toplayer(:,k), 'LineWidth', 2.5, 'Color', cols(mod(k-1,size(cols,1))+1, :));
% end
% hold off;
% lg = legend(names(1:min(end,nSeries)), 'Interpreter', 'none', 'Location', 'best');
% set(lg, 'FontSize', 16);
% 
% xlabel('Time');
% ylabel('Velocity (top layer)');
% grid on;

%% import model WL
load("P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\output\DFM.mat");    % T0 Apr-May 2018
ModelData(1).DFM = DFM;
load("P:\11207654-internship-pierce-2026\03_Model\14_T0bathy_T1groynes_Apr18\output\DFM.mat"); % T0 with groynes Apr 2018
ModelData(2).DFM = DFM;
load("P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\DFM.mat");         % T1 apr-may 2018
ModelData(3).DFM = DFM ;

% Create a folders cell array matching ModelData entries for plotting/legend use
folders = { 
          'T0',
          'T0 with Groynes',
          'T1'
          };

%% reading in model results for WL
nModels = numel(ModelData);
figure();

for ii = 1:nModels
    % Bath (index 15) and Wals (index 12)
    t_bath = ModelData(ii).DFM.wl(15).time;
    wl_bath = ModelData(ii).DFM.wl(15).val;
    t_wals = ModelData(ii).DFM.wl(12).time;
    wl_wals = ModelData(ii).DFM.wl(12).val;

    % datetime to datenum
    t_bath_num = datenum(t_bath);
    t_wals_num = datenum(t_wals);
    
    % use a colormap with nModels distinct colors and cycle using ii
    cmap = turbo(nModels);
    
    % --- plot Bath WL ---
    hold on
    plot(t_bath, wl_bath, '-', 'LineWidth', 1.5, 'Color', cmap(ii,:), 'DisplayName', sprintf('%s Bath', folders{ii}));
    hold off
    % xlabel('Time', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Water Level [m NAP]', 'FontSize', 16, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 18, 'XTickLabel', []);
    set(gca, 'FontSize', 18);
    xlim([t_bath(1) t_bath(end)])
    title('Bath', 'FontSize', 28, 'FontWeight', 'normal', 'FontAngle', 'italic');
    % title(sprintf('Bath: Model %s', folders{ii}), 'FontSize', 18, 'FontWeight', 'normal', 'FontAngle', 'italic');
    % place legend outside to the east, with larger font
    legend('show', 'Location', 'southeast', 'FontSize', 18, 'TextColor', 'k');
    
    % %--- plot Walsoorden WL ---
    % hold on
    % plot(t_wals, wl_wals, '-', 'LineWidth', 1.5, 'Color', cmap(ii,:), 'DisplayName', sprintf('%s Walsoorden', folders{ii}));
    % hold off
    % xlabel('Time', 'FontSize', 16, 'FontWeight', 'bold');
    % ylabel('Water Level [m NAP]', 'FontSize', 16, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 18);
    % xlim([t_wals(1) t_wals(end)]);
    % title('Walsoorden', 'FontSize', 28, 'FontWeight', 'normal', 'FontAngle', 'italic');
    % % title(sprintf('Walsoorden: Model %s', folders{ii}), 'FontSize', 18, 'FontWeight', 'bold');
    % legend('show', 'Location', 'southeast', 'FontSize', 18, 'TextColor', 'k');

    % % Add one large centered title for the entire figure
    % sgtitle(sprintf('Water Level', folders{ii}), 'FontSize', 24, 'FontWeight', 'bold');
end

%% import velocity field data
folders = { ...
    'P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\output\', ...
    'P:\11207654-internship-pierce-2026\03_Model\14_T0bathy_T1groynes_Apr18\output\', ...
    'P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\' ...
};

names = { 
          'T0',
          'T0 with Groynes',
          'T1'
          };

for i = 1:length(folders)
    ncFile = fullfile(folders{i}, 'WS_0000_map.nc');

    % choose date range depending on i
    if i == 1
        t0 = '1-May-2018 11:00:00';
        tend = '1-May-2018 23:00:00';
    end

    % read map/model data 
    DataXY{i} = EHY_getMapModelData(ncFile, 'varName', 'mesh2d_ucxa', 't0', t0, 'tend', tend, 'layer', '0');

    % Save all runs in one file
    outName = fullfile(pwd, 'VelData_1May.mat');
    save(outName, 'DataXY', 'names', 'folders');
    disp(['Saved: ' outName]);
end

%% bring in grid rom another mat file
FOU = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\FOU_Apr22-24_T0T1.mat'); %T0 and T1

for i = 1
    gridX = FOU.FOU(i).data.grid.face_nodes_x;
    gridY = FOU.FOU(i).data.grid.face_nodes_y;
end

%% convert flow field datenums to 'dd-mm-yyyy HH-MM'
time = cell(length(DataXY),1);
for i = 1
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

% %% plot flow field (alone)
% 
% nTimes = length(DataXY{1,1}.times);
% % nTimes = length(DataXY{1,1}.times(71:105,:));
% 
% for k = 1:nTimes
%     time_date = DataXY{1,1}.times(k);
%     figName = sprintf('Flow Field: %s \n', datestr(time_date, 'dd-mm-yyyy HH:MM'));
%     fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [200, 200, 800, 600]);
% 
%     % Use axes instead of subplot so it occupies the full window
%     ax = axes('Parent', fig);
%     tix = k; 
% 
%     % Compute hydro-mesh cell center geometry
%     if size(gridX,1) == 4
%         cx_run = mean(gridX,1);
%         cy_run = mean(gridY,1);
%     end
% 
%     % Extract velocity components
%     u = DataXY{1}.vel_x(tix,:); 
%     v = DataXY{1}.vel_y(tix,:);
% 
%     if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
%     if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
%     speed = sqrt(u.^2 + v.^2);
% 
%     % Plot mesh patches
%      patch(gridX, gridY, speed(:)', ...
%         'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%     hold(ax, 'on');
% 
%     % ---plot strekdammen nieuw + aangepast + bestaand--- (only for i == 2)
%     if i == 1
%         for k = 1:numel(Nieuw_x)
%             if ~isempty(Nieuw_x{k})
%                 hPol(end+1) = plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 4); %#ok<SAGROW>
%             end
%         end
%     end
%     hPol(3) = plot(ax, nan, nan, 'k-', 'LineWidth', 2); % placeholder for legend
% 
%     for ki = 1:numel(Aangepast_x)
%         if ~isempty(Aangepast_x{ki})
%         hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, 'r-','LineWidth', 4); %#ok<SAGROW>
%         end
%     end
%     hPol(1) = plot(nan, nan, 'r-', 'LineWidth', 2); % to use in
% 
%     for ki = 1:numel(Bestaand_x)
%         if ~isempty(Bestaand_x{ki})
%         hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 4); %#ok<SAGROW>
%         end
%     end
%     hPol(2) = hLine2;
% 
%     %========= Map geographic viewport=========
%     %Bath
%     xlim(ax, [69600 72900]);
%     ylim(ax, [378900 380600]);
% 
%     %Bath peak vel
%     % xlim(ax, [70000 71500]);
%     % ylim(ax, [379000 380000]);
% 
%     % %Bath ZOOM
%     % xlim(ax, [70500 71600]);
%     % ylim(ax, [379450 380100]);
% 
%     % Zimm
%     % xlim(ax, [64300 67200]);   % RDx in meters
%     % ylim(ax, [379300 380900]); % RDy in meters
% 
%     % %Zimm Zoom
%     % xlim(ax, [65200 67600]);
%     % ylim(ax, [379300 380400]);
% 
% 
%     % % ========= Map uniform 50m quiver arrows =========
%     % % 1. Get the current axis limits to grid only the visible viewport
%     % xl = xlim(ax);
%     % yl = ylim(ax);
%     % 
%     % % 2. Create a regular grid with exactly 50-meter spacing
%     % [x0, y0] = meshgrid(xl(1):50:xl(2), yl(1):50:yl(2));
%     % 
%     % % 3. Interpolate unstructured velocity field onto the 50m grid
%     % % 'none' prevents extrapolation of vectors outside your hydrodynamic domain boundaries
%     % F = scatteredInterpolant(cx_run(:), cy_run(:), u(:), 'linear', 'none');
%     % u_grid = F(x0, y0);
%     % F.Values = v(:); % Efficiently reuse the triangulation structure for the v-component
%     % v_grid = F(x0, y0);
%     % 
%     % % 4. Scale vectors consistently based on axis width
%     % vecScale = 0.8 * mean(diff(xl)) / sqrt(nanmean(u_grid(:).^2) + nanmean(v_grid(:).^2)) / 50;
%     % dx = u_grid * vecScale; 
%     % dy = v_grid * vecScale;
%     % 
%     % % 5. Plot the regularized quiver arrows
%     % quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);
%     % % ==========================================================
% 
%     % ========= Map uniform 50m quiver arrows (Uniform Length) =========
%     % 1. Get the current axis limits to grid only the visible viewport
%     xl = xlim(ax);
%     yl = ylim(ax);
% 
%     % 2. Create a regular grid with exactly 50-meter spacing
%     [x0, y0] = meshgrid(xl(1):70:xl(2), yl(1):70:yl(2));
% 
%     % 3. Filter out any NaN or Inf coordinates and velocities
%     isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & ...
%               isfinite(u(:))      & isfinite(v(:));
% 
%     cx_valid = cx_run(isValid);
%     cy_valid = cy_run(isValid);
%     u_valid  = u(isValid);
%     v_valid  = v(isValid);
% 
%     % 4. Interpolant using only finite data points
%     if ~isempty(cx_valid)
%         F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
%         u_grid = F(x0, y0);
% 
%         F.Values = v_valid(:); % Reuse structure for v-component
%         v_grid = F(x0, y0);
% 
%         % 5. Normalize the grid vectors to unit length (Magnitude = 1)
%         grid_speed = sqrt(u_grid.^2 + v_grid.^2);
%         u_norm = u_grid ./ grid_speed;
%         v_norm = v_grid ./ grid_speed;
% 
%         % 6. Define a fixed arrow length in meters (e.g., 15 meters long)
%         arrow_length_meters = 50; 
% 
%         dx = u_norm * arrow_length_meters; 
%         dy = v_norm * arrow_length_meters;
% 
%         % 7. Plot the uniform-length quiver arrows
%         % We pass 0 as the final scaling argument so MATLAB doesn't auto-scale them
%         quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.9, 'MaxHeadSize', 0.7);
%     end
%     % ==================================================================
% 
%   % % ========= Map uniform 50m quiver arrows inside KML boundary =========
%   %   xl = xlim(ax);
%   %   yl = ylim(ax);
%   % 
%   %   % Create a regular grid with exactly 50-meter spacing
%   %   [x0, y0] = meshgrid(xl(1):50:xl(2), yl(1):50:yl(2));
%   % 
%   %   % Filter out any NaN or Inf coordinates and velocities
%   %   isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & ...
%   %             isfinite(u(:))      & isfinite(v(:));
%   % 
%   %   cx_valid = cx_run(isValid);
%   %   cy_valid = cy_run(isValid);
%   %   u_valid  = u(isValid);
%   %   v_valid  = v(isValid);
%   % 
%   %   if ~isempty(cx_valid)
%   %       F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
%   %       u_grid = F(x0, y0);
%   % 
%   %       F.Values = v_valid(:); 
%   %       v_grid = F(x0, y0);
%   % 
%   %       % --- Mask using our converted RD coordinates ---
%   %       isInsideKML = inpolygon(x0, y0, poly_x, poly_y);
%   %       u_grid(~isInsideKML) = NaN;
%   %       v_grid(~isInsideKML) = NaN;
%   % 
%   %       % Normalize the grid vectors to unit length
%   %       grid_speed = sqrt(u_grid.^2 + v_grid.^2);
%   %       u_norm = u_grid ./ grid_speed;
%   %       v_norm = v_grid ./ grid_speed;
%   % 
%   %       % Define a fixed arrow length in meters
%   %       arrow_length_meters = 35; 
%   %       dx = u_norm * arrow_length_meters; 
%   %       dy = v_norm * arrow_length_meters;
%   % 
%   %       % Plot the uniform-length quiver arrows
%   %       quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);
%   % 
%   %       % OPTIONAL: Plot the KML boundary line itself so you can see it
%   %       hold(ax, 'on');
%   %       plot(ax, poly_x, poly_y, 'g--', 'LineWidth', 1.5); 
%   %   end
% 
%     % % Arrows: subsample for clarity
%     % nVectors = numel(cx_run);
%     % maxArrows = 4000;
%     % if nVectors > maxArrows
%     %     idx = round(linspace(1, nVectors, maxArrows));
%     % else
%     %     idx = 1:nVectors;
%     % end
%     % 
%     % % Scale vectors consistently based on axis width (increase arrow length)
%     % axUnits = get(ax, 'Units'); set(ax, 'Units', 'normalized');
%     % axPos = get(ax, 'Position'); set(ax, 'Units', axUnits);
%     % % Use a larger base multiplier to increase arrow lengths (was 0.2)
%     % vecScale = 0.8 * mean(diff(xlim)) / sqrt(nanmean(u(idx).^2)+nanmean(v(idx).^2)) / 50;
%     % 
%     % x0 = cx_run(idx); y0 = cy_run(idx);
%     % dx = u(idx) * vecScale; dy = v(idx) * vecScale;
%     % % Slightly increase linewidth for visibility
%     % quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);
% 
%     % Format Axes labels into uniform Kilometers units
%     xlabel(ax, 'RDx (km)', 'FontSize', 12);
%     ylabel(ax, 'RDy (km)', 'FontSize', 12);
%     daspect(ax, [1 1 1]);
% 
%     % Keep tick positions in meters but label in kilometers
%     xl = xlim(ax); yl = ylim(ax);
%     xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
%     yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
%     xk = (xk_min : 1.0 : xk_max);            
%     yk = (yk_min : 0.5 : yk_max);            
%     set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
%     set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%            'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
% 
%     % Plot Title
%     title(ax, figName, 'FontSize', 14, 'FontWeight', 'bold');
% 
% 
%     nLevels = 12;
%     cmap_flow = parula(nLevels); % Calls your custom viridis generator
%     colormap(ax1, cmap_flow);
%     clim(ax1, [0 1.2]);
%     % Force patch face colors to use discrete bins by mapping data to integer indices
%     ch = findobj(ax, '-property', 'CData');
%     for c = 1:numel(ch)
%         C = get(ch(c), 'CData');
%         if isnumeric(C)
%             % Normalize to [0,1], clamp, then map to 1:nLevels
%             Cnorm = (C - 0) ./ (1 - 0);
%             Cnorm = min(max(Cnorm, 0), 1);
%             Cidx = round(Cnorm * (nLevels-1)) + 1;
%             % Set CData to indexed colors via surface-like coloring:
%             % Replace numeric scalar per-face with RGB triplets
%             if isvector(Cidx)
%                 rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
%                 % For patch with FaceColor 'flat', set CData to indices and set FaceVertexCData
%                 try
%                     set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
%                 catch
%                     % Fallback: set CData to original normalized values (colormap still enforces discrete steps)
%                     set(ch(c), 'CData', Cnorm);
%                 end
%             else
%                 set(ch(c), 'CData', Cnorm);
%             end
%         end
%     end
%     hold(ax, 'off');
% 
%     % colobar
%     cb = colorbar(ax);
%     cb.Label.String = 'Speed (m/s)';
% end

% %% plotting one velocity field next to water level
% nTimes = length(DataXY{1,1}.times);
% 
% for i = 1:nModels
%     for k = 1:nTimes
%         time_date = DataXY{i}.times(k);
%         figName = sprintf('Flow Field %s: %s', names{i}, datestr(time_date, 'dd-mm-yyyy HH:MM'));
% 
%         % 1. Create a wide canvas for the side-by-side plots
%         fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [100, 100, 1400, 600]);
% 
%         % 2. Establish the 70% / 30% split using a 1x10 tiledlayout grid
%         tlo = tiledlayout(fig, 1, 10, 'TileSpacing', 'compact', 'Padding', 'compact');
% 
%         % ==================================================================
%         % PANEL 1: FLOW FIELD (Takes up 7 columns -> 70% width)
%         % ==================================================================
%         ax1 = nexttile(tlo, [1, 7]);
%         hold(ax1, 'on');
% 
%         tix = k; 
% 
%         % Compute hydro-mesh cell center geometry
%         if size(gridX,1) == 4
%             cx_run = mean(gridX,1);
%             cy_run = mean(gridY,1);
%         end
% 
%         % Extract velocity components
%         u = DataXY{1,i}.vel_x(tix,:); 
%         v = DataXY{1,i}.vel_y(tix,:);
%         if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
%         if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
%         speed = sqrt(u.^2 + v.^2);
% 
%         % Plot mesh patches
%         patch(gridX, gridY, speed(:)', 'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax1, 'FaceAlpha', 0.9);
% 
%         % --- Plot strekdammen  ---
%         for ki = 1:numel(Nieuw_x)
%             if ~isempty(Nieuw_x{ki})
%                 plot(ax1, Nieuw_x{ki}, Nieuw_y{ki}, 'w-', 'LineWidth', 3);
%             end
%         end
% 
%         for ki = 1:numel(Aangepast_x)
%             if ~isempty(Aangepast_x{ki})
%                 plot(ax1, Aangepast_x{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 3);
%             end
%         end
%         for ki = 1:numel(Aangepast_x)
%             if ~isempty(Aangepast_x{ki})
%                 plot(ax1, Aangepast_x{ki}, Aangepast_y{ki}, 'w--','LineWidth', 2);
%             end
%         end
% 
% 
%         for ki = 1:numel(Bestaand_x)
%             if ~isempty(Bestaand_x{ki})
%                  plot(ax1, Bestaand_x{ki}, Bestaand_y{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 3);
%             end
%         end
% 
%         for ki = 1
%             plot(ax1, Bestaand_x{ki}, Bestaand_y{ki}, 'w--','LineWidth', 1.5);
%         end
% 
%         % ========= Map Geographic Viewport =========
%         loc = 'Bath';
%         % xlim(ax1, [69600 72900]);
%         % ylim(ax1, [378850 380550]);
%         xlim(ax1, [69700 72900]);
%         ylim(ax1, [378900 380550]);
% 
%         % loc = 'Zimm';
%         % xlim(ax1, [64000 68100]);
%         % ylim(ax1, [379200 381000]);
% 
%         % ========= Uniform Quiver Arrows (Fixed Length) =========
%         xl = xlim(ax1);
%         yl = ylim(ax1);
%         [x0, y0] = meshgrid(xl(1):80:xl(2), yl(1):80:yl(2));
% 
%         isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(u(:)) & isfinite(v(:));
%         cx_valid = cx_run(isValid); cy_valid = cy_run(isValid);
%         u_valid  = u(isValid);      v_valid  = v(isValid);
% 
%         if ~isempty(cx_valid)
%             F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
%             u_grid = F(x0, y0);
%             F.Values = v_valid(:); 
%             v_grid = F(x0, y0);
% 
%             grid_speed = sqrt(u_grid.^2 + v_grid.^2);
%             u_norm = u_grid ./ grid_speed;
%             v_norm = v_grid ./ grid_speed;
% 
%             arrow_length_meters = 60; 
%             dx = u_norm * arrow_length_meters; 
%             dy = v_norm * arrow_length_meters;
% 
%             quiver(ax1, x0, y0, dx, dy, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.1);
%         end
% 
%         % ========= Format Axes into Kilometers Units =========
%         xlabel(ax1, 'RDx [km]', 'FontSize', 16, 'FontWeight', 'bold');
%         ylabel(ax1, 'RDy [km]', 'FontSize', 16, 'FontWeight', 'bold');
%         daspect(ax1, [1 1 1]);
% 
%         xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
%         yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
%         xk = (xk_min : 1.0 : xk_max);            
%         yk = (yk_min : 0.5 : yk_max);            
%         set(ax1, 'XTick', xk*1000, 'YTick', yk*1000);
%         set(ax1, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%                  'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false), ...
%                  'FontSize', 15);
% 
%         % title(ax1, figName, 'FontSize', 15, 'FontWeight', 'bold');
% 
%         % ========= Apply Discrete Colormap Levels =========
%         nLevels = 12;
%         cmap_flow = parula(nLevels);
%         colormap(ax1, cmap_flow);
%         clim(ax1, [0 1.2]);
% 
%         ch = findobj(ax1, '-property', 'CData');
%         for c = 1:numel(ch)
%             C = get(ch(c), 'CData');
%             if isnumeric(C)
%                 Cnorm = (C - 0) ./ (1.2 - 0); % Clamped normalized to clim max (1.2)
%                 Cnorm = min(max(Cnorm, 0), 1);
%                 Cidx = round(Cnorm * (nLevels-1)) + 1;
%                 if isvector(Cidx)
%                     rgb = reshape(cmap_flow(Cidx(:),:), [size(Cidx(:),1), 3]);
%                     try
%                         set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
%                     catch
%                         set(ch(c), 'CData', Cnorm);
%                     end
%                 else
%                     set(ch(c), 'CData', Cnorm);
%                 end
%             end
%         end
% 
% 
%         % Place a reduced-width colorbar below ax1 inside the tiled layout
%         cb = colorbar(ax1, 'southoutside'); 
%         cb.Label.String = 'Maximum Velocity [m/s]';
%         cb.Label.FontSize = 15;
%         cb.Units = 'normalized';
%         % Shrink the colorbar width to 70% of the axis width and center it
%         ax1_pos = ax1.Position;                      % [left bottom width height] in normalized units (tile-relative)
%         cb_width_frac = 0.60;                        % desired fraction of axis width
%         cb_height = cb.Position(4);                  % keep the default height
%         cb_left = ax1_pos(1) + (ax1_pos(3) - ax1_pos(3)*cb_width_frac)/2; % center beneath axis
%         cb.Position = [cb_left, cb.Position(2)-0.02, ax1_pos(3)*cb_width_frac, cb_height];
%         hold(ax1, 'off');
% 
%        % ==================================================================
%         % PANEL 2: WATER LEVEL SIGNAL (Takes up 3 columns -> 30% width)
%         % ==================================================================
%         ax2 = nexttile(tlo, [1, 3]);
%         hold(ax2, 'on');
% 
%         % 1. Convert the current numeric frame time into a datetime object
%         current_time_dt = datetime(DataXY{1,1}.times(k), 'ConvertFrom', 'datenum'); 
% 
%         % 2. Define the dynamic window boundaries using datetime durations (+/- 6 hours)
%         WL_window_min = current_time_dt - hours(6); 
%         WL_window_max = current_time_dt + hours(6);
% 
%         % 3. Plot the water level series (t_wals is natively datetime)
%         plot(ax2, t_bath, wl_bath, '-', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off'); 
% 
%         % % 4. Locate and plot the syncing indicator dot using datetime math
%             % WALS
%             % [~, closest_idx] = min(abs(t_wals - current_time_dt));
%             % plot(ax2, t_wals(closest_idx), wl_wals(closest_idx), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10, ...
%             %      'DisplayName', ['Current: ', datestr(current_time_dt, 'HH:MM')]);
%             % BATH
%             [~, closest_idx] = min(abs(t_bath - current_time_dt));
%             plot(ax2, t_bath(closest_idx), wl_bath(closest_idx), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10, ...
%                  'DisplayName', ['Current: ', datestr(current_time_dt, 'HH:MM')]);
% 
%         % 5. Clip the window viewport dynamically using the datetime limits
%         xlim(ax2, [WL_window_min, WL_window_max]); 
% 
%         % Convert specified string start/end times to datenum and restrict x-limits if within window
%         t0_dn = datenum(t0, 'dd-mmm-yyyy HH:MM:SS');
%         tend_dn = datenum(tend, 'dd-mmm-yyyy HH:MM:SS');
% 
%         % Convert datenums to datetime for compatibility with datetime x-axis
%         t0_dt = datetime(t0_dn, 'ConvertFrom', 'datenum') - 0.25;
%         tend_dt = datetime(tend_dn, 'ConvertFrom', 'datenum') + 0.25;
% 
%         % If the requested interval overlaps the current WL window, set x-limits to that interval
%         if tend_dt > WL_window_min && t0_dt < WL_window_max
%             % Clip to the existing WL window bounds to avoid showing outside range
%             xlim(ax2, [max(WL_window_min, t0_dt), min(WL_window_max, tend_dt)]);
%         end
% 
%         % 6. Clean generation of x-axis ticks for datetime axes (every 2 hours)
%         set(ax2, 'XTick', t0_dt : hours(3) : tend_dt);
% 
%         % Format native datetime ticks into readable strings (No datetick required!)
%         xtickformat(ax2, 'HH:mm');
%         xtickangle(ax2, 30);
%         set(ax2, 'FontSize', 14);
% 
%         % Labels and details
%         % title(ax2, 'Water Level Signal', 'FontSize', 20, 'FontWeight', 'bold');
%         xlabel(ax2, 'Time', 'FontSize', 17, 'FontWeight', 'bold');
%         ylabel(ax2, 'Water Level [m]', 'FontSize', 17, 'FontWeight', 'bold');
%         grid(ax2, 'off');
%         lg = legend(ax2, 'Location', 'southoutside', 'Box', 'off');
%         lg.FontSize = 16;
%         hold(ax2, 'off');
% 
%         % =====FORCE EQUAL Y-HEIGHT IN BOTH PANELS====
%         drawnow; 
% 
%         % Get the current positions of both axes in pixels
%         set(ax1, 'Units', 'pixels');
%         set(ax2, 'Units', 'pixels');
%         pos1 = get(ax1, 'Position'); % [left, bottom, width, height]
%         pos2 = get(ax2, 'Position');
% 
%         % Force ax2 to share ax1's calculated height and vertical alignment
%         pos2(4) = pos1(4); % Match height
%         pos2(2) = pos1(2); % Match bottom alignment
%         set(ax2, 'Position', pos2);
% 
%         % Restore units back to normal layout management
%         set(ax1, 'Units', 'normalized');
%         set(ax2, 'Units', 'normalized');
% 
%         % === legend =====
%         lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.09, 0.2, 0.05]);
%         hold(lgdAxes, 'on');
%         h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'New Groyne');
%         h_groyne_ch = plot(lgdAxes, NaN, NaN, 'k--', 'LineWidth', 3, 'DisplayName', 'Modified');
%         h_groyne_ex = plot(lgdAxes, NaN, NaN,  '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 2.5, 'DisplayName', 'Existing Groyne');
%         % lgd = legend(lgdAxes, [h_groyne, h_groyne_ch, h_groyne_ex], 'Location', 'southwest', 'Orientation', 'vertical');
%         % set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
%         % set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 
% 
%         lgd = legend(ax2, [h_groyne, h_groyne_ch, h_groyne_ex], 'Orientation', 'vertical');
%         set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
%         lgd.Position = [0.22, 0.11, 0.2, 0.05];  %[left, bottom, width, height]
% 
%         % % ========== Export current tiled layout to PNG ==========
%         % % Build safe output directory and filename, replacing invalid filename chars
%         % outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\flowfield_WL\T1';
%         % if ~exist(outDir, 'dir')
%         %     mkdir(outDir);
%         % end
%         % % Sanitize figName to remove characters invalid for filenames (e.g. : / \ ? * " < > |)
%         % invalidChars = '[:\/\?\*\<\>\"\\\|]';
%         % safeName = regexprep(figName, invalidChars, '-');
%         % safeName = strtrim(safeName); % remove leading/trailing spaces
%         % if isempty(safeName)
%         %     safeName = 'figure';
%         % end
%         % frameStr = sprintf('_%s', loc);
%         % outFile = fullfile(outDir, [safeName, frameStr, '.png']);
%         % exportgraphics(tlo, outFile, 'Resolution', 300);
%     end
% end

%% plotting 2 velocity field (T0,T1) next to water level & legend
nTimes = length(DataXY{1,1}.times);

for k = 1:nTimes
    time_date = DataXY{i}.times(k);
    figName = sprintf('Flow Field T0 T0wG: %s', datestr(time_date, 'dd-mm-yyyy HH:MM'));
          
    fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [100, 100, 1400, 1000]); 
    tlo = tiledlayout(fig, 2, 10, 'TileSpacing', 'compact', 'Padding', 'compact');

    cx_run = mean(gridX,1);
    cy_run = mean(gridY,1);
    
    % % =========================================================================
    % % 0. MASKING STEP 
    % % =========================================================================
    % % cx_run = cx_run(:);
    % % cy_run = cy_run(:);
    % speed = speed(:);
    % u = u(:);
    % v = v(:);
    % % If residuals variable exists use it, otherwise create placeholder
    % if ~isempty(cx_valid)
    %     F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
    %     u_grid = F(x0, y0);
    %     F.Values = v_valid(:); 
    %     v_grid = F(x0, y0);
    % 
    %     cx_run = cx_run;
    %     cy_run = cy_run;
    % 
    %     % ========= MASK QUIVER TO POLYGON =========
    %     inside_quiver = false(size(x0));
    %     for ki = 1:length(flowfield_x)
    %         inside_quiver = inside_quiver | inpolygon(x0, y0, flowfield_x{ki}, flowfield_y{ki});
    %     end
    %     u_grid(~inside_quiver) = NaN;
    %     v_grid(~inside_quiver) = NaN;
    %     % ==========================================
    % 
    %     grid_speed = sqrt(u_grid.^2 + v_grid.^2);
    %     u_norm = u_grid ./ grid_speed;
    %     v_norm = v_grid ./ grid_speed;
    % 
    %     arrow_length_meters = 60; 
    %     dx = u_norm * arrow_length_meters; 
    %     dy = v_norm * arrow_length_meters;
    % 
    %     quiver(ax1, x0, y0, dx, dy, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.1);  % ← crash here
    % end
    % ==================================================================
    % PANEL 1: FLOW FIELD (Takes up 7 columns -> 70% width)
    % ==================================================================
    ax1 = nexttile(tlo, 1, [1, 7]);
    hold(ax1, 'on');
    
    % STEP 2 — extract data
    tix = k;
    u = DataXY{1,1}.vel_x(tix,:);
    v = DataXY{1,1}.vel_y(tix,:);
    if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
    if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
    speed = sqrt(u.^2 + v.^2);
    
    % ========= MASK PATCH TO POLYGON =========
    cx_flat = cx_run(:);   % force column
    cy_flat = cy_run(:);   % force column
    inside_patch = false(numel(cx_flat), 1);
    for ki = 1:length(flowfield_x)
        inside_patch = inside_patch | inpolygon(cx_flat, cy_flat, flowfield_x{ki}, flowfield_y{ki});
    end
    speed = speed(:);
    speed(~inside_patch) = NaN;
    % ==========================================
    
    patch(gridX, gridY, speed(:)', 'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax1, 'FaceAlpha', 0.9);
    
    % ========= OVERLAY WHITE ON CELLS OUTSIDE POLYGON =========
    outside_patch = ~inside_patch;
    if any(outside_patch)
        patch(gridX(:, outside_patch), gridY(:, outside_patch), ...
            ones(1, sum(outside_patch)), ...
            'EdgeColor', 'none', 'FaceColor', 'white', 'Parent', ax1, 'FaceAlpha', 1);
    end
    
    % --- Plot strekdammen  ---
    for ki = 1:numel(Nieuw_x)
        if ~isempty(Nieuw_x{ki})
            plot(ax1, Nieuw_x{ki}, Nieuw_y{ki}, 'r-', 'LineWidth', 4);
        end
    end
    
    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
            plot(ax1, Aangepast_x{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 4);
        end
    end
    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
            plot(ax1, Aangepast_x{ki}, Aangepast_y{ki}, 'r--','LineWidth', 3);
        end
    end
    
    
    for ki = 1:numel(Bestaand_x)
        if ~isempty(Bestaand_x{ki})
             plot(ax1, Bestaand_x{ki}, Bestaand_y{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 4);
        end
    end
    
    for ki = 1
        plot(ax1, Bestaand_x{ki}, Bestaand_y{ki}, 'r--','LineWidth', 2);
    end
    
    % ========= Map Geographic Viewport =========
    loc = 'Bath';
    % xlim(ax1, [69600 72900]);
    % ylim(ax1, [378850 380550]);
    xlim(ax1, [69900 72500]);
    ylim(ax1, [378900 380100]);

    % loc = 'Zimm';
    % xlim(ax1, [64000 68100]);
    % ylim(ax1, [379200 381000]);
    
   xl = xlim(ax1); yl = ylim(ax1);
    [x0, y0] = meshgrid(xl(1):70:xl(2), yl(1):70:yl(2));
    
    isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(u(:)) & isfinite(v(:));
    cx_valid = cx_run(isValid); cy_valid = cy_run(isValid);
    u_valid  = u(isValid);      v_valid  = v(isValid);
    
    if ~isempty(cx_valid)
        F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
        u_grid = F(x0, y0);
        F.Values = v_valid(:);
        v_grid = F(x0, y0);
    
        % mask quiver to polygon
        inside_quiver = false(size(x0));
        for ki = 1:length(flowfield_x)
            inside_quiver = inside_quiver | inpolygon(x0, y0, flowfield_x{ki}, flowfield_y{ki});
        end
        u_grid(~inside_quiver) = NaN;
        v_grid(~inside_quiver) = NaN;
    
        grid_speed = sqrt(u_grid.^2 + v_grid.^2);
        u_norm = u_grid ./ grid_speed;
        v_norm = v_grid ./ grid_speed;
        dx = u_norm * 50;
        dy = v_norm * 50;
        quiver(ax1, x0, y0, dx, dy, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.1);
    end

    
    % ========= Format Axes into Kilometers Units =========
    % xlabel(ax1, 'RDx [km]', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel(ax1, 'RDy [km]', 'FontSize', 16, 'FontWeight', 'bold');
    daspect(ax1, [1 1 1]);
    
    % xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
    yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
    % xk = (xk_min : 1.0 : xk_max);            
    yk = (yk_min : 0.5 : yk_max);            
    % remove x tick labels, format y tick labels in km
    set(ax1, ...
        'XTickLabel', [], ...
        'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false), ...
        'FontSize', 15);
         
    % title(ax1, figName, 'FontSize', 15, 'FontWeight', 'bold');
    
    % ========= Apply Discrete Colormap Levels =========
    nLevels = 8;
    cmap_flow = parula(nLevels);
    colormap(ax1, cmap_flow);
    clim(ax1, [0 0.8]);
    
    ch = findobj(ax1, '-property', 'CData');
    for c = 1:numel(ch)
        C = get(ch(c), 'CData');
        if isnumeric(C)
            Cnorm = (C - 0) ./ (0.8 - 0); % Clamped normalized to clim max (1.2)
            Cnorm = min(max(Cnorm, 0), 1);
            Cidx = round(Cnorm * (nLevels-1)) + 1;
            if isvector(Cidx)
                rgb = reshape(cmap_flow(Cidx(:),:), [size(Cidx(:),1), 3]);
                try
                    set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
                catch
                    set(ch(c), 'CData', Cnorm);
                end
            else
                set(ch(c), 'CData', Cnorm);
            end
        end
    end
    
    
    % % Place a reduced-width colorbar below ax1 inside the tiled layout
    % cb = colorbar(ax1, 'southoutside'); 
    % cb.Label.String = 'Maximum Velocity [m/s]';
    % cb.Label.FontSize = 15;
    % cb.Units = 'normalized';
    % % Shrink the colorbar width to 70% of the axis width and center it
    % ax1_pos = ax1.Position;                      % [left bottom width height] in normalized units (tile-relative)
    % cb_width_frac = 0.60;                        % desired fraction of axis width
    % cb_height = cb.Position(4);                  % keep the default height
    % cb_left = ax1_pos(1) + (ax1_pos(3) - ax1_pos(3)*cb_width_frac)/2; % center beneath axis
    % cb.Position = [cb_left, cb.Position(2)-0.02, ax1_pos(3)*cb_width_frac, cb_height];
    hold(ax1, 'off');

   % ==================================================================
    % PANEL 2: WATER LEVEL SIGNAL (Takes up 3 columns -> 30% width)
    % ==================================================================
    ax2 = nexttile(tlo, 8, [1, 3]);   % row 1, columns 8-10
    hold(ax2, 'on');
    
    % 1. Convert the current numeric frame time into a datetime object
    current_time_dt = datetime(DataXY{1,1}.times(k), 'ConvertFrom', 'datenum'); 
    
    % 2. Define the dynamic window boundaries using datetime durations (+/- 6 hours)
    WL_window_min = current_time_dt - hours(6); 
    WL_window_max = current_time_dt + hours(6);
    
    % 3. Plot the water level series (t_wals is natively datetime)
    plot(ax2, t_bath, wl_bath, '-', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off'); 
    
    % % 4. Locate and plot the syncing indicator dot using datetime math
        % WALS
        % [~, closest_idx] = min(abs(t_wals - current_time_dt));
        % plot(ax2, t_wals(closest_idx), wl_wals(closest_idx), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10, ...
        %      'DisplayName', ['Current: ', datestr(current_time_dt, 'HH:MM')]);
        % BATH
        [~, closest_idx] = min(abs(t_bath - current_time_dt));
        plot(ax2, t_bath(closest_idx), wl_bath(closest_idx), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10, ...
             'DisplayName', ['Current: ', datestr(current_time_dt, 'HH:MM')]);
    
    % 5. Clip the window viewport dynamically using the datetime limits
    xlim(ax2, [WL_window_min, WL_window_max]); 
    
    % Convert specified string start/end times to datenum and restrict x-limits if within window
    t0_dn = datenum(t0, 'dd-mmm-yyyy HH:MM:SS');
    tend_dn = datenum(tend, 'dd-mmm-yyyy HH:MM:SS');

    % Convert datenums to datetime for compatibility with datetime x-axis
    t0_dt = datetime(t0_dn, 'ConvertFrom', 'datenum') - 0.25;
    tend_dt = datetime(tend_dn, 'ConvertFrom', 'datenum') + 0.25;

    % If the requested interval overlaps the current WL window, set x-limits to that interval
    if tend_dt > WL_window_min && t0_dt < WL_window_max
        % Clip to the existing WL window bounds to avoid showing outside range
        xlim(ax2, [max(WL_window_min, t0_dt), min(WL_window_max, tend_dt)]);
    end
    
    % 6. Clean generation of x-axis ticks for datetime axes (every 2 hours)
    set(ax2, 'XTick', t0_dt : hours(3) : tend_dt);
    
    % Format native datetime ticks into readable strings (No datetick required!)
    xtickformat(ax2, 'HH:mm');
    xtickangle(ax2, 30);
    set(ax2, 'FontSize', 14);
    
    % Labels and details
    % title(ax2, 'Water Level Signal', 'FontSize', 20, 'FontWeight', 'bold');
    xlabel(ax2, 'Time', 'FontSize', 17, 'FontWeight', 'bold');
    ylabel(ax2, 'Water Level [m]', 'FontSize', 17, 'FontWeight', 'bold');
    grid(ax2, 'off');
    % lg = legend(ax2, 'Location', 'southoutside', 'Box', 'off');
    % lg.FontSize = 16;
    hold(ax2, 'off');

  
    % ==================================================================
    % PANEL 3 (bottom-left): FLOW FIELD row 2 — 70% width
    % ==================================================================
    ax3 = nexttile(tlo, 11, [1, 7]);
    hold(ax3, 'on');
    
    tix = k;
    
    % Compute hydro-mesh cell center geometry
    if size(gridX,1) == 4
        cx_run = mean(gridX,1);
        cy_run = mean(gridY,1);
    end
    
    % Extract velocity components — T0wGroynes = DataXY{1,2}; T1 = DataXY{1,3}?
    u = DataXY{1,2}.vel_x(tix,:);   % ← adjust index
    v = DataXY{1,2}.vel_y(tix,:);
    if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
    if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
    speed = sqrt(u.^2 + v.^2);
    
   % ========= MASK PATCH TO POLYGON =========
    cx_flat = cx_run(:);   % force column
    cy_flat = cy_run(:);   % force column
    inside_patch = false(numel(cx_flat), 1);
    for ki = 1:length(flowfield_x)
        inside_patch = inside_patch | inpolygon(cx_flat, cy_flat, flowfield_x{ki}, flowfield_y{ki});
    end
    speed = speed(:);
    speed(~inside_patch) = NaN;
    % ==========================================
    
    patch(gridX, gridY, speed(:)', 'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax3, 'FaceAlpha', 0.9);
    
    % ========= OVERLAY WHITE ON CELLS OUTSIDE POLYGON =========
    outside_patch = ~inside_patch;
    if any(outside_patch)
        patch(gridX(:, outside_patch), gridY(:, outside_patch), ...
            ones(1, sum(outside_patch)), ...
            'EdgeColor', 'none', 'FaceColor', 'white', 'Parent', ax3, 'FaceAlpha', 1);
    end
    
    % --- Plot strekdammen ---
    for ki = 1:numel(Nieuw_x)
        if ~isempty(Nieuw_x{ki})
            plot(ax3, Nieuw_x{ki}, Nieuw_y{ki}, 'r-', 'LineWidth', 4);
        end
    end
    
    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
            plot(ax3, Aangepast_x{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 4);
        end
    end
    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
            plot(ax3, Aangepast_x{ki}, Aangepast_y{ki}, 'r--', 'LineWidth', 3);
        end
    end
    
    for ki = 1:numel(Bestaand_x)
        if ~isempty(Bestaand_x{ki})
            plot(ax3, Bestaand_x{ki}, Bestaand_y{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 4);
        end
    end
    
    for ki = 1
        plot(ax3, Bestaand_x{ki}, Bestaand_y{ki}, 'r--', 'LineWidth', 2);
    end
    
    % ========= Map Geographic Viewport =========
    xlim(ax3, [69900 72500]);
    ylim(ax3, [378900 380100]);
    
    % ========= Uniform Quiver Arrows (Fixed Length) =========
    xl = xlim(ax3);
    yl = ylim(ax3);
    [x0, y0] = meshgrid(xl(1):70:xl(2), yl(1):70:yl(2));
    
    isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(u(:)) & isfinite(v(:));
    cx_valid = cx_run(isValid); cy_valid = cy_run(isValid);
    u_valid  = u(isValid);      v_valid  = v(isValid);
    
    if ~isempty(cx_valid)
        F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
        u_grid = F(x0, y0);
        F.Values = v_valid(:);
        v_grid = F(x0, y0);
    
        % ========= MASK QUIVER TO POLYGON =========
        inside_quiver = false(size(x0));
        for ki = 1:length(flowfield_x)
            inside_quiver = inside_quiver | inpolygon(x0, y0, flowfield_x{ki}, flowfield_y{ki});
        end
        u_grid(~inside_quiver) = NaN;
        v_grid(~inside_quiver) = NaN;
        % ==========================================
    
        grid_speed = sqrt(u_grid.^2 + v_grid.^2);
        u_norm = u_grid ./ grid_speed;
        v_norm = v_grid ./ grid_speed;
    
        arrow_length_meters = 50;
        dx = u_norm * arrow_length_meters;
        dy = v_norm * arrow_length_meters;
    
        quiver(ax3, x0, y0, dx, dy, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.1);
    end
    
    % ========= Format Axes =========
    xlabel(ax3, 'RDx [km]', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel(ax3, 'RDy [km]', 'FontSize', 16, 'FontWeight', 'bold');
    daspect(ax3, [1 1 1]);
    
    xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
    yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
    xk = (xk_min : 1.0 : xk_max);
    yk = (yk_min : 0.5 : yk_max);
    set(ax3, 'XTick', xk*1000, 'YTick', yk*1000);
    set(ax3, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
             'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false), ...
             'FontSize', 15);
    
    % ========= Colormap =========
    nLevels = 8;
    cmap_flow = parula(nLevels);
    colormap(ax3, cmap_flow);
    clim(ax3, [0 0.8]);
    
    ch = findobj(ax3, '-property', 'CData');
    for c = 1:numel(ch)
        C = get(ch(c), 'CData');
        if isnumeric(C)
            Cnorm = min(max((C - 0) ./ 0.8, 0), 1);
            Cidx = round(Cnorm * (nLevels-1)) + 1;
            if isvector(Cidx)
                rgb = reshape(cmap_flow(Cidx(:),:), [size(Cidx(:),1), 3]);
                try
                    set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
                catch
                    set(ch(c), 'CData', Cnorm);
                end
            else
                set(ch(c), 'CData', Cnorm);
            end
        end
    end
    
    % Colorbar to the east outside of ax3, vertical orientation
    cb3 = colorbar(ax3, 'eastoutside');
    cb3.Label.String = 'Maximum Velocity [m/s]';
    cb3.Label.FontSize = 15;
    cb3.Label.FontWeight = 'bold';
    cb3.Direction = 'normal';      % ensure vertical increasing upward
    cb3.Location = 'eastoutside';
    cb3.Orientation = 'vertical';
    cb3.Units = 'normalized';
    ax3_pos = ax3.Position;
    cb_width_frac = 0.04;          % narrower fraction for a vertical colorbar
    cb_gap = 0.04;                 % small gap between axis and colorbar
    cb_height = ax3_pos(4) * 0.8;
    cb_left = ax3_pos(1) + ax3_pos(3) + cb_gap;
    % Center the reduced-height colorbar vertically alongside ax3
    cb_bottom = ax3_pos(2) + (ax3_pos(4) - cb_height) / 2;

    cb3.Position = [cb_left, cb_bottom, ax3_pos(3)*cb_width_frac, cb_height];
    
    hold(ax3, 'off');

     % ==================================================================
    % PANEL 4 (bottom-right): LEGEND — 30% width
    % ==================================================================
    ax4 = nexttile(tlo, 18, [1, 3]);  % row 2, columns 8-10
    hold(ax4, 'on');
    axis(ax4, 'off');
   
    xref = 0; yref = 0; refU = 1; refV = 0;
    hRef = quiver(ax4, xref, yref, refU, refV, 0, 'k', ...
     'LineWidth', 3, 'MaxHeadSize', 2);

    
    % Move legend here instead of floating lgdAxes
    h_groyne    = plot(ax4, NaN, NaN, 'r-',  'LineWidth', 4,   'DisplayName', 'New Groyne');
    h_groyne_ch = plot(ax4, NaN, NaN, 'r--', 'LineWidth', 3,   'DisplayName', 'Modified');
    h_groyne_ex = plot(ax4, NaN, NaN, '-',   'Color', [0.35 0.35 0.35], 'LineWidth', 3, 'DisplayName', 'Existing Groyne');
    WL_time = plot(ax4,  NaN, NaN, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10, ...
             'DisplayName', ['Current: ', datestr(current_time_dt, 'HH:MM')]);

    % Ensure the reference quiver appears in the legend
    hRef.Annotation.LegendInformation.IconDisplayStyle = 'on';

    % Prepare legend handles and labels
    legHandles = [h_groyne, h_groyne_ch, h_groyne_ex];
    legLabels  = {'New Groyne', 'Modified', 'Existing Groyne'};

    axTarget = ax4;
    % Append reference handle and label
    legHandles(end+1) = hRef;
    legLabels{end+1}  = 'Flow Direction';

    % Restrict axis limits so the physical arrow is outside the visible region
    % Choose limits that do not overlap the legend area (these are arbitrary offsets
    % for a blank legend tile).
    try
        xlim(axTarget, [10 20]);
        ylim(axTarget, [10 20]);
    catch
        % If setting limits fails (e.g. for log axes), ignore and proceed
    end

    % Turn axis visuals off but keep legend-able objects present
    axis(axTarget, 'off');

    % 4. Generate the legend sitting cleanly on the blank tile
    if ~isempty(legHandles)
        lgd = legend(axTarget, legHandles, legLabels, ...
            'Orientation', 'vertical', 'Box', 'off', 'FontSize', 16, ...
            'Interpreter', 'none', 'TextColor', 'k', 'Location', 'east');
    end
        
    hold(ax4, 'off');

    title(ax1, names{1}, 'FontSize', 24, 'FontWeight', 'bold');
    title(ax3, names{2}, 'FontSize', 24, 'FontWeight', 'bold');

    % =====FORCE EQUAL Y-HEIGHT IN BOTH PANELS====
    drawnow; 
 
    % Get the current positions of both axes in pixels
    set(ax1, 'Units', 'pixels');
    set(ax2, 'Units', 'pixels');
    pos1 = get(ax1, 'Position'); % [left, bottom, width, height]
    pos2 = get(ax2, 'Position');

    % Force ax2 to share ax1's calculated height and vertical alignment
    pos2(4) = pos1(4); % Match height
    pos2(2) = pos1(2); % Match bottom alignment
    set(ax2, 'Position', pos2);
    
    % Restore units back to normal layout management
    set(ax1, 'Units', 'normalized');
    set(ax2, 'Units', 'normalized');

    set(ax3, 'Units', 'pixels');
    set(ax4, 'Units', 'pixels');
    pos3 = get(ax3, 'Position');
    pos4 = get(ax4, 'Position');
    pos4(4) = pos3(4);
    pos4(2) = pos3(2);
    set(ax4, 'Position', pos4);
    set(ax3, 'Units', 'normalized');
    set(ax4, 'Units', 'normalized');

    % ========== Export current tiled layout to PNG ==========
    % Build safe output directory and filename, replacing invalid filename chars
    outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\flowfield_WL\T1';
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    % Sanitize figName to remove characters invalid for filenames (e.g. : / \ ? * " < > |)
    invalidChars = '[:\/\?\*\<\>\"\\\|]';
    safeName = regexprep(figName, invalidChars, '-');
    safeName = strtrim(safeName); % remove leading/trailing spaces
    if isempty(safeName)
        safeName = 'figure';
    end
    frameStr = sprintf('_%s', loc);
    outFile = fullfile(outDir, [safeName, frameStr, '.png']);
    exportgraphics(tlo, outFile, 'Resolution', 300);
end

%% plotting T0, T0wGroynes, T1, WL, and legend
nTimes = length(DataXY{1,1}.times);

for k = 1:nTimes
    time_date = DataXY{i}.times(k);
    figName = sprintf('Flow Field T0 T0wG T1: %s', datestr(time_date, 'dd-mm-yyyy HH:MM'));
          
    fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [100, 100, 900, 2400]); 
    tlo = tiledlayout(fig, 3, 10, 'TileSpacing', 'tight', 'Padding', 'tight');

    cx_run = mean(gridX,1);
    cy_run = mean(gridY,1);
    tix = k;
    loc = 'Zimmerman';

    % ==================================================================
    % PANELS 1, 3, 5: FLOW FIELDS — loop over DataXY entries
    % ==================================================================
    tile_positions = [1, 11, 21];   % nexttile start index for each row
    data_indices   = [1,  2,  3];   % DataXY{1, idx} to use per row
    ax_flow = gobjects(1, 3);       % store handles for later use

    for r = 1:3
        ax = nexttile(tlo, tile_positions(r), [1, 7]);
        hold(ax, 'on');
        ax_flow(r) = ax;

        % --- Extract velocity ---
        u = DataXY{1, data_indices(r)}.vel_x(tix,:);
        v = DataXY{1, data_indices(r)}.vel_y(tix,:);
        if numel(u) ~= numel(cx_run); u = reshape(u,1,[]); end
        if numel(v) ~= numel(cx_run); v = reshape(v,1,[]); end
        speed = sqrt(u.^2 + v.^2);

        % --- Mask patch to polygon ---
        cx_flat = cx_run(:); cy_flat = cy_run(:);
        inside_patch = false(numel(cx_flat), 1);
        for ki = 1:length(flowfield_x)
            inside_patch = inside_patch | inpolygon(cx_flat, cy_flat, flowfield_x{ki}, flowfield_y{ki});
        end
        speed = speed(:); speed(~inside_patch) = NaN;

        patch(gridX, gridY, speed(:)', 'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax, 'FaceAlpha', 0.9);

        % --- White overlay outside polygon ---
        outside_patch = ~inside_patch;
        if any(outside_patch)
            patch(gridX(:,outside_patch), gridY(:,outside_patch), ones(1,sum(outside_patch)), ...
                'EdgeColor', 'none', 'FaceColor', 'white', 'Parent', ax, 'FaceAlpha', 1);
        end

        % --- Strekdammen ---
        for ki = 1:numel(Nieuw_x)
            if ~isempty(Nieuw_x{ki}); plot(ax, Nieuw_x{ki}, Nieuw_y{ki}, 'r-', 'LineWidth', 4); end
        end
        for ki = 1:numel(Aangepast_x)
            if ~isempty(Aangepast_x{ki}); plot(ax, Aangepast_x{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 4); end
        end
        for ki = 1:numel(Aangepast_x)
            if ~isempty(Aangepast_x{ki}); plot(ax, Aangepast_x{ki}, Aangepast_y{ki}, 'r--', 'LineWidth', 3); end
        end
        for ki = 1:numel(Bestaand_x)
            if ~isempty(Bestaand_x{ki}); plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 4); end
        end
        for ki = 1; plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'r--', 'LineWidth', 2); end

        % --- Viewport ---
        % zoom on groynes bath
        % xlim(ax, [70200 72500]); ylim(ax, [378900 380100]);
        %bath zoom out
        xlim(ax, [70000 72800]); ylim(ax, [378900 380300]);
        %zimm
         xlim(ax, [64000 68100]); ylim(ax, [379200 381000]);
        xl = xlim(ax); yl = ylim(ax);
        [x0, y0] = meshgrid(xl(1):150:xl(2), yl(1):150:yl(2));

        % --- Quiver ---
        isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(u(:)) & isfinite(v(:));
        cx_valid = cx_run(isValid); cy_valid = cy_run(isValid);
        u_valid = u(isValid); v_valid = v(isValid);
        if ~isempty(cx_valid)
            F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
            u_grid = F(x0, y0); F.Values = v_valid(:); v_grid = F(x0, y0);
            inside_quiver = false(size(x0));
            for ki = 1:length(flowfield_x)
                inside_quiver = inside_quiver | inpolygon(x0, y0, flowfield_x{ki}, flowfield_y{ki});
            end
            u_grid(~inside_quiver) = NaN; v_grid(~inside_quiver) = NaN;
            grid_speed = sqrt(u_grid.^2 + v_grid.^2);
            u_norm = u_grid./grid_speed; v_norm = v_grid./grid_speed;
            quiver(ax, x0, y0, u_norm*90, v_norm*90, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.1);
        end

        % --- Axes formatting ---
        % daspect(ax, [1 1 1]);
        vp_w = diff(xlim(ax));
        vp_h = diff(ylim(ax));
        pbaspect(ax, [vp_w vp_h 1]);
        xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
        yk_min = floor(yl(1)/1000*2)/2; yk_max = ceil(yl(2)/1000*2)/2;
        xk = (xk_min:1.0:xk_max); yk = (yk_min:0.5:yk_max);
        set(ax, 'XTick', xk*1000, 'YTick', yk*1000, 'FontSize', 13);
        ylabel(ax, 'RDy [km]', 'FontSize', 14, 'FontWeight', 'bold');
        set(ax, 'YTickLabel', arrayfun(@(v) sprintf('%.1f',v), yk, 'UniformOutput', false));
        if r < 3
            set(ax, 'XTickLabel', []);   % suppress x labels on rows 1 and 2
        else
            xlabel(ax, 'RDx [km]', 'FontSize', 14, 'FontWeight', 'bold');
            set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f',v), xk, 'UniformOutput', false));
        end

        % --- Colormap ---
        nLevels = 8; cmap_flow = parula(nLevels);
        colormap(ax, cmap_flow); clim(ax, [0 0.8]);
        ch = findobj(ax, '-property', 'CData');
        for c = 1:numel(ch)
            C = get(ch(c), 'CData');
            if isnumeric(C)
                Cnorm = min(max(C./0.8, 0), 1);
                Cidx  = round(Cnorm*(nLevels-1))+1;
                if isvector(Cidx)
                    rgb = reshape(cmap_flow(Cidx(:),:), [numel(Cidx),3]);
                    try; set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
                    catch; set(ch(c), 'CData', Cnorm); end
                else
                    set(ch(c), 'CData', Cnorm);
                end
            end
        end

        % --- Colorbar on bottom panel only (horizontal in tile 6) ---
        if r == 3
            % Create horizontal colorbar below axes (eastoutside by default is vertical)
            cb = colorbar(ax, 'southoutside');
            cb.Label.String = 'Max. Velocity [m/s]';
            cb.Label.FontSize = 14; cb.Label.FontWeight = 'bold';
            cb.Units = 'normalized';
          
            height = 0.03;           % thickness of the horizontal colorbar
            x     = 0.70;           % align left with axes
            width = 0.25;           % match axes width
            y     = 0.15; % place just below axes          
            cb.Position = [x,y, width, height];
            cb.Direction = 'normal';
            cb.TickDirection = 'out';
        end

        % --- Title ---
        title(ax, names{data_indices(r)}, 'FontSize', 15, 'FontWeight', 'bold');
        hold(ax, 'off');
    end

    % ==================================================================
    % PANEL 2: WATER LEVEL (tiles 8-10)
    % ==================================================================
    ax2 = nexttile(tlo, 8, [1, 3]);
    hold(ax2, 'on');
    
    current_time_dt = datetime(DataXY{1,1}.times(k), 'ConvertFrom', 'datenum');
    WL_window_min = current_time_dt - hours(6);
    WL_window_max = current_time_dt + hours(6);
    
    plot(ax2, t_wals, wl_wals, '-', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
    [~, closest_idx] = min(abs(t_bath - current_time_dt));
    plot(ax2, t_wals(closest_idx), wl_wals(closest_idx), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10, ...
         'DisplayName', ['Current: ', datestr(current_time_dt, 'HH:MM')]);
    
    xlim(ax2, [WL_window_min, WL_window_max]);
    t0_dt   = datetime(datenum(t0,   'dd-mmm-yyyy HH:MM:SS'), 'ConvertFrom', 'datenum') - 0.25;
    tend_dt = datetime(datenum(tend, 'dd-mmm-yyyy HH:MM:SS'), 'ConvertFrom', 'datenum') + 0.25;
    if tend_dt > WL_window_min && t0_dt < WL_window_max
        xlim(ax2, [max(WL_window_min, t0_dt), min(WL_window_max, tend_dt)]);
    end
    set(ax2, 'XTick', t0_dt:hours(4):tend_dt);
    xtickformat(ax2, 'HH:mm'); xtickangle(ax2, 0); set(ax2, 'FontSize', 12);
    % xlabel(ax2, 'Time', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel(ax2, 'Water Level [m]', 'FontSize', 13, 'FontWeight', 'bold');
    grid(ax2, 'off');
    hold(ax2, 'off');

    % ==================================================================
    % PANEL 4: LEGEND (tiles 18-20)
    % ==================================================================
    ax4 = nexttile(tlo, 18, [1, 3]);
    hold(ax4, 'on'); axis(ax4, 'off');

      xref = 0; yref = 0; refU = 1; refV = 0;
    hRef = quiver(ax4, xref, yref, refU, refV, 0, 'k', ...
     'LineWidth', 3, 'MaxHeadSize', 2);

    
    % Move legend here instead of floating lgdAxes
    h_groyne    = plot(ax4, NaN, NaN, 'r-',  'LineWidth', 4,   'DisplayName', 'New Groyne');
    % h_groyne_ch = plot(ax4, NaN, NaN, 'r--', 'LineWidth', 3,   'DisplayName', 'Modified');
    h_groyne_ex = plot(ax4, NaN, NaN, '-',   'Color', [0.35 0.35 0.35], 'LineWidth', 3, 'DisplayName', 'Existing Groyne');
    WL_time = plot(ax4,  NaN, NaN, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 10, ...
             'DisplayName', ['Time: ', datestr(current_time_dt, 'HH:MM')]);

    hRef.Annotation.LegendInformation.IconDisplayStyle = 'on';

    % Prepare legend handles and labels
    legHandles = [h_groyne, h_groyne_ex, WL_time];
    legLabels = {'New Groyne', 'Existing Groyne', ...
        sprintf('Time: %s', datestr(current_time_dt, 'HH:MM')), ...
        'Flow Direction'};
    axTarget = ax4;
    % Append reference handle and label
    legHandles(end+1) = hRef;
    legLabels{end+1}  = 'Flow Direction';

    % Restrict axis limits so the physical arrow is outside the visible region
    try
        xlim(axTarget, [10 20]);
        ylim(axTarget, [10 20]);
    catch
        % If setting limits fails (e.g. for log axes), ignore and proceed
    end

    % Turn axis visuals off but keep legend-able objects present
    axis(axTarget, 'off');

    % 4. Generate the legend sitting cleanly on the blank tile
    if ~isempty(legHandles)
        lgd = legend(axTarget, legHandles, legLabels, ...
            'Orientation', 'vertical', 'Box', 'off', 'FontSize', 14, ...
            'Interpreter', 'none', 'TextColor', 'k', 'Location', 'east');
    end
        
    hold(ax4, 'off');

    % ==================================================================
    % PANEL 6: EMPTY (tiles 28-30)
    % ==================================================================
    ax6 = nexttile(tlo, 28, [1, 3]);
    axis(ax6, 'off');

    % ==================================================================
    % FORCE EQUAL Y-HEIGHT ACROSS ROW PAIRS
    % ================================================================== 
    drawnow;
    
    % Get current positions
    p1 = ax_flow(1).Position;
    p2 = ax_flow(2).Position;
    p3 = ax_flow(3).Position;
    
    % Desired gap between panels in normalized units
    gap = 0.008;   % tweak between 0 (none) and ~0.025 (tight)
    
    % Restack from bottom up, keeping panel heights fixed
    ax_flow(3).Position(2) = p3(2);                          % bottom panel anchored
    ax_flow(2).Position(2) = p3(2) + p3(4) + gap;           % middle above bottom
    ax_flow(1).Position(2) = p3(2) + p3(4) + gap + p2(4) + gap;  % top above middle
           
    % ==================================================================
    % EXPORT
    % ==================================================================
    % outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\flowfield_WL\T1';
    % if ~exist(outDir, 'dir'); mkdir(outDir); end
    % safeName = strtrim(regexprep(figName, '[:\/\?\*\<\>\"\\\|]', '-'));
    % if isempty(safeName); safeName = 'figure'; end
    % exportgraphics(tlo, fullfile(outDir, [safeName, sprintf('_%s', loc), '.png']), 'Resolution', 300);
end