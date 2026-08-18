close all
clear al
clc

% determine CDF from FOU files to plot 95th percentile to determine low dynamic area. 
% D. Pierce

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

% flats (Bath, Zimm, Valkenisse)
KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_flats_bath.kml');
for ki = 1:length(KML)
    [Bathflats_x{ki},Bathflats_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_flats_zimm.kml');
for ki = 1:length(KML)
    [Zimmflats_x{ki},Zimmflats_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

% KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\valkenisse.kml');
% for ki = 1:length(KML)
%     [valkflats_x{ki},valkflats_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
% end

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
%             hPol(end+1) = plot(Bathflats_x{k}, Bathflats_y{k}, 'k-', 'LineWidth', 1.5);
%         end
%     end
% end
% if exist('Zimmflats_x','var') && ~all(cellfun(@isempty,Zimmflats_x))
%     for k = 1:numel(Zimmflats_x)
%         if ~isempty(Zimmflats_x{k})
%             hPol(end+1) = plot(Zimmflats_x{k}, Zimmflats_y{k}, 'k-', 'LineWidth', 1.5);
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

%% load 
FOU  = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_Apr22-24_T0T1.mat");
data1  = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_Apr22_T0wGroynes.mat");
data  = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_T0_T0wG_T1.mat"); % has full T0 and T1. only 25/41 of T0wGroynes so suing load above to supplement T0wG
% sigma_layers = [2 3 5 8 10 12 15 15 15 15];
% data_da = (data.data.val * sigma_layers') / 100;

for i =1
    gridX = FOU.FOU(i).data.grid.face_nodes_x;
    gridY = FOU.FOU(i).data.grid.face_nodes_y;
    Xcen = FOU.FOU(i).data.grid.Xcen;
    Ycen = FOU.FOU(i).data.grid.Ycen;
end

%% load percentile vel
% 50th
% T0 = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel50pct_T0.mat");
% T0wG = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel5p0ct_T0wG.mat");
% T1 = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel50pct_T1.mat");

% 95th
T0 = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel95pct_T0.mat");
T0wG = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel95pct_T0wG.mat");
T1 = load("P:\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\vel95pct_T1.mat");

%% import models
folders = { ...
    'P:\11207654-internship-pierce-2026\03_Model\FOU model\15_T0_fou_Apr18\output\' , ...
    'P:\11207654-internship-pierce-2026\03_Model\FOU model\17_T0bathy_T1groynes_fou_Apr18\output\' , ...
    'P:\11207654-internship-pierce-2026\03_Model\FOU model\16_T1_fou_Apr18\output\',
};

% Names for the titles (Viscosity values) & save to mat files
% names = {'T0wGroynes'};
names = {'T0', 'T0wGroynes', 'T1'};

% read nc files
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
%     if i == 1
%         gridInfo = EHY_getGridInfo(ncFile, 'face_nodes_xy');
%         else
%     end 
% 
%     % save per-run DataXY using descriptive names array
%     nameVal = names(i);
%     if isnumeric(nameVal)
%         nameStr = sprintf('%g', names);
%         nameStr = strrep(nameStr, '.', 'p'); % replace dot with 'p' for filenames
%     else
%         nameStr = matlab.lang.makeValidName(char(nameVal));
%     end
%     % save DataXY and gridInfo for this folder using the constructed name
%     outName = fullfile(pwd, ['T1_maxvel' nameStr '.mat']);
%     velData = DataXY{i}; 
%     save(outName, 'DataXY', 'gridInfo');
% end

%% load .mat
% T0 = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\T0_maxvelT0.mat');    %T0
% T1 = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\T1_maxvelT1.mat');    %T1
% velData = {T0};
% timebelow = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\FOU_Apr22-24_T0T1.mat');
timebelow = load("\\storage008.directory.intra\11207654-internship-pierce-2026\04_Scripts\Model\ModelOutput\scripts\model_mat_files\FOU_Apr22_T0wGroynes.mat");
% ensure variable is a struct and not accessed with string keys elsewhere
% convert any string array field names in timebelow to char if needed later

% velData = DataXY;

% %% Plot max velocity
% figName = sprintf('Low Dynamic Area %s', nameStr);
% fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [200, 200, 800, 600]);
% 
% % Use axes instead of subplot so it occupies the full window
% ax = axes('Parent', fig);
% tix = k; 
% 
% % Compute hydro-mesh cell center geometry
% if size(gridInfo.face_nodes_x,1) == 4
%     cx_run = mean(gridInfo.face_nodes_x,1);
%     cy_run = mean(gridInfo.face_nodes_y,1);
% else
%     cx_run = mean(gridInfo.face_nodes_x,2).';
%     cy_run = mean(gridInfo.face_nodes_y,2).';
% end
% 
% for i = 1:length(folders)
%     speed = DataXY{i}.val;
% 
%     % Plot mesh patches
%     if size(gridInfo.face_nodes_x,1) == 4
%         patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%     else
%         patch(gridInfo.face_nodes_x', gridInfo.face_nodes_y', speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%     end
%     hold(ax, 'on');
% 
%      % =========================================================================
%      % --- Plot 0.6 m/s Contour Line ---
%      % =========================================================================
%     % 1. Create a fine grid based on your current map viewport boundaries
%     xl = xlim(ax);
%     yl = ylim(ax);
%     [X_grid, Y_grid] = meshgrid(xl(1):15:xl(2), yl(1):15:yl(2)); % 20-meter spacing for smooth contour
% 
%     % 2. Filter out any NaN coordinates or speeds
%     speed_flat = speed(:);
%     isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
% 
%     if any(isValid)
%         % 3. Interpolate speed from cell centers onto the regular grid
%         F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
%         speed_grid = F_speed(X_grid, Y_grid);
% 
%         % 4. Plot ONLY the 0.6 contour line
%         % [0.6 0.6] tells MATLAB to target exactly that value
%         % hLine4 = contour(ax, X_grid, Y_grid, speed_grid, [0.6 0.6], ...
%                                 % 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-');
%         % hPol(4) = plot(nan, nan, 'k-', 'LineWidth', 2); 
% 
%         % % Optional: Add a text label along the line automatically
%         % clabel(C, hContour, 'FontSize', 10, 'Color', 'k', 'FontWeight', 'bold');
%     end 
% 
%     % =========================================================================
%     % Calculate Area Below 0.6 m/s Inside KML
%     % =========================================================================
%     % 1. Create a logical mask for grid nodes below 0.6
%     isBelowThreshold = (speed_grid < 0.6);
% 
%     % 2. Initialize a mask to track which grid nodes fall inside ANY KML polygon
%     isInsideAnyKML = false(size(X_grid));
%     % 3. Loop through KML polygons (Bathflats and Zimmflats)
%     for ki = 1:max([numel(Bathflats_x), numel(Zimmflats_x)])
%         % Bathflats polygon (if exists)
%         if ki <= numel(Bathflats_x) && ~isempty(Bathflats_x{ki})
%             inPolyBath = inpolygon(X_grid, Y_grid, Bathflats_x{ki}, Bathflats_y{ki});
%             isInsideAnyKML = isInsideAnyKML | inPolyBath;
%         end
%         % Zimmflats polygon (if exists)
%         if ki <= numel(Zimmflats_x) && ~isempty(Zimmflats_x{ki})
%             inPolyZimm = inpolygon(X_grid, Y_grid, Zimmflats_x{ki}, Zimmflats_y{ki});
%             isInsideAnyKML = isInsideAnyKML | inPolyZimm;
%         end
%     end
% 
%     % 4. Combine conditions: Inside KML AND speed < 0.6 m/s
%     targetNodesMask = isInsideAnyKML & isBelowThreshold;
%     gridSpacing = 15;                     % meters
%     cellArea = gridSpacing * gridSpacing; % m^2 per grid cell
%     isInBath = false(size(X_grid));
%     isInZimm = false(size(X_grid));
% 
%     maxK = max(numel(Bathflats_x), numel(Zimmflats_x));
%     for k = 1:maxK
%         if k <= numel(Bathflats_x) && ~isempty(Bathflats_x{k})
%             isInBath = isInBath | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
%         end
%         if k <= numel(Zimmflats_x) && ~isempty(Zimmflats_x{k})
%             isInZimm = isInZimm | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
%         end
%     end
% 
%     % Combine with speed threshold (speed mask: logical where speed < 0.6)
%     bathMask = isInBath & isBelowThreshold;
%     zimmMask = isInZimm & isBelowThreshold;
% 
%     totalBathArea_m2 = sum(bathMask(:)) * cellArea;
%     totalZimmArea_m2 = sum(zimmMask(:)) * cellArea;
% 
%     fprintf('Bathflats area (speed<0.6): %.2f m^2 (%.1f ha)\n', totalBathArea_m2, totalBathArea_m2/1e4);
%     fprintf('Zimmflats area (speed<0.6): %.2f m^2 (%.1f ha)\n', totalZimmArea_m2, totalZimmArea_m2/1e4);
% 
%     % % plot low dynamic area as shaded region:
%     % plot(ax, X_grid(targetNodesMask), Y_grid(targetNodesMask), 'r.', 'MarkerSize', 3);
% 
%     % ---plot strekdammen nieuw + aangepast + bestaand--- (only for i == 2)
%     if i == 1
%         for k = 1:numel(Nieuw_x)
%             if ~isempty(Nieuw_x{k})
%                 hPol(end+1) = plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 3); %#ok<SAGROW>
%             end
%         end
%     end
%     hPol(3) = plot(ax, nan, nan, 'k-', 'LineWidth', 2); % placeholder for legend
% 
%     for ki = 1:numel(Aangepast_x)
%         if ~isempty(Aangepast_x{ki})
%         hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, 'k-','LineWidth', 3); %#ok<SAGROW>
%         end
%     end
% 
%     hPol(1) = plot(nan, nan, 'k-', 'LineWidth', 2); % to use in
% 
%     for ki = 1:numel(Bestaand_x)
%         if ~isempty(Bestaand_x{ki})
%         hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, 'k-', 'LineWidth', 3); %#ok<SAGROW>
%         end
%     end
%     hPol(2) = hLine2;
% 
%     %========= Map geographic viewport=========
%     % %Bath
%     % xlim(ax, [69600 72900]);
%     % ylim(ax, [378900 380600]);
% 
%     %Bath expansion
%     xlim(ax, [69000 72900]);
%     ylim(ax, [378800 380600]);
% 
%     % Zimm
%     % xlim(ax, [64300 67200]);   % RDx in meters
%     % ylim(ax, [379300 380900]); % RDy in meters
% 
%     %Zimm expansion
%     xlim(ax, [65000 68500]);
%     ylim(ax, [378500 381000]);
% 
%       % % ========= Map uniform 50m quiver arrows inside KML boundary =========
%       %   xl = xlim(ax);
%       %   yl = ylim(ax);
%       % 
%       %   % Create a regular grid with exactly 50-meter spacing
%       %   [x0, y0] = meshgrid(xl(1):50:xl(2), yl(1):50:yl(2));
%       % 
%       %   % Filter out any NaN or Inf coordinates and velocities
%       %   isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & ...
%       %             isfinite(u(:))      & isfinite(v(:));
%       % 
%       %   cx_valid = cx_run(isValid);
%       %   cy_valid = cy_run(isValid);
%       %   u_valid  = u(isValid);
%       %   v_valid  = v(isValid);
%       % 
%       %   if ~isempty(cx_valid)
%       %       F = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
%       %       u_grid = F(x0, y0);
%       % 
%       %       F.Values = v_valid(:); 
%       %       v_grid = F(x0, y0);
%       % 
%       %       % --- Mask using our converted RD coordinates ---
%       %       isInsideKML = inpolygon(x0, y0, poly_x, poly_y);
%       %       u_grid(~isInsideKML) = NaN;
%       %       v_grid(~isInsideKML) = NaN;
%       % 
%       %       % Normalize the grid vectors to unit length
%       %       grid_speed = sqrt(u_grid.^2 + v_grid.^2);
%       %       u_norm = u_grid ./ grid_speed;
%       %       v_norm = v_grid ./ grid_speed;
%       % 
%       %       % Define a fixed arrow length in meters
%       %       arrow_length_meters = 35; 
%       %       dx = u_norm * arrow_length_meters; 
%       %       dy = v_norm * arrow_length_meters;
%       % 
%       %       % Plot the uniform-length quiver arrows
%       %       quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);
%       % 
%       %       % OPTIONAL: Plot the KML boundary line itself so you can see it
%       %       hold(ax, 'on');
%       %       plot(ax, poly_x, poly_y, 'g--', 'LineWidth', 1.5); 
%       %   end
% 
%     % % Arrows: subsample for clarity
% % nVectors = numel(cx_run);
% % maxArrows = 4000;
% % if nVectors > maxArrows
% %     idx = round(linspace(1, nVectors, maxArrows));
% % else
% %     idx = 1:nVectors;
% % end
% % 
% % % Scale vectors consistently based on axis width (increase arrow length)
% % axUnits = get(ax, 'Units'); set(ax, 'Units', 'normalized');
% % axPos = get(ax, 'Position'); set(ax, 'Units', axUnits);
% % % Use a larger base multiplier to increase arrow lengths (was 0.2)
% % vecScale = 0.8 * mean(diff(xlim)) / sqrt(nanmean(u(idx).^2)+nanmean(v(idx).^2)) / 50;
% % 
% % x0 = cx_run(idx); y0 = cy_run(idx);
% % dx = u(idx) * vecScale; dy = v(idx) * vecScale;
% % % Slightly increase linewidth for visibility
% % quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 0.7, 'MaxHeadSize', 0.5);
% end
% 
% % Format Axes labels into uniform Kilometers units
% xlabel(ax, 'RDx [km]', 'FontSize', 16, 'FontWeight', 'bold');
% ylabel(ax, 'RDy [km]', 'FontSize', 16, 'FontWeight', 'bold');
% daspect(ax, [1 1 1]);
% 
% % Keep tick positions in meters but label in kilometers
% xl = xlim(ax); yl = ylim(ax);
% xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
% yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
% xk = (xk_min : 1.0 : xk_max);            
% yk = (yk_min : 0.5 : yk_max);            
% set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
% set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%        'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
% 
% % Use discrete colormap levels for color consistency
% nLevels = 12;
% cmap = parula(nLevels);
% colormap(ax, cmap);
% % Define color limits to span [0,1] as before
% clim(ax, [0 1.2]);
% % Force patch face colors to use discrete bins by mapping data to integer indices
% ch = findobj(ax, '-property', 'CData');
% for c = 1:numel(ch)
%     C = get(ch(c), 'CData');
%     if isnumeric(C)
%         % Normalize to [0,1], clamp, then map to 1:nLevels
%         Cnorm = (C - 0) ./ (1 - 0);
%         Cnorm = min(max(Cnorm, 0), 1);
%         Cidx = round(Cnorm * (nLevels-1)) + 1;
%         % Set CData to indexed colors via surface-like coloring:
%         % Replace numeric scalar per-face with RGB triplets
%         if isvector(Cidx)
%             rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
%             % For patch with FaceColor 'flat', set CData to indices and set FaceVertexCData
%             try
%                 set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
%             catch
%                 % Fallback: set CData to original normalized values (colormap still enforces discrete steps)
%                 set(ch(c), 'CData', Cnorm);
%             end
%         else
%             set(ch(c), 'CData', Cnorm);
%         end
%     end
% 
%     % Plot Title
%     title(ax, figName, 'FontSize', 24, 'FontWeight', 'bold');
% end
% hold(ax, 'off');
% 
% % colobar
% cb = colorbar(ax);
% cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
% cb.Label.FontSize = 12;
% cb.Label.FontWeight = 'bold';
% cb.FontSize = 12;
% cb.FontWeight = 'bold';
% 
% % ========================================================
% % COMPONENT ROUTING TO EMPTY TILE 4 (Legend & Colorbar)
% % ========================================================
% % Create invisible axes in current figure for legend & colorbar placement
% axLeg = axes('Visible', 'off', 'Units', 'normalized', 'Position', [0.75 0.05 0.2 0.15]);
% 
% h_target = plot(axLeg, NaN, NaN, 'r.', 'MarkerSize', 8, 'DisplayName', 'Low Dynamic Area');
% h_groyne = plot(axLeg, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'Structures');
% 
% % Build the legend on the invisible axes; ensure handles are valid
% validHandles = [h_target, h_groyne];
% validHandles = validHandles(arrayfun(@(h) isgraphics(h), validHandles));
% 
% if isempty(validHandles)
%     % Fallback: create a simple text legend on the invisible axes
%     text(0.1, 0.6, 'Low Dynamic Area', 'Parent', axLeg, 'Color', 'r', 'FontSize', 10);
%     text(0.1, 0.3, 'Structures', 'Parent', axLeg, 'Color', 'k', 'FontSize', 10);
% else
%     lgd = legend(axLeg, validHandles, 'Location', 'southoutside', 'Orientation', 'horizontal');
%     set(lgd, 'Box', 'off', 'FontSize', 12, 'Interpreter', 'none', 'Color', 'none', 'TextColor', 'k');
%     if isprop(lgd, 'ItemTokenSize')
%         set(lgd, 'ItemTokenSize', [30 18]);
%     end
% end
% 
% % Ensure the main axes retains focus and colorbar/limits
% if exist('ax','var') && isgraphics(ax)
%     axes(ax);
% end

