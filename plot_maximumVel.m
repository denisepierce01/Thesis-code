close all
clear al
clc

%plot max velocity per grid cell 

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
    % 'P:\11207654-internship-pierce-2026\03_Model\15_T0_fou_Apr18\output\' , ...
    'P:\11207654-internship-pierce-2026\03_Model\17_T0bathy_T1groynes_fou_Apr18\output' , ...
    % 'P:\11207654-internship-pierce-2026\03_Model\16_T1_fou_Apr18\output\',
};

% Names for the titles (Viscosity values) & save to mat files
names = {'T0 with Groynes'};
sigma_layers = [2 3 5 8 10 12 15 15 15 15];
sigma_weights = reshape(sigma_layers, 1, 1, 10);

for i = 1:length(folders)
    ncFile = fullfile(folders{i}, 'WS_0000_fou.nc');

    % % choose time
    % if i == 1
    %     t0 = '22-Apr-2018';
    %     tend = '23-May-2018';
    % end

    % read map/model data and grid info for this folder
    DataXY{i} = EHY_getMapModelData(ncFile, 'varName', 'mesh2d_fourier005_max', 'layer', '0'); %load all layers
    DataXY{i}.val = sum(DataXY{i}.val .* (sigma_weights / 100), 3); % depth averaged
    
    if i == 1
        gridInfo = EHY_getGridInfo(ncFile, 'face_nodes_xy');
        else
    end 

    % save per-run DataXY using descriptive names array
    nameVal = names(i);
    if isnumeric(nameVal)
        nameStr = sprintf('%g', names);
        nameStr = strrep(nameStr, '.', 'p'); % replace dot with 'p' for filenames
    else
        nameStr = matlab.lang.makeValidName(char(nameVal));
    end
    % save DataXY and gridInfo for this folder using the constructed name
    outName = fullfile(pwd, ['maxvel' nameStr '.mat']);
    velData = DataXY{i}; 
    save(outName, 'DataXY', 'gridInfo');
end

%% load .mat
% T0 = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\T0_maxvelT0.mat');    %T0
% T1 = load('P:\11207654-internship-pierce-2026\03_Model\ModelOutput\scripts\T1_maxvelT1.mat');    %T1
% velData = {T0};

velData = DataXY;

%% Plot max velocity
figName = sprintf('Low Dynamic Area %s', nameStr);
fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [200, 200, 800, 600]);

% Use axes instead of subplot so it occupies the full window
ax = axes('Parent', fig);
tix = k; 

% Compute hydro-mesh cell center geometry
if size(gridInfo.face_nodes_x,1) == 4
    cx_run = mean(gridInfo.face_nodes_x,1);
    cy_run = mean(gridInfo.face_nodes_y,1);
else
    cx_run = mean(gridInfo.face_nodes_x,2).';
    cy_run = mean(gridInfo.face_nodes_y,2).';
end

