function [N,p_gt,D] = setExpParam_varied_jod(q,sigma_jod)

    N = length(q);
    D = repmat( q', [N 1] ) - repmat( q, [1 N] );
    p_gt = normcdf( D, 0, sigma_jod );

end
