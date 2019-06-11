function [ry] = roty(theta)
%function [ry] = roty(theta)
%
% returns rotation matrix of theta degrees about y axis 
%

  th2 = theta*pi/180;

  ry = [cos(th2)     0  -sin(th2) ;...
	    0	     1      0     ;...
	sin(th2)     0   cos(th2) ];