for i = 1:length(folders)
    speed = DataXY{i}.val;
    
    % Plot mesh patches
    if size(gridInfo.face_nodes_x,1) == 4
        patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
    else
        patch(gridInfo.face_nodes_x', gridInfo.face_nodes_y', speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
    end
    hold(ax, 'on');
    
     % =========================================================================
     % --- Plot 0.6 m/s Contour Line ---
     % =========================================================================
    % 1. Create a fine grid based on your current map viewport boundaries
    xl = xlim(ax);
    yl = ylim(ax);
    [X_grid, Y_grid] = meshgrid(xl(1):15:xl(2), yl(1):15:yl(2)); % 20-meter spacing for smooth contour
    
    % 2. Filter out any NaN coordinates or speeds
    speed_flat = speed(:);
    isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
    
    if any(isValid)
        % 3. Interpolate speed from cell centers onto the regular grid
        F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
        speed_grid = F_speed(X_grid, Y_grid);
        
        % 4. Plot ONLY the 0.6 contour line
        % [0.6 0.6] tells MATLAB to target exactly that value
        % hLine4 = contour(ax, X_grid, Y_grid, speed_grid, [0.6 0.6], ...
                                % 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-');
        % hPol(4) = plot(nan, nan, 'k-', 'LineWidth', 2); 
           
        % % Optional: Add a text label along the line automatically
        % clabel(C, hContour, 'FontSize', 10, 'Color', 'k', 'FontWeight', 'bold');
    end 

    % =========================================================================
    % Calculate Area Below 0.6 m/s Inside KML
    % =========================================================================
    % 1. Create a logical mask for grid nodes below 0.6
    isBelowThreshold = (speed_grid < 0.6);
    
    % 2. Initialize a mask to track which grid nodes fall inside ANY KML polygon
    isInsideAnyKML = false(size(X_grid));
    % 3. Loop through KML polygons (Bathflats and Zimmflats)
    for ki = 1:max([numel(Bathflats_x), numel(Zimmflats_x)])
        % Bathflats polygon (if exists)
        if ki <= numel(Bathflats_x) && ~isempty(Bathflats_x{ki})
            inPolyBath = inpolygon(X_grid, Y_grid, Bathflats_x{ki}, Bathflats_y{ki});
            isInsideAnyKML = isInsideAnyKML | inPolyBath;
        end
        % Zimmflats polygon (if exists)
        if ki <= numel(Zimmflats_x) && ~isempty(Zimmflats_x{ki})
            inPolyZimm = inpolygon(X_grid, Y_grid, Zimmflats_x{ki}, Zimmflats_y{ki});
            isInsideAnyKML = isInsideAnyKML | inPolyZimm;
        end
    end
    
    % 4. Combine conditions: Inside KML AND speed < 0.6 m/s
    targetNodesMask = isInsideAnyKML & isBelowThreshold;
    gridSpacing = 15;                     % meters
    cellArea = gridSpacing * gridSpacing; % m^2 per grid cell
    isInBath = false(size(X_grid));
    isInZimm = false(size(X_grid));
    
    maxK = max(numel(Bathflats_x), numel(Zimmflats_x));
    for k = 1:maxK
        if k <= numel(Bathflats_x) && ~isempty(Bathflats_x{k})
            isInBath = isInBath | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
        end
        if k <= numel(Zimmflats_x) && ~isempty(Zimmflats_x{k})
            isInZimm = isInZimm | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
        end
    end
    
    % Combine with speed threshold (speed mask: logical where speed < 0.6)
    bathMask = isInBath & isBelowThreshold;
    zimmMask = isInZimm & isBelowThreshold;
    
    totalBathArea_m2 = sum(bathMask(:)) * cellArea;
    totalZimmArea_m2 = sum(zimmMask(:)) * cellArea;
    
    fprintf('Bathflats area (speed<0.6): %.2f m^2 (%.1f ha)\n', totalBathArea_m2, totalBathArea_m2/1e4);
    fprintf('Zimmflats area (speed<0.6): %.2f m^2 (%.1f ha)\n', totalZimmArea_m2, totalZimmArea_m2/1e4);
    
    % % plot low dynamic area as shaded region:
    % plot(ax, X_grid(targetNodesMask), Y_grid(targetNodesMask), 'r.', 'MarkerSize', 3);

    % ---plot strekdammen nieuw + aangepast + bestaand--- (only for i == 2)
    if i == 1
        for k = 1:numel(Nieuw_x)
            if ~isempty(Nieuw_x{k})
                hPol(end+1) = plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'k-', 'LineWidth', 3); %#ok<SAGROW>
            end
        end
    end
    hPol(3) = plot(ax, nan, nan, 'k-', 'LineWidth', 2); % placeholder for legend
    
    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
        hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, 'k-','LineWidth', 3); %#ok<SAGROW>
        end
    end

    hPol(1) = plot(nan, nan, 'k-', 'LineWidth', 2); % to use in
    
    for ki = 1:numel(Bestaand_x)
        if ~isempty(Bestaand_x{ki})
        hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, 'k-', 'LineWidth', 3); %#ok<SAGROW>
        end
    end
    hPol(2) = hLine2;
    
    %========= Map geographic viewport=========
    % %Bath
    % xlim(ax, [69600 72900]);
    % ylim(ax, [378900 380600]);
    
    %Bath expansion
    xlim(ax, [69000 72900]);
    ylim(ax, [378800 380600]);
    
    % Zimm
    % xlim(ax, [64300 67200]);   % RDx in meters
    % ylim(ax, [379300 380900]); % RDy in meters
    
    %Zimm expansion
    xlim(ax, [65000 68500]);
    ylim(ax, [378500 381000]);
    
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
end

