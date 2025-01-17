function [sigma,mu,A]=mygaussfit(x,y,h)

%
% [sigma,mu,A]=mygaussfit(x,y)
% [sigma,mu,A]=mygaussfit(x,y,h)
%
% fit to the function
% y=A * exp( -(x-mu)^2 / (2*sigma^2) )
%
% the fitting is been done by a polyfit to
% the log of the data.
%
% h is the threshold which is the fraction
% from the maximum y height that the data
% is been taken from.
% h should be a number between 0-1.
% if h have not been taken it is set to be 0.2
% as default.
%


%% threshold
if nargin==2, h=0.2; end

%% cutting
y = y - min(y);
ymax=max(y);
index = find(y>ymax*h);
y=reshape(y,1,max(size(y)));

%% fitting
p=polyfit(x(index),log(y(index)),2);
%y1 = polyval(p,x);
%plot(x,y1)
A2=p(1);
A1=p(2);
A0=p(3);
sigma=sqrt(-1/(2*A2));
mu=A1*sigma^2;
A=exp(A0+mu^2/(2*sigma^2));

