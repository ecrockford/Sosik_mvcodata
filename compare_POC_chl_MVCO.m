%Taylor 2/10/2023
% compare POC to chl



%%%%%%%%%%%%%%% CHL %%%%%%%%%%%%%%%%%%%%%%
load \\sosiknas1\Lab_data\MVCO\mvcodata\matlab_files\chl_data_reps.mat
header_chl=cellstr(header_chl);
chltable = cell2table(MVCO_chl_reps,"VariableNames",header_chl); %original MVCO code makes cell array from MS Access. Conver to table
chltable = renamevars(chltable,["Chl_a_Chl (ug/l)","Chl_b_Chl (ug/l)","Chl_c_Chl (ug/l)","Chl_a_Phaeo (ug/l)","Chl_b_Phaeo (ug/l)","Chl_10a_Chl (ug/l)","Chl_10b_Chl (ug/l)","Chl_a_quality_flag","Chl_b_quality_flag","Chl_c_quality_flag","Chl_10a_quality_flag","Chl_10b_quality_flag"], ...
    ["chl_repa","chl_repb","chl_repc","phaeo_repa","phaeo_repb","chl10_repa","chl10_repb","repa_quality_flag","repb_quality_flag","repc_quality_flag","rep10a_quality_flag","rep10b_quality_flag"]);
% chltable = chltable(chltable.FilterSize==0,:); %only want to compare WSW - not size fractions
%get rid of flag 3(bad) samples 
chltable.("chl_repa")(chltable.repa_quality_flag == 3) = NaN;
% also do phaeo? need to fix varname % chltable.("repa")(chltable.repa_quality_flag == 3) = NaN;
chltable.("chl_repb")(chltable.repb_quality_flag == 3) = NaN;
% also do phaeo? need to fix varname % chltable.fl_phaeo(chltable.chl_flag == 3) = NaN;

%%%%%%%%%%%%%%%%%%%% CHN %%%%%%%%%%%%%%%%%
%load POC and PON. have propper lat/lon/depth from API
% p = 'C:\work\LTER\POC\';
p = '\\sosiknas1\Lab_data\MVCO\mvcodata\matlab_files\';
load([p 'MVCO_CHN_calculated_table']);
%rename vars just for same LTER code to work on this
CHNtable = renamevars(CHNtable,["matdate","datetime"],["datetime","date_time_utc"]);
%Set BDL to 0.01 for plotting and arithmetic purposes
CHNtable.PON_umolperL(CHNtable.PON_umolperL == 0) = 0.01;
avg_ratio = nanmean(CHNtable.C_to_N_molar_ratio(CHNtable.C_to_N_molar_ratio <20)); % exlude any likely eroneous values
CHNtable.anomaly_ratio = CHNtable.C_to_N_molar_ratio - avg_ratio;

season_names = ["Winter";"Spring";"Summer";"Fall"];
season = table([1 2 12]', [3:5]', [6:8]', [9:11]','VariableNames',season_names);
[y,m,d] = datevec(CHNtable.datetime);
CHNtable.sample_year = y;
CHNtable.sample_month = m;
CHNtable.yearday = round(CHNtable.datetime-datenum(y,1,0));
clear y m d

chn_var2use = {'event_number','event_number_niskin','datetime','sample_year','sample_month','yearday','latitude','longitude','depth','CHN_sample_ID','replicate','POC_umolperL','PON_umolperL','POC_ugperL','PON_ugperL','C_to_N_molar_ratio','anomaly_ratio','CHNBlank','blank_estimated','C_quality_flag','N_quality_flag'};
% this was using excel doc and not compiled .mat file %chl_var2use={'LTERStation','chl_rep','FilterSize','DilutionDuringReading','Chl_Cal_Filename','fl_chl','fl_phaeo','Cal_Date','labNB','chl_flag','QC_d','chl_comments','chl_comments2'};
chl_var4match = ["chl_repa","chl_repb","phaeo_repa","phaeo_repb","repa_quality_flag","repb_quality_flag"];

% THIS DOESN'T WORK BECAUSE NOT FROM SAME NISKIN
matchup = [];
for count = 1:size(CHNtable,1)
    chl_ind = find(categorical(chltable.Event_Number_Niskin) == CHNtable.event_number_niskin(count));
    if ~isempty(chl_ind)
    avg_chl = nanmean([chltable.chl_repa(chl_ind) chltable.chl_repb(chl_ind)]);
    avg_phaeo = nanmean([chltable.phaeo_repa(chl_ind) chltable.phaeo_repb(chl_ind)]);
    avg_flag = nanmean([chltable.repa_quality_flag(chl_ind) chltable.repb_quality_flag(chl_ind)]);
    chltemp = table(avg_chl,avg_phaeo,avg_flag);
    temp = [CHNtable(count,chn_var2use) chltable(chl_ind,chl_var4match) chltemp];
    matchup = [matchup; temp];
    end
    clear chl_ind *temp avg*
end
clear count

figure
plot(matchup.datetime,matchup.POC_ugperL./matchup.avg_chl,'.','MarkerSize',12)
hold on
%%%%%set(gca,'xticks',[min(CHNtable.sample_year) max(CHNtable.sample_year)+1])
datetick('x')
xlabel('Date','Fontweight','bold'); ylabel('ratio  POC(ugperL) : chl (ugperL)','Fontweight','bold');
title('MVCO ALL POC(ugperL) : chl (ugperL) ratio')
grid on


