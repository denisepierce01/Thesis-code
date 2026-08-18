%% Plotting Zimm together 2016-2025

clear all;
close all;
clc;

KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Bath_buitendijks_polygoon.kml');
[POL_x.BATH,POL_y.BATH] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Ossenisse_buitendijks_polygoon.kml');
[POL_x.OSSE,POL_y.OSSE] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_Zimm.kml');
% KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Zimmerman_buitendijks_polygoon3.kml');
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

% load vaklodingen data
% load('p:\11207654-bathosszimm\04_Data\Vaklodingen\ZVAK_WS_helpdesk_vanTU.mat');
vak2025 = load('p:\11212794-westerschelde-2026\data\01_bathymetry\mat\WS2025.mat');
vak19552023 = load('p:\11212794-westerschelde-2026\data\01_bathymetry\mat\WS_1955-2023.mat');
% add year 2025 to the larger structure
vak2025.grd.x(1705:2546,2661:5076);
y2025interp = interp2(vak2025.grd.x(1705:2546,2661:5076),vak2025.grd.y(1705:2546,2661:5076),vak2025.grd.dp(1705:2546,2661:5076),vak19552023.grd.x,vak19552023.grd.y);
vak19552025 = vak19552023;
vak19552025.grd.dp(:,:,49) = y2025interp;
vak19552025.grd.year(49) = 2025;

% NAMES.BATH = 'Bath';          
% NAMES.OSSE = 'Ossenisse'; %DP turned off
NAMES.ZIMM = 'Zimmerman';     %DP turned off

KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\afzonderlijk\interessegebiedBATH_17_03_2026.kml');
[Randen_interessegebied.BATH(:,1), Randen_interessegebied.BATH(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_interessegebied.BATH(:,1) = Randen_interessegebied.BATH(:,1)./1000;
% Randen_interessegebied.BATH(:,2) = Randen_interessegebied.BATH(:,2)./1000;
KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\afzonderlijk\interessegebied_OSSENISSE_17_03_2026.kml');
[Randen_interessegebied.OSSE(:,1), Randen_interessegebied.OSSE(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_interessegebied.OSSE(:,1) = Randen_interessegebied.OSSE(:,1)./1000;
% Randen_interessegebied.OSSE(:,2) = Randen_interessegebied.OSSE(:,2)./1000;
% KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\afzonderlijk\Ossenisse_interessegebied_zoom.kml');
% [Randen_zoom.OSSE(:,1), Randen_zoom.OSSE(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_zoom.OSSE(:,1) = Randen_zoom.OSSE(:,1)./1000;
% Randen_zoom.OSSE(:,2) = Randen_zoom.OSSE(:,2)./1000;
% KML = KML2Coordinates('p:\11207654-bathosszimm\04_Data\Ingrepen\afzonderlijk\Zimmerman_interessegebied3.kml');
KML = KML2Coordinates('P:\11207654-internship-pierce-2026\05_Working\QGIS\SHP\boundary_Zimm.kml');

[Randen_interessegebied.ZIMM(:,1), Randen_interessegebied.ZIMM(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_interessegebied.ZIMM(:,1) = Randen_interessegebied.ZIMM(:,1)./1000;
% Randen_interessegebied.ZIMM(:,2) = Randen_interessegebied.ZIMM(:,2)./1000;
% Randen_interessegebied.BATH = [61.6890822784810 376.295965189873;61.9446202531646 376.761946202532;61.9518089090771 376.758557243633;61.9594986989963 376.756755094801;61.9684586672736 376.748730051194;61.9817443859881 376.742620768502;62.0031053334842 376.733025988223;62.0126889053428 376.728890021988;62.0209097205186 376.721972712671;62.0232843274958 376.716862407171;62.0297028656314 376.710409452239;62.0459591808227 376.687484818063;62.0479765427467 376.673832109387;62.0560277756495 376.667835517910;62.0668352399569 376.659408561423;62.0714424315798 376.652442414341;62.0746167531665 376.642870438319;62.0849249157957 376.631141989925;62.0996802864806 376.617984661131;62.1163913602776 376.606030198570;62.1275633448002 376.598068692647;62.1436946156372 376.590129281669;62.1530378688728 376.580687860352;62.1618269686908 376.572772187979;62.1734265373386 376.562049425665;62.1821827834794 376.560305708326;62.1913494880007 376.553503738095;62.1978269980425 376.549898333874;62.2286721559148 376.656033993640;62.2439601907556 376.660778190565;62.2562362089980 376.656399298050;62.2706270535707 376.650803143335;62.2854064068330 376.645347768576;62.2955780090678 376.643118390227;62.3064011406146 376.639687928673;62.3151143826174 376.635618062991;62.3237648252530 376.630338013674;62.3348090982553 376.629921314786;62.3451241691139 376.631769314997;62.3566112246786 376.633215196422;62.3636839663131 376.633404216320;62.3732721939052 376.631879002961;62.3886647881536 376.628196505597;62.4007984323737 376.627274973408;62.4109643255489 376.625230531693;62.4217746665816 376.622584804084;62.4322626526763 376.619411269479;62.4396979694270 376.618919198402;62.4666992056887 376.613528943991;62.4932411505502 376.608044821674;62.5191972048628 376.600461007993;62.5416434418468 376.592391833560;62.5688171408357 376.581882629658;62.5964756354510 376.569949743712;62.6282671147584 376.559487391335;62.6576981258943 376.548833788449;62.6716923844240 376.546084481721;62.6853264822072 376.541440342687;62.7042933518379 376.534085225269;62.7197796656527 376.532396351853;62.7206686378296 376.532431082538;62.7368595014481 376.527985666427;62.7574477260450 376.521211296093;62.7842417335284 376.512719208834;62.7989816452630 376.504652195504;62.8242585081182 376.492046935887;62.8363831310941 376.480906670191;62.8491932481103 376.471954662676;62.8728483677112 376.461750575669;62.8828463000464 376.459977894552;62.9052166015039 376.450337223654;62.9185680547234 376.441204600307;62.9349563064209 376.428276750112;62.9468882422845 376.412278534172;62.9616931329470 376.401735193821;62.9766624554969 376.402022938905;62.9902411446443 376.404032318262;63.0027113129013 376.401567609457;63.0190593905106 376.401278185256;63.0348562577095 376.402976975937;63.0627860830425 376.401772184283;63.0943988711095 376.391556244800;63.1312946745684 376.378410898574;63.1500470454716 376.371881262960;63.1595641035654 376.364660649681;63.1678006781822 376.359171353148;63.1793516883259 376.356124655140;63.1891757523697 376.353831040022;63.1971665645000 376.350383981827;63.2095289819432 376.347787168755;63.2185739533826 376.345849253197;63.2289637984194 376.346911336737;63.2350398155307 376.346686415458;63.2447786387037 376.343286462431;63.2585748819604 376.339501920409;63.2803536632840 376.336519792352;63.2990323769288 376.333551530562;63.3167597638409 376.329167676276;63.3402962128349 376.320890169557;63.3596995723355 376.314402031438;63.3757612809424 376.312672739452;63.3835592618948 376.311688085824;63.3969401616529 376.314075123021;63.4138754006835 376.310164539670;63.4250625448583 376.307775694507;63.4380638411896 376.303146526129;63.4482229838246 376.299745173579;63.4597259192703 376.299701710704;63.4730279816890 376.293966555549;63.4927170633981 376.293928854115;63.5056900265436 376.290843839433;63.5075042288431 376.290061675902;63.5285820668150 376.288054631765;63.5440686077606 376.282906120202;63.5509996341822 376.276980918175;63.5653489872349 376.274875797775;63.5824934840430 376.278484037748;63.6113225371158 376.270192536966;63.6415590493837 376.263425292325;63.6545803627142 376.257115788742;63.6736849263054 376.248882826262;63.6882847208508 376.243305336957;63.7017883823510 376.233968326447;63.7260764472368 376.232595469971;63.7438155879857 376.230586104387;63.7579234845241 376.230189344559;63.7721512686779 376.224752227727;63.7900067472695 376.219912653038;63.8077636921423 376.220891276913;63.8262377633025 376.221645549410;63.8376579522718 376.220380810806;63.8595350797284 376.212414855883;63.8898378061942 376.212668489177;63.9090084534909 376.211136288501;63.9288547675159 376.207097465383;63.9457798248060 376.200555452822;63.9672749733485 376.196592346574;63.9958552553458 376.188077360897;64.0482212164094 376.179541669333;64.1143801052378 376.158938600747;64.1857653098478 376.146891264111;64.2442867584539 376.130686396030;64.2736312624313 376.118018760502;64.3157537222604 376.106224027567;64.3661463713622 376.092736301546;64.4127102439798 376.078187200722;64.4469959069421 376.074537025302;64.4961355058188 376.070255919129;64.5307733550713 376.065777730372;64.5390822784810 376.064477848101;64.4549050632911 375.652610759494;61.9500000000000 375];
% Randen_interessegebied.OSSE = [56.2295094936709 378.218750000000;55.6823575949367 378.390110759494;55.6865891809648 378.403364137063;55.6990065925496 378.452569531569;55.7108420980837 378.501029912502;55.7260501872229 378.592550003495;55.7312995716068 378.630946669299;55.7392876665847 378.673612946481;55.7511508607582 378.740438509606;55.7550072708189 378.761746618422;55.7630520174911 378.789814723383;55.7708428023125 378.829383876475;55.7832079501827 378.883580581801;55.7861201130582 378.906511704089;55.7865175241372 378.923305761573;55.7858343492811 378.950989134631;55.7896994209175 378.984555754728;55.7964789216190 379.025763302053;55.8081501872044 379.070264737959;55.8149716747478 379.110424007240;55.8227252954749 379.147093862934;55.8319301022182 379.223826088895;55.8341024797755 379.249590156908;55.8423146327798 379.300754929098;55.8466762871588 379.324448809973;55.8480917073530 379.346142386811;55.8574569547057 379.371625744664;55.8608048600894 379.396907948761;55.8640099386887 379.435113521104;55.8716906913966 379.454683368470;55.8753822161940 379.494137511576;55.8754006029379 379.529318434287;55.8835762028661 379.565884854385;55.8945653604323 379.596765437732;55.8954838547777 379.631376453633;55.8922274266831 379.675856809048;55.8912989931165 379.724563700061;55.8856060239101 379.760912078353;55.8635136575891 379.828104508063;55.8510937074831 379.879021177397;55.8248412279164 379.908599964343;55.8371067233642 379.977427769238;55.8358042325958 379.979025699660;56.1000951299604 379.656618653904;58 378.300000000000];
% I = ones(size(ZVAK.X));
% I(~inpolygon(ZVAK.X./1000,ZVAK.Y./1000,Randen_interessegebied.BATH(:,1),Randen_interessegebied.BATH(:,2))&~inpolygon(ZVAK.X./1000,ZVAK.Y./1000,Randen_interessegebied.OSSE(:,1),Randen_interessegebied.OSSE(:,2))) = NaN;

%% 
figure;
plot(Randen_interessegebied.ZIMM(:,1)./1000, Randen_interessegebied.ZIMM(:,2)./1000, '-r', 'LineWidth', 2);
axis equal
grid on
box on
xlabel('RDx [km]');
ylabel('RDy [km]');
title('Zimmerman Interest Area Boundary');
%% Area of interest for plotting
% XLIM.BATH = [70 73];
% YLIM.BATH = [378.5  380.5];
% XLIM.BATH = [70.2, 72.8];      %DP clean
% YLIM.BATH = [378.9, 380.4];    %DP clean
% XLIM.BATH = [70.7, 70.9];      %DP zoom
% YLIM.BATH = [379.5, 379.7];    %DP zoom

% XLIM.OSSE = [56.5 60];      %DP clean
% YLIM.OSSE = [380.0 382.5];  %DP clean
% XLIM.OSSE = [57 60];
% % YLIM.OSSE = [380.0 382.0];

% XLIM.ZIMM = [64 67];
% YLIM.ZIMM = [379 381];
XLIM.ZIMM = [64.01 67.01];      %DP clean
YLIM.ZIMM = [379.2 380.8];      %DP clean

 
I = ones(size(vak19552025.grd.x));
I(~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.BATH(:,1),Randen_interessegebied.BATH(:,2))&~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.OSSE(:,1),Randen_interessegebied.OSSE(:,2))&~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.ZIMM(:,1),Randen_interessegebied.ZIMM(:,2))) = NaN;

y_min = 2016;
y_max = 2025;
% Create a 3x3 subplot for years 2016-2025 (excluding 2024 as in original)
years = y_min:y_max;
years(years==2023 | years==2024) = [];
nYears = length(years);   % should be 8

fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 1 20 24];   % adjusted for 3x3 grid
set(0,'DefaultAxesFontSize',8);

% Use LOCS = {'BATH'} as in the modified context
LOCS = {'ZIMM'}; 
Li = length(LOCS);

% Prepare colormap once
% CM_combined = [m_colmap('water'); m_colmap('land')];
CM = cptcmap('GMT_globe','ncol',24);

nRows = 4;
nCols = 2;

for k = 1:nYears
    Y_A = years(k);
    ax = subplot(nRows,nCols,k); hold(ax,'on'); axis equal; grid on; box on;
    AS = ax;
    idY_A = find(vak19552025.grd.year==Y_A);
    if isempty(idY_A)
        warning('Year %d not found in grd.year', Y_A);
        continue
    end
    P = pcolor(ax, vak19552025.grd.x./1000, vak19552025.grd.y./1000, vak19552025.grd.dp(:,:,idY_A).*I); % with masking
    % P = pcolor(ax, vak19552025.grd.x./1000, vak19552025.grd.y./1000, vak19552025.grd.dp(:,:,idY_A)); % without masking
    P.LineStyle = 'none';
    caxis(ax,[-3 3]);
    shading(ax,'interp');
    colormap(ax, CM);

    SA_temp = {ax};
    [LEG_G] = general_plot_parts(AS,1,NAMES,LOCS,XLIM,YLIM,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,'T1');
    title(ax, sprintf('%d', Y_A), 'FontSize', 10);
    xlim(ax, XLIM.(LOCS{1}));
    ylim(ax, YLIM.(LOCS{1}));

    % reduce axes labels to first column and last row
    % 1. Determine Position (for a 4x2 grid)
    isFirstColumn = (mod(k-1, nCols) == 0);
    isLastRow     = (k > (nRows-1)*nCols);

    % 2. Set X-Axis Labels (Last row only)
    if isLastRow
        xlabel(ax, 'RDx [km]');
    else
        xticklabels(ax, {});
        xlabel(ax, '');
    end

    % 3. Set Y-Axis Labels (First column only)
    if isFirstColumn
        ylabel(ax, 'RDy [km]');
    else
        yticklabels(ax, {});
        ylabel(ax, '');
    end

    % 4. Tidy Ticks
    ax.YTick = unique(round(ax.YTick*2)/2);
    ax.XTick = unique(round(ax.XTick*2)/2);

    % Add a single colorbar under the bottom row, centered across both columns
    if k == nYears
        cb = colorbar('southoutside');
        cb.Position(1) = 0.1;   % center left (adjust for 2-column centering)
        cb.Position(3) = 0.4;   % width
        cb.Position(4) = 0.015; % height
        cb.Position(2) = cb.Position(2) - 0.07;
        title(cb,'Bed Level [m NAP]','FontSize',9);
        cb.TickDirection = 'out';
        cb.FontSize = 9;
    end
end

SA = cell(1, nYears);
for ii = 1:nYears
    SA{ii} = subplot(nRows,nCols,ii);
end

% ---- Tighten subplot spacing ----
left_margin   = 0.08;
right_margin  = 0.04;
bottom_margin = 0.15;   % leave room for colorbar/legend at bottom
top_margin    = 0.04;
h_gap = 0.025;           % horizontal gap between columns
v_gap = 0.025;          % vertical gap between rows

total_h_gap = (nCols-1)*h_gap;
total_v_gap = (nRows-1)*v_gap;
ax_w = (1 - left_margin - right_margin - total_h_gap) / nCols;
ax_h = (1 - top_margin - bottom_margin - total_v_gap) / nRows;

for ii = 1:numel(SA)
    if isempty(SA{ii}) || ~isvalid(SA{ii})
        continue
    end
    col = mod(ii-1, nCols);
    row = floor((ii-1) / nCols);
    pos_x = left_margin + col*(ax_w + h_gap);
    pos_y = 1 - top_margin - (row+1)*ax_h - row*v_gap;
    SA{ii}.Position = [pos_x, pos_y, ax_w, ax_h];
end

drawnow;

%% Export
% print(fig,['p:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Vaklodingen\Output\ZIMM_2016_2025_CM6'  '.png'],'-dpng','-r600');

% %% FUNCTIONS SUB PLOT
% function [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,T)
% 
%     LEG_GROYNES = gobjects(1,3); % pre-allocate so empty categories don't break the legend call
% 
%     % for ki = 1:length(Opgehoogd_x)
%     %     if strcmp(T,'T1')
%     %         h = plot(Opgehoogd_x{ki}./1000,Opgehoogd_y{ki}./1000,':k','LineWidth',2);
%     %     else
%     %         h = plot(Opgehoogd_x{ki}./1000,Opgehoogd_y{ki}./1000,'Color',[1 1 1].*0.4);
%     %     end
%     %     LEG_GROYNES(4) = h(1);
%     % end
% 
%     if strcmp(T,'T1')
%         for ki = 1:length(Nieuw_x)
%             LEG_GROYNES(1) = plot(Nieuw_x{ki}./1000,Nieuw_y{ki}./1000,'-k','LineWidth',2);
%         end
%         for ki = 1:length(Bestaand_x)
%             LEG_GROYNES(3) = plot(Bestaand_x{ki}./1000,Bestaand_y{ki}./1000,'Color',[1 1 1].*0.4,'LineWidth',2);
%         end
%         % for ki = 1:length(Aangepast_x)
%         %     LEG_GROYNES(2) = plot(Aangepast_x{ki}./1000,Aangepast_y{ki}./1000,'--r','LineWidth',2);
%         % end
%     end
% 
%     axis equal
%     grid on
%     box on
%     xlabel('RDx [km]');
%     ylabel('RDy [km]')
% 
%     CB = colorbar;
%     delete(CB);
% 
%     % Only build the legend once, on the first subplot in the figure
%     hFig = ancestor(AS,'figure');
%     existingLeg = findall(hFig,'Type','Legend');
% 
%     if Li == 1
%         if isempty(existingLeg)
%             if strcmp(T,'T1')
%                 LEG_G = legend(LEG_GROYNES([1 3]), ...
%                     'New Construction', 'Existing Construction', ...
%                     'AutoUpdate','off','Location','southoutside');
%                 LEG_G.FontSize = 9;
%             else
%                 LEG_G = legend(LEG_GROYNES(1), ...
%                     'Bestaande dam/geulwandverdediging', ...
%                     'AutoUpdate','off','Location','southoutside');
%             end
%             LEG_G.Position(2) = 0.05; % y-pos
%             LEG_G.Position(1) = 0.67; % x-pos
%             LEG_G.Position(3) = 0.15; % width
%         else
%             LEG_G = existingLeg(1);
%         end
%         ylabel('')
%     else
%         LEG_G = [];
%     end
% 
%     title(NAMES.(LOCS{Li}))
%     xlim([XLIM.(LOCS{Li})])
%     ylim([YLIM.(LOCS{Li})])
% 
%     AS.YTick = unique(round(AS.YTick*2)/2);
%     AS.XTick = unique(round(AS.XTick*2)/2);
%     set(gca,'Layer','Top');
% end

%% Plotting as individuals
XLIM.ZIMM = [63.9 67.2];      
YLIM.ZIMM = [378.8 380.7];

y_min = 2016;
y_max = 2025;
years = y_min:y_max;
years(years==2023 | years==2024) = [];
nYears = length(years);

LOCS = {'ZIMM'};
Li = length(LOCS);

CM = cptcmap('GMT_globe','ncol',24);

outputFolder = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Vaklodingen\Output';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

for k = 1:nYears
    Y_A = years(k);
    idY_A = find(vak19552025.grd.year==Y_A);
    if isempty(idY_A)
        warning('Year %d not found in grd.year', Y_A);
        continue
    end

    % Create a fresh individual figure for this year
    fig = figure('Visible','off');   % 'off' avoids popping up 8+ windows; use 'on' if you want to see them
    fig.Units = 'centimeters';
    fig.Position = [1 1 12 10];      % adjust size for a single plot

    ax = axes(fig); hold(ax,'on'); axis equal; grid on; box on;
    AS = ax;

    I = ones(size(vak19552025.grd.x));
    I(~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.BATH(:,1),Randen_interessegebied.BATH(:,2))&~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.OSSE(:,1),Randen_interessegebied.OSSE(:,2))&~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.ZIMM(:,1),Randen_interessegebied.ZIMM(:,2))) = NaN;

    P = pcolor(ax, vak19552025.grd.x./1000, vak19552025.grd.y./1000, vak19552025.grd.dp(:,:,idY_A).*I); % with masking
    % P = pcolor(ax, vak19552025.grd.x./1000, vak19552025.grd.y./1000, vak19552025.grd.dp(:,:,idY_A)); % without masking
    P.LineStyle = 'none';
    caxis(ax,[-3 3]);
    shading(ax,'interp');
    colormap(ax, CM);

    [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,'T1');
    title(ax, sprintf('Zimmerman %d', Y_A), 'FontSize', 10);
    xlim(ax, XLIM.(LOCS{1}));
    ylim(ax, YLIM.(LOCS{1}));
    xlabel(ax, 'RDx [km]');
    ylabel(ax, 'RDy [km]');

    cb = colorbar(ax,'southoutside');
    title(cb,'Bed Level [m NAP]');
    cb.TickDirection = 'out';
    % shorten colorbar to half the axis width and center it under the axes
    drawnow; % ensure positions are up-to-date
    axPos = ax.Position; % [x y w h] in normalized units of the figure
    cbPos = cb.Position; % [x y w h]
    cbPos(3) = axPos(3)*0.5;  
    cbPos(2) = axPos(3) - 0.72;  % half the axis width
    cbPos(1) = axPos(1) + 0.4; % center under axis
    cb.Position = cbPos;

    % Save this year's figure as its own PNG, named by Y_A
    outFile = fullfile(outputFolder, sprintf('ZIMM_%d.png', Y_A));
    print(fig, outFile, '-dpng', '-r300');

    close(fig);  % close to free memory before next iteration
end

%% FUNCTIONS single figure plots
function [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,T)

    LEG_GROYNES = gobjects(1,3); % pre-allocate so empty categories don't break the legend call

    % for ki = 1:length(Opgehoogd_x)
    %     if strcmp(T,'T1')
    %         h = plot(Opgehoogd_x{ki}./1000,Opgehoogd_y{ki}./1000,':k','LineWidth',2);
    %     else
    %         h = plot(Opgehoogd_x{ki}./1000,Opgehoogd_y{ki}./1000,'Color',[1 1 1].*0.4);
    %     end
    %     LEG_GROYNES(4) = h(1);
    % end

    if strcmp(T,'T1')
        for ki = 1:length(Nieuw_x)
            LEG_GROYNES(1) = plot(Nieuw_x{ki}./1000,Nieuw_y{ki}./1000,'-k','LineWidth',2);
        end
        for ki = 1:length(Bestaand_x)
            LEG_GROYNES(3) = plot(Bestaand_x{ki}./1000,Bestaand_y{ki}./1000,'Color',[1 1 1].*0.4,'LineWidth',2);
        end
        % for ki = 1:length(Aangepast_x)
        %     LEG_GROYNES(2) = plot(Aangepast_x{ki}./1000,Aangepast_y{ki}./1000,'--r','LineWidth',2);
        % end
    end

    axis equal
    grid on
    box on
    xlabel('RDx [km]');
    ylabel('RDy [km]')

    CB = colorbar;
    delete(CB);

    % Only build the legend once, on the first subplot in the figure
    hFig = ancestor(AS,'figure');
    existingLeg = findall(hFig,'Type','Legend');

    if Li == 1
        if isempty(existingLeg)
            if strcmp(T,'T1')
                LEG_G = legend(LEG_GROYNES([1 3]), ...
                'New Construction', 'Existing Construction', ...
                'AutoUpdate','off','Location','southoutside');
            LEG_G.FontSize = 8;
            else
                LEG_G = legend(LEG_GROYNES(1), ...
                    'Bestaande dam/geulwandverdediging', ...
                    'AutoUpdate','off','Location','southoutside');
            end
            LEG_G.Position(2) = 0.05; % y-pos
            LEG_G.Position(1) = 0.25; % x-pos
            LEG_G.Position(3) = 0.05; % width
            % LEG_G.Position(4) = 0.03; % width
        else
            LEG_G = existingLeg(1);
        end
        ylabel('')
    else
        LEG_G = [];
    end

    title(NAMES.(LOCS{Li}))
    xlim([XLIM.(LOCS{Li})])
    ylim([YLIM.(LOCS{Li})])

    AS.YTick = unique(round(AS.YTick*2)/2);
    AS.XTick = unique(round(AS.XTick*2)/2);
    set(gca,'Layer','Top');
end

% 
% % function [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Opgehoogd_x,Opgehoogd_y,Aangepast_x,Aangepast_y,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,T)
% function [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Aangepast_x,Aangepast_y,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,T)
% 
%    if strcmp(T,'T1')
% 
%         for ki = 1:length(Nieuw_x)
%             LEG_GROYNES(1) = plot(Nieuw_x{ki}./1000,Nieuw_y{ki}./1000,'-k','LineWidth',2);
%         end
%         for ki = 1:length(Aangepast_x)
%             LEG_GROYNES(2) = plot(Aangepast_x{ki}./1000,Aangepast_y{ki}./1000,'-r','LineWidth',2);
%         end
%         for ki = 1:length(Bestaand_x)
%             LEG_GROYNES(3) = plot(Bestaand_x{ki}./1000,Bestaand_y{ki}./1000,'Color',[1 1 1].*0.5,'LineWidth',2);
%         end
% 
%     end
%         for ki = 1:length(LOCS)
%             fill(['POL_x.' LOCS{ki}]./1000,['POL_y.' LOCS{ki}]./1000,[1 1 1].*0.85)
%         end
% 
%     axis equal
%     grid on
%     box on
%     xlabel('RDx [km]');
%     ylabel('RDy [km]')
% 
%     CB = colorbar;
%     delete(CB);
% 
%     if Li == 2
%        ylabel('')
%        LEG_G = [];
%     elseif Li == 1
%         % Create a legend only once for the entire figure.
%         % Check if a legend already exists in the figure; if not, create it.
%         hFig = ancestor(AS,'figure');
%         existingLeg = findall(hFig,'Type','Legend');
%         if isempty(existingLeg)
%             if strcmp(T,'T1')
%                 % Remove "Modifications" from legend: only show New Construction and Existing Construction
%                 % LEG_GROYNES indices: 1 -> Nieuw (New Construction), 2 -> Aangepast (Modifications), 3 -> Bestaand (Existing)
%                 % Use only 1 and 3
%                 LEG_G = legend(LEG_GROYNES([1 3]),'New Construction','Existing Construction','AutoUpdate','off','Location','southoutside');
% 
%             else
%                 LEG_G = legend(LEG_GROYNES(1),'Existing Channel Wall','AutoUpdate','off','Location','southoutside');
%             end
%             % Move legend to a suitable position without overlapping subplots
%             LEG_G.Position(2) = 0.03; % adjust vertical position as needed
%             LEG_G.Position(1) = 0.60; % center-right
%             LEG_G.Position(3) = 0.15;  % width
%         else
%             % Reuse existing legend handle
%             LEG_G = existingLeg(1);
%         end
%         ylabel('')
%     else
%         LEG_G = [];
%     end    
% 
%     title(NAMES.(LOCS{Li}))
%     xlim([XLIM.(LOCS{Li})])
%     ylim([YLIM.(LOCS{Li})])    
% 
%     AS.YTick = unique(round(AS.YTick*2)/2);    
%     AS.XTick = unique(round(AS.XTick*2)/2);    
%     set(gca,'Layer','Top');
% end
% 
% function format_ratios_and_positions(SA,LOCS,LEG_G,XLIM,T)
%     A1p = plotboxpos(SA{1});
%     SA{1}.Position(3)=A1p(3)*1;
% 
% 
%     % Ensure equal scaling of x and y grid subplot 2
%     desired_ratio = diff(XLIM.(LOCS{2}))/diff(XLIM.(LOCS{1}));
%     SA{2}.Position(3) =A1p(3)*desired_ratio*1;
%     A2p = plotboxpos(SA{2});
%     actual_ratio = A2p(3)./A1p(3);
%     if abs(desired_ratio-actual_ratio)>0.1
%         error('Ratio is not equal to both axes')
%     end
%     SA{2}.Position(1) = A1p(1)+A1p(3)+0.05;
%     SA{2}.Position(2) = A1p(2)+A1p(4)-A2p(4)+SA{2}.Position(2)-A2p(2);
% 
%     % Ensure equal scaling of x and y grid subplot 3
%     desired_ratio = diff(XLIM.(LOCS{3}))/diff(XLIM.(LOCS{1}));
%     SA{3}.Position(3) =A1p(3)*desired_ratio*1;
%     A3p = plotboxpos(SA{3});
%     actual_ratio = A3p(3)./A1p(3);
%     if abs(desired_ratio-actual_ratio)>0.1
%         error('Ratio is not equal to both axes')
%     end 
%     SA{3}.Position(1) = SA{2}.Position(1)+A2p(3)+0.05;
%     SA{3}.Position(2) = A1p(2)+A1p(4)-A3p(4)+SA{3}.Position(2)-A3p(2);
% end
% 
% % Adjust overall figure margins and spacing between subplots
% fig = ancestor(SA{1},'figure'); % get figure handle from existing axes
% % Desired margins (normalized units)
% left_margin   = 0.06;
% right_margin  = 0.04;
% bottom_margin = 0.12;
% top_margin    = 0.08;
% h_gap = 0.025; % horizontal gap between subplots
% v_gap = 0.025; % vertical gap between subplots
% 
% % Number of columns/rows are 3 and 3 in this layout
% ncols = 2; nrows = 4;
% 
% % Compute width/height for each subplot (approx)
% total_h_gap = (ncols-1)*h_gap;
% total_v_gap = (nrows-1)*v_gap;
% ax_w = (1 - left_margin - right_margin - total_h_gap) / ncols;
% ax_h = (1 - top_margin - bottom_margin - total_v_gap) / nrows;
% 
% % Position subplots in a tight grid (row-major, top to bottom)
% for ii = 1:numel(SA)
%     col = mod(ii-1,ncols);
%     row = floor((ii-1)/ncols);
%     % y starts from top
%     pos_x = left_margin + col*(ax_w + h_gap);
%     pos_y = 1 - top_margin - (row+1)*ax_h - row*v_gap;
%     % Preserve current height scaling adjustments made earlier by format_ratios_and_positions
%     SA{ii}.Position = [pos_x, pos_y, ax_w, ax_h];
% end
% 
% % Optionally reduce axes label/legend overlaps by shrinking axes slightly
% for ii = 1:numel(SA)
%     SA{ii}.LooseInset = max(0.02, SA{ii}.LooseInset*0.6);
% end
% 
% drawnow;
% 
% % %% create box with samples and analyze trends of bed
% % Define 100m x 100m box
% center_x = 72 * 1000;
% center_y = 380 * 1000;
% 
% half_size = 50; 
% dx = 10; dy = 10; % 10 m sampling interval
% x_samples = (center_x-half_size):dx:(center_x+half_size);
% y_samples = (center_y-half_size):dy:(center_y+half_size);
% [XS, YS] = meshgrid(x_samples, y_samples);
% 
% %vak19552025.grd.dp(:,:,41:49)