


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%IMPORT SOLID STANDARD VALUES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script for importing data from the following spreadsheet:
%    Workbook: \\sosiknas1\Lab_data\MVCO\mvcodata\mvcochl.xls
%    Worksheet: Solid Std
% Auto-generated by MATLAB on 23-May-2022 16:30:08
%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 22);
% Specify sheet and range
opts.Sheet = "Solid Std";
opts.DataRange = "A2:V250";
% Specify column names and types
opts.VariableNames = ["date", "Fd", "tau", "Lab_notebook", "standard1", "standard2", "standard3", "standard4", "standard5", "standard6", "blank1", "blank2", "blank3", "blank4", "blank5", "blank6", "avgblank", "avg_befpre", "avgafter", "avgstandard", "Comments1", "Comments2"];
opts.VariableTypes = ["datetime", "double", "double", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical", "string"];
% Specify variable properties
opts = setvaropts(opts, ["Comments2"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Lab_notebook", "Comments1", "Comments2"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "date", "InputFormat", "");
% Import the data
chlstandard = readtable("\\sosiknas1\Lab_data\MVCO\mvcodata\mvcochl.xls", opts, "UseExcel", false);
%% Clear temporary variables
clear opts
%read in extra rows that don't necessarily have entries, get rid of empty rows
chlstandard = chlstandard(isfinite(chlstandard.date),:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%IMPORT CALIBRATION VALUES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script for importing data from the following spreadsheet:
%    Workbook: \\sosiknas1\Lab_data\MVCO\mvcodata\mvcochl.xls
%    Worksheet: Tau Fd comparison
% Auto-generated by MATLAB on 23-May-2022 16:25:51
%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 15);
% Specify sheet and range
opts.Sheet = "Tau Fd comparison";
opts.DataRange = "A2:O52";
% Specify column names and types
opts.VariableNames = ["CalDate", "date", "used", "avgblank", "avgstandard", "OD664nm", "OD750nm", "OldTau", "NewTau", "plot_tau_Rsq", "OldFd", "NewFd", "plot_Fd_Rsq", "Fluorometer", "Notes", "RunBy", "Comments"];
opts.VariableTypes = ["string", "datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical", "categorical", "categorical", "string"];
% Specify variable properties
opts = setvaropts(opts, ["CalDate", "Comments"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["CalDate", "Fluorometer", "Notes", "RunBy", "Comments"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "date", "InputFormat", "");
% Import the data
calibration = readtable("\\sosiknas1\Lab_data\MVCO\mvcodata\mvcochl.xls", opts, "UseExcel", false);
% Clear temporary variables
clear opts

%get rid of lines that aren't for Aquafluor8000446
%IMPORTANT this assumes entry is exactly Aquafluor 800446 every time
calibration = calibration(calibration.Fluorometer == 'Aquafluor 800446',:);
clear fluor ind


chlstandard.avgstandard = nanmean([chlstandard.standard1 chlstandard.standard2 chlstandard.standard3 chlstandard.standard4 chlstandard.standard5 chlstandard.standard6],2);


%%%%%%%%%%%%%%%
cal2018pre = datenum('11/1/2018','mm/dd/yyyy');
cal2020pre_otherstep = datenum('1/20/2019','mm/dd/yyyy');
cal2020post = datenum('12/22/2019','mm/dd/yyyy');
cal2022post = datenum('1/1/2022','mm/dd/yyyy');
ind_fakecal_smallstep = find(datenum(chlstandard.date)>cal2018pre & datenum(chlstandard.date)<cal2020pre_otherstep);
ind_fakecal = find(datenum(chlstandard.date)>cal2018pre & datenum(chlstandard.date)<cal2020post);
fakecal_avgsolidstandard = nanmean([chlstandard.standard1(ind_fakecal); chlstandard.standard2(ind_fakecal); chlstandard.standard3(ind_fakecal);chlstandard.standard4(ind_fakecal);chlstandard.standard5(ind_fakecal);chlstandard.standard6(ind_fakecal)]);
text(0.39,28,['fake avg std 27.6778, calc Fd 0.5122'],'color','r')
text(0.4,26.5,['small step, avg std 28.8945, calc Fd 0.5007'],'color','g')

ind = find(~isnan(chlstandard.Fd) & ~isnan(chlstandard.avgstandard));
ind_used = find(calibration.used ==1 & ~isnan(calibration.NewFd));



%%PLOT TREND OF STANDARD OVER TIME
figure
plot(datenum(chlstandard.date), [chlstandard.standard1 chlstandard.standard2 chlstandard.standard3 chlstandard.standard4 chlstandard.standard5 chlstandard.standard6],'b.')
hold on
plot(datenum(chlstandard.date), chlstandard.avgstandard,'r-')
xlabel('Date','fontweight','bold'); ylabel('Fluorometer Reading','fontweight','bold'); title('Solid Standard Aquafluor Fluorometer');
datetick('x','keeplimits')
a=get(gca,'children');
legend(a(1:2),'mean','ind STD reading')
set(gca,'ylim',[20 50])
grid on
%  [FO,goodness] = fit(chlstandard.avg_befpre, chlstandard.avgafter, 'poly1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot(chlstandard.Fd(ind),chlstandard.avgstandard(ind),'.','markersize',14)
hold on
plot(calibration.NewFd(ind_used),calibration.avgstandard(ind_used),'m^')
m = fit(calibration.NewFd(ind_used),calibration.avgstandard(ind_used), 'poly1');
plot(m) %plot just the fit line
legend('all','used','fit USED cals')
% plot(m,chlstandard.Fd(ind),chlstandard.avgstandard(ind)) %plot the fit line and the points
text(0.4,25,['y = ' num2str(m.p1) '*x + ' num2str(m.p2)],'color','r')
grid on;
axis([0.38 0.58 24 44])
xlabel('Fd','fontweight','bold');
ylabel('Avg Chl Sold Standard','fontweight','bold');
title('Fd cal coeff vs chl standard');


figure
plot(calibration.date(ind_used),calibration.NewTau(ind_used),'.','markersize',14)
hold on
plot(calibration.date(ind_used(2:3)),calibration.NewTau(ind_used(2:3)),'m^','markersize',14)
grid on
fakeTau = mean(calibration.NewTau(ind_used(2:3))); %assumes 2&3 are 2018 and 2022 cals
plot(datetime('01-Nov-2018','inputformat','dd-MM-yyy'),fakeTau,'r*','markersize',14)
plot(datetime('01-Nov-2018','inputformat','dd-MM-yyy'),fakeTau,'r.','markersize',14)
plot(calibration.date(ind_used(2:3)),calibration.NewTau(ind_used(2:3)),'m.','markersize',14)
legend('all Tau used','Tau to average for 2019','calculated 2019 Tau')
text(calibration.date(ind_used(11)),1.885,'Calc Tau of Avg 2018 & 2020 = 1.8682','color','r','fontweight','bold')
xlabel('date','fontweight','bold')
ylabel('Tau','fontweight','bold')
title('Tau over time from used calibrations')

figure
plot(chlstandard.tau(ind),chlstandard.avgstandard(ind),'.','markersize',14)
hold on
plot(calibration.NewTau(ind_used),calibration.avgstandard(ind_used),'m^')
m = fit(calibration.NewTau(ind_used),calibration.avgstandard(ind_used), 'poly1');
plot(m) %plot just the fit line
text(1.825,41,['y = ' num2str(m.p1) '*x + ' num2str(m.p2)],'color','r')
xlabel('Tau','fontweight','bold');
ylabel('Avg Chl Sold Standard','fontweight','bold');
title('Tau cal coeff vs chl standard');
legend('all','used','fit USED cals')
fakeTau = (fakecal_avgsolidstandard - m.p2)/m.p1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fakeFd = (fakecal_avgsolidstandard - m.p2)/m.p1;
plot(fakeFd,fakecal_avgsolidstandard,'g*','markersize',6)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Position',[257 154 1016 826])
subplot(221)
plot(chlstandard.Fd(ind),chlstandard.avgstandard(ind),'.','markersize',14)
hold on
plot(calibration.NewFd(ind_used),calibration.avgstandard(ind_used),'m^')
m = fit(chlstandard.Fd(ind),chlstandard.avgstandard(ind), 'poly1');
plot(m) %plot just the fit line
legend('all','used','fit all')
% plot(m,chlstandard.Fd(ind),chlstandard.avgstandard(ind)) %plot the fit line and the points
text(0.4,25,['y = ' num2str(m.p1) '*x + ' num2str(m.p2)],'color','r')
grid on;
axis([0.38 0.58 24 44])
xlabel('Fd','fontweight','bold');
ylabel('Avg Chl Sold Standard','fontweight','bold');
title('Fd cal coeff vs chl standard');

subplot(222)
plot(chlstandard.tau(ind),chlstandard.avgstandard(ind),'.','markersize',14)
hold on
plot(calibration.NewTau(ind_used),calibration.avgstandard(ind_used),'m^')
m = fit(chlstandard.tau(ind),chlstandard.avgstandard(ind), 'poly1');
plot(m) %plot just the fit line
legend('all','used','fit all')
% plot(m,chlstandard.tau(ind),chlstandard.avgstandard(ind))%plot the fit line and the points
axis([1.80 1.92 24 44])
text(1.81,43,['y = ' num2str(m.p1) '*x + ' num2str(m.p2)],'color','r')
grid on;
xlabel('Tau','fontweight','bold');
ylabel('Avg Chl Sold Standard','fontweight','bold');
title('Tau cal coeff vs chl standard');

subplot(223)
plot(chlstandard.date(ind),chlstandard.Fd(ind)./chlstandard.avgstandard(ind),'.','markersize',15)
hold on
grid on;
xlabel('Date','fontweight','bold');
ylabel('Ratio Fd : Chl Sold Standard','fontweight','bold');
title('Ratio Fd: Chl standard over time');

subplot(224)
plot(chlstandard.date(ind),chlstandard.tau(ind)./chlstandard.avgstandard(ind),'.','markersize',15)
hold on
grid on;
xlabel('Date','fontweight','bold');
ylabel('Ratio Tau : Chl Sold Standard','fontweight','bold');
title('Ratio Tau: Chl standard over time');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind = find(~isnan(chlstandard.Fd) & ~isnan(chlstandard.avgstandard));
%{
figure('Position',[257 154 1016 826])
subplot(221)
plot(chlstandard.avgstandard(ind),chlstandard.Fd(ind),'.','markersize',14)
hold on
m = fit(chlstandard.avgstandard(ind),chlstandard.Fd(ind), 'poly1');
plot(m,chlstandard.avgstandard(ind),chlstandard.Fd(ind))
text(0.41,29,['y = ' num2str(m.p1) '*x + ' num2str(m.p2)],'color','r')
grid on;
xlabel('Avg Chl Sold Standard','fontweight','bold');
ylabel('Fd','fontweight','bold');
title('Fd cal coeff vs chl standard');

subplot(222)
plot(chlstandard.avgstandard(ind),chlstandard.tau(ind),'.','markersize',14)
hold on
m = fit(chlstandard.avgstandard(ind),chlstandard.tau(ind), 'poly1');
plot(m,chlstandard.avgstandard(ind),chlstandard.tau(ind))
text(1.83,41.5,['y = ' num2str(m.p1) '*x + ' num2str(m.p2)],'color','r')
grid on;
xlabel('Avg Chl Sold Standard','fontweight','bold');
ylabel('Tau','fontweight','bold');
title('Tau cal coeff vs chl standard');
%}

% PLOT Fd TREND AND CHL STANDARD OVER TIME
figure
yyaxis left
plot(datenum(chlstandard.date), chlstandard.avgstandard, '.','markersize',10)
ylim([20 50])
ylabel('Avg Chl Standard','fontweight','bold');
yyaxis right
plot(datenum(calibration.date),calibration.NewFd,'*-')
ylabel('Fd Calibration Coeff','fontweight','bold')
datetick('x','keeplimits')
ylim([0.25 0.75])
grid on
xlabel('Date','fontweight','bold');


%%%%%%%%%plotting standard before and after readings
%{
ind = ~isnan(chlstandard.avgafter) & ~isnan(chlstandard.avg_befpre);
p = polyfit(chlstandard.avg_befpre(ind),chlstandard.avgafter(ind),1);
f = polyval(p,chlstandard.avg_befpre);

figure
plot(chlstandard.avg_befpre,chlstandard.avgafter,'.')
hold on
line([20 45], [20 45],'color','k')
plot(chlstandard.avg_befpre,f,'r--')
xlabel('Standard Before','fontweight','bold');ylabel('Standard After','fontweight','bold'); title('Solid Standard Readings Before vs After Running')
text(22,43,[num2str(p(1)) '*y +' num2str(p(2))],'color','r')
grid on
%}
%%
figure
yyaxis left
plot(chlstandard.avgstandard,chlstandard.Fd,'.','markersize',13)
ylabel('Fd','fontweight','bold')
yyaxis right
plot(chlstandard.avgstandard,chlstandard.tau,'^','markersize',6)
ylabel('Tau','fontweight','bold')
xlabel('Average Solid Standard','fontweight','bold')
grid on
title('Chl Standard and Fd over time')

