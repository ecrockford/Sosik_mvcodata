%create matrix of matdate (extracted from seabass filename) and ad,
%ap,ag,aph values; including the full spectrum and indices at 440,675


load mvco_specdb.mat

filelist = strvcat(filelist.name);
dates = filelist(:,6:13);
% Y = (dates(:,1:4)); M = (dates(:,5:6)); D = (dates(:,7:8));
% Y = str2num(Y);M = str2num(M);D = str2num(D);
str = num2str(dates)
specdate = datenum(str,'yyyymmdd')

ind400 = find(wavelength==400)
ind440 = find(wavelength==440)
ind675 = find(wavelength==675)

% find missing data replace -9999 with NaN
ad(find(ad<-999)) = NaN;
ag(find(ag<-999)) = NaN;
aph(find(aph<-999)) = NaN;
ap(find(ap<-999)) = NaN;



load C:/data/mvcodata/all_chlavg.mat 
%array are; all_chlavg chldepth matdate chlsample
%match all_chlavg data with spec data by matching the dates

[num,txt] = xlsread('C:/data/mvcodata/aph440_chl_match.xls')
allchl = num(:,4);
chl_10 = num(:,5);
chl_80 = num(:,6);
aph440 = num(:,1);
z = num(:,8);


figure
subplot(3,2,1)
plot(specdate,ad(ind440),'.-')
datetick('x','mmmyy')
ylabel('absorption (m^{-1})')
title('ad_{440}')
ylim=([min(ad(ind440)) max(ad(ind440))])
% title('a_{CDOM} at 440')

subplot(3,2,2)
plot(specdate,aph(ind440),'.-')
datetick('x','mmmyy')
ylabel('absorption (m^{-1})')
ylim=([min(aph(ind440)) max(aph(ind440))])
title('aph_{440}')


subplot(3,2,3)
aph440 = aph(ind440);
aph675 = aph(ind675);
plot(specdate,aph440./aph675,'.-')
ylim=([min(aph440./aph675) max(aph440./aph675)])
datetick('x','mmmyy')
ylabel('aph_{440}/aph_{675}')


subplot(3,2,4)
plot(specdate,aph440./allchl(1:51),'.-')
ylim=([min(aph440./allchl(1:51)) max(aph440./allchl(1:51))])
% hold on
% plot(specdate,aph440./chl_10(1:51),'r.-')
% plot(specdate,aph440./chl_80(1:51),'k.-')
datetick('x','mmmyy')
ylabel('aph_{440}/chl')
ylim = ([0 0.15])
legend('allchl','<10','<80')

subplot(3,2,5)
plot(matdate(chldepth<4 & chlsample==0),all_chlavg(chldepth<4 & chlsample==0),'.-')
datetick('x','mmmyy')
ylabel('surface chl')

subplot(3,2,6)
plot(specdate,ag(ind440),'.-')
ylim = ([min(ag(ind440)) max(ag(ind440))])
datetick('x','mmmyy')
ylabel('acdom_{440}')

load S_acdom440_values.mat %this load mat file that was generated after running curvefit.m
%arrays are all_acdom440 all_acdom675 all_cdom_S dates
Y = str2num(dates(:,1:4));
M = str2num(dates(:,5:6));
D = str2num(dates(:,7:8));
cdomdates = datenum(Y,M,D);

figure
subplot(2,1,1)
[AX,H1,H2] = plotyy(matdate,all_chlavg,cdomdates,sem_S)

set(get(AX(1),'Ylabel'),'String','all chlavg','visible','off')
set(get(AX(2),'Ylabel'),'String','slope SEM_S','visible','off')

subplot(2,1,2)
[AX,H1,H2] = plotyy(matdate,all_chlavg,cdomdates,hm_S)

set(get(AX(1),'Ylabel'),'String','all chlavg','visible','off','LineStyle','-')
set(get(AX(2),'Ylabel'),'String','slope hm_S','visible','off','LineStyle','-')

% % % plot(dates,all_acdom440,'.')
% % % datetick('x','mmmyy')
% % % ylabel('acdom_{440}')