% Format Axes labels into uniform Kilometers units
xlabel(ax, 'RDx [km]', 'FontSize', 16, 'FontWeight', 'bold');
ylabel(ax, 'RDy [km]', 'FontSize', 16, 'FontWeight', 'bold');
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

    % Plot Title
    title(ax, figName, 'FontSize', 24, 'FontWeight', 'bold');
end
hold(ax, 'off');

% colobar
cb = colorbar(ax);
cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.FontSize = 12;
cb.FontWeight = 'bold';

% ========================================================
% COMPONENT ROUTING TO EMPTY TILE 4 (Legend & Colorbar)
% ========================================================
% Create invisible axes in current figure for legend & colorbar placement
axLeg = axes('Visible', 'off', 'Units', 'normalized', 'Position', [0.75 0.05 0.2 0.15]);

h_target = plot(axLeg, NaN, NaN, 'r.', 'MarkerSize', 8, 'DisplayName', 'Low Dynamic Area');
h_groyne = plot(axLeg, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'Structures');

% Build the legend on the invisible axes; ensure handles are valid
validHandles = [h_target, h_groyne];
validHandles = validHandles(arrayfun(@(h) isgraphics(h), validHandles));

if isempty(validHandles)
    % Fallback: create a simple text legend on the invisible axes
    text(0.1, 0.6, 'Low Dynamic Area', 'Parent', axLeg, 'Color', 'r', 'FontSize', 10);
    text(0.1, 0.3, 'Structures', 'Parent', axLeg, 'Color', 'k', 'FontSize', 10);
else
    lgd = legend(axLeg, validHandles, 'Location', 'southoutside', 'Orientation', 'horizontal');
    set(lgd, 'Box', 'off', 'FontSize', 12, 'Interpreter', 'none', 'Color', 'none', 'TextColor', 'k');
    if isprop(lgd, 'ItemTokenSize')
        set(lgd, 'ItemTokenSize', [30 18]);
    end
end

% Ensure the main axes retains focus and colorbar/limits
if exist('ax','var') && isgraphics(ax)
    axes(ax);
end

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

