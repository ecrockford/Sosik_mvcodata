
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

%surface only
surface = CHNtable(CHNtable.depth < 5,:);
avg_surf_ratio = nanmean(surface.C_to_N_molar_ratio(surface.C_to_N_molar_ratio <20));
surface.anomaly_ratio = surface.C_to_N_molar_ratio - avg_surf_ratio;
%CARBON at surface by date
avg_surf_POCuM = nanmean(surface.POC_umolperL);
avg_surf_PONuM = nanmean(surface.PON_umolperL); 
if ~isfinite(avg_surf_PONuM) || ~isfinite(avg_surf_POCuM)
    error('Calculated avg of POC or PON is Inf. Check why. Could vol filt be incorrectly entered?')
end

avg_surf_POCugL = nanmean(surface.POC_ugperL); %(surface.C_to_N_molar_ratio <15));
avg_surf_PONugL = nanmean(surface.PON_ugperL); %(surface.C_to_N_molar_ratio <15));

%B4b is 2nd round of B4 that had to be estimated through averaging B4 & B5 because no true B4 analyzed for that batch of analysis
% indB4b = find(categorical(CHNtable.CHNBlank) == 'B4' & CHNtable.Date_Analyzed == 20151203);
% indB4b_surf = find(categorical(surface.CHNBlank) == 'B4' & surface.Date_Analyzed == 20151203);
ind_flag2 = find(CHNtable.C_quality_flag ==2 | CHNtable.N_quality_flag == 2);
ind_flag2_surf = find(surface.C_quality_flag ==2 | surface.N_quality_flag == 2);

%plot ratios per season
plot_limits = [0 20 0 100];
if max(CHNtable.POC_umolperL) > plot_limits(4) || max(CHNtable.PON_umolperL) > plot_limits(2), error('Max POC or PON outside of set plot limits. Check values'); end

figure
for count=1:4
subplot(2,2,count)
% plot(CHNtable.PON_umolperL(ismember(CHNtable.sample_month,season.(count))),CHNtable.POC_umolperL(ismember(CHNtable.sample_month,season.(count))),'b.','markersize',10)
grid on
hold on
%linear fit for this season. exclude Nans and suspicious flags of 2 or 3
n = fit(CHNtable.PON_umolperL(ismember(CHNtable.sample_month,season.(count)) & CHNtable.N_quality_flag ==1 & ~isnan(CHNtable.PON_umolperL)),CHNtable.POC_umolperL(ismember(CHNtable.sample_month,season.(count)) & CHNtable.N_quality_flag ==1 & ~isnan(CHNtable.PON_umolperL)), 'poly1');
plot(n,CHNtable.PON_umolperL(ismember(CHNtable.sample_month,season.(count)) & CHNtable.N_quality_flag ==1 & ~isnan(CHNtable.PON_umolperL)), CHNtable.POC_umolperL(ismember(CHNtable.sample_month,season.(count)) & CHNtable.N_quality_flag ==1 & ~isnan(CHNtable.PON_umolperL)))
%plot any bad or suspicious samples from this season
plot(CHNtable.PON_umolperL(ismember(CHNtable.sample_month,season.(count)) & CHNtable.N_quality_flag >1),CHNtable.POC_umolperL(ismember(CHNtable.sample_month,season.(count)) & CHNtable.N_quality_flag >1),'r*','markersize',8)
%auto line color is red but want that for flagged values so set to black
vars = get(gca,'children'); set(vars(2),'color','k'); set(vars(3),'markersize',10)
legend('all','linear fit','flag 2 or 3')
axis(plot_limits) %se above plot_limits set and error if a point outside of these limits that we won't see
txt = sprintf('y = %.2f * x + %.2f', n.p1, n.p2);
text(1, 95, txt, 'Color', 'k', 'FontSize', 10, 'FontWeight', 'Bold', 'HorizontalAlignment', 'left');
xlabel('PON - micromolar','FontWeight','bold'); ylabel('POC - micromolar','fontweight','bold');
title(['MVCO ' char(season_names(count))])
end

