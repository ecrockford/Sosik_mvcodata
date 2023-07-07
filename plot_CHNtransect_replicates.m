% p = 'C:\work\LTER\POC\';
p = '\\sosiknas1\Lab_data\LTER\CHN\';
load([p 'NESLTER_CHN_table'])

ind = find(CHNtable.PON_umolperL == 0);
CHNtable.PON_umolperL(ind) = 0.01;
clear ind

repb_ind = find(categorical(CHNtable.replicate) == 'b');
repa_ind = nan(length(repb_ind),1);
for count = 1:length(repb_ind)
    repa_ind(count) = find(categorical(CHNtable.replicate) == 'a' & categorical(CHNtable.cruise) == CHNtable.cruise(repb_ind(count)) & CHNtable.cast == CHNtable.cast(repb_ind(count)) & CHNtable.niskin == CHNtable.niskin(repb_ind(count)));
end
var2useA = {'cruise','cast','niskin','datetime','latitude','longitude','depth','CHN_sample_ID','POC_umolperL','PON_umolperL','C_to_N_molar_ratio','C_quality_flag','N_quality_flag'};
var2useB = {'CHN_sample_ID','POC_umolperL','PON_umolperL','C_to_N_molar_ratio','C_quality_flag','N_quality_flag'};
CHNreplicates = CHNtable(repa_ind,var2useA);
CHNreplicates = renamevars(CHNreplicates,var2useA(8:end),["ID#_repA","POC_repA","PON_repA","ratio_repA","Cflag_repA","Nflag_repA"]);
CHNreplicates  = [CHNreplicates CHNtable(repb_ind,var2useB)];
CHNreplicates = renamevars(CHNreplicates,var2useB,["ID#_repB","POC_repB","PON_repB","ratio_repB","Cflag_repB","Nflag_repB"]);
var2order = ["cruise","cast","niskin","datetime","latitude","longitude","depth","ID#_repA","ID#_repB","POC_repA","POC_repB","PON_repA","Cflag_repA","ratio_repA","ratio_repB","Cflag_repB","PON_repB","Nflag_repA","Nflag_repB","datetime"];
CHNreplicates = CHNreplicates(:,var2order);
CHNreplicates.POC_percentrange = range([CHNreplicates.POC_repA CHNreplicates.POC_repB],2)./nanmean([CHNreplicates.POC_repA CHNreplicates.POC_repB],2)*100;
CHNreplicates.PON_percentrange = range([CHNreplicates.PON_repA CHNreplicates.PON_repB],2)./nanmean([CHNreplicates.PON_repA CHNreplicates.PON_repB],2)*100;
CHNreplicates.ratio_percentrange = range([CHNreplicates.ratio_repA CHNreplicates.ratio_repB],2)./nanmean([CHNreplicates.ratio_repA CHNreplicates.ratio_repB],2)*100;

%%%%%%%%%%%%%%
figure('name','Histo CHN Replicate range/mean (%)')
subplot 131
hist(CHNreplicates.POC_percentrange, [0:5:max(CHNreplicates.POC_percentrange)]) 
ylabel('# of events'), xlabel('Replicate range / mean (%)'), title('NESLTER transect POC')
subplot 132
hist(CHNreplicates.PON_percentrange, [0:5:max(CHNreplicates.PON_percentrange)]) 
ylabel('# of events'), xlabel('Replicate range / mean (%)'), title('NESLTER transect PON')
subplot 133
hist(CHNreplicates.ratio_percentrange, [0:5:max(CHNreplicates.ratio_percentrange)]) 
ylabel('# of events'), xlabel('Replicate range / mean (%)'), title('MVCO C:N ratio')

%%%%%%%%%%%%%%
figure('name','CHN Replicate range/mean (%) over time')
subplot 311
plot(CHNreplicates.datetime,CHNreplicates.POC_percentrange,'.-','markersize',10); grid on
xlabel('Date','FontWeight','bold'); ylabel('POC replicate percent range','FontWeight','bold'); title('LTER POC replicate percent range')
subplot 312
plot(CHNreplicates.datetime,CHNreplicates.PON_percentrange,'.-','markersize',10); grid on
xlabel('Date','FontWeight','bold'); ylabel('PON replicate percent range','FontWeight','bold'); title('LTER PON replicate percent range')
subplot 313
plot(CHNreplicates.datetime,CHNreplicates.ratio_percentrange,'.-','markersize',10); grid on
xlabel('Date','FontWeight','bold'); ylabel('C:N ratio replicate percent range','FontWeight','bold'); title('LTER C:N ratio replicate percent range')

