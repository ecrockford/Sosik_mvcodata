%Create figure with up to 8 subplots of density and fluorescence profiles
%and points for extracted chl (.,+,*), Tchl from HPLC (square), and ratio
%of Fuco/Tchl from HPLC (diamond). Each figure is a single cruise day with
%stations 1-8 ploted in order and titled accordingly
%This script is currently setup to pick out a single cruise date to avoid
%too many figures accumulating from running the scripts (currently 21
%figures, 1 for each cruise date we have). To plot all the figures
%uncomment the top for loop and comment out the top input statements.
clear all
%load ctd_data_edited
load ctd_data3
load chl_stations
load HPLC_MVCO_pigments4plot

cruisetemp=NaN(1,length(cruise_dir));
for i=1:length(cruise_dir)
    cruisetemp(i)=datenum(cruise_dir(i).name(end-6:end));
end
[folder,xi]=sort(cruisetemp);
for n=1:length(cruise_dir), fprintf('%2d  %s\n',n,cruise_dir(xi(n)).name),end
i = input ('Enter number corresponding to cruise date you want to plot:');
cruise_dir(i)
answer=input('Would you like to plot a specific station number? (enter y or n)','s');
switch lower(answer)
    case {'y', 'yes'}
        find(~isnan(ctd_down(1,20,:,i)))
        j1=input('Enter number of station you want to plot from numbers listed above:');
    case {'n','no'}
        switch sum(~isnan(ctd_down(1,18,:,i)))
            case 1
                j1 = 4;
            case {2,3,4,5,6,7,8}
                j1=find(~isnan(ctd_down(1,20,:,i)));
            otherwise
                error(['Problem with existing cast data for given date: ' cruise_dir(i).name])
        end
    otherwise error('Answer must be y or n')
end
%####################################
%Comment out above for and switch loops and uncomment for loop below 
%(don't for get about ;end') to plot all the figures for every cruise date
%###################################
%for i = 1:size(ctd_down,4)
%    cruise_dir(i)
max1x = ceil(max(max([max(ctd_down(:,6,:,i))])));% max(ctd_up(:,6,:,i))])));  %max density
max2x = ceil(max(max([max(ctd_down(:,7,:,i))])));% max(ctd_up(:,7,:,i))])));  %max fluorescence
min1x = floor(min(min([min(ctd_down(:,6,:,i))])));% min(ctd_up(:,6,:,i))]))); %min density
min2x = floor(min(min([min(ctd_down(:,7,:,i))])));% min(ctd_up(:,7,:,i))]))); %min fluorescence
    
figure
for count1 = 1:length(j1)
    j=j1(count1);
    maxy = ceil(max(ctd_down(:,1,j,i))) + 2;
    y = ctd_down(:,1,j,i);  %depth
    x1 = ctd_down(:,6,j,i); %density downcast
    x2 = ctd_down(:,7,j,i); %fluor downcast
%    x3 = ctd_up(:,6,j,i);   %density upcast
%    x4 = ctd_up(:,7,j,i);   %fluor upcast
                
    xlabels{1} = 'Density (kg/m^3)';
    xlabels{2} = 'Fluorescence (mg/m^3)';
    ylabels{1} = 'Depth(m)';
    ylabels{2} = '';
        
%'if' the cruise date is a single cast make one large fig/plot for better,
%visualization. if multiple stations on date(i) make subplots organized by
%station
    if length(j1) > 1
        subplot(2,4,j);
    end
%plotxx function plots multiple x axes (in this case temp and salt)
    [ax,hlD,hlF] = plotxx(x1,y,x2,y,xlabels,ylabels);
    set(ax(2),'XColor',[0 .8 0]); %color-code x-axis green for fluor
    set(hlF,'Color',[0 .8 0]);%color-code hlF line green for fluor
%    hl3=line(x3,y,'Color','k','LineStyle',':','Parent',ax(1)); %plot density upcast same color (black) as downcast fitting to same x-axis (ax(1))
%    hl4=line(x4,y,'Color',[0 .8 0],'LineStyle',':','Parent',ax(2));%plot fluor upcast same green as downcast fitting to same x-axis (ax(2))
    set(ax(1),'XLim',[min1x max1x]); %set density x-axis limits
    set(ax(2),'XLim',[min2x max2x]); %set fluor x-axis limits
    if ~isnan(maxy)
        set(ax,'YLim',[0 maxy]); %set both y-axis limits for depth
    end
    set(ax,'YDir','reverse');
    if ~isnan(ctd_down(1,18,j,i))
        title(strcat(datestr(ctd_down(1,18,j,i), 'mm/dd/yy'),'-', datestr(ctd_down(1,18,j,i),'HH:MM'),'-',station_title(j,:)));
    end

    match_date = datenum(datestr(ctd_down(1,18,4,i),'yyyy-mm-dd'));
%find location in extracted chl data that matches date and station number as cast
%data subplotted above
    chl_point = find(chl_station == j & matday == match_date);
    hl5 = line(chl(chl_point,1),depth(chl_point),'Color','b','Marker','.','LineStyle','none','Parent',ax(2)); %replicate 1 points
    hl6 = line(chl(chl_point,2),depth(chl_point),'Color','b','Marker','+','LineStyle','none','Parent',ax(2)); %replicate 2 points
    hl7 = line(chl(chl_point,3),depth(chl_point),'Color','b','Marker','*','LineStyle','none','Parent',ax(2)); %replicate 3 points (uncommon)
%find locations in hplc data that matches date and station number as cast
%data subplotted above.
    hplc_point= find(hpstation == j & hpmatday == match_date);
%plot HPLC Tchl values to compare to fluor and extracted chl [.2 .6 0]
    hp1 = line(pigments(hplc_point,1),hpdepth(hplc_point),'Color','m','Marker','square','LineStyle','-');
%plot Fuco/Tchl to look at ratio of diatoms in the total chl value  [.2 .6 0]
    hp2 = line(pigments(hplc_point,10)./pigments(hplc_point,1),hpdepth(hplc_point),'Color','m','Marker','diamond','LineStyle',':');

end
legend('Down', 'Up', 'Chl a', 'Chl b', 'Chl c','Tchl HPLC','Fuc/Tchl')
%end

clear hl* x1 x2 x3 x4 max* min* ax*    