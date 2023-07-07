%last update 4/5/10 by taylor
%Flag bad CTD data. Manually look at cast data and determine if it should
%be red flagged. This uses the 4 dimensional matrix that groups the 3rd
%matrix dimension by station i.e. ctd_down(:,:,1,:) refers to all casts for
%station 1 ctd_down(:,:,2,:) refers to all casts for station 2, etc. There
%is a full matrix of NaN's if there is a date with no cast for a station.
%!!!!! Do not NaN out the date, lat, lon ever!! 2nd matrix dimension
%columsn 18:20!!
load ctd_data2

%5/21/07 - no station 1 or 6

%8/25/07 - no station 1
ctd_down(:,11,:,2) = NaN;
ctd_up(:,11,:,2) = NaN;

%9/13/07 - only ASIT
ctd_up(10:11,8,4,3) = NaN;

%10/11/07
ctd_down(11:13,8,4,4) = NaN;

ctd_down(10:11,3:5,2,4) = NaN;

ctd_down(:,11,:,4) = NaN;
ctd_up(:,11,:,4) = NaN;
ctd_down(:,9,:,4) = NaN;
ctd_up(:,9,:,4) = NaN;

%ctd_down(10:11,3:5,2,4) = ctd_up(10:11,3:5,2,4);
%ctd_down(:,8,4,4) = ctd_up(:,8,4,4);

%1/16/08
ind = find(ctd_down(:,1,8,5) < 4);
ctd_down(ind,3:6,8,5) = NaN;
ind = find(ctd_down(:,1,8,5) < 2.5);
ctd_down(ind,7,8,5) = NaN;
ind = find(ctd_down(:,1,8,5) < 3);
ctd_down(ind,10,8,5) = NaN;

ctd_up(12:13,8,7,5) = NaN;
ind = find(ctd_down(:,1,7,5) < 4);
ctd_down(ind,3:6,7,5) = NaN;
ctd_down(ind,10,7,5) = NaN;

ind = find(ctd_down(:,1,6,5) < 4);
ctd_down(ind,3:6,6,5) = NaN;
ctd_down(ind,10,6,5) = NaN;

ctd_down(8:9,2:17,5,5) = NaN;
ctd_down(1:17,2:17,5,5) = NaN;
ind = find(ctd_up(:,1,5,5) <2.5);
ctd_up(ind,3:6,5,5) = NaN;
ctd_up(ind,8:10,5,5) = NaN;
ctd_up(5:8,3:6,4,5) = NaN;

ind = find(ctd_down(:,1,4,5) < 3);
ctd_down(ind,3:10,4,5) = NaN;

ind = find(ctd_down(:,1,3,5) < 3.5);
ctd_down(ind,3:6,3,5) = NaN;
ctd_down(ind,10,3,5) = NaN;
ind = find(ctd_up(:,1,3,5) < 1.75);
ctd_up(ind,3:10,3,5) = NaN;
ind = find(ctd_up(:,1,3,5) < 3);
ctd_up(ind,8,3,5) = NaN;


ctd_down(:,9,:,5) = NaN;
ctd_up(:,9,:,5) = NaN;
ctd_down(:,11,:,5) = NaN;
ctd_up(:,11,:,5) = NaN;

%3/13/08
ind = find(ctd_down(:,1,7,6) < 2.25);
ctd_down(ind,3:6,7,6) = NaN;
ind = find(ctd_down(:,1,7,6) < 1.25);
ctd_down(ind,8:10,7,6) = NaN;

ind = find(ctd_down(:,1,6,6) < 1.5);
ctd_down(ind,8,6,6) = NaN;
ctd_down(ind,3:6,6,6) = NaN;

ind = find(ctd_down(:,1,5,6) < 1.75);
ctd_down(ind,10,5,6) = NaN;
ctd_down(ind,3:6,5,6) = NaN;
ind = find(ctd_down(:,1,5,6) < 1.25);
ctd_down(ind,7:8,5,6) = NaN;

ind = find(ctd_down(:,1,4,6) < 1.5);
ctd_down(ind,3:10,4,6) = NaN;

ctd_down(9:11,4:6,3,6) = NaN;

