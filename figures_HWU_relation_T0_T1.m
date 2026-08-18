clear all;
close all;
clc;

%% Initialise

dirs.figures = 'p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Figures\';

% *** ADCP ***
load('p:\11210344-001-bathosszimm\04_Data\ADCP\Structures\ADCP.mat');

% *** BATHYMETRY ***
load('p:\11210344-001-bathosszimm\04_Data\Bathymetrie\VAKL23_LIDAR23_AHN4.mat');

% *** POLYGONS ***
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Boundary_polygoon\Buitendijks_polygoon_Bath_Ossenisse_Zimmerman.kml');
for ki = 1:length(KML)
    [POL_x{ki},POL_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

% *** BATHYMETRY ***
load('p:\11210344-001-bathosszimm\04_Data\Bathymetrie\VAKL23_LIDAR23_AHN4.mat');

% *** KMLs ***
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\7_1_2026\Aangepast.kml');
for ki = 1:length(KML)
    [Aangepast_x{ki},Aangepast_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\7_1_2026\Nieuw.kml');
for ki = 1:length(KML)
    [Nieuw_x{ki},Nieuw_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\7_1_2026\HVP.kml');
for ki = 1:length(KML)
    [HVP_x{ki},HVP_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end
KML = KML2Coordinates('p:\11210344-001-bathosszimm\04_Data\Ingrepen\7_1_2026\Bestaand.kml');
for ki = 1:length(KML)
    [Bestaand_x{ki},Bestaand_y{ki}] = convertCoordinates(KML{ki}(:,1),KML{ki}(:,2),'CS2.code',28992,'CS1.code',4326);
end

%% Split data to individual tides

NAMES.PVO = 'Ossenisse'; %plaat van Ossenisse
NAMES.BATH = 'Bath';
NAMES.ZIM = 'Zimmerman';

LD_grens = 0.6;

LOCS = fieldnames(ADCP);
TIDES = [];

for Li = 1:length(LOCS)
    fig = figure;
    Ts = fieldnames(ADCP.(LOCS{Li}));

    for Ti = 1:length(Ts)
        A = ADCP.(LOCS{Li}).(Ts{Ti});
        I = fieldnames(A);
        for i = 1:length(I)
            if ~strcmp((I{i}),'Boat')

                TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}) = [];

                % Detect HW and LW
                [a HW_i] = findpeaks(A.(I{i}).WL_from_external_source,'MinPeakDistance',10/(24*60*uniquetol(diff(A.(I{i}).datenum),datenum(0,0,0,0,0,1))/60));
                [a LW_i] = findpeaks(A.(I{i}).WL_from_external_source.*-1,'MinPeakDistance',10/(24*60*uniquetol(diff(A.(I{i}).datenum),datenum(0,0,0,0,0,1))/60));
                % Now determine which tides actually to include (ignore incomplete tides)
                for k = 1:length(HW_i)
                    % Find nearby LW peaks
                    d=sort(abs(LW_i-HW_i(k)));
                    if (d(1) == d(2))
                        vals = find(abs(LW_i-HW_i(k))==d(1));
                        LW_is(1) = LW_i(vals(1));
                        LW_is(2) = LW_i(vals(2));
                    else
                        LW_is(1) = LW_i(find(abs(LW_i-HW_i(k))==d(1)));
                        LW_is(2) = max(LW_i(find(abs(LW_i-HW_i(k))==d(2)))); %soms komen hier meerdere indices uit - dan max
                    end
                    LW_is = sort(LW_is);
                    if LW_is(1) < HW_i(k) & LW_is(2) > HW_i(k) & diff(LW_is)<16/(24*60*uniquetol(diff(A.(I{i}).datenum),datenum(0,0,0,0,0,1))/60)
                        % This is a full tide that makes sense
                        ind = length(TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}))+1;
                        TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}){ind}.HW_i = HW_i(k);
                        TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}){ind}.LW_i = LW_is;
                        TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}){ind}.HW = A.(I{i}).WL_from_external_source(HW_i(k));
                        TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}){ind}.LW = A.(I{i}).WL_from_external_source(LW_is);
                        TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}){ind}.Uda_max = max(A.(I{i}).Umag_da(LW_is(1):LW_is(2)));
                    end
                end

                plot(A.(I{i}).t_CET,A.(I{i}).WL_from_external_source)
                hold on
                plot(A.(I{i}).t_CET(cellfun(@(x)x.HW_i,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}))),cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})),'or')


            end
        end
    end
end


%% GET HW PEAK FREQUENCY AT ALL STATIONS
load('p:\11210344-001-bathosszimm\04_Data\Waterstanden\Structures\WL.mat');

HW_STATION.OSSENISSE  = 'HANS';
HW_STATION.BATH = 'BATH';
HW_STATION.ZIMMERMAN = 'WALS';

year_to_analyze = 2018;

figure;
for Li = 1:length(LOCS)    
    WL_ti = find(year(datetime(WL.Time.(HW_STATION.(LOCS{Li})),'ConvertFrom','datenum'))  ==  year_to_analyze);
    WL_t = WL.Time.(HW_STATION.(LOCS{Li}))(WL_ti);
    WL_z = WL.Values.(HW_STATION.(LOCS{Li}))(WL_ti)/100; %cm to m
    if sum(isnan(WL_z))/length(WL_z) > 0.1
        error('More than 10 pct nans');
    end   
    PEAKS_z = findpeaks(WL_z,WL_t,'MinPeakDistance',0.45);
    HW_FREQ.(LOCS{Li}).z = -5:0.01:5;
    for zi = 1:length(HW_FREQ.(LOCS{Li}).z)
        HW_FREQ.(LOCS{Li}).f(zi) = length(find(PEAKS_z<HW_FREQ.(LOCS{Li}).z(zi)))/length(PEAKS_z);
    end
    hold on; plot(HW_FREQ.(LOCS{Li}).z,HW_FREQ.(LOCS{Li}).f)
end