% % Create invisible axes in current figure for legend & colorbar placement
% axLeg = axes('Visible', 'off', 'Units', 'normalized', 'Position', [0.75 0.05 0.2 0.15]);
% 
% % Populate dummy items onto hidden axes for uniform display (use consistent DisplayName)
% dummyGroyne = plot(axLeg, NaN, NaN, 'r-', 'LineWidth', 3, 'DisplayName', 'Existing Groynes');
% % dummyNew = plot(axLeg, NaN, NaN, 'k-', 'LineWidth', 2, 'DisplayName', 'New Groyne');
% dummyLDA = plot(axLeg, NaN, NaN, 'k-', 'LineWidth', 2, 'DisplayName', '0.6 m/s');
% % dummyFlow = quiver(axLeg, NaN, NaN, NaN, NaN, 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.5, 'DisplayName', 'Flow Direction');
% 
% % Create legend on the invisible axes
% lgd = legend(axLeg, [dummyGroyne, dummyLDA], 'Location', 'southoutside', 'FontSize', 12);
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


%% tiled bath and zimm low dynamic areas
viewports(1).name = 'Bath';
viewports(1).xlim = [68900 72900];
viewports(1).ylim = [378850 380600];
viewports(2).name = 'Zimmerman';
viewports(2).xlim = [64000 68100];
viewports(2).ylim = [379200 381000];

