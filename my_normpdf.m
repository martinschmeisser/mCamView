function p = my_normpdf(x, mu, sigma)
%MY_NORMPDF normal distribution
% returns the normalized propability of a normal distribution (gaussian)
% with center mu, spread sigma
    p = 1/(sqrt(2*pi)*sigma) * exp(-(1/2)*((x-mu)/sigma).^2);
end