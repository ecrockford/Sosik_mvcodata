load FLUOR_v_HPLC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%SHOULD WE BE COMPARING W TCHL AS OPPOSED TO TCHLA?%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%HPLC_label = strvcat(FLUOR_v_HPLC(:,11)); 
%temp = strmatch('HS046', HPLC_label);  %bad replicate
%Fluor_v_HPLC(temp,:) = [];

datetemp = char(FLUOR_v_HPLC(:,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(FLUOR_v_HPLC(:,4)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
matday = floor(matdate);
unqday = unique(matday);

event = strvcat(FLUOR_v_HPLC(:,2));

lat = cell2mat(FLUOR_v_HPLC(:,5)); 
lon = cell2mat(FLUOR_v_HPLC(:,6));
depth = cell2mat(FLUOR_v_HPLC(:,7));
fl_chl = cell2mat(FLUOR_v_HPLC(:,8:10));
fl_phaeo = cell2mat(FLUOR_v_HPLC(:,11:13));
HPLC_chl = cell2mat(FLUOR_v_HPLC(:,14:15));
HPLC_pheophytin = cell2mat(FLUOR_v_HPLC(:,16:17));
HPLC_pheophorbide = cell2mat(FLUOR_v_HPLC(:,18:19));
HPLC_chlb = cell2mat(FLUOR_v_HPLC(:,32:33));
quality = cell2mat(FLUOR_v_HPLC(:,20:22));
hplc_quality = cell2mat(FLUOR_v_HPLC(:,30:31));
caldate = NaN(length(lat), 3);
for count = 1:3,
    datetemp = char(FLUOR_v_HPLC(:,count+22)); ind = setdiff(1:length(lat), strmatch('null', datetemp));
    caldate(ind,count) = datenum(datetemp(ind,:), 'yyyy-mm-dd HH:MM:SS');
end;
clear datetemp ind count
blank = cell2mat(FLUOR_v_HPLC(:,26:28));

HPLC_label = FLUOR_v_HPLC(:,29);
%HPLC_chl_fl = cell2mat(CHL_comparison(:,12));

ind = find(depth <= 5 & lat > 41.31 & lat < 41.335 & lon < -70.55 & lon > -70.58);

unq_cal_date = unique(caldate(~isnan(caldate)));
unq_blank = unique(blank(find(~isnan(blank))));

%return
   
%HPLC_matdate = matdate(ind);
%HPLC_chl = HPLC_chl(ind);
%save CHLforRu HPLC_chl HPLC_matdate  -append

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 1 - COMPARE CHL REPS A VS B- WHOLE CHL ONLY%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','FL CHL Rep A vs B')
plot(fl_chl(:,1), fl_chl(:,2), '.')
hold on
line([0 8], [0 8])
real=find(~isnan(fl_chl(:,1))&~isnan(fl_chl(:,2)));
fit = polyfit(fl_chl(real,1), fl_chl(real,2),1);
fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 8], 'r')
xlabel('Fl - replicate a'), ylabel('Fl - replicate b')
a=get(gca,'children');
legend(a(1),['' num2str(fit(1)) '* X + ' num2str(fit(2)) ''])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 2 - COMPARE HPLC REPS A VS B - TCHLA %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','HPLC TCHLA Rep A vs B')
plot(HPLC_chl(:,1), HPLC_chl(:,2), '.')
hold on
line([0 8], [0 8])
real=find(~isnan(HPLC_chl(:,1))&~isnan(HPLC_chl(:,2)));
fit = polyfit(HPLC_chl(real,1), HPLC_chl(real,2),1);
fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 8], 'r');
ind = find(hplc_quality(:,1)==3);
plot(HPLC_chl(ind,1), HPLC_chl(ind,2), 'ro')
ind = find(hplc_quality(:,1)==2);
plot(HPLC_chl(ind,1), HPLC_chl(ind,2), 'g^')
ind = find(hplc_quality(:,2)==3);
plot(HPLC_chl(ind,1), HPLC_chl(ind,2), 'ro')
ind = find(hplc_quality(:,2)==2);
plot(HPLC_chl(ind,1), HPLC_chl(ind,2), 'g^')
xlabel('HPLC - replicate a'), ylabel('HPLC - replicate b'), title('HPLC Tchla')
a=get(gca,'children');
legend([a(4) a(3) a(1)],['' num2str(fit(1)) '* X + ' num2str(fit(2)) ''],'flag 3','flag 2')
clear ind a fit real
HPLC_chl = nanmean(HPLC_chl,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 3 - RATIO FL CHL:MEAN HPLC TCHLA %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','Ratio FL CHL:HPLC TCHLA over time')
%colorstr = 'bgrcmky';
colormat = [1 0 0;.6 0 0; 1 0 1; 1 .8 1; 1 .6 0; .6 .4 0;1 1 0; 0 1 0;.4 .4 0; .2 .6 0; 0 .6 .4; 0 1 1; 0 0 1; 0 0 .4; .8 .6 1; .6 0 1; .2 0 .4; .4 0 0; 0 0 0; .6 .6 .6];
%colormat key [1 red; 2 brick; 3 pink; 4 light pink; 5 orange; 6gold; 
%7 yellow; 8 green; 9 olive; 10 dark green; 11 blue/green; 12 light 
%blue; 13 blue; 14 navy; 15 light purple; 16 purple; 17 egglplant
%18 brown; 19 black; 20 gray; ]

temp = [];
for count = 1:length(unq_cal_date),
    ind = strmatch(unq_cal_date(count), caldate(:,1));
    plot(ind, fl_chl(ind,1)./HPLC_chl(ind),  '.','color', colormat(count,:))
    %plot(ind, (fl_chl(ind,1)+fl_phaeo(ind,1))./(HPLC_chl(ind)+HPLC_pheo(ind,1)+HPLC_pheo(ind,2)), ['.' colorstr(count)])
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
    hold on
    ind = strmatch(unq_cal_date(count), caldate(:,2));
    plot(ind, fl_chl(ind,2)./HPLC_chl(ind),  '+','color', colormat(count,:))
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
    ind = strmatch(unq_cal_date(count), caldate(:,3));
    plot(ind, fl_chl(ind,3)./HPLC_chl(ind),  '^','color', colormat(count,:))
    if ~isempty(ind), temp = [temp unq_cal_date(count)]; end;
end;
legend(datestr(temp','dd-mm-yyyy'))
line([0 800], [1 1])
ylabel('Ratio Fl Chl : HPLC Chl'), xlabel('Sample Count')
%put a vertical blue line to denote each bach of samples sent out to be run
ind = strmatch('HS030', HPLC_label);
line([ind ind], [0 10])
ind = strmatch('HS052', HPLC_label);
line([ind ind], [0 10])
%ind = strmatch('HS151', HPLC_label); %151 & 152 are duplicates
ind = strmatch('HS150', HPLC_label);
line([ind ind], [0 10])
%red lines are biodiversity cruise samples
ind = strmatch('M316', HPLC_label);
line([ind ind], [0 10],'color', 'r')
ind = strmatch('M318', HPLC_label);
line([ind ind], [0 10], 'color', 'r')
ind = strmatch('HS285', HPLC_label);
line([ind ind], [0 10])
ind = strmatch('HS285', HPLC_label);
line([ind ind], [0 10])
ind = strmatch('HS365', HPLC_label); %265 and 266 duplicates
line([ind ind], [0 10])
ind = strmatch('HS533', HPLC_label);
line([ind ind], [0 10])
ind = strmatch('HS635', HPLC_label);
line([ind ind], [0 10])
ind = strmatch('HS807', HPLC_label);
line([ind ind], [0 10])
ind = strmatch('HS925', HPLC_label);
line([ind ind], [0 10])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 4 - RATIO FL CHL:MEAN HPLC TCHLA %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','Ratio FL CHL:HPLC TCHLA over events by chl cal date')
eventnum = str2num(event(:,6:8)) + str2num(event(:,10:11))/10;
%colormat = [1 1 0; 1 0 0; 0 0 1; 0 1 1; 1 0 1; .5 .5 .5; 0 .5 .5; .5 .5 0; .5 0 .5; .5 1 0; .5 .25 1; 1 .5 0; 1 0 .75; 1 0 .25; .25 0 0; .4 .4 .4; .8 .8 .8; .2 .7 .9; .3 .3 1; .1 .6 .9];


colormat = [0.86 0.08 0.24; 1.00 0.00 0.00; 0.60 0.00 0.00; 1.00 0.00 1.00; 
            1.00 0.80 1.00; 1.00 0.50 0.30; 0.80 1.00 0.00; 1.00 0.60 0.00; 0.60 0.40 0.00;
            1.00 1.00 0.00; 1.00 0.90 0.77; 0.00 1.00 0.00; 0.68 1.00 0.18; 0.40 0.40 0.00 ;
            0.20 0.60 0.00; 0.00 0.60 0.40; 0.00 1.00 1.00; 0.52 0.44 1.00;
            0.00 0.00 1.00; 0.00 0.00 0.40; 0.80 0.60 1.00; 0.85 0.44 0.58;
            0.60 0.00 1.00; 0.20 0.00 0.40; 0.55 0.27 0.07; 0.40 0.00 0.00;
            0.00 0.00 0.00; 0.60 0.60 0.60; 0.20 0.20 0.20;
            0.86 0.08 0.24; 1.00 0.00 0.00; 0.60 0.00 0.00; 1.00 0.00 1.00;
            1.00 0.80 1.00; 1.00 0.50 0.30; 0.80 1.00 0.00; 1.00 0.60 0.00; 0.60 0.40 0.00;
            1.00 1.00 0.00; 1.00 0.90 0.77; 0.00 1.00 0.00; 0.68 1.00 0.18; 0.40 0.40 0.00;
            0.20 0.60 0.00; 0.00 0.60 0.40; 0.00 1.00 1.00; 0.52 0.44 1.00;
            0.00 0.00 1.00; 0.00 0.00 0.40; 0.80 0.60 1.00; 0.85 0.44 0.58;
            0.60 0.00 1.00; 0.20 0.00 0.40; 0.55 0.27 0.07; 0.40 0.00 0.00;
            0.00 0.00 0.00; 0.60 0.60 0.60; 0.20 0.20 0.20];
%{
colormat key [0 crimson; 1 red; 2 brick; 3 pink; 
              4 light pink; 4a coral; 5 orange; 6gold; 
             7 yellow; 7a bisque; 7b light green; 8 green; 8a greenyellow; 9 olive; 
            10 dark green; 11 blue/green; 12 light blue; 12a light slate blue
            13 blue; 14 navy; 15 light purple; 15a pale violetred
            16 purple; 17 egglplant; 17a saddle brown; 18 brown;
            19 black; 20 gray; 21 dark gray;
            0 crimson; 1 red; 2 brick; 3 pink;
            4 light pink; 4a coral; 5 orange; 6gold;
            7 yellow; 7a bisque; 7b light green; 8 green; 8a greenyellow; 9 olive;
            10 dark green; 11 blue/green; 12 light blue; 12a light slate blue
            13 blue; 14 navy; 15 light purple; 15a pale violetred
            16 purple; 17 egglplant; 17a saddle brown; 18 brown;
            19 black; 20 gray; 21 dark gray;]
%}
            
temp = [];
for count = 1:length(unq_blank),
    ind = strmatch(unq_blank(count), blank(:,1));
%    plot(ind, fl_chl(ind,1)./HPLC_chl(ind), ['.' colorstr(count)])
    plot(eventnum(ind), fl_chl(ind,1)./HPLC_chl(ind), '.','color', colormat(count,:))
    %plot(ind, (fl_chl(ind,1)+fl_phaeo(ind,1))./(HPLC_chl(ind)+HPLC_pheo(ind,1)+HPLC_pheo(ind,2)), ['.' colorstr(count)])
    if ~isempty(ind), temp = [temp unq_blank(count)]; end;
    hold on
    ind = strmatch(unq_blank(count), blank(:,2));
%    plot(ind, fl_chl(ind,2)./HPLC_chl(ind), ['+' colorstr(count)])
    plot(eventnum(ind), fl_chl(ind,2)./HPLC_chl(ind), '+','color', colormat(count,:))
    if ~isempty(ind), temp = [temp unq_blank(count)]; end;
    ind = strmatch(unq_blank(count), blank(:,3));
%    plot(ind, fl_chl(ind,3)./HPLC_chl(ind), ['^' colorstr(count)])
    plot(eventnum(ind), fl_chl(ind,3)./HPLC_chl(ind), '^','color', colormat(count,:))
    if ~isempty(ind), temp = [temp unq_blank(count)]; end;
end;
ind = find(isnan(blank(:,1)));
plot(eventnum(ind), fl_chl(ind,1)./HPLC_chl(ind), '.k')
ind = find(isnan(blank(:,2)));
plot(eventnum(ind), fl_chl(ind,2)./HPLC_chl(ind), '+k')
ind = find(isnan(blank(:,3)));
plot(eventnum(ind), fl_chl(ind,3)./HPLC_chl(ind), '^k')

legend(num2str((temp')), 'location', 'eastoutside')
line([0 350], [1 1])
ylabel('Ratio Fl Chl : HPLC Chl'), xlabel('Event number (stn.niskin/10)')
ind = strmatch('HS030', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('HS052', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
%ind = strmatch('HS151', HPLC_label);
ind = strmatch('HS150', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('M316', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10],'color', 'r')
ind = strmatch('M318', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10], 'color', 'r')
ind = strmatch('HS285', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('HS285', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('HS365', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('HS533', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('HS635', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('HS807', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ind = strmatch('HS925', HPLC_label);
line([eventnum(ind) eventnum(ind)], [0 10])
ylim([0 4]), xlim([10 max(eventnum)+4])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 5 - FL CHL VS MEAN HPLC TCHLA w/HS LABELS %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','HPLC Tchla vs Fl Chl - w/HS label')
errorbar(HPLC_chl, nanmean(fl_chl(:,1:2),2), (fl_chl(:,1)-fl_chl(:,2))/2, '.')
%error bar = replicate range on fluorometric
hold on
line([0 10], [0 10])
th = text(HPLC_chl,nanmean(fl_chl(:,1:2),2), HPLC_label, 'fontsize', 8);
ylabel('Fluorometric Chl, mean and range'), xlabel('HPLC TChla')

ind = find(quality == 3);
fl_chl(ind) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 6 - FL CHL VS MEAN HPLC TCHLA - w/HS labels, quality 3 removed %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','HPLC Tchla vs Fl Chl - w/HS label - flag 3 removed')
errorbar(HPLC_chl, nanmean(fl_chl(:,1:2),2), (fl_chl(:,1)-fl_chl(:,2))/2, '.')
%error bar = replicate range on fluorometric
hold on
line([0 10], [0 10])
th = text(HPLC_chl,nanmean(fl_chl(:,1:2),2), HPLC_label, 'fontsize', 8);
ylabel('Fluorometric Chl, mean and range'), xlabel('HPLC TChla')
title('quality 3 removed')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%FIG 7 - FL CHL VS MEAN HPLC TCHLA - quality 3 removed, no labels %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','HPLC Tchla vs Fl Chl - flag 3 removed (no HS)')
ind = find(~isnan(HPLC_chl) & ~isnan(nanmean(fl_chl(:,1:2),2)) & matdate > datenum('4-1-2006') & ~strcmp('HS069', HPLC_label));
errorbar(HPLC_chl(ind), nanmean(fl_chl(ind,1:2),2), (fl_chl(ind,1)-fl_chl(ind,2))/2, '.')
hold on
line([0 10], [0 10])
%th = text(HPLC_chl,nanmean(fl_chl(:,1:2),2), HPLC_label, 'fontsize', 8);
ylabel('Fluorometric Chl, mean and range'), xlabel('HPLC TChla')
title('quality 3 removed & CHORS removed')
%fit = polyfit(HPLC_chl(ind), nanmean(fl_chl(ind,1:2),2),1);
[m, b, r, sm, sb] = lsqfitgm(HPLC_chl(ind), nanmean(fl_chl(ind,1:2),2));  %model II regression
eval(['fplot(''x*' num2str(m) '+' num2str(b) ''',[0 10], ''color'', ''k'')'])
a=get(gca,'children');
legend(a(1),['x*' num2str(m) '+' num2str(b) ])