% one figure with tiles
figName = sprintf('T0wG\n');
% figName = sprintf('%s\n', nameStr);
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
    
    cx_run = mean(gridX,1);
    cy_run = mean(gridY,1);

    
    % for i = 1:length(folders)
        % speed = DataXY{i}.val;
        speed = T0wG.speed_90pct;
        
        % Plot mesh patches  
        patch(gridX, gridY, speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'FaceAlpha', 1.0, 'Parent', ax);
        hold(ax, 'on');
        
        % --- Create Interpolation Grid ---
        xl = viewports(loc).xlim;
        yl = viewports(loc).ylim;
        [X_grid, Y_grid] = meshgrid(xl(1):15:xl(2), yl(1):15:yl(2)); 
        
        speed_flat = speed(:);
        isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
        
        if any(isValid)
            F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
            speed_grid = F_speed(X_grid, Y_grid);
        end 
        
        % --- Calculate Area Below 0.6 m/s Inside Viewport KML Bounds ---
        isBelowThreshold = (speed_grid < 0.6);
        gridSpacing = 15;                     
        cellArea = gridSpacing * gridSpacing; 
        
        % Isolate mask evaluation purely to the active location pane
        locMask = false(size(X_grid));
        if strcmp(currentLoc, 'Bath')
            for k = 1:numel(Bathflats_x)
                if ~isempty(Bathflats_x{k})
                    locMask = locMask | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
                end
            end
        elseif strcmp(currentLoc, 'Zimmerman')
            for k = 1:numel(Zimmflats_x)
                if ~isempty(Zimmflats_x{k})
                    locMask = locMask | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
                end
            end
        end   

        % Final dynamic location boundary selection mask
        targetNodesMask = locMask & isBelowThreshold;
        areaResults.(currentLoc) = sum(targetNodesMask(:)) * cellArea;
        
        % --- Plot Low Dynamic Area as a Solid Shaded Region ---
        if any(targetNodesMask(:))
            maskData = double(targetNodesMask);
            [~, hShade] = contourf(ax, X_grid, Y_grid, maskData, [0.5 0.5], 'LineStyle', 'none'); 
            set(hShade, 'FaceColor', [242, 169, 0]/256, 'FaceAlpha', 1.0);
        end
        
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

        % if i == 1
        %     for k = 1:numel(Nieuw_x)
        %         if ~isempty(Nieuw_x{k})
        %             plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'r-', 'LineWidth', 3);
        %         end
        %     end
        % end
        % 
        % for ki = 1:numel(Aangepast_x)
        %     if ~isempty(Aangepast_x{ki})
        %         plot(ax, Aangepast_x{ki}, Aangepast_y{ki}, 'r-','LineWidth', 3);
        %     end
        % end
        % 
        % for ki = 1:numel(Bestaand_x)
        %     if ~isempty(Bestaand_x{ki})
        %         plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 3);
        %     end
        % end 
    % end
    
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
    
    % Color/Colormap Sync
    nLevels = 6;
    cmap = [linspace(1,0, nLevels)' linspace(1,0, nLevels)' linspace(1,0, nLevels)'];
    colormap(ax, cmap);
    ax.CLim = [0 1.2];
    
    % Force patch face colors to use discrete softer-blue bins
    nLevels = 6; % ensure consistent with above
    cmap = [linspace(0.85,0.45,nLevels)' linspace(0.9,0.6,nLevels)' linspace(0.98,0.7,nLevels)'];
    colormap(ax, cmap);
    ch = findobj(ax, '-property', 'CData');
    for c = 1:numel(ch)
        C = get(ch(c), 'CData');
        if isnumeric(C)
            Cnorm = (C - 0) ./ (1 - 0);
            Cnorm = min(max(Cnorm, 0), 1);
            Cidx = round(Cnorm * (nLevels-1)) + 1;
            if isvector(Cidx)
                rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
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
    % Colorbar Details
    if loc == 2
        cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
        cb.Position = [0.62, 0.09, 0.28, 0.03];  % [x y width height]
        cb.Label.String = '95th Percentile Depth-Avg Velocity [m/s]';
    end
    hold(ax, 'off');
end

% Provide readable name strings for locations and print area summary
nameStr = {'Bath', 'Zimmerman'};

% --- Print Areas Summary to Console ---
fprintf('Bathflats [%s] (speed<0.6): %.2f m^2 (%.1f ha)\n', nameStr{1}, areaResults.Bath, areaResults.Bath/1e4);
fprintf('Zimmflats [%s] (speed<0.6): %.2f m^2 (%.1f ha)\n', nameStr{2}, areaResults.Zimmerman, areaResults.Zimmerman/1e4);

% LEGEND 
lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.06, 0.2, 0.05]);
% h_target = patch(lgdAxes, NaN, NaN, [0, 0, 1], 'FaceAlpha', 0.7, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
hold(lgdAxes, 'on');
h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'New Groyne');
h_groyne_ch = plot(lgdAxes, NaN, NaN, 'k--', 'LineWidth', 2, 'DisplayName', 'Modified');
h_groyne_ex = plot(lgdAxes, NaN, NaN,  '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 2.5, 'DisplayName', 'Existing Groyne');
h_target = patch(lgdAxes, NaN, NaN, [242, 169, 0]/256, 'FaceAlpha', 0.9, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area');
lgd = legend(lgdAxes, [h_groyne, h_groyne_ch, h_groyne_ex, h_target], 'Location', 'southwest', 'Orientation', 'vertical');
set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 
lgd.NumColumns = 2;                       % display legend entries in two columns
lgd.Position = [0.20, 0.06, 0.24, 0.05];  %[left, bottom, width, height]

% lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.06, 0.2, 0.05]);
%  
% hold(lgdAxes, 'on');
% h_groyne = plot(lgdAxes, NaN, NaN, 'r-', 'LineWidth', 3, 'DisplayName', 'Structures');
% lgd = legend(lgdAxes, [h_target, h_groyne], 'Location', 'southwest', 'Orientation', 'vertical');
% set(lgd, 'Box', 'off', 'FontSize', 18, 'Interpreter', 'none', 'TextColor', 'k');
% set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 

