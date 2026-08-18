% Compare T0 and T1 ADCP observations of velocity in space and time (DEPTH_AVG)
% D. Pierce

clear all
close all
clc

%% Load measurement data
load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
load('p:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\04_output_locations\ADCP_overview.mat')

% %% Determine nStations 
% % idxRanges = [2:38, 72:92];
% % S_selected = S(idxRanges, :);
% nStations = size(S,1);
% 
% for ss = 1:length(nStations)
%         splitName = split(string(idxRanges(ss)), '_');
% % make splitname 1 2 3 based on columns of S
% if exist('S','var') && size(S_selected,2) >= 3
%     col1 = string(S(ss,1));
%     col2 = string(S(ss,2));
%     col3 = string(S(ss,3));
% else
%     % Fallback to using idxRanges value split (if entries are like 'BATH_T0_MP01')
%     parts = split(string(idxRanges(ss)), '_');
%     % Ensure at least 3 parts; pad with empty strings if necessary
%     while numel(parts) < 3
%         parts{end+1} = "";
%     end
%     col1 = parts{1};
%     col2 = parts{2};
%     col3 = parts{3};
% end
% splitName = {col1, col2, col3};
% 
% % Retrieve station metadata and data safely using splitName
% % S column 1,2,3 mapping if S is cell/char/numeric
% Scol1 = S_selected(ss,1);
% Scol2 = S_selected(ss,2);
% Scol3 = S_selected(ss,3);
% 
% % Attempt to get uvSeries and z if fields exist
% uvSeries = [];
% z = [];
% if isfield(ADCP, splitName{1}) && isfield(ADCP.(splitName{1}), splitName{2}) && isfield(ADCP.(splitName{1}).(splitName{2}), splitName{3})
%     fld = ADCP.(splitName{1}).(splitName{2}).(splitName{3});
%     if isfield(fld, 'Umag_da'), uvSeries = fld.Umag_da; end
%     if isfield(fld, 'META') && isfield(fld.META, 'ZBED'), z = fld.META.ZBED; end
% end
% end
% 
% %% ADCP Observations
% f0 = {};
% f1 = {};
% 
% % From ADCP.BATH (T0 and T1) - store with source prefix to keep duplicates separate
% if isfield(ADCP, 'BATH') && isstruct(ADCP.BATH)
%     if isfield(ADCP.BATH, 'T0') && isstruct(ADCP.BATH.T0)
%         fn = fieldnames(ADCP.BATH.T0);
%         for ii = 1:numel(fn)
%             f0{end+1,1} = ['BATH_' fn{ii}]; %#ok<SAGROW>
%         end
%     end
%     if isfield(ADCP.BATH, 'T1') && isstruct(ADCP.BATH.T1)
%         fn = fieldnames(ADCP.BATH.T1);
%         for ii = 1:numel(fn)
%             f1{end+1,1} = ['BATH_' fn{ii}]; %#ok<SAGROW>
%         end
%     end
% end
% 
% % Also include stations from ADCP.ZIMMERMAN (T0 and T1) and prefix with source
% if isfield(ADCP, 'ZIMMERMAN') && isstruct(ADCP.ZIMMERMAN)
%     if isfield(ADCP.ZIMMERMAN, 'T0') && isstruct(ADCP.ZIMMERMAN.T0)
%         fn = fieldnames(ADCP.ZIMMERMAN.T0);
%         for ii = 1:numel(fn)
%             f0{end+1,1} = ['ZIMM_' fn{ii}]; %#ok<SAGROW>
%         end
%     end
%     if isfield(ADCP.ZIMMERMAN, 'T1') && isstruct(ADCP.ZIMMERMAN.T1)
%         fn = fieldnames(ADCP.ZIMMERMAN.T1);
%         for ii = 1:numel(fn)
%             f1{end+1,1} = ['ZIMM_' fn{ii}]; %#ok<SAGROW>
%         end
%     end
% end
% 
% % Ensure column cell arrays and remove duplicates
% f0 = unique(cellstr(f0));
% f1 = unique(cellstr(f1));
% siteFields = unique([f0; f1]);
% 
% % siteFields = fieldnames(ADCP.BATH.T0);
% isStation = contains(siteFields, 'MP');
% stationNames = siteFields(isStation);
% % Create station names for titles without the 'MP' prefix if present
% stationNames_title = stationNames;
% for i = 1:numel(stationNames_title)
%     stationNames_title{i} = regexprep(stationNames_title{i}, '^MP', '');
% end
% nStations = length(stationNames);
% 
% % Preallocate cell arrays
% z0 = cell(size(stationNames));
% v0 = cell(size(stationNames));
% z1 = cell(size(stationNames));
% v1 = cell(size(stationNames));
% peakvel0 = cell(size(stationNames));
% peakvel1 = cell(size(stationNames));
% 
% for k = 1:nStations
%     s = stationNames{k};
%     % Default empty
%     v0{k} = [];
%     z0{k} = [];
%     peakvel0{k} = [];
%     % Check BATH T0
%     if isfield(ADCP, 'BATH') && isfield(ADCP.BATH, 'T0') && isfield(ADCP.BATH.T0, s)
%         fld = ADCP.BATH.T0.(s);
%         if isfield(fld, 'META') && isfield(fld.META, 'ZBED')
%             zvals = fld.META.ZBED;
%         else
%             zvals = [];
%         end
%         if isfield(fld, 'Umag_da')
%             vvals = fld.Umag_da;
%         else
%             vvals = [];
%         end
%         % Store if nonempty
%         if ~isempty(zvals), z0{k} = zvals; end
%         if ~isempty(vvals), v0{k} = vvals; end
%     end
% 
%     % Also check ZIMMERMAN T0 and append/merge if present
%     if isfield(ADCP, 'ZIMMERMAN') && isfield(ADCP.ZIMMERMAN, 'T0') && isfield(ADCP.ZIMMERMAN.T0, s)
%         zf = ADCP.ZIMMERMAN.T0.(s);
%         if isfield(zf, 'META') && isfield(zf.META, 'ZBED')
%             zvals_zim = zf.META.ZBED;
%         else
%             zvals_zim = [];
%         end
%         if isfield(zf, 'Umag_da')
%             vvals_zim = zf.Umag_da;
%         else
%             vvals_zim = [];
%         end
%         % Merge numeric arrays: concatenate along first non-singleton dim and remove NaNs
%         if ~isempty(zvals_zim)
%             if isempty(z0{k})
%                 z0{k} = zvals_zim;
%             else
%                 z0{k} = [z0{k}(:); zvals_zim(:)];
%             end
%             z0{k} = z0{k}(~isnan(z0{k}));
%         end
%         if ~isempty(vvals_zim)
%             if isempty(v0{k})
%                 v0{k} = vvals_zim;
%             else
%                 % If both are matrices with same columns, concatenate rows; otherwise vectorize and concatenate
%                 if ismatrix(v0{k}) && ismatrix(vvals_zim) && size(v0{k},2)==size(vvals_zim,2)
%                     v0{k} = [v0{k}; vvals_zim];
%                 else
%                     v0{k} = [v0{k}(:); vvals_zim(:)];
%                 end
%             end
%             if ~isempty(v0{k})
%                 peakvel0{k} = max(v0{k}, [], 'all'); % Use 'all' in case v0{k} is a 2D matrix
%             end
%         end
%     end
% end
% 
% % Repeat for T1: populate z1 and v1 similarly to z0 and v0
% for k = 1:nStations
%     s = stationNames{k};
%     % Default empty
%     v1{k} = [];
%     z1{k} = [];
%     peakvel1{k} = [];
%     % Check BATH T1
%     if isfield(ADCP, 'BATH') && isfield(ADCP.BATH, 'T1') && isfield(ADCP.BATH.T1, s)
%         fld = ADCP.BATH.T1.(s);
%         if isfield(fld, 'META') && isfield(fld.META, 'ZBED')
%             zvals = fld.META.ZBED;
%         else
%             zvals = [];
%         end
%         if isfield(fld, 'Umag_da')
%             vvals = fld.Umag_da;
%         else
%             vvals = [];
%         end
%         % Store if nonempty
%         if ~isempty(zvals), z1{k} = zvals; end
%         if ~isempty(vvals), v1{k} = vvals; end
%     end
% 
%     % Also check ZIMMERMAN T1 and append/merge if present
%     if isfield(ADCP, 'ZIMMERMAN') && isfield(ADCP.ZIMMERMAN, 'T1') && isfield(ADCP.ZIMMERMAN.T1, s)
%         zf = ADCP.ZIMMERMAN.T1.(s);
%         if isfield(zf, 'META') && isfield(zf.META, 'ZBED')
%             zvals_zim = zf.META.ZBED;
%         else
%             zvals_zim = [];
%         end
%         if isfield(zf, 'Umag_da')
%             vvals_zim = zf.Umag_da;
%         else
%             vvals_zim = [];
%         end
%         % Merge numeric arrays: concatenate along first non-singleton dim and remove NaNs
%         if ~isempty(zvals_zim)
%             if isempty(z1{k})
%                 z1{k} = zvals_zim;
%             else
%                 z1{k} = [z1{k}(:); zvals_zim(:)];
%             end
%             z1{k} = z1{k}(~isnan(z1{k}));
%         end
%         if ~isempty(vvals_zim)
%             if isempty(v1{k})
%                 v1{k} = vvals_zim;
%             else
%                 % If both are matrices with same columns, concatenate rows; otherwise vectorize and concatenate
%                 if ismatrix(v1{k}) && ismatrix(vvals_zim) && size(v1{k},2)==size(vvals_zim,2)
%                     v1{k} = [v1{k}; vvals_zim];
%                 else
%                     v1{k} = [v1{k}(:); vvals_zim(:)];
%                 end
%             end
%             % Remove rows that are all NaN for matrix case, or NaNs for vector case
%             if ismatrix(v1{k})
%                 v1{k} = v1{k}(~all(isnan(v1{k}),2), :);
%             else
%                 v1{k} = v1{k}(~isnan(v1{k}));
%             end
%             if ~isempty(v1{k})
%                 peakvel1{k} = max(v0{k}, [], 'all'); % Use 'all' in case v0{k} is a 2D matrix
%             end
%         end
%     end
% end

