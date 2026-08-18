clear all;
close all;
clc;

Ts = {'T0','T1'};
LOCS = {'WALS','BATH'};

dir_figures = 'p:\11207654-internship-pierce-2026\04_Scripts\rep_period\Figures\english\';

Full_simulation.T0 = 'p:\1204421-kpp-benokust\2025\06-Westerschelde\03_modelruns\000_hydrodynamic_validation\WS_hydro_3D_2018\dflowfm\output\WS_0000_his.nc';
%Full_simulation.T1 = 'p:\1221559-buitendijks\Model\Runs\Scenarios\S00_B1\DFM_OUTPUT_FlowFM\FlowFM_his.nc';

T_lunar_cyle = 29.53; % Days = 2 SN cycles

% Determine the beginnen and the end of tidal cycles by analysing WL_stations representative for BLHK and KNHK sepperately
Rep_station.WALS = 'WALS';
Rep_station.BATH = 'BATH';

for Ti = 1%:length(Ts)
    % Load model data    
    hisfile = Full_simulation.(Ts{Ti});    
    M.t = datetime(strrep(strrep(ncreadatt(hisfile,'time','units'),'seconds since ',''), ' +00:00', ''), 'InputFormat', 'uuuu-MM-dd HH:mm:ss')+seconds(ncread(hisfile,'time'));
    if minutes(M.t(2)-M.t(1))>120
        TI = 2:length(M.t);
    else
        TI = 1:length(M.t);
    end
    M.t = M.t(TI);
    %Ux = ncread(hisfile,'x_velocity');
    %Uy = ncread(hisfile,'y_velocity');
    %M.Umag = sqrt(Ux.^2+Uy.^2);
    %M.Umag = M.Umag(TI);
    %M.WL = ncread(hisfile,'waterlevel');
    %M.WL = M.WL(:,TI);
    M.Name = ncread(hisfile,'station_id');
    M.Name = cellfun(@(x)x(1:max(find(uint8(x)~=0))),char2cell(M.Name'),'UniformOutput',false);
    
    % Isolate tides for BLHK and KNHK (different reference point in channel)
    for Li = 1:length(LOCS)
        i_rs = find(strcmp(M.Name,[Rep_station.(LOCS{Li})]));
        M.WL(Li,:) = ncread(hisfile, 'waterlevel', [i_rs 1], [1 Inf]);
        REP_WL.(LOCS{Li}) = M.WL(Li,:);
    end
    % Timelag between both locations is 10 minutes (can be 30 min for LW), therefore, just use the
    % average signal for the selection of the tides
    REP_WL_COMB = (REP_WL.WALS+REP_WL.BATH)./2;
    
    % Determine LW and HW of tides
    [a LW_i] = findpeaks(REP_WL_COMB.*-1,'MinPeakDistance',round(10/24/days(M.t(end)-M.t(end-1))));
%     fig = figure;
%     plot(M.t,REP_WL_COMB)
%     hold on
%     plot(M.t(LW_i),REP_WL_COMB(LW_i),'or')
    % Value of tides
    clearvars TIDES
    TIDES.LW_t_start    = M.t(LW_i(1:(end-1)));
    TIDES.LW_t_end      = M.t(LW_i(2:end));
    for TTT = 1:length(TIDES.LW_t_start)
        TIDES.HW_val(TTT) = max(REP_WL_COMB(LW_i(TTT):LW_i(TTT+1)));
    end
    
    % Determine HW reference of a full year (containing a whole amount of lunar cycles)
    start_year = TIDES.LW_t_start(1);
    N_lunar_cyles = floor((TIDES.LW_t_end(end)-TIDES.LW_t_start(1))/days(T_lunar_cyle));
    end_year = TIDES.LW_t_end(min(find(TIDES.LW_t_end>start_year+days(N_lunar_cyles*T_lunar_cyle))));
    n_tides_in_year_wholeSNcyles = find(end_year==TIDES.LW_t_end);
    HW_REFERENCE = TIDES.HW_val(1:n_tides_in_year_wholeSNcyles);
    
    % Loop over all tides and plot cdfs
    last_tide_that_still_starts_full_cycle = max(find(TIDES.LW_t_start<(TIDES.LW_t_end(end)-days(T_lunar_cyle))));
    DL = 0.1;
    LEVELS_FOR_RMSE = 0.5*DL:DL:(1-DL*0.5);
    LEVELS_FOR_RMSE = sort([LEVELS_FOR_RMSE 0.25*DL 0.75*DL DL 1-0.25*DL 1-0.75*DL 1-DL]);
    %LEVELS_FOR_RMSE = unique(sort([LEVELS_FOR_RMSE 0.5*DL+0.8:DL/8:(1-DL/8*0.5)]));
    fig = figure;
    hold on
    [z_REF,p_REF] = cdf_HW(HW_REFERENCE);
    [U1 U2_REF] = unique(p_REF);
    HW_at_LEVELS_FOR_RMSE_REF = interp1(p_REF(U2_REF),z_REF(U2_REF),LEVELS_FOR_RMSE);
    for j = 1:last_tide_that_still_starts_full_cycle
        start_index_SN = j;
        rounding_hours = 1;
        end_index_SN = min(find(TIDES.LW_t_end>(TIDES.LW_t_start(start_index_SN)+days(T_lunar_cyle)-hours(rounding_hours))));
        [z,p] = cdf_HW(TIDES.HW_val(start_index_SN:end_index_SN));
        LEG_all_cycles = plot(z,p,'Color',[1 1 1].*0.75);
        [U1 U2_THIS] = unique(p);
        HW_at_LEVELS_FOR_RMSE_THIS = interp1(p(U2_THIS),z(U2_THIS),LEVELS_FOR_RMSE);
        RMSE(j) = sqrt(mean((HW_at_LEVELS_FOR_RMSE_THIS-HW_at_LEVELS_FOR_RMSE_REF).^2));       
    end     
    
    % Repeat ten tides with least RMSE
    [sorted_RMSE,sorted_RMSE_i] = sort(RMSE);
%     for j = 1:5
%         start_index_SN = sorted_RMSE_i(j);
%         end_index_SN = min(find(TIDES.LW_t_end>(TIDES.LW_t_start(start_index_SN)+days(T_lunar_cyle))));
%         [z,p] = cdf_HW(TIDES.HW_val(start_index_SN:end_index_SN));
%         if j == 1
%             LW = 2;
%             col = 'r';
%         else
%             LW = 1;
%             col = 'b';
%         end
%         plot(z,p,col,'LineWidth',LW);
%     end
    
    % Repeat SELECTED tide (lowest RMSE)
    start_index_SN = sorted_RMSE_i(1);
    end_index_SN = min(find(TIDES.LW_t_end>=(TIDES.LW_t_start(start_index_SN)+days(T_lunar_cyle)-hours(rounding_hours))));
    [z,p] = cdf_HW(TIDES.HW_val(start_index_SN:end_index_SN));
    LEG_selected = plot(z,p,'r','LineWidth',3);
    sorted_REF_HW = sort(HW_REFERENCE);
    fprintf('\n\n> %s\n',Ts{Ti})
    fprintf('Repr. SN-cycle regarding HWs (from/to):\n%s\n%s\n',TIDES.LW_t_start(start_index_SN),TIDES.LW_t_end(end_index_SN))
    fprintf('RMSE horizontal lines: %.03f m\n',min(RMSE))
    fprintf('This is %.2f days (SN cycle is %.2f days)\n',days(TIDES.LW_t_end(end_index_SN)-TIDES.LW_t_start(start_index_SN)),T_lunar_cyle)
    buf = sort(HW_REFERENCE,'descend');
    HW_EXC_12_REF = buf(12);
    fprintf('Max HW: %.2f m (selected SN) | %.2f m (exceeded 12 times in REF year)\n',max(TIDES.HW_val(start_index_SN:end_index_SN)),HW_EXC_12_REF)
    fprintf('!!! Mapoutput starting 1h before and ending 1h after (timelag project locations)\n')
    
    LEG_Ref = plot(z_REF,p_REF,'k','LineWidth',3);
    hold on
    XL = xlim;
    % for LEV = 1:length(LEVELS_FOR_RMSE)
    %     plot(XL,XL.*0+LEVELS_FOR_RMSE(LEV),'k')
    % end
       
    grid on
    box on
    set(gca,'Layer','top','FontSize',18)
    title('Representative Lunation','FontWeight','bold','FontSize',28)
    xlabel('HW [m+NAP]','FontWeight','bold')
    ylabel('Fraction HW lower [-]','FontWeight','bold')
    L=legend([LEG_all_cycles LEG_selected LEG_Ref],['All ' num2str(last_tide_that_still_starts_full_cycle) ' options for 1 lunation'],'Most Representative Period',[num2str(N_lunar_cyles) ' full lunations in ' num2str(year(mean(M.t)))],'Location','SouthEast');
    %set(gca,'YGrid','off')
    fig.Units = 'centimeters';
    fig.Position = [1 1 16 6];
    fig.PaperPositionMode = 'auto';
    L.Position(1:2) = [0.5922    0.148];
    print(fig,'-dpng','-r300',[dir_figures 'Distributions_' num2str(year(mean(M.t))) '.png']);
    
    fig = figure;
    plot(M.t,REP_WL_COMB)
    hold on
    i1 = find(M.t==TIDES.LW_t_start(start_index_SN));
    i2 = find(M.t==TIDES.LW_t_end(end_index_SN));
    plot(M.t(i1:i2),REP_WL_COMB(i1:i2))    
    ylabel('Waterstand [m+NAP]')
    L = legend(['Heel ' num2str(year(mean(M.t)))],'Representatieve periode','Location','SouthEast');
    grid on
    fig.Units = 'centimeters';
    fig.Position = [1 1 16 7];
    fig.PaperPositionMode = 'auto';
    L.Position(1:2) = [0.636    0.123];
    print(fig,'-dpng','-r300',[dir_figures 'Waterlevels_' num2str(year(mean(M.t))) '.png']);
   
end


function [z,p] = cdf_HW(HW)
    DZ = 0.05;
    z = floor((min(HW)-0.1)*10)/10:DZ:ceil((max(HW)+0.1)*10)/10;
    for zi = 1:length(z)
        p(zi) = length(find(HW<=z(zi)))./length(HW);
    end    
end
