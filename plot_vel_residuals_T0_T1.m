clear all
close all
clc

% plot residuals and vector field
% D. Pierce

%variables in nc files
    % mesh2d_average001_avg    = Average 001: U-component of cell-centre velocity, average value
    % mesh2d_average002_avg    = Average 002: V-component of cell-centre velocity, average value
    % mesh2d_average003_avg   = Average 003: U-component velocity, column average, average value
    % mesh2d_average004_avg   = Average 004: V-component velocity, column average, average value

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

KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\flowfieldarrows_boundary_enlarged.kml');
for ki = 1:length(KML)
    [flowfield_x{ki},flowfield_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

% KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_Zimm.kml');
% for ki = 1:length(KML)
%     [flowfield_x{ki},flowfield_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
% end

%% load model runs
folders = { ...
    % 'P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\output\' , ... %T0
    'P:\11207654-internship-pierce-2026\03_Model\14_T0bathy_T1groynes_Apr18\output\'  , ...   %T0 add groynes
      % 'P:\11207654-internship-pierce-2026\03_Model\12_T1bathy_T1groynes_Apr18\output\'  %T1
};
name = {
        % 'T0'; 
        'T0 with Groynes'
        % 'T1'
};

sigma_layers = [2 3 5 8 10 12 15 15 15 15];
zCCperc = sigma_layers/2 + [0 cumsum(sigma_layers(1:end-1))];

% loop through folders, load grid and velocity residuals, save to .mat
for k = 1:numel(folders)
    clear DataU DataV gridInfo; 

    currentFolder = folders{k}; % Code clarity helper
    mapFile = fullfile(currentFolder, 'WS_0000_map.nc');

    % select time
    t0 = '22-Apr-2018';
    tend = '23-May-2018'; 

    % load grid info (XY coordinates) - FIX: Kept inside loop in case grids differ
    if isfile(mapFile)
        gridInfo = EHY_getGridInfo(mapFile, {'face_nodes_xy'});
    else
        warning('Map file not found: %s', mapFile);
        gridInfo = [];
    end

    % load velocity residuals (layer 0 = depth-averaged / residual)
    fouFile = fullfile(currentFolder, 'WS_0000_fou.nc'); 
    if ~isfile(fouFile)
        % try to find any _fou.nc
        ncList = dir(fullfile(currentFolder, '*fou*.nc')); 
        if isempty(ncList)
            warning('No fou file found in %s. Skipping velocities.', currentFolder);
            DataU = []; DataV = [];
        else
            fouFile = fullfile(currentFolder, ncList(1).name);
        end
    end

    % Load data if file exists
    if isfile(fouFile)
        try
            DataU = EHY_getMapModelData(fouFile, 'varName', 'mesh2d_average001_avg', 't0', t0, 'tend', tend, 'layer', '0');
            DataV = EHY_getMapModelData(fouFile, 'varName', 'mesh2d_average002_avg', 't0', t0, 'tend', tend, 'layer', '0');
        catch ME
            warning('Failed to read velocity data from %s: %s', fouFile, ME.message);
            DataU = []; DataV = [];
        end
    end

    % prepare output struct and save
    out = struct(); % Reset struct every iteration
    out.gridInfo = gridInfo;
    out.sigma_layers = sigma_layers;
    if exist('DataU','var') && ~isempty(DataU); out.DataU = DataU; end
    if exist('DataV','var') && ~isempty(DataV); out.DataV = DataV; end

    % FIX: Changed 'names(k)' to 'name{k}' and altered '%g' to '%s'
    nameVal = name{k}; 
    matName = sprintf('%s.mat', nameVal); 

    try
        save(matName, '-struct', 'out');
        fprintf('Successfully saved: %s\n', matName);
    catch ME
        warning('Failed to save %s: %s', matName, ME.message);
    end
end

% %% after loop, load the last-run files used below (keep compatibility)
% % Note: fouFile and gridInfo will naturally belong to the last element of the loop (k=3)
% if exist('fouFile','var') && isfile(fouFile)
%     DataU = EHY_getMapModelData(fouFile,'varName','mesh2d_average001_avg','layer','0');
%     DataV = EHY_getMapModelData(fouFile,'varName','mesh2d_average002_avg','layer','0');
% end
% 
% if ~exist('gridInfo','var') || isempty(gridInfo)
%     error('No gridInfo available from the final folder run.');
% end

%% import .mat 
% load files and store in distinct structs to avoid overwriting variables
% load .mat files and assign to descriptive variables/structs
% v1 = load('P:\11207654-internship-pierce-2026\03_Model\data_TdW\scripts\DP\residual_T0.mat');
% v3 = load('P:\11207654-internship-pierce-2026\03_Model\data_TdW\scripts\DP\residual_T1.mat');
v2 = load("P:\11207654-internship-pierce-2026\03_Model\data_TdW\scripts\DP\residual_T0wGroynes.mat");
% grid =load('P:\11207654-internship-pierce-2026\03_Model\data_TdW\scripts\DP\residual_T0.mat');

% store all in a cell for easy iteration if needed
viscData = {v2,};
viscNames = {'T0wGroynes'};

% % select the first dataset as the default Data, DataU, DataV, sigma_layers, gridInfo
% % (adjust selection index if a different file should be active)
% sel = 1;
% S = viscData{sel};
% 
% % Copy expected variables from loaded .mat into workspace variables used later
% % Only assign if present to avoid errors
% if isfield(S, 'DataU'); DataU = S.DataU; end
% if isfield(S, 'DataV'); DataV = S.DataV; end
% if isfield(S, 'sigma_layers'); sigma_layers = S.sigma_layers; end
% if isfield(S, 'gridInfo'); gridInfo = S.gridInfo; end
% 
% % also expose the selected full struct for reference
% Data = S;

%% depth average
% Compute depth-averaged velocities from sigma_layers
for i = 1:length(viscData)
    S = viscData{i};
    % ensure DataU/DataV/sigma_layers exist in this struct
    if ~isfield(S,'DataU') || ~isfield(S,'DataV') || ~isfield(S,'sigma_layers')
        warning('viscData{%d} missing DataU/DataV/sigma_layers. Skipping.', i);
        continue;
    end

    DU = S.DataU;
    DV = S.DataV;
    sigma_layers_local = S.sigma_layers(:);

    % determine orientation and transpose if necessary so rows = nLayers
    nLayers = length(sigma_layers_local);
    % handle DataU
    if size(DU.val,2) == nLayers && size(DU.val,1) ~= nLayers
        DataU_layers = DU.val.'; % nLayers x nCells
    else
        DataU_layers = DU.val;
    end
    % handle DataV
    if size(DV.val,2) == nLayers && size(DV.val,1) ~= nLayers
        DataV_layers = DV.val.'; % nLayers x nCells
    else
        DataV_layers = DV.val;
    end

    % If flattened differently, attempt reshape using nLayers
    if size(DataU_layers,1) ~= nLayers && numel(DU.val) == nLayers * (numel(DU.val)/nLayers)
        DataU_layers = reshape(DU.val, nLayers, []);
    end
    if size(DataV_layers,1) ~= nLayers && numel(DV.val) == nLayers * (numel(DV.val)/nLayers)
        DataV_layers = reshape(DV.val, nLayers, []);
    end

    % compute normalized layer fractions (handle zeros)
    if all(isfinite(sigma_layers_local)) && sum(sigma_layers_local) > 0
        layer_frac = sigma_layers_local / sum(sigma_layers_local);
    else
        layer_frac = ones(nLayers,1) / nLayers;
    end

    % compute depth-averaged values (1 x nCells)
    DataU_da.val = (layer_frac.' * DataU_layers);
    DataV_da.val = (layer_frac.' * DataV_layers);

    % Replace invalid fill values with NaN (assume fill <= -900)
    DataU_da.val(DataU_da.val <= -900) = NaN;
    DataV_da.val(DataV_da.val <= -900) = NaN;

    % % save depth-averaged results into a .mat alongside original name if available
    % if i <= length(viscNames)
    %     outName = sprintf('%s_da.mat', viscNames{i});
    % else
    %     outName = sprintf('visc_%d_da.mat', i);
    % end
    % try
    %     save(outName, 'DataU_da', 'DataV_da', '-v7.3');
    % catch ME
    %     warning('Failed to save %s: %s', outName, ME.message);
    % end

    % if this is the selected dataset (sel), expose variables for plotting below
    if i == length(viscData);
        DataU = DataU_da;
        DataV = DataV_da;
        Data = S;
        sigma_layers = sigma_layers_local;
    end
end

%% Plot model residual velocities in 2x2 grid
nRuns = length(folders);
% create 2x2 tiled layout leaving room (approx 8% of figure height) at top for a shared title
t = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
% adjust outer position to reserve ~8% for title (use normalized units)
fig = gcf;
origPos = fig.Position; % in pixels, preserved for backup
set(t, 'Units', 'normalized');
outer = get(t, 'OuterPosition'); % normally [0 0 1 1]
% shrink tiled area vertically by 8% and shift down to leave space at top
reserve = 0.07;
set(t, 'OuterPosition', [outer(1), outer(2), outer(3), outer(4)*(1-reserve)]);
% create an invisible axes at top to host the title if needed
titleAx = axes('Position',[0, 1-(reserve), 1, reserve],'Visible','off','HitTest','off');

for k = 1:nRuns
    S = viscData{k};
    % attempt to use depth-averaged fields if present, otherwise compute as above
    if isfield(S, 'DataU_da') && isfield(S, 'DataV_da')
        DU = S.DataU_da;
        DV = S.DataV_da;
    else
        % fall back to per-layer DataU/DataV if depth-averaged not stored
        if ~isfield(S,'DataU') || ~isfield(S,'DataV') || ~isfield(S,'sigma_layers')
            warning('viscData{%d} missing required fields. Skipping.', k);
            continue;
        end
        DU = S.DataU;
        DV = S.DataV;
        sigma_layers_local = S.sigma_layers(:);
        nLayers = length(sigma_layers_local);
        % ensure orientation nLayers x nCells
        if size(DU.val,2) == nLayers && size(DU.val,1) ~= nLayers
            DataU_layers = DU.val.';
        else
            DataU_layers = DU.val;
        end
        if size(DV.val,2) == nLayers && size(DV.val,1) ~= nLayers
            DataV_layers = DV.val.';
        else
            DataV_layers = DV.val;
        end
        if size(DataU_layers,1) ~= nLayers && numel(DU.val) == nLayers * (numel(DU.val)/nLayers)
            DataU_layers = reshape(DU.val, nLayers, []);
        end
        if size(DataV_layers,1) ~= nLayers && numel(DV.val) == nLayers * (numel(DV.val)/nLayers)
            DataV_layers = reshape(DV.val, nLayers, []);
        end
        if all(isfinite(sigma_layers_local)) && sum(sigma_layers_local) > 0
            layer_frac = sigma_layers_local / sum(sigma_layers_local);
        else
            layer_frac = ones(nLayers,1) / nLayers;
        end
        DU.val = (layer_frac.' * DataU_layers);
        DV.val = (layer_frac.' * DataV_layers);
        DU.val(DU.val <= -900) = NaN;
        DV.val(DV.val <= -900) = NaN;
    end

    % Plot each run in its tiled axis
    ax = nexttile(t);
    axes(ax);
    hold(ax, 'on');

    % compute cell centers from the 4 face node coordinates (assumes NaN-free quads)
    if size(gridInfo.face_nodes_x,1) == 4
        cx = mean(gridInfo.face_nodes_x,1);
        cy = mean(gridInfo.face_nodes_y,1);
    else
        cx = mean(gridInfo.face_nodes_x,2).';
        cy = mean(gridInfo.face_nodes_y,2).';
    end

    % ensure velocity vectors align with number of centers
    u = DU.val;
    v = DV.val;
    if numel(u) ~= numel(cx)
        u = reshape(u,1,[]);
    end
    if numel(v) ~= numel(cx)
        v = reshape(v,1,[]);
    end

    % Calculate Magnitude (Speed)
    speed = sqrt(u.^2 + v.^2);

    % =========================================================================
    % 1. MASKING STEP 
    % =========================================================================
    % Convert polygon KMLs to plotting coordinates and mask using cell centers
    % Ensure cx, cy are column vectors for inpolygon usage
    cx_flat = cx(:);
    cy_flat = cy(:);
    speed = speed(:);
    u = u(:);
    v = v(:);
    % If residuals variable exists use it, otherwise create placeholder
    if ~exist('residuals','var') || isempty(residuals)
        residuals = speed; % fallback so later code can reference residuals
    end
    residuals = residuals(:);

    flowfield_x = cell(1,length(KML));
    flowfield_y = cell(1,length(KML));
    for ki = 1:length(KML)
        % convertCoordinates expects lon,lat in columns 1 and 2
        [flowfield_x{ki}, flowfield_y{ki}] = convertCoordinates( ...
            KML{ki}(:,1), KML{ki}(:,2), 'CS2.code', 28992, 'CS1.code', 4326);

        xpoly = flowfield_x{ki};
        ypoly = flowfield_y{ki};

        % use cell centers (cx_flat,cy_flat) rather than undefined X,Y
        inside = inpolygon(cx_flat, cy_flat, xpoly, ypoly);

        % apply mask
        speed(~inside) = NaN;
        u(~inside)     = NaN;
        v(~inside)     = NaN;
        residuals(~inside) = NaN;
    end

    % keep cx_flat/cy_flat for later quiver/interpolation steps
    cx_flat = cx_flat;
    cy_flat = cy_flat;

    % =========================================================================
    % 2. PLOT RESIDUALS (Background Color)
    % =========================================================================
    if size(gridInfo.face_nodes_x, 1) == 4
        % Flatten the masked speed vector to match face dimensions
        patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
    else
        patch(gridInfo.face_nodes_x', gridInfo.face_nodes_y', speed(:)', ...
              'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', ax);
    end

    % =========================================================================
    % 3. ARROWS FOR DIRECTION (Quiver Vectors)
    % =========================================================================
    xl = xlim(ax);
    yl = ylim(ax);
    
    % 2. Create a regular spatial grid with spacing
    [x0, y0] = meshgrid(xl(1):120:xl(2), yl(1):120:yl(2));
    
    % 3. Filter using the freshly cleaned, NaN-masked arrays
    isValid = isfinite(cx_flat) & isfinite(cy_flat) & isfinite(u) & isfinite(v);
    
    cx_valid = cx_flat(isValid);
    cy_valid = cy_flat(isValid);
    u_valid  = u(isValid);
    v_valid  = v(isValid);
    
    % 4. Interpolate ONLY if valid inside data exists
    if ~isempty(cx_valid)
        Fu = scatteredInterpolant(cx_valid(:), cy_valid(:), u_valid(:), 'linear', 'none');
        Fv = scatteredInterpolant(cx_valid(:), cy_valid(:), v_valid(:), 'linear', 'none');
        
        u_grid = Fu(x0, y0);
        v_grid = Fv(x0, y0);
        
        % 5. Normalize the grid vectors to unit length
        grid_speed = hypot(u_grid, v_grid);
        zeroMask = (grid_speed == 0);
        grid_speed(zeroMask) = 1; 
        
        u_norm = u_grid ./ grid_speed;
        v_norm = v_grid ./ grid_speed;
        
        % 6. Define a fixed arrow length in meters
        arrow_length_meters = 90;
        dx = u_norm * arrow_length_meters;
        dy = v_norm * arrow_length_meters;
        
        % -----------------------------------------------------------------
        % Mask using the KML again fr quiver
        % -----------------------------------------------------------------
        in_arrow_zone = false(size(x0));
        for ki = 1:length(KML)
            % Use the already converted coordinates from Step 1
            xpoly = flowfield_x{ki};
            ypoly = flowfield_y{ki};
            
            % Check which meshgrid arrow origins fall strictly within the polygon
            inside_grid = inpolygon(x0, y0, xpoly, ypoly);
            in_arrow_zone = in_arrow_zone | inside_grid;
        end
        
        % Combine finite data matching with the strict KML polygon check
        valid_arrows = isfinite(u_grid) & isfinite(v_grid) & (grid_speed > 0) & in_arrow_zone;
        
        % 8. Plot the uniform-length quiver arrows (autoscale off)
        quiver(ax, x0(valid_arrows), y0(valid_arrows), dx(valid_arrows), dy(valid_arrows), ...
               0, 'k', 'LineWidth', 2, 'MaxHeadSize', 2);
    end
   
    % ---plot strekdammen + aangepast---
    hPol = gobjects(2,1);
    hLine2 = gobjects(1,1);

    for ki = 1:numel(Nieuw_x)
        if (k==2 || k==3) && ~isempty(Nieuw_x{ki})
            hPol(end+1) = plot(Nieuw_x{ki}, Nieuw_y{ki}, 'k-', 'LineWidth', 4);
        end
    end
    hPol(3)  = plot(nan, nan, 'k-', 'LineWidth', 4);

    for ki = 1:numel(Aangepast_x)
        if ~isempty(Aangepast_x{ki})
            hLine1 = plot(Aangepast_x{ki}, Aangepast_y{ki}, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 4); 
        end
    end
    % define handle placeholder for Aangepast (do not plot)
    hPol(1) = plot(nan, nan, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 3);

    for ki = 1:numel(Bestaand_x)
        if ~isempty(Bestaand_x{ki})
            hLine2 = plot(Bestaand_x{ki}, Bestaand_y{ki}, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 4); 
        end
    end
    % ensure hLine2 is a valid graphics object before assignment
    if isempty(hLine2) || ~isgraphics(hLine2)
        hLine2 = plot(nan, nan, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 4);
        set(hLine2, 'Visible', 'off');
    end
    hPol(2) = hLine2;

    % % ========= Map uniform 50m quiver arrows (Uniform Length) =========
    % % 1. Get the current axis limits to grid only the visible viewport
    % xl = xlim(ax);
    % yl = ylim(ax);
    % 
    % % 2. Create a regular grid with exactly 20-meter spacing (more points -> denser arrows)
    % [x0, y0] = meshgrid(xl(1):400:xl(2), yl(1):400:yl(2));
    % 
    % % 3. Use run-local copies of cell centers and velocities (from this run)
    % cx_run = cx(:);
    % cy_run = cy(:);
    % u_run  = u(:);
    % v_run  = v(:);
    % 
    % % 4. Filter out any NaN or Inf coordinates and velocities
    % isValid = isfinite(cx_run) & isfinite(cy_run) & isfinite(u_run) & isfinite(v_run);
    % cx_valid = cx_run(isValid);
    % cy_valid = cy_run(isValid);
    % u_valid  = u_run(isValid);
    % v_valid  = v_run(isValid);
    % 
    % % 5. Interpolant using only finite data points
    % if ~isempty(cx_valid)
    %     % create scattered interpolants for u and v
    %     Fu = scatteredInterpolant(cx_valid, cy_valid, u_valid, 'linear', 'none');
    %     Fv = scatteredInterpolant(cx_valid, cy_valid, v_valid, 'linear', 'none');
    % 
    %     u_grid = Fu(x0, y0);
    %     v_grid = Fv(x0, y0);
    % 
    %     % 6. Normalize the grid vectors to unit length (guard against zeros)
    %     grid_speed = hypot(u_grid, v_grid);
    %     nonzero = grid_speed > 0;
    %     u_norm = zeros(size(u_grid));
    %     v_norm = zeros(size(v_grid));
    %     u_norm(nonzero) = u_grid(nonzero) ./ grid_speed(nonzero);
    %     v_norm(nonzero) = v_grid(nonzero) ./ grid_speed(nonzero);
    % 
    %     % 7. Define a fixed arrow length in meters (e.g., 15 meters long)
    %     arrow_length_meters = 150;
    % 
    %     dx = u_norm * arrow_length_meters;
    %     dy = v_norm * arrow_length_meters;
    % 
    %     % 8. Plot the uniform-length quiver arrows (autoscale off)
    %     quiver(ax, x0, y0, dx, dy, 0, 'k', 'LineWidth', 1.5, 'MaxHeadSize', 1.5);
    % end

    %Bath
    xlim(ax, [69850 72800]);
    ylim(ax, [378850 380500]);

    %Zimm
    % xlim(ax, [64200 67700]);
    % ylim(ax, [379000 380900]);
    hold(ax, 'off');

    % set axis labels with y-ticks displayed in kilometers (divide by 1000)
    hx = get(ax,'XLabel');
    hy = get(ax,'YLabel');
    set(hx, 'String', 'RDx [km]', 'FontSize', 24, 'FontWeight', 'bold');
    set(hy, 'String', 'RDy [km]', 'FontSize', 24, 'FontWeight', 'bold');

    % set x-ticks at multiples of 1.0 km and y-ticks at multiples of 0.5 km,
    xl = xlim(ax); yl = ylim(ax);
    % convert limits to kilometers, compute tick vectors, then convert back to meters
    xk_min = floor(xl(1)/1000); xk_max = ceil(xl(2)/1000);
    yk_min = floor(yl(1)/1000); yk_max = ceil(yl(2)/1000);
    xk = (xk_min : 1.0 : xk_max);            % ticks every 1.0 km
    yk = (yk_min : 1.0 : yk_max);            % ticks every 0.5 km
    set(ax, 'XTick', xk*1000, 'YTick', yk*1000, 'FontSize', 22);

    % tick label strings in km
    xLabels = arrayfun(@(v) sprintf('%.0f', v), xk, 'UniformOutput', false);
    yLabels = arrayfun(@(v) sprintf('%.0f', v), yk, 'UniformOutput', false);
    % only label y axis for specific tiles and apply axis label visibility similarly
    if ismember(k, [1, 3])
        yTickLabels = yLabels;
        % show YLabel only on these tiles
        set(get(ax,'YLabel'),'Visible','on');
    else
        yTickLabels = repmat({''}, size(yLabels));
        set(get(ax,'YLabel'),'Visible','off');
    end
    if ismember(k, [2, 3])
        xTickLabels = xLabels;
        % show XLabel only on these tiles
        set(get(ax,'XLabel'),'Visible','on');
    else
        xTickLabels = repmat({''}, size(xLabels));
        set(get(ax,'XLabel'),'Visible','off');
    end

    set(ax, 'XTickLabel', xTickLabels, 'YTickLabel', yTickLabels);
 
    % color map and colorbar
    colormap(ax, jet);
    clim = [0 0.2];
    caxis(ax, clim);

    % big title: Residual Velocity over entire figure
    if k == 1
        fig = ancestor(ax, 'figure');
        overallTimeStr = 'Residual Velocity';
        % remove any existing matching annotation to avoid duplicate titles
        anns = findall(fig, 'Type', 'annotation', '-and', 'String', overallTimeStr);
        delete(anns);
        % create a centered suptitle-like textbox slightly lower to avoid being
        % cut off at the top of the page when printing/exporting
        topPos = 0.955;           % lowered from 0.975 to avoid clipping
        height = 0.03;
        annotation(fig, 'textbox', [0, topPos, 1, height], 'String', overallTimeStr, ...
                   'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                   'FontWeight', 'bold', 'FontSize', 34, 'EdgeColor', 'none', 'Interpreter', 'none');
    
    end 

     % set title
    title(ax, name{k}, 'FontSize', 34, 'FontWeight', 'bold', 'Interpreter', 'none');
end

if k == 3
    % use the dedicated legend/blank tile (tile 4) for colorbar to control appearance
    axCB = nexttile(4);
    % ensure the axis is visible temporarily so colorbar attaches correctly
    wasHidden = strcmp(get(axCB, 'Visible'), 'off');
    if wasHidden
        set(axCB, 'Visible', 'on');
    end
    % apply colormap to that axes and create a widened colorbar on the west side
    colormap(axCB, jet);
    cb = colorbar(axCB, 'west');
    drawnow; % ensure positions are up to date
    axPos = get(axCB, 'Position');      % [left bottom width height]
    cbPos = get(cb, 'Position');        % [left bottom width height]
    extraWidth = 0.02; % increase width by 2% of figure width (tweakable)
    cbPos(1) = max(0, cbPos(1) - extraWidth); % shift left if possible
    cbPos(3) = cbPos(3) + extraWidth;         % increase width
    set(cb, 'Position', cbPos);

    cb.Label.String = 'Residual Velocity [m/s]';
    cb.Limits = [0 0.2];           % fixed color limits requested
    caxis(axCB, cb.Limits);        % enforce same limits for mapping
    cb.FontSize = 25;
    cb.Label.FontSize = 20;
    cb.Label.FontWeight = 'bold';
    cb.Box = 'off';
    set(axCB, 'Colormap', jet);
    % restore axis visibility if it was hidden before
    if wasHidden
        set(axCB, 'Visible', 'off');
    end
end

% =========================================================================
% 4. LEGEND & REFERENCE ARROW MANAGEMENT (Target Tile 4)
% =========================================================================
axTarget = nexttile(4); 
hold(axTarget, 'on');

legHandles = [];
legLabels = {};

% 1. Verify if hPol exists in the workspace from the loop iterations
if exist('hPol','var')
    if numel(hPol) >= 1 && isgraphics(hPol(1))
        legHandles(end+1) = hPol(1); 
        legLabels{end+1} = 'Channel Wall'; 
    end
    if numel(hPol) >= 2 && isgraphics(hPol(2))
        legHandles(end+1) = hPol(2); 
        legLabels{end+1} = 'Existing Groynes'; 
    end
    if numel(hPol) >= 3 && isgraphics(hPol(3))
        legHandles(end+1) = hPol(3); 
        legLabels{end+1} = 'New Groynes'; 
    end
end

% 2. Create a dummy quiver arrow
xref = 0; yref = 0; refU = 1; refV = 0;

hRef = quiver(axTarget, xref, yref, refU, refV, 0, 'k', ...
    'LineWidth', 3, 'MaxHeadSize', 2);

% --- THE KEY TRICK ---
hRef.Annotation.LegendInformation.IconDisplayStyle = 'on'; 
% restrict the axis limits elsewhere so the physical arrow is pushed off-screen
xlim(axTarget, [10 20]); 
ylim(axTarget, [10 20]);

legHandles(end+1) = hRef;
legLabels{end+1}  = 'Flow Direction';
axis(axTarget, 'off'); 

% 4. Generate the legend sitting cleanly on the blank tile
if ~isempty(legHandles)
    legend(axTarget, legHandles, legLabels, 'Location', 'east', 'FontSize', 24);
end

% %% --- export----
% outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\Comparisons';
% if ~exist(outDir, 'dir')
%     warning('Output directory does not exist: %s\nAttempting to create it.', outDir);
%     mkdir(outDir);
% end
% fig = gcf;
% filename = fullfile(outDir, 'residuals_bath');
% print(fig, [filename, '.png'], '-dpng', '-r300');

% %% export
% outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\viscosity\residuals';
% if ~exist(outDir, 'dir')
%     warning('Output directory does not exist: %s\nAttempting to create it.', outDir);
%     mkdir(outDir);
% end
% fig = gcf;
% filename = fullfile(outDir, 'residual_vel_arrow_bath');
% % save as FIG and PNG for convenience, use high resolution for PNG
% % savefig(fig, [filename, '.fig']);
% print(fig, [filename, '.png'], '-dpng', '-r300');

% %% plotting
% % Plot depth-averaged velocities
% figure;
% hold on;
% % compute cell centers from the 4 face node coordinates (assumes NaN-free quads)
% % gridInfo.face_nodes_x and .face_nodes_y are (4 x nCells) or (nCells x 4)
% if size(gridInfo.face_nodes_x,1) == 4
%     cx = mean(gridInfo.face_nodes_x,1);
%     cy = mean(gridInfo.face_nodes_y,1);
% else
%     cx = mean(gridInfo.face_nodes_x,2).';
%     cy = mean(gridInfo.face_nodes_y,2).';
% end
% 
% % ensure velocity vectors align with number of centers
% u = DataU_da.val;
% v = DataV_da.val;
% if numel(u) ~= numel(cx)
%     u = reshape(u,1,[]);
% end
% if numel(v) ~= numel(cx)
%     v = reshape(v,1,[]);
% end
% 
% % 2. Calculate Magnitude (Speed)
% speed = sqrt(u.^2 + v.^2);
% 
% size(gridInfo.face_nodes_x, 1) == 4
%     % This draws every cell as a filled polygon
%     p = patch(gridInfo.face_nodes_x, gridInfo.face_nodes_y, speed(:)', ...
%               'EdgeColor', 'none', 'FaceColor', 'flat');
% 
% colormap(jet);
% cb = colorbar;
% ylabel(cb, 'Residual Speed (m/s)');
% % caxis([0 0.4]); % Or use [nanmin(speed) nanmax(speed)]
% 
% % % set minimum spacing (meters) between plotted vectors
% % minDist = 20; % adjust as needed
% % nCells = numel(cx);
% % pts = [cx(:), cy(:)];
% % selected = false(nCells,1);
% % 
% % % To speed up, shuffle order so selection is spatially uniform (optional)
% % order = 1:nCells;
% % 
% % % use a simple grid-based acceleration: bin points into cells of size minDist
% % bx = floor((cx - min(cx)) / minDist);
% % by = floor((cy - min(cy)) / minDist);
% % bins = containers.Map('KeyType','char','ValueType','any');
% % 
% % for i = order
% %     key = sprintf('%d_%d', bx(i), by(i));
% %     if ~isKey(bins, key)
% %         bins(key) = i; % keep first in bin
% %         selected(i) = true;
% %     else
% %         % candidate: ensure it's not too close to the stored one(s) in this bin
% %         keep = true;
% %         neighbors = bins(key);
% %         for j = neighbors
% %             if hypot(cx(i)-cx(j), cy(i)-cy(j)) < minDist
% %                 keep = false;
% %                 break;
% %             end
% %         end
% %         if keep
% %             bins(key) = [neighbors, i]; %#ok<AGROW>
% %             selected(i) = true;
% %         end
% %     end
% % end
% % 
% % idx = find(selected);
% 
% % plot thinned quiver with autoscale for visibility
% % quiver(cx(idx), cy(idx), u(idx), v(idx), 1, 'k');
% xlabel('X Coordinate');
% ylabel('Y Coordinate');
% title('Depth-Averaged Velocity Field');
% grid on;
% xlim([63600 72900]);
% ylim([378800 380800]);
% 
% hold off;

