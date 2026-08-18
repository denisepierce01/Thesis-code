%Trying to extract RDx and RDy coordiantes quickly or z_sensor
%D. Pierce

clear all
close all
clc

% %% Load data
% load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')
% 
% stations = fieldnames(ADCP.OSSENISSE.T1);
% 
% RDx = [];
% RDy = [];
% stationNames = {};
% 
% for i = 1:length(stations)
% 
%     st = stations{i};
% 
%     if isfield(ADCP.OSSENISSE.T1.(st),'META')
% 
%         RDx(end+1) = ADCP.OSSENISSE.T1.(st).META.RDX;
%         RDy(end+1) = ADCP.OSSENISSE.T1.(st).META.RDY;
%         stationNames{end+1} = st;
% 
%     end
% 
% end

%% adapted for t_CET start and end of each ADCP

% Load data
load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')

stations = fieldnames(ADCP.BATH.T0);
stationNames = {};

t_start = [];
t_end = [];

for i = 1:length(stations)

    st = stations{i};

    if isfield(ADCP.BATH.T0, st)

        t_start(end+1) = ADCP.BATH.T0.(st).datenum(1,1);
        t_end(end+1) = ADCP.BATH.T0.(st).datenum(1,end);
        stationNames{end+1} = st;

    end

end 

% convert datenum to datetime
t_start = datetime(t_start, 'ConvertFrom', 'datenum');
t_end = datetime(t_end, 'ConvertFrom', 'datenum');

% create table based on location,sensor, period, start time, end time

% %% for adcp elevations of sensor
% stations = fieldnames(ADCP.ZIMMERMAN.T0);
% 
% z_sensor = [];
% stationNames = {};
% 
% for i = 1:length(stations)
% 
%     st = stations{i};
% 
%     if isfield(ADCP.ZIMMERMAN.T0.(st),'META')
% 
%         z_sensor(end+1) = ADCP.ZIMMERMAN.T0.(st).META.ZSENSOR;
%         stationNames{end+1} = st;
% 
%     end
% 
% end

%% trying new method
load('p:\11207654-internship-pierce-2026\02_Data\Velocity_data_ADCP\Processed matlab files\ADCP.mat')

% choose which ADCP grouping to use (modify if needed)
group = ADCP.ZIMMERMAN.T1;
stations = fieldnames(group);
stationNames = {};

t_start = [];
t_end = [];
location = {};
sensor = {};

for i = 1:length(stations)
    st = stations{i};
    if isfield(group, st) && isfield(group.(st),'datenum')
        dn = group.(st).datenum;
        if isempty(dn) || ~isnumeric(dn)
            continue
        end
        % use first and last time entries from datenum rows
        t_start(end+1) = dn(1,1);
        t_end(end+1)   = dn(1,end);
        stationNames{end+1} = st;
        % derive location from ADCP structure: ADCP.<station> (use station name)
        % if isfield(ADCP, st)
        %     location{end+1} = st; % location is ADCP.{station} per request
        %     % period label as ADCP.location.{station} -> store as string "ADCP.<station>"
        %     period{end+1} = sprintf('ADCP.%s', st);
        % else
        %     location{end+1} = '';
        %     period{end+1} = '';
        % end
        % try to extract sensor metadata if present
        if isfield(group.(st),'META') && isfield(group.(st).META,'ZSENSOR')
            sensor{end+1} = group.(st).META.ZSENSOR;
        else
            sensor{end+1} = '';
        end
    end
end

% convert datenum to datetime
t_start = datetime(t_start, 'ConvertFrom', 'datenum');
t_end   = datetime(t_end,   'ConvertFrom', 'datenum');

% create table based on location,sensor, period, start time, end time
T = table(stationNames(:), sensor(:), t_start(:), t_end(:), ...
    'VariableNames', {'Station','Sensor','StartTime','EndTime'});