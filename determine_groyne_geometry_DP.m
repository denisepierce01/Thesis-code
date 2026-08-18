

clear all
close all
clc

% Bepaal hoogte van de strekdammen
% Settings
jaar = 2018;
lidar_dir = 'P:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\02_bathymetry\lidar\';
groyne_dir = 'P:\11207654-bathosszimm-modelling\05_Modellering\01_modelopzet\03_groynes\';

%% Find data in lidar files
mat_files = dir([lidar_dir '*.mat']);
tif_files = dir([lidar_dir '*.tif']);

idx_mat = find(contains({mat_files(:).name}, num2str(jaar)));
idx_tif = find(contains({tif_files(:).name}, num2str(jaar)));
if ~isempty(idx_mat)
    load([mat_files(idx_mat).folder filesep mat_files(idx_mat).name]);
else
    [z, x, y, ~] = geoimread([tif_files(idx_tif).folder filesep tif_files(idx_tif).name]);
    [xx, yy] = meshgrid(x,y);
    z(z> 1e38) = NaN;
    S = m_shaperead([lidar_dir 'interessegebied']);
    
    % For area of Ossenisse (1) and Zimmerman and Bath (2)
    lidar = struct;
    for ii = 1:length(S.ncst)
        xpol = S.ncst{ii}(:,1); ypol = S.ncst{ii}(:,2);
        idx_bb = xx >= min(xpol) & xx <= max(xpol) & yy >= min(ypol) & yy <= max(ypol);

        xtmp = xx(idx_bb); ytmp = yy(idx_bb); ztmp = z(idx_bb);
        in_pol = inpolygon(xtmp, ytmp, xpol, ypol); 

        lidar(ii).x = xtmp(in_pol);
        lidar(ii).y = ytmp(in_pol);
        lidar(ii).z = ztmp(in_pol);
        lidar(ii).k = convhull(lidar(ii).x, lidar(ii).y);
        lidar(ii).S = scatteredInterpolant(lidar(ii).x,lidar(ii).y,lidar(ii).z);
    end

    save([lidar_dir strrep(tif_files(idx_tif).name, '.tif', '.mat')],  'lidar', '-v7.3')
end

%% Interpolate groynes in lidar data
% Laad groynes in

S = m_shaperead([groyne_dir 'Groynes_OssZimmBath_' num2str(jaar)]);
PNGfile = 'P:\11207654-internship-pierce-2026\03_Model\ModelInput\groyne';

png_dir = [PNGfile filesep num2str(jaar) filesep];
mkdir(png_dir)

