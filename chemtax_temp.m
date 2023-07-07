load profile_chemtax
leg=['diatoms' 'dinoflag' profile_header(15:16)];
unq_day=unique(profile_data(:,1));

%the precentage pigment is the %of that group normalized to TChl_a. So the
%percentage is not an actual percentage of the total sum of Chl, or total
%sum of pigment. 

fprintf('\n \n %s\n',['Number of cruise dates is ' num2str(length(unq_day))])
answer=input('\n Would you like to plot a specific cruise date? (enter y or n)','s');
switch lower(answer)
    case {'y', 'yes'}
        for n=1:length(unq_day)
            fprintf('%2d  %s\n',n,[datestr(unq_day(n),'mm/dd/yy') ', No of St: ' num2str(length(unique(profile_data(profile_data(:,1) == unq_day(n),4)))) ', No of Depths: ' num2str(length(profile_data(profile_data(:,1)==unq_day(n),3)))])
        end
        count = input ('\n Enter number corresponding to cruise date you want to plot:');
    case {'n','no'}
        count=1:length(unq_day);
    otherwise error('Answer must be y or n')
end
clear n

for i=count(1):count(end)
    stations=unique(profile_data(profile_data(:,1) == unq_day(i),4));
%    maxy=ceil(max(profile_data(ind,3)))+2;
    figure
    for j=1:length(stations)
        ind=find(profile_data(:,1) == unq_day(i) & profile_data(:,4) == stations(j));
        depth=profile_data(ind,3);
        unq_depth=unique(depth);
        percentages=zeros(length(unq_depth),4);
        if length(unq_depth)==1 & length(unq_depth) ~= length(depth) 
            unq_depth=[unq_depth;unq_depth+4];
            percentages=[mean(profile_data(ind,8:9)) mean(profile_data(ind,15:16)); 0,0,0,0];
        elseif length(unq_depth)==1
            unq_depth=[unq_depth;unq_depth+4];
            percentages=[profile_data(ind,8:9) profile_data(ind,15:16); 0,0,0,0];
        elseif length(unq_depth) ~= length(depth) & length(unq_depth)>1
            for k=1:length(unq_depth)
                ind2=find(profile_data(:,1) == unq_day(i) & profile_data(:,4) == stations(j) & profile_data(:,3) == unq_depth(k));
                if length(ind2) > 1
                    percentages(k,:)=[mean(profile_data(ind2,8:9)) mean(profile_data(ind2,15:16))];
                else percentages(k,:)=[profile_data(ind2,8:9) profile_data(ind2,15:16)];
                end
            end
        else         
            percentages=[profile_data(ind,8:9) profile_data(ind,15:16)];
        end
        subplot(2,4,stations(j));
        if length(unq_depth)==1
            barh(unq_depth,percentages,'stacked')
        elseif max(unq_depth)-min(unq_depth) > 15
            barh(unq_depth,percentages,0.3,'stacked')
        elseif max(unq_depth)-min(unq_depth) >= 8 
            barh(unq_depth,percentages,0.5,'stacked')
        else
            barh(unq_depth,percentages,0.7,'stacked')
        end
        set(gca,'ydir','reverse')
        axis([0 1 0 40])
%don't need to text label because can't do 5m ticks correctly
%label the depth on the right side of each stacked column to know the exact
%date. If you take out the manual yaxis labeling the plot would only label
%the yaxis where the depths are
%        for k=1:length(unq_depth)
%            if sum(percentages(k,:)) ~= 0
%                text(sum(percentages(k,:))+.05,unq_depth(k),num2str(unq_depth(k)))
%            end
%        end
        xlabel('Percentage of total chl')
        ylabel('Depth (m)')
        title([datestr(unq_day(i),'mm/dd/yy') '  St' num2str(stations(j))])
    end
    legend(leg)
end

%clear i j k ind ind2 count leg percentages unq_* stations depth