%compare replicates for POC, PON, and molar ratio
%includ 1:1 line

maxPOC = round(max([CHNreplicates.POC_repA; CHNreplicates.POC_repB]) +1);
maxPON = round(max([CHNreplicates.PON_repA; CHNreplicates.PON_repB]) +1);
maxratio = round(max([CHNreplicates.ratio_repA; CHNreplicates.ratio_repB]) +1);

figure('name','NESLTER CHN Replicate 1:1 compare')
subplot 131
flag2ind = find(CHNreplicates.Cflag_repA == 2 | CHNreplicates.Cflag_repB == 2);
flag3ind = find(CHNreplicates.Cflag_repA == 3 | CHNreplicates.Cflag_repB == 3);
hold on; grid on
line([0 maxPOC],[0 maxPOC],'color','k','linewidth',1)
plot(CHNreplicates.POC_repA,CHNreplicates.POC_repB,'b.','MarkerSize',12)
plot(CHNreplicates.POC_repA(flag2ind),CHNreplicates.POC_repB(flag2ind),'g^','MarkerSize',6,'MarkerFaceColor','g')
% plot(CHNreplicates.POC_repA(flag3ind),CHNreplicates.POC_repB(flag3ind),'r*') %doesn't work because turn flag3 to nan
xlabel('POC rep A','FontWeight','bold'); ylabel('POC rep B','FontWeight','bold'); title('Carbon - NESLTER POC (umol/L)')
axis square
legend('1:1 line','all','C suspicious','Location','best')
subplot 132
flag2ind = find(CHNreplicates.Nflag_repA == 2 | CHNreplicates.Nflag_repB == 2);
flag3ind = find(CHNreplicates.Nflag_repA == 3 | CHNreplicates.Nflag_repB == 3);
hold on; grid on
line([0 maxPON],[0 maxPON],'color','k','linewidth',1)
plot(CHNreplicates.PON_repA,CHNreplicates.PON_repB,'b^','MarkerFaceColor','b','markersize',4)
plot(CHNreplicates.PON_repA(flag2ind),CHNreplicates.PON_repB(flag2ind),'g^','MarkerSize',6,'MarkerFaceColor','g')
% plot(CHNreplicates.PON_repA(flag3ind),CHNreplicates.PON_repB(flag3ind),'r*') %doesn't work because turn flag3 to nan
xlabel('PON rep A','FontWeight','bold'); ylabel('PON rep B','FontWeight','bold'); title('Nitrogen - NESLTER PON (umol/L)')
axis square
legend('1:1 line','all','N suspicious','Location','best')
subplot 133
flag2ind = find(CHNreplicates.Cflag_repA == 2 | CHNreplicates.Cflag_repB == 2 | CHNreplicates.Nflag_repA == 2 | CHNreplicates.Nflag_repB == 2);
flag3ind = find(CHNreplicates.Cflag_repA == 3 | CHNreplicates.Cflag_repB == 3 | CHNreplicates.Nflag_repA == 3 | CHNreplicates.Nflag_repB == 3);
hold on; grid on
line([0 maxratio],[0 maxratio],'color','k','linewidth',1)
plot(CHNreplicates.ratio_repA,CHNreplicates.ratio_repB,'bsquare','MarkerSize',5,'markerfacecolor','b')
plot(CHNreplicates.ratio_repA(flag2ind),CHNreplicates.ratio_repB(flag2ind),'g^','MarkerSize',6,'MarkerFaceColor','g')
% plot(CHNreplicates.ratio_repA(flag3ind),CHNreplicates.ratio_repB(flag3ind),'r*') %doesn't work because turn flag3 to nan
xlabel('C:N ratio rep A','FontWeight','bold'); ylabel('C:N ratio rep B','FontWeight','bold'); title('MVCO POC:PON molar ratio')
axis square
legend('1:1 line','all','C or N suspicious','Location','best')



