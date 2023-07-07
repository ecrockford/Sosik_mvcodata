%Create figure with up to 8 subplots of temperature and salinity profiles
%Each figure is a single cruise day with
%stations 1-8 ploted in order and titled accordingly
%This script is currently setup to pick out a single cruise date to avoid
%too many figures accumulating from running the scripts (currently 21
%figures, 1 for each cruise date we have). To plot all the figures
%uncomment the top for loop and comment out the top input statements.
load ctd_data_edited
for n=1:length(cruise_dir), fprintf('%2d  %s\n',n,cruise_dir(n).name),end
i = input ('Enter number corresponding to cruise date you want to plot:');
cruise_dir(i)
answer=input('Would you like to plot a specific station number? (enter y or n)','s');
switch lower(answer)
    case {'y', 'yes'}
        find(~isnan(ctd_down(1,20,:,i)))
        j1=input('Enter number of station you want to plot from numbers listed above:');
    case {'n','no'}
        switch sum(~isnan(ctd_down(1,18,:,i)))
            case {1}
                j1 = 4;
            case {2,3,4,5,6,7,8}
                j1 = find(~isnan(ctd_down(1,20,:,i)));
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
    max1x = ceil(max(max([max(ctd_down(:,3,:,i)) max(ctd_up(:,3,:,i))])));  %max temperature
    max2x = ceil(max(max([max(ctd_down(:,5,:,i)) max(ctd_up(:,5,:,i))])));  %max salinity
    min1x = floor(min(min([min(ctd_down(:,3,:,i)) min(ctd_up(:,3,:,i))]))); %min temp
    min2x = floor(min(min([min(ctd_down(:,5,:,i)) min(ctd_up(:,5,:,i))]))); %min salt
    figure
    for count = 1:length(j1)
        j=j1(count);
        maxy = ceil(max(ctd_down(:,1,j,i))) + 2;
        y = ctd_down(:,1,j,i);
        x1 = ctd_down(:,3,j,i); %temp downcast
        x2 = ctd_down(:,5,j,i); %salinity downcast
        x3 = ctd_up(:,3,j,i);   %temp upcast
        x4 = ctd_up(:,5,j,i);   %salinity downcast
                
        xlabels{1} = 'Temperature (C)';
        xlabels{2} = 'Salinity (psu)';
        ylabels{1} = 'Depth(m)';
        ylabels{2} = '';
%'if' the cruise date is a single cast make one large fig/plot for better,
%visualization. if multiple stations on date(i) make subplots organized by
%station
        if length(j1) > 1
            subplot(2,4,j);
        end
%plotxx function plots multiple x axes (in this case temp and salt)
        [ax,hlT,hlS] = plotxx(x1,y,x2,y,xlabels,ylabels);
        set(ax(1),'XColor','r'); %color code x-axis red for temp
        set(ax(2),'XColor','b'); %color code x-axis blue for salt
        set(hlT,'Color','r'); %color code hlT line red for temp
        set(hlS,'Color','b'); %color code hlS line blue for temp
        hl3=line(x3,y,'Color','r','LineStyle',':','Parent',ax(1)); %plot temp upcast as line on sample x-axis as temp from downcast (ax1)
        hl4=line(x4,y,'Color','b','LineStyle',':','Parent',ax(2)); %plot temp upcast as line on sample x-axis as temp from downcast (ax1)
        set(ax(1),'XLim',[min1x max1x]); %set temp x-axis limits
        set(ax(2),'XLim',[min2x max2x]); %set salt x-axis limits
            if ~isnan(maxy)
                set(ax,'YLim',[0 maxy]); %set both y-axis limits for depth
            end
        set(ax,'YDir','reverse');
        
        if ~isnan(ctd_down(1,18,j,i))
            title(strcat(datestr(ctd_down(1,18,j,i), 'mm/dd/yy'),'-', datestr(ctd_down(1,18,j,i),'HH:MM'),'-',station_title(j,:)));
        end
    end
    legend('Down', 'Up')
%end
    clear max* min* hl* x* ax*
