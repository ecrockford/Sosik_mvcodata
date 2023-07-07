load ecochlsmoothhr2011
[ mdate_mat1, y_mat1, yearlist, yd ] = timeseries2ydmat_varres( ecosmooth(:,1), ecosmooth(:,7), 1/24 );

load hssmoothhr2011
[ mdate_mat2, y_mat2, yearlist, yd ] = timeseries2ydmat_varres( HSsmooth(:,1), HSsmooth(:,1), 1/24 );

figure
plot(y_mat1, y_mat2, '.')

figure
plot(mdate_mat1, y_mat1./y_mat2, '.')