% % Plot the results (BATH)
% %note that sometimes a location does have T0 or T1 data, but it does not show. This is because there is no complete tide
% 
% colors = {'k','r'};
% colors_lines = {[1 1 1].*0.7,'b'};
% shapes = {'o','s'};
% 
% HW_FOR_UCHANGE = [2 3];
% XL = [0 4];
% YL = [0 2];
% 
% for Li = 1
%     close all
%     Ts = fieldnames(ADCP.(LOCS{Li}));  
% 
%     fig = figure;
%     set(0,'DefaultAxesFontSize',9);
%     fig.Units = 'centimeters';
%     fig.Position = [2 2 16 13];
% 
%     % Get all instruments in all campaigns (important to ensure the right ones are plotted on top of eachother)
%     I_all = [];
%     for Ti = 1:length(Ts)    
%         A = ADCP.(LOCS{Li}).(Ts{Ti});
%         I = fieldnames(A);
%         I_all = [I_all; I];
%     end
%     I_all = unique(I_all);
%     I_all = strrep(sort(strrep(I_all,'MP00','MP0Z')),'MP0Z','MP00');
%     if ~isempty(find(strcmp(I_all,'Boat')))
%         I_all(find(strcmp(I_all,'Boat'))) = [];
%     end
% 
%     % Check for a given plot, whether T0 and T1 are plotted for the same location on top of eachother
%     CHECK_INST = [];
%     HW_range = [];
% 
%     % Keep the value of the linear fits
%     FITS = [];
%     CRITICAL_HW = []; % Critical HW level for which the LD velocity is exceeded
% 
%     for Ti = 1:length(Ts)       
%         A = ADCP.(LOCS{Li}).(Ts{Ti});
%         I = fieldnames(A);
% 
%         I(find(strcmp(I,'Boat'))) = [];
% 
%         for i = 1:length(I)
%             thisADCP = I{i};
%             if contains(thisADCP,'MP')
%                 thisADCP = thisADCP(3:end);
%             end
% 
%             if strcmp(I{i},'Boat')
% 
%             else
% 
%             columns = 5;
%             rows = ceil(length(I_all)/columns);
% 
%             if Ti == 1
%                 indx = i;
%             elseif Ti == 2
%                 indx = find(strcmp(CHECK_INST(:,1),thisADCP)); 
%             end
% 
%             subaxis(rows,columns,indx,'MT',0.01,'ML',0.07,'MR',0.02,'MB',0.05,'PB',0.03,'sv',-0.01,'sh',0.02);
% 
%             %check indices of plot vs data (if T0 and T1 in right window)
%             if Ti == 1
%                 CHECK_INST{i,1} = thisADCP;
%                 CHECK_INST{i,2} = indx;
%             elseif Ti == 2
%                 CHECK_INST{i,3} = thisADCP;
%                 CHECK_INST{i,4} = indx;
%             end
% 
%             hold on
%             plotpoints{Ti} = plot(cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})),cellfun(@(x)x.Uda_max,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})),shapes{Ti},'Color','none','MarkerFaceColor',colors{Ti},'MarkerSize',3);
%             af = cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}));
%             bf = cellfun(@(x)x.Uda_max,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}));
%             af = af(find(~isnan(bf)));
%             bf = bf(find(~isnan(bf)));
%             if isempty(af) && isempty(bf)
%                 FITS{Ti}.(I{i}) = [NaN NaN];
%             else
%                 FITS{Ti}.(I{i}) = polyfit(af,bf,1);
%             end
% 
% 
%             % Bepaal fractie van getijdes onder de critische LD_grens
%             this_z = HW_FREQ.(LOCS{Li}).z; this_z = [this_z 100]; 
%             this_f = HW_FREQ.(LOCS{Li}).f; this_f = [this_f 1]; %maak z en f langer, zodat interpolatie altijd goed gaat
%             HW_for_LDgrens = (LD_grens-FITS{Ti}.(I{i})(2))./FITS{Ti}.(I{i})(1); %gevalletje y = ax+b (vandaar (y-b)/a = x)
%             FRAC_TIDES_UNDER_CRITICAL_HW{Ti}.(LOCS{Li}).(I{i}) = interp1(this_z, this_f,HW_for_LDgrens); 
%             %FRAC_TIDES_UNDER_CRITICAL_HW{Ti}.(LOCS{Li}).(I{i}) = interp1(HW_FREQ.(LOCS{Li}).z,HW_FREQ.(LOCS{Li}).f,(LD_grens-FITS{Ti}.(I{i})(2))./FITS{Ti}.(I{i})(1)); %gevalletje y = ax+b (vandaar y-b/a = x)
%             crcf = corrcoef(af,bf);
%             R2{Ti}(i) = crcf(1,2).^2;
%             BEDL{Ti}.(I{i}) = ADCP.(LOCS{Li}).(Ts{Ti}).(I{i}).META.ZBED;
% 
%             if length(BEDL{Ti}.(I{i}))>1
%                 error('Hoe kan dit?')
%             end
%             HW_range{Ti}.(I{i}) = [min(cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}))) max(cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})))];
% 
%             plot(XL,LD_grens.*[1 1],'--k', 'DisplayName','0.6 m/s'); %grens voor laag-hoog dynamisch in de Westerschelde
%             hGrens = plot(XL,LD_grens.*[1 1],'--k', 'DisplayName','0.6 m/s');
%             AS = gca;
%             AS.XTick = 0:4;
% 
%             axis tight
%             if AS.XLim(1)<XL(1) || AS.XLim(2)>XL(2)
%                 warning('XL is too tight');
%             elseif AS.YLim(1)<YL(1) || AS.YLim(2)>YL(2)
%                 warning('YL is too tight');
%             end
%             xlim(XL);
%             ylim(YL);
% 
%             text( ...
%                 XL(2) - 0.00*diff(XL), ...
%                 YL(2) - 0.00*diff(YL), ...
%                 num2str(thisADCP), ...
%                 'HorizontalAlignment','right', ...
%                 'VerticalAlignment','top', ...
%                 'Color','w', ...
%                 'FontSize',9, ...
%                 'BackgroundColor','k', ...
%                 'Margin',0.1)
%                if Ti == 2 && isfield(FITS{1},I{i}) && isfield(FITS{2},I{i})
% 
%                    for Ti = 1:2
%                        if sum(FITS{Ti}.(I{i}))==0 || (sum(~isnan(cellfun(@(x)x.Uda_max,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})))) <= 5)
%                            %then the tides was incomplete and all
%                            %points have been set to NaN
%                        else
%                            fitlines{Ti} = plot(HW_range{Ti}.(I{i}),HW_range{Ti}.(I{i}).*FITS{Ti}.(I{i})(1)+FITS{Ti}.(I{i})(2),'Color',colors_lines{Ti},'LineWidth',1.5);
%                        end
%                    end
% 
%                    if  sum(~isnan(cellfun(@(x)x.Uda_max,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})))) <= 5 && sum(~isnan(FITS{Ti}.(I{i}))) ~= 0
%                        text(0.15,1.8,'too few tides','Fontsize',6,'Color',[1 1 1].*0.3);
%                        DELTA_U{2}.(LOCS{Li}).(I{i}) = NaN;
%                        DELTA_FRAC.(LOCS{Li}).(I{i}) = NaN;
%                        FRAC_TIDES_UNDER_CRITICAL_HW{Ti}.(LOCS{Li}).(I{i}) = NaN;
%                    else
% 
%                        if sum(FITS{Ti}.(I{i}))==0 || isnan(FITS{1}.(I{i})(1)) || isnan(FITS{2}.(I{i})(1))
%                        else
%                            text(0.15,1.72,{...
%                                sprintf('\\DeltaU_%g_m = %+.0f cm/s',HW_FOR_UCHANGE(1),...
%                                100*((HW_FOR_UCHANGE(1)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2))-(HW_FOR_UCHANGE(1)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2)))...
%                                ),...
%                                sprintf('\\DeltaU_%g_m = %+.0f cm/s',HW_FOR_UCHANGE(2),...
%                                100*((HW_FOR_UCHANGE(2)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2))-(HW_FOR_UCHANGE(2)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2)))...
%                                )...
%                                },'Fontsize',6,'Color',[1 1 1].*0.3)
%                        end
%                        DELTA_U{2}.(LOCS{Li}).(I{i}) = 100*((HW_FOR_UCHANGE(2)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2))-(HW_FOR_UCHANGE(2)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2)));
% 
%                        DELTA_FRAC.(LOCS{Li}).(I{i}) = FRAC_TIDES_UNDER_CRITICAL_HW{2}.(LOCS{Li}).(I{i})-FRAC_TIDES_UNDER_CRITICAL_HW{1}.(LOCS{Li}).(I{i});
%                    end
% 
%                end
% 
%             end
% 
% 
%             %labels:
%             nPlots = numel(I_all);            % aantal echte plots
% 
%             % Laatste rij info
%             lastRowUsed = ceil(nPlots / columns);
%             nLastRow = mod(nPlots, columns);
%             if nLastRow == 0
%                 nLastRow = columns;           % laatste rij vol
%             end
% 
%             % --- bepaal row/col (row-major, zoals subaxis)
%             rowIdx = ceil(indx / columns);
%             colIdx = mod(indx-1, columns) + 1;
% 
%             % --- Y-label links
%             if colIdx == 1
%                 ylabel('U_m_a_x [m/s]')
%             else
%                 set(gca,'YTickLabel',[])
%             end
% 
%             % --- X-label onderste rij + vrijstaande kolommen boven
%             showXlabel = (rowIdx == lastRowUsed) || ...
%                 (rowIdx == lastRowUsed-1 && colIdx > nLastRow);
% 
%             if showXlabel
%                 xlabel('HW [m+NAP]')
%             else
%                 set(gca,'XTickLabel',[])
%             end
% 
% 
% 
% 
%             grid on
%         end
%             if Ti == 2
%               % For these settings, both trend lines are plotted at both locations (so we have a full legend)
%               LEG = legend([plotpoints{1} plotpoints{2} fitlines{1} fitlines{2}, hGrens],'T0 tide','T1 tide','Fit T0 tides','Fit T1 tides', '0.6 m/s','AutoUpdate','off');
% 
%             end
% 
% 
%     end
%     %Move legend
%     LEG.Position = [0.7094    0.1239    0.1805    0.1090];
%     fig.PaperPositionMode = 'auto';
% 
%     print(fig,[dirs.figures LOCS{Li} '\' 'Umax_vs_HW.png'],'-dpng','-r600');
% 
%     DELTA_U{2}.(LOCS{Li}) = orderfields(DELTA_U{2}.(LOCS{Li}));
% 
% end
% 
% avg_R2.BATH = nanmean([R2{1,1} R2{1,2}]);

% %% Get some values for BATH
% fn_tmp = fieldnames(FITS{1,1});
% 
% for i = 1:length(fn_tmp)
% DELTAU3(i,1) = 100*((HW_FOR_UCHANGE(2)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2))-(HW_FOR_UCHANGE(2)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2)))
% DELTAU2(i,1) = 100*((HW_FOR_UCHANGE(1)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2))-(HW_FOR_UCHANGE(1)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2)))
% end
% 
% %get the range of the changes:
% min_range = min([abs(DELTAU2); abs(DELTAU3)])
% max_range = max([abs(DELTAU2); abs(DELTAU3)])
% fprintf(['De absolute verschillen tussen T0 en T1 zijn relatief klein ' ...
%          '(%.2f - %.2f cm/s) voor de droogvallende meetpunten van Bath.\n'], ...
%          min_range, max_range);
% 
% %get the average decrease in the xx02 points:
% MP = fieldnames(ADCP.BATH.T0); MP(1)=[];
% pattern = 'MP..02';
% indices = find(~cellfun('isempty', regexp(MP, pattern)));
% indices(indices==find(strcmp(MP,'MP0102'),1)) = []; %exclude MP0102
% avg_xx02 = nanmean([DELTAU2(indices); DELTAU3(indices)]);
% 
% %get the average decrease in the xx01 points:
% MP = fieldnames(ADCP.BATH.T0); MP(1)=[];
% pattern = 'MP01..';
% indices = find(~cellfun('isempty', regexp(MP, pattern)));
% avg_01xx = nanmean([DELTAU2(indices); DELTAU3(indices)]);
% 
% % gemiddelde van de puntenwolken T1
% fn = fieldnames(TIDES.BATH.T1);
% for FNi = 1:length(fn)
% xs=cellfun(@(x)x.HW,TIDES.BATH.T1.(fn{FNi}));
% ys=cellfun(@(x)x.Uda_max,TIDES.BATH.T1.(fn{FNi}));
% plot(xs,ys,'.'); hold on
% gemUmaxT1(FNi,1) = nanmean(ys);
% end
% 
% % gemiddelde van de puntenwolken T0
% fn = fieldnames(TIDES.BATH.T0);
% for FNi = 1:length(fn)
% xs=cellfun(@(x)x.HW,TIDES.BATH.T0.(fn{FNi}));
% ys=cellfun(@(x)x.Uda_max,TIDES.BATH.T0.(fn{FNi}));
% plot(xs,ys,'.'); hold on
% gemUmaxT0(FNi,1) = nanmean(ys);
% end
% 
% %procentueel verschil voor discussie:
% perc = ((gemUmaxT1-gemUmaxT0)/(gemUmaxT0)).*100;
% avg_perc = nanmean(perc(:,1));

