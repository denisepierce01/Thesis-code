function [TR, peakVel, peakTime] = determine_TR_12hrpeakVel_time(dtSeries, wlSeries, uvSeries)

    % Function to determine peak water level and tidal range.
    % dtSeries: datetime array
    % wlSeries: wl array on dtSeries times
    % uvSeries: vel magnitude array on dtSeries times
    
    % Basic idea:
    % Find HW and LW and find max velocity within a 10 hour window. Is
    % wrtten to separate ebb and flood peaks. combines them at the end.
    % Also saves time that peaks occur as peakTime.

    dt = hours(10); % window for searching single peak every ~10 hrs

    % Determine high and low waterlevel (min separation ~10 hrs to avoid duplicates)
    HWIdx = find(islocalmax(wlSeries, 'MinSeparation', hours(10), 'SamplePoints', dtSeries));
    LWIdx = find(islocalmax(-1.*wlSeries, 'MinSeparation', hours(10), 'SamplePoints', dtSeries));
    
    % Combine HW and LW indices and sort to get successive tide events
    tideIdx = sort([HWIdx(:); LWIdx(:)]);
    tideType = zeros(size(tideIdx)); % 1 for HW, -1 for LW
    tideType(ismember(tideIdx, HWIdx)) = 1;
    tideType(ismember(tideIdx, LWIdx)) = -1;
    
    % Ensure events are alternately HW and LW; if not, drop extras at ends
    if length(tideIdx) >= 2
        % Trim so first two are different types
        k = 1;
        while k < length(tideType) && tideType(k) == tideType(k+1)
            % remove the earlier of the two similar peaks
            tideIdx(k) = [];
            tideType(k) = [];
        end
        % Also ensure alternation throughout
        k = 1;
        while k < length(tideType)
            if tideType(k) == tideType(k+1)
                tideIdx(k) = [];
                tideType(k) = [];
            else
                k = k + 1;
            end
        end
    end

    % We want one peak every ~10 hours: take non-overlapping windows of 10 hours
    velMaxEbb = []; velMaxFl = []; % keep for compatibility but will be single sequence
    TR_ebb = []; TR_flood = [];
    tVelPeakEbb = NaT(0,1);
    tVelPeakFl  = NaT(0,1);

    if isempty(tideIdx)
        TR_ebb = [];
        TR_flood = [];
        velMaxEbb = NaN(0,1);
        velMaxFl  = NaN(0,1);
        return
    end

    % Build a sequence of 12-hour windows centered on each tide event but non-overlapping:
    % Start from the first tide event, create windows [ti - dt/2, ti + dt/2], keep windows that don't overlap previous.
    keptIdx = false(size(tideIdx));
    lastEnd = dtSeries(1) - days(1); % far past
    half_dt = dt/2;
    for i = 1:length(tideIdx)
        centerT = dtSeries(tideIdx(i));
        winStart = centerT - half_dt;
        winEnd   = centerT + half_dt;
        if winStart > lastEnd
            keptIdx(i) = true;
            lastEnd = winEnd;
        end
    end

    keptTideIdx = tideIdx(keptIdx);
    keptTideType = tideType(keptIdx);

    % For each kept tide event compute tidal range relative to the adjacent opposite event
    n = length(keptTideIdx);
    peakVel = NaN(n,1);
    peakTime = NaT(n,1);
    TR = NaN(n,1);
    for ii = 1:n
        idxCenter = keptTideIdx(ii);
        centerT = dtSeries(idxCenter);
        winStart = centerT - half_dt;
        winEnd   = centerT + half_dt;
        idx_t = dtSeries >= winStart & dtSeries <= winEnd;
        if any(idx_t)
            [peakVel(ii), imax] = max(uvSeries(idx_t));
            tIdx = find(idx_t);
            peakTime(ii) = dtSeries(tIdx(imax));
        else
            peakVel(ii) = NaN;
            peakTime(ii) = NaT;
        end

        % Determine tidal range: if center is HW (1) then range = HW - nearest LW (before or after)
        if keptTideType(ii) == 1 % HW
            % find nearest LW (either previous or next in original lists)
            % prefer the closest in time
            if ~isempty(LWIdx)
                [~, kclosest] = min(abs(dtSeries(LWIdx) - centerT));
                TR(ii) = wlSeries(idxCenter) - wlSeries(LWIdx(kclosest));
            else
                TR(ii) = NaN;
            end
        else % LW
            if ~isempty(HWIdx)
                [~, kclosest] = min(abs(dtSeries(HWIdx) - centerT));
                TR(ii) = wlSeries(HWIdx(kclosest)) - wlSeries(idxCenter);
            else
                TR(ii) = NaN;
            end
        end
    end

    % Now split results into ebb/flood style outputs but only one peak every ~10 hours:
    % If the kept tide is a HW, treat it as an ebb-range (HW->LW). If LW, treat as flood-range (LW->HW).
    ebbMask = keptTideType == 1;
    flMask  = keptTideType == -1;

    TR_ebb   = TR(ebbMask);
    TR_flood = TR(flMask);
    velMaxEbb = peakVel(ebbMask);
    velMaxFl  = peakVel(flMask);
    tVelPeakEbb = peakTime(ebbMask);
    tVelPeakFl  = peakTime(flMask);