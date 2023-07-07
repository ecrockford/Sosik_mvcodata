%load MVCO_chl
load chl_data

datetemp = char(MVCO_chl(:,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(MVCO_chl(:,4)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
matday = floor(matdate);
unqday = unique(matday);
clear datetemp

event = strvcat(MVCO_chl(:,2));
%lat = str2num(char(MVCO_chl(:,4))); 
%lon = str2num(char(MVCO_chl(:,5)));
%depth = str2num(char(MVCO_chl(:,6)));
lat = cell2mat(MVCO_chl(:,5)); 
lon = cell2mat(MVCO_chl(:,6));
depth = cell2mat(MVCO_chl(:,7));
filter_size = cell2mat(MVCO_chl(:,8));
pigm = cell2mat(MVCO_chl(:,9:10));

tempstr = cellstr([event num2str(depth)]);
[unqstr, ind] = unique(tempstr);
lat2 = lat(ind); lon2 = lon(ind); depth2 = depth(ind); 
matdate2 = matdate(ind);
event2 = event(ind,:);

width = 8;  %4 cols for filter 0, 2 for filter 10, 2 for filter 80
mvco_chlrep = NaN.*ones(length(unqstr), width);
mvco_phaeorep = NaN.*ones(length(unqstr), width);
for count = 1:length(unqstr),
    ind = find(strcmp(tempstr, unqstr(count)));
    ind2 = find(filter_size(ind) == 0);
    for count2 = 1:length(ind2),
        if length(ind2) > 4, disp('too many chl reps'), keyboard, end;  
        mvco_chlrep(count,count2) = pigm(ind(ind2(count2)),1);
        mvco_phaeorep(count,count2) = pigm(ind(ind2(count2)),2);
    end;
%    keyboard
    ind2 = find(filter_size(ind) == 10);
    for count2 = 1:length(ind2),
        mvco_chlrep(count,count2+4) = pigm(ind(ind2(count2)),1);
        mvco_phaeorep(count,count2+4) = pigm(ind(ind2(count2)),2);
    end;
    ind2 = find(filter_size(ind) == 80);
    for count2 = 1:length(ind2),
        mvco_chlrep(count,count2+6) = pigm(ind(ind2(count2)),1);
        mvco_phaeorep(count,count2+6) = pigm(ind(ind2(count2)),2);
    end;
end;

clear ind ind2 width tempstr unqstr lat lon depth matdate event unqday pigm filter* count* matday
matdate = matdate2;
lon = lon2;
lat = lat2;
depth = depth2;
event = event2;
clear *2

chlavg = [nanmean(mvco_chlrep(:,[1:4]),2) nanmean(mvco_chlrep(:,5:6),2) nanmean(mvco_chlrep(:,7:8),2)];       
phaeoavg = [nanmean(mvco_phaeorep(:,[1:4]),2) nanmean(mvco_phaeorep(:,5:6),2) nanmean(mvco_phaeorep(:,7:8),2)];       
rep_titles = {'whole a', 'whole b', 'whole c', 'whole d', '<10um a', '<10um b', '<80um a', '<80um b'};
avg_title = {'whole', '<10um', '<80um'};

save mvco_chlrep mvco_chlrep mvco_phaeorep depth lat lon matdate chlavg phaeoavg *titles event

percent_range = range(mvco_chlrep(:,1:4),2)./nanmean(mvco_chlrep(:,1:4),2)*100;  %case for whole water
%percent_range = range(mvco_chlrep(:,5:6),2)./nanmean(mvco_chlrep(:,5:6),2)*100; %case for < 10 micron replicates
%percent_range = range(mvco_chlrep(:,7:8),2)./nanmean(mvco_chlrep(:,7:8),2)*100;  %case for < 80 micron replicates
figure, hist(percent_range, [0:5:max(percent_range)]), ylabel('# of events'), xlabel('Replicate range / mean (%)')
xlim([-2.5 inf])
figure
plot(percent_range ,'.')
ylabel('Chl replicate range / mean (%)')
xlabel('Event index number')
%find cases with whole chl range > 20% of mean
ind = find(percent_range > 20);
hold on
plot(ind, percent_range(ind) ,'ro')

disp('events with high range for replicates')
disp(['event' 'range/mean %', rep_titles])
disp([event(ind,:) repmat('            ', length(ind),1) num2str([floor(percent_range(ind)) mvco_chlrep(ind,:)])])

figure
ratio = mvco_phaeorep(:,1:4)./mvco_chlrep(:,1:4);
plot(ratio(:,1), 'b.')
hold on
plot(ratio(:,2), 'ro')
ylabel('Ratio Phaeo/Chl')
xlabel('Event index number')
ind = find(ratio(:,1) > 1 | ratio(:,1) < 0);
plot(ind, ratio(ind,1), 'g.')
ind2 = find(ratio(:,2) > 1 | ratio(:,2) < 0);
plot(ind2, ratio(ind2,2), 'go')

disp('events with extreme phaeo/chl')
disp(['event' 'phaeo/chl', rep_titles])
disp([event(ind,:) repmat('            ', length(ind),1) num2str([ratio(ind,1) mvco_chlrep(ind,:)])])
disp([event(ind2,:) repmat('            ', length(ind2),1) num2str([ratio(ind2,2) mvco_chlrep(ind2,:)])])

percent_range = range(ratio(:,1:4),2)./nanmean(ratio(:,1:4),2)*100;  %case for whole water
figure
plot(percent_range ,'.')
ylabel('Phaeo/Chl replicate range / mean (%)')
xlabel('Event index number')
%find cases with range > 20% of mean
ind = find(percent_range > 50);
hold on
plot(ind, percent_range(ind) ,'ro')

disp('events with high range for chl/phaeo replicates')
disp(['event' 'range/mean %', rep_titles(1:2), rep_titles(1:2), 'phaeo/chl'])
disp([event(ind,:) repmat('            ', length(ind),1) num2str([floor(percent_range(ind)) mvco_chlrep(ind,1:2) mvco_phaeorep(ind,1:2) ratio(ind,1:2)])])




return
ind1 = find(depth2 <= 5 & lat2 > 41.31 & lat2 < 41.335 & lon2 < -70.55 & lon2 > -70.58);
FL_matdate = matdate2(ind1);
FL_chl = chlavg(ind1);

save CHLforRu FL_matdate FL_chl -append

%ASIT, near surface
ind1 = find(depth <= 5 & lat > 41.31 & lat < 41.335 & lon < -70.55 & lonn > -70.58);