clear all;
close all;
clc;

KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Bath_buitendijks_polygoon.kml');
[POL_x.BATH,POL_y.BATH] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Ossenisse_buitendijks_polygoon.kml');
[POL_x.OSSE,POL_y.OSSE] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Boundary_polygoon\afzonderlijk\Zimmerman_buitendijks_polygoon3.kml');
[POL_x.ZIM,POL_y.ZIM] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\7_1_2026\Nieuw.kml');
for ki = 1:length(KML)
    [Nieuw_x{ki},Nieuw_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\7_1_2026\Aangepast.kml');
for ki = 1:length(KML)
    [Aangepast_x{ki},Aangepast_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\7_1_2026\Bestaand.kml');
for ki = 1:length(KML)
    [Bestaand_x{ki},Bestaand_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
Opgehoogd_x{1} = [];
Opgehoogd_y{1} = [];

% load vaklodingen data
% load('p:\11210344-001-bathosszimm\04_Data\Vaklodingen\ZVAK_WS_helpdesk_vanTU.mat');
vak2025 = load('p:\11212794-westerschelde-2026\data\01_bathymetry\mat\WS2025.mat');
vak19552023 = load('p:\11212794-westerschelde-2026\data\01_bathymetry\mat\WS_1955-2023.mat');
% add year 2025 to the larger structure
vak2025.grd.x(1705:2546,2661:5076);
y2025interp = interp2(vak2025.grd.x(1705:2546,2661:5076),vak2025.grd.y(1705:2546,2661:5076),vak2025.grd.dp(1705:2546,2661:5076),vak19552023.grd.x,vak19552023.grd.y);
vak19552025 = vak19552023;
vak19552025.grd.dp(:,:,49) = y2025interp;
vak19552025.grd.year(49) = 2025;

%% 
NAMES.BATH = 'Bath';
NAMES.OSSE = 'Ossenisse';
NAMES.ZIMM = 'Zimmerman';

KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\afzonderlijk\Bath_interessegebied.kml');
[Randen_interessegebied.BATH(:,1), Randen_interessegebied.BATH(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_interessegebied.BATH(:,1) = Randen_interessegebied.BATH(:,1)./1000;
% Randen_interessegebied.BATH(:,2) = Randen_interessegebied.BATH(:,2)./1000;
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\afzonderlijk\interessegebied_OSSENISSE_17_03_2026.kml');
[Randen_interessegebied.OSSE(:,1), Randen_interessegebied.OSSE(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_interessegebied.OSSE(:,1) = Randen_interessegebied.OSSE(:,1)./1000;
% Randen_interessegebied.OSSE(:,2) = Randen_interessegebied.OSSE(:,2)./1000;
% KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\afzonderlijk\Ossenisse_interessegebied_zoom.kml');
% [Randen_zoom.OSSE(:,1), Randen_zoom.OSSE(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_zoom.OSSE(:,1) = Randen_zoom.OSSE(:,1)./1000;
% Randen_zoom.OSSE(:,2) = Randen_zoom.OSSE(:,2)./1000;
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\afzonderlijk\Zimmerman_interessegebied.kml');
[Randen_interessegebied.ZIMM(:,1), Randen_interessegebied.ZIMM(:,2)] = convertCoordinates(KML{1}(:,1),KML{1}(:,2),'CS2.code',28992,'CS1.code',4326);
% Randen_interessegebied.ZIMM(:,1) = Randen_interessegebied.ZIMM(:,1)./1000;
% Randen_interessegebied.ZIMM(:,2) = Randen_interessegebied.ZIMM(:,2)./1000;
% Randen_interessegebied.BATH = [61.6890822784810 376.295965189873;61.9446202531646 376.761946202532;61.9518089090771 376.758557243633;61.9594986989963 376.756755094801;61.9684586672736 376.748730051194;61.9817443859881 376.742620768502;62.0031053334842 376.733025988223;62.0126889053428 376.728890021988;62.0209097205186 376.721972712671;62.0232843274958 376.716862407171;62.0297028656314 376.710409452239;62.0459591808227 376.687484818063;62.0479765427467 376.673832109387;62.0560277756495 376.667835517910;62.0668352399569 376.659408561423;62.0714424315798 376.652442414341;62.0746167531665 376.642870438319;62.0849249157957 376.631141989925;62.0996802864806 376.617984661131;62.1163913602776 376.606030198570;62.1275633448002 376.598068692647;62.1436946156372 376.590129281669;62.1530378688728 376.580687860352;62.1618269686908 376.572772187979;62.1734265373386 376.562049425665;62.1821827834794 376.560305708326;62.1913494880007 376.553503738095;62.1978269980425 376.549898333874;62.2286721559148 376.656033993640;62.2439601907556 376.660778190565;62.2562362089980 376.656399298050;62.2706270535707 376.650803143335;62.2854064068330 376.645347768576;62.2955780090678 376.643118390227;62.3064011406146 376.639687928673;62.3151143826174 376.635618062991;62.3237648252530 376.630338013674;62.3348090982553 376.629921314786;62.3451241691139 376.631769314997;62.3566112246786 376.633215196422;62.3636839663131 376.633404216320;62.3732721939052 376.631879002961;62.3886647881536 376.628196505597;62.4007984323737 376.627274973408;62.4109643255489 376.625230531693;62.4217746665816 376.622584804084;62.4322626526763 376.619411269479;62.4396979694270 376.618919198402;62.4666992056887 376.613528943991;62.4932411505502 376.608044821674;62.5191972048628 376.600461007993;62.5416434418468 376.592391833560;62.5688171408357 376.581882629658;62.5964756354510 376.569949743712;62.6282671147584 376.559487391335;62.6576981258943 376.548833788449;62.6716923844240 376.546084481721;62.6853264822072 376.541440342687;62.7042933518379 376.534085225269;62.7197796656527 376.532396351853;62.7206686378296 376.532431082538;62.7368595014481 376.527985666427;62.7574477260450 376.521211296093;62.7842417335284 376.512719208834;62.7989816452630 376.504652195504;62.8242585081182 376.492046935887;62.8363831310941 376.480906670191;62.8491932481103 376.471954662676;62.8728483677112 376.461750575669;62.8828463000464 376.459977894552;62.9052166015039 376.450337223654;62.9185680547234 376.441204600307;62.9349563064209 376.428276750112;62.9468882422845 376.412278534172;62.9616931329470 376.401735193821;62.9766624554969 376.402022938905;62.9902411446443 376.404032318262;63.0027113129013 376.401567609457;63.0190593905106 376.401278185256;63.0348562577095 376.402976975937;63.0627860830425 376.401772184283;63.0943988711095 376.391556244800;63.1312946745684 376.378410898574;63.1500470454716 376.371881262960;63.1595641035654 376.364660649681;63.1678006781822 376.359171353148;63.1793516883259 376.356124655140;63.1891757523697 376.353831040022;63.1971665645000 376.350383981827;63.2095289819432 376.347787168755;63.2185739533826 376.345849253197;63.2289637984194 376.346911336737;63.2350398155307 376.346686415458;63.2447786387037 376.343286462431;63.2585748819604 376.339501920409;63.2803536632840 376.336519792352;63.2990323769288 376.333551530562;63.3167597638409 376.329167676276;63.3402962128349 376.320890169557;63.3596995723355 376.314402031438;63.3757612809424 376.312672739452;63.3835592618948 376.311688085824;63.3969401616529 376.314075123021;63.4138754006835 376.310164539670;63.4250625448583 376.307775694507;63.4380638411896 376.303146526129;63.4482229838246 376.299745173579;63.4597259192703 376.299701710704;63.4730279816890 376.293966555549;63.4927170633981 376.293928854115;63.5056900265436 376.290843839433;63.5075042288431 376.290061675902;63.5285820668150 376.288054631765;63.5440686077606 376.282906120202;63.5509996341822 376.276980918175;63.5653489872349 376.274875797775;63.5824934840430 376.278484037748;63.6113225371158 376.270192536966;63.6415590493837 376.263425292325;63.6545803627142 376.257115788742;63.6736849263054 376.248882826262;63.6882847208508 376.243305336957;63.7017883823510 376.233968326447;63.7260764472368 376.232595469971;63.7438155879857 376.230586104387;63.7579234845241 376.230189344559;63.7721512686779 376.224752227727;63.7900067472695 376.219912653038;63.8077636921423 376.220891276913;63.8262377633025 376.221645549410;63.8376579522718 376.220380810806;63.8595350797284 376.212414855883;63.8898378061942 376.212668489177;63.9090084534909 376.211136288501;63.9288547675159 376.207097465383;63.9457798248060 376.200555452822;63.9672749733485 376.196592346574;63.9958552553458 376.188077360897;64.0482212164094 376.179541669333;64.1143801052378 376.158938600747;64.1857653098478 376.146891264111;64.2442867584539 376.130686396030;64.2736312624313 376.118018760502;64.3157537222604 376.106224027567;64.3661463713622 376.092736301546;64.4127102439798 376.078187200722;64.4469959069421 376.074537025302;64.4961355058188 376.070255919129;64.5307733550713 376.065777730372;64.5390822784810 376.064477848101;64.4549050632911 375.652610759494;61.9500000000000 375];
% Randen_interessegebied.OSSE = [56.2295094936709 378.218750000000;55.6823575949367 378.390110759494;55.6865891809648 378.403364137063;55.6990065925496 378.452569531569;55.7108420980837 378.501029912502;55.7260501872229 378.592550003495;55.7312995716068 378.630946669299;55.7392876665847 378.673612946481;55.7511508607582 378.740438509606;55.7550072708189 378.761746618422;55.7630520174911 378.789814723383;55.7708428023125 378.829383876475;55.7832079501827 378.883580581801;55.7861201130582 378.906511704089;55.7865175241372 378.923305761573;55.7858343492811 378.950989134631;55.7896994209175 378.984555754728;55.7964789216190 379.025763302053;55.8081501872044 379.070264737959;55.8149716747478 379.110424007240;55.8227252954749 379.147093862934;55.8319301022182 379.223826088895;55.8341024797755 379.249590156908;55.8423146327798 379.300754929098;55.8466762871588 379.324448809973;55.8480917073530 379.346142386811;55.8574569547057 379.371625744664;55.8608048600894 379.396907948761;55.8640099386887 379.435113521104;55.8716906913966 379.454683368470;55.8753822161940 379.494137511576;55.8754006029379 379.529318434287;55.8835762028661 379.565884854385;55.8945653604323 379.596765437732;55.8954838547777 379.631376453633;55.8922274266831 379.675856809048;55.8912989931165 379.724563700061;55.8856060239101 379.760912078353;55.8635136575891 379.828104508063;55.8510937074831 379.879021177397;55.8248412279164 379.908599964343;55.8371067233642 379.977427769238;55.8358042325958 379.979025699660;56.1000951299604 379.656618653904;58 378.300000000000];
% I = ones(size(ZVAK.X));
% I(~inpolygon(ZVAK.X./1000,ZVAK.Y./1000,Randen_interessegebied.BATH(:,1),Randen_interessegebied.BATH(:,2))&~inpolygon(ZVAK.X./1000,ZVAK.Y./1000,Randen_interessegebied.OSSE(:,1),Randen_interessegebied.OSSE(:,2))) = NaN;

XLIM.BATH = [70 73];
YLIM.BATH = [378.5  380.5];
XLIM.OSSE = [57 60];
YLIM.OSSE = [380.0 382.0];
XLIM.ZIMM = [64 67];
YLIM.ZIMM = [379 381];

I = ones(size(vak19552025.grd.x));
I(~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.BATH(:,1),Randen_interessegebied.BATH(:,2))&~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.OSSE(:,1),Randen_interessegebied.OSSE(:,2))&~inpolygon(vak19552025.grd.x,vak19552025.grd.y,Randen_interessegebied.ZIMM(:,1),Randen_interessegebied.ZIMM(:,2))) = NaN;

y_min = 2015;
y_max = 2020;
for Y_A = y_min:(y_max-1)
    for Y_B = (Y_A+1):y_max
        if Y_A == 2024 || Y_B == 2024
            continue
        end

        fig = figure;
        fig.Units = 'centimeters';
        % fig.Position = [1 1 16 8.7];
        fig.Position = [1 1 30 10];

        set(0,'DefaultAxesFontSize',9);
        
        LOCS = {'OSSE','BATH','ZIMM'};
        % LOCS = {'ZIMM'};
        
        for Li = 1:length(LOCS)
            
%             SA{Li} = subaxis(1,2,Li,'MB',0.32,'MT',0.04,'ML',-0.058,'MR',0.03,'PL',-0.02);
            SA{Li} = subaxis(1,3,Li,'MB',0.11,'MT',0.035,'ML',0.07,'MR',0.07,'PL',0);
            hold on
            AS = gca;             
                        
            %     CAX = [-0.56 -.55];
            %     ele(find(ele<CAX(1))) = CAX(1);
% %             BV = ((ZVAK.Z.(['Y' num2str(Y_B)])-ZVAK.Z.(['Y' num2str(Y_A)])).*100)./(Y_B-Y_A).*I; % Bodemverandering in cm per jaar
            idY_A = find(vak19552025.grd.year==Y_A);
            idY_B = find(vak19552025.grd.year==Y_B);
            % BV = ((vak19552025.grd.dp(:,:,idY_B)-vak19552025.grd.dp(:,:,idY_A)).*100)./(Y_B-Y_A).*I; % Bodemverandering in cm per jaar
            BV = ((vak19552025.grd.dp(:,:,idY_B)-vak19552025.grd.dp(:,:,idY_A)).*100.*I); % Bodemverandering totaal in cm

            P=pcolor(vak19552025.grd.x./1000,vak19552025.grd.y./1000,BV);
            P.LineStyle = 'none';
            % caxis([-50 50]) % voor de plots in cm per jaar
            caxis([-150 150]) % voor de andere plots

            shading interp;
            
%             [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Opgehoogd_x,Opgehoogd_y,Aangepast_x,Aangepast_y,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,'T1');
            [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Aangepast_x,Aangepast_y,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,'T1');

            pause(0.1)          
                    
%             axis equal
%             grid on
%             box on
%             xlabel('RDx [km]');
%             ylabel('RDy [km]')
%           
%             
%             title(NAMES.(LOCS{Li}))
%             xlim([XLIM.(LOCS{Li})])
%             ylim([YLIM.(LOCS{Li})])
             
            AS = gca;
            AS.YTick = unique(round(AS.YTick));
            AS.XTick = unique(round(AS.XTick));            
                       
            %colormap(fliplr(gray')'  )
            %CM = turbo(10);
            CM = fliplr(cbrewer('div','RdBu',9)')';
            colormap(CM);
            %colormap(cbrewer('seq','YlGn',11));
            if Li == 2
                
                CB = colorbar(SA{Li},'Location','SouthOutside');        
                % CB.Position = [0.2 0.0834    0.3    0.02];
                % CB.Position = [CB.Position(1) CB.Position(2) CB.Position(3) 0.0200];
                % cbt = title(CB,[num2str(Y_B) ' - ' num2str(Y_A) ' [cm/yr]']);
                cbt = title(CB,[num2str(Y_B) ' - ' num2str(Y_A) ' [cm]']);
                CB.TickDirection = 'out';
            end
            
            set(gca,'Layer','Top');
        end
        CB.Position = [CB.Position(1) CB.Position(2)-0.15 CB.Position(3) 0.0200];
        format_ratios_and_positions(SA,LOCS,LEG_G,XLIM,'T1'); 

%         A1p = plotboxpos(SA{1});
%         A2p = plotboxpos(SA{2});
%         SA{2}.Position(2) = A1p(2)+A1p(4)-A2p(4)+SA{2}.Position(2)-A2p(2);
%         LEG_G.Position(1) = 0.6145;
%         LEG_G.Position(2) = 0.7515;
%         %cb.Position(1) = LEG_Ts.Position(1)+LEG_Ts.Position(3)/2-cb.Position(3)/2;

%         A1p = plotboxpos(SA{1});
%         % Ensure equal scaling of x and y grid
%         desired_ratio = diff(XLIM.(LOCS{2}))/diff(XLIM.(LOCS{1}));
%         SA{2}.Position(3) =A1p(3)*desired_ratio;
%         A2p = plotboxpos(SA{2});
%         actual_ratio = A2p(3)./A1p(3);
%         if abs(desired_ratio-actual_ratio)>0.1
%             error('Ratio is not equal to both axes')
%         end
%         SA{2}.Position(1) = A1p(1)+A1p(3)+0.08;
%         SA{2}.Position(2) = A1p(2)+A1p(4)-A2p(4)+SA{2}.Position(2)-A2p(2);
%         LEG_G.Position(1) = 1-LEG_G.Position(3)-0.002;
% 
%             LEG_G.Position(2) = 0.003;
        
        print(fig,['p:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Vaklodingen\Output\' num2str(Y_B) '-' num2str(Y_A) '.png'],'-dpng','-r600');
        
        % Exporteer gemiddelde bodemveranderingsrates [cm/yr] per gebied per periode
        BV_OSSE = BV;
        BV_OSSE(vak19552023.grd.x./1000<61) = NaN;
        BV_BATH = BV;
        BV_BATH(vak19552023.grd.x./1000>69) = NaN;
        % BV_ZIMM = BV;
        % BV_ZIMM(vak19552023.grd.x./1000>69) = NaN;
        fprintf('%s\t',[num2str(Y_B) '-' num2str(Y_A)]);
        fprintf('OSSE %.1f [cm/yr]\t',nanmean(nanmean(BV_OSSE)))
        fprintf('BATH %.1f [cm/yr]\n',nanmean(nanmean(BV_BATH)))
        % fprintf('ZIMM %.1f [cm/yr]\n',nanmean(nanmean(BV_ZIMM)))
        
    end
end

%% FUNCTIONS
% function [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Opgehoogd_x,Opgehoogd_y,Aangepast_x,Aangepast_y,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,T)
function [LEG_G] = general_plot_parts(AS,Li,NAMES,LOCS,XLIM,YLIM,Aangepast_x,Aangepast_y,Nieuw_x,Nieuw_y,Bestaand_x,Bestaand_y,POL_x,POL_y,T)

    LEG_GROYNES = [];
  
%     for ki = 1:length(Opgehoogd_x)
%         if strcmp(T,'T1')
%             LEG_GROYNES(4) = plot(Opgehoogd_x{ki}./1000,Opgehoogd_y{ki}./1000,':k','LineWidth',2);
%         else
%             LEG_GROYNES(4) = plot(Opgehoogd_x{ki}./1000,Opgehoogd_y{ki}./1000,'Color',[1 1 1].*0.4);
%         end
%     end
   if strcmp(T,'T1')
    
        for ki = 1:length(Nieuw_x)
            LEG_GROYNES(1) = plot(Nieuw_x{ki}./1000,Nieuw_y{ki}./1000,'-k','LineWidth',2);
        end
        for ki = 1:length(Aangepast_x)
            LEG_GROYNES(2) = plot(Aangepast_x{ki}./1000,Aangepast_y{ki}./1000,'-r','LineWidth',2);
        end
        for ki = 1:length(Bestaand_x)
            LEG_GROYNES(3) = plot(Bestaand_x{ki}./1000,Bestaand_y{ki}./1000,'Color',[1 1 1].*0.4);
        end

    end
        for ki = 1:length(LOCS)
            fill(['POL_x.' LOCS{ki}]./1000,['POL_y.' LOCS{ki}]./1000,[1 1 1].*0.85)
        end

    axis equal
    grid on
    box on
    xlabel('RDx [km]');
    ylabel('RDy [km]')
    
    CB = colorbar;
    delete(CB);
    
    if Li == 2
       ylabel('')
       LEG_G = [];
    elseif Li == 3  
            if strcmp(T,'T1')
            LEG_G = legend(LEG_GROYNES,'Nieuwe constructie','Aangepaste constructie','Bestaande constructie','AutoUpdate','off');
            else
            LEG_G = legend(LEG_GROYNES(1),'Bestaande dam/geulwandverdediging','AutoUpdate','off');
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

function format_ratios_and_positions(SA,LOCS,LEG_G,XLIM,T)
    A1p = plotboxpos(SA{1});
    SA{1}.Position(3)=A1p(3)*1;

   
    % Ensure equal scaling of x and y grid subplot 2
    desired_ratio = diff(XLIM.(LOCS{2}))/diff(XLIM.(LOCS{1}));
    SA{2}.Position(3) =A1p(3)*desired_ratio*1;
    A2p = plotboxpos(SA{2});
    actual_ratio = A2p(3)./A1p(3);
    if abs(desired_ratio-actual_ratio)>0.1
        error('Ratio is not equal to both axes')
    end
    SA{2}.Position(1) = A1p(1)+A1p(3)+0.05;
    SA{2}.Position(2) = A1p(2)+A1p(4)-A2p(4)+SA{2}.Position(2)-A2p(2);

    % Ensure equal scaling of x and y grid subplot 3
    desired_ratio = diff(XLIM.(LOCS{3}))/diff(XLIM.(LOCS{1}));
    SA{3}.Position(3) =A1p(3)*desired_ratio*1;
    A3p = plotboxpos(SA{3});
    actual_ratio = A3p(3)./A1p(3);
    if abs(desired_ratio-actual_ratio)>0.1
        error('Ratio is not equal to both axes')
    end 
    SA{3}.Position(1) = SA{2}.Position(1)+A2p(3)+0.05;
    SA{3}.Position(2) = A1p(2)+A1p(4)-A3p(4)+SA{3}.Position(2)-A3p(2);
    % LEG_G.Position(1) = 1-LEG_G.Position(3)-0.45;
    % if strcmp(T,'T1')
    %     LEG_G.Position(2) = 0.15;
    % else
    %     LEG_G.Position(2) = .07;
    % end
end