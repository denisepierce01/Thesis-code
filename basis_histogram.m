%% Histogram of T0 vsT1 under 0.6 m/s threshold
Bath_T0 = [10 ];
Bath_T1 = [13 0.6
           2 0.1
           1 0.3];
Oss_T0 = [2 3];
Oss_T1 = [2 3];
Zimm_T0 = [1 3];
Zimm_T1 = [1 3];

data = [Bath_T0; Bath_T1];     % 3x2 matrix: rows = groups, cols = categories
figure;
bar(data);                   % grouped bar chart
set(gca,'XTickLabel',{'Bath T0','Bath T1'}, 'FontSize',16);
xlabel('Site', 'FontSize',14);
ylabel('Value', 'FontSize',14);
ylim([0 16]);
legend({'T','T1'},'Location','best', 'FontSize',16);
title('Low Dynamic Area 95% of time ( < 0.6 m/s) ');

%% 1. Define the Data
% Each column corresponds to a T value (1.60, 1.38, 1.35, 1.33, 1.32)
% Each row corresponds to a pi range (bottom to top)
data = [22, 18, 17, 16, 16;  % 0.59-0.5
        22, 19, 18, 17, 17;  % 0.69-0.6  
        12, 11, 11, 10, 10;  % 0.79-0.7
        9,  10, 11, 11, 11;  % 0.89-0.8
        1,   2,  2,  2,  2;  % 0.99-0.9 (estimated from thin sliver)
        34, 40, 42, 43, 44]; % 1.0

% 2. Create the Figure
figure('Color', 'w');
b = bar(data', 'stacked', 'EdgeColor', 'none');

% 3. Set Custom Colors (Matching the purple-orange gradient)
% Using RGB values from light orange to dark navy
colors = [
    1.00, 0.75, 0.55; % Light Orange
    0.95, 0.45, 0.35; % Salmon/Coral
    0.85, 0.25, 0.40; % Pinkish-Red
    0.60, 0.15, 0.50; % Magenta/Purple
    0.40, 0.05, 0.50; % Dark Purple
    0.15, 0.05, 0.30  % Navy/Black
];
colormap(colors);

% 4. Add Percentage Labels
[rows, cols] = size(data);
for i = 1:cols % Loop through each bar (T)
    bottom = 0;
    for j = 1:rows % Loop through each segment (pi)
        val = data(j,i);
        if val > 2 % Only label if the segment is thick enough
            % Calculate text position (middle of the segment)
            text(i, bottom + val/2, sprintf('%d%%', val), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        end
        bottom = bottom + val;
    end
end

% 5. Formatting Axes and Labels
set(gca, 'XTickLabel', {'Bath T0', 'Bath T1', 'Ossenisse T0', 'Ossenisse T1', 'Zimmerman T0'}, ...
    'FontSize', 14, 'LineWidth', 1.5, 'TickDir', 'out');

xlabel('Sites', 'FontSize', 18, 'FontAngle', 'italic');
ylabel('% of sites that are below 0.6 m/s', 'FontSize', 18, 'FontAngle', 'italic');
ylim([0 100]);

% 6. Legend
lgd = legend({'0.59-0.5', '0.69-0.6', '0.79-0.7', '0.89-0.8', '0.99-0.9', '1.0'}, ...
    'Title', '\pi', 'Location', 'eastoutside');

%% 1. Define the Data
% Categories: Bath T0 and Bath T1
% Rows: Cumulative bins (e.g., 0-0.1, 0.1-0.2, 0.2-0.3, 0.3-0.4, 0.4-0.5, 0.5-0.6, >0.6)
% Values represent the number of sites in each interval
% Note: To show cumulative percentage, the sum of each column should be the total sites.

% Sample Data: Number of sites per interval
% Bins: [0-0.1, 0.1-0.2, 0.2-0.3, 0.3-0.4, 0.4-0.5, 0.5-0.6, >0.6]
data = [10, 15;  % 0.0 - 0.1
        12, 18;  % 0.1 - 0.2
        15, 20;  % 0.2 - 0.3
        18, 12;  % 0.3 - 0.4
        10, 10;  % 0.4 - 0.5
        15,  5;  % 0.5 - 0.6 (Threshold limit)
        20, 20]; % > 0.6 (Above threshold)

total_sites = sum(data); % Total for percentage calculation

% 2. Create the Figure
figure('Color', 'w');
b = bar(data', 'stacked', 'EdgeColor', 'k', 'LineWidth', 1);

% 3. Apply a Colormap (Sieve effect: Gradient for <0.6, Grey/Dark for >0.6)
% Using a transition from Light Blue to Deep Blue for the sieve, then Red for >0.6
custom_map = [
    0.9, 0.9, 1.0; % 0.0-0.1
    0.7, 0.8, 1.0; % 0.1-0.2
    0.5, 0.6, 1.0; % 0.2-0.3
    0.3, 0.4, 1.0; % 0.3-0.4
    0.1, 0.2, 0.9; % 0.4-0.5
    0.0, 0.0, 0.7; % 0.5-0.6
    0.5, 0.5, 0.5  % >0.6 (Grey indicates "passed the sieve")
];
colormap(custom_map);

% 4. Add Cumulative Percentage Labels
[rows, cols] = size(data);
for i = 1:cols % For each site (Bath T0, Bath T1)
    current_cumulative = 0;
    for j = 1:rows % For each bin
        segment_val = data(j,i);
        current_cumulative = current_cumulative + segment_val;
        
        % Calculate percentage of total sites
        pct = (current_cumulative / total_sites(i)) * 100;
        
        % Place text at the top of the current segment
        % We only label up to the 0.6 threshold as requested
        if j <= 6
            text(i, current_cumulative - (segment_val/2), ...
                sprintf('%.1f%%', pct), ...
                'HorizontalAlignment', 'center', 'Color', 'w', ...
                'FontSize', 9, 'FontWeight', 'bold');
        end
    end
end

% 5. Formatting
set(gca, 'XTickLabel', {'Bath T0', 'Bath T1'}, 'FontSize', 12);
ylabel('# of Sites', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Measurement Site', 'FontSize', 14, 'FontWeight', 'bold');
title('Cumulative Sieve Analysis (Threshold = 0.6)', 'FontSize', 14);

% 6. Legend
legend_labels = {'< 0.1', '0.1 - 0.2', '0.2 - 0.3', '0.3 - 0.4', '0.4 - 0.5', '0.5 - 0.6', '> 0.6'};
lgd = legend(legend_labels, 'Location', 'eastoutside', 'Title', 'Threshold Bin');

grid on;
set(gca, 'Layer', 'top'); % Ensure grid lines are behind bars