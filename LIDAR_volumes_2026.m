clear all
close all
clc

%% View LIDAR elevations over defined area
% Denise Pierce

%% folder of LIDAR data
% Model directories
folders = {'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\'};

%% box of interest (already defined above in main file, but keep for safety)
% XLIM = [70000 728000]; %Bath Limits 
% YLIM = [378500 387000];
% XLIM = [72250 72200]; % South East Bath
% YLIM = [379950 379850];

% Define rectangle corners (ensure they form a closed polygon) and plot over the GeoTIFF
% corner1 = [70706.4537, 379893.6965]; %long skinny Bath 0403
% corner2 = [70809.6617, 379922.9952];
% corner3 = [71014.03,    379492.67];
% corner4 = [70936.18929, 379449.49614];

% corner1 = [72304.56, 380388.61]; %Long skinny Bath 0903
% corner2 = [72424.47, 380339.91];
% corner3 = [72366.847, 379757.532];
% corner4 = [72235.097, 379762.457];

% name = ('Bath 0202');
% corner1 = [70370.499,379056.789]; %Bath 0202
% corner2 = [70255.774,379245.958];
% corner3 = [70473.010,379443.511];
% corner4 = [70615.055,379230.635];
 
% name = ('Bath 0302');
% corner1 = [70488.718,379451.509]; %Bath 0302
% corner2 = [70718.457,379628.921];
% corner3 = [70845.566,379428.453];
% corner4 = [70622.523,379256.631];

% name = ('Bath 0402');
% corner1 = [70730.74,379637.18]; %Bath 0402
% corner2 = [71019.508,379667.782];
% corner3 = [71083.255,379536.674];
% corner4 = [70884.305,379399.591];

% name = ('Bath 0502');
% corner1 = [71100.38707048306	379555.83419030195]; %Bath 0502
% corner2 = [71035.78963244798	379678.5403741238];
% corner3 = [71305.17316714258	379820.4736343392];
% corner4 = [71362.69607763714	379661.1525125999	];

% name = ('Bath 0602');
% corner1 = [71375.07591450009	379664.5614531853]; %Bath 0602
% corner2 = [71312.06877932885	379822.48243011953	];
% corner3 = [71617.04012666359	379909.30261352175	];
% corner4 = [71658.73565479463	379760.19120750343];

% name = ('Bath 0702');
% corner1 = [71885.56,379934.09]; %Bath 0702
% corner2 = [71895.25,379788.76];
% corner3 = [71681.75,379750.01];
% corner4 = [71637.25,379915.43];

% name = ('Bath 0802');
% corner1 = [71902.79,379934.09]; %Bath 0802
% corner2 = [72133.88,379947.73];
% corner3 = [72109.48,379787.33];
% corner4 = [71913.91,379790.92];

% name = ('Bath 0902');
% corner1 = [72154.78,379944.50]; %Bath 0902
% corner2 = [72472.71,379941.99];
% corner3 = [72442.21,379759.34];
% corner4 = [72129.30,379782.66];

% name = ('Bath Foreshore Marsh');
% corner1 = [72178.32705152518	380372.46422464197	]; %Bath foreshore salt marsh
% corner2 = [72443.87660687757	380324.71189231984	];
% corner3 = [72575.48669352153	380139.5260181925	];
% corner4 = [72148.04508468675	380301.4180716749	];

name = ('Zimm Foreshore Marsh');
corner1 = [65958.29459380824	379990.44556606485	]; %Zimm foreshore salt marsh
corner2 = [65935.0007731633	379932.2110144525	];
corner3 = [66508.02876102898	379896.1055924528	];
corner4 = [66519.67567135146	379935.7050875492];

% name = ('Zimmerman 0104');
% corner1 = [66437.30392180725	379626.64582702576]; %Zimm 0104
% corner2 = [65788.80861022294	379589.88900774566	];
% corner3 = [65967.34173244049	380020.4688907409	];
% corner4 = [66521.31950873316	379939.0787909064	];

% name = ('Zimmerman 0304');
% corner1 = [66476.68622817876	379637.14777539147	]; %Zimm 0304
% corner2 = [66543.63614901034	379918.07489417493	];
% corner3 = [67075.29728502582	379769.7348735089	];
% corner4 = [67056.91887538577	379725.10159295454	];

% name = ('Waarde East');
% corner1 = [64942.08902323533	380437.92133827903	]; %Waarde/Zimm between two groynes built in 2002
% corner2 = [65931.8976567061	    380029.65809556097	];
% corner3 = [65733.67338130281	379542.63024009985	];
% corner4 = [64754.366696197765	379983.71207146085  ];

% name = ('Waarde West');
% corner1 = [64724.17359464627	379999.46499400947	]; %Zimm west of groynes. confined by dike
% corner2 = [64020.54305414184	380629.5818959537];
% corner3 = [64075.67828306196	380710.97199578816	];
% corner4 = [64918.45963941242	380451.04877373617];

% Create polygon vertices in order and close the polygon by repeating the first vertex
polyXY = [corner1; corner2; corner3; corner4; corner1];
xv = polyXY(:,1);
yv = polyXY(:,2);

poly_closed = [polyXY; polyXY(1,:)];

x_poly = poly_closed(:,1);
y_poly = poly_closed(:,2);
% Compute polygon area using shoelace formula (signed area)
area_box = 0.5 * abs( sum( x_poly(1:end-1).*y_poly(2:end) - x_poly(2:end).*y_poly(1:end-1) ) );
fprintf('Area of polygon (polyXY): %.1f m^2\n', area_box);

%% import tif aerial and visualize polygon
% Import the specified GeoTIFF and display it with mapshow (or imshow if mapshow unavailable)
% tifpath = 'p:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Aerial_pictures\aerial_collage\2024_072000_Bath4.tif';
% [A_tif, R_tif] = readgeoraster(tifpath);
% 
% % Overlay polygon on GeoTIFF
% figure('Name', sprintf('%s AOI', name),'NumberTitle','off');
% mapshow(A_tif, R_tif); 
% hold on;
% plot(xv, yv, 'y-', 'LineWidth', 2);
% title('Aerial with box of interest');
% hold off;

%% import based on box area
% Loop over all folders and all .tif files, read a window covering the polygon defined by corner1-4
files_all = [];
for f = 1:numel(folders)
    files = dir(fullfile(folders{f}, '*.tif'));
    for k = 1:numel(files)
        files_all(end+1).folder = files(k).folder; %#ok<SAGROW>
        files_all(end).name = files(k).name;
    end
end

nFiles = numel(files_all);
A_sub_all = cell(nFiles,1);
R_sub_all = cell(nFiles,1);
file_paths = cell(nFiles,1);

% define polygon from provided corners (ensure closed polygon)
polyX = [corner1(1), corner2(1), corner3(1), corner4(1)];
polyY = [corner1(2), corner2(2), corner3(2), corner4(2)];
% ensure polygon is closed for any functions that expect it
if polyX(1) ~= polyX(end) || polyY(1) ~= polyY(end)
    polyX(end+1) = polyX(1); 
    polyY(end+1) = polyY(1); 
end

% compute polygon bounding box (world coordinates) to limit reads
xMin = min(polyX); xMax = max(polyX);
yMin = min(polyY); yMax = max(polyY);

for idx = 1:nFiles
    fname = fullfile(files_all(idx).folder, files_all(idx).name);
    file_paths{idx} = fname;
    try
        [A, R] = readgeoraster(fname);
    catch 
        try
            A = imread(fname);
            info = imfinfo(fname);
            if isfield(info(1), 'GeoTIFFTags') && ~isempty(info(1).GeoTIFFTags)
                % best-effort: construct referencing from geo tags not implemented here
                R = georasterref('RasterSize', size(A(:,:,1)), ...
                    'XWorldLimits', [], 'YWorldLimits', []); 
            else
                R = georasterref('RasterSize', size(A(:,:,1)), ...
                    'XWorldLimits', [0 size(A,2)], 'YWorldLimits', [0 size(A,1)]);
            end
        catch
            A_sub_all{idx} = [];
            R_sub_all{idx} = [];
            continue
        end
    end

    % Map polygon bounding box to intrinsic pixel coordinates
    try
        [cols, rows] = worldToIntrinsic(R, [xMin, xMax], [yMin, yMax]);
        cmin = max(1, floor(min(cols)));
        cmax = min(size(A,2), ceil(max(cols)));
        rmin = max(1, floor(min(rows)));
        rmax = min(size(A,1), ceil(max(rows)));
    catch
        % fallback to image center if mapping fails
        cmin = 1; cmax = min(3, size(A,2));
        rmin = 1; rmax = min(3, size(A,1));
    end

    % read just that region if possible
    try
        Z = readgeoraster(fname, 'PixelRegion', {[rmin rmax], [cmin cmax]});
    catch
        Z = A(rmin:rmax, cmin:cmax, :);
    end

    % store cropped array and updated referencing
    A_sub_all{idx} = Z;
    R_sub = R;
    R_sub.RasterSize = [size(Z,1), size(Z,2)];
    % compute accurate world limits for the cropped region if possible
    try
        % intrinsicToWorld expects vectors of column and row indices;
        % use the edges of the cropped region
        [x_edge1, y_edge1] = intrinsicToWorld(R, cmin, rmin);
        [x_edge2, y_edge2] = intrinsicToWorld(R, cmax, rmax);
        R_sub.XWorldLimits = [min(x_edge1,x_edge2), max(x_edge1,x_edge2)];
        R_sub.YWorldLimits = [min(y_edge1,y_edge2), max(y_edge1,y_edge2)];
    catch
        % leave R_sub as-is if conversion fails
    end

    % Additionally, create a mask for the polygon within the cropped region and store it
    try
        % build grid of world coordinates for each pixel center in the cropped Z
        [nR, nC, ~] = size(Z);
        % compute intrinsic coordinates for pixel centers in the cropped window
        cols_grid = (cmin:cmax);
        rows_grid = (rmin:rmax);
        [xv, yv] = intrinsicToWorld(R, cols_grid, rows_grid);
        % intrinsicToWorld with vector inputs returns vectors; make grids
        [Xg, Yg] = meshgrid(xv, yv);
        mask = inpolygon(Xg, Yg, polyX, polyY);
        % store mask alongside R_sub (as a custom field) for downstream use
        R_sub.PolygonMask = mask;
    catch
        % if any step fails, do not attach mask
    end

    R_sub_all{idx} = R_sub;
end

% If there are exactly 20 tiffs as requested, keep only first 20 (or warn)
if nFiles ~= 20
    warning('Found %d TIFF files; expected 20. Proceeding with found files.', nFiles);
end

% %% Load LIDAR 
% % Structure to hold yearly elevations per site: fields .year (Nx1) and .z (Nx1) and .file
% nSites = 1
% LIDAR_yearly = cell(nSites,1);
% 
% % regex to find a 4-digit year in filename
% yearPattern = '(19|20)\d{2}';
% 
% for s = 1:nSites
%     yrList = [];
%     zList = [];
%     fList = {};
%     % Define site box from XLIM/YLIM for site s
%     xBox = XLIM; 
%     yBox = YLIM;
%     if numel(XLIM) == nSites && numel(YLIM) == nSites
%         % if XLIM/YLIM were provided per-site as [x] scalars or [xMin xMax] vectors
%         xEntry = XLIM(s);
%         yEntry = YLIM(s);
%         if isscalar(xEntry) && isscalar(yEntry)
%             % fall back to small box around point
%             xBox = [xEntry-0.5, xEntry+0.5];
%             yBox = [yEntry-0.5, yEntry+0.5];
%         else
%             % use per-site box if given as two-element vectors per site are not supported;
%             % keep using the global XLIM/YLIM below
%             xBox = XLIM;
%             yBox = YLIM;
%         end
%     end
% 
%     % Use the provided global XLIM/YLIM as the area of interest
%     xMin = min(XLIM); xMax = max(XLIM);
%     yMin = min(YLIM); yMax = max(YLIM);
% 
%     % Compute a representative point (center) for pixel extraction, but also store box
%     x0 = (xMin + xMax) / 2;
%     y0 = (yMin + yMax) / 2;
% 
%     % Save the box for downstream use (keeps compatibility with code expecting XLIM/YLIM per-site)
%     siteBox{s} = struct('xlim',[xMin xMax],'ylim',[yMin yMax]); %#ok<SAGROW>
%     for f = 1:numel(folders)
%         folder = folders{f};
%         files = dir(fullfile(folder, '*.tif'));
%         for k = 1:numel(files)
%             fname = fullfile(folder, files(k).name);
%             % determine year from filename if possible
%             tok = regexp(files(k).name, yearPattern, 'match');
%             if ~isempty(tok)
%                 yr = str2double(tok{1});
%             else
%                 % fallback to file datenum year
%                 yr = year(files(k).datenum);
%             end
%             % skip if we already have a valid value for this year
%             if any(yrList==yr)
%                 continue
%             end
%             % try to read georaster info to map world to pixel
%             try
%                 info = georasterinfo(fname);
%                 R = info.RasterReference;
%             catch
%                 % unreadable file, skip
%                 continue
%             end
%             % get intrinsic coordinate for the exact site coordinate (closest pixel)
%             try
%                 [col, row] = worldToIntrinsic(R, x0, y0);
%             catch
%                 continue
%             end
%             col = round(col);
%             row = rounFd(row);
%             % clamp to raster size
%             if row < 1 || row > R.RasterSize(1) || col < 1 || col > R.RasterSize(2)
%                 % site outside this raster
%                 continue
%             end
%             % read that single pixel
%             try
%                 Zpix = readgeoraster(fname, 'PixelRegion', {[row row], [col col]});
%             catch
%                 try
%                     Zpix = imread(fname, 'PixelRegion', {[row row], [col col]});
%                 catch
%                     continue
%                 end
%             end
%             % Zpix may be array with band dimension; take first band and scalar value
%             if isempty(Zpix), continue; end
%             zval = double(Zpix(1));
%             % filter out nodata / extreme values and require -10 <= z <= 20
%             if ~isfinite(zval) || abs(zval) > 1e6
%                 continue
%             end
%             if zval < -10 || zval > 20
%                 continue
%             end
%             % accept this year's value
%             yrList(end+1,1) = yr; %#ok<AGROW>
%             zList(end+1,1) = zval; %#ok<AGROW>
%             fList{end+1,1} = fname; %#ok<AGROW>
%         end
%     end
%     % sort by year
%     if ~isempty(yrList)
%         [yrSorted, idx] = sort(yrList);
%         LIDAR_yearly{s} = struct('year', yrSorted, 'z', zList(idx), 'file', {fList(idx)});
%     else
%         LIDAR_yearly{s} = []; % no valid yearly data
%     end
% end
% 
% % Make LIDAR_yearly available as LIDAR_sub minimal summary as well
% % (so downstream code can still reference LIDAR_sub if needed)
% for s = 1:nSites
%     if isempty(LIDAR_yearly{s})
%         LIDAR_sub{s} = []; %#ok<SAGROW>
%     else
%         % store a compact struct per site containing yearly values
%         LIDAR_sub{s} = struct('yearly', LIDAR_yearly{s});
%     end
% end

%% Average Bed level
yearPattern = '(19|20)\d{2}';

bedLevel_file = nan(nFiles,1);
fileYear = nan(nFiles,1);

for idx = 1:nFiles
    Z = A_sub_all{idx};
    if isempty(Z)
        continue
    end
    Zband = double(Z(:,:,1));

    if isfield(R_sub_all{idx}, 'PolygonMask') && isequal(size(R_sub_all{idx}.PolygonMask), size(Zband))
        vals = Zband(R_sub_all{idx}.PolygonMask);
    else
        vals = Zband(:);
    end

    bedLevel_file(idx) = mean(vals, 'omitnan');

    % tok = regexp(file_paths{idx}, yearPattern, 'match');
    % if ~isempty(tok)
    %     fileYear(idx) = str2double(tok{1});
    % end
end


% Map file-level bed levels onto the requested years (this is the missing step)
years_req = 2016:2026;
years_req(ismember(years_req,[2023, 2024])) = [];

% Plot bed level time series
figure('Name', sprintf('%s Average Bed Level', name), 'NumberTitle','off');
plot(years_req, bedLevel_file, '-', 'LineWidth', 2, ...
    'MarkerFaceColor',[0.2 0.6 0.8], 'MarkerEdgeColor','k', 'Color',[0.2 0.6 0.8]);
grid on;
xlabel('Year','FontSize',16,'FontWeight','bold');
ylabel('Average Bed Level [m NAP]','FontSize',16,'FontWeight','bold');
title(sprintf('%s: Average Bed Level Over Time', name), 'FontSize', 20);
xticks(years_req);
box on;


%% Volume of box
% Calculate volume of box for years 2016-2025 excluding 2024
years_req = 2016:2026;
% remove years 2023 and 2024 from requested years
years_req(ismember(years_req,[2023, 2024])) = [];
% years_req = 2016:2025;
% years_req(years_req==2024) = [];

% Define vertical limits: bottom fixed at -3 m; top is per-pixel LIDAR elevation (z_bed)
z_bottom = -3; % m (fixed)
% Prepare results
nYears = numel(years_req);
vol_year = nan(nYears,1);

nFilesAll = numel(A_sub_all);
fileYears = nan(nFilesAll,1);
for i = 1:nFilesAll
    fileYears(i) = NaN; %#ok<NASGU>
end
% Try to extract year from R_sub_all metadata if present
for i = 1:nFilesAll
    try
        fn = R_sub_all{i}.Filename; %#ok<NODEF>
    catch
        fn = '';
    end
    if isempty(fn) && exist('file_list','var') && numel(file_list)>=i
        fn = file_list{i};
    end
    if ~isempty(fn) && ischar(fn)
        tok = regexp(fn, '(19|20)\d{2}', 'match');
        if ~isempty(tok)
            fileYears(i) = str2double(tok{1});
        else
            fileYears(i) = NaN;
        end
    else
        fileYears(i) = NaN;
    end
end

% If no filename years found, try to use ordering: assume A_sub_all corresponds to years_req in order (best-effort)
if all(isnan(fileYears))
    for yi = 1:nYears
        % pick index if available
        idx = yi;
        if idx <= nFilesAll && ~isempty(A_sub_all{idx})
            Z = A_sub_all{idx};
            % compute mean elevation over box ignoring NaNs
            zmean = mean(Z(:),'omitnan');
            vol_year(yi) = (zmean - z_bottom) * area_box;
        else
            vol_year(yi) = NaN;
        end
    end
else
    % Map each requested year to the matching file (if multiple match, average them)
    for yi = 1:nYears
        y = years_req(yi);
        idxs = find(fileYears==y);
        if isempty(idxs)
            vol_year(yi) = NaN;
            continue
        end
        zmeans = nan(numel(idxs),1);
        for k = 1:numel(idxs)
            Z = A_sub_all{idxs(k)};
            if isempty(Z)
                zmeans(k) = NaN;
            else
                zmeans(k) = mean(Z(:),'omitnan');
            end
        end
        zmean_all = mean(zmeans,'omitnan');
        if isempty(zmean_all) || ~isfinite(zmean_all)
            vol_year(yi) = NaN;
        else
            vol_year(yi) = (zmean_all - z_bottom) * area_box;
        end
    end
end

%% Plotting histogram of volumes
% Prepare year labels and clean vol array for plotting
% Prepare data for plotting: normalize so 2016 == 1
yrs_plot = years_req;
vol_plot = vol_year;

% % Subtract 0.05 * area_box from the 2023 entry only (if present)
% idx2023 = find(yrs_plot == 2023, 1);
% if ~isempty(idx2023) && numel(vol_plot) >= idx2023 && ~isnan(vol_plot(idx2023))
%     vol_plot(idx2023) = vol_plot(idx2023) - 0.075 * area_box;
% end

% Find index of 2016 in yrs_plot
idx2016 = find(yrs_plot == 2016, 1);
if isempty(idx2016) || isnan(vol_plot(idx2016)) || vol_plot(idx2016) == 0
    % Cannot normalize by 2016 (missing or zero) -> leave as-is and warn
    warning('Volume for 2016 is missing or zero. Skipping normalization.');
    norm_factor = 1;
else
    norm_factor = vol_plot(idx2016);
end
% Apply normalization (preserve NaNs)
vol_plot = vol_plot ./ norm_factor;

% Define error bars scaled accordingly (same relative fraction of area_box)
error_bars = 0.05 * area_box / norm_factor; %5 cm resolution with LIDAR 

% Create figure and histogram-like bar plot showing normalized volume per year
fh = figure('Name', sprintf('%s Normalized Volumes', name), 'NumberTitle','off');
hold on;
b = bar(1:numel(yrs_plot), vol_plot, 0.7, 'FaceColor',[0.2 0.6 0.8], 'EdgeColor','k');


%groynes built year
% Annotate groynes built between 2020 and 2021 (place a vertical label between bars for 2020 and 2021)
pos2020 = find(yrs_plot == 2020, 1);
pos2021 = find(yrs_plot == 2021, 1);
if ~isempty(pos2020) && ~isempty(pos2021)
    % place annotation midway between the two x positions, slightly above the top of the bars
    xmid = pos2021;
    % compute y position: use current ymax (after bar plotted) or fallback
    ax = gca;
    yrange = ylim(ax);
    ytext = yrange(2) * 0.98;
    % draw a vertical dashed line between the two bars
    line([xmid xmid], [yrange(1) yrange(2)*1.2], 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 1);
    % add text label rotated vertically
text(xmid-0.1, ytext-0.1, 'Groynes built', 'HorizontalAlignment','center', 'VerticalAlignment','bottom', ...
    'Color',[0.5 0.5 0.5], 'FontWeight','bold', 'Rotation', 90, 'FontSize', 18);
end

% Plot error bars for each non-NaN volume value
xpos = 1:numel(yrs_plot);
valid = ~isnan(vol_plot);
if any(valid)
    y = vol_plot(valid);
    xe = xpos(valid);
    errorbar(xe, y, repmat(error_bars, size(y)), repmat(error_bars, size(y)), ...
        'k', 'LineStyle','none', 'LineWidth', 1, 'CapSize', 10);
    legend_errbar  = errorbar(xe, y, repmat(error_bars, size(y)), repmat(error_bars, size(y)), ...
        'k', 'LineStyle','none', 'LineWidth', 1, 'CapSize', 10);
end

% Mark NaNs with cross markers at zero height
nanIdx = isnan(vol_plot);
if any(nanIdx)
    scatter(find(nanIdx), zeros(sum(nanIdx),1), 60, 'xk', 'LineWidth',1.5);
end

xlim([0.5, numel(yrs_plot)+0.5]);
% set y-limits based on min/max of vol_plot (ignore NaNs) with a small margin
vmin = min(vol_plot(~isnan(vol_plot)));
vmax = max(vol_plot(~isnan(vol_plot)));
if isempty(vmin) || isempty(vmax)
    ylim([0,1]);
else
    ylim([max(0,0.95*vmin), vmax*1.05]);
end
xticks(1:numel(yrs_plot));
xticklabels(string(yrs_plot));
xlabel('Year','FontSize',22,'FontWeight','bold');
ylabel('Sediment Volume [-]','FontSize',22,'FontWeight','bold');
set(gca,'FontSize',22);
title(sprintf('%s: Volume by Year', name), 'FontSize', 28);
% enable only horizontal grid lines (y-grid) without vertical grid lines
ax = gca;
grid(ax, 'on');
% turn off vertical grid lines by setting GridLineStyle for XGrid to 'off'
ax.XGrid = 'off';
ax.YGrid = 'on';
box on;
hold off;

% legend
hLegend = legend([b, legend_errbar], {'Volume', 'Error (±5 cm)'}, 'Location', 'best');
set(hLegend, 'FontSize', 24);

%% export
% outDir = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes';
% if ~exist(outDir, 'dir')
%     try
%         mkdir(outDir);
%     catch
%         warning('Could not create output directory: %s', outDir);
%     end
% end
% % Export figure fh to PNG with a safe filename
% if ishandle(fh)
%     figName = get(fh, 'Name');
%     if isempty(figName)
%         figName = 'figure';
%     end
%     % sanitize filename
%     figName = regexprep(figName, '[<>:"/\\|?*]', '_');
%     % timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
%     filename = fullfile(outDir, sprintf('%s_2016-2026.png', figName));
%     try
%         exportgraphics(fh, filename, 'BackgroundColor', 'white', 'Resolution', 150);
%     catch ME
%         warning('Failed to export figure to PNG: %s\n%s', filename, ME.message);
%     end
% end

% %% --subplot Lunar Nodal Tide Cycle and volume graph ----
% 
% % Create a single figure and use a 2-row subplot layout so both plots appear
% % together in the same figure (top: volumes, bottom: lunar nodal cycle)
% fh = figure('Name', sprintf('%s: Lunar Nodal Cycle Effect', name), 'NumberTitle','off');
% 
% % Top: Normalized Volumes
% subplot(2,1,1);
% hold on;
% b = bar(1:numel(yrs_plot), vol_plot, 0.7, 'FaceColor',[0.2 0.6 0.8], 'EdgeColor','k');
% 
% % groynes built year annotation between 2020 and 2021 (if present)
% pos2020 = find(yrs_plot == 2020, 1);
% pos2021 = find(yrs_plot == 2021, 1);
% if ~isempty(pos2020) && ~isempty(pos2021)
%     xmid = (pos2020 + pos2021) / 2;
%     ax = gca;
%     yrange = ylim(ax);
%     ytext = yrange(2) * 0.98;
%     line([xmid xmid], [yrange(1) yrange(2)*1.2], 'Color', [0.8 0 0], 'LineStyle', '--', 'LineWidth', 1);
%     text(xmid, ytext, 'Groynes built', 'HorizontalAlignment','center', 'VerticalAlignment','bottom', ...
%         'Color',[0.8 0 0], 'FontWeight','bold', 'Rotation', 0);
% end
% 
% % Plot error bars for each non-NaN volume value
% xpos = 1:numel(yrs_plot);
% valid = ~isnan(vol_plot);
% if any(valid)
%     y = vol_plot(valid);
%     xe = xpos(valid);
%     errorbar(xe, y, repmat(error_bars, size(y)), repmat(error_bars, size(y)), ...
%         'k', 'LineStyle','none', 'LineWidth', 1, 'CapSize', 10);
% end
% 
% % Mark NaNs with cross markers at zero height
% nanIdx = isnan(vol_plot);
% if any(nanIdx)
%     scatter(find(nanIdx), zeros(sum(nanIdx),1), 60, 'xk', 'LineWidth',1.5);
% end
% 
% xlim([0.5, numel(yrs_plot)+0.5]);
% % set y-limits based on min/max of vol_plot (ignore NaNs) with a small margin
% valid_vals = vol_plot(~isnan(vol_plot));
% if isempty(valid_vals)
%     ylim([0,1]);
% else
%     vmin = min(valid_vals);
%     vmax = max(valid_vals);
%     ylim([max(0,0.95*vmin), vmax*1.05]);
% end
% xticks(1:numel(yrs_plot));
% xticklabels(string(yrs_plot));
% xlabel('Year');
% ylabel('Normalized Volume (2016 = 1)');
% title(sprintf('%s: Normalized Volume by Year', name));
% grid on;
% box on;
% hold off;
% 
% % Bottom: Lunar Nodal Cycle (placed in same figure)
% subplot(2,1,2);
% t = 1990:0.01:2040;              % time vector from 1990 to 2040 (years)
% period = 18.61;                  % years
% % Preserve the original phase relative to the previous start (2001.80)
% % Compute wt so that wt at t=2001.80 equals original wt(1)=0:
% t_ref = 2001.80;
% wt = 2*pi*(t - t_ref)/period;    % angular argument with same phase reference
% LNC = sin(wt);                   % sine wave amplitude 1
% 
% plot(t, LNC, 'b-', 'LineWidth', 3, 'DisplayName', 'Lunar Nodal Cycle');
% hold on;
% % Sedimentation signal 1/4 period (phase) behind LNC: shift time by +period/4
% t_shift = t + period/4;
% plot(t_shift, LNC, 'r-', 'LineWidth', 2, 'DisplayName', 'Sedimentation');
% legend('Location','best');
% hold off;
% xlabel('Year');
% ylabel('Amplitude');
% title('Lunar Nodal Cycle (18.6-year sine wave)');
% xlim([2005.5, 2024.5]);
% xticks_years = 2002:2:2030;
% set(gca, 'XTick', xticks_years);
% xtickformat('%.0f');
% grid on;

% %%===== IGNORE======
% % %% import all tiffs in folder 
% % folder = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Aerial_pictures\aerial_collage'
% % 
% % % List all .tif/.tiff files in the folder
% % tifFiles = dir(fullfile(folder, '*.tif'));
% % tifFiles = [tifFiles; dir(fullfile(folder, '*.tiff'))]; % include .tiff
% % 
% % if isempty(tifFiles)
% %     warning('No TIFF files found in folder: %s', folder);
% % else
% %     nFiles = numel(tifFiles);
% %     A_sub_all = cell(nFiles,1);
% %     R_sub_all = cell(nFiles,1);
% %     figure('Name','All aerial TIFFs','NumberTitle','off');
% %     % Display in tiled layout if available
% %     try
% %         t = tiledlayout(ceil(sqrt(nFiles)), ceil(sqrt(nFiles)), 'TileSpacing','compact');
% %     catch
% %         t = [];
% %     end
% %     for k = 1:nFiles
% %         fp = fullfile(folder, tifFiles(k).name);
% %         try
% %             [A, R] = readgeoraster(fp);
% %         catch ME
% %             warning('Failed to read %s: %s', fp, ME.message);
% %             A = [];
% %             R = [];
% %         end
% %         A_sub_all{k} = A;
% %         R_sub_all{k} = R;
% %         % Show each raster
% %         if isempty(A)
% %             continue;
% %         end
% %         if ~isempty(t)
% %             nexttile;
% %         else
% %             subplot(ceil(sqrt(nFiles)), ceil(sqrt(nFiles)), k);
% %         end
% %         try
% %             mapshow(A, R);
% %         catch
% %             imshow(A, []);
% %             axis image;
% %         end
% %         title(tifFiles(k).name, 'Interpreter', 'none', 'FontSize', 8);
% %     end
% % end
% 
% % % nFilesAll = numel(A_sub_all);
% 
% % % calculate area above and below 2025 compared to 2016 using A_sub_all
% % Now expect A_sub_all{4,1} -> 2025 and A_sub_all{5,1} -> 2016
% if numel(A_sub_all) < 5 || isempty(A_sub_all{4}) || isempty(A_sub_all{5})
%     warning('A_sub_all does not contain required entries for 2025 (index 4) and 2016 (index 5). Skipping area calculation.');
% else
%     Z2025 = A_sub_all{4};
%     Z2016 = A_sub_all{5};
%     % Ensure matrices are numeric and same size
%     if ~isnumeric(Z2025) || ~isnumeric(Z2016) || ~isequal(size(Z2025), size(Z2016))
%         warning('Raster arrays for 2025 and 2016 must be numeric and the same size. Skipping area calculation.');
%     else
%         % Compute per-pixel difference: 2025 - 2016
%         dz = double(Z2025) - double(Z2016);
%         % Pixel area from spatial limits and raster resolution: area_box already computed above
%         nPix = numel(dz);
%         if nPix == 0
%             warning('No pixels in selected box.');
%         else
%             pixelArea = area_box / nPix; % m^2 per pixel
%             % Mask finite pixels
%             valid = isfinite(dz);
%             if ~any(valid)
%                 warning('No finite difference values to compute areas.');
%             else
%                 dzv = dz;
%                 dzv(~valid) = 0;
%                 % Total net volume change (sum of dz * pixelArea)
%                 net_volume = sum(dzv(:)) * pixelArea; % m^3 (elevation * m^2)
%                 % Volumes where 2025 is above 2016 (positive dz) and where below (negative dz)
%                 above_mask = dzv > 0;
%                 below_mask = dzv < 0;
%                 vol_above = sum(dzv(above_mask)) * pixelArea; % positive
%                 vol_below = -sum(dzv(below_mask)) * pixelArea; % positive
%                 % Report results
%                 fprintf('Net volume change (2025 - 2016) over box: %.3f m^3\n', net_volume);
%                 fprintf('Volume where 2025 above 2016: %.3f m^3\n', vol_above);
%                 fprintf('Volume where 2025 below 2016: %.3f m^3\n', vol_below);
%                 % Optional visualization: show difference map with diverging colormap
%                 try
%                     figure('Name','Difference 2025 - 2016','NumberTitle','off');
%                     imagesc(dz); axis image; colorbar;
%                     colormap(gca, redbluecmap(256)); % use red/blue diverging map if available
%                     title('Per-pixel elevation difference (2025 - 2016)');
%                 catch
%                     % Fallback plotting without custom colormap
%                     try
%                         figure('Name','Difference 2025 - 2016','NumberTitle','off');
%                         imagesc(dz); axis image; colorbar;
%                         title('Per-pixel elevation difference (2025 - 2016)');
%                     catch
%                         % ignore plotting errors
%                     end
%                 end
%             end
%         end
%     end
% end

%% save vol_plot as .mat
% Prepare target directory
targetDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', 'Topo_Bathy', 'Lidar', 'Volumes', '2016-2026_Bath');
if ~exist(targetDir, 'dir')
    try
        mkdir(targetDir);
    catch
        warning('Could not create target directory: %s', targetDir);
    end
end

% Ensure vol_plot exists
if exist('vol_plot','var')
    % Prepare filename using variable 'name' if available and valid
    if exist('name','var') && ischar(name) && ~isempty(name)
        safeName = regexprep(name, '[^\w\-]', '_'); % sanitize filename
        fname = fullfile(targetDir, sprintf('%s_vol_plot.mat', safeName));
    else
        fname = fullfile(targetDir, 'vol_plot.mat');
    end
    % Save vol_plot and associated variables that are likely useful
    varsToSave = {'vol_plot'};
    if exist('years_req','var'), varsToSave{end+1} = 'years_req'; end
    if exist('bedLevel_file','var'), varsToSave{end+1} = 'bedLevel_file'; end
    if exist('years_log','var'), varsToSave{end+1} = 'years_log'; end
    if exist('y_fit','var'), varsToSave{end+1} = 'y_fit'; end
    try
        save(fname, varsToSave{:});
        fprintf('Saved vol_plot to %s\n', fname);
    catch ME
        warning('Failed to save vol_plot to %s: %s', fname, ME.message);
    end
else
    warning('vol_plot variable does not exist; nothing saved.');
end

% %% fit a logarithmic function to volumes 2020-2025 from histogram plot
% % Ensure positive y for logarithmic model; shift if necessary
% if any(y <= 0)
%     shift = abs(min(y)) + eps;
%     y_shifted = y + shift;
% else
%     shift = 0;
%     y_shifted = y;
% end
% 
% % Fit model y = a + b*log(x)
% X = [ones(size(x(:))) log(x(:))];
% coeff = X \ y_shifted(:);  % [a; b]
% 
% a = coeff(1);
% b = coeff(2);
% 
% % Construct fitted values and optionally plot
% y_fit_shifted = a + b*log(x);
% y_fit = y_fit_shifted - shift;
% 
% % Compute R-squared for the log fit (using original y)
% SS_res = sum((y(:) - y_fit(:)).^2);
% SS_tot = sum((y(:) - mean(y(:))).^2);
% if SS_tot > 0
%     R2 = 1 - SS_res / SS_tot;
% else
%     R2 = NaN; % undefined if no variance in y
% end
% 
% % Store log fit results in workspace variables for later use
% fit_log.a = a;
% fit_log.b = b;
% fit_log.shift = shift;
% fit_log.x = x;
% fit_log.y = y;
% fit_log.y_fit = y_fit;
% fit_log.R2 = R2;
% 
% %% fit a linear model y = m*x + c and report R^2
% % Fit linear model on original data (no log)
% XL = [ones(size(x(:))) x(:)];
% coeff_lin = XL \ y(:); % [c; m]
% c = coeff_lin(1);
% m = coeff_lin(2);
% 
% % Construct linear fitted values
% y_fit_lin = c + m .* x;
% 
% % Compute R-squared for linear fit
% SS_res_lin = sum((y(:) - y_fit_lin(:)).^2);
% if SS_tot > 0
%     R2_lin = 1 - SS_res_lin / SS_tot;
% else
%     R2_lin = NaN;
% end
% 
% % Store linear fit results
% fit_lin.c = c;
% fit_lin.m = m;
% fit_lin.x = x;
% fit_lin.y = y;
% fit_lin.y_fit = y_fit_lin;
% fit_lin.R2 = R2_lin;
% 
% % Attach fit summaries to workspace for later use
% fit_summary.log.R2 = R2;
% fit_summary.log.coeffs = [a; b];
% fit_summary.lin.R2 = R2_lin;
% fit_summary.lin.coeffs = [c; m];
% 
% % Display brief fit results to command window
% fprintf('Log fit R^2 = %.4f\n', R2_log);
% fprintf('Linear fit R^2 = %.4f\n', R2_lin);

% % Save fit_log struct to a .mat file in the requested folder
% targetDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', 'Topo_Bathy', 'Lidar', 'Volumes', '2016-2025', 'log_fits');
% if ~exist(targetDir, 'dir')
%     % try to create the directory, but don't error if it fails
%     try
%         mkdir(targetDir);
%     catch
%         warning('Could not create target directory: %s', targetDir);
%     end
% end
% 
% if exist('name','var') && ischar(name) && ~isempty(name)
%     fname = fullfile(targetDir, sprintf('%s_fit_log.mat', name));
% else
%     fname = fullfile(targetDir, 'fit_log.mat');
% end

% % Plot data and fit if plotting is available
% figure('Name','Logarithmic fit 2020-2025','NumberTitle','off');
% hold on;
% plot(years_log, y, 'o', 'MarkerFaceColor','b');
% plot(years_log, y_fit, '-r', 'LineWidth', 1.5);
% % Display R^2 on the plot
% txt = sprintf('R^2 = %.3f', fit_log.R2);
% 
% % Place text at upper-left corner of axes with some padding
% ax = gca;
% xlim_vec = xlim(ax);
% ylim_vec = ylim(ax);
% x_pos = xlim_vec(1) + 0.02 * diff(xlim_vec);
% y_pos = ylim_vec(2) - 0.08 * diff(ylim_vec);
% text(x_pos, y_pos, txt, 'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'white', 'EdgeColor', 'k', 'Margin', 4);
% xlabel('Year');
% ylabel('Volume');
% title('Logarithmic fit to volumes (2020-2025)');
% legend('Observed','Log fit','Location','best');
% grid on;
% hold off;

% %% bars and log fit together
% fh = figure('Name', sprintf('%s Volumes', name), 'NumberTitle','off');
% hold on;
% bar(years_req, vol_plot, 'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'k', 'FaceAlpha', 0.6);
% % plot the fitted log curve over the bar chart and include R^2 in the legend label
% plot(years_log, y_fit, '-r', 'LineWidth', 1.5);
% %groynes dashed line
% pos2020 = find(years_req == 2020, 1);
% pos2021 = find(years_req == 2021, 1);
% if ~isempty(pos2020) && ~isempty(pos2021)
%     % compute x position midway between the two year tick positions (in data coords)
%     xmid = (years_req(pos2020) + years_req(pos2021)) / 2;
%     % get current y-limits to place the line and text just inside the axes
%     ax = gca;
%     yr = ylim(ax);
%     % keep line within graph by using axes limits (not extending beyond)
%     yline_bot = yr(1) + 0.02 * diff(yr); % small inset from bottom
%     yline_top = yr(2) - 0.02 * diff(yr); % small inset from top
%     % draw vertical dashed line at xmid spanning inside the plotting area
%     line(ax, [xmid xmid], [yline_bot yline_top], 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 1.5, 'Clipping', 'on');
%     % add text label just above the top of the line but inside axes
%     text(ax, xmid, yline_top - 0.01 * diff(yr), 'Groynes built', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
%         'Color', [0.5 0.5 0.5], 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', 'white', 'EdgeColor', 'none', 'Clipping', 'on');
% end
% % error bars of +/-0.05 on each volume bar (only where data exists)
% xpos = years_req; % bar x positions are actual years
% valid = ~isnan(vol_plot);
% if any(valid)
%     xe = xpos(valid);
%     y = vol_plot(valid);
%     eb = 0.05; % error bar magnitude
%     % plot vertical error bars centered on each bar (in data coordinates)
%     errorbar(xe, y, repmat(eb, size(y)), repmat(eb, size(y)), ...
%         'k', 'LineStyle','none', 'LineWidth', 1, 'CapSize', 10);
% end
% 
% hold off;
% 
% ax = gca;
% ax.XTick = years_req;
% ax.FontSize = 14; % increase axis tick label size
% ax.XTickLabel = arrayfun(@(y) num2str(y), years_req, 'UniformOutput', false);
% legend('Volumes', sprintf('Log fit (R^2 = %.3f)', fit_log.R2), 'Location', 'northwest', 'FontSize', 14);
% xlabel('Year');
% ylabel('Volume');
% ylim([min(vol_plot-0.1) max(vol_plot)+.1])
% title(sprintf('%s Volumes', name));
% grid on;

% % %% ----Export all figures to PNGs-----------------------
% % % Export all open figure windows to PNG files in the specified folder.
% % outFolder = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025';
% % if ~exist(outFolder, 'dir')
% %     mkdir(outFolder);
% % end
% % figHandles = findall(0, 'Type', 'figure');
% % if isempty(figHandles)
% %     warning('No open figures to export.');
% % else
% %     for k = 1:numel(figHandles)
% %         fh = figHandles(k);
% %         % Bring figure to front to ensure proper rendering
% %         try
% %             set(0, 'CurrentFigure', fh);
% %         catch
% %         end
% %         % Determine base name from figure 'Name' property or default
% %         figName = get(fh, 'Name');
% %         if isempty(figName)
% %             baseName = sprintf('Figure_%d', fh.Number);
% %         else
% %             % sanitize filename
% %             baseName = regexprep(figName, '[^\w\-_\. ]', '_');
% %             baseName = strtrim(baseName);
% %             if isempty(baseName)
% %                 baseName = sprintf('Figure_%d', fh.Number);
% %             end
% %         end
% % 
% %         % Final filename
% %         filename = fullfile(outFolder, sprintf('%s.png', baseName));
% %         % Ensure unique filename
% %         n = 1;
% %         fname0 = filename;
% %         while exist(filename, 'file')
% %             filename = fullfile(outFolder, sprintf('%s_%d.png', baseName, n));
% %             n = n + 1;
% %         end
% %         % Export using exportgraphics if available for better quality; fallback to saveas
% %         exportgraphics(fh, filename, 'BackgroundColor', 'white', 'Resolution', 300);
% %     end
% % end
% 
% %% compare all log fits on one graph
% % Load all .mat fit_log files from the log_fits folder and plot their fits for comparison
% fitDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', 'Topo_Bathy', 'Lidar', 'Volumes', '2016-2025_Bath', 'log_fits');
% if ~exist(fitDir, 'dir')
%     warning('Log fits directory does not exist: %s', fitDir);
% else
%     files = dir(fullfile(fitDir, '*.mat'));
%         fh2 = figure('Name','Comparison of log fits','NumberTitle','off');
%         hold on;
%         cmap = jet(numel(files));
%         legendEntries = cell(1, numel(files));
%         for k = 1:numel(files)
%             fname = fullfile(fitDir, files(k).name);
%             S = load(fname, 'fit_log');
%             if ~isfield(S, 'fit_log') || isempty(S.fit_log)
%                 continue;
%             end
%             fl = S.fit_log;
%             % Ensure fl.x and fl.y_fit exist
%             if ~isfield(fl, 'x') || ~isfield(fl, 'y_fit')
%                 continue;
%             end
% 
%             % If fl.x contains actual years (e.g., [2021,2022,2025]), map them to compact plotting positions 1..n
%             % but preserve spacing corresponding to the provided years: map unique sorted years to 1..m
%             if all(fl.x >= 1900) || all(fl.x >= 2000) % heuristic: fl.x are years
%                 [uniqueYears, ~, ic] = unique(fl.x, 'stable');
%                 plotX = ic; % positions 1..numel(uniqueYears) preserving order
%                 years_map = uniqueYears;
%             else
%                 % fl.x are indices; use them directly (or fallback)
%                 plotX = fl.x;
%                 % Default years_map if not provided
%                 if isfield(fl, 'years') && numel(fl.years) == numel(fl.x)
%                     years_map = fl.years;
%                 else
%                     years_map = 2020 + (0:numel(fl.x)-1);
%                 end
%             end
% 
%             % If fl.x specifically equals [2021,2022,2025] (or contains those years), ensure mapping keeps these distinct
%             % (the above unique handling already preserves gaps; we still plot at compact indices)
%             % Normalize y values for plotting comparison if needed
%             yfit = fl.y_fit;
%             if ~isvector(yfit) || numel(yfit) ~= numel(plotX)
%                 % try to interpolate/resample if lengths differ
%                 yfit = interp1(1:numel(yfit), yfit, linspace(1,numel(yfit), numel(plotX)), 'linear', 'extrap');
%             end
%             % Plot using cycling colormap
%             plot(plotX, yfit, 'LineWidth', 1.5, 'Color', cmap(mod(k-1,size(cmap,1))+1,:));
% 
%             % Set x ticks and labels to reflect actual years (use years_map)
%             ax2 = gca;
%             ax2.XTick = 1:numel(years_map);
%             ax2.XTickLabel = arrayfun(@(y) num2str(y), years_map, 'UniformOutput', false);
% 
%             % Prepare legend entry
%             [~, base] = fileparts(files(k).name);
%             if isfield(fl, 'name') && ischar(fl.name) && ~isempty(fl.name)
%                 nameLabel = fl.name;
%             else
%                 nameLabel = base;
%             end
%             if isfield(fl, 'R2')
%                 legendEntries{k} = sprintf('%s (R^2=%.3f)', nameLabel, double(fl.R2));
%             else
%                 legendEntries{k} = nameLabel;
%             end
%         end
%         % remove empty legend entries
%         legendEntries = legendEntries(~cellfun(@isempty, legendEntries));
%         if ~isempty(legendEntries)
%             legend(legendEntries, 'Location', 'best', 'Interpreter', 'none');
%         end
%         xlabel('Year');
%         ylabel('Volume (Normalized)');
%         title('Comparison of Volume Trends');
%         grid on;
%         hold off;
% end


%% plotting all volumes from 2016-2026
% Load all .mat files from vol_plots directory and plot their years_req vs vol_plot on one figure
volPlotsDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', 'Topo_Bathy', 'Lidar', 'Volumes', '2016-2026_Bath');
if ~exist(volPlotsDir, 'dir')
    warning('vol_plots directory does not exist: %s', volPlotsDir);
else
    files = dir(fullfile(volPlotsDir, '*.mat'));
    if isempty(files)
        warning('No .mat files found in %s', volPlotsDir);
    else
        fh = figure('Name','All Volumes 2016-2026','NumberTitle','off');
        hold on;
        cmap = jet(max(1,numel(files)));
        legendEntries = cell(1, numel(files));
        for k = 1:numel(files)
            S = load(fullfile(volPlotsDir, files(k).name));
            % Expect variables years_req and vol_plot in each file
            if isfield(S, 'years_req') && isfield(S, 'vol_plot') && isfield(S,bedLevel_file)
                yrs = S.years_req(:);
                vols = S.vol_plot(:);
                bed = S.bedLevel_file(:);
                % If yrs are actual years like [2016,2017,2025] keep them; otherwise use indices
                if isempty(yrs) || isempty(vols) || numel(yrs) ~= numel(vols)
                    % try to handle common alternate names
                    if isfield(S, 'years') && numel(S.years)==numel(vols)
                        yrs = S.years(:);
                    elseif isfield(S, 'x') && numel(S.x)==numel(vols)
                        yrs = S.x(:);
                    else
                        % fallback to indices
                        yrs = (1:numel(vols))';
                    end
                end
                plot(yrs, vols, '-o', 'LineWidth', 5, 'Color', cmap(mod(k-1,size(cmap,1))+1,:));

                [~, base] = fileparts(files(k).name);
                % make a variable names.title that is only the 4 digit number
                tok = regexp(base, '(\d{4})', 'match');
                if ~isempty(tok)
                    names.title = tok{1};
                else
                    names.title = base; % fallback if no 4-digit year found
                end
                % Prepare legend entry: remove 'vol' or 'plot' words, replace underscores, handle specific names
                entry = names.title;
                % remove words 'vol' and 'plot' (case-insensitive) and any surrounding separators
                entry = regexprep(entry, '(?i)(^|[_\-\s])(?:vol|plot)([_\-\s]|$)', ' ');
                entry = strtrim(regexprep(entry, '\s+', ' '));
                entry = strrep(entry, '_', ' ');
                entry = regexprep(entry, '(?i)waarde[_\s]?east', 'East Waarde');
                entry = regexprep(entry, '(?i)waarde[_\s]?west', 'West Waarde');
                legendEntries{k} = entry;

                % Add a vertical line at x=2021.2 to indicate groynes built,
                % but only add the annotation once (avoid repeating for each file).
                if k == 1
                    xline(2021, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.5, 'HandleVisibility', 'off');
                    % add label 'Groyne Built' near the vertical line without adding to legend
                    ylims = ylim;
                    yPos = ylims(2)+.07; % 5% down from top
                    t = text(2021-.5, yPos, 'Groyne Built', 'Color', [0.3 0.3 0.3], 'FontSize', 24, ...
                        'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'Interpreter', 'none', ...
                        'HandleVisibility', 'off');
                    % rotate text 270 degrees (counterclockwise), equivalent to -90 degrees
                    t.Rotation = 90;
                end
            end
        end
        legendEntries = legendEntries(~cellfun(@isempty, legendEntries));
        if ~isempty(legendEntries)
            % Create legend with 2 columns
            lh = legend(legendEntries, 'Interpreter', 'none', 'Location', 'northwest');
            % enlarge legend font
            lh.FontSize = 22;
        end
        xlabel('Year', 'FontSize', 30, 'FontWeight', 'bold');
        ylabel('Sediment Volume', 'FontSize', 30, 'FontWeight', 'bold');
        % Set title and ensure its font size is preserved (do not let later ax.FontSize override it)
        % th = title('Sediment Volume Evolution: Zimmerman', 'FontSize', 55, 'FontWeight', 'bold');
        % enlarge tick labels and axes fonts without changing the title font size
        ax = gca;
        ax.FontSize = 28;
        % Ensure title uses its own FontSize even if axes properties change
        th.FontUnits = 'points';
        th.FontSize = 40;
        ax = gca;
        ax.YGrid = 'on';
        ax.XGrid = 'off';
        ax.GridLineStyle = '-';
        ax.GridColor = [0.8 0.8 0.8];
        ax.GridAlpha = 0.6;
        hold off;

    end
end

% %% Plotting all volumes AND bed levels from 2016-2026
% volPlotsDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', ...
%     'Topo_Bathy', 'Lidar', 'Volumes', '2016-2026_Zimm');
% 
% if ~exist(volPlotsDir, 'dir')
%     warning('vol_plots directory does not exist: %s', volPlotsDir);
% else
%     files = dir(fullfile(volPlotsDir, '*.mat'));
%     if isempty(files)
%         warning('No .mat files found in %s', volPlotsDir);
%     else
%         nFilesMat = numel(files);
%         cmap = jet(max(1,nFilesMat));
% 
%         % ---------- FIGURE 1: Volume vs Year ----------
%         fh1 = figure('Name','All Volumes 2016-2026','NumberTitle','off');
%         hold on;
%         legendEntries_vol = cell(1, nFilesMat);
%         groyneLineDrawn_vol = false;
% 
%         for k = 1:nFilesMat
%             S = load(fullfile(volPlotsDir, files(k).name));
% 
%             if isfield(S, 'years_req') && isfield(S, 'vol_plot')
%                 yrs  = S.years_req(:);
%                 vols = S.vol_plot(:);
% 
%                 if isempty(yrs) || isempty(vols) || numel(yrs) ~= numel(vols)
%                     if isfield(S, 'years') && numel(S.years)==numel(vols)
%                         yrs = S.years(:);
%                     elseif isfield(S, 'x') && numel(S.x)==numel(vols)
%                         yrs = S.x(:);
%                     else
%                         yrs = (1:numel(vols))';
%                     end
%                 end
% 
%                 plot(yrs, vols, '-', 'LineWidth', 5, ...
%                     'Color', cmap(mod(k-1,size(cmap,1))+1,:));
% 
%              % linear regression
%             fitMask = yrs >= 2021 & yrs <= 2026 & ~isnan(vols);
%             if sum(fitMask) >= 2   % need at least 2 points to fit a line
%                 xFit = yrs(fitMask);
%                 yFit = vols(fitMask);
% 
%                 p = polyfit(xFit, yFit, 1);           % linear fit: p(1)=slope, p(2)=intercept
%                 yPred = polyval(p, xFit);
% 
%                 SSresid = sum((yFit - yPred).^2);
%                 SStotal = sum((yFit - mean(yFit)).^2);
%                 R2 = 1 - SSresid/SStotal;
% 
%                 % plot the fitted trend line across the fit range only
%                 % xLine = linspace(min(xFit), max(xFit), 50);
%                 % plot(xLine, polyval(p, xLine), '--', 'LineWidth', 2, ...
%                 %     'Color', cmap(mod(k-1,size(cmap,1))+1,:), 'HandleVisibility','off');
% 
%                 fprintf('Volume trend 2020-2026: slope=%.4f /yr, R^2=%.3f\n', p(1), R2);
% 
%                 % optionally show R^2 in the legend text itself
%                 % entry = sprintf('%s (R^2=%.2f)', entry, R2);
%             else
%                 fprintf('%s -- Not enough points (2020-2026) to fit a trend line.\n', entry);
%             end
% 
%             % legend
%             [~, base] = fileparts(files(k).name);
%             entry = base;
% 
%             % Remove 'vol' and 'plot' anywhere in the string (case-insensitive)
%             entry = regexprep(entry, '(?i)vol', '');
%             entry = regexprep(entry, '(?i)plot', '');
% 
%             % Turn underscores into spaces, collapse repeated whitespace
%             entry = strrep(entry, '_', ' ');
%             entry = strtrim(regexprep(entry, '\s+', ' '));
% 
%             % Standardize specific area names
%             entry = regexprep(entry, '(?i)waarde[_\s]?east', 'East Waarde');
%             entry = regexprep(entry, '(?i)waarde[_\s]?west', 'West Waarde');
%             entry = regexprep(entry, '(?i)zimmerman', 'Zimm');   % <-- shorten Zimmerman to Zimm
% 
%             legendEntries_vol{k} = entry;
% 
%                 if ~groyneLineDrawn_vol
%                     xline(2021, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.5, 'HandleVisibility', 'off');
%                     ylims = ylim;
%                     yPos = ylims(2) + 0.02;
%                     t = text(2021-0.5, yPos, 'Groyne Built', 'Color', [0.3 0.3 0.3], 'FontSize', 24, ...
%                         'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
%                         'Interpreter', 'none', 'HandleVisibility', 'off');
%                     t.Rotation = 90;
%                     groyneLineDrawn_vol = true;
%                 end
%             end
%         end
% 
%         legendEntries_vol = legendEntries_vol(~cellfun(@isempty, legendEntries_vol));
%         if ~isempty(legendEntries_vol)
%             lh1 = legend(legendEntries_vol, 'Interpreter', 'none', 'Location', 'eastoutside');
%             lh1.FontSize = 18;
%         end
% 
%         xlabel('Year', 'FontSize', 30, 'FontWeight', 'bold');
%         ylabel('Sediment Volume [-]', 'FontSize', 30, 'FontWeight', 'bold');
%         % th1 = title('Sediment Volume Evolution: Zimmerman', 'FontWeight', 'bold');
%         % th1.FontUnits = 'points';
%         % th1.FontSize = 40;
% 
%         ax1 = gca;
%         ax1.FontSize = 28;
%         ax1.YGrid = 'on';
%         ax1.XGrid = 'off';
%         ax1.GridLineStyle = '-';
%         ax1.GridColor = [0.8 0.8 0.8];
%         ax1.GridAlpha = 0.6;
%         hold off;
% 
%         % ---------- FIGURE 2: Bed Level vs Year ----------
%         fh2 = figure('Name','All Bed Levels 2016-2026','NumberTitle','off');
%         hold on;
%         legendEntries_bed = cell(1, nFilesMat);
%         groyneLineDrawn_bed = false;
% 
%         for k = 1:nFilesMat
%             S = load(fullfile(volPlotsDir, files(k).name));
% 
%             % Bed level uses its own year vector (years_plot), separate from
%             % the volume calc's years_req, since they were built differently.
%             if isfield(S, 'years_plot') && isfield(S, 'bedLevel_avg')
%                 yrs = S.years_plot(:);
%                 bed = S.bedLevel_avg(:);
%             elseif isfield(S, 'years_req') && isfield(S, 'bedLevel_file')
%                 % fallback if saved under the older naming
%                 yrs = S.years_req(:);
%                 bed = S.bedLevel_file(:);
%             else
%                 continue
%             end
% 
%             if isempty(yrs) || isempty(bed) || numel(yrs) ~= numel(bed)
%                 continue
%             end
% 
%             plot(yrs, bed, '-', 'LineWidth', 5, ...
%                 'Color', cmap(mod(k-1,size(cmap,1))+1,:));
% 
%             % linear regression
%             fitMask = yrs >= 2021 & yrs <= 2026 & ~isnan(bed);
%             if sum(fitMask) >= 2
%                 xFit = yrs(fitMask);
%                 yFit = bed(fitMask);
% 
%                 p = polyfit(xFit, yFit, 1);
%                 yPred = polyval(p, xFit);
% 
%                 SSresid = sum((yFit - yPred).^2);
%                 SStotal = sum((yFit - mean(yFit)).^2);
%                 R2 = 1 - SSresid/SStotal;
% 
%                 fprintf('%s -- Bed level trend 2021-2026: slope=%.4f m/yr, R^2=%.3f\n', entry, p(1), R2);
% 
%                 entry = sprintf('%s (R^2=%.2f)', entry, R2);
%             else
%                 fprintf('%s -- Not enough points (2021-2026) to fit a trend line.\n', entry);
%             end
% 
%               % legend
%            [~, base] = fileparts(files(k).name);
%             entry = base;
% 
%             % Remove 'vol' and 'plot' anywhere in the string (case-insensitive)
%             entry = regexprep(entry, '(?i)vol', '');
%             entry = regexprep(entry, '(?i)plot', '');
% 
%             % Turn underscores into spaces, collapse repeated whitespace
%             entry = strrep(entry, '_', ' ');
%             entry = strtrim(regexprep(entry, '\s+', ' '));
% 
%             % Standardize specific area names
%             entry = regexprep(entry, '(?i)waarde[_\s]?east', 'East Waarde');
%             entry = regexprep(entry, '(?i)waarde[_\s]?west', 'West Waarde');
%             entry = regexprep(entry, '(?i)zimmerman', 'Zimm');   % <-- shorten Zimmerman to Zimm
% 
%             legendEntries_bed{k} = entry;
% 
%             if ~groyneLineDrawn_bed
%                 xline(2021, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.5, 'HandleVisibility', 'off');
%                 ylims = ylim;
%                 yPos = ylims(2) -0.08;
%                 t = text(2021-0.5, yPos, 'Groyne Built', 'Color', [0.3 0.3 0.3], 'FontSize', 24, ...
%                     'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
%                     'Interpreter', 'none', 'HandleVisibility', 'off');
%                 t.Rotation = 90;
%                 groyneLineDrawn_bed = true;
%             end
%         end
% 
%         legendEntries_bed = legendEntries_bed(~cellfun(@isempty, legendEntries_bed));
%         if ~isempty(legendEntries_bed)
%             lh2 = legend(legendEntries_bed, 'Interpreter', 'none', 'Location', 'eastoutside');
%             lh2.FontSize = 18;
%         end
% 
%         xlabel('Year', 'FontSize', 30, 'FontWeight', 'bold');
%         ylabel('Average Bed Level [m NAP]', 'FontSize', 30, 'FontWeight', 'bold');
%         % th2 = title('Average Bed Level Evolution: Zimmerman', 'FontWeight', 'bold');
%         % % th2.FontUnits = 'points';
%         % th2.FontSize = 40;
% 
%         ax2 = gca;
%         ax2.FontSize = 28;
%         ax2.YGrid = 'on';
%         ax2.XGrid = 'off';
%         ax2.GridLineStyle = '-';
%         ax2.GridColor = [0.8 0.8 0.8];
%         ax2.GridAlpha = 0.6;
%         hold off;
%     end
% end

%% plotting bath and zimm bed levels side by side
bathDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', ...
    'Topo_Bathy', 'Lidar', 'Volumes', '2016-2026_Bath');
zimmDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', ...
    'Topo_Bathy', 'Lidar', 'Volumes', '2016-2026_Zimm');

datasets = struct('name', {'Bath', 'Waarde/Zimmerman'}, 'dir', {bathDir, zimmDir});

fh = figure('Name', 'Bed Levels 2016-2026: Bath vs Zimm', 'NumberTitle', 'off');
tl = tiledlayout(fh, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
fh.Position(3:4) = [1200, 400];

for d = 1:numel(datasets)
    volPlotsDir = datasets(d).dir;
    ax = nexttile(tl);
    hold(ax, 'on');

    files = dir(fullfile(volPlotsDir, '*.mat'));
    if isempty(files)
        warning('No .mat files found in %s', volPlotsDir);
        title(ax, sprintf('%s (no files)', datasets(d).name));
        continue
    end

    nFilesMat = numel(files);
    cmap = jet(max(1, nFilesMat));

    legendEntries_bed = cell(1, nFilesMat);
    groyneLineDrawn_bed = false;

    for k = 1:nFilesMat
        S = load(fullfile(volPlotsDir, files(k).name));

        yrs = S.years_req(:);
        bed = S.bedLevel_file(:);
        
        % plot
        plot(ax, yrs, bed, '-', 'LineWidth', 5, ...
            'Color', cmap(mod(k-1, size(cmap,1))+1, :));

        % legend
        [~, base] = fileparts(files(k).name);
        entry = base;
           entry = regexprep(entry, '(?i)Bath', '');
        entry = regexprep(entry, '(?i)vol', '');
        entry = regexprep(entry, '(?i)plot', '');
        entry = regexprep(entry, '(?i)erman', '');
        entry = strrep(entry, '_', ' ');
        entry = strtrim(regexprep(entry, '\s+', ' '));
        legendEntries_bed{k} = entry;

    end
    ax.FontSize = 14;

    legendEntries_bed = legendEntries_bed(~cellfun(@isempty, legendEntries_bed));
    if ~isempty(legendEntries_bed)
        if d==1
            % For first tile, place legend in two columns
            lh = legend(ax, legendEntries_bed, 'Interpreter', 'none', 'Location', 'southeast', 'NumColumns', 2);
        else
            lh = legend(ax, legendEntries_bed, 'Interpreter', 'none', 'Location', 'southeast');
        end
        lh.FontSize = 11;
    end

    xlabel(ax, 'Year', 'FontSize', 15, 'FontWeight', 'bold');
    if d==1
        ylabel(ax, 'Average Bed Level [m NAP]', 'FontSize', 15, 'FontWeight', 'bold');
    end
    title(ax, datasets(d).name, 'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
    % apply italic style to the title string
    t = get(ax, 'Title');
    t.FontAngle = 'italic';

    
    ax.YGrid = 'on';
    ax.XGrid = 'off';
    ax.GridLineStyle = '-';
    ax.GridColor = [0.8 0.8 0.8];
    ax.GridAlpha = 0.6;

    if ~groyneLineDrawn_bed
            if d==1
                xlineYear = 2020;
                fontSize = 14;
                xOffset = -0.5;
                yposFrac = .35; % distance from top as fraction of y-range
            else
                xlineYear = 2021;
                fontSize = 14;
                xOffset = -0.5;
                yposFrac = 0.97;
            end
            % draw vertical line on top of existing plots by using axes children order
            hl = xline(ax, xlineYear, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.5, 'HandleVisibility', 'off');
            % move line to top of stack
            uistack(hl, 'top');
            ylims = ylim(ax);
            yPos = ylims(2) - yposFrac*(ylims(2)-ylims(1));
            t = text(ax, xlineYear + xOffset, yPos, 'Groyne Built', 'Color', [0.3 0.3 0.3], ...
                'FontSize', fontSize, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
                'Interpreter', 'none', 'HandleVisibility', 'off');
            % ensure text is on top
            uistack(t, 'top');
            t.Rotation = 90;
            groyneLineDrawn_bed = true;
    end

    hold(ax, 'off');
end


% export 
outDir = fullfile('P:','11207654-internship-pierce-2026','02_Data','Topo_Bathy','Lidar','Volumes','2016-2026_Zimm');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

outFile = fullfile(outDir, 'volumeevolution_BathZimm.png');
exportgraphics(fh, outFile, 'Resolution', 300);


% % %% exponential decay for volumes since disturbance fitting (delete?)
% % % Prepare data
% % if exist('vol_plot','var') && ~isempty(vol_plot)
% %     vp = vol_plot(:);
% % else
% %     vp = [];
% % end
% % 
% % % Determine fitting years corresponding to the last up-to-4 points
% % if isempty(vp)
% %     warning('vol_plot is empty; skipping exponential fit.');
% % else
% %     n = min(4, numel(vp));
% %     ydata = vp(end-n+1:end);
% % 
% %     if exist('yrs_plot','var') && ~isempty(yrs_plot) && numel(yrs_plot)==numel(vp)
% %         yrs_all = yrs_plot(:);
% %         yrs_fit = yrs_all(end-n+1:end);
% %     elseif ~isempty(years_decay)
% %         yrs_fit = years_decay(:);
% %         if numel(yrs_fit) ~= numel(ydata)
% %             % try align by taking last n of years_decay
% %             yrs_fit = yrs_fit(end-n+1:end);
% %         end
% %     else
% %         yrs_fit = (1:n)'; % fallback to indices
% %     end
% % 
% %     % Keep only finite and positive y values for log-linear fit
% %     valid = isfinite(yrs_fit) & isfinite(ydata) & (ydata > 0);
% %     if nnz(valid) < 2
% %         warning('Not enough valid positive data points to fit exponential decay.');
% %     else
% %         x = yrs_fit(valid);
% %         y = ydata(valid);
% % 
% %         % Shift x to improve conditioning
% %         x0 = min(x);
% %         X = x - x0;
% % 
% %         % Linearize and fit
% %         coeffs = polyfit(X, log(y), 1);
% %         b_exp = coeffs(1);
% %         loga = coeffs(2);
% %         a_exp = exp(loga);
% % 
% %         % Predicted values on training x for R^2
% %         y_pred_train = a_exp * exp(b_exp * (x - x0));
% % 
% %         % Calculate R-squared (coefficient of determination) on original y
% %         ss_res = sum((y - y_pred_train).^2);
% %         ss_tot = sum((y - mean(y)).^2);
% %         if ss_tot > 0
% %             R2 = 1 - ss_res/ss_tot;
% %         else
% %             R2 = NaN;
% %         end
% % 
% %         % Create smooth x range for plotting (preserve year/integer spacing)
% %         if all(mod(x,1)==0) % integer years or indices
% %             xplot = (min(x):max(x))';
% %         else
% %             xplot = linspace(min(x), max(x), 100)';
% %         end
% %         yfit = a_exp * exp(b_exp * (xplot - x0));
% % 
% %         % Plot actual bars and fitted curve
% %         figure();
% %         hold on;
% %         bar(yrs_fit, ydata, 0.7, 'FaceColor',[0.2 0.6 0.8], 'EdgeColor','k');
% %         plot(xplot, yfit, '-r', 'LineWidth', 2);
% % 
% %         % Annotate fit parameters concisely
% %         txt = sprintf('y = %.3g e^{%.3g (x-%g)}', a_exp, b_exp, x0);
% %         xpos = xplot(max(1,round(numel(xplot)*0.6)));
% %         ypos = a_exp * exp(b_exp * (xpos - x0));
% %         text(xpos, ypos, txt, 'FontSize', 12, 'Color', 'r', 'BackgroundColor','w', ...
% %             'Interpreter','none', 'EdgeColor','none');
% % 
% %         hold off;
% %     end
% % end
% 
% %% import vol_plots
% % load mat files (handles multiple files that may have same variable names)
% % import vol_plots
% % load mat files (handles multiple files that may have same variable names)
% vol = struct(); % preallocate as struct to hold per-file vol entries
% fileList = { ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0202.mat', ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0302.mat', ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0402.mat', ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0502.mat', ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0602.mat', ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0702.mat', ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0802.mat', ...
%     'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2025_Bath\vol_plots\Bath_0902.mat' ...
%     };
% 
% for k = 1:numel(fileList)
%     S = load(fileList{k});
%     % prefer explicit field 'vol' if present, otherwise try common alternatives
%     if isfield(S, 'vol')
%         v = S.vol;
%     elseif isfield(S, 'vol_plot')
%         v = S.vol_plot;
%     elseif isfield(S, 'volume')
%         v = S.volume;
%     else
%         % store entire struct if no recognized volume variable
%         v = S;
%     end
% 
%     % store into vol(k) preserving original structure when possible
%     if isstruct(v)
%         vol(k) = v; %#ok<SAGROW>
%     else
%         % place numeric/vector data into a struct with field 'data'
%         vol(k).data = v; %#ok<SAGROW>
%     end
% 
%     % also keep filename base for reference
%     [~, base] = fileparts(fileList{k});
%     vol(k).source = base;
% end
% 
% % plotting
% for k = 1:numel(vol)
%     % Extract numeric series from vol(k)
%     if isfield(vol(k), 'data')
%         series = vol(k).data;
%     end
%     % Take last up-to-4 finite positive values
%     finiteIdx = isfinite(series) & (series > 0);
%     if nnz(finiteIdx) < 2
%         warning('vol(%d): not enough positive finite points for fitting; skipping.', k);
%         continue;
%     end
%     idx = find(finiteIdx);
%     lastIdx = idx(max(1,end-3):end); % indices of last up-to-4 valid points
%     y = series(lastIdx);
%     % if series corresponds to specific years, map last indices to those years:
%     % here x should represent [2020,2021,2022,2025] for up-to-4 last points.
%     years_all = [2020, 2021, 2022, 2025]; 
%     % Ensure years_all length matches number of elements in series when possible.
%     % If series is longer than years_all, assume the last numel(years_all) entries map to these years.
%     nY = numel(years_all);
%     nS = numel(series);
%     if nS >= nY
%         % Map the final nY entries of series to the specified years, then pick lastIdx subset
%         baseIdx = (nS - nY + 1):nS;
%         % Build full x vector aligned with series
%         x_full = nan(nS,1);
%         x_full(baseIdx) = years_all(:);
%     else
%         % If series shorter than years_all, align its entries to the last nS years of years_all
%         x_full = years_all((nY - nS + 1):nY)';
%     end
%     % Select x values corresponding to lastIdx
%     x = x_full(lastIdx);
% 
%     % ==== exponential decay equation ===  (van maren 2023)
%     % eqn X(t) = Xe + (X0 - Xe) e^(-t/Tau)
%     % X(t) = volume 
%     % Xe = target value in new equilib (93.75%)
%     % t = time since intervention
%     % tau = adaptation timescale
% 
%     % For growth behavior: fit y(t) = Xe - A * exp(-t/tau) OR equivalently
%     % y(t) = Xe - A * exp(b*(t-x0)) with b = -1/tau (so b<0). However user
%     % requested "fit x y values such that this is growth with half lives".
%     % We'll fit a logistic-like exponential approach to an upper equilibrium Xe
%     % chosen as 1.0625 * last observed value (i.e., growth to 106.25% of last).
%     x0 = min(x);
%     x = x(:);
%     y = y(:);
% 
%     % % Choose Xe as 1.0625 * last observed value (target equilibrium fraction above last observed)
%     % X0_obs = y(end);
%     % % Estimate Xe from data by fitting the exponential-approach model rather than
%     % % assuming a fixed multiple. We perform a non-linear least squares fit to
%     % % y(t) = Xe - A * exp(b*(t-x0)) with parameters [Xe, A, b]. Constrain Xe to
%     % % be >= max(y) to represent an upper equilibrium, A>0, b<0. Use lsqcurvefit
%     % % if available, otherwise fall back to a simple grid search over Xe.
%     % t_fit = x - x0;
%     % y_fit = y;
%     % 
%     % % Determine Xe based on this eqn:
%     % 
%     % % Initial guesses
%     % Xe0 = max(y) * 1.05;          % slightly above max observed
%     % A0  = Xe0 - y(1);
%     % b0  = -0.5;                   % initial decay rate
%     % 
%     % % Define model (exponential approach-to-equilibrium)
%     % model = @(p, t) p(1) - p(2) .* exp(p(3) .* t); % p = [Xe, A, b] 
%     % 
%     % % Bounds: Xe >= max(y), A >= 0, b <= -eps
%     % lb = [-Inf, 0, -Inf];
%     % ub = [ Inf, Inf, 0];
%     % 
%     % use_lsq = exist('lsqcurvefit', 'file') == 2;
%     % 
%     %     if use_lsq
%     %         opts = optimoptions('lsqcurvefit', 'Display', 'off');
%     %         p0 = [Xe0, max(A0, eps), b0];
%     %         p = lsqcurvefit(model, p0, t_fit, y_fit, lb, ub, opts);
%     %         Xe = p(1);
%     %     % else
%     %     %     % simple grid search fallback for Xe: try values from max(y) to 1.5*max(y)
%     %     %     Xe_grid = linspace(max(y), max(y)*1.5, 201);
%     %     %     bestErr = Inf; bestXe = Xe0;
%     %     %     for g = Xe_grid
%     %     %         % linearize for A and b by fitting ln(Xe - y) = ln(A) + b*t
%     %     %         delta = (g - y_fit);
%     %     %         valid = delta > 0 & isfinite(delta);
%     %     %         if nnz(valid) < 2, continue; end
%     %     %         T = t_fit(valid);
%     %     %         L = log(delta(valid));
%     %     %         coeffs = polyfit(T, L, 1);
%     %     %         b_est = coeffs(1);
%     %     %         A_est = exp(coeffs(2));
%     %     %         ypred = g - A_est .* exp(b_est .* t_fit);
%     %     %         err = sum((y_fit(valid) - ypred(valid)).^2);
%     %     %         if err < bestErr
%     %     %             bestErr = err;
%     %     %             bestXe = g;
%     %     %         end
%     %     %     end
%     %     %     Xe = bestXe;
%     %     % end
%     %     end
%     % 
%     % % % Model: y = Xe - A * exp(b*(t-x0)), where b = -1/tau (b<0), A = Xe - y0
%     % % y_shift = Xe - y;           % should be positive for growth towards Xe
%     % % finitePos = (y_shift > 0) & isfinite(y_shift);
%     % % 
%     % % X = x(finitePos) - x0;
%     % % Y = log(y_shift(finitePos));   % ln(Xe - y) linear in X with slope b
%     % % 
%     % % coeffs = polyfit(X, Y, 1);
%     % % b = coeffs(1);                 % expected negative for approach to Xe
%     % % logA = coeffs(2);
%     % % A = exp(logA);                 % A = Xe - y_at_fitted_start
%     % % 
%     % % % Reconstruct fitted curve on original x
%     % % yfit = Xe - A * exp(b * (x - x0));
%     % % 
%     % % % Interpret fit in terms of timescales (half-life for distance-to-equilibrium)
%     % % if b < 0 && isfinite(b)
%     % %     tau = -1 / b;                  % characteristic timescale
%     % %     T_half = tau * log(2);        % time to halve the gap to Xe
%     % %     % Time to reach 93.75% of equilibrium (i.e., 4 half-lives)
%     % %     Ta = 4 * T_half;
%     % % else
%     % %     tau = NaN; T_half = NaN; Ta = NaN;
%     % % end
%     % 
%     % % R2
%     % validFit = isfinite(yfit) & isfinite(y);
%     % if any(validFit)
%     %     y_obs = y(validFit);
%     %     y_pred = yfit(validFit);
%     %     ss_res = sum((y_obs - y_pred).^2);
%     %     ss_tot = sum((y_obs - mean(y_obs)).^2);
%     %     if ss_tot > 0
%     %         R2 = 1 - ss_res / ss_tot;
%     %     end
%     % end
%     % vol(k).growthfit.R2 = R2;
%     % 
%     % % Save fit results
%     % vol(k).growthfit.tau = tau;
%     % vol(k).growthfit.T_half = T_half;
%     % vol(k).growthfit.Ta94 = Ta;
%     % vol(k).growthfit.Xe = Xe;
%     % vol(k).growthfit.A = A;
%     % 
%     % % Plot measured data and fitted growth curve
%     % try
%     %     figure();
%     %     hold on;
%     %     bar(x, y, 0.7, 'FaceColor',[0.6 0.9 0.6], 'EdgeColor','k');
%     % 
%     %     if all(mod(x,1)==0)
%     %         xplot = (min(x):max(x))';
%     %     else
%     %         xplot = linspace(min(x), max(x), 100)';
%     %     end
%     %     yplot = Xe - A * exp(b * (xplot - x0));
%     %     plot(xplot, yplot, '-r', 'LineWidth', 2);
%     % 
%     %     ann = {};
%     %     % if isfinite(tau),    ann{end+1} = sprintf('\\tau=%.3g', tau); end
%     %     % if isfinite(T_half), ann{end+1} = sprintf('T_{1/2}=%.3g', T_half); end
%     %     if isfinite(Ta),     ann{end+1} = sprintf('T_{94%%}=%.2g', Ta); end
%     %     if isfinite(R2),     ann{end+1} = sprintf('R2_{94%%}=%.3g', R2); end
%     %     % ann{end+1} = sprintf('Xe=%.3g', Xe);
%     %     % ann{end+1} = sprintf('A=%.3g', A);
%     %     anntxt = strjoin(ann, ', ');
%     % 
%     %     xpos = xplot(max(1, round(numel(xplot)*0.6)));
%     %     ypos = Xe - A * exp(b * (xpos - x0));
%     %     text(xpos, ypos, anntxt, 'FontSize',10, 'Color','r', 'BackgroundColor','w', 'Interpreter','tex');
% 
%         xlabel('Index / Year');
%         ylabel('Volume');
%         title(sprintf('Volume Adaptation: %s', vol(k).base), 'FontSize', 24, 'FontWeight', 'bold');
%         grid on;
%         hold off;
%     end
% 
% 


%% Morphological Adaptation Timescale: Volumes & Bed Levels (fit to S from saved .mat files)
volPlotsDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', ...
    'Topo_Bathy', 'Lidar', 'Volumes', '2016-2026_Zimm');

files = dir(fullfile(volPlotsDir, '*.mat'));
nFilesMat = numel(files);

% Containers to collect fit results
expoResults = struct('name', {}, 'metric', {}, 'Xe', {}, 'A', {}, 'tau', {}, ...
                      'T_half', {}, 'Ta94', {}, 'R2', {}, 'F', {}, 'p_value', {}, 'rejectNull', {});

fitOnwardYear = 2021; % only fit the exponential model using data from this year onward
minPointsForFit = 3;  % need at least 3 points to fit a 3-parameter model

for k = 1:nFilesMat
    S = load(fullfile(volPlotsDir, files(k).name));

    % Extract a short station code (e.g. '0202') from the filename
    [~, base] = fileparts(files(k).name);
    tokens = regexp(base, '\d+', 'match');
    if ~isempty(tokens)
        name = tokens{end};
    else
        name = base;
    end

    % Run the fit for Volume (Bed Level currently disabled below)
    metricsToFit = {};
    if isfield(S, 'years_req') && isfield(S, 'vol_plot')
        metricsToFit{end+1} = struct('label','Volume', 'x', S.years_req(:), 'y', S.vol_plot(:));
    end
    % if isfield(S, 'years_plot') && isfield(S, 'bedLevel_avg')
    %     metricsToFit{end+1} = struct('label','BedLevel', 'x', S.years_plot(:), 'y', S.bedLevel_avg(:));
    % elseif isfield(S, 'years_req') && isfield(S, 'bedLevel_file')
    %     metricsToFit{end+1} = struct('label','BedLevel', 'x', S.years_req(:), 'y', S.bedLevel_file(:));
    % end

    for m = 1:numel(metricsToFit)
        metricLabel = metricsToFit{m}.label;
        x_all = metricsToFit{m}.x;
        y_all = metricsToFit{m}.y;

        if isempty(x_all) || isempty(y_all) || numel(x_all) ~= numel(y_all)
            warning('%s (%s): year/value vectors missing or mismatched; skipping.', name, metricLabel);
            continue;
        end

        % Keep only finite points from fitOnwardYear onward
        validIdx = isfinite(x_all) & isfinite(y_all) & (x_all >= fitOnwardYear);
        x = x_all(validIdx);
        y = y_all(validIdx);

        if numel(x) < minPointsForFit
            warning('%s (%s): only %d valid point(s) from %d onward; need >= %d. Skipping.', ...
                name, metricLabel, numel(x), fitOnwardYear, minPointsForFit);
            continue;
        end

        [x, sortIdx] = sort(x);
        y = y(sortIdx);

        % Time relative to the first observation in this window
        x0 = min(x);
        t_fit = x - x0;

        % ========================================================================
        % linear fit (kept for reference/comparison)
        % ========================================================================
        p_lin = polyfit(t_fit, y, 1);
        yfit_lin = polyval(p_lin, t_fit);
        RSS_linear = sum((y - yfit_lin).^2);
        df_linear  = numel(y) - 2; %degress of freedom

        % =========================================================================
        % NON-LINEAR FIT FOR Xe, A, and tau
        % Model: X(t) = Xe - A * exp(-t / tau)
        % =========================================================================
        fitModel = @(p, t) p(1) - p(2) * exp(-t ./ p(3));

        Xe_guess  = max(y) * 1.10;
        A_guess   = max(Xe_guess - y(1), 1e-3);
        tau_guess = 6.0;
        p0 = [Xe_guess, A_guess, tau_guess];

        lb = [max(y), 0.001, 0.1];
        ub = [Inf, Inf, Inf];

        % extra room to converge for F-test
        if exist('optimoptions','file') == 2
            opts = optimoptions('lsqcurvefit', 'Display', 'off', ...
                'MaxFunctionEvaluations', 5000, 'MaxIterations', 2000);
        else
            opts = optimset('Display', 'off', 'MaxFunEvals', 5000, 'MaxIter', 2000);
        end

        try
            if exist('lsqcurvefit','file') == 2
                pFit = lsqcurvefit(fitModel, p0, t_fit, y, lb, ub, opts);
            elseif exist('lsqnonlin','file') == 2
                residFun = @(p) fitModel(p, t_fit) - y;
                pFit = lsqnonlin(residFun, p0, lb, ub, opts);
            elseif exist('fminsearch','file') == 2
                costFun = @(p) sum((fitModel(p, t_fit) - y).^2);
                p0c = max(lb, min(p0, ub));
                pFit = fminsearch(costFun, p0c);
                pFit = max(lb, min(pFit, ub));
            else
                pFit = p0;
            end
            Xe  = pFit(1);
            A   = pFit(2);
            tau = pFit(3);
        catch ME
            warning('%s (%s): nonlinear fit failed (%s). Using initial guesses.', ...
                name, metricLabel, ME.message);
            Xe  = p0(1);
            A   = max(p0(2), 1e-6);
            tau = max(p0(3), 0.1);
        end

        T_half = tau * log(2);
        Ta = 4 * T_half;

        yfit = fitModel([Xe, A, tau], t_fit);
        RSS_exp = sum((y - yfit).^2);
        ss_tot  = sum((y - mean(y)).^2);
        R2 = 1 - (RSS_exp / ss_tot);
        df_exp = numel(y) - 3; % degress of freedom

        % ========================================================================
        % F-test: H0 = linear adequate, H1 = exponential justified
        % ========================================================================
        if df_exp >= 1 && RSS_linear > RSS_exp
            F = ((RSS_linear - RSS_exp) / (df_linear - df_exp)) / (RSS_exp / df_exp);
            p_value = 1 - fcdf_manual(F, df_linear - df_exp, df_exp);
            rejectNull = p_value < 0.05;
        elseif df_exp >= 1
            F = NaN; p_value = 1; rejectNull = false;
            warning('%s (%s): exponential RSS (%.4g) >= linear RSS (%.4g); fit did not improve, skipping F-test.', ...
                name, metricLabel, RSS_exp, RSS_linear);
        else
            F = NaN; p_value = NaN; rejectNull = false;
            warning('%s (%s): not enough points (n=%d) for a valid F-test (need n >= 4).', ...
                name, metricLabel, numel(y));
        end

        if rejectNull
            verdict = 'REJECT H0 (exponential justified)';
        else
            verdict = 'FAIL TO REJECT H0 (linear adequate)';
        end
        fprintf('%s (%s): F=%.3f, p=%.4f -> %s\n', name, metricLabel, F, p_value, verdict);

        % ========================================================================
        % Store EVERYTHING in one single assignment
        % ========================================================================
        expoResults(end+1) = struct('name', name, 'metric', metricLabel, ...
            'Xe', Xe, 'A', A, 'tau', tau, 'T_half', T_half, 'Ta94', Ta, 'R2', R2, ...
            'F', F, 'p_value', p_value, 'rejectNull', rejectNull); %#ok<SAGROW>
        
        % % ====== Plotting ============
        % figure('Name', sprintf('%s Adaptation: %s', metricLabel, name));
        % hold on;
        % bar(x, y, 0.7, 'FaceColor',[0.2 0.6 0.8], 'EdgeColor','k');
        % 
        % xplot = linspace(min(x), max(x) + 5, 100)';
        % yplot = fitModel([Xe, A, tau], xplot - x0);
        % plot(xplot, yplot, '-r', 'LineWidth', 3);
        % 
        % yline(Xe, '--b', sprintf('Xe = %.2f', Xe), 'LabelHorizontalAlignment','left', 'LineWidth', 3);
        % 
        % ann = {};
        % if isfinite(Ta), ann{end+1} = sprintf('T_{94%%}=%.2g yrs', Ta); end
        % if isfinite(R2), ann{end+1} = sprintf('R^2=%.3f', R2); end
        % anntxt = strjoin(ann, ', ');
        % 
        % textFontSize = 22;
        % set(findall(gcf,'-property','FontSize'),'FontSize',textFontSize);
        % 
        % xpos = xplot(round(numel(xplot)*0.5));
        % ypos = fitModel([Xe, A, tau], xpos - x0);
        % text(xpos-1.2, ypos+0.05, anntxt, 'FontSize',22, 'Color','r', 'BackgroundColor','w', 'Margin', 2);
        % 
        % xlabel('Year','FontSize',24);
        % if strcmp(metricLabel,'Volume')
        %     ylabel('Volume (Normalized to 2016)','FontSize',24);
        % else
        %     ylabel('Average Bed Level (m)','FontSize',24);
        % end
        % title(sprintf('%s Adaptation: %s', metricLabel, name), 'FontSize', 30, 'FontWeight', 'bold');
        % 
        % ax = gca;
        % ax.XGrid = 'off';
        % ax.YGrid = 'on';
        % 
        % xlim([min(x)-0.5, max(x)+0.5]);
        % ylim([min(y)-0.1*range(y)-eps, Xe+0.1]);
        % hold off;
    end
end


% %% Morphological Adaptation Timescale: Volumes
% for k = 1:numel(vol)
%     % Extract numeric series from vol(k)
%     if isfield(vol(k), 'data')
%         series = vol(k).data;
%     end
% 
%     % Take last up-to-4 finite positive values
%     finiteIdx = isfinite(series) & (series > 0);
%     if nnz(finiteIdx) < 2
%         warning('vol(%d): not enough positive finite points for fitting; skipping.', k);
%         continue;
%     end
% 
%     idx = find(finiteIdx);
%     lastIdx = idx(max(1,end-3):end); % indices of last up-to-4 valid points
%     y = series(lastIdx);
%     y = y(:); % Force column vector
% 
%     % Year mapping setup
%     years_all = [2020, 2021, 2022, 2025, 2026]; 
%     nY = numel(years_all);
%     nS = numel(series);
%     if nS >= nY
%         baseIdx = (nS - nY + 1):nS;
%         x_full = nan(nS,1);
%         x_full(baseIdx) = years_all(:);
%     else
%         x_full = years_all((nY - nS + 1):nY)';
%     end
%     x = x_full(lastIdx);
%     x = x(:); % Force column vector
% 
%     % Time relative to the first observation in this window
%     x0 = min(x);
%     t_fit = x - x0;
% 
%     % better name for title
%     % Extract a concise name code from vol(k).source, e.g. 'Bath_0202' -> '0202'
%     name = '';
%     if isfield(vol(k), 'source') && ischar(vol(k).source)
%         src = vol(k).source;
%         % Find groups of digits in the string and take the last group (common for codes)
%         tokens = regexp(src, '\d+', 'match');
%         if ~isempty(tokens)
%             name = tokens{end};
%         else
%             % Fallback: remove non-alphanumeric and underscores, then remove leading text up to last underscore
%             parts = regexp(src, '[^_]+', 'match');
%             if ~isempty(parts)
%                 name = parts{end};
%             else
%                 name = src;
%             end
%         end
%     end
%     % Store short name for use in titles/labels
%     shortName = name;
% 
%     % ========================================================================
%     % linear fit
%     % ==========================================================================  
%     p = polyfit(t_fit, y, 1);
%     y_fit_linear = polyval(p, t_fit);
% 
%     % =========================================================================
%     % NON-LINEAR FIT FOR Xe, A, and tau
%     % Model: X(t) = Xe - A * exp(-t / tau)
%     % Coefficients vector: p = [Xe, A, tau]
%     % =========================================================================
%     fitModel = @(p, t) p(1) - p(2) * exp(-t ./ p(3));
% 
%     % Initial guesses
%     Xe_guess  = max(y) * 1.10;         % Assume equilibrium is slightly above max observed
%     A_guess   = Xe_guess - y(1);       % Initial distance to equilibrium
%     tau_guess = 6.0;                   % Initial guess for adaptation time scale (years)
%     p0 = [Xe_guess, A_guess, tau_guess];
% 
%     % Constraints: Xe >= max(y), A > 0, tau > 0
%     lb = [max(y), 0.001, 0.1];
%     ub = [Inf, Inf, Inf];
% 
%     % Use lsqcurvefit without optimoptions for compatibility with older MATLAB
%     % Build options using optimset if optimoptions is unavailable
%     % if exist('optimoptions','file') == 2
%     %     opts = optimoptions('lsqcurvefit', 'Display', 'off');
%     % else
%     %     opts = optimset('Display', 'off');
%     % end
% 
%     try
%         % If lsqcurvefit exists, use it; otherwise fall back to lsqnonlin on residuals
%         if exist('lsqcurvefit','file') == 2
%             [pFit, ~] = lsqcurvefit(fitModel, p0, t_fit, y, lb, ub, opts);
%         else
%             % Define residual function for lsqnonlin: residuals between model and y
%             residFun = @(p) fitModel(p, t_fit) - y;
%             % Ensure lsqnonlin exists
%             if exist('lsqnonlin','file') == 2
%                 % lsqnonlin doesn't accept separate lb/ub unless in newer versions; provide them
%                 [pFit, ~] = lsqnonlin(residFun, p0, lb, ub, opts);
%             else
%                 % As a last resort use fminsearchbnd-like approach using fminsearch if available
%                 % Define cost (sum of squares)
%                 costFun = @(p) sum((fitModel(p, t_fit) - y).^2);
%                 % Constrain initial guess into bounds
%                 p0 = max(lb, min(p0, ub));
%                 % Use fminsearch (unconstrained) starting from p0; results may violate bounds slightly
%                 if exist('fminsearch','file') == 2
%                     pFit = fminsearch(costFun, p0);
%                     % enforce bounds post hoc
%                     pFit = max(lb, min(pFit, ub));
%                 else
%                     % If none available, fallback to simple closed-form guesses
%                     pFit = p0;
%                 end
%             end
%         end
%         Xe  = pFit(1);
%         A   = pFit(2);
%         tau = pFit(3);
%     catch
%         % On any error, fall back to initial guesses (safe defaults)
%         Xe  = p0(1);
%         A   = max(p0(2), 1e-6);
%         tau = max(p0(3), 0.1);
%     end
% 
%     % Calculate characteristic milestones
%     T_half = tau * log(2);            % Time to close half the gap to Xe
%     Ta = 4 * T_half;                  % Time to reach ~93.75% of equilibrium (4 half-lives)
% 
%     % Evaluate fit and compute R2
%     yfit = fitModel([Xe, A, tau], t_fit);
%     ss_res = sum((y - yfit).^2);
%     ss_tot = sum((y - mean(y)).^2);
%     R2 = 1 - (ss_res / ss_tot);
% 
%     % Save fit results back into structure
%     vol(k).growthfit.R2 = R2;
%     vol(k).growthfit.tau = tau;
%     vol(k).growthfit.T_half = T_half;
%     vol(k).growthfit.Ta94 = Ta;
%     vol(k).growthfit.Xe = Xe;
%     vol(k).growthfit.A = A;
% 
%     % ======Plotting ============
%     figure('Name', sprintf('Volume Adaptation: Bath %s', name));
%     hold on;
%     bar(x, y, 0.7, 'FaceColor',[0.2 0.6 0.8], 'EdgeColor','k');
% 
%     % Generate a smooth curve for plotting
%     xplot = linspace(min(x), max(x) + 5, 100)'; % extending 5 years into future to see asymptote
%     yplot = fitModel([Xe, A, tau], xplot - x0);
% 
%     plot(xplot, yplot, '-r', 'LineWidth', 3);
%     % Draw the asymptote line for Xe
%     yline(Xe, '--b', sprintf('Xe = %.2f', Xe), 'LabelHorizontalAlignment','left', 'LineWidth', 3);
% 
%     % Build Annotation
%     ann = {};
%     if isfinite(Ta),     ann{end+1} = sprintf('T_{94%%}=%.2g yrs', Ta); end
%     if isfinite(R2),     ann{end+1} = sprintf('R^2=%.3f', R2); end
%     anntxt = strjoin(ann, ', ');
%     % Set font size for annotation text
%     textFontSize = 22;
%     set(findall(gcf,'-property','FontSize'),'FontSize',textFontSize);
% 
%     xpos = xplot(round(numel(xplot)*0.5));
%     ypos = fitModel([Xe, A, tau], xpos - x0);
%     text(xpos-1.2, ypos+0.05, anntxt, 'FontSize',22, 'Color','r', 'BackgroundColor','w', 'Margin', 2);
% 
%     xlabel('Year','FontSize',24);
%     ylabel('Volume (Normalized to 2016)','FontSize',24);
%     title(sprintf('Volume Adaptation: Bath %s', name), 'FontSize', 30, 'FontWeight', 'bold');
%     % Enable only horizontal grid lines (y-grid)
%     ax = gca;
%     ax.XGrid = 'off';
%     ax.YGrid = 'on';
% 
%     xlim([2019.5 2025.5]);
%     ylim([0.7 Xe+0.1]);
%     hold off;
% end

% % ----Export all figures to PNGs-----------------------
% % Export all open figure windows to PNG files in the specified folder.
% outFolder = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Lidar\Volumes\2016-2026_Bath';
% if ~exist(outFolder, 'dir')
%     mkdir(outFolder);
% end
% figHandles = findall(0, 'Type', 'figure');
% if isempty(figHandles)
%     warning('No open figures to export.');
% else
%     for k = 1:numel(figHandles)
%         fh = figHandles(k);
%         % Bring figure to front to ensure proper rendering
%         try
%             set(0, 'CurrentFigure', fh);
%         catch
%         end
%         % Determine base name from figure 'Name' property or default
%         figName = get(fh, 'Name');
%         if isempty(figName)
%             baseName = sprintf('Figure_%d', fh.Number);
%         else
%             % sanitize filename
%             baseName = regexprep(figName, '[^\w\-_\. ]', '_');
%             baseName = strtrim(baseName);
%             if isempty(baseName)
%                 baseName = sprintf('Figure_%d', fh.Number);
%             end
%         end
% 
%         % Final filename
%         filename = fullfile(outFolder, sprintf('%s.png', baseName));
%         % Ensure unique filename
%         n = 1;
%         fname0 = filename;
%         while exist(filename, 'file')
%             filename = fullfile(outFolder, sprintf('%s_%d.png', baseName, n));
%             n = n + 1;
%         end
%         % Export using exportgraphics if available for better quality; fallback to saveas
%         exportgraphics(fh, filename, 'BackgroundColor', 'white', 'Resolution', 300);
%     end
% end
 
% %% plotting Bath and Zimm together cleanly with error bars
% volPlotsDir = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', 'Topo_Bathy', 'Lidar', 'Volumes', '2016-2025_Zimm', 'vol_plots');
% volPlotsDir1 = fullfile('P:', filesep, '11207654-internship-pierce-2026', '02_Data', 'Topo_Bathy', 'Lidar', 'Volumes', '2016-2025_Bath', 'vol_plots');
% 
% filesZimm = dir(fullfile(volPlotsDir, '*.mat'));
% filesBath = dir(fullfile(volPlotsDir1, '*.mat'));
% 
% [filesZimm.sourceDir] = deal(volPlotsDir);
% [filesBath.sourceDir] = deal(volPlotsDir1);
% [filesZimm.siteLabel] = deal('Zimm');
% [filesBath.siteLabel] = deal('Bath');
% 
% files = [filesZimm; filesBath];
% 
% % separate colormaps per site
% % 'hot' gives a classic thermal look (black -> red -> yellow -> white)
% % swap to turbo(...) if you want a blue->red->yellow thermal-camera style instead
% cmapBath = parula(max(1,numel(filesBath)));
% cmapZimm = hot(max(1,numel(filesZimm)));
% 
% fh = figure('Name','All Volumes 2016-2025','NumberTitle','off');
% hold on;
% legendEntries = cell(1, numel(files));
% 
% bathIdx = 0;
% zimmIdx = 0;
% 
% for k = 1:numel(files)
%     S = load(fullfile(files(k).sourceDir, files(k).name));
% 
%     if isfield(S, 'years_req') && isfield(S, 'vol_plot')
%         yrs = S.years_req(:);
%         vols = S.vol_plot(:);
% 
%         if isempty(yrs) || isempty(vols) || numel(yrs) ~= numel(vols)
%             if isfield(S, 'years') && numel(S.years)==numel(vols)
%                 yrs = S.years(:);
%             elseif isfield(S, 'x') && numel(S.x)==numel(vols)
%                 yrs = S.x(:);
%             else
%                 yrs = (1:numel(vols))';
%             end
%         end
% 
%         % assign color and line style based on site
%         if strcmp(files(k).siteLabel, 'Bath')
%             bathIdx = bathIdx + 1;
%             thisColor = cmapBath(bathIdx, :);
%             lineStyle = '-';
%         else
%             zimmIdx = zimmIdx + 1;
%             thisColor = cmapBath(zimmIdx, :);
%             lineStyle = '--';
%         end
% 
%         plot(yrs, vols, lineStyle, 'LineWidth', 5, 'Color', thisColor);
% 
%         [~, base] = fileparts(files(k).name);
%         tok = regexp(base, '(\d{4})', 'match');
%         if ~isempty(tok)
%             names.title = tok{1};
%         else
%             names.title = base;
%         end
% 
%         entry = names.title;
%         entry = strrep(entry, '_', ' ');
%         entry = regexprep(entry, '(?i)waarde[_\s]?east', 'Waarde East');
%         entry = regexprep(entry, '(?i)waarde[_\s]?west', 'Waarde West');
%         entry = sprintf('%s (%s)', entry, files(k).siteLabel);
%         legendEntries{k} = entry;
% 
%         if k == 1
%             xline(2021, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.5, 'HandleVisibility', 'off');
%             ylims = ylim;
%             yPos = ylims(2)+.07;
%             t = text(2021-.3, yPos, 'Groyne Built', 'Color', [0.3 0.3 0.3], 'FontSize', 24, ...
%                 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'Interpreter', 'none', ...
%                 'HandleVisibility', 'off');
%             t.Rotation = 90;
%         end
%     end
% end
% 
% legendEntries = legendEntries(~cellfun(@isempty, legendEntries));
% if ~isempty(legendEntries)
%     lh = legend(legendEntries, 'Interpreter', 'none', 'Location', 'northwest');
%     lh.FontSize = 22;
% end
% 
% xlabel('Year', 'FontSize', 30, 'FontWeight', 'bold');
% ylabel('Volume (Normalized to 2016)', 'FontSize', 30, 'FontWeight', 'bold');
% th = title('Sediment Volume Evolution: Zimmerman & Bath', 'FontSize', 55, 'FontWeight', 'bold');
% 
% ax = gca;
% ax.FontSize = 28;
% th.FontUnits = 'points';
% th.FontSize = 40;
% ax.YGrid = 'on';
% ax.XGrid = 'off';
% ax.GridLineStyle = '-';
% ax.GridColor = [0.8 0.8 0.8];
% ax.GridAlpha = 0.6;
% hold off;
% 
% % % export to specified folder with ensured existence
% % outDir = fullfile('P:','11207654-internship-pierce-2026','02_Data','Topo_Bathy','Lidar','Volumes','2016-2025_Zimm');
% % if ~exist(outDir, 'dir')
% %     mkdir(outDir);
% % end
% % outFile = fullfile(outDir, 'volumeevolution_Zimm.png');
% % exportgraphics(fh, outFile, 'Resolution', 300);

%% Local functions (must be at the end of the script)
function p = fcdf_manual(F, df1, df2)
    % Manual F-distribution CDF using the regularized incomplete beta function
    % (avoids needing Statistics and Machine Learning Toolbox)
    x = (df1 .* F) ./ (df1 .* F + df2);
    p = betainc(x, df1/2, df2/2);
end