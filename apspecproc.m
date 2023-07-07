function [wvln,ap,aph,ad]=apspecproc(apfilename,adfilename,volfilt,filterarea,zerowvlnmin,zerowvlnmax);

% [wvln,ap,aph,ad]=apspecproc('apfilename','adfilename',volfilt,filterarea,zerowvln,zerowindow);
% Processes spectra obtained using the QFT with the algorithm of Mitchell et al.,
% 1990. volfilt is the volume filtered in m^3, filterarea is the area of the filter
% containing the particles in m^2 (pi*radius^2).  (N.B. 1ml=1e-6 m^3 and 1cm^2 = 1e-4 m^2).
% zerowvlnmin and zerowvlnmax are the max and min wavelenngths to be used to calculate
% the zero offset.

% Ru Morrison, 28 June 2001.

% Factors from Mitchell et al., 1990
Mitcha=.392; Mitchb=.655;

if ~isempty(apfilename) & ~strcmp(apfilename,'-9999')
   % load files
   % Files from UVwinlab for the lambda 18 have 86 header lines before the data
   [ap,header]=file_read(apfilename,86);
   apwvln=ap(:,1); ap=ap(:,2);  
   zerowvlns=find(apwvln>=zerowvlnmin & apwvln<=zerowvlnmax); % define zeroing range
   apzero=mean(ap(zerowvlns)); % Calculate zero
   ap=ap-apzero;  % apply zero
   ap= Mitcha .* ap + Mitchb .* ap.^2;  % apply algorithm to calculate ODs
   ap=2.3*ap/(volfilt/filterarea);  % calculate ap
end

if (~isempty(adfilename) & ~strcmp(adfilename,'-9999')) %& adfilename~=-9999;
   % load files
   % Files from UVwinlab for the lambda 18 have 86 header lines before the data
   [ad,header]=file_read(adfilename,86);
   adwvln=ad(:,1); ad=ad(:,2);
   adzero=mean(ad(zerowvlns));
   ad=ad-adzero;
   ad= Mitcha .* ad + Mitchb .* ad.^2;
   ad=2.3*ad/(volfilt/filterarea);
end


% Calculate aph or generate variables with -9999

if exist('ap','var') & exist('ad','var')
   % Check that adwvln and apwvln are the same
   if length(apwvln)~=length(adwvln)
      disp('warning: ap and ad wavelengths not the same')
   else
      wvln=apwvln;
   end
   aph=ap-ad;
elseif exist('ap','var') & ~exist('ad','var')
   ad=repmat(-9999,size(ap,1),1);
   aph=repmat(-9999,size(ap,1),1);
   wvln=apwvln;
elseif ~exist('ap','var') & exist('ad','var')
   ap=repmat(-9999,size(ap,1),1);
   aph=repmat(-9999,size(ap,1),1);
   wvln=adwvln;
end