%{
color = 'kbrg';
figure
hold on
for count=1:4
% plot(CHNtable.PON_umolperL(ismember(CHNtable.sample_month,season.(count))),CHNtable.POC_umolperL(ismember(CHNtable.sample_month,season.(count))),'color',color(count),'marker','.','markersize',8,'LineStyle','none')
plot(CHNtable.PON_umolperL(ismember(CHNtable.sample_month,season.(count))),CHNtable.depth(ismember(CHNtable.sample_month,season.(count))),'color',color(count),'marker','.','markersize',8,'LineStyle','none')
xlabel('PON - micromolar','FontWeight','bold'); ylabel('POC - micromolar','fontweight','bold');
title('MVCO C:N ratio by season')
end
% plot(CHNtable.PON_umolperL(CHNtable.N_quality_flag >1),CHNtable.POC_umolperL(CHNtable.N_quality_flag >1),'r*','markersize',8)
plot(CHNtable.PON_umolperL(CHNtable.N_quality_flag >1),CHNtable.depth(CHNtable.N_quality_flag >1),'r*','markersize',8)
legend('winter','spring','summer','fall','flag 2 or 3')
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get indicies to plot replicates against each other
repb_ind = find(categorical(CHNtable.replicate) == 'b');
repa_ind = nan(length(repb_ind),1);
for count = 1:length(repb_ind)
    repa_ind(count) = find(categorical(CHNtable.replicate) == 'a' & categorical(CHNtable.event_number_niskin) == categorical(CHNtable.event_number_niskin(repb_ind(count))));
end
repb_flag = find(CHNtable.C_quality_flag(repb_ind) >1 | CHNtable.N_quality_flag(repb_ind) >1);
repa_flag = find(CHNtable.C_quality_flag(repa_ind) >1 | CHNtable.N_quality_flag(repa_ind) >1);

%get max values of POC, PON, and ratio for 1:1 line plotting
maxPOC = round(max([CHNtable.POC_umolperL(repa_ind); CHNtable.POC_umolperL(repb_ind)]) +1);
maxPON = round(max([CHNtable.PON_umolperL(repa_ind); CHNtable.PON_umolperL(repb_ind)]) +1);
maxratio = round(max([CHNtable.C_to_N_molar_ratio(repa_ind); CHNtable.C_to_N_molar_ratio(repb_ind)]) +1);

%%
%confirm rep_a is actually the replicate of rep_b
figure
plot(CHNtable.datetime(repa_ind),CHNtable.depth(repa_ind),'.')
hold on
datetick('x')
legend('rep a','rep b')
xlabel('Date'); ylabel('Depth'); title('MVCO CHN replicate samples time vs depth')

%%
%compare replicates for POC, PON, and molar ratio
%includ 1:1 line
figure
subplot 131
hold on; grid on
line([0 maxPOC],[0 maxPOC],'color','k','linewidth',1)
plot(CHNtable.POC_umolperL(repa_ind),CHNtable.POC_umolperL(repb_ind),'b.','MarkerSize',12)
plot(CHNtable.POC_umolperL(repa_ind(repa_flag)),CHNtable.POC_umolperL(repb_ind(repa_flag)),'ro')
plot(CHNtable.POC_umolperL(repa_ind(repb_flag)),CHNtable.POC_umolperL(repb_ind(repb_flag)),'ro')
xlabel('POC rep A','FontWeight','bold'); ylabel('POC rep B','FontWeight','bold'); title('Carbon - MVCO POC (umol/L)')
axis square
subplot 132
hold on; grid on
line([0 maxPON],[0 maxPON],'color','k','linewidth',1)
plot(CHNtable.PON_umolperL(repa_ind),CHNtable.PON_umolperL(repb_ind),'b^','MarkerFaceColor','b','markersize',4)
plot(CHNtable.PON_umolperL(repa_ind(repa_flag)),CHNtable.PON_umolperL(repb_ind(repa_flag)),'ro','MarkerSize',8)
plot(CHNtable.PON_umolperL(repa_ind(repb_flag)),CHNtable.PON_umolperL(repb_ind(repb_flag)),'ro','MarkerSize',8)
xlabel('PON rep A','FontWeight','bold'); ylabel('PON rep B','FontWeight','bold'); title('Nitrogen - MVCO PON (umol/L)')
axis square
subplot 133
hold on; grid on
line([0 maxratio],[0 maxratio],'color','k','linewidth',1)
plot(CHNtable.C_to_N_molar_ratio(repa_ind),CHNtable.C_to_N_molar_ratio(repb_ind),'bsquare','MarkerSize',5,'markerfacecolor','b')
plot(CHNtable.C_to_N_molar_ratio(repa_ind(repa_flag)),CHNtable.C_to_N_molar_ratio(repb_ind(repa_flag)),'ro','MarkerSize',8)
plot(CHNtable.C_to_N_molar_ratio(repa_ind(repb_flag)),CHNtable.C_to_N_molar_ratio(repb_ind(repb_flag)),'ro','MarkerSize',8)
xlabel('C:N ratio rep A','FontWeight','bold'); ylabel('C:N ratio rep B','FontWeight','bold'); title('MVCO POC:PON molar ratio')
axis square

%% PERCENT RANGE
%
a = range([CHNtable.POC_umolperL(repa_ind) CHNtable.POC_umolperL(repb_ind)],2)./nanmean([CHNtable.POC_umolperL(repa_ind) CHNtable.POC_umolperL(repb_ind)],2)*100;  %case for whole water
b = range([CHNtable.PON_umolperL(repa_ind) CHNtable.PON_umolperL(repb_ind)],2)./nanmean([CHNtable.PON_umolperL(repa_ind) CHNtable.PON_umolperL(repb_ind)],2)*100;  %case for whole water
c = range([CHNtable.C_to_N_molar_ratio(repa_ind) CHNtable.C_to_N_molar_ratio(repb_ind)],2)./nanmean([CHNtable.C_to_N_molar_ratio(repa_ind) CHNtable.C_to_N_molar_ratio(repb_ind)],2)*100;  %case for whole water
names = ["POC_umolperL";"PON_umolperL";"C_to_N_molar_ratio"];
percent_range = table(a, b, c,'VariableNames',names);
clear a b c names

figure('name','Histo CHN Replicate range/mean (%)')
subplot 131
hist(percent_range.POC_umolperL, [0:5:max(percent_range.POC_umolperL)]) 
ylabel('# of events'), xlabel('Replicate range / mean (%)'), title('MVCO POC')
subplot 132
hist(percent_range.PON_umolperL, [0:5:max(percent_range.PON_umolperL)]) 
ylabel('# of events'), xlabel('Replicate range / mean (%)'), title('MVCO PON')
subplot 133
hist(percent_range.C_to_N_molar_ratio, [0:5:max(percent_range.C_to_N_molar_ratio)]) 
ylabel('# of events'), xlabel('Replicate range / mean (%)'), title('MVCO C:N ratio')

figure('name','CHN Replicate range/mean (%) over time')
subplot 311
plot(CHNtable.datetime(repa_ind),percent_range.POC_umolperL,'.-')
hold on
plot(CHNtable.datetime(repa_ind(repa_flag)),percent_range.POC_umolperL(repa_flag),'ro')
plot(CHNtable.datetime(repb_ind(repb_flag)),percent_range.POC_umolperL(repb_flag),'ro')
xlabel('Date'); datetick('x'); ylabel('Replicate range / mean (%)'); title('MVCO POC % range')
legend('all replicates','flag 2 or 3')
subplot 312
plot(CHNtable.datetime(repa_ind),percent_range.PON_umolperL,'.-')
hold on
plot(CHNtable.datetime(repa_ind(repa_flag)),percent_range.PON_umolperL(repa_flag),'ro')
plot(CHNtable.datetime(repb_ind(repb_flag)),percent_range.PON_umolperL(repb_flag),'ro')
xlabel('Date'); datetick('x'); ylabel('Replicate range / mean (%)'); title('MVCO PON % range')
legend('all replicates','flag 2 or 3')
subplot 313
plot(CHNtable.datetime(repa_ind),percent_range.C_to_N_molar_ratio,'.-')
hold on
plot(CHNtable.datetime(repa_ind(repa_flag)),percent_range.C_to_N_molar_ratio(repa_flag),'ro')
plot(CHNtable.datetime(repb_ind(repb_flag)),percent_range.C_to_N_molar_ratio(repb_flag),'ro')
xlabel('Date'); datetick('x'); ylabel('Replicate range / mean (%)'); title('MVCO C:N ratio % range')
legend('all replicates','flag 2 or 3')

badind = find(percent_range.POC_umolperL > 20); %Taylor arbitrarily chose 20% for now
var2useA = {'event_number_niskin','datetime','depth','CHN_sample_ID','POC_umolperL','PON_umolperL','C_to_N_molar_ratio','C_quality_flag','N_quality_flag'};
var2useB = {'CHN_sample_ID','POC_umolperL','PON_umolperL','C_to_N_molar_ratio','C_quality_flag','N_quality_flag'};
questionableC = CHNtable(repa_ind(badind),var2useA);
questionableC = renamevars(questionableC,var2useA(4:end),["ID#_repA","POC_repA","PON_repA","ratio_repA","Cflag_repA","Nflag_repA"]);
questionableC  = [questionableC CHNtable(repb_ind(badind),var2useB)];
questionableC = renamevars(questionableC,var2useB,["ID#_repB","POC_repB","PON_repB","ratio_repB","Cflag_repB","Nflag_repB"]);
questionableC.POC_percentrange = round(percent_range.POC_umolperL(badind));
var2order = ["event_number_niskin","POC_percentrange","depth","ID#_repA","ID#_repB","POC_repA","POC_repB","Cflag_repA","Cflag_repB","ratio_repA","ratio_repB","PON_repA","PON_repB","Nflag_repA","Nflag_repB","datetime"];
disp('events with high range for POC replicates')
questionableC = questionableC(:,var2order)

badind = find(percent_range.PON_umolperL > 20); %Taylor arbitrarily chose 20% for now
questionableN = CHNtable(repa_ind(badind),var2useA);
questionableN = renamevars(questionableN,var2useA(4:end),["ID#_repA","POC_repA","PON_repA","ratio_repA","Cflag_repA","Nflag_repA"]);
questionableN  = [questionableN CHNtable(repb_ind(badind),var2useB)];
questionableN = renamevars(questionableN,var2useB,["ID#_repB","POC_repB","PON_repB","ratio_repB","Cflag_repB","Nflag_repB"]);
questionableN.PON_percentrange = round(percent_range.PON_umolperL(badind));
var2order = ["event_number_niskin","PON_percentrange","depth","ID#_repA","ID#_repB","PON_repA","PON_repB","Nflag_repA","Nflag_repB","ratio_repA","ratio_repB","POC_repA","POC_repB","Cflag_repA","Cflag_repB","datetime"];
disp('events with high range for PON replicates')
questionableN = questionableN(:,var2order)

badind = find(percent_range.C_to_N_molar_ratio > 20); %Taylor arbitrarily chose 20% for now
questionableN = CHNtable(repa_ind(badind),var2useA);
questionableN = renamevars(questionableN,var2useA(4:end),["ID#_repA","POC_repA","PON_repA","ratio_repA","Cflag_repA","Nflag_repA"]);
questionableN  = [questionableN CHNtable(repb_ind(badind),var2useB)];
questionableN = renamevars(questionableN,var2useB,["ID#_repB","POC_repB","PON_repB","ratio_repB","Cflag_repB","Nflag_repB"]);
questionableN.C_to_N_molar_ratio = round(percent_range.C_to_N_molar_ratio(badind));
var2order = ["event_number_niskin","C_to_N_molar_ratio","depth","ID#_repA","ID#_repB","ratio_repA","ratio_repB","POC_repA","POC_repB","PON_repA","PON_repB","Cflag_repA","Cflag_repB","Nflag_repA","Nflag_repB","datetime"];
disp('events with high range for c:N RATIO of replicates')
questionableN = questionableN(:,var2order)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%RATIO all points by sample count
figure
plot(CHNtable.C_to_N_molar_ratio,'.-','MarkerSize',12)
hold on
% plot(indB4b,CHNtable.C_to_N_molar_ratio(indB4b),'go','markersize',10)
plot(ind_flag2,CHNtable.C_to_N_molar_ratio(ind_flag2),'r*','markersize',10)
line([0 size(CHNtable,1)],[avg_ratio avg_ratio],'color','k','linestyle','--','linewidth',2)
ylim([0 20])
grid on
xlabel('Sample Count','FontWeight','bold');
ylabel('Molar Ratio C:N','FontWeight','bold');
title('MVCO all POC : PON ratio by sample count')
% legend('all','B4b avg B4a & B5','flag2','location','best')

%RATIO at surface by sample count
figure
plot(surface.C_to_N_molar_ratio,'.-','MarkerSize',12)
hold on
% plot(indB4b_surf,surface.C_to_N_molar_ratio(indB4b_surf),'go','markersize',10)
plot(ind_flag2_surf,surface.C_to_N_molar_ratio(ind_flag2_surf),'r*','markersize',10)
line([0 size(surface,1)],[avg_surf_ratio avg_surf_ratio],'color','k','linestyle','--','linewidth',2)
ylim([0 20])
grid on
xlabel('Sample Count','FontWeight','bold');
ylabel('Molar Ratio C:N','FontWeight','bold');
title('Surface MVCO POC : PON ratio by sample count')
% legend('all','B4b avg B4a & B5','flag2','mean ratio','location','best')

%RATIO at surface by date
figure
plot(surface.datetime,surface.C_to_N_molar_ratio,'-.','MarkerSize',12)
hold on
% plot(surface.datetime(indB4b_surf),surface.C_to_N_molar_ratio(indB4b_surf),'go','markersize',10)
plot(surface.datetime(ind_flag2_surf),surface.C_to_N_molar_ratio(ind_flag2_surf),'r*','markersize',10)
line([min(surface.datetime) max(surface.datetime)],[avg_surf_ratio avg_surf_ratio],'color','k','linestyle','--','linewidth',2)
ylim([0 15]); grid on
xlabel('Date','FontWeight','bold'); datetick('x');
ylabel('Molar Ratio C:N','FontWeight','bold'); title('Surface MVCO POC : PON ratio over time');
legend('all','mean ratio','location','best') %legend('all','B4b avg B4a & B5','mean ratio','location','best')


figure
subplot(3,1,1);
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

subplot(3,1,2);
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

subplot(3,1,3);
plot(surface.datetime,surface.C_to_N_molar_ratio,'.','MarkerSize',12)
hold on
% plot(surface.datetime(indB4b_surf),surface.C_to_N_molar_ratio(indB4b_surf),'go','markersize',10)
plot(surface.datetime(ind_flag2_surf),surface.C_to_N_molar_ratio(ind_flag2_surf),'r*','markersize',10)
line([min(surface.datetime) max(surface.datetime)],[avg_surf_ratio avg_surf_ratio],'color','k','linestyle','--','linewidth',2)
xlabel('Date','FontWeight','bold'); datetick('x')
ylabel('Molar Ratio C:N','FontWeight','bold'); title('MVCO Surface POC : PON ratio over time')
ylim([5 15]); grid on;
legend('all','mean ratio','location','best')
% legend('all','B4b avg B4a & B5','flag2','mean ratio','location','best')
%     set(gcf, 'position', [488 41.8 560 740.8])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%for QC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot(CHNtable.PON_umolperL,CHNtable.POC_umolperL,'.','markersize',10)
grid on
hold on
ind = find(CHNtable.N_quality_flag == 2);
plot(CHNtable.PON_umolperL(ind),CHNtable.POC_umolperL(ind),'r*','markersize',10)
ind = find(CHNtable.C_quality_flag == 2);
plot(CHNtable.PON_umolperL(ind),CHNtable.POC_umolperL(ind),'ro','markersize',10)
ind = find(~isnan(CHNtable.PON_umolperL) & CHNtable.N_quality_flag ==1);
n = fit(CHNtable.PON_umolperL(ind),CHNtable.POC_umolperL(ind), 'poly1');
plot(n,CHNtable.PON_umolperL, CHNtable.POC_umolperL)
xlabel('PON - micromolar','FontWeight','bold');
ylabel('POC - micromolar','fontweight','bold')
title('PON : POC - MVCO all samples - all depths')


indc = find(CHNtable.PON_umolperL == 0.01 & CHNtable.POC_umolperL >5);

%by depth
figure
subplot 121
plot(CHNtable.POC_umolperL,CHNtable.depth,'.','markersize',12)
hold on
plot(CHNtable.POC_umolperL(ind_flag2),CHNtable.depth(ind_flag2),'r*','markersize',10)
plot(CHNtable.POC_umolperL(indc),CHNtable.depth(indc),'ro','markersize',10,'MarkerFaceColor','c')
set(gca, 'YDir','reverse')
title(' POC - all')
xlabel('POC - micromolar','fontweight','bold')
ylabel('Depth (m)','fontweight','bold')
grid on
subplot 122
plot(CHNtable.PON_umolperL,CHNtable.depth,'.','markersize',12)
hold on
plot(CHNtable.PON_umolperL(ind_flag2),CHNtable.depth(ind_flag2),'r*','markersize',10)
plot(CHNtable.PON_umolperL(indc),CHNtable.depth(indc),'co','markersize',10,'MarkerFaceColor','c')
set(gca, 'YDir','reverse')
grid on
legend('all','flag2','suspect N BDL & C>5','location','best')
xlabel('PON - micromolar','fontweight','bold')
ylabel('Depth (m)','fontweight','bold')
title('MVCO PON - all')