% LABELS
for loc = 1:numel(axHandles)
    thisAx = axHandles(loc);
    set(thisAx, 'FontSize', 14, 'LineWidth', 1.2);
    xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
    if loc == 1
        ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
    end
    texTitle = sprintf('\\bf{\\it{%s}}', viewports(loc).name);
    title(thisAx, texTitle, 'FontSize', 22);
end

title(t, figName, 'FontSize', 26, 'FontWeight', 'bold');

% colorbar properties
if exist('cb', 'var') && isgraphics(cb)
    cb.FontSize = 14;
    cb.Label.String = '\bf{95th Percentile Depth-Avg Velocity [m/s]}';
    cb.Label.FontSize = 14;
    set(cb, 'FontWeight', 'bold'); % Makes colorbar tick mark numbers bold
end
% Set face alpha for patch objects used as targets in legend/axes
hPatches = findall(fig, 'Type', 'Patch');
if ~isempty(hPatches)
    set(hPatches, 'FaceAlpha', 0.6);
end

% %% export
% outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\Low Dynamic Area';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% 
% pngName = fullfile(outDir, sprintf('LDA_95pct_T1.png'));
% 
% % Save figure at 300 DPI
% set(fig, 'PaperPositionMode', 'auto');
% print(fig, pngName, '-dpng', '-r300');


%% time below 0.6 m/s (including dry time) yields high percentages
% for i = 1
% for i = 1:length(timebelow.FOU) %T1
    % time_sec = timebelow.FOU(i).data.tau.valTimeBelow(:, 13); % time in seconds per cell
    time_sec = data1.FOU.data.tau.valTimeBelow_DA(:,13);
    % time_sec = timebelow.FOU(i).data.tau.valTimeBelow(:, 13); % time in seconds per cell
    total_time = max(time_sec);
    % Convert t0 and tend (format like '22-May-2018') to datenums then to seconds
    % if ischar(t0) || isstring(t0)
    %     t0_num = datenum(char(t0));
    % else
    %     t0_num = t0;
    % end
    % if ischar(tend) || isstring(tend)
    %     tend_num = datenum(char(tend));
    % else
    %     tend_num = tend;
    % end
    % % datenums are in days; convert to seconds
    % t0_sec = t0_num * 24 * 3600;
    % tend_sec = tend_num * 24 * 3600;
    % compute percentage of time below threshold for this cell
    time_percent = time_sec ./ total_time;
% end

viewports(1).name = 'Bath';
viewports(1).xlim = [68900 72900];
viewports(1).ylim = [378850 380600];
viewports(2).name = 'Zimmerman';
viewports(2).xlim = [64000 68100];
viewports(2).ylim = [379200 381000];

% one figure with tiles
% figName = sprintf('%s\n', nameStr);
figName = sprintf('T0 with Groynes\n');
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
    if size(gridX,1) == 4
        cx_run = mean(gridX,1);
        cy_run = mean(gridY,1);
    else
        cx_run = mean(gridX,2).';
        cy_run = mean(gridY,2).';
    end
    
    % for i = 1:length(folders)
        speed = time_percent;
        
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
        if i == 1
            for k = 1:numel(Nieuw_x)
                if ~isempty(Nieuw_x{k})
                    plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 3);
                end
            end
        end

        for ki = 1:numel(Aangepast_x)
            if ~isempty(Aangepast_x{ki})
                plot(ax, Aangepast_x{ki}, Aangepast_y{ki}, 'k-','LineWidth', 3);
            end
        end
        
        for ki = 1:numel(Bestaand_x)
            if ~isempty(Bestaand_x{ki})
                plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'k-', 'LineWidth', 3);
            end
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
    
    % Color/Colormap Sync (custom discrete "viridisus" with specified percentile breakpoints)
    % Define breakpoints (percentiles) and corresponding normalized values (0-1)
    percentiles = [30, 60, 90, 95, 100];
    vals = percentiles / 100;                       % normalized positions
    nLevels = 256;                                  % high-res colormap then sampled
    baseMap = jet(nLevels);                     % use viridis as base ("viridisus")
    
    % Create a colormap that changes specifically at the requested percentiles.
    xq = linspace(0,1,64)';                         % final colormap sampling positions
    % Build control points including 0 and ensure unique, sorted
    ctrl_x = [0, vals];
    ctrl_x = unique(ctrl_x);
    % For colors at control points, sample from baseMap
    ctrl_idx = round(ctrl_x*(nLevels-1))+1;
    ctrl_colors = baseMap(ctrl_idx, :);
    % Interpolate RGB across 0..1 at xq using control colors
    cmap = interp1(ctrl_x, ctrl_colors, xq, 'linear');
    colormap(ax, cmap);
    clim(ax, [0 1]);
    
    % Create custom discrete color ticks at the requested percentiles for colorbar labeling
    % We'll attach a colorbar when loc == 2 later; here prepare tick positions and labels in normalized units
    cb_tick_vals = [0, vals];                       % include 0 (0%) plus percentiles
    cb_tick_vals = unique(cb_tick_vals);
    cb_tick_labels = arrayfun(@(v) sprintf('%.0f%%', v*100), cb_tick_vals, 'UniformOutput', false);
    
    % Force patch face colors to use discrete bins consistent with cmap
    ch = findobj(ax, '-property', 'CData');
    nCmap = size(cmap,1);
    for c = 1:numel(ch)
        C = get(ch(c), 'CData');
        if isnumeric(C)
            Cnorm = (C - 0) ./ (1 - 0);
            Cnorm = min(max(Cnorm, 0), 1);
            % Map normalized values to discrete colormap indices
            Cidx = round(Cnorm * (nCmap-1)) + 1;
            if isvector(Cidx)
                rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
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

    % Store tick info in axes appdata so the later colorbar section can pick it up
    setappdata(ax, 'CustomColorbarTicks', cb_tick_vals);
    setappdata(ax, 'CustomColorbarTickLabels', {cb_tick_labels});
    
    % Colorbar Details
    if loc == 2
        cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
        cb.Position = [0.62, 0.09, 0.25, 0.03];  % [x y width height]
        cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
    end
    hold(ax, 'off');