% %% Process T1 stations
% for k = 1:nStations
%     s = stationNames{k};
%     peakvel1{k} = [];
%     v1{k} = [];
%     z1{k} = [];
%     if isfield(ADCP.BATH.T1, s)
%         fld = ADCP.BATH.T1.(s);
%         if isfield(fld, 't_CET'), t1 = fld.t_CET; else t1 = []; end
%         if isfield(fld, 'Umag_da'), v1 = fld.Umag_da; else v1 = []; end
%         if isfield(fld, 'Udir_da'), d1 = fld.Udir_da; else d1 = []; end
%         if isfield(fld, 'META') && isfield(fld.META, 'RDX'), rdx1 = fld.META.RDX; else rdx1 = []; end
%         if isfield(fld, 'META') && isfield(fld.META, 'RDY'), rdy1 = fld.META.RDY; else rdy1 = []; end
% 
%         if ~isempty(t1), t1 = t1(:); end
% 
%         if ~isempty(t1)
%             nObs = numel(t1);
%             mask = true(nObs,1);
%             if ~isempty(v1) && size(v1,1)==nObs
%                 mask = mask & any(~isnan(v1),2);
%             elseif ~isempty(v1) && isvector(v1)
%                 v1 = v1(:);
%                 if numel(v1)==nObs
%                     mask = mask & ~isnan(v1);
%                 end
%             end
%             if ~isempty(d1) && size(d1,1)==nObs
%                 mask = mask & any(~isnan(d1),2);
%             elseif ~isempty(d1) && isvector(d1)
%                 d1 = d1(:);
%                 if numel(d1)==nObs
%                     mask = mask & ~isnan(d1);
%                 end
%             end
%             t1 = t1(mask,:);
%             if ~isempty(v1) && size(v1,1)==nObs, v1 = v1(mask,:); elseif ~isempty(v1) && numel(v1)==nObs, v1 = v1(mask); end
%             if ~isempty(d1) && size(d1,1)==nObs, d1 = d1(mask,:); elseif ~isempty(d1) && numel(d1)==nObs, d1 = d1(mask); end
%             if ~isempty(rdx1) && numel(rdx1)==nObs, rdx1 = rdx1(mask); end
%             if ~isempty(rdy1) && numel(rdy1)==nObs, rdy1 = rdy1(mask); end
%         else
%             if ~isempty(v1), v1 = v1(~all(isnan(v1),2),:); end
%             if ~isempty(d1), d1 = d1(~all(isnan(d1),2),:); end
%         end
% 
%         if isempty(t1), t1 = []; end
%         if isempty(v1), v1 = []; end
%         if isempty(d1), d1 = []; end
%         if isempty(rdx1), rdx1 = []; end
%         if isempty(rdy1), rdy1 = []; end
% 
%         time1{k} = t1;
%         vel1_da{k} = v1;
%         dir1_da{k} = d1;
%         RDx1{k} = rdx1;
%         RDy1{k} = rdy1;
%     else
%         RDx1{k} = [];
%         RDy1{k} = [];
%     end
% end

%% Zimmerman
% % Build unified list of station fields present in any of the four structures
% siteFields_all = {};
% if isfield(ADCP, 'BATH') && isfield(ADCP.BATH, 'T0')
%     siteFields_all = [siteFields_all; fieldnames(ADCP.BATH.T0)];
% end
% if isfield(ADCP, 'BATH') && isfield(ADCP.BATH, 'T1')
%     siteFields_all = [siteFields_all; fieldnames(ADCP.BATH.T1)];
% end
% if isfield(ADCP, 'ZIMMERMAN') && isfield(ADCP.ZIMMERMAN, 'T0')
%     siteFields_all = [siteFields_all; fieldnames(ADCP.ZIMMERMAN.T0)];
% end
% if isfield(ADCP, 'ZIMMERMAN') && isfield(ADCP.ZIMMERMAN, 'T1')
%     siteFields_all = [siteFields_all; fieldnames(ADCP.ZIMMERMAN.T1)];
% end
% 
% % Unique and keep as column cell array of strings
% if ~isempty(siteFields_all)
%     siteFields_all = unique(siteFields_all);
% else
%     siteFields_all = {};
% end

% %% Exclude non-station fields if any (assume station fields contain 'MP')
% isStation = contains(siteFields_all, 'MP');
% stationNames = siteFields_all(isStation);
% nStations = length(stationNames);
% 
% Zimm_z0 = cell(1, nStations);
% Zimm_z1 = cell(1, nStations);
% 
% for k = 1:nStations
%     s = stationNames{k};
% 
%     % --- Process T0 ---
%     if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'META') && isfield(ADCP.ZIMMERMAN.T0.(s).META, 'ZBED')
%        tempData0 = ADCP.ZIMMERMAN.T0.(s).META.ZBED;
%        % Ensure numeric and remove NaNs
%        if isnumeric(tempData0)
%            Zimm_z0{k} = tempData0(~isnan(tempData0));
%        end
%     end
% 
%     % --- Process T1 ---
%     if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'META') && isfield(ADCP.ZIMMERMAN.T1.(s).META, 'ZBED')
%         tempData1 = ADCP.ZIMMERMAN.T1.(s).META.ZBED;
%         if isnumeric(tempData1)
%             Zimm_z1{k} = tempData1(~isnan(tempData1));
%         end
%     end
% end

%% Velocities Zimm
siteFields = fieldnames(ADCP.ZIMMERMAN.T0);
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
nStations = length(stationNames);

% Preallocate
Zvel0_da = cell(size(stationNames));
Zvel1_da = cell(size(stationNames));

for k = 1:nStations
    s = stationNames{k};

    station_title = strrep(s, 'MP', '');
    % --- 1. Data Extraction & Cleaning ---
    v0 = []; v1 = []; 

    if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'Umag_da')
       temp0 = ADCP.ZIMMERMAN.T0.(s).Umag_da(1,:);
       v0 = temp0(~isnan(temp0));
       Zvel0_da{k} = v0;
    end

    if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'Umag_da')
        temp1 = ADCP.ZIMMERMAN.T1.(s).Umag_da(1,:);
        v1 = temp1(~isnan(temp1));
        Zvel1_da{k} = v1;
    end
end

%% Velocities Bath
siteFields = fieldnames(ADCP.BATH.T0);
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
nStations = length(stationNames);

