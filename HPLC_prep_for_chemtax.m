%This file pulls prevelent information from the HPLC mat file created from
%the database and HPLCproc.xl and organizes it in a format that is readily
%inputted into Chemtax to get diatom, flagellate, etc. estimates. 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%!!! need to make sure HPLC_reps has been run first. and that database is
%up to date
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clear all
%loads HPLC, header
load MVCO_HPLC_reps
%combine duplicates into 1 column instead of a&b side by side in matrix for
%less coding later on. make station matrix matchup with new, elongated hplc
%matrix (i.e. a & b samples stacked 1 on top of other - not side by side

%carry over all information from initial matrix. replicate b's actually
%still side by side, but also stucked underneath. later on will cut out
%only stacked part of matrix for specific information
ind=find(strncmp(HPLC(:,60),'HS',2));
start_of_dup=length(HPLC)+1;
HPLC=[HPLC;HPLC(ind,1:7) HPLC(ind,60:111) cellstr(repmat('D',length(ind),1)) cell(length(ind),51)];
station4hplc=num2cell([station4hplc;station4hplc(ind)]);
header4chemtax={'Event Bottle NO.','HS No.','Depth (m)','Date','Month','Monthb','Time_GMT','Station No','Latitude_S','Longitude_E','TChlb','TChlc','Carot',...
    'HexFuc','ButFuc','Allox','Diadin','Diatox','Fucox','Perid','Zeaxan','Neoxan','Violax','Prasin','Lutein','Tchla','Chl_c12','Chl_c3'};
%get out just the MVCO samples (exclude the Cramer cruise samples)
%HPLC_pigments=cell(length(ind),25);
%Bottle number; Sample ID number/HS###; sample depth
ID = [HPLC(:,2) HPLC(:,8) HPLC(:,7)];

%reformat date for proper Chemtax format. Convert to matlab matday number
%because easier to manipulate below.
date=datenum(HPLC(:,3),'yyyy-mm-dd');
%date
date1=cellstr(datestr(date,'mm/dd/yyyy'));
%month number - helpful to divide up data temporally into seasons
date2 = cellstr(datestr(date,'mm'));
%month number to split the year into 2 halves - a specific way to divide up
%the data 'summer' and 'winter'
date3 = num2cell(abs(str2num(cell2mat(date2))-7));
%UTC time hh:mm:ss
time =cell2mat(HPLC(:,4));
time = cellstr(time(:,12:19));
%Lat, Lon
latlon=HPLC(:,5:6);
%TChlb, TChlc, Carot
pig1=HPLC(:,10:12);
%HexFuc
pig2=HPLC(:,14);
%ButFuc
pig3=HPLC(:,13);
%Allox, Diadin, Diatox, Fucox, Perid, Zeaxan
pig4=HPLC(:,15:20);
%Neoxan, Violax
pig5=HPLC(:,31:32);
%Prasin
pig6=HPLC(:,35);
%Lutein
pig7=HPLC(:,30);
%TChla
pig8=HPLC(:,9);
%Chlorophyll_c12, Chlorophyll_c3, 
pig9=HPLC(:,28:29);

%combine all pigment columns, change to double, make all below detection
%limit values (0.000999 and -111) to zero values for chemtax use. BDL
%values were originally supplied as 0.000999 and were changed to -111 in
%late 2013 (for seabass purposes)
data = cell2mat([pig1 pig2 pig3 pig4 pig5 pig6 pig7 pig8 pig9]);
BDL = find(data < 0.001);%below detection limit
data(BDL) = 0;
%use num2cell below to change data double matrix back to cell matrix to
%combine for final variable for ease of using xlswrite below.

%combine all the individual pieces into one usuable matrix. some pieces of
%matrix numbers, other pieces strings, etc.
HPLC_pigments  = [ID date1 date2 date3 time station4hplc latlon num2cell(data)];

%make matrix to register if HPLC samples have duplicates
duplicates = zeros(length(HPLC_pigments),1);
%a value of 1 in the duplicates list means it's replicate A
%ind is from line 14 in this script
duplicates(ind)=1;
%a value of 2 means it's replicate B
%get start_of_dup from line 15. the beginning of the stacked rep b's
duplicates(start_of_dup:end)=2;

%save mat file with all MVCO sample HPLC pigment results
save HPLC_pigments_for_chemtax HPLC_pigments duplicates header4chemtax
save HPLC_pigments_for_chemtax_tempApr2014 HPLC_pigments header4chemtax


%save just surface sample MVCO HPLC's with surface being >= 4m
ind = find(cell2mat(HPLC_pigments(:,3)) <= 4);
HPLC_surf_pig=HPLC_pigments(ind,:);
surf_dup=duplicates(ind);
save HPLC_surface_pigments_for_chemtax HPLC_surf_pig surf_dup header4chemtax
%prep this hpmatday variable so can use date function when labeling excel
hpmatday = date;
clear date
%save in excel format for Emily to use in Chemtax - takes out apostrophe's
%in cell array
%updates HPLC_pigments.xls with a new worksheet with all data. the new worksheet is
%labeled with the date it was update.
excel=[header4chemtax;HPLC_pigments];
[status,message]=xlswrite('HPLC_pigments.xls',excel,['HPLC_Data_' date])

%save pigment version to plot
hpmeta = [ID date1 date2 date3 time station4hplc latlon];
hpdepth = cell2mat(ID(:,3));
hpstation = cell2mat(station4hplc);
hplat = cell2mat(latlon(:,1));
hplon = cell2mat(latlon(:,2));
pigments = cell2mat([pig8 pig1 pig2 pig3 pig4 pig5 pig6 pig7]);
header_pig = {'Tchl','TChlb','TChlc','Carot','HexFuc','ButFuc','Allox','Diadin','Diatox','Fucox','Perid','Zeaxan','Neoxan','Violax','Prasin','Lutein'};
save HPLC_MVCO_pigments4plot.mat hp* header_pig pigments duplicates
clear pig* date8 time ID latlon date* HPLC HPLC_a HPLC_b date header i ind time hp* header_pig start_of_dup

clear excel HPLC_surf_pig message status surf_dup