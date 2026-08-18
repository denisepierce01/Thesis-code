% <Name of script>
% Contact: Reinier.Schrijvershof@deltares.nl
% Output:
% 1. 
% 2.

if ~exist('oetsettings.m')
    error('Script assumes Open Earth Tools are added to your MATLAB session');
end

addpath(genpath('../_functions/'))
    
clear all; close all; clc;

%%%%%%%%%%%%%%%%%%%%%%
% Settings to Adjust %
%%%%%%%%%%%%%%%%%%%%%%
% Setting on models, directories, and output
SET                 = struct;
SET.sims            = {...
    % 'P:\11207654-internship-pierce-2026\03_Model\15_T0_fou_Apr18\';
    'P:\11207654-internship-pierce-2026\03_Model\17_T0bathy_T1groynes_fou_Apr18\'};
    % 'P:\11207654-internship-pierce-2026\03_Model\16_T1_fou_Apr18\'};
SET.legStr          = {'T0wGroynes'};
% SET.legStr          = {'T0','T0wGroynes','T1'};
SET.savePath        = 'P:\11207654-internship-pierce-2026\03_Model\ModelOutput\Comparisons\T0_T1\'; % Locations where sub save dirs are made
SET.compareSubDir   = ''; % Optional: theme of the intercomparison (e.g. sensi_n)
% Logical switches
SET.plotModels      = 1; % Plot figures for given models separately
SET.plotComparison  = 1; % Plot figures for comparing given models
SET.calculateRunTimes = 1;
% Time interval
SET.t1              = datenum(2018,04,22,00,00,00); % Time for analysis
SET.t2              = datenum(2018,04,23,00,00,00);
% Limits for map output
SET.XL              = [];
SET.YL              = []; 
SET.CL              = [-25 5];         
SET.CLerosed        = [-10 10];
% Observation stations wanted
% SET.Stats           = {'AQD01','AQD02','AQD03','AQD04','AQD05','AQD06','AQD07','AQD08','AQD09'};
SET.StatsLegStr     = {''}; % If station names not appropiate
% Observations cross-sections wanted
SET.StatsCS         = {''};
SET.StatsCSLegStr   = {''};

% Other information
SET.ldbFile     = 'P:\11207654-internship-pierce-2026\03_Model\11_T0bathy_T0groynes_Apr18\nevla_j19_6-w6a_incl_monding_bathy_interp_no_rivers_BathOssZimm_j2018.xyz'; % or ldb file
SET.bathyFile   = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Vaklodingen\WS_1955-2023.mat';
SET.HPpol       = 'P:\11207654-internship-pierce-2026\02_Data\Study_area_boundaries\location_bath.shp';
SET.obsFile     = 'P:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat';

% % Make directories and filenames to store results
% [SET.figDirSim,SET.figDirComb,SET.subSims] = postTools.makeModelOutputDirs(SET.sims,SET.savePath,SET.plotModels,SET.plotComparison,SET.compareSubDir);

% =========================================================================
% REPLACEMENT FOR missing postTools.makeModelOutputDirs
% =========================================================================
% 1. Initialize output containers
SET.figDirSim  = cell(size(SET.sims));
SET.subSims    = cell(size(SET.sims));
SET.figDirComb = ''; % Default fallback

% 2. Loop through each simulation name to create individual output paths
for idxSim = 1:numel(SET.sims)
    currentSim = SET.sims{idxSim};
    
    % If the sim path is a full file path, extract just the folder/run name
    [~, simName, ~] = fileparts(currentSim);
    SET.subSims{idxSim} = simName;
    
    % Construct the path for individual simulation figures
    if SET.plotModels
        simDir = fullfile(SET.savePath, simName);
        if ~exist(simDir, 'dir')
            mkdir(simDir); % Create the folder on your computer if it doesn't exist
        end
        SET.figDirSim{idxSim} = simDir;
    else
        SET.figDirSim{idxSim} = SET.savePath;
    end
end

% 3. Construct and create the comparison/combined directory path if requested
if SET.plotComparison
    % Use compareSubDir if provided, otherwise default to a 'Comparison' folder
    if isfield(SET, 'compareSubDir') && ~isempty(SET.compareSubDir)
        combDirName = SET.compareSubDir;
    else
        combDirName = 'Comparison';
    end
    
    combDir = fullfile(SET.savePath, combDirName);
    if ~exist(combDir, 'dir')
        mkdir(combDir);
    end
    SET.figDirComb = combDir;
else
    SET.figDirComb = SET.savePath; 
end

%% Load model data
fprintf('\tLoading model data...\n');

% Directory structure
in = ''; 
out = '/output/';

sigma_layers = [2 3 5 8 10 12 15 15 15 15];
sigma_weights = reshape(sigma_layers, 1, 1, 10);

clear MAP HIS FOU;
MAP = struct; HIS = struct; FOU = struct; info = struct;
for i = 1:length(SET.sims)
    tic;

    matFile = sprintf('MAPdata_%s.mat',SET.subSims{i});
    matFouFile = sprintf('FOUdata_%s.mat',SET.subSims{i});
    if exist([SET.sims{i},out,matFile],'file')
        fprintf('\tLoading data from mat file for %s\n',SET.subSims{i})
        % MAPdata = [];
        load([SET.sims{i},out,matFile]);
        % MAP(i).data = MAPdata;
        FOUdata = [];
        load([SET.sims{i},out,matFouFile]);
        FOU(i).data = FOUdata;
    else

        % Filenames
        % mduFile  = cellstr(ls([SET.sims{i},in,'*.mdu']));
        % netFile  = cellstr(ls([SET.sims{i},in,'*_net.nc']));
        % diaFile  = cellstr(ls([SET.sims{i},out,'*.dia']));
        % hisFile  = cellstr(ls([SET.sims{i},out,'*_his.nc']));
        % mapFile  = cellstr(ls([SET.sims{i},out,'*_map.nc']));
        fouFile  = cellstr(ls([SET.sims{i},out,'*_fou.nc']));

        % if SET.calculateRunTimes
        %     % Status and computational times
        %     info = EHY_runTimeInfo([SET.sims{i},in,mduFile{1}]);
        %     if isfield(info,'realTime_D')
        %         fprintf('\tModel takes 1 real-world day for %.1f simulation days\n',24*60/info.compTime_minPerDay);
        %     else
        %         if length(diaFile) == 1
        %             dia = fileread([SET.sims{i},out,'\',diaFile{1}]);
        %         else
        %             dia = fileread([SET.sims{i},out,'\',diaFile{2}]);
        %         end
        %         id1                     = strfind(dia,'** INFO   : Modelinit finished   at:');
        %         dirInfo                 = dir([SET.sims{i},out,'\',hisFile{1}]);
        %         info.realStartDate      = dia(id1+37:id1+56);
        %         info.realStartDateDN    = datenum([info.realStartDate(end-9:end),' ',info.realStartDate(1:8)],'dd-mm-yyyy HH:MM:SS');
        %         info.realStopDateDN     = dirInfo.datenum;
        %         info.daysSimulated      = ( (str2double(info.status(1:end-1))/100)*info.simPeriod_D );
        %         info.daysComputational  = info.realStopDateDN - info.realStartDateDN;
        %         info.compRatio = info.daysSimulated/info.daysComputational;
        %         fprintf('\tModel takes 1 real-world day for %.1f simulation days\n',info.compRatio);
        %     end
        % 
        % end

        %%% FOU file
        FOU(i).data.grid = EHY_getGridInfo([SET.sims{i},out,'\',fouFile{1}],...
            {'face_nodes_xy','XYcen'});

        % Filter out required fields
        info = ncinfo([SET.sims{i},out,'\',fouFile{1}]);
        long_name_all = [];
        for j = 1:length(info.Variables)
            if any(strcmp({info.Variables(j).Attributes.Name},'long_name'))
                id = strcmp({info.Variables(j).Attributes.Name},'long_name');
                long_name_all{j,1} = info.Variables(j).Attributes(id).Value;
            end
        end
        idx         = ~cellfun('isempty', regexp(long_name_all, 'velocity magnitude.*cumulative time below|cumulative time below.*velocity magnitude', 'once'));
        short_name  = {info.Variables(idx).Name}';
        long_name   = long_name_all(idx);

        FOU(i).data.tau.short_name = short_name;
        FOU(i).data.tau.long_name = long_name;
        % Load data
        for j = 1:length(short_name)
            % Time below threshold
            data = [];
            data = EHY_getMapModelData([SET.sims{i},out,'\',fouFile{1}],'varName',short_name{j});
            depth_avg = sum(data.val .* (sigma_weights / 100), 3);
            FOU(i).data.tau.valTimeBelow(:,j) = depth_avg(:);
        end

        % Save the file to mat file    
        FOUdata = [];
        FOUdata = FOU(i).data;
        save([SET.sims{i},out,matFouFile],'FOUdata');
        

        % %%% MAP file
        % % Network
        % MAP(i).data.grid = EHY_getGridInfo([SET.sims{i},out,'\',mapFile{end}],...
        %     {'face_nodes_xy','XYcen'});
        % % Bed level
        % % data = EHY_getMapModelData([SET.sims{i},out,'\',mapFile{1}],...
        %     % 'varName','dps'); % Bed level
        % % MAP(i).bed      = data.val;
        % % Water depth
        % data = EHY_getMapModelData([SET.sims{i},out,'\',mapFile{1}],...
        %     'varName','wd'); % Bed level
        % MAP(i).data.wd      = data.val;
        % % Water level
        % data = EHY_getMapModelData([SET.sims{i},out,'\',mapFile{1}],...
        %     'varName','wl'); % Bed level
        % MAP(i).data.wl      = data.val;
        % % Velocities
        % data = EHY_getMapModelData([SET.sims{i},out,'\',mapFile{1}],...
        %     'varName','uv'); % Velocities
        % MAP(i).data.Time     = data.times;
        % MAP(i).data.vel.u    = data.vel_x;
        % MAP(i).data.vel.v    = data.vel_y;
        % MAP(i).data.vel.mag  = data.vel_mag;
        % MAP(i).data.vel.dir  = data.vel_dir;
        % % Tau_s
        % data1 = EHY_getMapModelData([SET.sims{i},out,'\',mapFile{1}],...
        %     'varName','mesh2d_tausx');
        % data2 = EHY_getMapModelData([SET.sims{i},out,'\',mapFile{1}],...
        %     'varName','mesh2d_tausy');
        % MAP(i).data.taus      = data1;
        % % MAP(i).data.taus      = rmfield(MAP(i).data.tau,'val');
        % MAP(i).data.taus.u    = data1.val;
        % MAP(i).data.taus.v    = data2.val;
        % 
        % % Tau_b (only magnitude)
        % data = EHY_getMapModelData([SET.sims{i},out,'\',mapFile{1}],...
        %     'varName','mesh2d_taub');
        % MAP(i).data.taub      = data;
        % 
        % % Save the file to mat file
        % MAPdata = [];
        % MAPdata = MAP(i).data;
        % save([SET.sims{i},out,matFile],'MAPdata','-v7.3');
        
    end
    % fprintf('\tLoading took %.1f minutes\n',toc/60); % took ~1 hour!

end

% %% Load other data
% load(SET.bathyFile);
% 
% HP = [];
% data = m_shaperead(SET.HPpol(1:end-4));
% HP.pol = data.ncst{1};
% 
% ldbF = landboundary('read',SET.ldbFile);
% 
% % Load observations Hond-Paap
% load(SET.obsFile);

%% Load other data
load(SET.bathyFile);

HP = [];
data = m_shaperead(SET.HPpol(1:end-4));
HP.pol = data.ncst{1};

% Read XYZ file instead of .ldb (allow .xyz, .dat, .txt). If file exists, load as columns X Y (Z optional).
ldbF = [];
if exist(SET.ldbFile,'file')
    [~,~,ext] = fileparts(SET.ldbFile);
    try
        if strcmpi(ext,'.ldb')
            % Keep existing behavior if a proper .ldb is provided
            ldbF = landboundary('read',SET.ldbFile);
        elseif any(strcmpi(ext,{'.xyz','.dat','.txt'}))
            % Simple XYZ reader: try readmatrix first; if it fails due to
            tbl = [];
            try
                tbl = readmatrix(SET.ldbFile);
            catch
                % Attempt to read as whitespace-delimited numeric file
                fid = fopen(SET.ldbFile,'r');
                if fid ~= -1
                    data = textscan(fid, '%f%f%f%*[^\n]', 'CollectOutput', true);
                    fclose(fid);
                    if ~isempty(data) && ~isempty(data{1})
                        tbl = data{1};
                    end
                end
            end

            if isempty(tbl) || size(tbl,2) < 2
                warning('ldbFile:invalidXYZ','%s does not contain at least two columns. ldbF set empty.',SET.ldbFile);
            else
                ldbF.X = tbl(:,1);
                ldbF.Y = tbl(:,2);
                if size(tbl,2) >= 3
                    ldbF.Z = tbl(:,3);
                end
            end
        end
    end
end

load(SET.obsFile);

%% vaklodingen 2018 only
vaklodingen  = load('P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Vaklodingen\WS_1955-2023.mat');

targetYear = 2018; 
yearIdx = find(vaklodingen.grd.year == targetYear);

% 2. Initialize the clean 'D' structure for your calculation script
D = struct;

% 3. Map the spatial grid coordinates directly
D.x = vaklodingen.grd.x;
D.y = vaklodingen.grd.y;
D.z = vaklodingen.grd.dp(:, :, yearIdx);

%% Calculations
fprintf('\tCalculations...\n');

% Contours from vaklodingen
SET.XL = [min(D.x),max(D.x)];
SET.YL = [min(D.y),max(D.y)];
idx = D.x >= SET.XL(1) & D.x <= SET.XL(2);
idy = D.y >= SET.YL(1) & D.y <= SET.YL(2);

% Define subset of data
i=1;
HP.IN = inpolygon(FOU(i).data.grid.Xcen, FOU(i).data.grid.Ycen, HP.pol(:,1),HP.pol(:,2));
HP.X = FOU(i).data.grid.Xcen(HP.IN);
HP.Y = FOU(i).data.grid.Ycen(HP.IN);
HP.Z = FOU(i).data.tau.valTimeBelow(HP.IN,:);

tauSwitch = 'taub';
% for i = 1:length(MAP)
% 
%     % Use these lines below for taus
%     if isfield(MAP(i).data,'tau')
%         MAP(i).data = rmfield(MAP(i).data,'tau');
%     end
% 
%     if strcmp(tauSwitch,'taus')
%         % Magnitude and direction
%         MAP(i).data.tau.mag = hypot(MAP(i).data.taus.u,MAP(i).data.taus.v);
%         MAP(i).data.tau.dir = uv2dir(MAP(i).data.taus.u,MAP(i).data.taus.v);
%     elseif strcmp(tauSwitch,'taub')
%         % Use this line below for taub
%         MAP(i).data.tau.mag = MAP(i).data.taub.val;
%     end
% 
%     prc = prctile(MAP(i).data.tau.mag,[10,50,90],1);
%     MAP(i).data.tau.mag10 = prc(1,:)';
%     MAP(i).data.tau.mag50 = prc(2,:)';
%     MAP(i).data.tau.mag90 = prc(3,:)';
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%
% %%% Curves at point %%%%
% %%%%%%%%%%%%%%%%%%%%%%%%
% %%% From the map file
% obs.x = 70000;               
% obs.y = 379000;
% for i = 1:length(MAP)
%     [~,obs.id] = min(abs(hypot(FOU(i).data.grid.Xcen - obs.x,FOU(i).data.grid.Ycen - obs.y)));
%     TAU.map.val = FOU(i).data.tau.valTimeBelow(:,obs.id);
% end
% 
% % Sort data
% TAU.map.valSort = sort(TAU.map.val);
% % Compute cumulative probability
% TAU.map.n = (1:length(TAU.map.valSort))' / length(TAU.map.valSort);

%%% From the fou file
for i = 1:length(FOU)

    tauVec = [];
    for j = 1:length(FOU(i).data.tau.long_name)
        id = strfind(FOU(i).data.tau.long_name{j},'cumulative time below');
        tauVec(j,1) = str2double(FOU(i).data.tau.long_name{j}(id+22:end));
    end

    FOU(i).data.tau.valSort = unique(tauVec);
    % totTime = (MAP(i).data.tau.times(end) - MAP(i).data.tau.times(1)) * 24 * 60 * 60;
    totTime = max(FOU(i).data.tau.valTimeBelow,[],2);

    clear allTime
    [nr,nc]             = size(FOU(i).data.tau.valTimeBelow);
    allTime             = NaN(nr,nc);
    allTime(:,1:nc)     = FOU(i).data.tau.valTimeBelow;
    fracTime            = allTime./totTime;

end

i=1;
tau = FOU(i).data.tau.valSort;
percentiles = [10,50,90];
n = size(fracTime, 1);
tauPerc = zeros(n, length(percentiles));
for i = 1:n
    % Interpolate tau at given percentile values (as fraction of 1)
    if any(isnan(fracTime(i,:))) || all(fracTime(i,:) == 1)
        tauPerc(i,:) = NaN(1,length(percentiles));
    else
        
        % Extract row and remove duplicate y-values for interpolation
        [yUnique, idx] = unique(fracTime(i,:), 'stable');
        tauUnique = tau(idx);

        % Interpolate tau at given percentile values (as fraction of 1)
        tauPerc(i,:) = interp1(yUnique, tauUnique, percentiles/100, 'linear', 'extrap');
    end
end


%% Plot settings

% This script changes all interpreters from 'tex' to 'latex'
list_factory = fieldnames(get(groot, 'factory')); % Get all factory settings
index_interpreter = find(contains(list_factory, 'Interpreter')); % Find interpreter settings
for i = 1:length(index_interpreter)
    default_name = strrep(list_factory{index_interpreter(i)}, 'factory', 'default'); % Convert to default property name
    set(groot, default_name, 'latex'); % Set to 'latex'
end

clr = colororder;

fprintf('\tVisualizations...\n');

% %% Figure 1: Comparison of cdf at position of AQD03
% 
% for i = 1:length(SET.sims)
%     close all;
%     fig = figure; fig.Units = 'centimeters'; fig.Position = [10 5 10 10];
%     fig.PaperUnits = 'centimeters';
%     fig.PaperSize = fig.Position([3,4]);
%     axs = tight_subplot(1,1,[0.01,0.01],[0.15,0.05],[0.15,0.15]);
% 
%     set(fig,'CurrentAxes',axs(1)); ax = gca; hold on; box on; grid on;
%     % hp(1) = plot(TAU.map.valSort,TAU.map.n,'k','Linewidth',2);
%     hp(2) = plot(FOU(i).data.tau.valSort,fracTime(obs.id,:),'color',clr(2,:),'Linewidth',1.5);
%     xlabel('$\tau$ (N $m^{-2}$)')
%     ylabel('Probabillity')
% 
%     legStr = {'cdf 1 hr map output','cdf time subceedance output'};
%     legend(hp,legStr,'location','se');
% 
%     % Write to file
%     figName = sprintf('TauPerc_comparison_cdf_%s',tauSwitch);
%     print(fig,'-dpng','-r300',[SET.figDirSim{i},figName,'.png'])
% end

%% Figure 2: Comparison of maps of tau percentiles

SET.XL = [68000, 72000];
SET.YL = [379000, 380500];
CL = [0,5];
clrTau = jet(CL(2)/0.05);

plotFlds = {'mag10','mag50','mag90'};
titStr = {'$10^{th} \%$','$50^{th} \%$','$90^{th} \%$'};

for i = 1:length(SET.sims)

    close all;
    fig = figure; fig.Units = 'centimeters'; fig.Position = [60 5 20 21];
    fig.PaperUnits = 'centimeters';
    fig.PaperSize = fig.Position([3,4]);

    axs = tight_subplot(2,3,[0.01,0.01],[0.08,0.05],[0.07,0.15]);


    for j = 1:3
        f = plotFlds{j};

        set(fig,'CurrentAxes',axs(j)); ax = gca; hold on; box on; grid on;
        FOU(i).data.gridHP.face_nodes_x = FOU(i).data.grid.face_nodes_x(:,HP.IN);
        FOU(i).data.gridHP.face_nodes_y = FOU(i).data.grid.face_nodes_y(:,HP.IN);
        EHY_plotMapModelData(FOU(i).data.gridHP,FOU(i).data.tau.(f)(HP.IN,1))
        [C,H] = contour(HP.X,HP.Y,HP.Z,[-2,-1,0],'color',[0.5,0.5,0.5]);
        axis equal;
        colormap(clrTau);
        xlim(SET.XL); ylim(SET.YL);
        clim(CL);

        % Title
        title(titStr{j});

        if j == 3
            hc = colorbar('location','east');

            hc.Position = [0.91,0.1,0.02,0.8];

            hc.Position(1)+0.1;
            hc.Position(4) = hc.Position(4)-0.05;
            title(hc,'\tau (N m^{-2})')
        end

        set(fig,'CurrentAxes',axs(j+3)); ax = gca; hold on; box on; grid on;
        FOU(i).data.gridHP.face_nodes_x = FOU(i).data.grid.face_nodes_x(:,HP.IN);
        FOU(i).data.gridHP.face_nodes_y = FOU(i).data.grid.face_nodes_y(:,HP.IN);
        EHY_plotMapModelData(FOU(i).data.gridHP,tauPerc(HP.IN,j))
        [C,H] = contour(HP.X,HP.Y,HP.Z,[-2,-1,0],'color',[0.5,0.5,0.5]);
        axis equal;
        colormap(clrTau);
        xlim(SET.XL); ylim(SET.YL);
        clim(CL);
        

    end

    for j = 1:3
        set(fig,'CurrentAxes',axs(j));
        set(gca,'XTickLabel',[])
        % set(gca,'XTickLabel',get(gca,'XTick')./1e3)
    end
    for j = [2,3,5,6]
        set(fig,'CurrentAxes',axs(j));
        set(gca,'YTickLabel',[])
    end
    for j = 4:6
        set(fig,'CurrentAxes',axs(j));
        set(gca,'XTickLabel',get(gca,'XTick')./1e3)
        xlabel('RDx (km)');
        
    end
    for j = [1,4]
        set(fig,'CurrentAxes',axs(j));
        set(gca,'YTickLabel',get(gca,'YTick')./1e3)
        ylabel('RDy (km)')
    end


    % Write to file
    figName = sprintf('TauPerc_comparison_maps10-50-60-90th_%s',tauSwitch);
    print(fig,'-dpng','-r300',[SET.figDirSim{i},figName,'.png'])

end

%% Comparison tau magnitude with scatter plots

xl = [0.25,1.5,5];

plotFlds = {'mag10','mag50','mag90'};
titStr = {'$10^{th} \%$','$50^{th} \%$','$90^{th} \%$'};

for i = 1:length(SET.sims)

    close all;
    fig = figure; fig.Units = 'centimeters'; fig.Position = [60 5 20 8];
    fig.PaperUnits = 'centimeters';
    fig.PaperSize = fig.Position([3,4]);

    axs = tight_subplot(1,3,0.05,[0.2,0.07],[0.07,0.05]);

    for j = 1:length(plotFlds)
        f = plotFlds{j};

        set(fig,'CurrentAxes',axs(j)); ax = gca; hold on; box on; grid on;
        scatter(FOU(i).data.tau.(f)(HP.IN,1),tauPerc(HP.IN,j),20,'k','filled')
        plot([0,5],[0,5],'-k')

        xlim([0,xl(j)]);
        ylim([0,xl(j)]);
        % Title
        title(titStr{j});
        xlabel('$\tau_{1hr \; map \; output}$ (N $m^{-2}$)')

        if j == 1
            ylabel('$\tau_{time \; subceedance \; output}$ (N $m^{-2}$)')
        end
    end


    figName = sprintf('TauPerc_comparison_scatter10-50-60-90th_%s',tauSwitch);
    print(fig,'-dpng','-r300',[SET.figDirSim{i},figName,'.png'])
end

%% Helper functions
% function tauPerc = tauPercentiles(fracTime, tau, percentiles)
% tauPercentiles calculates interpolated tau values at given percentiles
% 
% Inputs:
%   fracTime   - n x m matrix of CDF values (rows = different distributions)
%   tau        - 1 x m vector of corresponding x-values
%   percentiles - vector of desired percentiles (0-100)
%
% Output:
%   tauPerc - n x length(percentiles) matrix of interpolated tau values


    

% end