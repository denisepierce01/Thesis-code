close all
clear all
clc

% %% create polygon and two lines
% % Define polygon corners (hard-coded provided values)
% % c2 = [72440, 380440];
% % c1 = [72280, 379720]; %0903 XS Bath
% c3 = [69620, 379500];
% c4 = [70076, 378675]; % 0101 XS Bath
% 
% c1 = [71798.74689713161, 379790.33241622517];
% c2 = [71654.31368231568, 380383.4113045631]; %0703 Bath
% 
% 
% % % Polygon (ensure closed)
% % polyXY = [c1; c2; c3; c4; c1];
% % xv = polyXY(:,1);
% % yv = polyXY(:,2);
% % if ~(polyXY(1,1) == polyXY(end,1) && polyXY(1,2) == polyXY(end,2))
% %     polyXY(end+1,:) = polyXY(1,:); %#ok<AGROW>
% % end
% % poly_closed = polyXY;
% 
% % Create two line segments: line1 from c1 to c2, line2 from c3 to c4
% line1 = [c1; c2]; % 2x2 matrix: [x y; x y]
% line2 = [c3; c4];
% 
% %% import tif aerial and visualize polygon
% % % Import the specified GeoTIFF and display it with mapshow (or imshow if mapshow unavailable)
% % tifpath = 'p:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Aerial_pictures\aerial_collage\2024_072000_Bath4.tif';
% % [A_tif, R_tif] = readgeoraster(tifpath);
% 
% % % Overlay polygon on GeoTIFF
% % figure();
% % mapshow(A_tif, R_tif); 
% % hold on;
% % Plot polygon corners (optional) and the two line segments on top of the GeoTIFF
% % Plot polygon outline in yellow
% % polyXY = [c1; c2; c3; c4; c1];
% % plot(polyXY(:,1), polyXY(:,2), 'y-', 'LineWidth', 2);
% 
% % Plot the two line segments in distinct colors and mark endpoints
% plot(line1(:,1), line1(:,2), 'r-', 'LineWidth', 2);
% % plot(line2(:,1), line2(:,2), 'b-', 'LineWidth', 2);
% plot(line1(:,1), line1(:,2), 'ro', 'MarkerFaceColor','r');
% % plot(line2(:,1), line2(:,2), 'bo', 'MarkerFaceColor','b');
% title('Aerial with box of interest');
% hold off;
% 
% %% import corresponding jgp
% % import corresponding jpg (aerial)
% aerial_gis = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Aerial_pictures\XS\0703.jpg';
% % Display the aerial_gis image and overlay the two line segments
% I = imread(aerial_gis);
% 
% figure();
% imshow(I);
% 
% 
% %% import tiff
% folders = {'P:/11212794-westerschelde-2026/data/01_bathymetry/arc/ga2017/'};
% %% import based on line1 and line2
% % Loop over all folders and all .tif files, read a window covering the
% % bounding box of the two line segments (line1 and line2) only.
% files_all = [];
% for f = 1:numel(folders)
%     files = dir(fullfile(folders{f}, 'ga2017.tif'));
% %     %% import tiff
% % folders = {'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\'};
% % %% import based on line1 and line2
% % % Loop over all folders and all .tif files, read a window covering the
% % % bounding box of the two line segments (line1 and line2) only.
% % files_all = [];
% % for f = 1:numel(folders)
% %     files = dir(fullfile(folders{f}, '2017_dtm_2.tif'));
%     for k = 1:numel(files)
%         files_all(end+1).folder = files(k).folder; %#ok<SAGROW>
%         files_all(end).name = files(k).name;
%     end
% end
% 
% nFiles = numel(files_all);
% A_sub_all = cell(nFiles,1);
% R_sub_all = cell(nFiles,1);
% file_paths = cell(nFiles,1);
% 
% % define bounding box from the two lines' endpoints
% allX = [line1(:,1); line2(:,1)];
% allY = [line1(:,2); line2(:,2)];
% xMin = min(allX); xMax = max(allX);
% yMin = min(allY); yMax = max(allY);
% 
% for idx = 1:nFiles
%     fname = fullfile(files_all(idx).folder, files_all(idx).name);
%     file_paths{idx} = fname;
%     try
%         [A, R] = readgeoraster(fname);
%     catch
%         try
%             A = imread(fname);
%             info = imfinfo(fname);
%             if isfield(info(1), 'GeoTIFFTags') && ~isempty(info(1).GeoTIFFTags)
%                 % best-effort construct referencing not implemented; fall back
%                 R = georasterref('RasterSize', size(A(:,:,1)), ...
%                     'XWorldLimits', [], 'YWorldLimits', []); %#ok<NASGU>
%             else
%                 R = georasterref('RasterSize', size(A(:,:,1)), ...
%                     'XWorldLimits', [0 size(A,2)], 'YWorldLimits', [0 size(A,1)]);
%             end
%         catch
%             A_sub_all{idx} = [];
%             R_sub_all{idx} = [];
%             continue
%         end
%     end
% 
%     % Quick reject: if raster does not overlap bounding box, skip
%     try
%         xlimR = R.XWorldLimits;
%         ylimR = R.YWorldLimits;
%         if xMax < min(xlimR) || xMin > max(xlimR) || yMax < min(ylimR) || yMin > max(ylimR)
%             A_sub_all{idx} = [];
%             R_sub_all{idx} = [];
%             continue
%         end
%     catch
%         % if referencing info not available, attempt to proceed
%     end
% 
%     % Map bounding box to intrinsic pixel coordinates
%     try
%         [cols, rows] = worldToIntrinsic(R, [xMin, xMax], [yMin, yMax]);
%         cmin = max(1, floor(min(cols)));
%         cmax = min(size(A,2), ceil(max(cols)));
%         rmin = max(1, floor(min(rows)));
%         rmax = min(size(A,1), ceil(max(rows)));
%     catch
%         % fallback to entire image if mapping fails
%         cmin = 1; cmax = size(A,2);
%         rmin = 1; rmax = size(A,1);
%     end
% 
%     % read just that region if possible
%     try
%         Z = readgeoraster(fname, 'PixelRegion', {[rmin rmax], [cmin cmax]});
%     catch
%         Z = A(rmin:rmax, cmin:cmax, :);
%     end
% 
%     % store cropped array and updated referencing
%     A_sub_all{idx} = Z;
%     R_sub = R;
%     R_sub.RasterSize = [size(Z,1), size(Z,2)];
%     % compute accurate world limits for the cropped region if possible
%     try
%         [x_edge1, y_edge1] = intrinsicToWorld(R, cmin, rmin);
%         [x_edge2, y_edge2] = intrinsicToWorld(R, cmax, rmax);
%         R_sub.XWorldLimits = [min(x_edge1,x_edge2), max(x_edge1,x_edge2)];
%         R_sub.YWorldLimits = [min(y_edge1,y_edge2), max(y_edge1,y_edge2)];
%     catch
%         % leave R_sub as-is if conversion fails
%     end
% 
%     % Additionally, create a mask for the bounding-box region (optionally refined later)
%     try
%         [nR, nC, ~] = size(Z);
%         cols_grid = (cmin:cmax);
%         rows_grid = (rmin:rmax);
%         [xv, yv] = intrinsicToWorld(R, cols_grid, rows_grid);
%         [Xg, Yg] = meshgrid(xv, yv);
%         % mask pixels inside the convex hull of the two line segments (thin region)
%         % Use polygon defined by endpoints in order: line1 endpoints then reversed line2 endpoints
%         polyX = [line1(1,1), line1(2,1), line2(2,1), line2(1,1)];
%         polyY = [line1(1,2), line1(2,2), line2(2,2), line2(1,2)];
%         mask = inpolygon(Xg, Yg, polyX, polyY);
%         R_sub.PolygonMask = mask;
%     catch
%         % do nothing on failure
%     end
% 
%     R_sub_all{idx} = R_sub;
% end
% 
% % Warn if expected number differs (retain behavior)
% if nFiles ~= 20
%     warning('Found %d TIFF files; expected 20. Proceeding with found files.', nFiles);
% end
% 
% %% extract transects from A_sub_all based on RDx RDy from transects
% % For each cropped raster, sample LIDAR elevations along the two line segments.
% % extract LIDAR values for line1 and line2
% % Preallocate cell arrays to hold values for each file: {file}{1 or 2}
% LIDAR_vals = cell(nFiles,1);
% 
% % For each cropped raster, sample elevations along the two line segments.
% for idx = 1:nFiles
%     Z = A_sub_all{idx};
%     Rsub = R_sub_all{idx};
%     if isempty(Z) || isempty(Rsub)
%         LIDAR_vals{idx} = {[],[]};
%         continue
%     end
% 
%     % Ensure Z is single-band numeric (if RGB, convert to grayscale or take first band)
%     if ndims(Z) == 3
%         Zg = double(Z(:,:,1));
%     else
%         Zg = double(Z);
%     end
% 
%     % Prepare function to sample along a line: world coords -> intrinsic -> bilinear interp
%     sampleLine = @(lineXY) sample_along_line(lineXY, Rsub, Zg);
% 
%     try
%         vals1 = sampleLine(line1)/100; %cm to meters
%         vals2 = sampleLine(line2)/100; %cm to meters;
%     catch
%         vals1 = [];
%         vals2 = [];
%     end
% 
%     LIDAR_vals{idx} = {vals1, vals2};
% end
% 
% % Helper local function: returns column vector of sampled values along provided Nx2 world coords
% function vals = sample_along_line(lineXY, Rref, Zimg)
%     % lineXY: Nx2 [X Y] in world coordinates (may be just two endpoints or many points)
%     % Rref: spatial referencing for the cropped image (must support worldToIntrinsic/intrinsicToWorld)
%     % Zimg: numeric array of raster values
%     % Create dense sampling along the polyline at 1-pixel intrinsic spacing approximate
%     % Convert line endpoints to intrinsic coordinates (cols, rows)
%     [cols_world, rows_world] = worldToIntrinsic(Rref, lineXY(:,1), lineXY(:,2));
%     % worldToIntrinsic can return vectors for each point:
%     cols = cols_world;
%     rows = rows_world;
% 
%     % If only two points provided, generate intermediate points by distance in intrinsic space
%     if numel(cols) == 2
%         % compute Euclidean distance in intrinsic coords
%         d = hypot(diff(cols), diff(rows));
%         if d < 1
%             nPts = 2;
%         else
%             nPts = max(2, ceil(d)+1);
%         end
%         t = linspace(0,1,nPts)';
%         cols = cols(1) + (cols(2)-cols(1))*t;
%         rows = rows(1) + (rows(2)-rows(1))*t;
%     else
%         % If more than two vertices, interpolate along polyline to have roughly 1-pixel spacing
%         % compute cumulative distances
%         dc = hypot(diff(cols), diff(rows));
%         cumd = [0; cumsum(dc)];
%         if cumd(end) < 1
%             cols = cols(:);
%             rows = rows(:);
%         else
%             nPts = max(2, ceil(cumd(end))+1);
%             tq = linspace(0, cumd(end), nPts);
%             cols = interp1(cumd, cols, tq, 'linear')';
%             rows = interp1(cumd, rows, tq, 'linear')';
%         end
%     end
% 
%     % Bilinear interpolation of Zimg at (cols, rows). interp2 expects X = columns, Y = rows
%     [nR, nC] = size(Zimg);
%     Cq = cols(:);
%     Rq = rows(:);
% 
%     % clamp query points slightly to valid range to avoid NaNs at edges
%     Cq = min(max(Cq, 1), nC);
%     Rq = min(max(Rq, 1), nR);
% 
%     % Use interp2 with default linear interpolation
%     [Cgrid, Rgrid] = meshgrid(1:nC, 1:nR); %#ok<NASGU>
%     vals = interp2(Cgrid, Rgrid, Zimg, Cq, Rq, 'linear');
% 
%     % For any NaNs (e.g., outside), try nearest neighbor fallback
%     nanIdx = isnan(vals);
%     if any(nanIdx)
%         vals(nanIdx) = interp2(Cgrid, Rgrid, Zimg, Cq(nanIdx), Rq(nanIdx), 'nearest');
%     end
% 
%     vals = vals(:);
% end
% 
% 
% %% plotting XS
% % Plot cross-section: x-distance along transect vs values from line1 for each file
% figure;
% hold on;
% colors = lines(nFiles);
% legendEntries = cell(nFiles,1);
% 
% for idx = 1:nFiles
%     valsPair = LIDAR_vals{idx};
%     vals1 = valsPair{1};
%     if isempty(vals1)
%         continue
%     end
% 
%     % compute cumulative distance along sampled intrinsic points to use as x-axis
%     % Need intrinsic coordinates corresponding to samples: reuse sampling function logic to get cols/rows
%     try
%         [cols_world, rows_world] = worldToIntrinsic(R_sub_all{idx}, line1(:,1), line1(:,2)); %#ok<ASGLU>
%         cols = cols_world; rows = rows_world;
%         if numel(cols) == 2
%             d = hypot(diff(cols), diff(rows));
%             if d < 1
%                 nPts = 2;
%             else
%                 nPts = max(2, ceil(d)+1);
%             end
%             t = linspace(0,1,nPts)';
%             cols = cols(1) + (cols(2)-cols(1))*t;
%             rows = rows(1) + (rows(2)-rows(1))*t;
%         else
%             dc = hypot(diff(cols), diff(rows));
%             cumd = [0; cumsum(dc)];
%             if cumd(end) < 1
%                 cols = cols(:); rows = rows(:);
%             else
%                 nPts = max(2, ceil(cumd(end))+1);
%                 tq = linspace(0, cumd(end), nPts);
%                 cols = interp1(cumd, cols, tq, 'linear')';
%                 rows = interp1(cumd, rows, tq, 'linear')';
%             end
%         end
%         % cumulative distance in world units approximated by intrinsic spacing
%         diffs = hypot(diff(cols), diff(rows));
%         xdist = [0; cumsum(diffs)];
%         % ensure xdist length matches vals1
%         if numel(xdist) ~= numel(vals1)
%             xdist = linspace(0, xdist(end), numel(vals1))';
%         end
%     catch
%         xdist = (1:numel(vals1))';
%     end
% 
%     plot(xdist*20, vals1, '-', 'Color', colors(mod(idx-1,size(colors,1))+1,:), 'LineWidth', 1.2, 'HandleVisibility', 'off');
%     % plot circles (markers as unfilled circles) at specified points
%     % Use plot with 'o' marker and specify marker size and edge color
%     plot(333.9, 1.043, 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'DisplayName', '0903');
%     plot(599, -1.165, 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'DisplayName', '0902');
%     legend('show');
%     % legendEntries{idx} = sprintf('File %d', idx);
% end
% 
% xlabel('Distance (m)');
% ylabel('Elevation NAP (m)');
% title('Cross Section');
% % legend(nonzeros(double(~cellfun(@isempty, LIDAR_vals))).*0 + {legendEntries{:}}, 'Interpreter', 'none');
% hold off;

%% velocity data
load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')

%% ADCP Observations
% Load  data 
siteFields = fieldnames(ADCP.BATH.T0);
% Exclude non-station fields if any (assume station fields contain 'MP' or similar)
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
% create a title-friendly version of station names by removing any occurrence of 'MP'
stationNames_title = regexprep(stationNames, 'MP', '');
nStations = length(stationNames);

% Preallocate cell arrays to hold time, magnitude and direction for each station
time0 = cell(size(stationNames));
vel0_da = cell(size(stationNames));
dir0_da = cell(size(stationNames));

% Initialize time1, vel1_da, dir1_da in case missing
time1 = cell(size(stationNames));
vel1_da = cell(size(stationNames));
dir1_da = cell(size(stationNames));

for k = 1:nStations
    s = stationNames{k};
    % Safely access fields; if a field or subfield is missing, set empty
    if isfield(ADCP.BATH.T0, s) && ...
       isfield(ADCP.BATH.T0.(s), 't_CET') && ...
       isfield(ADCP.BATH.T0.(s), 'Umag_da') && ...
       isfield(ADCP.BATH.T0.(s), 'Udir_da')
        % Read all available columns
        time0{k} = ADCP.BATH.T0.(s).t_CET;
        vel0_da{k} = ADCP.BATH.T0.(s).Umag_da;
        dir0_da{k} = ADCP.BATH.T0.(s).Udir_da;
        % Apply sign convention: directions 0-180 => positive, 180-360 => negative
        if ~isempty(dir0_da{k}) && ~isempty(vel0_da{k})
            % Ensure vectors same length; operate elementwise
            n0 = min(numel(dir0_da{k}), numel(vel0_da{k}));
            dirs = dir0_da{k}(:);
            vels = vel0_da{k}(:);
            % Truncate if lengths differ
            dirs = dirs(1:n0);
            vels = vels(1:n0);
            signFactor = ones(n0,1);
             % Directions in [165,345) are considered negative flow BATH
            signFactor(dirs >= 180 & dirs < 360) = -1;
            % % Directions in [165,345) are considered negative flow BATH
            % signFactor(dirs >= 165 & dirs < 345) = -1;
             % Directions in [200,20) are considered negative flow Bath
            % signFactor(dirs >= 200 & dirs < 20) = -1;
            vel0_da{k} = (vels .* signFactor);
            % If original arrays were longer, preserve remaining values as-is
            if numel(ADCP.BATH.T0.(s).Umag_da) > n0
                vel0_da{k} = [vel0_da{k}; ADCP.BATH.T0.(s).Umag_da(n0+1:end)];
            end
        end
    else
        time0{k} = [];
        vel0_da{k} = [];
        dir0_da{k} = [];
    end
end

% Process T1 stations (safely) - read all columns
for k = 1:numel(stationNames)
    s = stationNames{k};
    if isfield(ADCP.BATH.T1, s) && ...
       isfield(ADCP.BATH.T1.(s), 't_CET') && ...
       isfield(ADCP.BATH.T1.(s), 'Umag_da') && ...
       isfield(ADCP.BATH.T1.(s), 'Udir_da')
        time1{k} = ADCP.BATH.T1.(s).t_CET;
        vel1_da{k} = ADCP.BATH.T1.(s).Umag_da;
        dir1_da{k} = ADCP.BATH.T1.(s).Udir_da;
        % Apply sign convention: directions 0-180 => positive, 180-360 => negative
        if ~isempty(dir1_da{k}) && ~isempty(vel1_da{k})
            n1 = min(numel(dir1_da{k}), numel(vel1_da{k}));
            dirs = dir1_da{k}(:);
            vels = vel1_da{k}(:);
            dirs = dirs(1:n1);
            vels = vels(1:n1);
            signFactor = ones(n1,1);
            signFactor(dirs >= 180 & dirs < 360) = -1;
            vel1_da{k} = (vels .* signFactor);
            if numel(ADCP.BATH.T1.(s).Umag_da) > n1
                vel1_da{k} = [vel1_da{k}; ADCP.BATH.T1.(s).Umag_da(n1+1:end)];
            end
        end
    else
        time1{k} = [];
        vel1_da{k} = [];
        dir1_da{k} = [];
    end
end

%% water level Bath
WL_Bath =  ADCP.BATH.T0.MP0702.WL_from_external_source;
WL_Bath_time = ADCP.BATH.T0.MP0702.t_CET;
WL_Bath1 =  ADCP.BATH.T1.MP0103.WL_from_external_source; %phase 1
WL_Bath_time1 = ADCP.BATH.T1.MP0103.t_CET;
WL_Bath2 =  ADCP.BATH.T1.MP0703.WL_from_external_source; %phase 2
WL_Bath_time2 = ADCP.BATH.T1.MP0703.t_CET;
% Collect WL_Bath and WL_Bath_time for all stations for T0 and T1

%% collect WL per station for T0 and T1
% Initialize as cell arrays sized to stationNames
nStations = numel(stationNames);
WL_Bath = []; WL_Bath_time = [];
WL_Bath_cell = repmat({[]}, 1, nStations);
WL_Bath_time_cell = repmat({[]}, 1, nStations);
WL_Bath1 = repmat({[]}, 1, nStations);
WL_Bath_time1 = repmat({[]}, 1, nStations);

for k = 1:nStations
    s = stationNames{k};
    % T0
    if isfield(ADCP.BATH, 'T0') && isfield(ADCP.BATH.T0, s) ...
            && isfield(ADCP.BATH.T0.(s), 'WL_from_external_source') ...
            && isfield(ADCP.BATH.T0.(s), 't_CET')
        WLtmp = ADCP.BATH.T0.(s).WL_from_external_source;
        WLttmp = ADCP.BATH.T0.(s).t_CET;
        if ~isempty(WLtmp), WLtmp = WLtmp(:); end
        if ~isempty(WLttmp), WLttmp = WLttmp(:); end
        WL_Bath_cell{k} = WLtmp;
        WL_Bath_time_cell{k} = WLttmp;
        % also append to overall vectors for T0
        if ~isempty(WLtmp)
            WL_Bath = [WL_Bath; WLtmp];
        end
        if ~isempty(WLttmp)
            WL_Bath_time = [WL_Bath_time; WLttmp];
        end
    else
        WL_Bath_cell{k} = [];
        WL_Bath_time_cell{k} = [];
    end

    % T1
    if isfield(ADCP.BATH, 'T1') && isfield(ADCP.BATH.T1, s) ...
            && isfield(ADCP.BATH.T1.(s), 'WL_from_external_source') ...
            && isfield(ADCP.BATH.T1.(s), 't_CET')
        WLtmp1 = ADCP.BATH.T1.(s).WL_from_external_source;
        WLttmp1 = ADCP.BATH.T1.(s).t_CET;
        if ~isempty(WLtmp1), WLtmp1 = WLtmp1(:); end
        if ~isempty(WLttmp1), WLttmp1 = WLttmp1(:); end
        WL_Bath1{k} = WLtmp1;
        WL_Bath_time1{k} = WLttmp1;
    else
        WL_Bath1{k} = [];
        WL_Bath_time1{k} = [];
    end
end

% Provide non-cell fallback variables expected later in the script
% (keep original scalar names for compatibility)
WL_Bath = WL_Bath;            % vector concatenation for T0 (may be empty)
WL_Bath_time = WL_Bath_time;  % vector concatenation for T0 times
WL_Bath = WL_Bath_cell;       % per-station cell array for T0 (overwrite name to cells)
WL_Bath_time = WL_Bath_time_cell;

%% Plot High Water versus velocity (tiled format)
%setting up tile format
nStations = numel(stationNames);
nRows = 5;
nCols = 4;

% figure with A4 Vertical proportions
fig = figure('Name', 'High Water Velocities Tiled', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 18, 22]; % Width=18cm, Height=25cm fits well on A4

% title plot
t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');

% Global Title, X-Label, and Y-Label to the layout (t), not individual plots
title(t, 'Velocity vs Water Level: Bath', 'FontSize', 20, 'FontWeight', 'bold');
xlabel(t, 'Velocity (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 14, 'FontWeight', 'bold');

% % Title textbox above the tiled layout
% titleStr = 'Velocity vs Water Level';
% topMargin = 0.10; % fraction of figure height reserved for title
% t.Units = 'normalized';
% t.Position = [0, 0, 1, 1 - topMargin];
% annotation(fig, 'textbox', [0.05, 1 - topMargin + 0.01, 0.9, topMargin - 0.02], ...
%     'String', titleStr, ...
%     'HorizontalAlignment', 'center', ...
%     'VerticalAlignment', 'middle', ...
%     'FontSize', 16, ...
%     'FontWeight', 'bold', ...
%     'LineStyle', 'none', ...
%     'Interpreter', 'none');

% Loop stations and plot into tiles (limit to number of tiles available)
maxTiles = nRows * nCols;
nToPlot = min(nStations, maxTiles);
for k = 1:nToPlot

    % Prepare T0 data (use WL_Bath for T0)
    if exist('WL_Bath','var') && exist('WL_Bath_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        % WL_Bath and WL_Bath_time are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Bath) && numel(WL_Bath) >= k
            zWL_cell = WL_Bath{k};
            twl_cell = WL_Bath_time{k};
        else
            zWL_cell = WL_Bath;
            twl_cell = WL_Bath_time;
        end
        tWL = twl_cell(:);
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0 = vel0_da{k}(:);
        if isdatetime(tWL)
            twl_num = datenum(tWL);
        else
            twl_num = tWL;
        end
        if isdatetime(tV0)
            tv0_num = datenum(tV0);
        else
            tv0_num = tV0;
        end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
            valid0 = ~isnan(z0_at_v) & ~isnan(v0);
        else
            valid0 = false(size(v0));
            z0_at_v = NaN(size(v0));
        end
    else
        v0 = [];
        z0_at_v = [];
        valid0 = [];
    end

    % Prepare T1 data (use WL_Bath1 for T1)
    if exist('WL_Bath1','var') && exist('WL_Bath_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        % WL_Bath1 and WL_Bath_time1 are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Bath1) && numel(WL_Bath1) >= k
            zWL1_cell = WL_Bath1{k};
            twl1_cell = WL_Bath_time1{k};
        else
            zWL1_cell = WL_Bath1;
            twl1_cell = WL_Bath_time1;
        end
        tWL1 = twl1_cell(:);
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1 = vel1_da{k}(:);
        if isdatetime(tWL1)
            twl1_num = datenum(tWL1);
        else
            twl1_num = tWL1;
        end
        if isdatetime(tV1)
            tv1_num = datenum(tV1);
        else
            tv1_num = tV1;
        end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
            valid1 = ~isnan(z1_at_v) & ~isnan(v1);
        else
            valid1 = false(size(v1));
            z1_at_v = NaN(size(v1));
        end
    else
        v1 = [];
        z1_at_v = [];
        valid1 = [];
    end

    % ===PLOTTING===
    nexttile;
    hold on;
    y_line = [-4 4.5];
    plot([0 0], y_line, 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5, 'HandleVisibility', 'off');
    hasData = false;
    if ~isempty(valid0) && any(valid0(:))
        plot(v0(valid0), z0_at_v(valid0), '-','LineWidth',1.0, 'Color', [0 0.4470 0.7410], 'DisplayName', 'T0');
        hasData = true;
    end
    if ~isempty(valid1) && any(valid1(:))
        plot(v1(valid1), z1_at_v(valid1), '-','LineWidth',1.0, 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'T1');
        hasData = true;
    end
    if ~hasData
        % no data: show station name and note
        text(0.5, 0.5, 'No valid data', 'Units', 'normalized', 'HorizontalAlignment', 'center', 'FontSize', 10);
    % else
    %     legend('show', 'Location', 'best');
    end

    set(gca, 'FontSize', 12);
    grid on;
    ylim([-3 4]);
    xlim([-1.4 1.4]);
    titleStrStation = stationNames_title{k};
    % legend('show', 'Location', 'best');
    title(titleStrStation, 'Interpreter', 'none', 'FontSize', 14);
    hold off;
end

% If there are remaining tiles (when nStations < maxTiles), fill them empty to keep layout consistent
for k = (nToPlot+1):maxTiles
    nexttile;
    axis off;
end

% Put legend in 20th tile (tile index 12 in a 4x5 layout)
nexttile(20);
axis off;
% Create an invisible axes to host the legend centered within the tile
hAx = gca;
hAx.Visible = 'off';

% Create legend entries without plotting new graphics by using line objects with NaN data
hLine1 = line(nan, nan, 'LineWidth', 2.5, 'Color', [0 0.4470 0.7410]);
hLine2 = line(nan, nan, 'LineWidth', 2.5, 'Color', [0.8500 0.3250 0.0980]);

lgd = legend([hLine1, hLine2], {'T0','T1'}, ...
    'Location', 'west', ...
    'FontSize', 14, ...
    'Box', 'off', ...
    'Interpreter', 'none');

% Ensure legend is placed inside the tile and does not affect other tiles
lgd.Units = 'normalized';
lgd.Position(1:2) = max(min(lgd.Position(1:2), 1), 0);

% %% export figure 
% outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% fname = fullfile(outDir, sprintf('Bath_HW_vel.png'));
% % Save current figure as PNG with good resolution
% try
%     exportgraphics(gcf, fname, 'Resolution', 300);
% catch
%     % fallback to print if exportgraphics unavailable
%     try
%         print(gcf, fname, '-dpng', '-r300');
%     catch
%         % final fallback
%         saveas(gcf, fname);
%     end
% end

%% Residual Velocity
nStations = numel(stationNames);
nRows = 5; nCols = 4;
maxTiles = nRows * nCols; % Total slots = 20

fig = figure('Name', 'High Water Velocities Tiled Bins', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 17, 24]; 

t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');
title(t, 'Residual Velocity vs Water Level: Bath', 'FontSize', 16, 'FontWeight', 'bold');
xlabel(t, 'Velocity (m/s)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 13, 'FontWeight', 'bold');

% --- Binning Settings ---
z_edges = -3:0.2:4.5; % 0.2m bins
z_centers = z_edges(1:end-1) + 0.1;
v_edges = -1.4:0.1:1.4; % 0.1m bins

% Plot max 19 stations to leave the 20th tile for the legend
nToPlot = min(nStations, maxTiles - 1);

for k = 1:nToPlot
   % Prepare T0 data (use WL_Bath for T0)
    if exist('WL_Bath','var') && exist('WL_Bath_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        % WL_Bath and WL_Bath_time are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Bath) && numel(WL_Bath) >= k
            zWL_cell = WL_Bath{k};
            twl_cell = WL_Bath_time{k};
        else
            zWL_cell = WL_Bath;
            twl_cell = WL_Bath_time;
        end
        tWL = twl_cell(:);
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0 = vel0_da{k}(:);
        if isdatetime(tWL)
            twl_num = datenum(tWL);
        else
            twl_num = tWL;
        end
        if isdatetime(tV0)
            tv0_num = datenum(tV0);
        else
            tv0_num = tV0;
        end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
            valid0 = ~isnan(z0_at_v) & ~isnan(v0);
        else
            valid0 = false(size(v0));
            z0_at_v = NaN(size(v0));
        end
    else
        v0 = [];
        z0_at_v = [];
        valid0 = [];
    end

    % Prepare T1 data (use WL_Bath1 for T1)
    if exist('WL_Bath1','var') && exist('WL_Bath_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        % WL_Bath1 and WL_Bath_time1 are per-station cell arrays from earlier;
        % attempt to use station-specific cell if available, otherwise fall back to concatenated vectors
        if iscell(WL_Bath1) && numel(WL_Bath1) >= k
            zWL1_cell = WL_Bath1{k};
            twl1_cell = WL_Bath_time1{k};
        else
            zWL1_cell = WL_Bath1;
            twl1_cell = WL_Bath_time1;
        end
        tWL1 = twl1_cell(:);
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1 = vel1_da{k}(:);
        if isdatetime(tWL1)
            twl1_num = datenum(tWL1);
        else
            twl1_num = tWL1;
        end
        if isdatetime(tV1)
            tv1_num = datenum(tV1);
        else
            tv1_num = tV1;
        end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
            valid1 = ~isnan(z1_at_v) & ~isnan(v1);
        else
            valid1 = false(size(v1));
            z1_at_v = NaN(size(v1));
        end
    else
        v1 = [];
        z1_at_v = [];
        valid1 = [];
    end

    ax = nexttile;
    hold on;

    % --- Binning Logic for T0 ---
    if ~isempty(valid0) && any(valid0)
        v0_raw = v0(valid0);
        z0_raw = z0_at_v(valid0);

        v0_binned = NaN(size(z_centers));
        for b = 1:numel(z_centers)
            % Find indices where water level falls into the current bin
            idx = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
            if any(idx)
                v0_binned(b) = mean(v0_raw(idx)); % Calculate average velocity for this WL bin
            end
        end
        % Plot binned T0
        plot(v0_binned, z_centers, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, ...
            'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410], 'DisplayName', 'T0');
    end

    % --- Binning Logic for T1 ---
    if ~isempty(valid1) && any(valid1)
        v1_raw = v1(valid1);
        z1_raw = z1_at_v(valid1);

        v1_binned = NaN(size(z_centers));
        for b = 1:numel(z_centers)
            idx = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
            if any(idx)
                v1_binned(b) = mean(v1_raw(idx));
            end
        end
        % Plot binned T1
        plot(v1_binned, z_centers, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, ...
            'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'DisplayName', 'T1');
    end

    % --- Formatting ---
    ax.XTick = [-0.5 0 0.5];
    ax.XTickLabel = {}; 
    ax.YTickLabel = {};
    if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end % Show left column
    if k > (nRows-1)*nCols, ax.XTickLabelMode = 'auto'; end   % Show bottom row
    grid on; 
    ax.GridAlpha = 0.1;
    ax.FontSize = 12;
    ylim([-3 4]); 
    xlim([-1 1]);
    title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 12);

    % --text for flood and ebb--
    % add text for "flood" and "ebb" on each tile at bottom
    % Place 'flood' at left-bottom and 'ebb' at right-bottom of each tile
    xLimits = xlim(ax);
    yLimits = ylim(ax);
    xPadding = 0.03 * range(xLimits);
    yPadding = 0.02 * range(yLimits);

    % Left-bottom (flood)
    text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7], ...
        'Interpreter', 'none');

    % Right-bottom (ebb)
    text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7], ...
        'Interpreter', 'none');

    % Reference line
    line([0 0], [-3 4], 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

% Put legend in 20th tile (tile index 20 in a 4x5 layout)
try
    tlayout = gca;
    % If current axes is not a tile, attempt to get tiledlayout parent
    if ~isa(tlayout.Parent, 'matlab.graphics.layout.TiledChartLayout')
        % Find the tiledlayout in the figure
        tlay = findall(gcf, 'Type', 'tiledlayout');
        if ~isempty(tlay)
            tlayout = tlay(1);
        else
            tlayout = [];
        end
    else
        tlayout = tilayout.Parent;
    end
catch
    tlayout = [];
end

% Safely select tile 20 if layout exists and has enough tiles
if exist('tlayout','var') && ~isempty(tlayout)
    try
        nexttile(20);
    catch
        % If tile 20 doesn't exist, use the last tile
        tiles = findall(gcf, 'Type', 'axes');
        if ~isempty(tiles)
            axes(tiles(end));
            cla;
        else
            axes;
        end
    end
else
    % No tiledlayout found; create a new invisible axes for legend
    axes('Position',[0 0 1 1],'Visible','off');
end

axLeg = nexttile(t, 20); 
axis(axLeg, 'off'); % Hide the axes box

% 3. Create dummy lines that match the binned plot style
hT0 = line(axLeg, nan, nan, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0 0.4470 0.7410], 'LineStyle', '-');
hT1 = line(axLeg, nan, nan, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'LineStyle', '-');

% 4. Generate the legend
lgd = legend(axLeg, [hT0, hT1], {'T0', 'T1'}, ...
    'Location', 'west', ...
    'FontSize', 16, ...
    'Box', 'off', ...
    'FontWeight', 'bold');

% 5. Optional: Final layout tightening
t.Padding = 'compact';
t.TileSpacing = 'compact';

% %% export 
% outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% fname = fullfile(outDir, sprintf('Bath_residual_HW_vel.png'));
% % Save current figure as PNG with good resolution
% try
%     exportgraphics(gcf, fname, 'Resolution', 300);
% catch
%     % fallback to print if exportgraphics unavailable
%     try
%         print(gcf, fname, '-dpng', '-r300');
%     catch
%         % final fallback
%         saveas(gcf, fname);
%     end
% end

%% Binning percentiles
nStations = numel(stationNames);
nRows = 5; nCols = 4;
maxTiles = nRows * nCols; % Total slots = 20

fig = figure('Name', 'High Water Velocities Percentile', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 17, 24]; 

t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');
title(t, 'Velocity vs Water Level: Bath', 'FontSize', 20, 'FontWeight', 'bold');
xlabel(t, 'Velocity (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 14, 'FontWeight', 'bold');

% --- Binning Settings ---
z_edges = -3:0.2:4.5; % 0.2m bins
z_centers = z_edges(1:end-1) + 0.1;
v_edges = -1.4:0.1:1.4; % 0.1m bins

% Plot max 19 stations to leave the 20th tile for the legend
nToPlot = min(nStations, maxTiles - 1);

for k = 1:nToPlot
   % Prepare T0 data (use WL_Bath for T0)
    if exist('WL_Bath','var') && exist('WL_Bath_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        % WL_Bath and WL_Bath_time are per-station cell arrays from earlier;
        if iscell(WL_Bath) && numel(WL_Bath) >= k
            zWL_cell = WL_Bath{k};
            twl_cell = WL_Bath_time{k};
        else
            zWL_cell = WL_Bath;
            twl_cell = WL_Bath_time;
        end
        tWL = twl_cell(:);
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0 = vel0_da{k}(:);
        if isdatetime(tWL)
            twl_num = datenum(tWL);
        else
            twl_num = tWL;
        end
        if isdatetime(tV0)
            tv0_num = datenum(tV0);
        else
            tv0_num = tV0;
        end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
            valid0 = ~isnan(z0_at_v) & ~isnan(v0);
        else
            valid0 = false(size(v0));
            z0_at_v = NaN(size(v0));
        end
    else
        v0 = [];
        z0_at_v = [];
        valid0 = [];
    end

    % Prepare T1 data (use WL_Bath1 for T1)
    if exist('WL_Bath1','var') && exist('WL_Bath_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        % WL_Bath1 and WL_Bath_time1 are per-station cell arrays from earlier;
        if iscell(WL_Bath1) && numel(WL_Bath1) >= k
            zWL1_cell = WL_Bath1{k};
            twl1_cell = WL_Bath_time1{k};
        else
            zWL1_cell = WL_Bath1;
            twl1_cell = WL_Bath_time1;
        end
        tWL1 = twl1_cell(:);
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1 = vel1_da{k}(:);
        if isdatetime(tWL1)
            twl1_num = datenum(tWL1);
        else
            twl1_num = tWL1;
        end
        if isdatetime(tV1)
            tv1_num = datenum(tV1);
        else
            tv1_num = tV1;
        end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
            valid1 = ~isnan(z1_at_v) & ~isnan(v1);
        else
            valid1 = false(size(v1));
            z1_at_v = NaN(size(v1));
        end
    else
        v1 = [];
        z1_at_v = [];
        valid1 = [];
    end

    ax = nexttile;
    hold on;
    
        % --- Binning Logic for T0: compute 5th, 50th, 95th percentiles per flood/ebb velocity ---
        pctiles = [5 50 95];
        nPct = numel(pctiles);
        % colors for T0 (blue): single shade for 5 & 95, solid for 50 (slightly lighter)
        royalBlue = [65, 105, 225] / 255;
        lightBlue = [173, 216, 230] / 255;
        color_edge0 = royalBlue;
        color_med0 = lightBlue;
    
        if ~isempty(valid0) && any(valid0)
        v0_raw = v0(valid0);
        z0_raw = z0_at_v(valid0);
        
        % Initialize separate matrices for Ebb (<0) and Flood (>0)
        v0_eb_pct = NaN(numel(z_centers), nPct);
        v0_fl_pct = NaN(numel(z_centers), nPct);
        
        for b = 1:numel(z_centers)
            idx_bin = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
            if any(idx_bin)
                v_bin = v0_raw(idx_bin);
                
                % Split into ebb and flood components
                v_ebb = v_bin(v_bin < 0);
                v_flood = v_bin(v_bin >= 0);
                
                if ~isempty(v_ebb),   v0_eb_pct(b,:) = prctile(v_ebb, pctiles); end
                if ~isempty(v_flood), v0_fl_pct(b,:) = prctile(v_flood, pctiles); end
            end
        end
        
        % --- Plot Ebb Envelope & Median ---
        baseOrange = [0.8500 0.3250 0.0980];
        idx_eb = ~isnan(v0_eb_pct(:,1));
        if any(idx_eb)
            x_patch_eb = [v0_eb_pct(idx_eb,1); flipud(v0_eb_pct(idx_eb,3))];
            y_patch_eb = [z_centers(idx_eb)'; flipud(z_centers(idx_eb)')];
            fill(ax, x_patch_eb, y_patch_eb, royalBlue, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_eb_pct(idx_eb,2), z_centers(idx_eb), 'LineWidth', 2, 'Color', royalBlue);
        end
        
        % --- Plot Flood Envelope & Median ---
        idx_fl = ~isnan(v0_fl_pct(:,1));
        if any(idx_fl)
            x_patch_fl = [v0_fl_pct(idx_fl,1); flipud(v0_fl_pct(idx_fl,3))];
            y_patch_fl = [z_centers(idx_fl)'; flipud(z_centers(idx_fl)')];
            fill(ax, x_patch_fl, y_patch_fl, royalBlue, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_fl_pct(idx_fl,2), z_centers(idx_fl), 'LineWidth', 2, 'Color', royalBlue);
        end
        end

        % --- Binning Logic for T1: compute 5th, 50th, 95th percentiles per WL bin ---
        if ~isempty(valid1) && any(valid1)
            v1_raw = v1(valid1);
            z1_raw = z1_at_v(valid1);
            
            % Initialize separate matrices for Ebb (<0) and Flood (>=0)
            v1_eb_pct = NaN(numel(z_centers), nPct);
            v1_fl_pct = NaN(numel(z_centers), nPct);
            
            for b = 1:numel(z_centers)
                idx_bin = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
                if any(idx_bin)
                    v_bin = v1_raw(idx_bin);
                    
                    % Split into ebb and flood components
                    v_ebb1   = v_bin(v_bin < 0);
                    v_flood1 = v_bin(v_bin >= 0);
                    
                    if ~isempty(v_ebb1),   v1_eb_pct(b,:) = prctile(v_ebb1, pctiles); end
                    if ~isempty(v_flood1), v1_fl_pct(b,:) = prctile(v_flood1, pctiles); end
                end
            end
            
            % --- Plot T1 Ebb Envelope & Median (Orange) ---
            idx_eb1 = ~isnan(v1_eb_pct(:,1)) & ~isnan(v1_eb_pct(:,2)) & ~isnan(v1_eb_pct(:,3));
            if any(idx_eb1)
                z_sub_eb1 = z_centers(idx_eb1);
                x_patch_eb1 = [v1_eb_pct(idx_eb1,1); flipud(v1_eb_pct(idx_eb1,3))];
                y_patch_eb1 = [z_sub_eb1(:); flipud(z_sub_eb1(:))];
                
                fill(ax, x_patch_eb1, y_patch_eb1, baseOrange, ...
                    'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, v1_eb_pct(idx_eb1,2), z_sub_eb1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
                    'DisplayName', 'T1 Ebb Median');
            end
            
            % --- Plot T1 Flood Envelope & Median (Orange) ---
            idx_fl1 = ~isnan(v1_fl_pct(:,1)) & ~isnan(v1_fl_pct(:,2)) & ~isnan(v1_fl_pct(:,3));
            if any(idx_fl1)
                z_sub_fl1 = z_centers(idx_fl1);
                x_patch_fl1 = [v1_fl_pct(idx_fl1,1); flipud(v1_fl_pct(idx_fl1,3))];
                y_patch_fl1 = [z_sub_fl1(:); flipud(z_sub_fl1(:))];
                
                fill(ax, x_patch_fl1, y_patch_fl1, baseOrange, ...
                    'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, v1_fl_pct(idx_fl1,2), z_sub_fl1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
                    'DisplayName', 'T1 Flood Median');
            end
        end

   % --- Formatting ---
        ax.XTick = [-1 0 1];
        ax.XTickLabel = {}; 
        ax.YTickLabel = {};
        if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end % Show left column
        % Show x tick labels for bottom row and for tiles 15-18
        if k > (nRows-1)*nCols || ismember(k, 15:18)
            ax.XTickLabelMode = 'auto';
        end
        grid on; 
        ax.GridAlpha = 0.1;
        ax.FontSize = 12;
        ylim([-3 4]); 
        xlim([-1.4 1.4]);
        title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 12);
    
        % --text for flood and ebb--
        % add text for "flood" and "ebb" on each tile at bottom
        xLimits = xlim(ax);
        yLimits = ylim(ax);
        xPadding = 0.03 * range(xLimits);
        yPadding = 0.02 * range(yLimits);
    
        % Left-bottom (flood)
        text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7], ...
            'Interpreter', 'none');
    
        % Right-bottom (ebb)
        text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7], ...
            'Interpreter', 'none');
        
        % Reference line
        line([0 0], [-3 4], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off');
end 

% Put legend in 20th tile (tile index 20 in a 4x5 layout)
try
    tlayout = gca;
    % If current axes is not a tile, attempt to get tiledlayout parent
    if ~isa(tlayout.Parent, 'matlab.graphics.layout.TiledChartLayout')
        % Find the tiledlayout in the figure
        tlay = findall(gcf, 'Type', 'tiledlayout');
        if ~isempty(tlay)
            tlayout = tlay(1);
        else
            tlayout = [];
        end
    else
        tlayout = tilayout.Parent;
    end
catch
    tlayout = [];
end

% Safely select tile 20 if layout exists and has enough tiles
if exist('tlayout','var') && ~isempty(tlayout)
    try
        nexttile(20);
    catch
        % If tile 20 doesn't exist, use the last tile
        tiles = findall(gcf, 'Type', 'axes');
        if ~isempty(tiles)
            axes(tiles(end));
            cla;
        else
            axes;
        end
    end
else
    % No tiledlayout found; create a new invisible axes for legend
    axes('Position',[0 0 1 1],'Visible','off');
end

axLeg = nexttile(t, 19); 
axis(axLeg, 'off'); % Hide the axes box

% Create dummy legend entries matching the shaded region + median line for T1
% Shaded patch (5th-95th) - use a patch handle with FaceAlpha matching fill
hT0_patch = patch(axLeg, nan(1,4), nan(1,4), royalBlue, 'FaceAlpha', 0.2, ...
    'EdgeColor', 'none');
hT1_patch = patch(axLeg, nan(1,4), nan(1,4), baseOrange, 'FaceAlpha', 0.2, ...
    'EdgeColor', 'none');

% Median line (50th) for T1
hT1_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);

