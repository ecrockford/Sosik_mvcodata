clear all
load MVCO_HPLC_reps
%tease out surface HPLC pigments and station #s to plot total Chla on bar plots. plotting
%tchla and not tchl because the chemtax groupings are all normalized to
%tchla
surf_pig=find(cell2mat(HPLC(:,7))<4);
hplc_surf=HPLC(surf_pig,:);
station4hplc=station4hplc(surf_pig);
clear HPLC surf_pig
%if duplicates exist average together. (averaged duplicate groupings down
%the line because can't plot multiple of sample x value on bar plot)
tchla=NaN(length(hplc_surf),1);
for i=1:length(hplc_surf)
    if ~isnan(cell2mat(hplc_surf(i,61)))
        tchla(i)=mean([cell2mat(hplc_surf(i,9)) cell2mat(hplc_surf(i,61))]);
    else tchla(i)=cell2mat(hplc_surf(i,9));
    end
end
clear i
%make depth, lat, lon, date matrixes that are numbers and not cells for
%ease of manipulation downstream
pigdepth=cell2mat(hplc_surf(:,7));
piglat=cell2mat(hplc_surf(:,5));
piglon=cell2mat(hplc_surf(:,6));
pigdate=datenum(hplc_surf(:,3),'yyyy-mm-dd');

load profile_chemtax
leg=['diatoms' 'dinoflag' profile_header(15:16)];
%To get spatial resolution across lat & lon I pulled out only the surface
%pigments for easier visualization. Multiple depths at 1 lat/lon would be
%too cumbersome.
surface=profile_data(profile_data(:,3)<4,:);
clear profile_data
unq_day=unique(surface(:,1));
year=str2num(datestr(unq_day,'yyyy'));

%subplot for lat = perpendicular to shore
%************** this temp 'for' loop creates 1 figure for each year of data
%collected. all cruise dates are subplotted on each figure for each year.
for latlon=1:2
for temp=2007:max(year)
    count=find(year == temp);
%= number of cruise days in that year which will be # of subplots
    numb_figs = [1:length(count)]; 
    figure
    for i=1:length(numb_figs)
        switch latlon
            case 1
%from surf pigment groupings find data with matching date and station #
%less that 6 (perpendicular to shore)
                ind=find(surface(:,1) == unq_day(count(i)) & surface(:,4) < 6);
                hplcind=find(pigdate == unq_day(count(i)) & station4hplc < 6);
%Make a unique list of available latitudes to excludes duplicates because
%can't plot 2 of the same x value (lat or lon) on bar plot, need to average
%duplicates downstream
                if unq_day(count(i))==733389
                    coord=surface(ind,5);
                    coordhplc=piglat(hplcind);
                else
                    coord=unique(surface(ind,5));
                    coordhplc=unique(piglat(hplcind));
                end
            case 2
%from surf pigment groupings find data with matching date and station #
%greater that 3 (parallel to shore)
                ind=find(surface(:,1) == unq_day(count(i)) & surface(:,4) > 3);
                hplcind=find(pigdate == unq_day(count(i)) & station4hplc > 3);
%733845 is 3/13/09 which was special day with 2 station6 surf samples due
%to ctd problems. adjust to include both samples
                if unq_day(count(i))==733845
                    coord=surface(ind,6);
                    coordhplc=piglon(hplcind);
                else
%Make a unique list of available longitudes. Excludes duplicates.
                coord=unique(surface(ind,6));
                coordhplc=unique(piglon(hplcind));
                end
        end
        percentages=zeros(length(coord),4);
        stations=zeros(length(coord),1);
        chl=zeros(length(coordhplc),1);
%the below if statements looks for replicates within the cruise date
%        if length(coord) ~= length(surface(ind,4))
            for k=1:length(coord)
                switch latlon
%find in pigment %group surface data the specific date and coordinate
                    case 1
                        ind2=find(surface(:,1) == unq_day(count(i)) & surface(:,5) == coord(k) & surface(:,4) < 6); %column 5=lat
                    case 2
                        ind2=find(surface(:,1) == unq_day(count(i)) & surface(:,6) == coord(k) & surface(:,4) > 3); %column 6=lon
                end
                if length(ind2) > 1
%if length of specific day and station sample is greater than 1 that means
%it's a replicate sample. average them together else can't plot correctly
                    percentages(k,:)=[mean(surface(ind2,8:9)) mean(surface(ind2,15:16))];
                    stations(k)=mean(surface(ind2,4));
%this loop needs to account for the stations where no replicates occur 
%just take the data into the percentage matrix
                else percentages(k,:)=[surface(ind2,8:9) surface(ind2,15:16)];
                    stations(k)=surface(ind2,4);
                end
            end
%compiling coordinates and Tchla values from the hplc pigment data is done
%separately from the grouping percentages because sometimes (as of 11/9/10)
%there are missing chemtax data for hplc pigments. we want to include all
%the pigment data and this can also be used as a way to check that chemtax
%has been run for all the existing pigment data
            for k=1:length(coordhplc)
                switch latlon
                    case 1
                        hplcind2=find(pigdate == unq_day(count(i)) & piglat == coordhplc(k) & station4hplc < 6);
                    case 2
                        hplcind2=find(pigdate == unq_day(count(i)) & piglon == coordhplc(k) & station4hplc > 3);
                end
%don't need if length(ind)>1 loop because the tchla matrix has already
%averaged replicates together at the start of the script. in theory
%shouldn't need this loop...
%turns out you do need the >1 loop for the horn point lab precision double
%check when they re-run the same sample for their own precision quality
%control
                if length(hplcind2) >1
                    chl(k)=mean(tchla(hplcind2));
                else chl(k)=tchla(hplcind2);
                end
            end

        subplot(2,4,numb_figs(i))
%following if statement tries to adjust width of bars to make them fat
%enough. the control of width is dependent on spacing of yaxis values, the
%width is not just a generic number you can set = annoying
%        if coord(end)-coord(end-1) < 0.01
%            barh(coord,percentages,1.9,'stacked')
%        elseif coord(end)-coord(end-1) < 0.005
%            barh(coord,percentages,2.3,'stacked')
%        else
        if length(coord) == 1
            barh([coord 0],[percentages; 0 0 0 0],0.2,'stacked')
        else
            barh(coord,percentages,.7,'stacked')
        end
%        end
        ax1=gca;
%label the lats on the right side of each stacked column to know the station.
%If you take out the manual yaxis labeling the plot would only label
%the yaxis where the depths are
        for k=1:length(coord)
            text(sum(percentages(k,:))+.05,coord(k),['S' num2str(stations(k))])
        end
        xlabel('Percentage of total chl')
        switch latlon
            case 1
                ylabel('Latitude (dec. degrees N)')
                axis([0 1 41.13 41.34])
            case 2
                ylabel('Longitude (dec. degrees W)')
                axis([0 1 -70.7 -70.4])
        end
%legend uses the general taxa of percentage groupings. this script only
%includes what we determed as the 4 largest contributing groups. need to
%put before plotting Tchla because need legend to correspond to bar colors
        if i == length(numb_figs)
                legend(leg);
        end
%plot second xaxix (top of graph) for total chla from hplc data. turn off 
%the 2nd yaxis display and set the limits the same as the first yaxis
%have a separate coordinate matrix for tchla from hplc's to double check
%that the data match up with the chemtax grouped data
%       'TightInset',get(ax1,'TightInset'),...
        set(ax1,'Box','on','ActivePositionProperty','position') ;
        ax2=axes('Position',get(ax1,'Position'),...
       'XAxisLocation','top',...
       'YAxisLocation','right',...
       'Color','none',...
       'XColor','m','YColor','k');
%       set(ax2,'box','off')
       hl=line(chl,coordhplc,'color','m','marker','*','linestyle','-');%'Parent',ax2);
%       set(ax1,'activepositionproperty','tightinset');
%       set(ax2,'tightinset',get(ax1,'tightinset')); 
%       set(ax2,'xLimMode','manual')
       set(ax2,'xlim',[0 ceil(max(chl))]);
%       set(ax2,'PlotBoxAspectRatioMode','manual');
%       set(ax2,'PlotBoxAspectRatio',get(ax1('PlotBoxAspectRatio')));
%       set(ax2,'DataAspectRatioMode','manual');
%       set(ax2,'position',get(ax1,'position'))
       set(ax2,'ylim',get(ax1,'ylim'),'YTickLabel',[]);
       xlabel('HPLC Tchla');
       set(ax2,'position',get(ax1,'position'))

        title([datestr(unq_day(count(i)),'mm/dd/yy')])
    end
keyboard
end
end