ind = find(ctd_down(:,1,2,6) < 1.25);
ctd_down(ind,3:10,2,6) = NaN;

ctd_down(:,9,:,6) = NaN;
ctd_up(:,9,:,6) = NaN;
ctd_down(:,11,:,6) = NaN;
ctd_up(:,11,:,6) = NaN;

%5/23/08
ctd_down(11,8,8,7) = NaN;

ctd_down(9:11,8,6,7) = NaN;

ind = find(ctd_up(:,1,1,7) < 0.5);
ctd_up(ind,3:10,1,7) = NaN;

ctd_down(:,9,:,7) = NaN;
ctd_up(:,9,:,7) = NaN;
ctd_down(:,11,:,7) = NaN;
ctd_up(:,11,:,7) = NaN;

%6/27/08
ctd_down(:,9,:,8) = NaN;
ctd_up(:,9,:,8) = NaN;
ctd_down(:,11,:,8) = NaN;
ctd_up(:,11,:,8) = NaN;

%7/17/08
ind = find(ctd_down(:,1,8,9) < 2.5);
ctd_down(ind,3:6,8,9) = NaN;
ctd_down(ind,10,8,9) = NaN;

ind = find(ctd_down(:,1,3,9) < 2.25);
ctd_down(ind,4:6,3,9) = NaN;
ctd_down(ind,8:10,3,9) = NaN;

ctd_down(:,9,:,9) = NaN;
ctd_up(:,9,:,9) = NaN;
ctd_down(:,11,:,9) = NaN;
ctd_up(:,11,:,9) = NaN;

%7/31/08
ctd_down(:,9,:,10) = NaN;
ctd_up(:,9,:,10) = NaN;
ctd_down(:,11,:,10) = NaN;
ctd_up(:,11,:,10) = NaN;

%9/11/08
ind = find(ctd_down(:,1,3,11) < 2.5);
ctd_down(ind,4:8,3,11) = NaN;
ctd_up(8,7,3,11) = NaN;

ind = find(ctd_down(:,1,4,11) < 2.75);
ctd_down(ind,4:6,4,11) = NaN;

ind = find(ctd_down(:,1,2,11) < 2.5);
ctd_down(ind,4:6,3,11) = NaN;

ctd_down(:,9,:,11) = NaN;
ctd_up(:,9,:,11) = NaN;
ctd_down(:,11,:,11) = NaN;
ctd_up(:,11,:,11) = NaN;

%10/6/08 ASIT only
ctd_down(14,4:6,4,12) = NaN;
ctd_down(14,10,4,12) = NaN;

ctd_down(:,9,:,12) = NaN;
ctd_up(:,9,:,12) = NaN;
ctd_down(:,11,:,12) = NaN;
ctd_up(:,11,:,12) = NaN;

%10/11/08 ASIT only - no water samples for
ind = find(ctd_down(:,1,4,13) < 2.5);
ctd_down(ind,3:6,4,13) = NaN;
ctd_down(ind,10,4,13) = NaN;

ctd_down(:,9,:,13) = NaN;
ctd_up(:,9,:,13) = NaN;
ctd_down(:,11,:,13) = NaN;
ctd_up(:,11,:,13) = NaN;

%10/24/08 ASIT only
ctd_down(:,9,:,14) = NaN;
ctd_up(:,9,:,14) = NaN;
ctd_down(:,11,:,14) = NaN;
ctd_up(:,11,:,14) = NaN;

%11/13/08 no st 2
ind = find(ctd_down(:,1,7,15) < 3.5);
ctd_down(ind,4:6,7,15) = NaN;
ctd_down(ind,10,7,15) = NaN;

ctd_down(9,3:6,3,15) = NaN;
ctd_down(9,8:10,3,15) = NaN;

ctd_down(10,3:7,1,15) = NaN;
ctd_down(10,10,1,15) = NaN;

ctd_down(:,9,:,15) = NaN;
ctd_up(:,9,:,15) = NaN;
ctd_down(:,11,:,15) = NaN;
ctd_up(:,11,:,15) = NaN;