fID = fopen([groyne_dir filesep 'Groynes_OssZimmBath_' num2str(jaar) '.fxw'], 'w');
% Loop through all the groynes
cnt_oss = 1; cnt_bat = 1; cnt_zim = 1;
for gg = 1:length(S.ncst)
    if ~isempty(S.ncst{gg})
        figure; hold on; grid on;
        set(gcf, 'Position', [450 450 900, 400])
        ylabel('\bf{\it{Elevation [m NAP]}}','FontSize',16)
        xlabel('\bf{\it{Groyne Length [m]}}','FontSize',16)
        
        % Title
        if S.dbfdata{gg} == 1 % Ossenisse 
            fignaam = ['Ossenisse - ' num2str(cnt_oss)];
            title(fignaam)
            cnt_oss = cnt_oss + 1;
        elseif S.dbfdata{gg} == 2 % Zimmerman 
            fignaam = ['Zimmerman - ' num2str(cnt_zim)];
            title(fignaam)
            cnt_zim = cnt_zim + 1;
        elseif S.dbfdata{gg} == 3 || S.dbfdata{gg} == 4 % Bath cross shore (3) and along shore (4)
            fignaam = ['Bath - ' num2str(cnt_bat)];
            title(fignaam)
            cnt_bat = cnt_bat + 1;
        end

        % Loop through all the groyne sections
        sec_length_tot = 0; sec_cnt = 1;
        for pp = 1:length(S.ncst{gg})-1
            sec_length = hypot(diff(S.ncst{gg}(pp:pp+1,1)), diff(S.ncst{gg}(pp:pp+1,2)));
            if sec_length ~= 0
                dL = 2; %m
                sec = 0:dL:sec_length; % Devide up in section of 2m (same resolution as lidar)
                xl = S.ncst{gg}(pp,1) + sec/sec_length*diff(S.ncst{gg}(pp:pp+1,1));
                yl = S.ncst{gg}(pp,2) + sec/sec_length*diff(S.ncst{gg}(pp:pp+1,2));
        
                if S.dbfdata{gg} == 1 % Ossenisse --> use lidar area 2
                    zl = lidar(2).S(xl, yl);
                else
                    % Zimmerman of Bath --> gebruik lidar gebied 1
                    zl = lidar(1).S(xl, yl);
                end

                %Exclude NaNs
                idx_nan = isnan(zl);
                zl(idx_nan) = []; sec(idx_nan) = [];

                % Make linear trend line for cross shore groynes
                if S.dbfdata{gg} ~= 4
                    p = polyfit(sec, zl, 1);
                    zfit = polyval(p,sec);
                else % Use mean for alongshore groynes (only at Bath)
                    zfit = zl;
                end
        
                scatter(sec_length_tot+sec, zl, 10, 'r', 'filled')
                
                % Save for _fxw file and plotting
                secS(sec_cnt).x = xl([1,end]);
                secS(sec_cnt).y = yl([1,end]);
                secS(sec_cnt).sec = sec_length_tot + sec([1,end]);
                secS(sec_cnt).z = zfit([1, end]);
                secS(sec_cnt).zall = zfit;
       
                % Update
                sec_cnt = sec_cnt + 1;
                sec_length_tot = sec_length_tot + sec(end);
            end
        end

        if S.dbfdata{gg} == 4 % For alongshore groynes
            allX = [secS(:).x];
            allY = [secS(:).y];
            zmean = mean([secS(:).zall]);
            allZ = ones(size(allX))*zmean;
            allSec = [secS(:).sec];
        else % Cross shore groynes
            if length(secS) > 1 % Groynes with multiple line segments
                allX = average_interior_points([secS(:).x]);
                allY = average_interior_points([secS(:).y]);
                allZ = average_interior_points([secS(:).z]);
                allSec = average_interior_points([secS(:).sec]);
            else % Groynes with one line segment
                allX = [secS(:).x];
                allY = [secS(:).y];
                allZ = [secS(:).z];
                allSec = [secS(:).sec];
            end
        end
        plot(allSec, allZ, 'k-', 'LineWidth',2)
        
        % Save figure
        % exportgraphics(gcf, [png_dir strrep(fignaam, ' ', '') '.png'])

        % Write in _fxw file
        fprintf(fID, '%s\n', strrep(fignaam, ' ', ''));
        fprintf(fID, '%i 3\n', length(allX));
        for pp = 1:length(allX)
            fprintf(fID, '%f %f %f\n', allX(pp), allY(pp), allZ(pp));
        end
        clear secS
        close gcf
    end
end


fclose(fID);

%% tile plotting Bath and Zimm
nValid = sum(cellfun(@(x, d) ~isempty(x) && d ~= 1, S.ncst, S.dbfdata));

nCols = 3;
nRows = 1;
% nCols = 3;
% nRows = 5;

fig = figure;
set(fig, 'Position', [100 100 1000,300]);
% set(fig, 'Position', [100 100 1000,1500]);
t = tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');

% Single shared axis labels for the whole tiled layout
ylabel(t, '\bf{\it{Elevation [m NAP]}}', 'FontSize', 14)
xlabel(t, '\bf{\it{Groyne Length [m]}}', 'FontSize', 14)
% set(gca, 'FontSize', 12);

fID = fopen([groyne_dir filesep 'Groynes_OssZimmBath_' num2str(jaar) '.fxw'], 'w');
cnt_oss = 1; cnt_bat = 1; cnt_zim = 1;
legendAdded = false;

