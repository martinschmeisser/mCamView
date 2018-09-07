function [p, X, Y] = my_normpdf2D(x, y, mu, sigma, rho)
%MY_NORMPDF2D two-dimensional normal distribution
% returns the normalized propability of a 2D normal distribution (gaussian)
% with center mu, spread sigma and correlation factor rho
    x = x-mu(1);
    y = y-mu(2);
    disp(sigma);
    disp(sigma(1)^2);
    [X,Y] = meshgrid(x,y);
    
    p = 1/(sqrt(2*pi)*sigma(1)*sigma(2))* exp( ((X.^2./(sigma(1)^2) + Y.^2./(sigma(2)^2)) + 2*rho*X.*Y/(sigma(1)*sigma(2)) )* (-1/(2*(1 - rho.^2)))) ;
end