end

% LEGEND 
lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.06, 0.2, 0.05]);
% h_target = patch(lgdAxes, NaN, NaN, [0, 0, 1], 'FaceAlpha', 0.7, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
hold(lgdAxes, 'on');
h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'Structures');
lgd = legend(lgdAxes, [h_groyne], 'Location', 'southwest', 'Orientation', 'vertical');
set(lgd, 'Box', 'off', 'FontSize', 18, 'Interpreter', 'none', 'TextColor', 'k');
set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 


% LABELS
for loc = 1:numel(axHandles)
    thisAx = axHandles(loc);
    set(thisAx, 'FontSize', 14, 'LineWidth', 1.2);
    xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
    if loc == 1
        ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
    end
    texTitle = sprintf('\\bf{\\it{%s}}', viewports(loc).name);
    title(thisAx, texTitle, 'FontSize', 22);
end

title(t, figName, 'FontSize', 26, 'FontWeight', 'bold');

% colorbar properties
if exist('cb', 'var') && isgraphics(cb)
    cb.FontSize = 14;               
    cb.Label.String = '\bf{Time below 0.6 m/s [%]}';
    cb.Label.FontSize = 14;
    set(cb, 'FontWeight', 'bold'); % Makes colorbar tick mark numbers bold
end

%% time cell is wet (WL > 0.05 m)

for i = 1:length(folders)
    ncFile = fullfile(folders{i}, 'WS_0000_fou.nc');

    % read map/model data and grid info for this folder
    TimeWet{i} = EHY_getMapModelData(ncFile, 'varName', 'mesh2d_time_003_above'); 
 
    % save per-run
    nameVal = names(i);
    if isnumeric(nameVal)
        nameStr = sprintf('%g', names);
        nameStr = strrep(nameStr, '.', 'p');
    else
        nameStr = matlab.lang.makeValidName(char(nameVal));
    end
    % save DataXY and gridInfo for this folder using the constructed name
    outName = fullfile(pwd, ['TimeWet''.mat']);
    velData = TimeWet{i}; 
    save(outName, 'TimeWet');
end


% %% time below 0.6 m/s (wet) / TimeWet 
% 
% % for i = 1
% for i = 1:length(timebelow.FOU) %T1
%     time_06 = data1.FOU.data.tau.valTimeBelow_DA(:,13);
%     % time_06 = timebelow.FOU(i).data.tau.valTimeBelow(:, 13); % time in seconds per cell
%     total_time = max(time_06);
%     time_dry = total_time - TimeWet{i}.val;
%     time_percent = (time_06 - time_dry) ./ TimeWet{i}.val; % percentage of time LDA when cell is wet
% end
% 
% viewports(1).name = 'Bath';
% viewports(1).xlim = [68900 72900];
% viewports(1).ylim = [378850 380600];
% viewports(2).name = 'Zimmerman';
% viewports(2).xlim = [64000 68100];
% viewports(2).ylim = [379200 381000];
% 
% % one figure with tiles
% % figName = sprintf('%s\n', nameStr);
% figName = sprintf('T0 with Groynes\n', nameStr);
% fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [100, 150, 1400, 600]);
% t = tiledlayout(1, 2, 'Parent', fig, 'TileSpacing', 'compact', 'Padding', 'compact');
% 
% % Initialize arrays to store values for terminal readout
% axHandles = [];
% areaResults = struct('Bath', 0, 'Zimmerman', 0);
% 
% % Loop over both geographical locations to build tiles
% for loc = 1:numel(viewports)
%     currentLoc = viewports(loc).name;
% 
%     % Move to the next available tile
%     ax = nexttile(t);
%     axHandles(loc) = ax; 
% 
%     % Compute hydro-mesh cell center geometry
%     if size(gridX,1) == 4
%         cx_run = mean(gridX,1);
%         cy_run = mean(gridY,1);
%     else
%         cx_run = mean(gridX,2).';
%         cy_run = mean(gridY,2).';
%     end
% 
%     for i = 1:length(folders)
%         speed = time_percent;
% 
%         % values below 0.05 are often dry cells. assign them as 100% of
%         % time below 0.6 m/s in plotting such that graph is simpler
%         % visually
%         if ~isempty(speed)
%             mask = speed < 0.2;
%             speed(mask) = 0.99;
%         end
% 
%         % Plot mesh patches
%         if size(gridX,1) == 4
%             patch(gridX, gridY, speed(:)', ...
%                   'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%         else
%             patch(gridX', gridY', speed(:)', ...
%                   'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%         end
%         hold(ax, 'on');
% 
%         % --- Plot structures ---
%         if i == 2
%             for k = 1:numel(Nieuw_x)
%                 if ~isempty(Nieuw_x{k})
%                     plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 3);
%                 end
%             end
%         end
% 
%         for ki = 1:numel(Aangepast_x)
%             if ~isempty(Aangepast_x{ki})
%                 plot(ax, Aangepast_x{ki}, Aangepast_y{ki}, 'k-','LineWidth', 3);
%             end
%         end
% 
%         for ki = 1:numel(Bestaand_x)
%             if ~isempty(Bestaand_x{ki})
%                 plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'k-', 'LineWidth', 3);
%             end
%         end
%     end
% 
%     %========= Viewport Limits & Data Aspect Ratio =========
%     xlim(ax, viewports(loc).xlim);
%     ylim(ax, viewports(loc).ylim);
%     daspect(ax, [1 1 1]);
% 
%     % Setup Ticks in Kilometers
%     xl = xlim(ax); yl = ylim(ax);
%     xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
%     yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
%     xk = (xk_min : 1.0 : xk_max);            
%     yk = (yk_min : 0.5 : yk_max);            
%     set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
%     set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%            'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
% 
%     % Color/Colormap Sync
%     nLevels = 20;
%     cmap = turbo(nLevels);
%     colormap(ax, cmap);
%     clim(ax, [0 1]);
% 
%     % Force patch face colors to use discrete bins
%     ch = findobj(ax, '-property', 'CData');
%     for c = 1:numel(ch)
%         C = get(ch(c), 'CData');
%         if isnumeric(C)
%             Cnorm = (C - 0) ./ (1 - 0);
%             Cnorm = min(max(Cnorm, 0), 1);
%             Cidx = round(Cnorm * (nLevels-1)) + 1;
%             if isvector(Cidx)
%                 rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
%                 try
%                     set(ch(c), 'FaceVertexCData', rgb, 'CDataMapping', 'direct');
%                 catch
%                     set(ch(c), 'CData', Cnorm);
%                 end
%             else
%                 set(ch(c), 'CData', Cnorm);
%             end
%         end
%     end
% 
%     % Colorbar Details
%     if loc == 2
%         cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
%         cb.Position = [0.62, 0.09, 0.25, 0.03];  % [x y width height]
%         tickVals = linspace(0, 1, 5);                     % 5 ticks (customize as needed)
%         tickLabels = arrayfun(@(v) sprintf('%.0f', v*100), tickVals, 'UniformOutput', false);
%         cb.Ticks = tickVals;
%         cb.TickLabels = tickLabels;
%         cb.FontSize = 12;
%     end
%     hold(ax, 'off');
% end
% 
% % LEGEND 
% lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.06, 0.2, 0.05]);
% % h_target = patch(lgdAxes, NaN, NaN, [0, 0, 1], 'FaceAlpha', 0.7, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
% hold(lgdAxes, 'on');
% h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'Structures');
% lgd = legend(lgdAxes, [h_groyne], 'Location', 'southwest', 'Orientation', 'vertical');
% set(lgd, 'Box', 'off', 'FontSize', 18, 'Interpreter', 'none', 'TextColor', 'k');
% set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 
% 
% 
% % LABELS
% for loc = 1:numel(axHandles)
%     thisAx = axHandles(loc);
%     set(thisAx, 'FontSize', 14, 'LineWidth', 1.2);
%     xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
%     if loc == 1
%         ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
%     end
%     texTitle = sprintf('\\bf{\\it{%s}}', viewports(loc).name);
%     title(thisAx, texTitle, 'FontSize', 22);
% end
% 
% title(t, figName, 'FontSize', 26, 'FontWeight', 'bold');
% 
% % colorbar properties
% if exist('cb', 'var') && isgraphics(cb)
%     cb.FontSize = 14;               
%     cb.Label.String = '\bf{Time below 0.6 m/s [%]}';
%     cb.Label.FontSize = 14;
%     set(cb, 'FontWeight', 'bold'); % Makes colorbar tick mark numbers bold
% end

