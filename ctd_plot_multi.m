%4/6/10 - Taylor
%Plot all parameters for a single cast on the same plot (temp, salt, dens,
%fluor, turb, extracted chl). This script creates a new figure for every
%cast ever done. The amount of figures will quickly become cumbersome so I
%often set i equal to the cruise date I'm interested in and just plot the
%j for loop, one date at a time. 
% Author:
%   Blair Greenan
%   Bedford Institute of Oceanography
%   18-May-1999
%   Matlab 5.2.1
%   greenanb@mar.dfo-mpo.gc.ca
% =========================================================================
%
load ctd_data_edited
load chl_stations
load HPLC_MVCO_pigments4plot

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
for j=j1
    j
%        subplot(2,4,j);

        y = ctd_down(:,1,j,i);
        dens = ctd_down(:,6,j,i);
        fluor = ctd_down(:,7,j,i);
        turb = ctd_down(:,8,j,i);
        temp = ctd_down(:,3,j,i);
        salt = ctd_down(:,5,j,i);
        max_dens = ceil(max(max([max(ctd_down(:,6,:,i)) max(ctd_up(:,6,:,i))])));
        min_dens = floor(min(min([min(ctd_down(:,6,:,i)) min(ctd_up(:,6,:,i))])));
        max_fluor = ceil(max(max([max(ctd_down(:,7,:,i)) max(ctd_up(:,7,:,i))])));
        min_fluor = floor(min(min([min(ctd_down(:,7,:,i)) min(ctd_up(:,7,:,i))])));
        max_turb = ceil(max(max([max(ctd_down(:,8,:,i)) max(ctd_up(:,8,:,i))])));
        min_turb = floor(min(min([min(ctd_down(:,8,:,i)) min(ctd_up(:,8,:,i))])));
        max_temp = ceil(max(max([max(ctd_down(:,3,:,i)) max(ctd_up(:,3,:,i))])));
        min_temp = floor(min(min([min(ctd_down(:,3,:,i)) min(ctd_up(:,3,:,i))])));
        max_salt = ceil(max(max([max(ctd_down(:,5,:,i)) max(ctd_up(:,5,:,i))])));
        min_salt = floor(min(min([min(ctd_down(:,5,:,i)) min(ctd_up(:,5,:,i))])));
        maxy = ceil(max(max(ctd_down(:,1,j,:)))) + 2;
        match_date = datenum(datestr(ctd_down(1,18,4,i),'yyyy-mm-dd'));
        chl_point = find(chl_station == j & matday == match_date);
        hplc_point= find(hpstation == j & hpmatday == match_date);
        if ~isnan(ctd_down(1,18,j,i))
        figure;
% plot ctd cast fluorescence vs depth
        hl1=plot(fluor,y,'color',[0 .8 0],'linestyle','-','Linewidth',2);
% assign current axis handle to variable for later reference if needed
        ax1=gca;
% set properties of the axes
        set(ax1,'xlim',[0 max_fluor]);
        if ~isnan(maxy)
            set(ax1,'ylim',[0 maxy]);
        end
        set(ax1,'XMinorTick','on','ydir','reverse', 'box','on','xcolor',get(hl1,'color'))
        xlabel('Fluorescence (mg/m^3) (solid)')
        ylabel('Depth (m)');
%plot extracted chlorophyll values
        hl5 = line(chl(chl_point,1),depth(chl_point),'Color',get(hl1,'color'),'Marker','.','LineStyle','none');%,'Parent',ax(1));
        hl6 = line(chl(chl_point,2),depth(chl_point),'Color',get(hl1,'color'),'Marker','+','LineStyle','none');%,'Parent',ax(1));
        hl7 = line(chl(chl_point,3),depth(chl_point),'Color',get(hl1,'color'),'Marker','*','LineStyle','none');%,'Parent',ax(1));
%plot HPLC Tchl values to compare to fluor and extracted chl
        hp1 = line(pigments(hplc_point,1),hpdepth(hplc_point),'Color',[.2 .6 0],'Marker','diamond','LineStyle','none');
%plot Fuco/Tchl to look at ratio of diatoms in the total chl value
        hp2 = line(pigments(hplc_point,10)./pigments(hplc_point,1),hpdepth(hplc_point),'Color',[.2 .6 0],'Marker','diamond','LineStyle','none');
        
% add 1st floating axis for the second parameter plotted
        [hl2,ax2,ax3] = floatAxisX(dens,y,'k:','Density (kg/m^3) (dotted)',[min_dens max_dens 0 maxy]);
        set(ax2,'ydir','reverse')
        set(hl2,'linewidth',2);
% add 2nd floating axis for the third parameter plotted
        [hl3,ax4,ax5] = floatAxisX(salt,y,'b','Salinity (psu)',[min_salt max_salt 0 maxy]);
        set(ax4,'ydir','reverse');
        set(hl3,'linewidth',2);

% add 3nd floating axis for the third parameter plotted
        [hl4,ax6,ax7] = floatAxisX(temp,y,'r','Temperature (deg C)',[min_temp max_temp 0 maxy]);
        set(ax6,'ydir','reverse')
        set(hl4,'linewidth',2);
 %from plotxx trying to make second x axis on top of plot        
        set(ax1,'Box','on','ActivePositionProperty','position') ;
        ax8=axes('Position',get(ax1,'Position'),...
       'XAxisLocation','top',...
       'YAxisLocation','right',...
       'Color','none',...
       'XColor','m','YColor','k');
       set(ax8,'box','off')
       hl8=line(turb,y,'color','m','linestyle','--','linewidth',2,'Parent',ax8);
       set(ax8,'YDir','reverse','xlim',[0 max_turb]);
        if ~isnan(maxy)
            set(ax8,'ylim',[0 maxy]);
        end
       xlabel('Turbidity (ftu)');
       if ~isnan(ctd_down(1,18,j,i))
           title(strcat(datestr(ctd_down(1,18,j,i), 'mm/dd/yy'),'-', datestr(ctd_down(1,18,j,i),'HH:MM'),'-',station_title(j,:)));
       end
       end
end
 clear hl* x1 x2 x3 x4 max* min* ax* chl_pointy dens salt fluor turb temp match_date