% %% Plot the results (OSSENISSE)
% Li = 2;
% 
% I_T0 = fieldnames(ADCP.(LOCS{Li}).T0a);
% I_T1 = fieldnames(ADCP.(LOCS{Li}).T1);
% 
% % Boat eruit
% I_T0(strcmp(I_T0,'Boat')) = [];
% I_T1(strcmp(I_T1,'Boat')) = [];
% 
% % Gemeenschappelijke meetpunten
% I_both = intersect(I_T0, I_T1);
% 
% colors = {'k','r'};
% colors_lines = {[1 1 1].*0.7,'b'};
% shapes = {'o','s'};
% 
% HW_FOR_UCHANGE = [2 3];
% XL = [0 4];
% YL = [0 4];
% 
% count = 0;
% for Li = 2
%     close all
% 
%     Ts = {'T0a','T1'};
% 
%     fig = figure;
%     set(0,'DefaultAxesFontSize',9);
%     fig.Units = 'centimeters';
%     fig.Position = [2 2 16 16];
% 
%     % Get all instruments in all campaigns (important to ensure the right ones are plotted on top of eachother)
%     I_all = [];
%     for Ti = 1:length(Ts)    
%         A = ADCP.(LOCS{Li}).(Ts{Ti});
%         I = fieldnames(A);
%         I_all = [I_all; I];
%     end
%     I_all = unique(I_all);
%     I_all = strrep(sort(strrep(I_all,'MP00','MP0Z')),'MP0Z','MP00');
%     if ~isempty(find(strcmp(I_all,'Boat')))
%         I_all(find(strcmp(I_all,'Boat'))) = [];
%     end
%     I_all = sort(I_all);
% 
%     % Check for a given plot, whether T0 and T1 are plotted for the same location on top of eachother
%     CHECK_INST = [];
%     HW_range = [];
% 
%     % Keep the value of the linear fits
%     FITS = [];
%     CRITICAL_HW = []; % Critical HW level for which the LD velocity is exceeded
% 
%     for Ti = 1:length(Ts)       
%         A = ADCP.(LOCS{Li}).(Ts{Ti});
%         I = fieldnames(A);
% 
%         I(find(strcmp(I,'Boat'))) = [];
% 
%         for i = 1:length(I)
%             thisADCP = I{i};
%             if contains(thisADCP,'MP')
%                 thisADCP = thisADCP(3:end);
%             end
% 
%             if strcmp(I{i},'Boat')
% 
%             else
% 
%             columns = 5;
%             rows = ceil(length(I_all)/columns);
% 
%             if Ti == 1
%                 indx = i;
%             elseif Ti == 2
%                 indx = find(strcmp(CHECK_INST(:,1),thisADCP)); 
%             end
% 
%             subaxis(rows,columns,indx,'MT',0.01,'ML',0.07,'MR',0.02,'MB',0.05,'PB',0.03,'sv',-0.01,'sh',0.02);
% 
%             %check indices of plot vs data (if T0 and T1 in right window)
%             if Ti == 1
%                 CHECK_INST{i,1} = thisADCP;
%                 CHECK_INST{i,2} = indx;
%             elseif Ti == 2
%                 CHECK_INST{i,3} = thisADCP;
%                 CHECK_INST{i,4} = indx;
%             end
% 
%             hold on
%             plotpoints{Ti} = plot(cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})),cellfun(@(x)x.Uda_max,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})),shapes{Ti},'Color','none','MarkerFaceColor',colors{Ti},'MarkerSize',3);
%             af = cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}));
%             bf = cellfun(@(x)x.Uda_max,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}));
%             af = af(find(~isnan(bf)));
%             bf = bf(find(~isnan(bf)));
%             FITS{Ti}.(I{i}) = polyfit(af,bf,1);
%             if isnan(FITS{Ti}.(I{i})(1))
%                 error('Hoe kan dit?');
%             end          
% 
%             % Bepaal fractie van getijdes onder de critische LD_grens
%             this_z = HW_FREQ.(LOCS{Li}).z; this_z = [this_z 100]; 
%             this_f = HW_FREQ.(LOCS{Li}).f; this_f = [this_f 1]; %maak z en f langer, zodat interpolatie altijd goed gaat
%             HW_for_LDgrens = (LD_grens-FITS{Ti}.(I{i})(2))./FITS{Ti}.(I{i})(1); %gevalletje y = ax+b (vandaar (y-b)/a = x)
%             FRAC_TIDES_UNDER_CRITICAL_HW{Ti}.(LOCS{Li}).(I{i}) = interp1(this_z, this_f,HW_for_LDgrens); 
%             %FRAC_TIDES_UNDER_CRITICAL_HW{Ti}.(LOCS{Li}).(I{i}) = interp1(HW_FREQ.(LOCS{Li}).z,HW_FREQ.(LOCS{Li}).f,(LD_grens-FITS{Ti}.(I{i})(2))./FITS{Ti}.(I{i})(1)); %gevalletje y = ax+b (vandaar y-b/a = x)
% 
%             crcf = corrcoef(af,bf);
%             R2{Ti}(i) = crcf(1,2).^2;
%             BEDL{Ti}.(I{i}) = ADCP.(LOCS{Li}).(Ts{Ti}).(I{i}).META.ZBED;
% 
%             if length(BEDL{Ti}.(I{i}))>1
%                 error('Hoe kan dit?')
%             end
%             HW_range{Ti}.(I{i}) = [min(cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i}))) max(cellfun(@(x)x.HW,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})))];
% 
%             plot(XL,LD_grens.*[1 1],'--k', 'DisplayName','0.6 m/s'); %grens voor laag-hoog dynamisch in de Westerschelde
%             hGrens = plot(XL,LD_grens.*[1 1],'--k', 'DisplayName','0.6 m/s');
%             AS = gca;
%             if ismember(count,[1:columns:(rows*columns)])
%                 ylabel('U_m_a_x [m/s]')
% 
%             end
%             if ismember(count,[(rows*columns)-columns+1 : (rows*columns)])
%                 xlabel('HW [m+NAP]');
% 
%             end
%             AS.XTick = 0:4;
% 
%             axis tight
%             if AS.XLim(1)<XL(1) || AS.XLim(2)>XL(2)
%                 warning('XL is too tight');
%             elseif AS.YLim(1)<YL(1) || AS.YLim(2)>YL(2)
%                 warning('YL is too tight');
%             end
%             xlim(XL);
%             ylim(YL);
% 
%             text( ...
%                 XL(2) - 0.00*diff(XL), ...
%                 YL(2) - 0.00*diff(YL), ...
%                 num2str(thisADCP), ...
%                 'HorizontalAlignment','right', ...
%                 'VerticalAlignment','top', ...
%                 'Color','w', ...
%                 'FontSize',9, ...
%                 'BackgroundColor','k', ...
%                 'Margin',0.1)
% 
% 
% 
%             if Ti <= length(FITS)
%                 if isfield(FITS{Ti},I{i})
% 
%                     if isnan(FITS{Ti}.(I{i})(1)) || sum(FITS{Ti}.(I{i})) ==0
%                             DELTA_U{2}.(LOCS{Li}).(I{i}) = NaN;
%                     else
% 
%                         if sum(FITS{Ti}.(I{i}))==0
%                             %then the tides was incomplete and all
%                             %points have been set to NaN
%                         else
%                             fitlines{Ti} = plot(HW_range{Ti}.(I{i}),HW_range{Ti}.(I{i}).*FITS{Ti}.(I{i})(1)+FITS{Ti}.(I{i})(2),'Color',colors_lines{Ti},'LineWidth',1.5);
%                         end
% 
%                     end
%                 end
%             end
% 
%             if Ti == 2 && ismember(I{i},I_both)
% 
%                         if  sum(~isnan(cellfun(@(x)x.Uda_max,TIDES.(LOCS{Li}).(Ts{Ti}).(I{i})))) <= 5 && sum(~isnan(FITS{Ti}.(I{i}))) ~= 0
%                             text(0.15,1.8,'too few tides','Fontsize',6,'Color',[1 1 1].*0.3);
%                             DELTA_U{2}.(LOCS{Li}).(I{i}) = NaN;
%                             DELTA_FRAC.(LOCS{Li}).(I{i}) = NaN;
%                             FRAC_TIDES_UNDER_CRITICAL_HW{Ti}.(LOCS{Li}).(I{i}) = NaN;
%                         else
% 
%                             if sum(FITS{Ti}.(I{i}))==0 || isnan(FITS{1}.(I{i})(1)) || isnan(FITS{2}.(I{i})(1))
%                             else
%                                 text(0.02,0.98,{ ...
%                                     sprintf('\\DeltaU_%g_m = %+.0f cm/s', HW_FOR_UCHANGE(1), ...
%                                     100*((HW_FOR_UCHANGE(1)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2)) - ...
%                                     (HW_FOR_UCHANGE(1)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2))) ...
%                                     ), ...
%                                     sprintf('\\DeltaU_%g_m = %+.0f cm/s', HW_FOR_UCHANGE(2), ...
%                                     100*((HW_FOR_UCHANGE(2)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2)) - ...
%                                     (HW_FOR_UCHANGE(2)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2))) ...
%                                     ) ...
%                                     }, ...
%                                     'Units','normalized', ...
%                                     'HorizontalAlignment','left', ...
%                                     'VerticalAlignment','top', ...
%                                     'FontSize',6, ...
%                                     'Color',[1 1 1]*0.3);
%                             end
%                             DELTA_U{2}.(LOCS{Li}).(I{i}) = 100*((HW_FOR_UCHANGE(2)*FITS{2}.(I{i})(1)+FITS{2}.(I{i})(2))-(HW_FOR_UCHANGE(2)*FITS{1}.(I{i})(1)+FITS{1}.(I{i})(2)));
% 
%                             DELTA_FRAC.(LOCS{Li}).(I{i}) = FRAC_TIDES_UNDER_CRITICAL_HW{2}.(LOCS{Li}).(I{i})-FRAC_TIDES_UNDER_CRITICAL_HW{1}.(LOCS{Li}).(I{i});
%                         end
% 
% 
% 
%             end
% 
% 
%             %labels:
%             nPlots = numel(I_all);            % aantal echte plots
% 
%             % Laatste rij info
%             lastRowUsed = ceil(nPlots / columns);
%             nLastRow = mod(nPlots, columns);
%             if nLastRow == 0
%                 nLastRow = columns;           % laatste rij vol
%             end
% 
%             % --- bepaal row/col (row-major, zoals subaxis)
%             rowIdx = ceil(indx / columns);
%             colIdx = mod(indx-1, columns) + 1;
% 
%             % --- Y-label links
%             if colIdx == 1
%                 ylabel('U_m_a_x [m/s]')
%             else
%                 set(gca,'YTickLabel',[])
%             end
% 
%             % --- X-label onderste rij + vrijstaande kolommen boven
%             showXlabel = (rowIdx == lastRowUsed) || ...
%                 (rowIdx == lastRowUsed-1 && colIdx > nLastRow);
% 
%             if showXlabel
%                 xlabel('HW [m+NAP]')
%             else
%                 set(gca,'XTickLabel',[])
%             end
% 
%             end
%             grid on
%         end
%         if Ti == 2
%             % For these settings, both trend lines are plotted at both locations (so we have a full legend)
%             LEG = legend([plotpoints{1} plotpoints{2} fitlines{1} fitlines{2}, hGrens],'T0 tide','T1 tide','Fit T0 tides','Fit T1 tides', '0.6 m/s','AutoUpdate','off');
%         end
% 
%     end
% 
% 
% 
%     %Move legend
%     LEG.Position = [    0.5190    0.0995    0.1805    0.1090];
%     fig.PaperPositionMode = 'auto';
% 
%     print(fig,[dirs.figures LOCS{Li} '\' 'Umax_vs_HW.png'],'-dpng','-r600');
% 
%     %    DELTA_U{2}.(LOCS{Li}) = orderfields(DELTA_U{2}.(LOCS{Li}));
% 
% end
% avg_R2.OSSENISSE = nanmean([R2{1,1} R2{1,2}]);


% %% % %%%% SPATIAL OVERVIEW OF CHANGES (BATH)
% % close all
% % 
% % NAMES.BATH = 'Bath';
% % NAMES.PVO  = 'Ossenisse';
% % 
% % XLIM.BATH = [69 74];
% % YLIM.BATH = [378 381];
% % XLIM.PVO  = [55 62];
% % YLIM.PVO  = [379 384];
% % 
% % fig = figure;
% % fig.Units = 'centimeters';
% % fig.Position = [1 1 15 10];
% % set(0,'DefaultAxesFontSize',9);
% % LOCS = fieldnames(ADCP);
% % 
% % for Li = 1
% %     hold on
% %     ele = bathymetry.z;    
% %     CAX = [-3 3];
% %     ele(find(ele<CAX(1))) = CAX(1);
% %     P = pcolor(bathymetry.x/1000,bathymetry.y/1000,ele); hold on
% %     P.LineStyle = 'none';
% %     caxis(CAX)
% %     colormap(fliplr(gray')')
% %     shading interp;
% % 
% %     LEG_GROYNES = [];
% %     for ki = 1:length(Aangepast_x)
% %         LEG_GROYNES(3) = plot(Aangepast_x{ki}./1000,Aangepast_y{ki}./1000,':k','LineWidth',2);
% %     end
% %     for ki = 1:length(HVP_x)
% %         LEG_GROYNES(4) = plot(HVP_x{ki}./1000,HVP_y{ki}./1000,'k','LineWidth',4);
% %     end
% %     for ki = 1:length(Nieuw_x)
% %         LEG_GROYNES(2) = plot(Nieuw_x{ki}./1000,Nieuw_y{ki}./1000,'-k','LineWidth',2);
% %     end
% %     for ki = 1:length(Bestaand_x)
% %         LEG_GROYNES(1) = plot(Bestaand_x{ki}./1000,Bestaand_y{ki}./1000,'Color',[1 1 1].*0.4,'LineWidth',1);
% %     end
% % 
% %     for ki = 1:length(POL_x)
% %         fill(POL_x{ki}./1000,POL_y{ki}./1000,[1 1 1].*0.85)
% %     end
% % 
% %     Ts = fieldnames(ADCP.(LOCS{Li}));
% % 
% %     colors = {'k','r'};
% %     shapes = {'o','s'};
% %     locations = {'Bottom','Top'};
% % 
% %     % Check the extent of the colourscale that we need to use
% %     CS = [10^9 -10^9];
% %     fn1 = fieldnames(DELTA_U{2});
% %     for fn1i = 1:length(fn1)
% %         fn2 = fieldnames(DELTA_U{2}.(fn1{fn1i}));
% %         for fn2i = 1:length(fn2)
% %             CS(1) = min([CS(1) DELTA_U{2}.(fn1{fn1i}).(fn2{fn2i})]);
% %             CS(2) = max([CS(2) DELTA_U{2}.(fn1{fn1i}).(fn2{fn2i})]);
% %         end
% %     end
% %     CS = [floor(CS(1)/10)*10 ceil(CS(2)/10)*10];
% %     CS_binedges = CS(1):10:CS(2);
% % 
% %     CS_abs_max = max(abs(CS_binedges));
% %     CS_stepsz = unique(diff(CS_binedges));
% %     CS_range = [-1*CS_abs_max:CS_stepsz:CS_abs_max];
% %     CM_to_pick_from = fliplr(cbrewer('div','RdYlBu',length(CS_range))')';
% %     cm_markers = CM_to_pick_from;
% %     %change values to max 1
% %     idx=find(cm_markers(:,1)>1);
% %     for i = 1:length(idx)
% %         cm_markers(idx(i),:) = [1 1 1];
% %     end
% % 
% %     %remove excess-colors:
% %     c1 = 0; c2 = 0;
% %     index = find(~ismember(CS_range,CS_binedges));
% %     for i = 1:length(index)
% %         if ~mod(i,2)
% %             cm_markers(end-c1,:) = [];
% %             c1 = c1+1;
% %         else
% %             cm_markers(1+c2,:) = [];
% %             c2 = c2+1;
% %         end
% %     end
% %     % Set the color for 0 value to white
% %     [~, zeroIndex] = min(abs(CS_binedges));
% %     % Set the color at this index to white
% %     cm_markers(zeroIndex,:) = [1 1 1];
% %     cm_markers(end,:) = []; %remove one color so ticks and cb blocks match
% % 
% %     % lines and markers
% %     for Ti = length(Ts)       
% %         A = ADCP.(LOCS{Li}).(Ts{Ti});
% %         I = fieldnames(A);
% %         for i = 1:length(I)
% %             if ~strcmp((I{i}),'Boat') && isfield(DELTA_U{2}.(LOCS{Li}),I{i}) && ~isnan(DELTA_U{2}.(LOCS{Li}).(I{i}))
% %                 plot(A.(I{i}).META.RDX./1000,A.(I{i}).META.RDY./1000,shapes{1},'Color',colors{1},'MarkerFaceColor',cm_markers(max(find(DELTA_U{2}.(LOCS{Li}).(I{i})>CS_binedges)),:),'MarkerSize',8);                
% %             end
% %         end
% %     end
% % 
% %     %Plot markers for legend
% %     for Mi = 1:length(CS_binedges)-1
% %         h(Mi) = plot(NaN,NaN,shapes{Ti},'Color',colors{Ti},'MarkerFaceColor',cm_markers(Mi,:));
% %         COLMARKLEG{Mi} = [num2str(CS_binedges(Mi)) 'cm/s to ' num2str(CS_binedges(Mi+1)) 'cm/s'];
% %     end
% % 
% %     axis equal
% %     grid on
% %     box on
% %     xlabel('RDx [km]');
% %     ylabel('RDy [km]')
% % 
% % 
% %     LEG_G = legend([LEG_GROYNES],{'existing groyne','new groyne','channel wall','high water flats'},'Location','southeast');
% %     cb_bathy = colorbar('Location','SouthOutside');
% %     cb_bathy.Position = [0.735 0.41   0.15    0.02];
% %     tcb = title(cb_bathy,'z_b [m+NAP]');
% %     cb_bathy.TickDirection = 'out';
% % 
% %     title(NAMES.(LOCS{Li}))
% %     xlim([XLIM.(LOCS{Li})])
% %     ylim([YLIM.(LOCS{Li})])
% % 
% %     AS = gca;
% %     AS.XTick = [0:1:1000];
% %     AS.YTick = [0:1:1000];
% % 
% % 
% %     set(gca,'Layer','Top');
% % end
% % 
% % 
% % % Add fake axis for colorbar
% % FAX = axes;
% % colormap(FAX,cm_markers);
% % caxis([CS_binedges(1) CS_binedges(end)]);
% % cb = colorbar;
% % cb.Position = [0.18   0.48    0.010    0.30466];
% % cb.Ticks = CS_binedges;
% % cb.TickDirection = 'out';
% % cb.Limits = CS_binedges([1 end]);
% % cb.AxisLocation = 'in';
% % title(cb,{'\DeltaU [cm/s]','(HW = 3 m)'})
% % FAX.Position = [-1 -1 0.1 0.1];
% % 
% % %print(fig,[dirs.figures LOCS{Li} '\' 'HW_U_relation_T0_T1_3m_MAP.png'],'-dpng','-r600');
% 
% %% %%%% SPATIAL OVERVIEW OF CHANGES (OSSENISSE)
% %niet mogelijk, want geen DELTA_U voor Ossenisse!
% 
% % %% %%%% SPATIAL OVERVIEW OF % of tides critial velocity exceeded, change between T0 and T1 (BATH)
% % close all
% % 
% % NAMES.BATH = 'Bath';
% % NAMES.PVO  = 'Ossenisse';
% % 
% % XLIM.BATH = [69 74];
% % YLIM.BATH = [378 381];
% % XLIM.PVO  = [55 62];
% % YLIM.PVO  = [379 384];
% % 
% % if strcmp(LOCS{Li},'BATH')
% %     XL = [69 74];
% %     YL = [378 381];
% % else strcmp(LOCS{Li},'OSSENISSE')
% %     XL = [55 62];
% %     YL = [379 384];
% % end
% % 
% % 
% % fig = figure;
% % fig.Units = 'centimeters';
% % fig.Position = [1 1 15 10];
% % set(0,'DefaultAxesFontSize',9);
% % LOCS = fieldnames(ADCP);
% % 
% % for Li = 1
% %     hold on
% %     ele = bathymetry.z;    
% %     CAX = [-3 3];
% %     ele(find(ele<CAX(1))) = CAX(1);
% %     P = pcolor(bathymetry.x/1000,bathymetry.y/1000,ele); hold on
% %     P.LineStyle = 'none';
% %     caxis(CAX)
% %     colormap(fliplr(gray')')
% %     shading interp;
% % 
% %     LEG_GROYNES = [];
% %     for ki = 1:length(Aangepast_x)
% %         LEG_GROYNES(3) = plot(Aangepast_x{ki}./1000,Aangepast_y{ki}./1000,':k','LineWidth',2);
% %     end
% %     for ki = 1:length(HVP_x)
% %         LEG_GROYNES(4) = plot(HVP_x{ki}./1000,HVP_y{ki}./1000,'k','LineWidth',4);
% %     end
% %     for ki = 1:length(Nieuw_x)
% %         LEG_GROYNES(2) = plot(Nieuw_x{ki}./1000,Nieuw_y{ki}./1000,'-k','LineWidth',2);
% %     end
% %     for ki = 1:length(Bestaand_x)
% %         LEG_GROYNES(1) = plot(Bestaand_x{ki}./1000,Bestaand_y{ki}./1000,'Color',[1 1 1].*0.4,'LineWidth',1);
% %     end
% % 
% %     for ki = 1:length(POL_x)
% %         fill(POL_x{ki}./1000,POL_y{ki}./1000,[1 1 1].*0.85)
% %     end
% % 
% %     Ts = fieldnames(ADCP.(LOCS{Li}));
% % 
% %     colors = {'k','r'};
% %     shapes = {'o','s'};
% %     locations = {'Bottom','Top'};
% % 
% %     % Check the extent of the colourscale that we need to use
% %     CS = [10^9 -10^9];
% % 
% %     fn1 = fieldnames(DELTA_FRAC);
% %     for fn1i = 1:length(fn1)
% %         fn2 = fieldnames(DELTA_FRAC.(fn1{fn1i}));
% %         for fn2i = 1:length(fn2)
% %             CS(1) = min([CS(1) 100*DELTA_FRAC.(fn1{fn1i}).(fn2{fn2i})]);
% %             CS(2) = max([CS(2) 100*DELTA_FRAC.(fn1{fn1i}).(fn2{fn2i})]);
% %         end
% %     end
% %     CS = [floor(CS(1)/20)*20 ceil(CS(2)/20)*20];
% %     CS_binedges = CS(1):20:CS(2);
% %     CS_abs_max = max(abs(CS_binedges));
% %     CS_stepsz = unique(diff(CS_binedges));
% %     CS_range = [-1*CS_abs_max:CS_stepsz:CS_abs_max];
% %     CM_to_pick_from = (cbrewer('div','RdYlBu',length(CS_range))')';
% %     cm_markers = CM_to_pick_from;
% %     %change values to max 1
% %     idx=find(cm_markers(:,1)>1);
% %     for i = 1:length(idx)
% %         cm_markers(idx(i),:) = [1 1 1];
% %     end
% % 
% %    %remove excess-colors:
% %     c1 = 0; c2 = 0;
% %     index = find(~ismember(CS_range,CS_binedges));
% %     for i = 1:length(index)
% %         if ~mod(i,2)
% %             cm_markers(end-c1,:) = [];
% %             c1 = c1+1;
% %         else
% %             cm_markers(1+c2,:) = [];
% %             c2 = c2+1;
% %         end
% %     end
% % 
% %     %n_positive = length(find(CS_binedges>0));
% %     %n_negative = length(find(CS_binedges<0));
% %     %cm_markers(1:n_negative,:) = CM_to_pick_from(1:2:n_negative*2,:);
% %     %cm_markers(n_negative+1:n_negative+n_positive,1:3) = CM_to_pick_from(end-(n_positive-1+1):end-1,1:3);
% % 
% %     % Set the color for 0 value to white
% %     [~, zeroIndex] = min(abs(CS_binedges));
% %     % Set the color at this index to white
% %     cm_markers(zeroIndex,:) = [1 1 1];
% %     cm_markers(end,:) = []; %remove one color so ticks and cb blocks match
% % 
% %     % lines and markers
% %     for Ti = 2      
% %         A = ADCP.(LOCS{Li}).(Ts{Ti});
% %         I = fieldnames(A);
% %         for i = 1:length(I)
% %             if ~strcmp((I{i}),'Boat') && isfield(DELTA_FRAC.(LOCS{Li}),I{i}) && ~isnan(DELTA_FRAC.(LOCS{Li}).(I{i}))
% %                 DF = DELTA_FRAC.(LOCS{Li}).(I{i})*100;
% %                 plot(A.(I{i}).META.RDX./1000,A.(I{i}).META.RDY./1000,shapes{1},'Color',colors{1},'MarkerFaceColor',cm_markers(max(find(DF>=CS_binedges)),:),'MarkerSize',8);
% %             end
% % 
% %         end
% %     end
% %     % Plot markers for legend
% %     for Mi = 1:length(cm_markers)
% %         h(Mi) = plot(NaN,NaN,shapes{Ti},'Color',colors{Ti},'MarkerFaceColor',cm_markers(Mi,:));
% %         COLMARKLEG{Mi} = [num2str(CS_binedges(Mi)) 'cm/s to ' num2str(CS_binedges(Mi+1)) 'cm/s'];
% %     end
% %     axis equal
% %     grid on
% %     box on
% %     xlabel('RDx [km]');
% %     ylabel('RDy [km]')
% % 
% %     LEG_G = legend([LEG_GROYNES],{'existing groyne','new groyne','channel wall','high water flats'}, 'location','southeast');
% %     cb_bathy = colorbar('Location','SouthOutside');
% %     cb_bathy.Position = [0.735 0.41    0.15    0.02];
% %     tcb = title(cb_bathy,'z_b [m+NAP]');
% %     cb_bathy.TickDirection = 'out'; 
% % 
% %     title(NAMES.(LOCS{Li}))
% %     xlim([XLIM.(LOCS{Li})])
% %     ylim([YLIM.(LOCS{Li})])    
% %     AS = gca;
% %     AS.XTick = [0:1:1000];
% %     AS.YTick = [0:1:1000];
% % 
% %     set(gca,'Layer','Top');
% % end
% % 
% % % Add fake axis for colorbar
% % FAX = axes;
% % colormap(FAX,cm_markers);
% % caxis([CS_binedges(1) CS_binedges(end)]);
% % cb = colorbar;
% % cb.Position = [0.19   0.48    0.010    0.30466];
% % cb.Ticks = CS_binedges;
% % cb.TickDirection = 'out';
% % cb.Limits = CS_binedges([1 end]);
% % cb.AxisLocation = 'in';
% % title(cb,{'\Delta HW [%]',['(onder ' num2str(LD_grens) ' m/s)']})
% % FAX.Position = [-1 -1 0.1 0.1];
% % %print(fig,[dirs.figures LOCS{Li} '\' 'HW_U_relation_T0_T1_MAP_pctTIDES.png'],'-dpng','-r600');
% 
% %% %%%% SPATIAL OVERVIEW OF % of tides critial velocity exceeded, change between T0 and T1 (OSSENISSE)
% % niet mogelijk want geen DELTA_FRAC
% 
% % %% %%%% SPATIAL OVERVIEW OF % of tides critial velocity exceeded, plot T0 and T1 (BATH)
% % close all
% % 
% % NAMES.BATH = 'Bath';
% % NAMES.PVO  = 'Ossenisse';
% % 
% % XLIM.BATH = [69 74];
% % YLIM.BATH = [378 381];
% % XLIM.PVO  = [55 62];
% % YLIM.PVO  = [379 384];
% % 
% % if strcmp(LOCS{Li},'BATH')
% %     XL = [69 74];
% %     YL = [378 381];
% % else strcmp(LOCS{Li},'OSSENISSE')
% %     XL = [55 62];
% %     YL = [379 384];
% % end
% % 
% % 
% % fig = figure;
% % fig.Units = 'centimeters';
% % fig.Position = [1 1 15 10];
% % set(0,'DefaultAxesFontSize',9);
% % LOCS = fieldnames(ADCP);
% % 
% % for Li = 1
% %     hold on
% %     ele = bathymetry.z;    
% %     CAX = [-3 3];
% %     ele(find(ele<CAX(1))) = CAX(1);
% %     P = pcolor(bathymetry.x/1000,bathymetry.y/1000,ele); hold on
% %     P.LineStyle = 'none';
% %     caxis(CAX)
% %     colormap(fliplr(gray')')
% %     shading interp;
% % 
% %     LEG_GROYNES = [];
% %     for ki = 1:length(Aangepast_x)
% %         LEG_GROYNES(3) = plot(Aangepast_x{ki}./1000,Aangepast_y{ki}./1000,':k','LineWidth',2);
% %     end
% %     for ki = 1:length(HVP_x)
% %         LEG_GROYNES(4) = plot(HVP_x{ki}./1000,HVP_y{ki}./1000,'k','LineWidth',4);
% %     end
% %     for ki = 1:length(Nieuw_x)
% %         LEG_GROYNES(2) = plot(Nieuw_x{ki}./1000,Nieuw_y{ki}./1000,'-k','LineWidth',2);
% %     end
% %     for ki = 1:length(Bestaand_x)
% %         LEG_GROYNES(1) = plot(Bestaand_x{ki}./1000,Bestaand_y{ki}./1000,'Color',[1 1 1].*0.4,'LineWidth',1);
% %     end
% % 
% %     for ki = 1:length(POL_x)
% %         fill(POL_x{ki}./1000,POL_y{ki}./1000,[1 1 1].*0.85)
% %     end
% % 
% %     Ts = fieldnames(ADCP.(LOCS{Li}));
% % 
% %     colors = {'k','r'};
% %     shapes = {'o','s'};
% %     locations = {'Bottom','Top'};
% % 
% %     % Check the extent of the colourscale that we need to use
% %     CS = [10^9 -10^9];
% % 
% %     fn1 = fieldnames(DELTA_FRAC);
% %     for fn1i = 1:length(fn1)
% %         fn2 = fieldnames(DELTA_FRAC.(fn1{fn1i}));
% %         for fn2i = 1:length(fn2)
% %             CS(1) = min([CS(1) 100*DELTA_FRAC.(fn1{fn1i}).(fn2{fn2i})]);
% %             CS(2) = max([CS(2) 100*DELTA_FRAC.(fn1{fn1i}).(fn2{fn2i})]);
% %         end
% %     end
% %     CS = [0 100];
% %     CS_binedges = CS(1):10:CS(2);
% % 
% %     CM_to_pick_from = cbrewer('seq','YlGn',10);
% %     cm_markers = CM_to_pick_from;
% % 
% %     % lines and markers
% %     for Ti = 1:length(Ts)       
% %         A = ADCP.(LOCS{Li}).(Ts{Ti});
% %         I = fieldnames(A);
% %         for i = 1:length(I)
% %             if ~strcmp((I{i}),'Boat') && isfield(DELTA_FRAC.(LOCS{Li}),I{i}) && ~isnan(DELTA_FRAC.(LOCS{Li}).(I{i}))
% %                 DF = FRAC_TIDES_UNDER_CRITICAL_HW{Ti}.(LOCS{Li}).(I{i})*100;
% %                 fprintf('%s\t%s\t%s\t%.1f\n',LOCS{Li},Ts{Ti},I{i},DF)
% %                 plot(A.(I{i}).META.RDX./1000,A.(I{i}).META.RDY./1000,shapes{1},'Color',colors{1},'MarkerFaceColor',cm_markers(min(10,max(find(DF>=CS_binedges))),:),'MarkerSize',8/Ti);                
% %             end
% %         end
% %     end
% %     % Plot markers for legend
% %     for Mi = 1:length(cm_markers)
% %         h(Mi) = plot(NaN,NaN,shapes{Ti},'Color',colors{Ti},'MarkerFaceColor',cm_markers(Mi,:),'HandleVisibility','off');
% %         COLMARKLEG{Mi} = [num2str(CS_binedges(Mi)) 'cm/s to ' num2str(CS_binedges(Mi+1)) 'cm/s'];
% %     end
% %     axis equal
% %     grid on
% %     box on
% %     xlabel('RDx [km]');
% %     ylabel('RDy [km]')
% % 
% %     cb_bathy = colorbar('Location','SouthOutside');
% %     cb_bathy.Position = [0.735 0.41    0.15    0.02];
% %     tcb = title(cb_bathy,'z_b [m+NAP]');
% %     cb_bathy.TickDirection = 'out';
% %     LEG_G = legend([LEG_GROYNES],{'existing groyne','new groyne','channel wall','high water flats'},'Location','southeast');
% %     title(NAMES.(LOCS{Li}))
% %     xlim([XLIM.(LOCS{Li})])
% %     ylim([YLIM.(LOCS{Li})])    
% %     AS = gca;
% %     AS.XTick = [0:1:1000];
% %     AS.YTick = [0:1:1000];
% % 
% %     set(gca,'Layer','Top');
% % end
% % 
% % %create points for extra legend:
% % XL = XLIM.(LOCS{Li});
% % YL = YLIM.(LOCS{Li});
% % plot(XL(2)-(XL(2)-XL(1))*0.1, YL(2)-(YL(2)-YL(1))*0.065,shapes{1},'Color',colors{1},'MarkerFaceColor','w','MarkerSize',8,'HandleVisibility','off');
% % text(XL(2)-(XL(2)-XL(1))*0.07, YL(2)-(YL(2)-YL(1))*0.065,'T0');
% % plot(XL(2)-(XL(2)-XL(1))*0.1, YL(2)-(YL(2)-YL(1))*0.125,shapes{1},'Color',colors{1},'MarkerFaceColor','w','MarkerSize',8/2,'HandleVisibility','off');
% % text(XL(2)-(XL(2)-XL(1))*0.07, YL(2)-(YL(2)-YL(1))*0.125,'T1');
% % 
% % % Add fake axis for colorbar
% % FAX = axes;
% % colormap(FAX,cm_markers);
% % caxis([CS_binedges(1) CS_binedges(end)]);
% % cb = colorbar;
% % cb.Position = [0.19   0.48    0.010    0.30466];
% % cb.Ticks = CS_binedges;
% % cb.TickDirection = 'out';
% % cb.Limits = CS_binedges([1 end]);
% % cb.AxisLocation = 'in';
% % title(cb,{'% tide',['under ' num2str(LD_grens*100) ' cm/s']})
% % FAX.Position = [-1 -1 0.1 0.1];
% 
% 
% %print(fig,[dirs.figures LOCS{Li} '\' 'HW_U_relation_T0_T1_MAP_pctTIDES_T0andT1.png'],'-dpng','-r600');
% 
% %% values:
% % 
% % % %van getijden onder de ld grens:
% % T0_frac = cell2mat(struct2cell(FRAC_TIDES_UNDER_CRITICAL_HW{1,1}.BATH))*100; 
% % T1_frac = cell2mat(struct2cell(FRAC_TIDES_UNDER_CRITICAL_HW{1,2}.BATH))*100; 
% % 
% % %ignore meetpunten in geul:
% % idx = [1 18];
% % T0_frac(idx) = [];
% % T1_frac(idx) = [];
% % 
% % avgT0_frac = nanmean(T0_frac)
% % avgT1_frac = nanmean(T1_frac)