surface = matchup(matchup.depth < 6,:);

figure
plot(surface.datetime,surface.POC_ugperL./surface.avg_chl,'.','MarkerSize',12))
hold on
indB11 = find(categorical(surface.CHNBlank) == 'B11');
plot(surface.datetime(indB11),surface.POC_ugperL(indB11)./surface.avg_chl(indB11),'gx')
indB13 = find(categorical(surface.CHNBlank) == 'B13');
plot(surface.datetime(indB13),surface.POC_ugperL(indB13)./surface.avg_chl(indB13),'rx')
legend('all',['B11=' num2str(surface.blankC(indB11(1)))],['B13=' num2str(surface.blankC(indB13(1)))],'location','best')
xlabel('Date','Fontweight','bold'); ylabel('ratio POC(ugperL) : chl (ugperL)','Fontweight','bold');
title('SURFACE ratio  POC(ugperL) : chl (ugperL)')
grid on

figure
subplot(4,1,1);
plot(surface.datetime,surface.POC_ugperL,'.','MarkerSize',12)
hold on
% plot(surface.datetime(indB4b_surf),surface.POC_umolperL(indB4b_surf),'go','markersize',10)
plot(surface.datetime(ind_flag2_surf),surface.POC_ugperL(ind_flag2_surf),'r*','markersize',10)
line([min(surface.datetime) max(surface.datetime)],[avg_surf_POCugL avg_surf_POCugL],'color','k','linestyle','--','linewidth',1)
ylim([0 700])
xlabel('Date','FontWeight','bold'); datetick('x');
ylabel('POC (ug/L)','FontWeight','bold'); title('MVCO Surface POC (uM) over time');
grid on;
legend('all','flag2','mean POC','location','best')
% legend('all','B4b avg B4a & B5','flag2','mean POC','location','best')

subplot(4,1,2);
plot(surface.datetime,surface.PON_ugperL,'.','MarkerSize',12)
hold on
% plot(surface.datetime(indB4b_surf),surface.PON_umolperL(indB4b_surf),'go','markersize',10)
plot(surface.datetime(ind_flag2_surf),surface.PON_ugperL(ind_flag2_surf),'r*','markersize',10)
line([min(surface.datetime) max(surface.datetime)],[avg_surf_PONugL avg_surf_PONugL],'color','k','linestyle','--','linewidth',2)
ylim([0 100])
xlabel('Date','FontWeight','bold'); datetick('x');
ylabel('PON (ug/L)','FontWeight','bold'); title('MVCO Surface PON(ug/L) over time');
grid on;
legend('all','mean PON','location','best') %legend('all','B4b avg B4a & B5','flag2','mean PON','location','best')

subplot(4,1,3);
plot(surface.datetime,surface.C_to_N_molar_ratio,'.','MarkerSize',12)
hold on
% plot(surface.datetime(indB4b_surf),surface.C_to_N_molar_ratio(indB4b_surf),'go','markersize',10)
plot(surface.datetime(ind_flag2_surf),surface.C_to_N_molar_ratio(ind_flag2_surf),'r*','markersize',10)
line([min(surface.datetime) max(surface.datetime)],[avg_surf_ratio avg_surf_ratio],'color','k','linestyle','--','linewidth',2)
xlabel('Date','FontWeight','bold'); datetick('x')
ylabel('Molar Ratio C:N','FontWeight','bold'); title('MVCO Surface POC : PON ratio over time')
ylim([5 15]); grid on;
legend('all','mean ratio','location','best')

subplot(4,1,4);
plot(surface.datetime,surface.POC_ugperL./surface.avg_chl,'.','MarkerSize',12))
hold on
% indB11 = find(categorical(surface.CHNBlank) == 'B11');
% plot(surface.datetime(indB11),surface.POC_ugperL(indB11)./surface.avg_chl(indB11),'gx')
% indB13 = find(categorical(surface.CHNBlank) == 'B13');
% plot(surface.datetime(indB13),surface.POC_ugperL(indB13)./surface.avg_chl(indB13),'rx')
% legend('all',['B11=' num2str(surface.blankC(indB11(1)))],['B13=' num2str(surface.blankC(indB13(1)))],'location','best')
xlabel('Date','Fontweight','bold'); ylabel('ratio POC(ugperL) : chl (ugperL)','Fontweight','bold');
title('SURFACE ratio  POC(ugperL) : chl (ugperL)')
grid on


figure
plot(surface.latitude,surface.POC_ugperL./surface.avg_chl,'.','MarkerSize',12))
hold on
indB11 = find(categorical(surface.CHNBlank) == 'B11');
plot(surface.latitude(indB11),surface.POC_ugperL(indB11)./surface.avg_chl(indB11),'gx')
indB13 = find(categorical(surface.CHNBlank) == 'B13');
plot(surface.latitude(indB13),surface.POC_ugperL(indB13)./surface.avg_chl(indB13),'rx')
legend('all',['B11=' num2str(surface.blankC(indB11(1)))],['B13=' num2str(surface.blankC(indB13(1)))],'location','best')
xlim([39.70 41.2])
xlabel('Latitude','Fontweight','bold'); ylabel('ratio POC(ugperL) : chl (ugperL)','Fontweight','bold');
title('SURFACE ratio  POC(ugperL) : chl (ugperL)')
grid on







