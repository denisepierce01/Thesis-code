%% view wind from KNMI input for model
%D. Pierce
close all 
clear all 
clc

%% load wind 
% Prompt for file or use default path, then read numeric data from a whitespace-delimited text file
defaultPath = "P:\11207654-internship-pierce-2026\03_Model\14_T0bathy_T1groynes_Apr18\wind.txt";

rawData = readmatrix(defaultPath);

time_min = rawData(:,1);        % in minutes since 01-Dec-2017
wind_speed = rawData(:,2);      % wind speed (m/s)
wind_direction = rawData(:,3);  %wind direction degrees nautical

%% cleaning data
% KNMI uses error code 990 when wind direction cannot be found for low wind
% speed. removing those from data and associated times & magnitudes.
% Also handle possible NaNs and ensure vectors are column vectors before removal.

% Identify invalid indices: KNMI code 990 or NaN in wind_direction
invalidIdx = (wind_direction == 990) | isnan(wind_direction);

% Report how many entries will be removed (helps debug "why these not removed")
nInvalid = sum(invalidIdx);
if nInvalid > 0
    fprintf('Removing %d invalid wind-direction entries (990 or NaN).\n', nInvalid);
else
    fprintf('No invalid wind-direction entries (990 or NaN) found.\n');
end

% Remove those entries from wind_direction, wind_speed, and time_min
wind_direction(invalidIdx) = [];
wind_speed(invalidIdx) = [];
time_min(invalidIdx) = [];

%% convert time to include date
% reference start datetime
ref = datetime(2017,12,1,0,0,0);

% convert minutes to duration and add to reference
time_date = ref + minutes(time_min);

% (optional) ensure column vector of datetimes matching time_min
time_date = time_date(:);

%% view wind magnitude time series
figure()
% subplot(2,1,1)
plot(time_date, wind_speed, 'Color', [0.6 0.6 0.6], 'LineWidth', 2);
xlabel('Time','FontSize',20,'FontWeight','bold')
ylabel('Wind Speed [m/s]','FontSize',20,'FontWeight','bold')
title('Wind Speed: Vlissingen (KNMI)','FontSize', 24)
set(gca,'FontSize',18)

box off
set(gca,'TickDir','in') % conventional outward ticks
set(gca, 'XAxisLocation','bottom', 'YAxisLocation','left', 'TickLength',[0.01 0.01])
xlim([datetime(2018,4,22,0,0,0), datetime(2018,5,23,0,0,0)]); % Apr2018 model period
ylim([0 16])
grid off


% xlim([datetime(2018,1,1,0,0,0), datetime(2018,12,31,23,59,59)])

% subplot(2,1,2)
% plot(time_date, wind_direction, '-r', 'LineWidth', 2.5);
% grid on
% xlabel('Time','FontSize',24)
% ylabel('Direction (deg nautical)','FontSize',24)
% title('Direction','FontSize',26)
% set(gca,'FontSize',24)
% xlim([datetime(2018,11,18,0,0,0), datetime(2018,12,31,23,59,59)]) %nov2018 model period
% % xlim([datetime(2018,1,1,0,0,0), datetime(2018,12,31,23,59,59)])

% add a big centered title for the entire figure
% ha = axes('Units','normal','Position',[0 0 1 1],'Visible','off');
% text(0.5, 0.98, 'Wind Speed: Vlissingen (KNMI)', 'HorizontalAlignment','center', ...
%     'FontSize',36, 'FontWeight','bold', 'Parent', ha);

%% wind rose
dirBinWidth = 20;                            % degrees per sector (16 sectors)
speedEdges  = [0 4 8 12 16 Inf];     % m/s bin edges
speedLabels = {'0-4','4-8','8-12','12-16','16+'};
cmap        = flipud(jet(numel(speedEdges)-1)); % one color per speed bin
titleStr    = 'Wind Rose: Vlissingen (KNMI)';

% Restrict to the same model period as your time series plot (optional)
useDateFilter = true;
tStart = datetime(2018,4,22,0,0,0);
tEnd   = datetime(2018,5,23,0,0,0);