%% building CDF 
velocities = [0.01, 0.05, 0.10:0.05:2.00]; % Length: 41 elements
total_period_sec = 2678400; % Define your total simulation time scalar directly

for i = 3  
    all_times_sec = data.FOU(i).data.tau.valTimeBelow_DA;  % i=1 T0 ; i=3 T1 
    % all_times_sec = data1.FOU(1).data.tau.valTimeBelow_DA; % i=2 T0 with Groynes

    numCells = size(all_times_sec, 1); 
    speed_90pct = zeros(numCells, 1); 
    
    for cell = 1:numCells
        
        % === STEP 1: Get Scalar T_wet and T_dry for cell ===
        current_T_wet = TimeWet{i}.val(cell); 
        current_T_dry = total_period_sec - current_T_wet;
        
        if current_T_wet <= 0
            speed_90pct(cell) = 0;
            continue;
        end
        
        raw_cell_cdf = all_times_sec(cell, 1:41)'; 
        
        % === Correct distribution ===
        corrected_cdf = raw_cell_cdf - current_T_dry;
        corrected_cdf(corrected_cdf < 0) = 0;
        
        % === Calculate 90th percentile ===
        percentile = 0.50; % <-----   SELECT PERCENTILE in CDF TO GENERATE HERE 
        target = percentile * current_T_wet; 
        
        % === Interpolate ===
        [unique_cdf, unique_idx] = unique(corrected_cdf, 'stable');
        unique_velocities = velocities(unique_idx);
        
        if numel(unique_cdf) > 1 && target <= max(unique_cdf)
            speed_90pct(cell) = interp1(unique_cdf, unique_velocities, target, 'linear', 0);
        else
            speed_90pct(cell) = 0; 
        end
    end
end


%%
percentile = 0.95;

%% plotting CDF
viewports(1).name = 'Bath';
viewports(1).xlim = [68900 72900];
viewports(1).ylim = [378850 380600];
viewports(2).name = 'Zimmerman';
viewports(2).xlim = [64000 68100];
viewports(2).ylim = [379200 381000];
Xgrid_local = [63500 73000];
Ygrid_local = [378800 381000];

