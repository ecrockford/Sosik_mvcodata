function [wvln,acdom,abs_ag]=acdomspecproc_Dec2012(acdomfile,blankfile,zerowvlnmin,zerowvlnmax);
%updated by Taylor Ded 18, 2012 - seadas wants absorbance (optical density)
%for ap, ad, and ag now, we only submitted the absorption coefficients in the past
%
%
% [wvln,acdom]=acdomspecproc(acdomfile,blankfile, zerowvlnmin,zerowvlnmax);
% Processes acdom files from UVwinlab and PE Lambda 18.
% acdomfile is the filename, zerowvlnmin and zerowvlnmax define the 
% range of wavelengths over which the zero offset is calculated.

% Ru Morrison, 28 June 2001.

% load file
% Files from UVwinlab for the lambda 18 have 86 header lines before the data
%clear

[acdom,header]=file_read(acdomfile,86);
wvln=acdom(:,1); acdom=acdom(:,2); 
abs_ag = acdom; %added by Taylor Dec 18,2012 - seabass wants absorbance (optical density) now too
if ~isempty(blankfile) & ~strcmp(blankfile,'-9999') % load blank file if given'
  [blank,headerb]=file_read(blankfile,86);
   wvlnb=blank(:,1); blank=blank(:,2);
  % Check if blank file has same wavelengths if not display error message stop
   if wvlnb~=wvln
      disp('Warning: wavelengths in blank file not the same as in acdom file')
      return
   end
  % subtract blank from acdom
   acdom=acdom-blank;
end

zerowvlns=find(wvln>=zerowvlnmin & wvln<=zerowvlnmax); % define zeroing range
acdomzero=mean(acdom(zerowvlns)); % Calculate zero
acdom=acdom-acdomzero;  % apply zero
acdom=2.3*acdom*10;