% %% Subplots Bath and Zimm Low Dynamic Areas (bad spacing. old version)
% viewports(1).name = 'Bath';
% viewports(1).xlim = [68900 72900];
% viewports(1).ylim = [378850 380600];
% 
% viewports(2).name = 'Zimmerman';
% viewports(2).xlim = [64000 68100];
% viewports(2).ylim = [379000 381000];
% 
% % Create ONE main wide figure window for side-by-side display
% figName = sprintf('Low Dynamic Area: %s', nameStr);
% fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [100, 150, 1400, 600]);
% 
% % Loop over both geographical locations to build subplots
% for loc = 1:numel(viewports)
%     currentLoc = viewports(loc).name;
% 
%     % Create subplot: 1 row, 2 columns, active pane is 'loc'
%     ax = subplot(1, 2, loc, 'Parent', fig);
% 
%     % Compute hydro-mesh cell center geometry
%     if size(gridInfo.face_nodes_x,1) == 4
%         cx_run = mean(gridInfo.face_nodes_x,1);
%         cy_run = mean(gridInfo.face_nodes_y,1);
%     else
%         cx_run = mean(gridInfo.face_nodes_x,2).';
%         cy_run = mean(gridInfo.face_nodes_y,2).';
%     end
% 
%     for i = 1:length(folders)
%         speed = DataXY{i}.val;
% 
%         % Plot mesh patches
%         if size(gridInfo.face_nodes_x,1) == 4
%             patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
%                   'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%         else
%             patch(gridInfo.face_nodes_x', gridInfo.face_nodes_y', speed(:)', ...
%                   'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%         end
%         hold(ax, 'on');
% 
%         % =========================================================================
%         % --- Create Interpolation Grid ---
%         % =========================================================================
%         xl = viewports(loc).xlim;
%         yl = viewports(loc).ylim;
%         [X_grid, Y_grid] = meshgrid(xl(1):15:xl(2), yl(1):15:yl(2)); 
% 
%         speed_flat = speed(:);
%         isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
% 
%         if any(isValid)
%             F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
%             speed_grid = F_speed(X_grid, Y_grid);
%         end 
% 
%         % =========================================================================
%         % Calculate Area Below 0.6 m/s Inside KML
%         % =========================================================================
%         isBelowThreshold = (speed_grid < 0.6);
%         gridSpacing = 15;                     
%         cellArea = gridSpacing * gridSpacing; 
% 
%         isInBath = false(size(X_grid));
%         isInZimm = false(size(X_grid));
% 
%         maxK = max(numel(Bathflats_x), numel(Zimmflats_x));
%         for k = 1:maxK
%             if k <= numel(Bathflats_x) && ~isempty(Bathflats_x{k})
%                 isInBath = isInBath | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
%             end
%             if k <= numel(Zimmflats_x) && ~isempty(Zimmflats_x{k})
%                 isInZimm = isInZimm | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
%             end
%         end
% 
%         % Combine with speed threshold
%         bathMask = isInBath & isBelowThreshold;
%         zimmMask = isInZimm & isBelowThreshold;
% 
%         totalBathArea_m2 = sum(bathMask(:)) * cellArea;
%         totalZimmArea_m2 = sum(zimmMask(:)) * cellArea;
% 
%         % Isolate targets for visual plot points
%         if strcmp(currentLoc, 'Bath')
%             targetNodesMask = bathMask; 
%         else
%             targetNodesMask = zimmMask;
%         end
% 
%         % Plot low dynamic area as shaded region
%         % plot(ax, X_grid(targetNodesMask), Y_grid(targetNodesMask), 'r.', 'MarkerSize', 3);
% 
%         % --- Plot Low Dynamic Area as a Solid Shaded Region ---
%         if any(targetNodesMask(:))
%             maskData = double(targetNodesMask);
%             [~, hShade] = contourf(ax, X_grid, Y_grid, maskData, [0.5 0.5], 'LineStyle', 'none'); %trace contour
%             set(hShade, 'FaceColor', [1, 0, 0], 'FaceAlpha', 0.8);  % shades low dynamic area
%         end
% 
%         % --- Plot structures ---
%         if i == 1
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
%     %========= Set active geographic viewport limits =========
%     xlim(ax, viewports(loc).xlim);
%     ylim(ax, viewports(loc).ylim);
% 
%     % Format Axes labels into uniform Kilometers units
%     xlabel(ax, 'RDx [km]', 'FontSize', 14, 'FontWeight', 'bold');
%     ylabel(ax, 'RDy [km]', 'FontSize', 14, 'FontWeight', 'bold');
%     daspect(ax, [1 1 1]);
% 
%     % ticks in kilometers
%     xl = xlim(ax); yl = ylim(ax);
%     xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
%     yk_min = floor(yl(1)/1000 * 2) / 2; yk_max = ceil(yl(2)/1000 * 2) / 2;
%     xk = (xk_min : 1.0 : xk_max);            
%     yk = (yk_min : 0.5 : yk_max);            
%     set(ax, 'XTick', xk*1000, 'YTick', yk*1000);
%     set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%            'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
% 
%     % Subplot Title
%     title(ax, currentLoc, 'FontSize', 16, 'FontWeight', 'bold');
% 
%     % colormap
%     nLevels = 12;
%     cmap = parula(nLevels);
%     colormap(ax, cmap);
%     clim(ax, [0 1.2]);
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
%     hold(ax, 'off');
% 
%     % Only add colorbar for loc == 2
%     if loc == 2
%         cb = colorbar(ax);
%         cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
%         cb.Label.FontSize = 10;
%         cb.Label.FontWeight = 'bold';
%     end
% 
% 
% end
% 
% % --- Print Areas Summary to Console ---
% fprintf('Bathflats [%s] (speed<0.6): %.2f m^2 (%.1f ha)\n', nameStr, totalBathArea_m2, totalBathArea_m2/1e4);
% fprintf('Zimmflats [%s] (speed<0.6): %.2f m^2 (%.1f ha)\n', nameStr, totalZimmArea_m2, totalZimmArea_m2/1e4);
% 
% % big title
% sgtitle(fig, figName, 'FontSize', 20, 'FontWeight', 'bold');
% 
% % legend
% lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.4, 0.01, 0.2, 0.05]);
% h_target = patch(lgdAxes, NaN, NaN, [1 0 0], 'FaceAlpha', 0.8, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
% hold(lgdAxes, 'on');
% h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'Structures');
% lgd = legend(lgdAxes, [h_target, h_groyne], 'Location', 'southeast', 'Orientation', 'vertical');
% set(lgd, 'Box', 'off', 'FontSize', 12, 'Interpreter', 'none', 'TextColor', 'k');
% % NOW hide the auxiliary legend track axis safely without breaking the children elements
% set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []);

