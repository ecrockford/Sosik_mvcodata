%colormat key [  3 pink; 4 light pink; 5 orange; 6gold;9 olive;  
% 8 green; 10 dark green; 11 blue/green; 12 light 
%blue; 13 blue; 14 navy; 15 light purple; 16 purple; 17 egglplant
%18 brown; 19 black; 20 gray; ]
%extra colors: 1 red;1 0 0;7 yellow;1 1 0; 
%2 brick;.6 0 0;

load instr_deployment_data

temp=find(mark_dead ==1);
dfluor=unique(SN(temp));
figure
for count=1:length(fluor)
    hold on
    ind=find(strcmp(SN,fluor(count,:))); %find all the entries for a specific fluorometer
    plot(matday(ind),days(ind,1),'.-','color',colormat(count,:))
    
end
xlabel('Date')
ylabel('Days Deployed - positive slope = deployed')
datetick('x')
legend(fluor(:,:),'interpreter','none');
title('Fluorometers - days deployed between being serviced - red = dead')
for count=1:length(dfluor)
    hold on
    ind=find(strcmp(SN,dfluor(count)));
    plot(matday(ind),days(ind,1),'xr','markersize',9,'linewidth',2)
end
clear count ind temp

figure
for count=1:length(fluor)
    hold on
    ind=find(strcmp(SN,fluor(count,:))); %find all the entries for a specific fluorometer
    plot(instr_count(ind),days(ind,3),'.-','color',colormat(count,:))
    
end
xlabel('Instrument Count')
ylabel('Total Days Deployed - positive slope = deployed')
legend(fluor(:,:),'interpreter','none');
title('Fluorometers - total days deployed over instrument lifetime - red = dead')
for count=1:length(dfluor)
    hold on
    ind=find(strcmp(SN,dfluor(count)));
    plot(instr_count(ind),days(ind,3),'xr','markersize',9,'linewidth',2)
end
clear count ind

ind=find(strncmp(dfluor,'FLNTUSB',7));
new_dfluor=dfluor(ind);
figure
for count=1:length(new_dfluor)
    ind = find(strcmp(SN,new_dfluor(count,:))); %find all the entries for a specific dead fluorometer
    hold on
        if strcmp(new_dfluor(count),'FLNTUSB_959')
            plot(matday(ind)-70,days(ind,2),'.-','color',colormat(count,:))
        elseif strcmp(new_dfluor(count),'FLNTUSB_961')
            plot(matday(ind)+70,days(ind,2),'.-','color',colormat(count,:))
        end
    plot(matday(ind),days(ind,2),'.-','color',colormat(count,:))
    for i=1:length(ind)
        hold on
        if strcmp(new_dfluor(count),'FLNTUSB_959')
            text(matday(ind(i))-70,days(ind(i),2),local(ind(i)))
        elseif strcmp(new_dfluor(count),'FLNTUSB_961')
            text(matday(ind(i))+70,days(ind(i),2),local(ind(i)))
        end
        text(matday(ind(i)),days(ind(i),2),local(ind(i)))
    end
end
xlabel('Date')
ylabel('Days without service')
datetick('x')
legend(new_dfluor(:,:),'interpreter','none');

    
    