% Preallocate cell arrays to hold magnitude
Bvel0_da = cell(size(stationNames));
Bvel1_da = cell(size(stationNames));
for k = 1:nStations
    s = stationNames{k};
    station_title = strrep(s, 'MP', '');
    % --- 1. Data Extraction & Cleaning ---
    v0 = []; v1 = []; % Initialize empty for this station

    if isfield(ADCP.BATH.T0, s) && isfield(ADCP.BATH.T0.(s), 'Umag_da')
       temp0 = ADCP.BATH.T0.(s).Umag_da(1,:);
       Bvel0_da = temp0(~isnan(temp0));
    end

    if isfield(ADCP.BATH.T1, s) && isfield(ADCP.BATH.T1.(s), 'Umag_da')
        temp1 = ADCP.BATH.T1.(s).Umag_da(1,:);
        Bvel1_da = temp1(~isnan(temp1));
    end
end

% %% ADCP Observations Zimm
% % Load  data 
% siteFields = fieldnames(ADCP.ZIMMERMAN.T0);
% % Exclude non-station fields if any (assume station fields contain 'MP' or similar)
% isStation = contains(siteFields, 'MP');
% stationNames = siteFields(isStation);
% nStations = length(stationNames);
% 
% % Preallocate cell arrays to hold magnitude
% vel0_da = cell(size(stationNames));
% vel1_da = cell(size(stationNames));
% 
% bins = 0:0.1:1;
% 
% for k = 1:nStations
%     s = stationNames{k};
% 
%     % --- Process T0 ---
%     if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'Umag_da')
%        tempData0 = ADCP.ZIMMERMAN.T0.(s).Umag_da(1,:);
%        % Remove NaNs: "Keep tempData0 where it is NOT NaN"
%        vel0_da{k} = tempData0(~isnan(tempData0));
%     end
% 
%     % --- Process T1 ---
%     if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'Umag_da')
%         tempData1 = ADCP.ZIMMERMAN.T1.(s).Umag_da(1,:);
%         % Remove NaNs
%         vel1_da{k} = tempData1(~isnan(tempData1));
%     end
%     % %--plot--
%     % figure()
%     % % Use {k} instead of (s)
%     % histogram(vel0_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5); 
%     % hold on;
%     % histogram(vel1_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5, 'FaceColor', 'r'); 
%     % 
%     % xlabel('Velocity Magnitude (m/s)');
%     % ylabel('Frequency');
%     % % Dynamic title using the station name string
%     % title(['Bath Velocity Histogram for Station: ' s]); 
%     % legend('T0', 'T1');
%     % hold off;
% 
%     %---for probability--
%     figure()
%     % Use 'Normalization', 'probability' to change the y-axis
%     histogram(vel0_da{k}, 'BinEdges', bins, ...
%         'Normalization', 'probability', ...
%         'FaceAlpha', 0.5, 'FaceColor', 'b'); 
% 
%     hold on;
% 
%     histogram(vel1_da{k}, 'BinEdges', bins, ...
%         'Normalization', 'probability', ...
%         'FaceAlpha', 0.5, 'FaceColor', 'r');
% 
%     xlabel('Velocity Magnitude (m/s)');
%     ylabel('Probability'); % Updated label
%     title(['Velocity Distribution: ' s]);
%     legend('T0', 'T1');
%     hold off;
% end

%% ADCP Observations Zimm - Unified Visualization
siteFields = fieldnames(ADCP.ZIMMERMAN.T0);
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
nStations = length(stationNames);

% Preallocate
vel0_da = cell(size(stationNames));
vel1_da = cell(size(stationNames));
bins = 0:0.2:1;

% Create a large figure for the tiled layout
figure('Units', 'normalized', 'Position', [0.05, 0.05, 0.9, 0.85], ...
       'Name', 'Velocity Histogram Zimm', ... % Added quotes here
       'NumberTitle', 'off', ...               % Removes "Figure 1:" prefix
       'Color', 'w'); 
tlo = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');