for gg = 1:length(S.ncst)
    if ~isempty(S.ncst{gg}) && S.dbfdata{gg} ~= 1 % Skip Ossenisse entirely
        nexttile; hold on; grid on;
        % ylabel('\bf{\it{Elevation [m NAP]}}', 'FontSize', 10)
        % xlabel('\bf{\it{Groyne Length [m]}}', 'FontSize', 10)

        % Title
        if S.dbfdata{gg} == 2 % Zimmerman
            fignaam = ['Zimmerman ' num2str(cnt_zim)];
            title(fignaam, 'FontSize', 12)
            cnt_zim = cnt_zim + 1;
        elseif S.dbfdata{gg} == 3 || S.dbfdata{gg} == 4 % Bath cross shore (3) and along shore (4)
            if ismember(cnt_bat, [10, 11, 12])
                fignaam = ['Bath channel wall ' num2str(cnt_bat-9)];
            elseif ismember(cnt_bat, [1])
                fignaam = ['Bath Middle Groyne'];
            else
                fignaam = ['Bath ' num2str(cnt_bat-1)];
            end
            title(fignaam, 'FontSize', 12)
            cnt_bat = cnt_bat + 1;
        end
        % Loop through all the groyne sections
        sec_length_tot = 0; sec_cnt = 1;
        for pp = 1:length(S.ncst{gg})-1
            sec_length = hypot(diff(S.ncst{gg}(pp:pp+1,1)), diff(S.ncst{gg}(pp:pp+1,2)));
            if sec_length ~= 0
                dL = 2; %m
                sec = 0:dL:sec_length; % Devide up in section of 2m (same resolution as lidar)
                xl = S.ncst{gg}(pp,1) + sec/sec_length*diff(S.ncst{gg}(pp:pp+1,1));
                yl = S.ncst{gg}(pp,2) + sec/sec_length*diff(S.ncst{gg}(pp:pp+1,2));
                % Zimmerman or Bath --> gebruik lidar gebied 1
                zl = lidar(1).S(xl, yl);
                % Exclude NaNs
                idx_nan = isnan(zl);
                zl(idx_nan) = []; sec(idx_nan) = [];
                % Make linear trend line for cross shore groynes
                if S.dbfdata{gg} ~= 4
                    p = polyfit(sec, zl, 1);
                    zfit = polyval(p,sec);
                else % Use mean for alongshore groynes (only at Bath)
                    zfit = zl;
                end
                scatter(sec_length_tot+sec, zl, 10, 'r', 'filled')
                % Save for _fxw file and plotting
                secS(sec_cnt).x = xl([1,end]);
                secS(sec_cnt).y = yl([1,end]);
                secS(sec_cnt).sec = sec_length_tot + sec([1,end]);
                secS(sec_cnt).z = zfit([1, end]);
                secS(sec_cnt).zall = zfit;
                % Update
                sec_cnt = sec_cnt + 1;
                sec_length_tot = sec_length_tot + sec(end);
            end
        end

        if S.dbfdata{gg} == 4 % For alongshore groynes
            allX = [secS(:).x];
            allY = [secS(:).y];
            zmean = mean([secS(:).zall]);
            allZ = ones(size(allX))*zmean;
            allSec = [secS(:).sec];
        else % Cross shore groynes
            if length(secS) > 1 % Groynes with multiple line segments
                allX = average_interior_points([secS(:).x]);
                allY = average_interior_points([secS(:).y]);
                allZ = average_interior_points([secS(:).z]);
                allSec = average_interior_points([secS(:).sec]);
            else % Groynes with one line segment
                allX = [secS(:).x];
                allY = [secS(:).y];
                allZ = [secS(:).z];
                allSec = [secS(:).sec];
            end
        end
    
        ax.FontSize = 12; 
        plot(allSec, allZ, 'k-', 'LineWidth', 2)
        if ~legendAdded
            legend({'Lidar data', 'Schematized Groyne Crest'}, 'Location', 'best', 'FontSize', 10)
            legendAdded = true;
        end

       

        % Write in _fxw file
        fprintf(fID, '%s\n', strrep(fignaam, ' ', ''));
        fprintf(fID, '%i 3\n', length(allX));
        for pp = 1:length(allX)
            fprintf(fID, '%f %f %f\n', allX(pp), allY(pp), allZ(pp));
        end
        % clear secS
    end
end

exportgraphics(gcf, [png_dir strrep(fignaam, ' ', '') '.png'])

%% Function

function out = average_interior_points(in)
interior = in(2:end-1);
assert(mod(numel(interior), 2) == 0, ...
       'Interior length must be even (pairs of subsequent values).');
pair_means = mean(reshape(interior, 2, []), 1);  % averages [2&3], [4&5], ...
out = [in(1), pair_means, in(end)];
end

