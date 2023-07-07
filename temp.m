clear all
load profile_chemtax
leg=['diatoms' 'dinoflag' profile_header(15:16)];
surface=profile_data(profile_data(:,3)<4,:);
clear profile_data
%To get spatial resolution across lat & lon I pulled out only the surface
%pigments for easier visualization. Multiple depths at 1 lat/lon would be
%too cumbersome.

%the precentage pigment is the %of that group normalized to TChl_a. So the
%percentage is not an actual percentage of the total sum of Chl, or total
%sum of pigment. the plotted chl value on top x-axis is TChl_a
unq_day=unique(surface(:,1));
year=str2num(datestr(unq_day,'yyyy'));

%subplot for lat = perpendicular to shore
%************** this temp 'for' loop creates 1 figure for each year of data
%collected. all cruise dates are subplotted on each figure for each year.
for latlon=1:2
for temp=2007:max(year)
    count=find(year == temp);
    numb_figs = [1:length(count)]; %= number of cruise days in that year
    figure
    for i=1:length(count)
%find where in the 5 stations perpendicular to shore data actually exists
        switch latlon
            case 1
%from surf pigment groupings find data with matching date and station #
%less that 6 (perpendicular to shore)
                ind=find(surface(:,1) == unq_day(count(i)) & surface(:,4) < 6); 
                unq_coord=unique(surface(ind,5));
            case 2
                ind=find(surface(:,1) == unq_day(count(i)) & surface(:,4) > 3);
                unq_coord=unique(surface(ind,6));
        end
                if length(ind) ~= size(unq_coord,1)
                    for j=1:length(unq_coord)
                        switch latlon
                            case 1
                                ind2=find(surface(:,1) == unq_day(count(i)) & surface(:,5) == unq_coord(j));
                            case 2
                                ind2=find(surface(:,1) == unq_day(count(i)) & surface(:,6) == unq_coord(j));
                        end
                        if length(ind2) > 1
                            subplot(2,4,numb_figs(i))
                            barh(unq_coord(j),[mean(surface(ind2,8:9)) mean(surface(ind2,15:16))],0.4,'stacked')
                            text(sum([mean(surface(ind2,8:9)) mean(surface(ind2,15:16))],2)+.05,unq_coord(j),num2str(surface(ind2,4)))
                            axis([0 1 41.13 41.34])
                            hold on
                            set(gca,'ydir','reverse')
                        else
                            subplot(2,4,numb_figs(i))
                            axis([0 1 41.13 41.34])
                            text(sum([surface(ind2,8:9) surface(ind2,15:16)],2)+.05,unq_coord(j),num2str(surface(ind2,4)))
                            hold on
                            set(gca,'ydir','reverse')
                        end
                    end
                else
                    subplot(2,4,numb_figs(i))
                    barh(surface(ind,5),[surface(ind,8:9) surface(ind,15:16)],0.4,'stacked')
                    hold on
                    axis([0 1 41.13 41.34])
%don't need to for lat                    set(gca,'ydir','reverse')
                    text(sum([surface(ind,8:9) surface(ind,15:16)],2)+.05,surface(ind,5),num2str(surface(ind,4)))
                end

        xlabel('Percentage of total chl')
        switch latlon
            case 1
                ylabel('Latitude (dec. degrees N)')
            case 2
                ylabel('Longitude (dec. degrees W)')
        end
        title([datestr(unq_day(count(i)),'mm/dd/yy')])
    end
%legend uses the general taxa of percentage groupings. this script only
%includes what we determed as the 4 largest contributing groups
    legend(leg)
end
end

    