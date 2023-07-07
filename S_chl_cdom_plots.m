%compare the Slope (S) and acdom (440nm) from mvco data
load S_acdom440_values.mat %this load mat file that was generated after running simbiosasappoc.m

                           
str = num2str(matedate)
matedate = datenum(str,'yyyymmdd')
                           
figure
subplot(2,2,1)
plot(matedate,all_acdom412,'.-','Color','r');
%plot(matedate,slope440,'.-','Color','r');
% % % ax1 = gca;
% % % set(ax1,'XColor','r','YColor','r')
ylabel('acdom 412')
%ylabel('Slope 440')
datetick

% % % ax2 = axes('Position',get(ax1,'Position'),...
% % %            'XAxisLocation','top',...
% % %            'YAxisLocation','right',...
% % %            'Color','none',...
% % %            'XColor','k','YColor','k');
% % % 
load  C:/data/mvcodata/all_chlavg.mat

hold on
plot(matdate(chldepth<4),all_chlavg(chldepth<4),'.-')%'Color','k','Parent',ax2); 
ylabel('Chl (mg m^{-3})')
datetick         

subplot(2,2,3)
load S_acdom440_values.mat %this load mat file that was generated after running simbiosasappoc.m                         
str = num2str(matedate)
matedate = datenum(str,'yyyymmdd')
plot(matedate,all_acdom440,'.-')
 ylabel('a_{cdom} 440')
datetick
                           