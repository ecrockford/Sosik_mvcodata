load ctd_testing_processing
load ctd_data2
a=nanmean(ctd_testd(:,1:10,:,:));
header_test=ctd_header(1:10);
header_compare={'Mar old','May old','Jul old','Mar test','May test','Jul test'};
mar1308=nanmean(ctd_down(:,1:10,:,6));
may2308=nanmean(ctd_down(:,1:10,:,7));
jul1708=nanmean(ctd_down(:,1:10,:,9));
clear n names sensors ans

%pressure
pressure = NaN(8,6);
for count=1:8
    pressure(count,1)=mar1308(1,2,count,1);
end

for count=1:8
    pressure(count,2)=may2308(1,2,count,1);
end

for count=1:8
    pressure(count,3)=jul1708(1,2,count,1);
end

for date=1:3
    for count=1:8
        pressure(count,date+3)=a(1,2,count,date);
    end
end

%temp
temp = NaN(8,6);
for count=1:8
    temp(count,1)=mar1308(1,3,count,1);
end

for count=1:8
    temp(count,2)=may2308(1,3,count,1);
end

for count=1:8
    temp(count,3)=jul1708(1,3,count,1);
end

for date=1:3
    for count=1:8
        temp(count,date+3)=a(1,3,count,date);
    end
end

%salinity
salt = NaN(8,6);
for count=1:8
    salt(count,1)=mar1308(1,5,count,1);
end

for count=1:8
    salt(count,2)=may2308(1,5,count,1);
end

for count=1:8
    salt(count,3)=jul1708(1,5,count,1);
end

for date=1:3
    for count=1:8
        salt(count,date+3)=a(1,5,count,date);
    end
end

%dens
dens = NaN(8,6);
for count=1:8
    dens(count,1)=mar1308(1,6,count,1);
end

for count=1:8
    dens(count,2)=may2308(1,6,count,1);
end

for count=1:8
    dens(count,3)=jul1708(1,6,count,1);
end

for date=1:3
    for count=1:8
        dens(count,date+3)=a(1,6,count,date);
    end
end

%fluor
fluor = NaN(8,6);
for count=1:8
    fluor(count,1)=mar1308(1,7,count,1);
end

for count=1:8
    fluor(count,2)=may2308(1,7,count,1);
end

for count=1:8
    fluor(count,3)=jul1708(1,7,count,1);
end

for date=1:3
    for count=1:8
        fluor(count,date+3)=a(1,7,count,date);
    end
end

%oxygen
oxygen_conc = NaN(8,6);
for count=1:8
    oxygen_conc(count,1)=mar1308(1,10,count,1);
end

for count=1:8
    oxygen_conc(count,2)=may2308(1,10,count,1);
end

for count=1:8
    oxygen_conc(count,3)=jul1708(1,10,count,1);
end

for date=1:3
    for count=1:8
        oxygen_conc(count,date+3)=a(1,10,count,date);
    end
end
clear count date

figure
colormat='brmkgc';
for count=1:3
    plot(pressure(:,count),pressure(:,count+3),'.','color',colormat(count))
    fit = polyfit(pressure(:,count),pressure(:,count+3),1);
    fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 ceil(max(max(pressure)))], 'color',colormat(count))
    title([station_title(i,:) ' , red is ' num2str(fit(1)) '*x+' num2str(fit(2))])

end


figure
for count=1:8
    subplot(2,4,count)
    plot(ctd_testd(:,10,count,3),ctd_testd(:,1,count,3))
    hold on
    plot(ctd_down(:,10,count,9),ctd_down(:,1,count,9),'r')
    set(gca,'ydir','reverse')
    ylabel('depth (m)')
    xlabel('do')
    title('7-17-08')
end
    legend('test process','original')

    