for k = 1:nStations
    s = stationNames{k};
    
    station_title = strrep(s, 'MP', '');
    % --- 1. Data Extraction & Cleaning ---
    v0 = []; v1 = []; 
    
    if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'Umag_da')
       temp0 = ADCP.ZIMMERMAN.T0.(s).Umag_da(1,:);
       v0 = temp0(~isnan(temp0));
       vel0_da{k} = v0;
    end
    
    if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'Umag_da')
        temp1 = ADCP.ZIMMERMAN.T1.(s).Umag_da(1,:);
        v1 = temp1(~isnan(temp1));
        vel1_da{k} = v1;
    end
    % --- 1b. Extract ZBED metadata if present ---
    zbed0 = []; zbed1 = [];
    if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'META') && isfield(ADCP.ZIMMERMAN.T0.(s).META, 'ZBED')
        tempMeta0 = ADCP.ZIMMERMAN.T0.(s).META.ZBED;
        % Ensure numeric and remove NaNs
        zbed0 = tempMeta0(~isnan(tempMeta0));
    end
    if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'META') && isfield(ADCP.ZIMMERMAN.T1.(s).META, 'ZBED')
        tempMeta1 = ADCP.ZIMMERMAN.T1.(s).META.ZBED;
        zbed1 = tempMeta1(~isnan(tempMeta1));
    end

    % --- 2. Create Tile for each Station ---
    nexttile;
    
    if ~isempty(v0) || ~isempty(v1)
       % Plot T0
    histogram(v0, 'BinEdges', bins, 'Normalization', 'probability', ...
        'FaceAlpha', 0.4, 'FaceColor', [0 0.447 0.741], 'EdgeColor', 'b');
    hold on;
    
    % Plot T1
    histogram(v1, 'BinEdges', bins, 'Normalization', 'probability', ...
        'FaceAlpha', 0.4, 'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'r');
        
        % Formatting individual tile
        title(station_title, 'FontSize', 40);
        grid on;
        set(gca, 'XTick', [0.2, 0.4, 0.6, 0.8, 1], 'TickDir', 'in', 'FontSize', 17);
        
        % Fix Y-axis limits for better comparison across tiles (Optional)
        ylim([0 0.55]); 
    end
end

% --- 3. Global Labels and Legend ---
xlabel(tlo, 'Velocity Magnitude (m/s)', 'FontSize', 20, 'FontWeight', 'bold');
ylabel(tlo, 'Probability', 'FontSize', 20, 'FontWeight', 'bold');
title(tlo, 'Zimmerman: Velocity Magnitude Probability Distributions', 'FontSize', 28,  'FontWeight', 'bold');

% Shared Legend at the bottom
lg = legend({'T0', 'T1'}, 'Orientation', 'horizontal', 'FontSize', 20);
lg.Layout.Tile = 16;

%% ADCP Observations Bath
% Load  data 
siteFields = fieldnames(ADCP.BATH.T0);
% Exclude non-station fields if any (assume station fields contain 'MP' or similar)
isStation = contains(siteFields, 'MP');
stationNames = siteFields(isStation);
nStations = length(stationNames);

% Preallocate cell arrays to hold magnitude
vel0_da = cell(size(stationNames));
vel1_da = cell(size(stationNames));

bins = 0:0.2:1;

% for k = 1:nStations
%     s = stationNames{k};
% 
%     % --- Process T0 ---
%     if isfield(ADCP.BATH.T0, s) && isfield(ADCP.BATH.T0.(s), 'Umag_da')
%        tempData0 = ADCP.BATH.T0.(s).Umag_da(1,:);
%        % Remove NaNs: "Keep tempData0 where it is NOT NaN"
%        vel0_da{k} = tempData0(~isnan(tempData0));
%     end
% 
%     % --- Process T1 ---
%     if isfield(ADCP.BATH.T1, s) && isfield(ADCP.BATH.T1.(s), 'Umag_da')
%         tempData1 = ADCP.BATH.T1.(s).Umag_da(1,:);
%         % Remove NaNs
%         vel1_da{k} = tempData1(~isnan(tempData1));
%     end
%     % %--plot--
%     % figure()
%     % % Use {k} instead of (s)
%     % histogram(vel0_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5); 
%     % hold on;
%     % histogram(vel1_da{k}, 'BinEdges', bins, 'FaceAlpha', 0.5, 'FaceColor', 'r'); 
%     % 
%     % xlabel('Velocity Magnitude (m/s)');
%     % ylabel('Frequency');
%     % % Dynamic title using the station name string
%     % title(['Bath Velocity Histogram for Station: ' s]); 
%     % legend('T0', 'T1');
%     % hold off;
% 
%     % %---for probability--
%     % figure()
%     % % Use 'Normalization', 'probability' to change the y-axis
%     % histogram(vel0_da{k}, 'BinEdges', bins, ...
%     %     'Normalization', 'probability', ...
%     %     'FaceAlpha', 0.5, 'FaceColor', 'b'); 
%     % 
%     % hold on;
%     % 
%     % histogram(vel1_da{k}, 'BinEdges', bins, ...
%     %     'Normalization', 'probability', ...
%     %     'FaceAlpha', 0.5, 'FaceColor', 'r');
%     % 
%     % xlabel('Velocity Magnitude (m/s)', 'FontSize', 18);
%     % ylabel('Probability', 'FontSize', 18);
%     % title(['Velocity Distribution: ' s], 'FontSize', 24);
%     % 
%     % % 2. Increase Legend size
%     % legend('T0', 'T1', 'FontSize', 16);
%     % 
%     % % 3. Increase Tick Label size (the numbers on the axes)
%     % set(gca, 'FontSize', 14);
%     %     legend('T0', 'T1');
%     %     hold off;
% % end
% 
%     % --- Setup ---
% 
% end 
    % Create one large figure for all stations
    % figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8], 'Name', Vel_Histogram_Bath); 
    figure('Units', 'normalized', ...
       'Position', [0.3, 0.05, 0.6, 0.9], ... %[Left, Bottom, Width, Height]
       'Name', 'Velocity Histogram Bath', ... % Added quotes here
       'NumberTitle', 'off', ...               % Removes "Figure 1:" prefix
       'Color', 'w');                          % Optional: sets background to white
    tlo = tiledlayout(5, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    for k = 1:nStations
        s = stationNames{k};
        station_title = strrep(s, 'MP', '');
        
        % --- 1. Data Extraction & Cleaning ---
        v0 = []; v1 = []; % Initialize empty for this station
        
        if isfield(ADCP.BATH.T0, s) && isfield(ADCP.BATH.T0.(s), 'Umag_da')
           temp0 = ADCP.BATH.T0.(s).Umag_da(1,:);
           v0 = temp0(~isnan(temp0));
        end
        
        if isfield(ADCP.BATH.T1, s) && isfield(ADCP.BATH.T1.(s), 'Umag_da')
            temp1 = ADCP.BATH.T1.(s).Umag_da(1,:);
            v1 = temp1(~isnan(temp1));
        end
        
        % --- 2. Plotting (One Tile per Station) ---
        nexttile;
        
        if ~isempty(v0) || ~isempty(v1)
            % Plot T0
            histogram(v0, 'BinEdges', bins, 'Normalization', 'probability', ...
                'FaceAlpha', 0.4, 'FaceColor', [0 0.447 0.741], 'EdgeColor', 'b');
            hold on;
            
            % Plot T1
            histogram(v1, 'BinEdges', bins, 'Normalization', 'probability', ...
                'FaceAlpha', 0.4, 'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'r');
            
            % Formatting individual tile
             title(station_title, 'FontSize', 16);
           set(gca, 'XTick', [0.2, 0.4, 0.6, 0.8, 1], 'TickDir', 'in', 'FontSize', 12);
           % Automatically scale and add 10% breathing room at the top
            axis tight; 
            yl = ylim; 
            ylim([0, yl(2) * 1.1]);
            grid on;
        end
    end
    
    % --- 3. Global Labels (Shared across all tiles) ---
    xlabel(tlo, 'Velocity Magnitude (m/s)', 'FontSize', 18, 'FontWeight', 'bold');
    ylabel(tlo, 'Probability', 'FontSize', 18, 'FontWeight', 'bold');
    title(tlo, 'Bath: Velocity Magnitude Probability Distributions', 'FontSize', 22,  'FontWeight', 'bold');
    
    % Shared Legend (Placed at the bottom or east of the tiles)
    lg = legend({'T0', 'T1'}, 'Orientation', 'horizontal', 'FontSize', 14);
    lg.Layout.Tile = 20;
    % lg.Layout.Tile = 'south';

% %% categorize ADCPS by Z bed
% % --- Categorize ADCP stations by elevation z0 and z1 into bins and compare velocities ---
% % Using stationNames and nStations from above; extract ZBED from META for each station
% 
% % Convert cell arrays of scalars to numeric column vectors (ignore empty cells)
% % Ensure zbed0 and zbed1 become cell arrays each containing a scalar (or NaN) per station,
% % then convert to numeric arrays for later vertcat usage.
% for k = 1:nStations
%     s = stationNames{k};
%     % initialize as NaN
%     z0val = NaN;
%     z1val = NaN;
%     if isfield(ADCP.BATH.T0, s) && isfield(ADCP.BATH.T0.(s), 'META') && isfield(ADCP.BATH.T0.(s).META, 'ZBED')
%         tmp = ADCP.BATH.T0.(s).META.ZBED;
%         if isnumeric(tmp) && ~isempty(tmp)
%             tmp = tmp(~isnan(tmp));
%             if ~isempty(tmp)
%                 z0val = tmp(1);
%             end
%         end
%     end
%     if isfield(ADCP.BATH.T1, s) && isfield(ADCP.BATH.T1.(s), 'META') && isfield(ADCP.BATH.T1.(s).META, 'ZBED')
%         tmp = ADCP.BATH.T1.(s).META.ZBED;
%         if isnumeric(tmp) && ~isempty(tmp)
%             tmp = tmp(~isnan(tmp));
%             if ~isempty(tmp)
%                 z1val = tmp(1);
%             end
%         end
%     end
%     zbed0{k} = z0val;
%     zbed1{k} = z1val;
% end
% 
% % Convert cell arrays to numeric column vectors
% zbed0 = cell2mat(zbed0(:));
% zbed1 = cell2mat(zbed1(:));
% z0_all = vertcat(zbed0{:});
% z1_all = vertcat(zbed1{:});
% 
% % Create elevation bins (adjust edges as needed)
% zEdges = [-20, -2, -1, 0, 1, 2];  % custom bin edges
% nZBins = numel(zEdges)-1;
% zBinCenters = (zEdges(1:end-1) + zEdges(2:end)) / 2;
% 
% % Count stations per elevation bin for z0 and z1 (count occurrences)
% zCounts0 = histcounts(z0_all, zEdges);
% zCounts1 = histcounts(z1_all, zEdges);
% 
% % Create bar chart showing counts for z0 and z1 side-by-side
% figure('Units','normalized','Position',[0.4 0.4 0.4 0.4],'Color','w');
% hb = bar(zBinCenters, [zCounts0(:), zCounts1(:)], 'grouped');
% colormap([0 0.447 0.741; 0.85 0.325 0.098]);
% hb(1).FaceColor = [0 0.447 0.741];
% hb(2).FaceColor = [0.85 0.325 0.098];
% 
% % Create categorical x-axis labels from zEdges like '-2 to -1', '-1 to 0', etc.
% zLabels = arrayfun(@(a,b) sprintf('%g to %g', a, b), zEdges(1:end-1), zEdges(2:end), 'UniformOutput', false);
% set(gca, 'XTick', zBinCenters, 'XTickLabel', zLabels, 'FontSize', 12);
% xtickangle(45);
% set(gca, 'XTick', zBinCenters, 'FontSize', 12);
% xlabel('Bed Elevation (m)', 'FontSize', 14, 'FontWeight', 'bold');
% ylabel('Number of Stations', 'FontSize', 14, 'FontWeight', 'bold');
% title('Number of Stations per Bed Level (z0 and z1)', 'FontSize', 16, 'FontWeight', 'bold');
% legend({'z0 (T0)','z1 (T1)'}, 'Location', 'best', 'FontSize', 12);
% grid on;

%% associate with velocity_da in boxchart
%peak velocity of vel0 and vel1
peakVel0 = nan(1, nStations);
peakVel1 = nan(1, nStations);
zbin0 = nan(1, nStations);
zbin1 = nan(1, nStations);

for k = 1:nStations
    s = stationNames{k};
    % Extract velocities for this station (reuse earlier logic)
    v0 = [];
    v1 = [];
    if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'Umag_da')
        temp0 = ADCP.ZIMMERMAN.T0.(s).Umag_da(1,:);
        v0 = temp0(~isnan(temp0));
    end
    if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'Umag_da')
        temp1 = ADCP.ZIMMERMAN.T1.(s).Umag_da(1,:);
        v1 = temp1(~isnan(temp1));
    end

    % Peak velocities (NaN when empty)
    if ~isempty(v0)
        peakVel0(k) = max(v0);
    end
    if ~isempty(v1)
        peakVel1(k) = max(v1);
    end

    % Extract ZBED for this station (use NaN when missing)
    z0val = NaN;
    z1val = NaN;
    if isfield(ADCP.ZIMMERMAN.T0, s) && isfield(ADCP.ZIMMERMAN.T0.(s), 'META') && isfield(ADCP.ZIMMERMAN.T0.(s).META, 'ZBED')
        tmp = ADCP.ZIMMERMAN.T0.(s).META.ZBED;
        if isnumeric(tmp) && ~isempty(tmp)
            tmp = tmp(~isnan(tmp));
            if ~isempty(tmp)
                z0val = tmp(1);
            end
        end
    end
    if isfield(ADCP.ZIMMERMAN.T1, s) && isfield(ADCP.ZIMMERMAN.T1.(s), 'META') && isfield(ADCP.ZIMMERMAN.T1.(s).META, 'ZBED')
        tmp = ADCP.ZIMMERMAN.T1.(s).META.ZBED;
        if isnumeric(tmp) && ~isempty(tmp)
            tmp = tmp(~isnan(tmp));
            if ~isempty(tmp)
                z1val = tmp(1);
            end
        end
    end

    zbin0(k) = z0val;
    zbin1(k) = z1val;
