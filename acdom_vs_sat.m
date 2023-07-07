load mvco_specdb

dates = datestr(mvcodata(:,7),'yyyymmdd');
ap = mvcodata(:,1);
aph = mvcodata(:,2);
ad = mvcodata(:,3);
ag = mvcodata(:,4);
wavelength = mvcodata(:,5);
depth = mvcodata(:,6);

unq_date = unique(dates(~isnan(dates)));
surface = find(mvcodata(:,6) >4);

figure
plot(surface(:,4),surface(:,5),'.')