%4/27/09
ctd_up(9,4:7,8,16) = NaN;
ctd_up(9,10,8,16) = NaN;

ind = find(ctd_up(:,1,5,16) <2.5);
ctd_up(ind,4:6,5,16) = NaN;
ctd_up(ind,10,5,16) = NaN;

ind = find(ctd_up(:,1,4,16) <3.25);
ctd_up(ind,4:6,4,16) = NaN;

ctd_down(:,4:6,2,16) = ctd_up(:,4:6,2,16);

ctd_down(:,4:6,1,16) = ctd_up(:,4:6,1,16);

ctd_down(:,9,:,16) = NaN;
ctd_up(:,9,:,16) = NaN;
ctd_down(:,11,:,16) = NaN;
ctd_up(:,11,:,16) = NaN;

%6/4/09
ctd_down(1:9,3:10,8,17) = NaN;

ctd_down(9,3:10,6,17) = NaN;

ctd_down(9,4:6,5,17) = NaN;

ctd_down(:,9,:,17) = NaN;
ctd_up(:,9,:,17) = NaN;
ctd_down(:,11,:,17) = NaN;
ctd_up(:,11,:,17) = NaN;

%7/30/09 ASIT only
ctd_down(1:9,3:10,4,18) = NaN;

ctd_down(:,9,:,18) = NaN;
ctd_up(:,9,:,18) = NaN;
ctd_down(:,11,:,18) = NaN;
ctd_up(:,11,:,18) = NaN;

%8/12/09
ctd_down(1:7,3:10,7,19) = NaN;

ind = find(ctd_down(:,1,5,19) < 1.5);
ctd_down(ind,3:10,5,19) = NaN;

ind = find(ctd_down(:,1,4,19) < 3);
ctd_down(ind,3:6,4,19) = NaN;

ind = find(ctd_down(:,1,2,19) < 2.5);
ctd_down(ind,3:6,2,19) = NaN;

ind = find(ctd_down(:,1,1,19) < 1.5);
ctd_down(ind,4:7,1,19) = NaN;

ind = find(ctd_down(:,1,1,19) < 1.25);
ctd_down(ind,3,1,19) = NaN;
ctd_down(ind,8:10,1,19) = NaN;

ctd_down(:,9,:,19) = NaN;
ctd_up(:,9,:,19) = NaN;
ctd_down(:,11,:,19) = NaN;
ctd_up(:,11,:,19) = NaN;

%10/21/09
ind = find(ctd_down(:,1,8,20) < 1);
ctd_down(ind,3:6,8,20) = NaN;

ind = find(ctd_down(:,1,7,20) < 1.5);
ctd_down(ind,3:10,7,20) = NaN;

ind = find(ctd_down(:,1,5,20) < 1.25);
ctd_down(ind,3:7,5,20) = NaN;
ctd_down(ind,10,5,20) = NaN;
ind = find(ctd_down(:,1,5,20) < 2.0);
ctd_down(ind,8,5,20) = NaN;

ind = find(ctd_down(:,1,4,20) < 3);
ctd_down(ind,4:6,4,20) = NaN;

ind = find(ctd_down(:,1,1,20) < 1.5);
ctd_down(ind,3:10,1,20) = NaN;

ctd_down(:,9,:,20) = NaN;
ctd_up(:,9,:,20) = NaN;
ctd_down(:,11,:,20) = NaN;
ctd_up(:,11,:,20) = NaN;

%2/9/10 ASIT only

ctd_down(:,9,:,21) = NaN;
ctd_up(:,9,:,21) = NaN;
ctd_down(:,11,:,21) = NaN;
ctd_up(:,11,:,21) = NaN;

%try and use down cast for each cast unless data is suspect. then
%substitute upcast values into downcast for as much data coverage as
%possible?

%for i = 1:size(ctd_down,4)
%    for j = 1:size(ctd_down,3)
%        for k = 1:size(ctd_down,2)
%            ind = find(isnan(ctd_down(:,k,j,i)));
%            ctd_down(ind,k,j,i) = ctd_up(ind,k,j,i);
%        end
%    end
%end

clear i ind j k ans depth_bins
                
save ctd_data_edited