end

% Group peak velocities by elevation bins defined by zEdges
zEdges = [-20, -2, -1, 0, 1, 2];
zLabels = arrayfun(@(a,b) sprintf('%g to %g', a, b), zEdges(1:end-1), zEdges(2:end), 'UniformOutput', false);

% For T0: collect peakVel0 into cells per bin
peakByBin0 = cell(1, numel(zEdges)-1);
peakByBin1 = cell(1, numel(zEdges)-1);
[~,~,bins0] = histcounts(zbin0, zEdges);
[~,~,bins1] = histcounts(zbin1, zEdges);

for ib = 1:numel(zEdges)-1
    peakByBin0{ib} = peakVel0(bins0 == ib & ~isnan(peakVel0));
    peakByBin1{ib} = peakVel1(bins1 == ib & ~isnan(peakVel1));
end

% Prepare combined data for boxchart: create categorical x with bin labels repeated for T0 and T1
catLabels = repmat(zLabels(:), 2, 1); % first half T0, second half T1 (but we will plot them side-by-side)
figure('Units','normalized','Position',[0.2 0.2 0.6 0.5],'Color','w');
hold on;

offset = 0.12; % horizontal offset for grouping
xPos = 1:numel(zLabels);

% --- FIX 1: Initialize as empty arrays, not gobjects placeholders ---
legendHandles = [];
legendLabels = {};
repT0 = [];
repT1 = [];

% Plot T0
for ib = 1:numel(zLabels)
    data = peakByBin0{ib};
    if ~isempty(data)
        hb = boxchart(ones(size(data)) * (xPos(ib)-offset), data, 'BoxWidth', 0.2);
        hb.MarkerStyle = 'o';
        hb.BoxFaceColor = [0 0.447 0.741];
        hb.BoxFaceAlpha = 0.6;
        hb.LineWidth = 1;
        
        % Capture the very first valid T0 chart we plot for the legend
        if isempty(repT0)
            repT0 = hb;
        end
    end
end

% Plot T1
for ib = 1:numel(zLabels)
    data = peakByBin1{ib};
    if ~isempty(data)
        hb = boxchart(ones(size(data)) * (xPos(ib)+offset), data, 'BoxWidth', 0.2);
        hb.MarkerStyle = 'o';
        hb.BoxFaceColor = [0.8500 0.3250 0.0980];
        hb.BoxFaceAlpha = 0.6;
        hb.LineWidth = 1;
        
        % Capture the very first valid T1 chart we plot for the legend
        if isempty(repT1)
            repT1 = hb;
        end
    end
end

% --- FIX 2: Clean and direct handle assignment ---
if ~isempty(repT0)
    legendHandles(end+1) = repT0;
    legendLabels{end+1} = 'T0'; 
end
if ~isempty(repT1)
    legendHandles(end+1) = repT1;
    legendLabels{end+1} = 'T1'; 
end