% %% tiled bath and zimm low dynamic areas (bad axes. older version)
% viewports(1).name = 'Bath';
% viewports(1).xlim = [68900 72900];
% viewports(1).ylim = [378850 380600];
% viewports(2).name = 'Zimmerman';
% viewports(2).xlim = [64000 68100];
% viewports(2).ylim = [379200 381000];
% 
% % Create ONE main wide figure window
% figName = sprintf('Low Dynamic Area: %s\n', nameStr);
% fig = figure('Name', figName, 'NumberTitle', 'off', 'Position', [100, 150, 1400, 600]);
% 
% % Create a compact tiled layout with tight spacing
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
%     if size(gridInfo.face_nodes_x,1) == 4
%         cx_run = mean(gridInfo.face_nodes_x,1);
%         cy_run = mean(gridInfo.face_nodes_y,1);
%     else
%         cx_run = mean(gridInfo.face_nodes_x,2).';
%         cy_run = mean(gridInfo.face_nodes_y,2).';
%     end
% 
%     for i = 1:length(folders)
%         speed = DataXY{i}.val;
% 
%         % Plot mesh patches
%         if size(gridInfo.face_nodes_x,1) == 4
%             patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
%                   'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%         else
%             patch(gridInfo.face_nodes_x', gridInfo.face_nodes_y', speed(:)', ...
%                   'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
%         end
%         hold(ax, 'on');
% 
%         % --- Create Interpolation Grid ---
%         xl = viewports(loc).xlim;
%         yl = viewports(loc).ylim;
%         [X_grid, Y_grid] = meshgrid(xl(1):15:xl(2), yl(1):15:yl(2)); 
% 
%         speed_flat = speed(:);
%         isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
% 
%         if any(isValid)
%             F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
%             speed_grid = F_speed(X_grid, Y_grid);
%         end 
% 
%         % --- Calculate Area Below 0.6 m/s Inside Viewport KML Bounds ---
%         isBelowThreshold = (speed_grid < 0.6);
%         gridSpacing = 15;                     
%         cellArea = gridSpacing * gridSpacing; 
% 
%         % Isolate mask evaluation purely to the active location pane
%         locMask = false(size(X_grid));
%         if strcmp(currentLoc, 'Bath')
%             for k = 1:numel(Bathflats_x)
%                 if ~isempty(Bathflats_x{k})
%                     locMask = locMask | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
%                 end
%             end
%         elseif strcmp(currentLoc, 'Zimmerman')
%             for k = 1:numel(Zimmflats_x)
%                 if ~isempty(Zimmflats_x{k})
%                     locMask = locMask | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
%                 end
%             end
%         end
% 
%         % Final dynamic location boundary selection mask
%         targetNodesMask = locMask & isBelowThreshold;
%         areaResults.(currentLoc) = sum(targetNodesMask(:)) * cellArea;
% 
%         % --- Plot Low Dynamic Area as a Solid Shaded Region ---
%         if any(targetNodesMask(:))
%             maskData = double(targetNodesMask);
%             [~, hShade] = contourf(ax, X_grid, Y_grid, maskData, [0.5 0.5], 'LineStyle', 'none'); 
%             set(hShade, 'FaceColor', [0, 0, 1], 'FaceAlpha', 0.7);
%         end
% 
%         % --- Plot structures ---
%         if i == 1
%             for k = 1:numel(Nieuw_x)
%                 if ~isempty(Nieuw_x{k})
%                     plot(ax, Nieuw_x{k}, Nieuw_y{k}, 'r-', 'LineWidth', 3);
%                 end
%             end
%         end
% 
%         for ki = 1:numel(Aangepast_x)
%             if ~isempty(Aangepast_x{ki})
%                 plot(ax, Aangepast_x{ki}, Aangepast_y{ki}, 'r-','LineWidth', 3);
%             end
%         end
% 
%         for ki = 1:numel(Bestaand_x)
%             if ~isempty(Bestaand_x{ki})
%                 plot(ax, Bestaand_x{ki}, Bestaand_y{ki}, 'r-', 'LineWidth', 3);
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
%     set(ax, 'XTick', xk*1000, 'YTick', yk*1000, 'FontSize', 12);
%     set(ax, 'XTickLabel', arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false), ...
%            'YTickLabel', arrayfun(@(v) sprintf('%.1f', v), yk, 'UniformOutput', false));
% 
%     % Color/Colormap Sync
%     nLevels = 6;
%     cmap = [linspace(1,0, nLevels)' linspace(1,0, nLevels)' linspace(1,0, nLevels)'];
%     colormap(ax, cmap);
%     clim(ax, [0 1.2]);
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
%     % colorbar details
%     if loc == 2
%         cb = colorbar(ax, 'southoutside', 'Orientation', 'horizontal');
%         cb.Position = [0.62, 0.12, 0.25, 0.03];  % [x y width height]
%         cb.Label.String = 'Maximum Depth-Avg Velocity [m/s]';
%         cb.FontSize = 12;               % tick label size
%         cb.Label.FontSize = 14;
%         cb.Label.FontWeight = 'bold';
%     end
%     hold(ax, 'off');
% end
% 
% % --- Print Areas Summary to Console ---
% fprintf('Bathflats [%s] (speed<0.6): %.2f m^2 (%.1f ha)\n', nameStr, areaResults.Bath, areaResults.Bath/1e4);
% fprintf('Zimmflats [%s] (speed<0.6): %.2f m^2 (%.1f ha)\n', nameStr, areaResults.Zimmerman, areaResults.Zimmerman/1e4);
% 
% %legend
% lgdAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.22, 0.10, 0.2, 0.05]);
% h_target = patch(lgdAxes, NaN, NaN, [0, 0, 1], 'FaceAlpha', 0.7, 'EdgeColor', 'none', 'DisplayName', 'Low Dynamic Area'); 
% hold(lgdAxes, 'on');
% h_groyne = plot(lgdAxes, NaN, NaN, 'r-', 'LineWidth', 3, 'DisplayName', 'Structures');
% lgd = legend(lgdAxes, [h_target, h_groyne], 'Location', 'southwest', 'Orientation', 'vertical');
% set(lgd, 'Box', 'off', 'FontSize', 18, 'Interpreter', 'none', 'TextColor', 'k');
% set(lgdAxes, 'Visible', 'off', 'XTick', [], 'YTick', []); % hide the auxiliary legend 
% 
% % Labels
% for loc = 1:numel(axHandles)
%     thisAx = axHandles(loc);
%     set(thisAx, 'FontWeight', 'bold', 'FontSize', 12, 'LineWidth', 1.2);
%     xlabel(thisAx, 'RDx [km]', 'FontSize', 14, 'FontWeight', 'bold');
%     ylabel(thisAx, 'RDy [km]', 'FontSize', 14, 'FontWeight', 'bold');
% title(thisAx, viewports(loc).name, 'FontSize', 18, 'FontWeight', 'bold', 'FontAngle', 'italic');
% end
% 
% % title(t, figName, 'FontSize', 18, 'FontWeight', 'bold');

