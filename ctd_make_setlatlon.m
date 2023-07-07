setcoord =[1.0000   41.1200   41.1700  -70.5300  -70.6000;
    2.0000   41.1900   41.2100  -70.5500  -70.6000;
    3.0000   41.2300   41.2700  -70.5300  -70.6000;
    4.0000   41.3100   41.3300  -70.5600  -70.5800;
    5.0000   41.3300   41.3400  -70.5500  -70.5670;
    6.0000   41.3200   41.3500  -70.5900  -70.6900;
    7.0000   41.3200   41.3350  -70.4900  -70.5200;
    8.0000   41.3000   41.3350  -70.4100  -70.4600];

setcoord_header={'station no'; 'bottom (S) lat'; 'top (N) lat'; 'right (E) lon';'left (W) lon'};

save setlatlon setcoord_header setcoord

%.m files that reference station coordinates, i.e. setlatlon.mat
%ctd_make2.m
%chl_reps.m
%HPLC_reps.m
%nut_reps.m
%check_coord.m
%ctd_tempmake.m
%MVCO_sample_reps.m
%HPLC_label_stations.m - obsolete - in C:\data\mvcodata\matlab_files\old_matfiles