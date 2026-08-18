% Create stop-motion GIF or video from a series of PNGs
% D.Pierce

close all
clear all
clc

%% ---- USER SETTINGS ----
inputFolder  = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Vaklodingen\Output\Bath'; 
outputFolder = 'P:\11207654-internship-pierce-2026\02_Data\Topo_Bathy\Vaklodingen\Output'; % <-- set your output location

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

filePattern  = '*.png';            % pattern to match PNG files
outputName   = 'stopmotion_BathBed';       % output filename (no extension)
frameRate    = 1;                  % frames per second
resizeWidth  = 1200;                % resize width in px (set [] to skip resizing)
makeGIF      = true;               % set true to export GIF
makeVideo    = true;               % set true to export MP4
loopGIF      = 1;                  % 0 = infinite loop for GIF

%% ---- GET AND SORT FILES ----
fileList = dir(fullfile(inputFolder, filePattern));
if isempty(fileList)
    error('No PNG files found in folder: %s', inputFolder);
end

% Natural sort (handles frame1, frame2, ..., frame10 correctly)
[~, idx] = sort_nat({fileList.name});
fileList = fileList(idx);

fprintf('Found %d frames.\n', numel(fileList));

% info = imfinfo(fullfile(inputFolder, 'ZIMM_2016.png'));
% fprintf('%d x %d px\n', info.Width, info.Height);

%% ---- CREATE GIF ----
if makeGIF
     gifFile = fullfile(outputFolder, [outputName '.gif']);
    for k = 1:numel(fileList)
        img = imread(fullfile(fileList(k).folder, fileList(k).name));

        if ~isempty(resizeWidth)
            img = imresize(img, [NaN resizeWidth]);
        end

        [A, map] = rgb2ind(img, 256);

        if k == 1
            imwrite(A, map, gifFile, 'gif', 'LoopCount', loopGIF, ...
                'DelayTime', 1/frameRate);
        else
            imwrite(A, map, gifFile, 'gif', 'WriteMode', 'append', ...
                'DelayTime', 1/frameRate);
        end
    end
    fprintf('GIF saved to %s\n', gifFile);
end

% %% ---- CREATE VIDEO (MP4) ----
% if makeVideo
%     videoFile = fullfile(outputFolder, [outputName '.mp4']);
%     v = VideoWriter(videoFile, 'MPEG-4');
%     v.FrameRate = frameRate;
%     open(v);
% 
%     for k = 1:numel(fileList)
%         img = imread(fullfile(fileList(k).folder, fileList(k).name));
% 
%         if ~isempty(resizeWidth)
%             img = imresize(img, [NaN resizeWidth]);
%         end
% 
%         % VideoWriter requires consistent frame size and RGB (uint8)
%         if size(img, 3) == 1
%             img = repmat(img, [1 1 3]); % convert grayscale to RGB
%         end
% 
%         writeVideo(v, img);
%     end
% 
%     close(v);
%     fprintf('Video saved to %s\n', videoFile);
% end

%% ---- HELPER: Natural sort function ----
function [sorted, idx] = sort_nat(cellArray)
    % Extract numeric parts for natural sorting (frame1, frame2, ..., frame10)
    nums = zeros(size(cellArray));
    for i = 1:numel(cellArray)
        tok = regexp(cellArray{i}, '\d+', 'match');
        if ~isempty(tok)
            nums(i) = str2double(tok{end});
        else
            nums(i) = i;
        end
    end
    [~, idx] = sort(nums);
    sorted = cellArray(idx);
end