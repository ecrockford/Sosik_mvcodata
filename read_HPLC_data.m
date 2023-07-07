load \\Queenrose\from_Samwise\data\mvcodata\matlab_files\MVCO_HPLC_reps

event = strvcat(HPLC(:,1));
HPLC = HPLC(find(event(:,1) == 'M'),:);
event = strvcat(HPLC(:,1));
header=header_hplc;

datetemp = char(HPLC(:,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(HPLC(:,4)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
matday = floor(matdate);
unqday = unique(matday);

lat = cell2mat(HPLC(:,5)); 
lon = cell2mat(HPLC(:,6));
depth = cell2mat(HPLC(:,7));
pigment = cell2mat(HPLC(:,9:36));
pigment_header = header(9:36);
pigment_b = cell2mat(HPLC(:,61:88));
pigment_header_b = header(61:88);

asit_surf_ind = find(depth < 5 & lat > 41.31 & lat < 41.33 & lon > -70.58 & lon < -70.55);

figure
plot(matdate(asit_surf_ind), pigment(asit_surf_ind,1), '.-')
hold on
plot(matdate(asit_surf_ind), pigment_b(asit_surf_ind,1), '+')
plot(matdate(asit_surf_ind), pigment(asit_surf_ind,10), 'r.-')
plot(matdate(asit_surf_ind), pigment_b(asit_surf_ind,10), 'r+')
ylabel('Pigment Conc (ug/L)')
datetick('x', 10)
title('Chla & Fuco')

figure
plot(matdate(asit_surf_ind), pigment(asit_surf_ind,10)./pigment(asit_surf_ind,1), 'r.-')
hold on
plot(matdate(asit_surf_ind), pigment_b(asit_surf_ind,10)./pigment_b(asit_surf_ind,1), 'r+')
datetick('x', 10)
title('Ratio Fuco/Total Chl_a')

figure
plot(matdate(asit_surf_ind), pigment(asit_surf_ind,11), 'r.-')
hold on
plot(matdate(asit_surf_ind), pigment_b(asit_surf_ind,11), 'r+')
ylabel('Pigment Conc (ug/L)')
datetick('x', 10)
title('Peridinin - unique to dinoflagellates')

figure
plot(matdate(asit_surf_ind), pigment(asit_surf_ind,5), 'r.-')
hold on
plot(matdate(asit_surf_ind), pigment_b(asit_surf_ind,5), 'r+')
ylabel('Pigment Conc (ug/L)')
datetick('x', 10)
title('But-Fucoxanthin - unique to golden brown flagellates')

figure
plot(matdate(asit_surf_ind), pigment(asit_surf_ind,7), 'r.-')
hold on
plot(matdate(asit_surf_ind), pigment_b(asit_surf_ind,7), 'r+')
ylabel('Pigment Conc (ug/L)')
datetick('x', 10)
title('But-Alloxanthin - unique to cryptomonads')

figure
plot(matdate(asit_surf_ind), pigment(asit_surf_ind,27), 'r.-')
hold on
plot(matdate(asit_surf_ind), pigment_b(asit_surf_ind,27), 'r+')
ylabel('Pigment Conc (ug/L)')
datetick('x', 10)
title('Prasinoxanthin - unique to cryptomonads')