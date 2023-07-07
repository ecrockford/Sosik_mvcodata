clear
load C:\data\mvcodata\matlab_files\swwim
save swwimtemp wt* README_sw mday_sw ht* sst_sw lw_sw lat_sw lon_sw wd_sw

clear
load swwimtemp
%load C:\data\mvcodata\matlab_files\swwimtemp
%daily smooth
[y,m,d,h,mi,s] = datevec(mday_sw);
unq_yr=unique(y);
%mday=[datenum(unq_yr(1),0,1,0,0,0) datenum(unq_yr(end),12,31,0,0,0)];

%%%%%%%%%%%%%%
%{
t = find(diff(d));
t = [0; t];
wt27 = NaN.*zeros(length(t), size(wt27_sw,2));
wt15 = NaN.*zeros(length(t), size(ht15_sw,2));
lw = NaN.*zeros(length(t), size(lw_sw,2));
swimm_sst = NaN.*zeros(length(t), size(sst_sw,2));
%}
%%%%%%%%%%

wt27_halfm = NaN(366,length(unq_yr));
wt27_2m = wt27_halfm;
wt27_5m = wt27_halfm;
wt15_2m = wt27_halfm;
lw = wt27_halfm;
sst_27m = wt27_halfm;
sst_15m = wt27_halfm;
mday = wt27_halfm;
avgvel27_16meast=mday;
avgvel27_16mnorth=mday;
avgvel27_2meast=mday;
avgvel27_2mnorth=mday;
wavg_4coleast=mday;
wavg_4colnorth=mday;
for noyear=1:length(unq_yr)
    temp=[datenum(unq_yr(noyear),0,1,0,0,0):datenum(unq_yr(noyear),12,31,0,0,0)]';
    mday(1:length(temp),noyear)=temp;
end
clear ht* m mi s y d h unq_yr wd_sw temp

day=floor(mday_sw);
unq_days=unique(day);

for count=1:length(unq_days)
    swind=find(day==unq_days(count));
    newind=find(mday==unq_days(count));
    wt27_halfm(newind) = nanmean(wt27_sw(swind,end));
    wt27_2m(newind) = nanmean(wt27_sw(swind,end-1));
    wt27_5m(newind) = nanmean(wt27_sw(swind,end-2));
    wt15_2m(newind) = nanmean(wt15_sw(swind,end));
    lw(newind) = nanmean(lw_sw(swind));
    sst_27m(newind) = nanmean(sst_sw(swind,end));
    sst_15m(newind) = nanmean(sst_sw(swind,3));
    avgvel27_2meast(newind)=nanmean(real(wen27_sw(swind,end)));
    avgvel27_2meast(newind)=nanmean(imag(wen27_sw(swind,end)));
    avgvel27_16meast(newind)=nanmean(real(wen27_sw(swind,20)));
    avgvel27_16mnorth(newind)=nanmean(imag(wen27_sw(swind,20)));
    wavg_4coleast(newind)=nanmean(real(wavg_sw(swind,end)));
    wavg_4colnorth(newind)=nanmean(imag(wavg_sw(swind,end)));
end

save dailyswimm_temp sst_27m sst_15m wt27_halfm wt27_2m wt27_5m wt15_2m lw mday avgvel27_* wavg_4col




%{
for noyear=1:length(unq_yr)
    ind=find(y==unq_yr(noyear))
    tempwt27=wt27_sw(ind,:);
    tempwt15=wt15_sw(ind,:);
    templw=lw_sw(ind,:);
    tempsst=sst_sw(ind,:);
    days=floor(mday_sw(noyear));
    unq_days=unique(days);
    jday=
    for count=1:length(unq_days)
%}

total = length(t);
for count = 1:total-1
    if rem(count,100) == 0,
        disp([num2str(count) ' of ' num2str(total)]) 
    end;
    wt27(count,:) = nanmean(wt27_sw(t(count)+1:t(count+1),:),1);
    wt15(count,:) = nanmean(wt15_sw(t(count)+1:t(count+1),:),1);
    lw(count,:) = nanmean(lw_sw(t(count)+1:t(count+1),:),1);
    swimm_sst(count,:) = nanmean(sst_sw(t(count)+1:t(count+1),:),1);
    mday(count,:) = nanmean(mday_sw(t(count)+1:t(count+1),:),1);
    jd(count,:) = nanmean(jd_sw(t(count)+1:t(count+1),:),1);
end;
count = count + 1;
wt27(count,:) = mean(wt27_sw(t(count)+1:end,:),1);
wt15(count,:) = mean(wt15_sw(t(count)+1:end,:),1);
lw(count,:) = mean(lw_sw(t(count)+1:end,:),1);
swimm_sst(count,:) = mean(sst_sw(t(count)+1:end,:),1);
mday(count,:) = mean(mday_sw(t(count)+1:end,:),1);
jd(count,:) = mean(jd_sw(t(count)+1:end,:),1);

save dailyswimm_temp wt27 lw mday_sw ht27_sw ht15_sw README_sw jd_sw sst_sw

