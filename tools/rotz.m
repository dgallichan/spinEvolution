function [rz] = rotz(theta)
%function [rz] = rotz(theta)
%
% returns rotation matrix of theta degrees about z axis 
%

  th2 = theta*pi/180;

  rz = [cos(th2)  sin(th2)  0 ;...
	-sin(th2) cos(th2)  0 ;...
	     0        0     1 ];