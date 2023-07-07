clear all

load MVCO_sample_summary
%plot all mean NO2/NO3 vs all mean extracted chl to look for correlation
figure
plot(nanmean(nut(:,1:3),2),nanmean(chl(:,1:3),2),'.')
xlabel('Mean NO2 No3')
ylabel('Mean Extracted Chl (ug/L)')

%subplot each station with mean nutrient vs depth to see if geographic
%pattern
%currently plots nitrate/ammonium ratio vs depth
figure
for i=1:8
    station=find(station4sum == i);
    subplot(2,4,i)
    hold on
    plot(nanmean(nut(station,1:3),2)./nanmean(nut(station,4:6),2),depth(station),'.')
    line([1 0],[1 30])
%    plot(nanmean(nut(station,1:3),2),depth(station),'.')
 %   plot(nanmean(nut(station,4:6),2),depth(station),'r.')
%    plot(nanmean(nut(station,7:9),2),depth(station),'k.')
%    plot(nanmean(nut(station,10:12),2),depth(station),'m.')
    xlabel('nutrient')
    ylabel('Depth(m)')
    title(title_station(i))
    set(gca,'xlim',[0 ceil(max(nanmean(nut(:,1:3),2)))]);
    set(gca,'ydir','reverse')
end

%subplot for each station of all nutrients over year day to look for annual
%pattern
figure
for i=1:8
    station=find(station4sum == i);
    if i == 5
        figure
    end
    if i < 5
        a=i;
    else a=i-4;
    end
    subplot(4,1,a)
    hold on
    plot(yearday(station),nanmean(nut(station,1:3),2),'r.')
    plot(yearday(station),nanmean(nut(station,4:6),2),'.')
    plot(yearday(station),nanmean(nut(station,7:9),2),'g.')
    plot(yearday(station),nanmean(nut(station,10:12),2),'m.')
    xlabel('Year Day')
    ylabel('Nutrient (uM)')
    title(title_station(i))
    set(gca,'xlim', [0 370])
    set(gca,'ylim', [0 ceil(max(max(nut)))])
    if i == 4 | i == 8
        legend('NO2 NO3', 'NH4', 'SiO2', 'PO4')
    end
end


%subplot for each station nut vs chl and then fit a line. not very pretty
figure
for i=1:8
    station=find(station4sum == i);
    subplot(2,4,i)
    hold on
    plot(nanmean(nut(station,1:3),2),nanmean(chl(station,1:3),2),'.')
%    plot(nanmean(nut(station,4:6),2),depth(station),'r.')
%    plot(nanmean(nut(station,7:9),2),depth(station),'k.')
%    plot(nanmean(nut(station,10:12),2),depth(station),'m.')
    fit = polyfit(nanmean(nut(station,1:3),2),nanmean(chl(station,1:3),2),1);
    fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 18], 'r')
    xlabel('nutrient')
    ylabel('chl (ug/l)')
    title([title_station(i) ', red is ' num2str(fit(1)) '*x+' num2str(fit(2)) ])
    set(gca,'ylim',[0 ceil(max(nanmean(chl(:,1:3),2)))]);
    set(gca,'xlim',[0 ceil(max(nanmean(nut(:,1:3),2)))]);
end

%figure for each station plotting each mean nutrient on its own subplot vs
%mean extracted chl
for i=1:8
figure
    station=find(station4sum == i);
    subplot(2,2,1)
    hold on
    plot(nanmean(nut(station,1:3),2),nanmean(chl(station,1:3),2),'.')
    fit = polyfit(nanmean(nut(station,1:3),2),nanmean(chl(station,1:3),2),1);
    fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 18], 'r')
    xlabel('NO_2- + NO_3-')
    ylabel('chl (ug/l)')
    title([title_station(i) ', red is ' num2str(fit(1)) '*x+' num2str(fit(2)) ])
    set(gca,'ylim',[0 ceil(max(nanmean(chl(:,1:3),2)))]);
    set(gca,'xlim',[0 ceil(max(nanmean(nut(:,1:3),2)))]);

    subplot(2,2,2)
    hold on
    plot(nanmean(nut(station,4:6),2),nanmean(chl(station,1:3),2),'.')
    fit = polyfit(nanmean(nut(station,1:3),2),nanmean(chl(station,1:3),2),1);
    fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 18], 'r')
    xlabel('NH_4+')
    ylabel('Chl (ug/l)')
    title([title_station(i) ', red is ' num2str(fit(1)) '*x+' num2str(fit(2)) ])
    set(gca,'ylim',[0 ceil(max(nanmean(chl(:,1:3),2)))]);
    set(gca,'xlim',[0 ceil(max(nanmean(nut(:,4:6),2)))]);

    subplot(2,2,3)
    hold on
    plot(nanmean(nut(station,7:9),2),nanmean(chl(station,1:3),2),'.')
    fit = polyfit(nanmean(nut(station,1:3),2),nanmean(chl(station,1:3),2),1);
    fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 18], 'r')
    xlabel('SiO_2')
    ylabel('Chl (ug/l)')
    title([title_station(i) ', red is ' num2str(fit(1)) '*x+' num2str(fit(2)) ])
    set(gca,'ylim',[0 ceil(max(nanmean(chl(:,1:3),2)))]);
    set(gca,'xlim',[0 ceil(max(nanmean(nut(:,7:9),2)))]);

    subplot(2,2,4)
    hold on
    plot(nanmean(nut(station,10:12),2),nanmean(chl(station,1:3),2),'.')
    fit = polyfit(nanmean(nut(station,1:3),2),nanmean(chl(station,1:3),2),1);
    fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 18], 'r')
    xlabel('PO_4^3-')
    ylabel('Chl (ug/l)')
    title([title_station(i) ', red is ' num2str(fit(1)) '*x+' num2str(fit(2)) ])
    set(gca,'ylim',[0 ceil(max(nanmean(chl(:,1:3),2)))]);
    set(gca,'xlim',[0 ceil(max(nanmean(nut(:,10:12),2)))]);

end