% Also create corresponding dummy entries for T0 style if desired (kept from original pattern)
hT0_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', royalBlue);

% Ensure colors are clipped to [0,1]
for hh = [hT1_patch, hT0_patch, hT1_med, hT0_med]
    if isprop(hh, 'FaceColor')
        c = get(hh, 'FaceColor');
        if ~isempty(c) && ~any(isnan(c))
            c = min(max(c,0),1);
            set(hh, 'FaceColor', c);
        end
    end
    if isprop(hh, 'Color')
        c = get(hh, 'Color');
        if ~isempty(c) && ~any(isnan(c))
            c = min(max(c,0),1);
            set(hh, 'Color', c);
        end
    end
end

% Build legend using the patch handle for the shaded region and the median line
lgd = legend(axLeg, [hT0_med, hT1_med, hT0_patch, hT1_patch], ...
    {'T0 - median', 'T1 - median', 'T0 - 95% interval', 'T1 - 95% interval'}, ...
    'Location', 'west', 'FontSize', 12, 'Box', 'off', 'FontWeight', 'bold');

% 5. Optional: Final layout tightening
t.Padding = 'compact';
t.TileSpacing = 'compact';

% %% export 
% outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% fname = fullfile(outDir, sprintf('Bathpctshaded_HW_vel.png'));
% % Save current figure as PNG with good resolution
% try
%     exportgraphics(gcf, fname, 'Resolution', 300);
% catch
%     % fallback to print if exportgraphics unavailable
%     try
%         print(gcf, fname, '-dpng', '-r300');
%     catch
%         % final fallback
%         saveas(gcf, fname);
%     end
% end

