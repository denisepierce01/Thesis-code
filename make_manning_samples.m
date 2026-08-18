% Script to make variable manning field (.xyz)

clear all
close all
clc

%% Load data

% Grid
grdFile = 'p:\archivedprojects\11210344-001-bathosszimm\05_Modellering\01_modelopzet\01_grid\nevla_j19_6-w6a_incl_monding_bathy_interp_no_rivers_BathOssZimm_Oss_ref3_net.nc';
X = ncread(grdFile, 'mesh2d_node_x');
Y = ncread(grdFile, 'mesh2d_node_y');

% polygons
pol_flat = landboundary('read', 'P:\11207654-internship-pierce-2026\03_Model\ModelInput\BathZimmFlats.pol');
pol_trns = landboundary('read', 'P:\11207654-internship-pierce-2026\03_Model\ModelInput\transition.pol');

%% Make roughness

n_flats = 0.018;
n_channels = 0.026;

n_all = NaN(size(X));

inpolFlats = inpolygon(X,Y, pol_flat(:,1), pol_flat(:,2));
inpolTrans = inpolygon(X,Y, pol_trns(:,1), pol_trns(:,2));
n_all(inpolFlats) = n_flats;
n_all(~inpolFlats & ~inpolTrans) = 0.026;

% Interpolate remaining part
idx = ~isnan(n_all);
F = scatteredInterpolant(X(idx), Y(idx), n_all(idx));
n_all = F(X,Y);

%% Check
figure

%points
scatter(X,Y,10,n_all, 'filled')

% % Create a continuous-looking patch map by triangulating the scattered nodes
% tri = delaunay(X, Y);
% trisurf(tri, X, Y, zeros(size(X)), n_all, 'EdgeColor', 'none', 'FaceColor', 'interp');
% view(2); axis equal; hold on;

xlim([61800 73000]);
ylim([376500 382200]);
hcb = colorbar;
hcb.Label.String = "Manning's roughness";
hcb.Label.FontSize = 18;
hcb.FontSize = 12;
set(gca, 'FontSize', 16);
title("Manning's Roughness: Tidal Flats and Buffer", 'FontSize', 24);

% Divide tick labels by 1000 for display (convert to km)
xt = get(gca, 'XTick');
yt = get(gca, 'YTick');

% Only label even tick values (after dividing by 1000)
xt_km = xt/1000;
yt_km = yt/1000;
xt_labels = repmat({''}, size(xt_km));
yt_labels = repmat({''}, size(yt_km));
is_even_x = mod(round(xt_km), 2) == 0;
is_even_y = mod(round(yt_km), 2) == 0;
xt_labels(is_even_x) = arrayfun(@(v) num2str(v), xt_km(is_even_x), 'UniformOutput', false);
yt_labels(is_even_y) = arrayfun(@(v) num2str(v), yt_km(is_even_y), 'UniformOutput', false);
set(gca, 'XTickLabel', xt_labels, 'YTickLabel', yt_labels);
ylabel('RDy (km)', 'FontSize', 20);
xlabel('RDx (km)', 'FontSize', 20);


%% Write as .xyz file
% outputFile = 'p:\11210344-001-bathosszimm\05_Modellering\01_modelopzet\05_roughness_polygon\n_all.xyz';
% FID = fopen(outputFile, 'w');
% fprintf(FID, '%f %f %f\n', [X, Y, n_all].');
% fclose(FID);
