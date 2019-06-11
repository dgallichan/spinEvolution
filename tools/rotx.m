function [rx] = rotx(theta)
%function [rx] = rotx(theta)
%
% returns rotation matrix of theta degrees about x axis 
%

  th2 = theta*pi/180;

  rx = [1      0        0    ;...
	0  cos(th2) sin(th2) ;...
	0 -sin(th2) cos(th2) ];