% %% %% plotting profile and velocity side by side (modified to include GeoTIFF subplot)
% figure();
% 
% % Subplot 1: Aerial with box of interest (GeoTIFF + lines)
% subplot(1,3,1);
% imshow(I);
% 
% % Subplot 2: Cross Shore Profile (elevation vs distance)
% subplot(1,3,2);
% hold on;
% plot(xdist*20, vals1, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 4, 'HandleVisibility', 'off');
% plot(84, -1, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor',  'b', 'DisplayName', '0702');
% plot(270, 1.4, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'DisplayName', '0703');
% % plot(40, -1.160, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor',  'b', 'DisplayName', '0902');
% % plot(305, 1.0, 'o', 'MarkerSize', 18, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'DisplayName', '0903');
% legend('show');
% % hLeg = legend;
% % set(hLeg, 'FontSize', 16);
% hold off;
% % xlim([0 600]);
% ylim([-2.5 5]);
% xlabel('Distance (m)', 'FontSize', 18);
% ylabel('Elevation NAP (m)', 'FontSize', 18);
% title('Profile', 'FontSize', 28);
% set(gca, 'FontSize', 20);
% 
% % Subplot 3: Velocity vs Water Level for stations 
% subplot(1,3,3);
% hold on;
% for k = 1:nStations
%     % check station name matches (robust to stationNames content)
%     if ischar(stationNames{k}) || isstring(stationNames{k})
%         name = char(stationNames{k});
%     else
%         continue
%     end
%     if contains(name, '0702') || contains(name, '0703')
%         % Prepare T0 data
%         if isempty(time0{k}) || isempty(vel0_da{k}) || isempty(WL_Bath_time) || isempty(WL_Bath)
%             v0 = [];
%             z0_at_v = [];
%             valid0 = false(0,1);
%         else
%             tV0 = time0{k}(:);
%             v0 = vel0_da{k}(:);
%             tWL = WL_Bath_time(:);
%             zWL = WL_Bath(:);
%             if isdatetime(tWL)
%                 twl_num = datenum(tWL);
%             else
%                 twl_num = tWL;
%             end
%             if isdatetime(tV0)
%                 tv0_num = datenum(tV0);
%             else
%                 tv0_num = tV0;
%             end
%             validWL = ~isnan(zWL) & ~isnan(twl_num);
%             if sum(validWL) >= 2
%                 zWL_valid = zWL(validWL);
%                 twl_valid = twl_num(validWL);
%                 z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
%                 valid0 = ~isnan(z0_at_v) & ~isnan(v0);
%             else
%                 v0 = [];
%                 z0_at_v = [];
%                 valid0 = false(size(v0));
%             end
%         end
% 
%         % Prepare T1 data (use WL_Bath_time1 / WL_Bath1 if available)
%         if isempty(time1{k}) || isempty(vel1_da{k}) || isempty(WL_Bath_time1) || isempty(WL_Bath1)
%             v1 = [];
%             z1_at_v = [];
%             valid1 = false(0,1);
%         else
%             tV1 = time1{k}(:);
%             v1 = vel1_da{k}(:);
%             tWL1 = WL_Bath_time1(:);
%             zWL1 = WL_Bath1(:);
%             if isdatetime(tWL1)
%                 twl1_num = datenum(tWL1);
%             else
%                 twl1_num = tWL1;
%             end
%             if isdatetime(tV1)
%                 tv1_num = datenum(tV1);
%             else
%                 tv1_num = tV1;
%             end
%             validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
%             if sum(validWL1) >= 2
%                 zWL1_valid = zWL1(validWL1);
%                 twl1_valid = twl1_num(validWL1);
%                 z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
%                 valid1 = ~isnan(z1_at_v) & ~isnan(v1);
%             else
%                 v1 = [];
%                 z1_at_v = [];
%                 valid1 = false(size(v1));
%             end
%         end
% 
%         % If neither has valid data, skip
%         if (~any(valid0(:)) && ~any(valid1(:)))
%             continue;
%         end
% 
%         % plot with specific colors for 0902 (blue) and 0903 (red), include T0 and T1
%         if contains(name, '0702')
%             colT0 = 'b'; %dark blue
%             colT1 = [0.3010 0.7450 0.9330]; %light blue
%         else % 0903
%             colT0 = 'r';    % red
%             colT1 = [1.0 0.6 0.6];    % lighter red (pinkish)
%         end
%         plotted = false;
%         if any(valid0(:))
%             plot(v0(valid0), z0_at_v(valid0), 'o-','LineWidth',1.2, 'Color', colT0, 'DisplayName', sprintf('%s T0', stationNames_title{k}));
%             plotted = true;
%         end
%         % if any(valid1(:))
%         %     plot(v1(valid1), z1_at_v(valid1), 's-','LineWidth',1.2, 'Color', colT1, 'DisplayName', sprintf('%s T1', stationNames_title{k}));
%         %     plotted = true;
%         % end
%         if ~plotted
%             continue;
%         end
%     end
% end
% ylabel('Water Level NAP (m)', 'FontSize', 18);
% xlabel('Velocity (m/s)', 'FontSize', 18);
% title('Velocity vs Water Level', 'FontSize', 20);
% set(gca, 'FontSize', 20);
% ylim([-2.5 5]);
% legend('show');
% hLeg = legend;
% set(hLeg, 'FontSize', 16, 'Location', 'best');
% hold off;
% 
% % Add one large centered title for the entire figure (suptitle-like)
% sgtitle('Bath (0702 & 0703) Velocities on Cross Shore Profile', 'FontSize', 26, 'FontWeight', 'bold');

%% Binning percentiles with groynes!
nStations = numel(stationNames);
nRows = 4; nCols = 5;
maxTiles = nRows * nCols; % Total slots = 20

fig = figure('Name', 'High Water Velocities Percentile', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 17, 18]; 

t = tiledlayout(nRows, nCols, 'TileSpacing', 'tight', 'Padding', 'tight');
% title(t, 'Velocity vs Water Level: Bath', 'FontSize', 16, 'FontWeight', 'bold');
xlabel(t, 'Depth Averaged Velocity (m/s)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(t, 'Water Level NAP (m)', 'FontSize', 13, 'FontWeight', 'bold');

% --- Binning Settings ---
z_edges = -3:0.2:4.5; % 0.2m bins
z_centers = z_edges(1:end-1) + 0.1;
v_edges = -1.4:0.1:1.4; % 0.1m bins

% Plot max 19 stations to leave the 20th tile for the legend
nToPlot = min(nStations, maxTiles - 1);

for k = 1:nToPlot
   % Prepare T0 data (use WL_Bath for T0)
    if exist('WL_Bath','var') && exist('WL_Bath_time','var') && ~isempty(time0{k}) && ~isempty(vel0_da{k})
        % WL_Bath and WL_Bath_time are per-station cell arrays from earlier;
        if iscell(WL_Bath) && numel(WL_Bath) >= k
            zWL_cell = WL_Bath{k};
            twl_cell = WL_Bath_time{k};
        else
            zWL_cell = WL_Bath;
            twl_cell = WL_Bath_time;
        end
        tWL = twl_cell(:);
        zWL = zWL_cell(:);
        tV0 = time0{k}(:);
        v0 = vel0_da{k}(:);
        if isdatetime(tWL)
            twl_num = datenum(tWL);
        else
            twl_num = tWL;
        end
        if isdatetime(tV0)
            tv0_num = datenum(tV0);
        else
            tv0_num = tV0;
        end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            zWL_valid = zWL(validWL);
            twl_valid = twl_num(validWL);
            z0_at_v = interp1(twl_valid, zWL_valid, tv0_num, 'linear', NaN);
            valid0 = ~isnan(z0_at_v) & ~isnan(v0);
        else
            valid0 = false(size(v0));
            z0_at_v = NaN(size(v0));
        end
    else
        v0 = [];
        z0_at_v = [];
        valid0 = [];
    end

    % Prepare T1 data (use WL_Bath1 for T1)
    if exist('WL_Bath1','var') && exist('WL_Bath_time1','var') && ~isempty(time1{k}) && ~isempty(vel1_da{k})
        % WL_Bath1 and WL_Bath_time1 are per-station cell arrays from earlier;
        if iscell(WL_Bath1) && numel(WL_Bath1) >= k
            zWL1_cell = WL_Bath1{k};
            twl1_cell = WL_Bath_time1{k};
        else
            zWL1_cell = WL_Bath1;
            twl1_cell = WL_Bath_time1;
        end
        tWL1 = twl1_cell(:);
        zWL1 = zWL1_cell(:);
        tV1 = time1{k}(:);
        v1 = vel1_da{k}(:);
        if isdatetime(tWL1)
            twl1_num = datenum(tWL1);
        else
            twl1_num = tWL1;
        end
        if isdatetime(tV1)
            tv1_num = datenum(tV1);
        else
            tv1_num = tV1;
        end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            zWL1_valid = zWL1(validWL1);
            twl1_valid = twl1_num(validWL1);
            z1_at_v = interp1(twl1_valid, zWL1_valid, tv1_num, 'linear', NaN);
            valid1 = ~isnan(z1_at_v) & ~isnan(v1);
        else
            valid1 = false(size(v1));
            z1_at_v = NaN(size(v1));
        end
    else
        v1 = [];
        z1_at_v = [];
        valid1 = [];
    end

    ax = nexttile;
    hold on;
    
        % --- Binning Logic for T0: compute 5th, 50th, 95th percentiles per flood/ebb velocity ---
        pctiles = [5 50 95];
        nPct = numel(pctiles);
        % colors for T0 (blue): single shade for 5 & 95, solid for 50 (slightly lighter)
        royalBlue = [65, 105, 225] / 255;
        lightBlue = [173, 216, 230] / 255;
        color_edge0 = royalBlue;
        color_med0 = lightBlue;
    
        if ~isempty(valid0) && any(valid0)
        v0_raw = v0(valid0);
        z0_raw = z0_at_v(valid0);
        
        % Initialize separate matrices for Ebb (<0) and Flood (>0)
        v0_eb_pct = NaN(numel(z_centers), nPct);
        v0_fl_pct = NaN(numel(z_centers), nPct);
        
        for b = 1:numel(z_centers)
            idx_bin = z0_raw >= z_edges(b) & z0_raw < z_edges(b+1);
            if any(idx_bin)
                v_bin = v0_raw(idx_bin);
                
                % Split into ebb and flood components
                v_ebb = v_bin(v_bin < 0);
                v_flood = v_bin(v_bin >= 0);
                
                if ~isempty(v_ebb),   v0_eb_pct(b,:) = prctile(v_ebb, pctiles); end
                if ~isempty(v_flood), v0_fl_pct(b,:) = prctile(v_flood, pctiles); end
            end
        end
        
        % --- Plot Ebb Envelope & Median ---
        baseOrange = [0.8500 0.3250 0.0980];
        idx_eb = ~isnan(v0_eb_pct(:,1));
        if any(idx_eb)
            x_patch_eb = [v0_eb_pct(idx_eb,1); flipud(v0_eb_pct(idx_eb,3))];
            y_patch_eb = [z_centers(idx_eb)'; flipud(z_centers(idx_eb)')];
            fill(ax, x_patch_eb, y_patch_eb, royalBlue, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_eb_pct(idx_eb,2), z_centers(idx_eb), 'LineWidth', 2, 'Color', royalBlue);
        end
        
        % --- Plot Flood Envelope & Median ---
        idx_fl = ~isnan(v0_fl_pct(:,1));
        if any(idx_fl)
            x_patch_fl = [v0_fl_pct(idx_fl,1); flipud(v0_fl_pct(idx_fl,3))];
            y_patch_fl = [z_centers(idx_fl)'; flipud(z_centers(idx_fl)')];
            fill(ax, x_patch_fl, y_patch_fl, royalBlue, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            plot(ax, v0_fl_pct(idx_fl,2), z_centers(idx_fl), 'LineWidth', 2, 'Color', royalBlue);
        end
        end

        % --- Binning Logic for T1: compute 5th, 50th, 95th percentiles per WL bin ---
        if ~isempty(valid1) && any(valid1)
            v1_raw = v1(valid1);
            z1_raw = z1_at_v(valid1);
            
            % Initialize separate matrices for Ebb (<0) and Flood (>=0)
            v1_eb_pct = NaN(numel(z_centers), nPct);
            v1_fl_pct = NaN(numel(z_centers), nPct);
            
            for b = 1:numel(z_centers)
                idx_bin = z1_raw >= z_edges(b) & z1_raw < z_edges(b+1);
                if any(idx_bin)
                    v_bin = v1_raw(idx_bin);
                    
                    % Split into ebb and flood components
                    v_ebb1   = v_bin(v_bin < 0);
                    v_flood1 = v_bin(v_bin >= 0);
                    
                    if ~isempty(v_ebb1),   v1_eb_pct(b,:) = prctile(v_ebb1, pctiles); end
                    if ~isempty(v_flood1), v1_fl_pct(b,:) = prctile(v_flood1, pctiles); end
                end
            end
            
            % --- Plot T1 Ebb Envelope & Median (Orange) ---
            idx_eb1 = ~isnan(v1_eb_pct(:,1)) & ~isnan(v1_eb_pct(:,2)) & ~isnan(v1_eb_pct(:,3));
            if any(idx_eb1)
                z_sub_eb1 = z_centers(idx_eb1);
                x_patch_eb1 = [v1_eb_pct(idx_eb1,1); flipud(v1_eb_pct(idx_eb1,3))];
                y_patch_eb1 = [z_sub_eb1(:); flipud(z_sub_eb1(:))];
                
                fill(ax, x_patch_eb1, y_patch_eb1, baseOrange, ...
                    'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, v1_eb_pct(idx_eb1,2), z_sub_eb1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
                    'DisplayName', 'T1 Ebb Median');
            end
            
            % --- Plot T1 Flood Envelope & Median (Orange) ---
            idx_fl1 = ~isnan(v1_fl_pct(:,1)) & ~isnan(v1_fl_pct(:,2)) & ~isnan(v1_fl_pct(:,3));
            if any(idx_fl1)
                z_sub_fl1 = z_centers(idx_fl1);
                x_patch_fl1 = [v1_fl_pct(idx_fl1,1); flipud(v1_fl_pct(idx_fl1,3))];
                y_patch_fl1 = [z_sub_fl1(:); flipud(z_sub_fl1(:))];
                
                fill(ax, x_patch_fl1, y_patch_fl1, baseOrange, ...
                    'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, v1_fl_pct(idx_fl1,2), z_sub_fl1, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange, ...
                    'DisplayName', 'T1 Flood Median');
            end
        end

   % --- Formatting ---
        ax.XTick = [-1 0 1];
        ax.XTickLabel = {}; 
        ax.YTickLabel = {};
        if mod(k-1, nCols) == 0, ax.YTickLabelMode = 'auto'; end % Show left column
        if k > (nRows-1)*nCols || ismember(k, 14:18)
          ax.XTickLabelMode = 'auto';
        end
        grid on; 
        ax.GridAlpha = 0.1;
        ax.FontSize = 11;
        ylim([-3 4]); 
        xlim([-1.4 1.4]);
        title(stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 12);
    
        % --text for flood and ebb--
        % add text for "flood" and "ebb" on each tile at bottom
        xLimits = xlim(ax);
        yLimits = ylim(ax);
        xPadding = 0.03 * range(xLimits);
        yPadding = 0.02 * range(yLimits);
    
        % Left-bottom (flood)
        text(xLimits(1) + xPadding, yLimits(1) + yPadding, 'ebb', ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7], ...
            'Interpreter', 'none');
    
        % Right-bottom (ebb)
        text(xLimits(2) - xPadding, yLimits(1) + yPadding, 'flood', ...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color',  [0.7 0.7 0.7], ...
            'Interpreter', 'none');
        
        % Reference line
        line([0 0], [-3 4], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off');

        % --- Add customizable gray rectangles to represent groynes on left and right y-axis ---
        % Only draw rectangles for specific k values; no default boxes
        valid_k = [5,7,8,10,11,12,14,15,17];
        if ~ismember(k, valid_k)
            % Skip drawing any rectangles for this tile
        else
            % Determine y1 (left) and y2 (right) based on k
            y1 = [];
            y2 = [];
            if k == 5 %0202
                y1 = [-1.6 3];
                y2 = [-2.16 -1.16];
            end
            if k == 7 %0302
                y1 = [-1.82 -0.82];
                y2 = [-1.94 -0.94];
            end
            if k==8 %0402
                y1 = [-2.03 -1.03];
                y2 = [-1.75 -0.75];
            end
            if k == 10 %0502
                y1 = [-1.83 -0.83];
                y2 = [-1.81 -0.81];
            end
            if k == 11 %0602
                y1 = [-1.8 -0.8];
                y2 = [-1.87 -0.87];
            end
            if k == 12 %0702
                y1 = [-1.34 -0.34];
                y2 = [-1.34 -0.34];
            end
            if k == 14 %0802
                y1 = [-1.71 -0.71];
                y2 = [-1.51 -0.51];
            end
            if k == 15 %0902
                y1 = [-1.45 -0.45];
                y2 = [-0.56 0.44];
            end
            if k == 17 %10002
                y1 = [-0.79 0.21];
            end

            % User-configurable parameters (can be adjusted per tile before this block)
            if ~exist('rect_width','var') || isempty(rect_width)
                rect_width = 0.06 * range(xLimits); % width in x-data units (fraction of x-range)
            end
            if ~exist('rect_color','var') || isempty(rect_color)
                rect_color = [0.6 0.6 0.6]; % gray
            end
            if ~exist('rect_alpha','var') || isempty(rect_alpha)
                rect_alpha = 0.5;
            end

            % Compute rectangle positions in data coordinates
            % Left rectangle anchored near left x-limit
            xl = xLimits(1);
            xr = xLimits(2);
            left_rect_x = [xl, xl + rect_width];
            right_rect_x = [xr - rect_width, xr];

            % Clamp vertical extents to axis limits
            y_min_ax = yLimits(1);
            y_max_ax = yLimits(2);

            % Draw left rectangle only if y1 provided and has span
            if ~isempty(y1)
                yl_left = max(min(y1(1), y_max_ax), y_min_ax);
                yh_left = max(min(y1(2), y_max_ax), y_min_ax);
                if yh_left > yl_left
                    x_poly_left = [left_rect_x(1), left_rect_x(2), left_rect_x(2), left_rect_x(1)];
                    y_poly_left = [yl_left, yl_left, yh_left, yh_left];
                    fill(ax, x_poly_left, y_poly_left, rect_color, 'FaceAlpha', rect_alpha, ...
                        'EdgeColor', 'none', 'HandleVisibility', 'off');
                end
            end

            % Draw right rectangle only if y2 provided and has span
            if exist('y2','var') && ~isempty(y2)
                yl_right = max(min(y2(1), y_max_ax), y_min_ax);
                yh_right = max(min(y2(2), y_max_ax), y_min_ax);
                if yh_right > yl_right
                    x_poly_right = [right_rect_x(1), right_rect_x(2), right_rect_x(2), right_rect_x(1)];
                    y_poly_right = [yl_right, yl_right, yh_right, yh_right];
                    fill(ax, x_poly_right, y_poly_right, rect_color, 'FaceAlpha', rect_alpha, ...
                        'EdgeColor', 'none', 'HandleVisibility', 'off');
                end
            end
        end

end 

% Put legend in 20th tile (tile index 20 in a 4x5 layout)
try
    tlayout = gca;
    % If current axes is not a tile, attempt to get tiledlayout parent
    if ~isa(tlayout.Parent, 'matlab.graphics.layout.TiledChartLayout')
        % Find the tiledlayout in the figure
        tlay = findall(gcf, 'Type', 'tiledlayout');
        if ~isempty(tlay)
            tlayout = tlay(1);
        else
            tlayout = [];
        end
    else
        tlayout = tilayout.Parent;
    end
catch
    tlayout = [];
end

% Safely select tile 20 if layout exists and has enough tiles
if exist('tlayout','var') && ~isempty(tlayout)
    try
        nexttile(20);
    catch
        % If tile 20 doesn't exist, use the last tile
        tiles = findall(gcf, 'Type', 'axes');
        if ~isempty(tiles)
            axes(tiles(end));
            cla;
        else
            axes;
        end
    end
else
    % No tiledlayout found; create a new invisible axes for legend
    axes('Position',[0 0 1 1],'Visible','off');
end

axLeg = nexttile(t, 19); 
axis(axLeg, 'off'); % Hide the axes box

% Create dummy legend entries matching the shaded region + median line for T1
% Shaded patch (5th-95th) - use a patch handle with FaceAlpha matching fill
hT0_patch = patch(axLeg, nan(1,4), nan(1,4), royalBlue, 'FaceAlpha', 0.5, ...
    'EdgeColor', 'none');
hT1_patch = patch(axLeg, nan(1,4), nan(1,4), baseOrange, 'FaceAlpha', 0.5, ...
    'EdgeColor', 'none');

% Median line (50th) for T1
hT1_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', baseOrange);

% Also create corresponding dummy entries for T0 style if desired (kept from original pattern)
hT0_med = line(axLeg, nan, nan, 'LineWidth', 2.5, 'LineStyle', '-', 'Color', royalBlue);

% Add dummy legend entry for groyne rectangles using the configured rect_color/rect_alpha/rect_width
% Ensure the variables exist; provide fallbacks consistent with tile defaults
if ~exist('rect_color','var') || isempty(rect_color)
    rect_color = [0.6 0.6 0.6];
end
if ~exist('rect_alpha','var') || isempty(rect_alpha)
    rect_alpha = 0.5;
end
% Create a small rectangle patch in the legend axes
% Position/coords are NaNs for drawing-invisible geometry but color/alpha will appear in legend
hGroyne_patch = patch(axLeg, nan(1,4), nan(1,4), rect_color, 'FaceAlpha', rect_alpha, ...
    'EdgeColor', 'none');

% Ensure colors are clipped to [0,1]
for hh = [hT1_patch, hT0_patch, hT1_med, hT0_med, hGroyne_patch]
    if isprop(hh, 'FaceColor')
        c = get(hh, 'FaceColor');
        if ~isempty(c) && ~any(isnan(c))
            c = min(max(c,0),1);
            set(hh, 'FaceColor', c);
        end
    end
    if isprop(hh, 'Color')
        c = get(hh, 'Color');
        if ~isempty(c) && ~any(isnan(c))
            c = min(max(c,0),1);
            set(hh, 'Color', c);
        end
    end
    if isprop(hh, 'FaceAlpha')
        a = get(hh, 'FaceAlpha');
        if isempty(a) || isnan(a)
            set(hh, 'FaceAlpha', 1);
        end
    end
end

% Build legend using the patch handle for the shaded region, the median lines, and the groyne rectangle
lgd = legend(axLeg, [hT0_med, hT1_med, hT0_patch, hT1_patch, hGroyne_patch], ...
    {'T0 - median', 'T1 - median', 'T0 - 95% interval', 'T1 - 95% interval', 'Groynes'}, ...
    'Location', 'west', 'FontSize', 11, 'Box', 'off', 'FontWeight', 'bold');

% 5. Optional: Final layout tightening
t.Padding = 'compact';
t.TileSpacing = 'compact';

%% reorganizing tiles based on channel, low flat, high flat
nRows = 6; nCols = 4;
maxTiles = nRows * nCols; % 24 total slots

fig = figure('Name', 'High Water Velocities Percentile', 'Color', 'w');
fig.Units = 'centimeters';
fig.Position = [1, 1, 19, 22];

t = tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
xlabel(t, 'Depth Averaged Velocity [m/s]', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(t, 'Water Level [m NAP]',           'FontSize', 13, 'FontWeight', 'bold');

% --- Binning Settings ---
z_edges   = -3:0.2:4.5;
z_centers = z_edges(1:end-1) + 0.1;
v_edges   = -1.4:0.1:1.4;
pctiles   = [5 50 95];
nPct      = numel(pctiles);

% --- Colors ---
royalBlue  = [65, 105, 225] / 255;
baseOrange = [0.8500 0.3250 0.0980];
rect_color = [0.6 0.6 0.6];
rect_alpha = 0.5;
rect_width_frac = 0.06; % fraction of x-range

% -----------------------------------------------------------------------
% Tile assignment: [k_index, tile_number]
% k = index into stationNames (1-based)
% -----------------------------------------------------------------------
% Channels
tileMap = [
    1,  1;   % MP0101
    18, 2;   % MP1101
    % Low flats
    2,  5;   % MP0102
    3,  6;   % MP0103
    5,  7;   % MP0202
    7,  8;   % MP0302
    8,  9;   % MP0402
    10, 10;  % MP0502
    11, 11;  % MP0602
    12, 12;  % MP0702
    14, 13;  % MP0802
    15, 14;  % MP0902
    17, 15;  % MP1002
    % High flats
    4,  17;  % MP0104
    6,  18;  % MP0203
    9,  19;  % MP0403
    13, 20;  % MP0703
    16, 21;  % MP0903
];

% -----------------------------------------------------------------------
% Groyne definitions: key = k index, value = [y1_bot y1_top; y2_bot y2_top]
% NaN row = no rectangle on that side
% -----------------------------------------------------------------------
groyneData = containers.Map('KeyType','int32','ValueType','any');
groyneData(5)  = [-1.6,  3.0;  -2.16, -1.16];  % MP0202
groyneData(7)  = [-1.82, -0.82; -1.94, -0.94]; % MP0302
groyneData(8)  = [-2.03, -1.03; -1.75, -0.75]; % MP0402
groyneData(10) = [-1.83, -0.83; -1.81, -0.81]; % MP0502
groyneData(11) = [-1.8,  -0.8;  -1.87, -0.87]; % MP0602
groyneData(12) = [-1.34, -0.34; -1.34, -0.34]; % MP0702
groyneData(14) = [-1.71, -0.71; -1.51, -0.51]; % MP0802
groyneData(15) = [-1.45, -0.45; -0.56,  0.44]; % MP0902
groyneData(17) = [-0.79,  0.21;  NaN,   NaN];   % MP1002

% -----------------------------------------------------------------------
% Group label annotations (drawn after all tiles)
% Store [tileStart, tileEnd, label]
% -----------------------------------------------------------------------
groupDefs = {
    'Channels',  [1  2];
    'Low Flats', [5  15];
    'High Flats',[17 21];
};

% -----------------------------------------------------------------------
% Which tiles are in the left column (show y-tick labels)?
% Left column tiles: 1,5,9,13,17,21
% -----------------------------------------------------------------------
leftColTiles  = 1:nCols:maxTiles;

% Which tiles are in the bottom row of each group or last data row?
% Show x-tick labels on: channels row (tiles 1-4), last low flat row (13-16), high flat rows (17-24)
xLabelTiles = [1 2 3 4, 13 14 15 16, 17 18 19 20 21 22 23 24];

% -----------------------------------------------------------------------
% Main plotting loop
% -----------------------------------------------------------------------
for row = 1:size(tileMap, 1)
    k      = tileMap(row, 1);
    tileNo = tileMap(row, 2);

    % --- Prepare T0 data ---
    v0 = []; z0_at_v = []; valid0 = false(0);
    if exist('WL_Bath','var') && exist('WL_Bath_time','var') && ...
            ~isempty(time0{k}) && ~isempty(vel0_da{k})
        if iscell(WL_Bath) && numel(WL_Bath) >= k
            zWL = WL_Bath{k}(:);  tWL = WL_Bath_time{k}(:);
        else
            zWL = WL_Bath(:);     tWL = WL_Bath_time(:);
        end
        tV0 = time0{k}(:);  v0 = vel0_da{k}(:);
        twl_num = isdatetime(tWL)*0 + datenum(tWL);   % works for datetime or numeric
        tv0_num = isdatetime(tV0)*0 + datenum(tV0);
        if isdatetime(tWL), twl_num = datenum(tWL); else, twl_num = tWL; end
        if isdatetime(tV0), tv0_num = datenum(tV0); else, tv0_num = tV0; end
        validWL = ~isnan(zWL) & ~isnan(twl_num);
        if sum(validWL) >= 2
            z0_at_v = interp1(twl_num(validWL), zWL(validWL), tv0_num, 'linear', NaN);
            valid0  = ~isnan(z0_at_v) & ~isnan(v0);
        end
    end

    % --- Prepare T1 data ---
    v1 = []; z1_at_v = []; valid1 = false(0);
    if exist('WL_Bath1','var') && exist('WL_Bath_time1','var') && ...
            ~isempty(time1{k}) && ~isempty(vel1_da{k})
        if iscell(WL_Bath1) && numel(WL_Bath1) >= k
            zWL1 = WL_Bath1{k}(:);  tWL1 = WL_Bath_time1{k}(:);
        else
            zWL1 = WL_Bath1(:);     tWL1 = WL_Bath_time1(:);
        end
        tV1 = time1{k}(:);  v1 = vel1_da{k}(:);
        if isdatetime(tWL1), twl1_num = datenum(tWL1); else, twl1_num = tWL1; end
        if isdatetime(tV1),  tv1_num  = datenum(tV1);  else, tv1_num  = tV1;  end
        validWL1 = ~isnan(zWL1) & ~isnan(twl1_num);
        if sum(validWL1) >= 2
            z1_at_v = interp1(twl1_num(validWL1), zWL1(validWL1), tv1_num, 'linear', NaN);
            valid1  = ~isnan(z1_at_v) & ~isnan(v1);
        end
    end

    % --- Open tile ---
    ax = nexttile(t, tileNo);
    hold(ax, 'on');

    % --- Plot T0 ---
    if any(valid0)
        v0r = v0(valid0);  z0r = z0_at_v(valid0);
        v0_eb_pct = NaN(numel(z_centers), nPct);
        v0_fl_pct = NaN(numel(z_centers), nPct);
        for b = 1:numel(z_centers)
            idx_bin = z0r >= z_edges(b) & z0r < z_edges(b+1);
            if any(idx_bin)
                vb = v0r(idx_bin);
                ve = vb(vb <  0);  if ~isempty(ve), v0_eb_pct(b,:) = prctile(ve, pctiles); end
                vf = vb(vb >= 0);  if ~isempty(vf), v0_fl_pct(b,:) = prctile(vf, pctiles); end
            end
        end
        for side = {'eb','fl'}
            if strcmp(side{1},'eb'), pct = v0_eb_pct; else, pct = v0_fl_pct; end
            idx = ~isnan(pct(:,1));
            if any(idx)
                xp = [pct(idx,1); flipud(pct(idx,3))];
                yp = [z_centers(idx)'; flipud(z_centers(idx)')];
                fill(ax, xp, yp, royalBlue, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, pct(idx,2), z_centers(idx), 'LineWidth', 2, 'Color', royalBlue, 'HandleVisibility', 'off');
            end
        end
    end

    % --- Plot T1 ---
    if any(valid1)
        v1r = v1(valid1);  z1r = z1_at_v(valid1);
        v1_eb_pct = NaN(numel(z_centers), nPct);
        v1_fl_pct = NaN(numel(z_centers), nPct);
        for b = 1:numel(z_centers)
            idx_bin = z1r >= z_edges(b) & z1r < z_edges(b+1);
            if any(idx_bin)
                vb = v1r(idx_bin);
                ve = vb(vb <  0);  if ~isempty(ve), v1_eb_pct(b,:) = prctile(ve, pctiles); end
                vf = vb(vb >= 0);  if ~isempty(vf), v1_fl_pct(b,:) = prctile(vf, pctiles); end
            end
        end
        for side = {'eb','fl'}
            if strcmp(side{1},'eb'), pct = v1_eb_pct; else, pct = v1_fl_pct; end
            idx = ~isnan(pct(:,1)) & ~isnan(pct(:,2)) & ~isnan(pct(:,3));
            if any(idx)
                zs  = z_centers(idx);
                xp  = [pct(idx,1); flipud(pct(idx,3))];
                yp  = [zs(:); flipud(zs(:))];
                fill(ax, xp, yp, baseOrange, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
                plot(ax, pct(idx,2), zs, 'LineWidth', 2.5, 'Color', baseOrange, 'HandleVisibility', 'off');
            end
        end
    end

    % --- Formatting ---
    ax.XTick = [-1 0 1];
    ax.XTickLabel = {};
    ax.YTickLabel = {};
    if ismember(tileNo, leftColTiles),  ax.YTickLabelMode = 'auto'; end
    if ismember(tileNo, leftColTiles),  ax.YTickLabelMode = 'auto'; end
    
    % Suppress x labels by default, only show on tiles 18-21
    if ismember(tileNo, [18 19 20 21])
        ax.XTickLabelMode = 'auto';
    else
        ax.XTickLabel = {};
    end
    grid(ax, 'on');
    ax.GridAlpha  = 0.1;
    ax.FontSize   = 11;
    ylim(ax, [-3 4]);
    xlim(ax, [-1.4 1.4]);
    title(ax, stationNames_title{k}, 'Interpreter', 'none', 'FontSize', 11);
    
    xLimits = xlim(ax);  yLimits = ylim(ax);
    xPad = 0.03 * range(xLimits);  yPad = 0.02 * range(yLimits);
    text(ax, xLimits(1)+xPad, yLimits(1)+yPad, 'ebb',   'HorizontalAlignment','left',  'VerticalAlignment','bottom','FontSize',10,'FontWeight','bold','Color',[0.7 0.7 0.7]);
    text(ax, xLimits(2)-xPad, yLimits(1)+yPad, 'flood', 'HorizontalAlignment','right', 'VerticalAlignment','bottom','FontSize',10,'FontWeight','bold','Color',[0.7 0.7 0.7]);
    line(ax, [0 0], [-3 4], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off');

    % --- Groynes ---
    if isKey(groyneData, int32(k))
        gd = groyneData(int32(k));  % 2x2: row1=left [bot top], row2=right [bot top]
        rw = rect_width_frac * range(xLimits);
        xl = xLimits(1);  xr = xLimits(2);
        ym = yLimits(1);  yx = yLimits(2);

        % Left groyne
        yb = max(min(gd(1,1), yx), ym);
        yt = max(min(gd(1,2), yx), ym);
        if yt > yb
            fill(ax, [xl xl xl+rw xl+rw], [yb yt yt yb], rect_color, ...
                'FaceAlpha', rect_alpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        end

        % Right groyne (only if not NaN)
        if ~isnan(gd(2,1))
            yb2 = max(min(gd(2,1), yx), ym);
            yt2 = max(min(gd(2,2), yx), ym);
            if yt2 > yb2
                fill(ax, [xr-rw xr-rw xr xr], [yb2 yt2 yt2 yb2], rect_color, ...
                    'FaceAlpha', rect_alpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            end
        end
    end
end

% -----------------------------------------------------------------------
% Legend in tile 3
% -----------------------------------------------------------------------
axLeg = nexttile(t, 23);
axis(axLeg, 'off');

hT0_med   = line(axLeg, nan, nan, 'LineWidth', 2.5, 'Color', royalBlue);
hT1_med   = line(axLeg, nan, nan, 'LineWidth', 2.5, 'Color', baseOrange);
hT0_patch = patch(axLeg, nan(1,4), nan(1,4), royalBlue,   'FaceAlpha', 0.5, 'EdgeColor', 'none');
hT1_patch = patch(axLeg, nan(1,4), nan(1,4), baseOrange,  'FaceAlpha', 0.4, 'EdgeColor', 'none');
hGr_patch = patch(axLeg, nan(1,4), nan(1,4), rect_color,  'FaceAlpha', rect_alpha, 'EdgeColor', 'none');

legend(axLeg, [hT0_med, hT1_med, hT0_patch, hT1_patch, hGr_patch], ...
    {'T0 - median','T1 - median','T0 - 95% interval','T1 - 95% interval','Groynes'}, ...
    'Location', 'west', 'FontSize', 11, 'Box', 'off');

% -----------------------------------------------------------------------
% Group labels as text annotations on the figure
% Drawn by converting tile positions to figure-normalized coordinates
% -----------------------------------------------------------------------
drawnow;  % ensure tile positions are computed

groupTileRanges = {
    'Channel',  [1  2];
    'Low Flats', [5  15];
    'High Flats',[17 21];
};

labelColor = [0.2 0.2 0.2];

for g = 1:size(groupTileRanges, 1)
    label     = groupTileRanges{g,1};
    tileRange = groupTileRanges{g,2};

    % Get position of first and last tile in group
    axFirst = nexttile(t, tileRange(1));
    axLast  = nexttile(t, tileRange(2));

    posFirst = axFirst.Position;  % [left bottom width height] in normalized fig units
    posLast  = axLast.Position;

    % Label x: left edge of first tile in group
    % Label y: top edge of first tile + small offset
    xLabel = posFirst(1)-0.03;
    yLabel = posFirst(2) + posFirst(4) + 0.010;

    % Width spans from left of first to right of last tile in same row
    wLabel = (posLast(1) + posLast(3)) - posFirst(1);

    annotation(fig, 'textbox', [xLabel, yLabel, wLabel, 0.02], ...
        'String', label, ...
        'FontSize', 12, ...
        'FontAngle', 'italic', ...
        'Color', labelColor, ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'bottom', ...
        'FitBoxToText', 'off', ...
        'Interpreter', 'none');
end

% -----------------------------------------------------------------------
% Final tightening
% -----------------------------------------------------------------------
t.Padding     = 'compact';
t.TileSpacing = 'compact';

%% export figure
outDir = 'P:\11207654-internship-pierce-2026\04_Scripts\HWvsU\Figures_DP';
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
fname = fullfile(outDir, sprintf('Bath_VelvsWL_wgroynes2.png'));
exportgraphics(gcf, fname, 'Resolution', 300);