% --- Optional date filtering ---
if useDateFilter
    idxKeep = (time_date >= tStart) & (time_date <= tEnd);
    ws = wind_speed(idxKeep);
    wd = wind_direction(idxKeep);
else
    ws = wind_speed;
    wd = wind_direction;
end

% --- Bin directions into sectors (nautical: 0=N, clockwise) ---
nDirBins = round(360/dirBinWidth);
dirEdges = (-dirBinWidth/2):dirBinWidth:(360-dirBinWidth/2);
wdWrapped = mod(wd, 360);
wdShifted = wdWrapped;
wdShifted(wdShifted >= dirEdges(end)) = wdShifted(wdShifted >= dirEdges(end)) - 360;
[~,~,dirBinIdx] = histcounts(wdShifted, dirEdges);
dirBinIdx(dirBinIdx == 0) = 1; % edge-value safety catch

nSpeedBins = numel(speedEdges) - 1;
[~,~,speedBinIdx] = histcounts(ws, speedEdges);

% --- Frequency table: rows = direction sector, cols = speed bin ---
freqTable = zeros(nDirBins, nSpeedBins);
nTotal = numel(ws);
for d = 1:nDirBins
    for s = 1:nSpeedBins
        freqTable(d,s) = sum(dirBinIdx == d & speedBinIdx == s);
    end
end
freqPct = 100 * freqTable / nTotal; % percentage of total observations

% --- Plot windrose as stacked polar wedges ---
figure('Color','w','Position',[100 100 800 700]);
ax = axes; axis equal off; hold(ax,'on');

maxR = ceil(max(sum(freqPct,2))/2)*2 + 2; % radial limit with headroom

for d = 1:nDirBins
    centerDeg = (d-1)*dirBinWidth;
    % Convert nautical (0=N, clockwise) to standard math angle (0=E, counterclockwise)
    theta1 = deg2rad(90 - (centerDeg - dirBinWidth/2));
    theta2 = deg2rad(90 - (centerDeg + dirBinWidth/2));
    thetaFill = linspace(theta1, theta2, 12);

    rInner = 0;
    for s = 1:nSpeedBins
        rOuter = rInner + freqPct(d,s);
        if freqPct(d,s) > 0
            xOuter = rOuter*cos(thetaFill);         yOuter = rOuter*sin(thetaFill);
            xInner = rInner*cos(fliplr(thetaFill));  yInner = rInner*sin(fliplr(thetaFill));
            patch(ax, [xOuter, xInner], [yOuter, yInner], cmap(s,:), ...
                'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.5);
        end
        rInner = rOuter;
    end
end

% --- Radial grid circles + % labels ---
gridVals = 0:5:maxR;
thetaCircle = linspace(0, 2*pi, 100);
for g = gridVals
    plot(ax, g*cos(thetaCircle), g*sin(thetaCircle), '-', 'Color', [0.5 0.5 0.5]);
    if g ~= 0
        text(ax, 0, -g, sprintf('%d%%', g), 'FontSize', 16, ...
            'HorizontalAlignment','center', 'BackgroundColor','w');
    end
end

% --- Compass labels ---
compassDirs = {'N','E','S','W'};
compassAngles = [90, 0, -90, 180]; % math-convention degrees
for i = 1:4
    ang = deg2rad(compassAngles(i));
    text(ax, (maxR+3)*cos(ang), (maxR+3)*sin(ang), compassDirs{i}, ...
        'FontSize',22, 'FontWeight','bold', 'HorizontalAlignment','center');
end

xlim(ax, [-maxR, maxR]);
ylim(ax, [-maxR, maxR]);

% legend
legendHandles = gobjects(nSpeedBins,1);
for s = 1:nSpeedBins
    legendHandles(s) = patch(ax, NaN, NaN, cmap(s,:), 'EdgeColor', 'none');
end
lgd = legend(ax, legendHandles, speedLabels, 'Location', 'northeastoutside', 'FontSize',18);
lgd.Title.String = 'Wind Speed [m/s]';

% export figure
% outDir = 'P:\11207654-internship-pierce-2026\03_Model\ModelInput\';
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% outFile = fullfile(outDir, 'windrose_apr2018.png');
% saveas(gcf, outFile);
