load ctd_data3
load setlatlon
%coordinates set by ctd_setlatlon.m
%see file for lat/lon coordinates
%all other scripts pull coordinates from setlatlon.mat

w = setcoord(:,4)-setcoord(:,5);
h=setcoord(:,3)-setcoord(:,2);

colormat = [1 0 0;1 0 1; 1 .8 1; 1 .6 0;1 1 0; 0 1 0; 0 1 1;.8 .6 1];

figure
for i=1:8
    rectangle('Position',[setcoord(i,5) setcoord(i,2) w(i) h(i)],'FaceColor',colormat(i,:))
end

hold on
plot(meta_data(:,3),meta_data(:,2),'.')

title('All existing processed CTD cast locations')