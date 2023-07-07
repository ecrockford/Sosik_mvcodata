%load MVCO_chl
load chl_data_reps

datetemp = char(MVCO_chl_reps(:,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(MVCO_chl_reps(:,4)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
matday = floor(matdate);
unqday = unique(matday);
clear datetemp unqday

event = strvcat(MVCO_chl_reps(:,2));
lat = cell2mat(MVCO_chl_reps(:,5)); 
lon = cell2mat(MVCO_chl_reps(:,6));
depth = cell2mat(MVCO_chl_reps(:,7));
chl = cell2mat(MVCO_chl_reps(:,8:14));
phaeo = cell2mat(MVCO_chl_reps(:,15:21));
quality = cell2mat(MVCO_chl_reps(:,22:28));
caldate = NaN(length(lat), 7);
for count = 1:7,
    datetemp = char(MVCO_chl_reps(:,count+28)); ind = setdiff(1:length(lat), strmatch('null', datetemp));
    caldate(ind,count) = datenum(datetemp(ind,:), 'yyyy-mm-dd HH:MM:SS');
end;
clear datetemp ind count

rep_titles = {'whole a', 'whole b', 'whole c', '<10um a', '<10um b', '<80um a', '<80um b', 'flag a', 'flag b', 'flag c', 'flag 10a', 'flag 10b', 'flag 80a', 'flag 80b'};
avg_title = {'whole', '<10um', '<80um'};

badind = find(max(quality(:,1:3)')' == 3);
percent_range = range(chl(:,1:3),2)./nanmean(chl(:,1:3),2)*100;  %case for whole water
%percent_range = range(chl(:,5:6),2)./nanmean(chl(:,4:5),2)*100; %case for < 10 micron replicates
%percent_range = range(chl(:,7:8),2)./nanmean(chl(:,6:7),2)*100;  %case for < 80 micron replicates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 1 - HISTO REP RAGNE/MEAN%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','Histo Chl Replicate range/mean (%)')
hist(percent_range, [0:5:max(percent_range)]), ylabel('# of events'), xlabel('Replicate range / mean (%)')
xlim([-2.5 inf])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 2 - REP RAGNE/MEAN OVER TIME%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position',[2 502 1275 420], 'name','Chl replicate range / mean (%) over time')
plot(percent_range ,'.')
ylabel('Chl replicate range / mean (%)')
xlabel('Event index number')
%find cases with whole chl range > 20% of mean
ind = find(percent_range > 20);
hold on
plot(ind, percent_range(ind) ,'go')
plot(badind, percent_range(badind) ,'r*')  %already flagged bad (flag 3 = throw out)
legend('all', 'outliers', 'flag =3')
th = text(badind,percent_range(badind), event(badind,:), 'fontsize', 8, 'interpreter', 'none');

disp('events with high range for replicates')
disp(['event' 'range/mean %', rep_titles(1:5) rep_titles(8:12)])
%excluded <80um and now only display whole and <10 who looks at <80 anyway? TC Dec7,2011
%disp([event(ind,:) repmat('            ', length(ind),1) num2str([floor(percent_range(ind)) chl(ind,:) quality(ind,:)])])
disp([event(ind,:) repmat('            ', length(ind),1) num2str([floor(percent_range(ind)) chl(ind,1:5) quality(ind,1:5)])])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 3 - REP RAGNE/MEAN OVER TIME%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ratio = phaeo(:,1:3)./chl(:,1:3);
percent_range = range(ratio(:,1:3),2)./nanmean(ratio(:,1:3),2)*100;  %case for whole water
figure('position',[2 502 1275 420], 'name','Percent Range: Phaeo/Chl replicate range / mean (%) over time')
plot(percent_range ,'.')
title('Percent range for whole water')
ylabel('Phaeo/Chl replicate range / mean (%)')
xlabel('Event index number')
%find cases with range > 20% of mean
ind = find(percent_range > 50);
hold on
plot(ind, percent_range(ind) ,'go')
plot(badind, percent_range(badind),'r*')%flag 3 = thrown out
th = text(badind,percent_range(badind), event(badind,:), 'fontsize', 8, 'interpreter', 'none');


disp('events with high range for phaeo/chl replicates')
disp({'event' 'range/mean %', 'wholeA chl', 'wholeB chl', 'wholeA phaeo', 'wholeB phaeo', 'phaeo/chl a', 'phaeo/chl b', 'flag wholeA','flag wholeB'})
disp([event(ind,:) repmat('            ', length(ind),1) num2str([floor(percent_range(ind)) chl(ind,1:2) phaeo(ind,1:2) ratio(ind,1:2) quality(ind,1:2)])])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 4 - RATIO PHAEO/CHL OVER TIME %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
badind1 = find(quality(:,1) == 3);
badind2 = find(quality(:,2) == 3);
figure('position',[2 502 1275 420], 'name','Ratio Phaeo/Chl over time')
plot(ratio(:,1), 'b.')
hold on
plot(ratio(:,2), 'bo')
ylabel('Ratio Phaeo/Chl')
xlabel('Event index number')
ind = find(ratio(:,1) > 1 | ratio(:,1) < 0);
plot(ind, ratio(ind,1), 'g.')
ind2 = find(ratio(:,2) > 1 | ratio(:,2) < 0);
plot(ind2, ratio(ind2,2), 'go')
plot(badind1, ratio(badind1,1), 'r*')
plot(badind2, ratio(badind2,2), 'r*')

th = text(badind1,ratio(badind1,1), event(badind1,:), 'fontsize', 8, 'interpreter', 'none','color','r');
th2 = text(badind2,ratio(badind2,2), event(badind2,:), 'fontsize', 8, 'interpreter', 'none');


disp('events with extreme phaeo/chl')
%ind=bad ratio whole chl A
disp(['event' 'phaeo/chl', rep_titles(1:2), 'phaeoA', 'phaeoB', rep_titles(8:12)])
disp('Bad Ratio whole chlA')
disp([event(ind,:) repmat('            ', length(ind),1) num2str([ratio(ind,1) chl(ind,1:2) phaeo(ind,1:2) quality(ind,1:5)])])
%ind2=bad ratio whole chl B
disp(' ')
disp('Bad Ratio whole chlB')
disp([event(ind2,:) repmat('            ', length(ind2),1) num2str([ratio(ind2,2) chl(ind2,1:2) phaeo(ind2,1:2) quality(ind2,1:5) ])])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 5 - RATIO PHAEO/CHL W CAL DATE %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position',[2 502 1275 420], 'name','Ratio Phaeo/Chl w Calibration Date')
%colorstr = 'bgrcmky';
colormat = [1 1 0; 1 0 0; 0 0 1; 0 1 1; 1 0 1; .5 .5 .5; 0 .5 .5; .5 .5 0; .5 0 .5; .5 1 0; .5 .25 1; 1 .5 0; 1 0 .75; 1 0 .25; .25 1 .25; .3 0 1];
temp = [];
unq_cal_date = unique(caldate(~isnan(caldate)));
for count = 1:length(unq_cal_date),
    ind = strmatch(unq_cal_date(count), caldate(:,1));
    plot(ind, ratio(ind,1),  '.' ,'color', colormat(count,:))
    %plot(ind, (fl_chl(ind,1)+fl_phaeo(ind,1))./(HPLC_chl(ind)+HPLC_pheo(ind,1)+HPLC_pheo(ind,2)), ['.' colorstr(count)])
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
    hold on
    ind = strmatch(unq_cal_date(count), caldate(:,2));
    plot(ind, ratio(ind,2),  '+','color', colormat(count,:))
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
    ind = strmatch(unq_cal_date(count), caldate(:,3));
    plot(ind, ratio(ind,3),  '^')
%     if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
end;
legend(datestr(temp'))
ylabel('Ratio Phaeo/Chl')
xlabel('Index number')
plot(badind1,ratio(badind1,1),'r*')
th = text(badind1,ratio(badind1,1), event(badind1,:), 'fontsize', 8, 'interpreter', 'none');
plot(badind2,ratio(badind2,2),'r*')
th2 = text(badind2,ratio(badind2,2), event(badind2,:), 'fontsize', 8, 'interpreter', 'none');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 6 - CHL OVER TIME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position',[2 38 1275 420], 'name','Chl over time w Calibration Date')
% colormat = [1 1 0; 1 0 0; 0 0 1; 0 1 1; 1 0 1; .5 .5 .5; 0 .5 .5; .5 .5 0; .5 0 .5; .5 1 0; .5 .25 1; 1 .5 0; 1 0 .75; 1 0 .25];
temp = [];
unq_cal_date = unique(caldate(~isnan(caldate)));
for count = 1:length(unq_cal_date),
    ind = strmatch(unq_cal_date(count), caldate(:,1));
    plot(ind, chl(ind,1),  '.','color', colormat(count,:))
    %plot(ind, (fl_chl(ind,1)+fl_phaeo(ind,1))./(HPLC_chl(ind)+HPLC_pheo(ind,1)+HPLC_pheo(ind,2)), ['.' colorstr(count)])
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
    hold on
    ind = strmatch(unq_cal_date(count), caldate(:,2));
    plot(ind, chl(ind,2),  '+','color', colormat(count,:))
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
    ind = strmatch(unq_cal_date(count), caldate(:,3));
    plot(ind, chl(ind,3),  '^','color', colormat(count,:))
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
end;
legend(datestr(temp'))
ylabel('Chl')
xlabel('Index number')
plot(badind1,chl(badind1,1),'k.','markersize',20)
th = text(badind1,chl(badind1,1), event(badind1,:), 'fontsize', 8, 'interpreter', 'none');
plot(badind2,chl(badind2,2),'k.','markersize',20)
th2 = text(badind2,chl(badind2,2), event(badind2,:), 'fontsize', 8, 'interpreter', 'none');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 7 - COMPARE CHL REPS A VS B- WHOLE CHL ONLY%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
th = text(chl(:,1),chl(:,2), event, 'fontsize', 8, 'interpreter', 'none');
hold on
plot(chl(:,1), chl(:,2), '.', 'markersize', 15)
badind = find(max(quality(:,1:3)')' == 3);
plot(chl(badind,1), chl(badind,2), 'r*')
legend('quality 1/2', 'quality 3')
line([0 12], [0 12])
ylabel('Chl - rep b')
xlabel('Chl - rep a')


%remove quality 3 values
ind = find(quality == 3);
chl(ind) = NaN;
phaeo(ind) = NaN;

chlavg = [nanmean(chl(:,[1:3]),2) nanmean(chl(:,4:5),2) nanmean(chl(:,6:7),2)];       
phaeoavg = [nanmean(phaeo(:,[1:3]),2) nanmean(phaeo(:,4:5),2) nanmean(phaeo(:,6:7),2)];       

save mvco_chlrep chl phaeo quality caldate depth lat lon matdate chlavg phaeoavg *titles event

return
ind1 = find(depth <= 5 & lat > 41.31 & lat < 41.335 & lon < -70.55 & lon > -70.58);
FL_matdate = matdate(ind1);
FL_chl = chlavg(ind1);

save CHLforRu2 FL_matdate FL_chl -append

%ASIT, near surface
ind1 = find(depth <= 5 & lat > 41.31 & lat < 41.335 & lon < -70.55 & lon > -70.58);
