%plot CHN results for analysis

load CHN_data_reps
%###################################################################
%Set up variables and indexes for plotting below

depth = cell2mat(MVCO_CHN_reps(:,7));
surface = find(depth< 4);
m6 = find(depth == 6);
m10 = find(depth == 10);
bottom = find(depth > 10);

carbon = cell2mat(MVCO_CHN_reps(:,13));
nitrogen = cell2mat(MVCO_CHN_reps(:,12));

unq_niskin=unique(MVCO_CHN_reps(:,2));
duplicates = [];
dupmatdate = [];
for count = 1:length(unq_niskin)
    dup_spot=find(strcmp(MVCO_CHN_reps(:,2),unq_niskin(count)));
    if length(dup_spot)>1
        duplicates = [duplicates; MVCO_CHN_reps(dup_spot,:)];
        dupmatdate = [dupmatdate; matdate(dup_spot)];
    end
end

spot = 1:2:length(duplicates);
percent_rangeC = range([cell2mat(duplicates(spot,12)) cell2mat(duplicates(spot+1,12))],2)./mean([cell2mat(duplicates(spot,12)) cell2mat(duplicates(spot+1,12))],2)*100;
percent_rangeN = range([cell2mat(duplicates(spot,11)) cell2mat(duplicates(spot+1,11))],2)./mean([cell2mat(duplicates(spot,11)) cell2mat(duplicates(spot+1,11))],2)*100;
ratio = cell2mat(duplicates(:,12))./cell2mat(duplicates(:,11));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 1 - HISTO REP RAGNE/MEAN%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','Histo Replicate range/mean (%)')
subplot(1,2,1)
hist(percent_rangeC)
ylabel('# of events','fontweight','bold'); xlabel('Replicate range / mean (%)','fontweight','bold'); title('Carbon','fontweight','bold')

subplot(1,2,2)
hist(percent_rangeN)
ylabel('# of events','fontweight','bold'); xlabel('Replicate range / mean (%)','fontweight','bold'); title('Nitrogen','fontweight','bold')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 2 - REP RAGNE/MEAN OVER TIME%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','Replicate range/mean (%) Over Time')
subplot(3,1,1)
plot(percent_rangeC,'.')
ylabel('Carbon','fontweight','bold'); title('Precent Range / Mean Over Time','fontweight','bold')

subplot(3,1,2)
plot(percent_rangeN,'.')
ylabel('Nitrogen','fontweight','bold')

subplot(3,1,3)
plot(range([ratio(spot) ratio(spot+1)],2)./mean([ratio(spot) ratio(spot+1)],2),'.')
ylabel('Ratio C:N','fontweight','bold')
xlabel('Event index number','fontweight','bold')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FIG 3 - REP COMPARISON%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
subplot(2,2,1)
plot(cell2mat(duplicates(spot,12)),cell2mat(duplicates(spot+1,12)),'.')
line([8 30], [8 30],'color','k','linestyle','--')
xlabel('rep 1','fontweight','bold'); ylabel('rep 2','fontweight','bold')
title('Carbon replicate comparison','fontweight','bold')

subplot(2,2,2)
plot(cell2mat(duplicates(spot,11)),cell2mat(duplicates(spot+1,11)),'.')
line([1 3.5], [1 3.5],'color','k','linestyle','--')
xlabel('rep 1','fontweight','bold'); ylabel('rep 2','fontweight','bold')
title('Nitrogen replicate comparison','fontweight','bold')

subplot(2,2,3)
plot(ratio(spot), ratio(spot+1),'.')
line([5 10], [5 10],'color','k','linestyle','--')
xlabel('rep 1','fontweight','bold'); ylabel('rep 2','fontweight','bold')
title('C:N ratio duplicate comparison','fontweight','bold')

%make ratio for all not just duplicates
clear ratio
ratio = carbon./nitrogen;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FIG 4 - unadjusted carbon results over time, color code for depth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name','Carbon, Nitrogen, C:N Ratio Over Time','position',[1 35 1280 916])
subplot(3,1,1)
plot(matdate(surface),carbon(surface),'g.-','markersize',20)
hold on
plot(matdate(m6),carbon(m6),'ro-','markersize',10)
plot(matdate(m10),carbon(m10),'m*-','markersize',10)
plot(matdate(bottom),carbon(bottom),'b^-','markersize',10)
legend('surface','6m','10m','bottom')
datetick('x','keeplimits')
title('Carbon','fontweight','bold'); ylabel('Carbon (umol)','fontweight','bold')

subplot(3,1,2)
plot(matdate(surface),nitrogen(surface),'g.-','markersize',20)
hold on
plot(matdate(m6),nitrogen(m6),'ro-','markersize',10)
plot(matdate(m10),nitrogen(m10),'m*-','markersize',10)
plot(matdate(bottom),nitrogen(bottom),'b^-','markersize',10)
datetick('x','keeplimits')
title('Nitrogen','fontweight','bold'); ylabel('Nitrogen (umol)','fontweight','bold')

subplot(3,1,3)
plot(matdate(surface),ratio(surface),'g.-','markersize',20)
hold on
plot(matdate(m6),ratio(m6),'ro-','markersize',10)
plot(matdate(m10),ratio(m10),'m*-','markersize',10)
plot(matdate(bottom),ratio(bottom),'b^-','markersize',10)
title('C:N Ratio','fontweight','bold')
datetick('x','keeplimits')
ylabel('C:N','fontweight','bold')

%plot carbon vs nitrogen. color code for depth
figure
plot(carbon(surface),nitrogen(surface),'g.','markersize',15)
hold on
plot(carbon(m6),nitrogen(m6),'ro','markersize',10)
plot(carbon(m10),nitrogen(m10),'m*','markersize',10)
plot(carbon(bottom),nitrogen(bottom),'b^','markersize',10)
legend('surface','6m','10m','bottom','location','best')
xlabel('Carbon (umol)'); ylabel('Nitrogen (umol)');
title('Unadjusted Carbon vs Nitrogen - CHN')

%plot carbon:nitrogen ratio over time
figure('position',[58 502 1210 420],'name','C:N ratio over time')
plot(matdate(surface),carbon(surface)./nitrogen(surface),'g.','markersize',15)
hold on
plot(matdate(m6),carbon(m6)./nitrogen(m6),'ro','markersize',10)
plot(matdate(m10),carbon(m10)./nitrogen(m10),'m*','markersize',10)
plot(matdate(bottom),carbon(bottom)./nitrogen(bottom),'b^','markersize',10)
legend('surface','6m','10m','bottom','location','best')
xlabel('Date'); ylabel('Ratio Carbon:Nitrogen (umol)');
datetick('x','keeplimits')
title('unadjusted carbon : nitrogen ratio - CHN')