%% tiled bath and zimm low dynamic areas
viewports(1).name = 'Bath';
viewports(1).xlim = [68900 72900];
viewports(1).ylim = [378850 380600];
viewports(2).name = 'Zimmerman';
viewports(2).xlim = [64000 68100];
viewports(2).ylim = [379200 381000];

% one figure with tiles
figName = sprintf('T0 with Groynes\n', nameStr);
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
    if size(gridInfo.face_nodes_x,1) == 4
        cx_run = mean(gridInfo.face_nodes_x,1);
        cy_run = mean(gridInfo.face_nodes_y,1);
    else
        cx_run = mean(gridInfo.face_nodes_x,2).';
        cy_run = mean(gridInfo.face_nodes_y,2).';
    end
    
    for i = 1:length(folders)
        speed = DataXY{i}.val;
        
        % Plot mesh patches
        if size(gridInfo.face_nodes_x,1) == 4
            patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
                  'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
        else
            patch(gridInfo.face_nodes_x', gridInfo.face_nodes_y', speed(:)', ...
                  'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
        end
        hold(ax, 'on');

        if any(isValid)
            % Interpolate speed from cell centers
            F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
            speed_grid = F_speed(X_grid, Y_grid);
            
            % 4. Plot 0.6 contour linr
            hLine4 = contour(ax, X_grid, Y_grid, speed_grid, [0.6 0.6], ...
                                    'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'LineStyle', '-');          
            % % Optional: Add a text label along the line automatically
            % clabel(C, hContour, 'FontSize', 10, 'Color', 'k', 'FontWeight', 'bold');
        end 
        
        % % --- Determine & Plot Low Dynamic Area ---
        % xl = viewports(loc).xlim;
        % yl = viewports(loc).ylim;
        % [X_grid, Y_grid] = meshgrid(xl(1):15:xl(2), yl(1):15:yl(2)); 
        % 
        % speed_flat = speed(:);
        % isValid = isfinite(cx_run(:)) & isfinite(cy_run(:)) & isfinite(speed_flat);
        % 
        % if any(isValid)
        %     F_speed = scatteredInterpolant(cx_run(isValid)', cy_run(isValid)', speed_flat(isValid), 'linear', 'none');
        %     speed_grid = F_speed(X_grid, Y_grid);
        % end 
        % 
        % % --- Calculate Area Below 0.6 m/s Inside Viewport KML Bounds ---
        % isBelowThreshold = (speed_grid < 0.6);
        % gridSpacing = 15;                     
        % cellArea = gridSpacing * gridSpacing; 
        % 
        % % Isolate mask evaluation purely to the active location pane
        % locMask = false(size(X_grid));
        % if strcmp(currentLoc, 'Bath')
        %     for k = 1:numel(Bathflats_x)
        %         if ~isempty(Bathflats_x{k})
        %             locMask = locMask | inpolygon(X_grid, Y_grid, Bathflats_x{k}, Bathflats_y{k});
        %         end
        %     end
        % elseif strcmp(currentLoc, 'Zimmerman')
        %     for k = 1:numel(Zimmflats_x)
        %         if ~isempty(Zimmflats_x{k})
        %             locMask = locMask | inpolygon(X_grid, Y_grid, Zimmflats_x{k}, Zimmflats_y{k});
        %         end
        %     end
        % end
        % 
        % % Final dynamic location boundary selection mask
        % targetNodesMask = locMask & isBelowThreshold;
        % areaResults.(currentLoc) = sum(targetNodesMask(:)) * cellArea;
        % 
        % % --- Plot Low Dynamic Area as a Solid Shaded Region ---
        % if any(targetNodesMask(:))
        %     maskData = double(targetNodesMask);
        %     [~, hShade] = contourf(ax, X_grid, Y_grid, maskData, [0.5 0.5], 'LineStyle', 'none'); 
        %     set(hShade, 'FaceColor', [0, 0, 1], 'FaceAlpha', 0.7);
        % end
        
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
    
    % Force patch face colors to use discrete bins
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
h_target = plot(lgdAxes, NaN, NaN, 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'DisplayName', '0.6 m/s'); 
hold(lgdAxes, 'on');
h_groyne = plot(lgdAxes, NaN, NaN, 'k-', 'LineWidth', 3, 'DisplayName', 'Structures');
lgd = legend(lgdAxes, [h_target, h_groyne], 'Location', 'southwest', 'Orientation', 'vertical');
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
    cb.Label.String = '\bf{Maximum Depth-Avg Velocity [m/s]}';
    cb.Label.FontSize = 14;
    set(cb, 'FontWeight', 'bold'); % Makes colorbar tick mark numbers bold
end

%% --- export all open figures ---
outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\Max_Velocity';
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

pngName = fullfile(outDir, sprintf('T0wGroynes_maxVel.png', safeFigName));

% Save figure at 300 DPI
set(fig, 'PaperPositionMode', 'auto');
print(fig, pngName, '-dpng', '-r300');