% one figure with tiles
% figName = sprintf('%s\n', nameStr);
figName = sprintf('T0 with Groynes \n');
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
    cx_run = Xcen(:)';  
    cy_run = Ycen(:)';
    
    % for i = 1:length(folders)
       % speed = speed_90pct;
       speed = T0wG.speed_90pct(:);

        % Plot mesh patches
        patch(gridX, gridY, speed(:)', ...
            'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
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
    % end 

    %  %=== plot 0.6 contour line===
    % xl = xlim(ax);
    % yl = ylim(ax);
    % 
    % % 1. Coarsen grid spacing slightly for a massive speed boost (e.g., 25m or 30m)
    % [Xgrid_local, Ygrid_local] = meshgrid(xl(1):20:xl(2), yl(1):20:yl(2)); 
    % 
    % speed_flat = T0.speed_90pct(:);
    % % speed_flat = speed_90pct(:);
    % 
    % % Only interpolate inside or near this viewport.
    % buffer = 50; % Include a small buffer outside the viewport limits
    % in_view = (cx_run(:) >= xl(1)-buffer & cx_run(:) <= xl(2)+buffer & ...
    %            cy_run(:) >= yl(1)-buffer & cy_run(:) <= yl(2)+buffer);
    % 
    % isValid = in_view & isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
    % 
    % idx = find(isValid);
    % idx = idx(1:2:end);  % thin the triangulation input, not the output resolution
    % F_speed = scatteredInterpolant(Xcen(idx), Ycen(idx), speed_flat(idx), 'linear', 'none');
    % 
    % % if any(isValid)
    % %     % Create interpolant using ONLY localized cells (reducing size from 199k to just a few thousand)
    % %     F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
    % %     speed_grid = F_speed(X_grid, Y_grid);
    % % 
    % %     % 4. Plot contour line (Typo 'LineWidtth' corrected here!)
    % %     contour(ax, X_grid, Y_grid, speed_grid, [0.5 0.5], ...
    % %             'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'LineStyle', '-');
    % % end

    % % === plot 0.6 contour lines ===
    % xl = xlim(ax);
    % yl = ylim(ax);
    % 
    % % Extraction grid
    % [X_grid, Y_grid] = meshgrid(xl(1):20:xl(2), yl(1):20:yl(2));
    % 
    % % Only interpolate inside or near this viewport
    % buffer = 50;
    % in_view = (Xcen(:) >= xl(1)-buffer & Xcen(:) <= xl(2)+buffer & ...
    %            Ycen(:) >= yl(1)-buffer & Ycen(:) <= yl(2)+buffer);
    % isValid = in_view & isfinite(Xcen(:)) & isfinite(Ycen(:)) & isfinite(speed);
    % 
    % if any(isValid)
    %     idx = find(isValid);
    %     idx = idx(1:2:end);
    % 
    %     F_speed = scatteredInterpolant(Xcen(idx), Ycen(idx), speed(idx), 'linear', 'none');
    %     speed_grid = F_speed(X_grid, Y_grid);
    % 
    %     % 0.6 m/s contour
    %     contour(ax, X_grid, Y_grid, speed_grid, [0.6 0.6], ...
    %         'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'LineStyle', '-');
    % end

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
    
    % Color/Colormap Sync
    nLevels = 12;
    cmap = turbo(nLevels);
    colormap(ax, cmap);
    clim(ax, [0 1.2]);
    
     % Color/Colormap Sync
    nLevels = 12;
    cmap = turbo(nLevels);
    colormap(ax, cmap);
    clim(ax, [0 1.2]);
    
    
    % discrete color bins
    ch = findobj(ax, '-property', 'CData');
    for c = 1:numel(ch)
        C = get(ch(c), 'CData');
        if isnumeric(C)
            Cnorm = (C - 0) ./ (1.2 - 0);
            Cnorm = min(max(Cnorm, 0), 1);
            Cidx = round(Cnorm * (nLevels-1)) + 1;
            if isvector(Cidx)
                rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
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
    
    % Colorbar Details
    if loc == 2
        cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
        cb.Position = [0.62, 0.09, 0.25, 0.03];  % [x y width height]
        cb.Label.String = '95th percentile Depth-Avg Velocity [m/s]';
        tickPositions = 0:0.2:1.2;
        cb.Ticks = tickPositions;
        cb.TickLabels = string(tickPositions);
    end
    hold(ax, 'off');
end

% LEGEND 
lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.06, 0.2, 0.05]);
% h_target = patch(lgdAxes, NaN, NaN, [0, 0, 1], 'FaceAlpha', 0.7, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
hold(lgdAxes, 'on');
h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'New Groyne');
h_groyne_ch = plot(lgdAxes, NaN, NaN, 'k--', 'LineWidth', 2, 'DisplayName', 'Modified');
h_groyne_ex = plot(lgdAxes, NaN, NaN,  '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 2.5, 'DisplayName', 'Existing Groyne');
h_contour =  plot(lgdAxes,  NaN, NaN, 'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', '0.6 m/s Contour');
lgd = legend(lgdAxes, [h_groyne, h_groyne_ch, h_groyne_ex, h_contour], 'Location', 'southwest', 'Orientation', 'vertical');
set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 
lgd.NumColumns = 2;                       % display legend entries in two columns
lgd.Position = [0.20, 0.06, 0.24, 0.05];  %[left, bottom, width, height]

% LABELS
for loc = 1:numel(axHandles)
    thisAx = axHandles(loc);
    set(thisAx, 'FontSize', 14, 'LineWidth', 1.2);
    xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
    if loc == 1
        ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
    end
    texTitle = sprintf('\\it{%s}', viewports(loc).name);
    title(thisAx, texTitle, 'FontSize', 22);
end

title(t, figName, 'FontSize', 26, 'FontWeight', 'bold');

% colorbar properties
if exist('cb', 'var') && isgraphics(cb)
    cb.FontSize = 14;               
    cb.Label.String = sprintf('\\bf{%.0fth Percentile Depth-Avg Velocity [m/s]}', percentile*100);
    cb.Label.FontSize = 14;
    set(cb, 'FontWeight', 'bold'); % Makes colorbar tick mark numbers bold
end

% % --- export all open figures ---
% outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\Low Dynamic Area';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% 
% pngName = fullfile(outDir, sprintf('50pct_T0wG.png'));
% % pngName = fullfile(outDir, sprintf('%s_wet95pctVEL.png', safeFigName));
% 
% % Save figure at 300 DPI
% set(fig, 'PaperPositionMode', 'auto');
% print(fig, pngName, '-dpng', '-r300');

%% plotting CDF & calculate Low Dyn Area based on 95% percentile (<0.6 m/s)
viewports(1).name = 'Bath';
viewports(1).xlim = [68900 72900];
viewports(1).ylim = [378850 380600];
viewports(2).name = 'Zimmerman';
viewports(2).xlim = [64000 68100];
viewports(2).ylim = [379200 381000];

% one figure with tiles
% figName = sprintf('%s\n', nameStr);
figName = sprintf('T1\n', nameStr);
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
    if size(gridX,1) == 4
        cx_run = mean(gridX,1);
        cy_run = mean(gridY,1);
    end
    
    for i = 1:length(folders)
       speed = speed_90pct;

        % Plot mesh patches
        patch(gridX, gridY, speed(:)', ...
            'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
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
    end 

     %=== plot 0.6 contour line ===
    xl = xlim(ax);
    yl = ylim(ax);
    
    % 1. Set a consistent grid spacing (25-meter grid resolution)
    gridSpacing = 30;                     
    [X_grid, Y_grid] = meshgrid(xl(1):gridSpacing:xl(2), yl(1):gridSpacing:yl(2)); 
    
    speed_flat = speed_90pct(:);
    
    % 2. Spatial Crop for optimization
    buffer = 50; 
    in_view = (cx_run(:) >= xl(1)-buffer & cx_run(:) <= xl(2)+buffer & ...
               cy_run(:) >= yl(1)-buffer & cy_run(:) <= yl(2)+buffer);
           
    isValid = in_view & isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
    
    if any(isValid)
        % Create interpolant using ONLY localized cells
        F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
        speed_grid = F_speed(X_grid, Y_grid);
        
        % 4. Plot contour line 
        contour(ax, X_grid, Y_grid, speed_grid, [0.6 0.6], ...
                'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'LineStyle', '-');
            
        % --- Calculate Area Below 0.6 m/s Inside Viewport KML Bounds ---
        isBelowThreshold = (speed_grid < 0.5);
        cellArea = gridSpacing * gridSpacing; % Automatically scales dynamically (625 m^2)
        
        % Isolate mask evaluation purely to the active location pane
        locMask = false(size(X_grid));
        if strcmp(currentLoc, 'Bath')
            for k = 1:numel(Bathflats_x)
                if ~isempty(Bathflats_x{k})
                    locMask = locMask | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
                end
            end
        elseif strcmp(currentLoc, 'Zimmerman')
            for k = 1:numel(Zimmflats_x)
                if ~isempty(Zimmflats_x{k})
                    locMask = locMask | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
                end
            end
        end   
        
        % Final dynamic location boundary selection mask
        targetNodesMask = locMask & isBelowThreshold;
        
        % Calculate total area in square meters
        areaResults.(currentLoc) = sum(targetNodesMask(:)) * cellArea;
        
        % Optional terminal display readout to verify results:
        % Display area in m^2 and hectares
        area_m2 = areaResults.(currentLoc);
        area_ha = area_m2 / 10000; % 1 hectare = 10,000 m^2
        fprintf('Location: %s | Low Dynamic Area: %.1f ha \n', currentLoc, area_ha);
        
        % --- Plot Low Dynamic Area as a Solid Shaded Region ---
        if any(targetNodesMask(:))
            hShade = pcolor(ax, X_grid, Y_grid, double(targetNodesMask));
            shading(ax, 'flat');
            
            % Enforce transparency mapping: 1 (opaque blue region), 0 (completely transparent overlay)
            set(hShade, 'FaceAlpha', 'flat', ...
                        'AlphaData', double(targetNodesMask) * 0.4, ... % Adjust 0.4 opacity as needed
                        'FaceColor', [0, 0, 1], ...                     % Pure Blue Fill
                        'EdgeColor', 'none');
        end  
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
        
        % Color/Colormap Sync
        nLevels = 12;
        cmap = turbo(nLevels);
        colormap(ax, cmap);
        clim(ax, [0 1.2]);
        
        
        % discrete color bins
        ch = findobj(ax, '-property', 'CData');
        for c = 1:numel(ch)
            C = get(ch(c), 'CData');
            if isnumeric(C)
                Cnorm = (C - 0) ./ (1 - 0);
                Cnorm = min(max(Cnorm, 0), 1);
                Cidx = round(Cnorm * (nLevels-1)) + 1;
                if isvector(Cidx)
                    rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
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
        
        % Colorbar Details
        if loc == 2
            cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
            cb.Position = [0.62, 0.09, 0.25, 0.03];  % [x y width height]
            cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
            tickPositions = 0:0.2:1.2;
            cb.Ticks = tickPositions;
            cb.TickLabels = string(tickPositions);
        end
        hold(ax, 'off');
    end

% LEGEND 
lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.06, 0.2, 0.05]);
% h_target = patch(lgdAxes, NaN, NaN, [0, 0, 1], 'FaceAlpha', 0.7, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
hold(lgdAxes, 'on');
h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'New Groyne');
h_groyne_ch = plot(lgdAxes, NaN, NaN, 'k--', 'LineWidth', 2, 'DisplayName', 'Modified');
h_groyne_ex = plot(lgdAxes, NaN, NaN,  '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 2.5, 'DisplayName', 'Existing Groyne');
h_contour =  plot(lgdAxes,  NaN, NaN, 'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', '0.6 m/s Contour');
lgd = legend(lgdAxes, [h_groyne, h_groyne_ch, h_groyne_ex, h_contour], 'Location', 'southwest', 'Orientation', 'vertical');
set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 
lgd.NumColumns = 2;                       % display legend entries in two columns
lgd.Position = [0.20, 0.06, 0.24, 0.05];  %[left, bottom, width, height]

% LABELS
for loc = 1:numel(axHandles)
    thisAx = axHandles(loc);
    set(thisAx, 'FontSize', 14, 'LineWidth', 1.2);
    xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
    if loc == 1
        ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
    end
    texTitle = sprintf('\\bf{\\it{%s}}', viewports(loc).name);
    title(thisAx, texTitle, 'FontSize', 22);
end

title(t, figName, 'FontSize', 26, 'FontWeight', 'bold');

% colorbar properties
if exist('cb', 'var') && isgraphics(cb)
    cb.FontSize = 14;               
    cb.Label.String = sprintf('\\bf{%.0fth Percentile Depth-Avg Velocity [m/s]}', percentile*100);
    cb.Label.FontSize = 14;
    set(cb, 'FontWeight', 'bold'); % Makes colorbar tick mark numbers bold
end

%% highlightinh LDA and gray sclae the rest
viewports(1).name = 'Bath';
viewports(1).xlim = [68900 72900];
viewports(1).ylim = [378850 380600];
viewports(2).name = 'Zimmerman';
viewports(2).xlim = [64000 68100];
viewports(2).ylim = [379200 381000];

% one figure with tiles
figName = sprintf('T0 with Groynes\n');
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
    if size(gridX,1) == 4
        cx_run = mean(gridX,1);
        cy_run = mean(gridY,1);
    end
    
    % for i = 1:length(folders)
        speed = speed_90pct;
        % Plot mesh patches
        patch(gridX, gridY, speed(:)', ...
            'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
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
    end 
    
    %=== plot 0.6 contour line ===
    xl = xlim(ax);
    yl = ylim(ax);
    
    % Consistent 20m grid spacing
    gridSpacing = 20;
    [X_grid, Y_grid] = meshgrid(xl(1):gridSpacing:xl(2), yl(1):gridSpacing:yl(2)); 
    
    speed_flat = speed_90pct(:);
    
    % Only interpolate inside or near this viewport.
    buffer = 50; 
    in_view = (cx_run(:) >= xl(1)-buffer & cx_run(:) <= xl(2)+buffer & ...
               cy_run(:) >= yl(1)-buffer & cy_run(:) <= yl(2)+buffer);
           
    isValid = in_view & isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
    
    if any(isValid)
        % Create interpolant using ONLY localized cells
        F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
        speed_grid = F_speed(X_grid, Y_grid);
        
        % Plot contour line
        contour(ax, X_grid, Y_grid, speed_grid, [0.5 0.5], ...
                'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'LineStyle', '-');
            
        % --- Calculate Area & Generate Target Mask ---
        isBelowThreshold = (speed_grid < 0.6);
        cellArea = gridSpacing * gridSpacing; 
        
        locMask = false(size(X_grid));
        if strcmp(currentLoc, 'Bath')
            for k = 1:numel(Bathflats_x)
                if ~isempty(Bathflats_x{k})
                    locMask = locMask | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
                end
            end
        elseif strcmp(currentLoc, 'Zimmerman')
            for k = 1:numel(Zimmflats_x)
                if ~isempty(Zimmflats_x{k})
                    locMask = locMask | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
                end
            end
        end   
        
        targetNodesMask = locMask & isBelowThreshold;
        areaResults.(currentLoc) = sum(targetNodesMask(:)) * cellArea;
        
        % --- MODIFICATION 1: Plot Low Dynamic Area as a Solid Blue Mask Patch ---
        if any(targetNodesMask(:))
            hShade = pcolor(ax, X_grid, Y_grid, double(targetNodesMask));
            shading(ax, 'flat');
            
            % Set to solid pure blue ([0, 0, 1]) with 40% transparency so grey grid shines through
            set(hShade, 'FaceAlpha', 'flat', ...
                        'AlphaData', double(targetNodesMask) * 0.4, ... 
                        'FaceColor', [0, 0, 1], ...                     
                        'EdgeColor', 'none');
        end
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
    
    % --- MODIFICATION 2: Change Colormap to White-to-Black ---
    nLevels = 12;
    cmap = flipud(gray(nLevels)); % Inverts gray map: 0 is White, Max is Black
    colormap(ax, cmap);
    clim(ax, [0 1.2]);
    
    % discrete color bins
    ch = findobj(ax, '-property', 'CData');
    for c = 1:numel(ch)
        C = get(ch(c), 'CData');
        if isnumeric(C)
            Cnorm = (C - 0) ./ (1.2 - 0); % Corrected normalized upper scaling boundary to 1.2
            Cnorm = min(max(Cnorm, 0), 1);
            Cidx = round(Cnorm * (nLevels-1)) + 1;
            if isvector(Cidx)
                rgb = reshape(cmap(Cidx(:),:), [size(Cidx(:),1), 3]);
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
    
    % Colorbar Details
    if loc == 2
        cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
        cb.Position = [0.62, 0.09, 0.25, 0.03];  % [x y width height]
        tickPositions = 0:0.2:1.2;
        cb.Ticks = tickPositions;
        cb.TickLabels = string(tickPositions);
    end
    hold(ax, 'off');
% end

% LEGEND 
lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.06, 0.2, 0.05]);
hold(lgdAxes, 'on');
h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'New Groyne');
h_groyne_ch = plot(lgdAxes, NaN, NaN, 'k--', 'LineWidth', 2, 'DisplayName', 'Modified');
h_groyne_ex = plot(lgdAxes, NaN, NaN,  '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 2.5, 'DisplayName', 'Existing Groyne');
h_contour =  plot(lgdAxes,  NaN, NaN, 'Color', [0.3 0.3 0.3], 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', '0.6 m/s Contour');
h_bluePatch = patch(lgdAxes, NaN, NaN, [0 0 1], 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'DisplayName', 'Area < 0.6 m/s');

lgd = legend(lgdAxes, [h_groyne, h_groyne_ch, h_groyne_ex, h_contour, h_bluePatch], 'Location', 'southwest', 'Orientation', 'vertical');
set(lgd, 'Box', 'off', 'FontSize', 16, 'Interpreter', 'none', 'TextColor', 'k');
set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); 
lgd.NumColumns = 2;                       
lgd.Position = [0.20, 0.06, 0.24, 0.05];  

% LABELS
for loc = 1:numel(axHandles)
    thisAx = axHandles(loc);
    set(thisAx, 'FontSize', 14, 'LineWidth', 1.2);
    xlabel(thisAx, '\bf{RDx [km]}', 'FontSize', 16);
    if loc == 1
        ylabel(thisAx, '\bf{RDy [km]}', 'FontSize', 16);
    end
    texTitle = sprintf('\\bf{\\it{%s}}', viewports(loc).name);
    title(thisAx, texTitle, 'FontSize', 22);
end
title(t, figName, 'FontSize', 26, 'FontWeight', 'bold');

% Colorbar properties sizing normalization updates
if exist('cb', 'var') && isgraphics(cb)
    cb.FontSize = 14;               
    cb.Label.String = sprintf('\\bf{95th Percentile Depth-Avg Velocity [m/s]}');
    cb.Label.FontSize = 14;
    set(cb, 'FontWeight', 'bold'); 
end