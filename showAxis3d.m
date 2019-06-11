function showAxis3d(AxMax,axLabels)
% function showAxis3d(AxMax)
%
% put on some labelled axes in 3d

if nargin < 2
    axLabels = {'x','y','z'};
end

if nargin < 1    AxMax = 1; end

arrowWidth = .1;
arrowHeight = .1;
l3 = line([-AxMax AxMax; 0 0; 0 0]', [0 0;-AxMax AxMax ; 0 0]', [0 0; 0 0;-AxMax AxMax ]');
aX{1} = line([0 0; 0 0]', [-arrowWidth 0; 0 arrowWidth]', [AxMax-arrowHeight AxMax; AxMax AxMax-arrowHeight]);
aX{2} = line([-arrowWidth 0; 0 arrowWidth]', [AxMax-arrowHeight AxMax; AxMax AxMax-arrowHeight], [0 0; 0 0]' );
aX{3} = line([AxMax-arrowHeight AxMax; AxMax AxMax-arrowHeight], [-arrowWidth 0; 0 arrowWidth]',[0 0; 0 0]');

tX{1} = text(AxMax+arrowWidth,0,0,axLabels{1}); tX{2} = text(0,AxMax+arrowWidth,0,axLabels{2}); tX{3} = text(0,0,AxMax+arrowHeight,axLabels{3});

for iX = 1:3
    set(aX{iX},'Color','k','LineWidth',2)
    set(tX{iX},'FontSize',20,'FontWeight','bold')
end
  
set(l3,'Color','k','LineWidth',2)
