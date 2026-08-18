% Script to plot residual sediment transport for different runs

% Check output (significant wave height, peak period) for different
% model runs

clear all 
close all
clc

% Analyse fourier output
% addpath(genpath('p:\11210344-001-bathosszimm\05_Modellering\04_postprocessing\')) % Add curvvec function

%% Load data

folders = {
    'p:\11210344-scheldemonding\03_Modellering\04_new_model_2026\02_simulations\01_test_runs\12_flow_sed_waves_incl_ref_V2\fm\'
    'p:\11210344-scheldemonding\03_Modellering\04_new_model_2026\02_simulations\01_test_runs\20_flow_sed_waves_incl_ref_V2_susWbedW\fm\'
};

pngFolder = 'p:\11210344-scheldemonding\03_Modellering\04_new_model_2026\02_simulations\01_test_runs\PNGs\Res_sediment_transport\';
if ~exist(pngFolder, 'file'); mkdir(pngFolder); end

names = {'susW = bedW = 0.6', 'susW = bedW = 0.1'};
figName = '12_20_susW_bedW';

t0 = datenum(2025,8,30);
tend = t0 + 1/24;

for ii = 1:length(folders)
    outputFolder = [folders{ii} '\output\'];
    matFile = [outputFolder 'res_sed_trp.mat'];
    mapFiles = dir([outputFolder '*_map.nc']);

    if isfile(matFile)
        load(matFile)
    else
        gridInfo = EHY_getGridInfo([mapFiles(1).folder filesep mapFiles(1).name], 'face_nodes_xy');
        BED.x = EHY_getMapModelData([mapFiles(1).folder filesep mapFiles(1).name], ...
            'varName','mesh2d_sbxcum','t0', t0, 'tend', tend);
        BED.y = EHY_getMapModelData([mapFiles(1).folder filesep mapFiles(1).name], ...
            'varName','mesh2d_sbycum','t0', t0, 'tend', tend);
        SUS.x = EHY_getMapModelData([mapFiles(1).folder filesep mapFiles(1).name], ...
            'varName','mesh2d_ssxcum','t0', t0, 'tend', tend);
        SUS.y = EHY_getMapModelData([mapFiles(1).folder filesep mapFiles(1).name], ...
            'varName','mesh2d_ssycum','t0', t0, 'tend', tend);
       save(matFile, 'SUS', 'BED', 'gridInfo', '-v7.3');
    end

    Data(ii).SUS = SUS; Data(ii).BED = BED; Data(ii).gridInfo = gridInfo;
end

% Load bathy (vaklodingen 2025)
load('p:\11212794-westerschelde-2026\projects_2026\01_sedimenttransportmodel\02_modelopzet\02_bathymetry\2025\Westerschelde_NL\WS2025.mat')

% Load nourishments
ldb1 = landboundary('read', 'c:\Users\wilde_tm\OneDrive - Stichting Deltares\Documents\03 Projecten\014 SITO WS\02 Scheldemonding\Data Marco 27-05-2024\Shapefiles_stortzones\Stortzone_1_def.ldb');
ldb2 = landboundary('read', 'c:\Users\wilde_tm\OneDrive - Stichting Deltares\Documents\03 Projecten\014 SITO WS\02 Scheldemonding\Data Marco 27-05-2024\Shapefiles_stortzones\Stortzone_2_def.ldb');

%% Calculate total transport

for ii = 1:length(Data)
    Data(ii).TOT.x = Data(ii).SUS.x.val + Data(ii).BED.x.val;
    Data(ii).TOT.y = Data(ii).SUS.y.val + Data(ii).BED.y.val;

    % Get cell center values
    Data(ii).gridInfo.cc_x = mean(Data(ii).gridInfo.face_nodes_x, 'omitnan');
    Data(ii).gridInfo.cc_y = mean(Data(ii).gridInfo.face_nodes_y, 'omitnan');
end

%% Plot data

plotLims = [10 20 381 387]*1e3;

buffer = 100;
idx_grd = grd.x >= plotLims(1) - buffer & grd.x <= plotLims(2) + buffer & ...
          grd.y >= plotLims(3) - buffer & grd.y <= plotLims(4) + buffer;
dp_plot = grd.dp;
dp_plot(~idx_grd) = NaN;

dx = 50;
x = plotLims(1)-buffer:dx:plotLims(2)+buffer;
y = plotLims(3)-buffer:dx:plotLims(4)+buffer;
[xx, yy] = meshgrid(x,y);

figure(1); clf(1); hold on;
set(gcf, 'Position', [200 200 1100 580])
% Plot background image
cmap=cptcmap('GMT_globe','ncol',29);
clims = [-20 5];
pcolor(grd.x./1e3, grd.y./1e3, dp_plot, 'LineStyle','none', 'HandleVisibility', 'off')
colormap(cmap); clim(clims);
cb = colorbar(); ylabel(cb, 'Bodemhoogte [m NAP]')
axis equal;
xlim(plotLims(1:2)./1e3); ylim(plotLims(3:4)./1e3)
title(['Cumulative total transport at: ' datestr(t0)])

% Quiver plot
colors = {'r', 'b'};
for ii = 1:length(Data)
      
    % Interpolate on regular grid
    in_domain = Data(ii).gridInfo.cc_x >= plotLims(1) & Data(ii).gridInfo.cc_x <= plotLims(2) & ...
        Data(ii).gridInfo.cc_y >= plotLims(3) & Data(ii).gridInfo.cc_y <= plotLims(4);

    Fx = scatteredInterpolant(Data(ii).gridInfo.cc_x(in_domain).', Data(ii).gridInfo.cc_y(in_domain).', squeeze(Data(ii).TOT.x(in_domain)));
    Fy = scatteredInterpolant(Data(ii).gridInfo.cc_x(in_domain).', Data(ii).gridInfo.cc_y(in_domain).', squeeze(Data(ii).TOT.y(in_domain)));
    
    Fu_on_grd = Fx(xx, yy);
    Fv_on_grd = Fy(xx, yy);

    idx_ref_arrow = xx >= 18.5e3 & yy >= 386.5e3;
    Fu_on_grd(idx_ref_arrow) = 0;
    Fv_on_grd(idx_ref_arrow) = 0;
    
    scale = 3e4;
    thinner = 5;
    quiver(xx(1:thinner:end, 1:thinner:end)./1e3, yy(1:thinner:end, 1:thinner:end)./1e3, ...
        Fu_on_grd(1:thinner:end, 1:thinner:end)*scale, Fv_on_grd(1:thinner:end, 1:thinner:end)*scale, ...
        'off', 'Color', colors{ii}, 'MaxHeadSize', 0.04, 'DisplayName', names{ii})
    
    % curvvec(xx(1:thinner:end, 1:thinner:end)./1e3,yy(1:thinner:end, 1:thinner:end)./1e3, ...
    %     Fu_on_grd(1:thinner:end, 1:thinner:end)*scale, Fv_on_grd(1:thinner:end, 1:thinner:end)*scale, ...
    %     'color',colors{ii},'minmag',0.01*scale,'maxmag',0.2*scale,'numpoints',10,'thin', 1,'linewidth', 0.1)

    if ii == 1
        quiver(18.7, 386.9, 1e-5*scale, 0, 'off', 'Color', 'k', 'MaxHeadSize', 1, 'HandleVisibility', 'off')
        text(  18.7, 386.75, '1\cdot10^{-5} m^3/s/m', 'HandleVisibility', 'off')
    end
end

plot(ldb1(:,1)./1e3, ldb1(:,2)./1e3, 'k-', 'LineWidth', 1.5, 'HandleVisibility', 'off')
plot(ldb2(:,1)./1e3, ldb2(:,2)./1e3, 'k-', 'LineWidth', 1.5, 'HandleVisibility', 'off')
legend('Location', 'southwest')
ylabel('\bf{\it{Y [km]}}'); xlabel('\bf{\it{X [km]}}')

% exportgraphics(gcf, [pngFolder figName '.png'])