% Formatting Axis
set(gca, 'XTick', xPos, 'XTickLabel', zLabels, 'FontSize', 16);
xtickangle(45);
xlabel('Bed Elevation [m]', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('Max. Depth-Avg Velocity [m/s]', 'FontSize', 16, 'FontWeight', 'bold');
title('Peak Velocity by Bed Elevation: Zimmerman', 'FontSize', 30, 'FontWeight', 'bold');

% --- FIX 3: Robust Legend Creation ---
if ~isempty(legendHandles)
    lg = legend(legendHandles, legendLabels, 'Location', 'northeast', 'FontSize', 20);
    lg.ItemTokenSize = [20, 10];
end

grid off;
hold off;

%% plotting zimm and bath box charts together
sites = {'ZIMMERMAN', 'BATH'};
zEdges = [-20, -2, -1, 0, 1, 2];
zLabels = arrayfun(@(a,b) sprintf('%g to %g', a, b), zEdges(1:end-1), zEdges(2:end), 'UniformOutput', false);

% We will store the binned results for both sites in a structure
siteData = struct();

for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    
    if isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T0')
        sNames = fieldnames(ADCP.(currentSite).T0);
    elseif isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T1')
        sNames = fieldnames(ADCP.(currentSite).T1);
    else
        continue; % Skip if site doesn't exist
    end
    
    nStations = numel(sNames);
    peakVel0 = nan(1, nStations);
    peakVel1 = nan(1, nStations);
    zbin0 = nan(1, nStations);
    zbin1 = nan(1, nStations);
    
    for k = 1:nStations
        s = sNames{k};
        v0 = []; v1 = [];
        
        % Extract velocities (using dynamic field naming for ZIMMERMAN/BATH)
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'Umag_da')
            temp0 = ADCP.(currentSite).T0.(s).Umag_da(1,:);
            v0 = temp0(~isnan(temp0));
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'Umag_da')
            temp1 = ADCP.(currentSite).T1.(s).Umag_da(1,:);
            v1 = temp1(~isnan(temp1));
        end
        
        if ~isempty(v0), peakVel0(k) = max(v0); end
        if ~isempty(v1), peakVel1(k) = max(v1); end
        
        % Extract ZBED
        z0val = NaN; z1val = NaN;
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'META') && isfield(ADCP.(currentSite).T0.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T0.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z0val = tmp(1); end
            end
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'META') && isfield(ADCP.(currentSite).T1.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T1.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z1val = tmp(1); end
            end
        end
        zbin0(k) = z0val;
        zbin1(k) = z1val;
    end
    
    % Binning
    peakByBin0 = cell(1, numel(zEdges)-1);
    peakByBin1 = cell(1, numel(zEdges)-1);
    [~,~,bins0] = histcounts(zbin0, zEdges);
    [~,~,bins1] = histcounts(zbin1, zEdges);
    
    for ib = 1:numel(zEdges)-1
        peakByBin0{ib} = peakVel0(bins0 == ib & ~isnan(peakVel0));
        peakByBin1{ib} = peakVel1(bins1 == ib & ~isnan(peakVel1));
    end
    
    % Save data to structural array for plotting
    siteData.(currentSite).peakByBin0 = peakByBin0;
    siteData.(currentSite).peakByBin1 = peakByBin1;
end

%% 2. Combined Plotting with Subplots
% Initialize a wide canvas layout matching your image
figure('Units','normalized','Position',[0.05 0.2 0.9 0.55],'Color','w');

offset = 0.12; 
xPos = 1:numel(zLabels);

for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    
    % Create subplot: 1 row, 2 columns
    subplot(1, 2, sIdx);
    hold on;
    
    legendHandles = [];
    legendLabels = {};
    repT0 = [];
    repT1 = [];
    
    % Pull binned data
    peakByBin0 = siteData.(currentSite).peakByBin0;
    peakByBin1 = siteData.(currentSite).peakByBin1;
    
    % Plot T0
    for ib = 1:numel(zLabels)
        data = peakByBin0{ib};
        if ~isempty(data)
            hb = boxchart(ones(size(data)) * (xPos(ib)-offset), data, 'BoxWidth', 0.2);
            hb.MarkerStyle = 'o';
            hb.BoxFaceColor = [0 0.447 0.741]; % Blue
            hb.BoxFaceAlpha = 0.6;
            hb.LineWidth = 1;
            if isempty(repT0), repT0 = hb; end
        end
    end
    
    % Plot T1
    for ib = 1:numel(zLabels)
        data = peakByBin1{ib};
        if ~isempty(data)
            hb = boxchart(ones(size(data)) * (xPos(ib)+offset), data, 'BoxWidth', 0.2);
            hb.MarkerStyle = 'o';
            hb.BoxFaceColor = [0.8500 0.3250 0.0980]; % Orange
            hb.BoxFaceAlpha = 0.6;
            hb.LineWidth = 1;
            if isempty(repT1), repT1 = hb; end
        end
    end
    
    % Legend assignment logic per subplot
    if ~isempty(repT0)
        legendHandles(end+1) = repT0;
        legendLabels{end+1} = 'T0'; 
    end
    if ~isempty(repT1)
        legendHandles(end+1) = repT1;
        legendLabels{end+1} = 'T1'; 
    end
    
    % Subplot Formatting
    set(gca, 'XTick', xPos, 'XTickLabel', zLabels, 'FontSize', 14);
    xtickangle(45);
    xlabel('Bed Elevation [m]', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Max. Depth-Avg Velocity [m/s]', 'FontSize', 14, 'FontWeight', 'bold');
    ylim([0 1.6]);
    
    % Proper title casing dynamically based on site string
    siteTitle = [upper(currentSite(1)), lower(currentSite(2:end))];
    title(['Peak Velocity by Bed Elevation: ', siteTitle], 'FontSize', 22, 'FontWeight', 'bold');
    
    if ~isempty(legendHandles)
        lg = legend(legendHandles, legendLabels, 'Location', 'northeast', 'FontSize', 16);
        lg.ItemTokenSize = [15, 8];
    end
    
    grid off;
    hold off;
end

%% one axis (modified: T0 blue, T1 orange; BATH shaded, ZIMMERMAN outline)
sites = {'ZIMMERMAN', 'BATH'};
zEdges = [-20, -2, -1, 0, 1, 2];
zLabels = arrayfun(@(a,b) sprintf('%g to %g', a, b), zEdges(1:end-1), zEdges(2:end), 'UniformOutput', false);

% We will store the binned results for both sites in a structure
siteData = struct();

for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    
    if isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T0')
        sNames = fieldnames(ADCP.(currentSite).T0);
    elseif isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T1')
        sNames = fieldnames(ADCP.(currentSite).T1);
    else
        continue; % Skip if site doesn't exist
    end
    
    nStations = numel(sNames);
    peakVel0 = nan(1, nStations);
    peakVel1 = nan(1, nStations);
    zbin0 = nan(1, nStations);
    zbin1 = nan(1, nStations);
    
    for k = 1:nStations
        s = sNames{k};
        v0 = []; v1 = [];
        
        % Extract velocities (using dynamic field naming for ZIMMERMAN/BATH)
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'Umag_da')
            temp0 = ADCP.(currentSite).T0.(s).Umag_da(1,:);
            v0 = temp0(~isnan(temp0));
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'Umag_da')
            temp1 = ADCP.(currentSite).T1.(s).Umag_da(1,:);
            v1 = temp1(~isnan(temp1));
        end
        
        if ~isempty(v0), peakVel0(k) = max(v0); end
        if ~isempty(v1), peakVel1(k) = max(v1); end
        
        % Extract ZBED
        z0val = NaN; z1val = NaN;
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'META') && isfield(ADCP.(currentSite).T0.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T0.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z0val = tmp(1); end
            end
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'META') && isfield(ADCP.(currentSite).T1.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T1.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z1val = tmp(1); end
            end
        end
        zbin0(k) = z0val;
        zbin1(k) = z1val;
    end
    
    % Binning
    peakByBin0 = cell(1, numel(zEdges)-1);
    peakByBin1 = cell(1, numel(zEdges)-1);
    [~,~,bins0] = histcounts(zbin0, zEdges);
    [~,~,bins1] = histcounts(zbin1, zEdges);
    
    for ib = 1:numel(zEdges)-1
        peakByBin0{ib} = peakVel0(bins0 == ib & ~isnan(peakVel0));
        peakByBin1{ib} = peakVel1(bins1 == ib & ~isnan(peakVel1));
    end
    
    % Save data to structural array for plotting
    siteData.(currentSite).peakByBin0 = peakByBin0;
    siteData.(currentSite).peakByBin1 = peakByBin1;
end

%% 2. Combined Plotting on one axis with style rules:
% Initialize a wide canvas layout matching your image
figure('Units','normalized','Position',[0.05 0.2 0.9 0.55],'Color','w');

offset = 0.12; 
xPos = 1:numel(zLabels);

% create single axes occupying the figure
ax = axes('Position',[0.08 0.12 0.85 0.78]);
hold(ax, 'on');

legendHandles = [];
legendLabels = {};

% Colors
colorT0 = [0 0.447 0.741]; % Blue
colorT1 = [0.8500 0.3250 0.0980]; % Orange
shadeAlpha = 0.6;

% Plot order: for visibility plot shaded BATH first, then outlined ZIMMERMAN
% To avoid exact overlap between BATH and ZIMMERMAN at same x coordinate,
% nudge ZIMMERMAN slightly left and BATH slightly right (per time) so their
% boxcharts are horizontally separated across the same z-bin positions.
nudge = 0.06; % additional horizontal offset to separate sites
for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    peakByBin0 = siteData.(currentSite).peakByBin0;
    peakByBin1 = siteData.(currentSite).peakByBin1;
    
    isBath = strcmpi(currentSite, 'BATH');
    isZimm = strcmpi(currentSite, 'ZIMMERMAN');
    
    % Determine site-specific horizontal adjustment
    % BATH: shift slightly right; ZIMMERMAN: shift slightly left
    siteShift = 0;
    if isBath
        siteShift = +nudge;
    elseif isZimm
        siteShift = -nudge;
    end
    
    % T0 (blue)
    repT0 = [];
    for ib = 1:numel(zLabels)
        data = peakByBin0{ib};
        if ~isempty(data)
            x = ones(size(data)) * (xPos(ib)-offset + siteShift);
            hb = boxchart(ax, x, data, 'BoxWidth', 0.18);
            hb.MarkerStyle = 'o';
            hb.LineWidth = 1;
            if isBath
                hb.BoxFaceColor = colorT0;
                hb.BoxFaceAlpha = shadeAlpha;
                hb.MarkerColor = colorT0;
            elseif isZimm
                hb.BoxFaceColor = 'none';
                hb.BoxEdgeColor = colorT0;
                hb.MarkerColor = colorT0;
            else
                hb.BoxFaceColor = colorT0;
                hb.BoxFaceAlpha = shadeAlpha;
            end
            if isempty(repT0), repT0 = hb; end
        end
    end
    
    % T1 (orange)
    repT1 = [];
    for ib = 1:numel(zLabels)
        data = peakByBin1{ib};
        if ~isempty(data)
            x = ones(size(data)) * (xPos(ib)+offset + siteShift);
            hb = boxchart(ax, x, data, 'BoxWidth', 0.18);
            hb.MarkerStyle = 'o';
            hb.LineWidth = 1;
            if isBath
                hb.BoxFaceColor = colorT1;
                hb.BoxFaceAlpha = shadeAlpha;
                hb.MarkerColor = colorT1;
            elseif isZimm
                hb.BoxFaceColor = 'none';
                hb.BoxEdgeColor = colorT1;
                hb.MarkerColor = colorT1;
            else
                hb.BoxFaceColor = colorT1;
                hb.BoxFaceAlpha = shadeAlpha;
            end
            if isempty(repT1), repT1 = hb; end
        end
    end
    
    % Collect legend handles once per time (avoid duplicate entries)
    if ~isempty(repT0) && ~any(arrayfun(@(h) isequal(h,repT0), legendHandles))
        legendHandles(end+1) = repT0; %#ok<SAGROW>
        legendLabels{end+1} = ['T0 - ' currentSite];
    end
    if ~isempty(repT1) && ~any(arrayfun(@(h) isequal(h,repT1), legendHandles))
        legendHandles(end+1) = repT1; %#ok<SAGROW>
        legendLabels{end+1} = ['T1 - ' currentSite];
    end
end

% Final formatting for the single axes
set(ax, 'XTick', xPos, 'XTickLabel', zLabels, 'FontSize', 14);
xtickangle(ax,45);
xlabel(ax, 'Bed Elevation [m]', 'FontSize', 16, 'FontWeight', 'bold');
ylabel(ax, 'Max. Depth-Avg Velocity [m/s]', 'FontSize', 14, 'FontWeight', 'bold');
ylim(ax, [0 1.6]);

title(ax, 'Peak Velocity by Bed Elevation: BATH (shaded) and ZIMMERMAN (outline)', 'FontSize', 20, 'FontWeight', 'bold');

if ~isempty(legendHandles)
    lg = legend(ax, legendHandles, legendLabels, 'Location', 'northeast', 'FontSize', 14);
    lg.ItemTokenSize = [15, 8];
end

grid(ax, 'off');
hold(ax, 'off');


% %% 1. Define the directory
% png_dir = "P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\";
% 
% % 2. Ensure the directory exists (prevents error if folder is missing)
% if ~exist(png_dir, 'dir')
%     mkdir(png_dir);
% end
% 
% % 3. Define the filename (e.g., using the figure name)
% figName = "Velocity_Histogram_Zimm"; 
% fullPath = fullfile(png_dir, figName + ".png");
% 
% % 4. Export with high resolution (300 DPI is standard for reports)
% exportgraphics(gcf, fullPath, 'Resolution', 300);

%% peak median min vel one axis (modified: T0 blue, T1 orange; BATH shaded, ZIMMERMAN outline)
sites = {'ZIMMERMAN', 'BATH'};
zEdges = [-20, -2, -1, 0, 1, 2];
zLabels = arrayfun(@(a,b) sprintf('%g to %g', a, b), zEdges(1:end-1), zEdges(2:end), 'UniformOutput', false);

% We will store the binned results for both sites in a structure
siteData = struct();
for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    
    if isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T0')
        sNames = fieldnames(ADCP.(currentSite).T0);
    elseif isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T1')
        sNames = fieldnames(ADCP.(currentSite).T1);
    else
        continue; % Skip if site doesn't exist
    end
    
    nStations = numel(sNames);
    
    % Initialize cells to collect the 3 descriptive stats per station dynamically
    statVel0 = cell(1, nStations);
    statVel1 = cell(1, nStations);
    zbin0 = nan(1, nStations);
    zbin1 = nan(1, nStations);
    
    for k = 1:nStations
        s = sNames{k};
        v0 = []; v1 = [];
        
        % Extract velocities
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'Umag_da')
            temp0 = ADCP.(currentSite).T0.(s).Umag_da(1,:);
            v0 = temp0(~isnan(temp0));
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'Umag_da')
            temp1 = ADCP.(currentSite).T1.(s).Umag_da(1,:);
            v1 = temp1(~isnan(temp1));
        end
        
        % --- CHANGED LOGIC: Capture Max, Median, and Min per station ---
        if ~isempty(v0)
            statVel0{k} = [max(v0), median(v0), min(v0)];
        else
            statVel0{k} = [];
        end
        if ~isempty(v1)
            statVel1{k} = [max(v1), median(v1), min(v1)];
        else
            statVel1{k} = [];
        end
        
        % Extract ZBED
        z0val = NaN; z1val = NaN;
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'META') && isfield(ADCP.(currentSite).T0.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T0.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z0val = tmp(1); end
            end
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'META') && isfield(ADCP.(currentSite).T1.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T1.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z1val = tmp(1); end
            end
        end
        zbin0(k) = z0val;
        zbin1(k) = z1val;
    end
    
    % Binning
    peakByBin0 = cell(1, numel(zEdges)-1);
    peakByBin1 = cell(1, numel(zEdges)-1);
    [~,~,bins0] = histcounts(zbin0, zEdges);
    [~,~,bins1] = histcounts(zbin1, zEdges);
    
    for ib = 1:numel(zEdges)-1
        % Flatten the pooled station stats (Max, Med, Min) belonging to this elevation bin
        validIndices0 = (bins0 == ib & ~cellfun(@isempty, statVel0));
        if any(validIndices0)
            peakByBin0{ib} = cell2mat(statVel0(validIndices0));
        else
            peakByBin0{ib} = [];
        end
        
        validIndices1 = (bins1 == ib & ~cellfun(@isempty, statVel1));
        if any(validIndices1)
            peakByBin1{ib} = cell2mat(statVel1(validIndices1));
        else
            peakByBin1{ib} = [];
        end
    end
    
    % Save data to structural array for plotting
    siteData.(currentSite).peakByBin0 = peakByBin0;
    siteData.(currentSite).peakByBin1 = peakByBin1;
end

%% 2. Combined Plotting on one axis with style rules:
figure('Units','normalized','Position',[0.05 0.2 0.9 0.55],'Color','w');
offset = 0.12; 
xPos = 1:numel(zLabels);
ax = axes('Position',[0.08 0.12 0.85 0.78]);
hold(ax, 'on');

legendHandles = [];
legendLabels = {};

colorT0 = [0 0.447 0.741]; % Blue
colorT1 = [0.8500 0.3250 0.0980]; % Orange
shadeAlpha = 0.6;
nudge = 0.06; 

for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    peakByBin0 = siteData.(currentSite).peakByBin0;
    peakByBin1 = siteData.(currentSite).peakByBin1;
    
    isBath = strcmpi(currentSite, 'BATH');
    isZimm = strcmpi(currentSite, 'ZIMMERMAN');
    
    siteShift = 0;
    if isBath
        siteShift = +nudge;
    elseif isZimm
        siteShift = -nudge;
    end
    
    % T0 (blue)
    repT0 = [];
    for ib = 1:numel(zLabels)
        data = peakByBin0{ib};
        if ~isempty(data)
            x = ones(size(data)) * (xPos(ib)-offset + siteShift);
            hb = boxchart(ax, x, data, 'BoxWidth', 0.18);
            hb.MarkerStyle = 'o';
            hb.LineWidth = 1;
            if isBath
                hb.BoxFaceColor = colorT0;
                hb.BoxFaceAlpha = shadeAlpha;
                hb.MarkerColor = colorT0;
            elseif isZimm
                hb.BoxFaceColor = 'none';
                hb.BoxEdgeColor = colorT0;
                hb.MarkerColor = colorT0;
            else
                hb.BoxFaceColor = colorT0;
                hb.BoxFaceAlpha = shadeAlpha;
            end
            if isempty(repT0), repT0 = hb; end
        end
    end
    
    % T1 (orange)
    repT1 = [];
    for ib = 1:numel(zLabels)
        data = peakByBin1{ib};
        if ~isempty(data)
            x = ones(size(data)) * (xPos(ib)+offset + siteShift);
            hb = boxchart(ax, x, data, 'BoxWidth', 0.18);
            hb.MarkerStyle = 'o';
            hb.LineWidth = 1;
            if isBath
                hb.BoxFaceColor = colorT1;
                hb.BoxFaceAlpha = shadeAlpha;
                hb.MarkerColor = colorT1;
            elseif isZimm
                hb.BoxFaceColor = 'none';
                hb.BoxEdgeColor = colorT1;
                hb.MarkerColor = colorT1;
            else
                hb.BoxFaceColor = colorT1;
                hb.BoxFaceAlpha = shadeAlpha;
            end
            if isempty(repT1), repT1 = hb; end
        end
    end
    
    if ~isempty(repT0) && ~any(arrayfun(@(h) isequal(h,repT0), legendHandles))
        legendHandles(end+1) = repT0; %#ok<SAGROW>
        legendLabels{end+1} = ['T0 - ' currentSite];
    end
    if ~isempty(repT1) && ~any(arrayfun(@(h) isequal(h,repT1), legendHandles))
        legendHandles(end+1) = repT1; %#ok<SAGROW>
        legendLabels{end+1} = ['T1 - ' currentSite];
    end
end

% Final formatting for the single axes
set(ax, 'XTick', xPos, 'XTickLabel', zLabels, 'FontSize', 14);
xtickangle(ax,45);
xlabel(ax, 'Bed Elevation [m]', 'FontSize', 16, 'FontWeight', 'bold');
ylabel(ax, 'Velocity Stats (Min, Med, Max) [m/s]', 'FontSize', 14, 'FontWeight', 'bold');
ylim(ax, [0 1.6]);
title(ax, 'Velocity Statistics by Bed Elevation: BATH (shaded) and ZIMMERMAN (outline)', 'FontSize', 16, 'FontWeight', 'bold');

if ~isempty(legendHandles)
    lg = legend(ax, legendHandles, legendLabels, 'Location', 'northeast', 'FontSize', 14);
    lg.ItemTokenSize = [15, 8];
end
grid(ax, 'off');
hold(ax, 'off');

%% seaprate bath and zimm plotting peak, min, median
sites = {'BATH', 'ZIMMERMAN'};
zEdges = [-20, -2, -1, 0, 1, 2];
zLabels = arrayfun(@(a,b) sprintf('%g to %g', a, b), zEdges(1:end-1), zEdges(2:end), 'UniformOutput', false);

% Structure to store the compiled descriptive stats per site
siteData = struct();

for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    
    % % Dynamically fetch the correct station names for the active site
    % if isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T0')
    %     sNames = fieldnames(ADCP.(currentSite).T0);
    % elseif isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T1')
    %     sNames = fieldnames(ADCP.(currentSite).T1);
    % else
    %     continue; % Skip if site data is missing
    % end
    
    sNamesT0 = {};
    sNamesT1 = {};
    if isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T0')
        sNamesT0 = fieldnames(ADCP.(currentSite).T0);
    end
    if isfield(ADCP, currentSite) && isfield(ADCP.(currentSite), 'T1')
        sNamesT1 = fieldnames(ADCP.(currentSite).T1);
    end
    
    % Combine them and keep only unique names
    sNames = unique([sNamesT0; sNamesT1]);
    
    if isempty(sNames)
        continue; % Skip if neither T0 nor T1 has stations
    end
    
    nStations = numel(sNames);
    nStations = numel(sNames);
    
    % Use cell arrays to store 3-element stat vectors [Max, Med, Min] per station
    statVel0 = cell(1, nStations);
    statVel1 = cell(1, nStations);
    zbin0 = nan(1, nStations);
    zbin1 = nan(1, nStations);
    
    for k = 1:nStations
        s = sNames{k};
        v0 = []; v1 = [];
        
        % Extract depth-averaged velocities
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'Umag_da')
            temp0 = ADCP.(currentSite).T0.(s).Umag_da(1,:);
            v0 = temp0(~isnan(temp0));
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'Umag_da')
            temp1 = ADCP.(currentSite).T1.(s).Umag_da(1,:);
            v1 = temp1(~isnan(temp1));
        end
        
        % Capture percentiles 5th, 25th, 50th, 75th, and 95th for each individual station
        if ~isempty(v0)
            p = prctile(v0, [0 25 50 75 100]);
            statVel0{k} = p(:)'; % store as row vector [5,25,50,75,95]
        end
        if ~isempty(v1)
            p = prctile(v1, [0 25 50 75 100]);
            statVel1{k} = p(:)'; % store as row vector [5,25,50,75,95]
        end
        
        % Extract Bed Elevation (ZBED)
        z0val = NaN; z1val = NaN;
        if isfield(ADCP.(currentSite).T0, s) && isfield(ADCP.(currentSite).T0.(s), 'META') && isfield(ADCP.(currentSite).T0.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T0.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z0val = tmp(1); end
            end
        end
        if isfield(ADCP.(currentSite).T1, s) && isfield(ADCP.(currentSite).T1.(s), 'META') && isfield(ADCP.(currentSite).T1.(s).META, 'ZBED')
            tmp = ADCP.(currentSite).T1.(s).META.ZBED;
            if isnumeric(tmp) && ~isempty(tmp)
                tmp = tmp(~isnan(tmp)); if ~isempty(tmp), z1val = tmp(1); end
            end
        end
        zbin0(k) = z0val;
        zbin1(k) = z1val;
    end
    
    % Group metrics into elevation bins
    peakByBin0 = cell(1, numel(zEdges)-1);
    peakByBin1 = cell(1, numel(zEdges)-1);
    [~,~,bins0] = histcounts(zbin0, zEdges);
    [~,~,bins1] = histcounts(zbin1, zEdges);
    
    for ib = 1:numel(zEdges)-1
        % Unroll and flatten station cell arrays belonging to this bin
        validIdx0 = (bins0 == ib & ~cellfun(@isempty, statVel0));
        if any(validIdx0), peakByBin0{ib} = cell2mat(statVel0(validIdx0)); end
        
        validIdx1 = (bins1 == ib & ~cellfun(@isempty, statVel1));
        if any(validIdx1), peakByBin1{ib} = cell2mat(statVel1(validIdx1)); end
    end
    
    % Store binned datasets back into our global plotting structure
    siteData.(currentSite).peakByBin0 = peakByBin0;
    siteData.(currentSite).peakByBin1 = peakByBin1;
end

%% 2. Side-by-Side Plotting Layout
% Create a wide format canvas suitable for subplots
figure('Units','normalized','Position',[0.05 0.2 0.9 0.55],'Color','w');

offset = 0.12; 
xPos = 1:numel(zLabels);

% Standard visual colors
colorT0 = [0 0.447 0.741];        % Blue
colorT1 = [0.8500 0.3250 0.0980]; % Orange
shadeAlpha = 0.6;

for sIdx = 1:numel(sites)
    currentSite = sites{sIdx};
    
    % Initialize 1x2 Subplot matrix grid
    subplot(1, 2, sIdx);
    hold on;
    
    legendHandles = [];
    legendLabels = {};
    repT0 = [];
    repT1 = [];
    
    peakByBin0 = siteData.(currentSite).peakByBin0;
    peakByBin1 = siteData.(currentSite).peakByBin1;
    
    % Plot T0 (Blue Boxplots)
    for ib = 1:numel(zLabels)
        data = peakByBin0{ib};
        if ~isempty(data)
            hb = boxchart(ones(size(data)) * (xPos(ib)-offset), data, 'BoxWidth', 0.2);
            hb.MarkerStyle = 'none';
            hb.BoxFaceColor = colorT0;
            hb.BoxFaceAlpha = shadeAlpha;
            hb.LineWidth = 1;
            if isempty(repT0), repT0 = hb; end
        end
    end
    
    % Plot T1 (Orange Boxplots)
    for ib = 1:numel(zLabels)
        data = peakByBin1{ib};
        if ~isempty(data)
            hb = boxchart(ones(size(data)) * (xPos(ib)+offset), data, 'BoxWidth', 0.2);
            hb.MarkerStyle = 'none';
            hb.BoxFaceColor = colorT1;
            hb.BoxFaceAlpha = shadeAlpha;
            hb.LineWidth = 1;
            if isempty(repT1), repT1 = hb; end
        end
    end
    
    % Clean legend handle accumulation
    if ~isempty(repT0)
        legendHandles(end+1) = repT0;
        legendLabels{end+1} = 'T0'; 
    end
    if ~isempty(repT1)
        legendHandles(end+1) = repT1;
        legendLabels{end+1} = 'T1'; 
    end
    
    % Formatting and labels for the active Subplot
    set(gca, 'XTick', xPos, 'XTickLabel', zLabels, 'FontSize', 14);
    xtickangle(45);
    xlabel('Bed Elevation [m NAP]', 'FontSize', 16, 'FontWeight', 'bold');
    ylim([0 2]);
      
    % Only label y-axis on the second subplot (and only plot data for the second subplot)
    if sIdx == 1
        ylabel('Depth Avg Velocity [m/s]', 'FontSize', 16, 'FontWeight', 'bold');
    end

    % Add a gray horizontal reference line at y = 0.6
    hRef = yline(0.6, 'Color', [0.8 0.8 0.8], 'LineWidth', 1.5, 'LineStyle', '-');
    % Add the reference line to legend handles/labels so it can be shown when legend is created
    if exist('legendHandles','var') && exist('legendLabels','var')
        legendHandles(end+1) = hRef;
        legendLabels{end+1} = '0.6 m/s';
    end
    
    % Dynamically title each chart using proper casing syntax
    siteTitle = [upper(currentSite(1)), lower(currentSite(2:end))];
    title(siteTitle, 'FontSize', 20, 'FontWeight', 'normal', 'FontAngle', 'italic');

    % Add a single big title across the entire figure (centered above subplots)
    sgt = sgtitle('Velocity Distribution across Bed Elevation', 'FontSize', 24, 'FontWeight', 'bold');
    % Adjust position slightly upward for better spacing
    % sgt.Position(2) = 0.95;
    
    % Only add legend on the second subplot (sIdx == 2)
    if sIdx == 2 && ~isempty(legendHandles)
        lg = legend(legendHandles, legendLabels, 'Location', 'northeast', 'FontSize', 16);
        lg.ItemTokenSize = [15, 8];
    end
    
    grid off;
    hold off;
end