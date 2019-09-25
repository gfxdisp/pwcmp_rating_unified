function [Q, a, b, c] = mixing_with_ref(D, M, datasets_sizes)
% Scaling method for pairwise comparisons & rating
%
% [Q, a, b, c] = mixing(D, M, datasets_sizes)
%
% D - NxN matrix with positive integers. D(i,j) = k means that the
%     condition i was better than j in k number of trials. N - is the total
%     number of conditions in all datasets.
% M - NxK matrix with collected ratings, where K is the number of 
% observers. If a rating was not collected for a specific observer or object
% just fill it with NaNs.
% datasets_sizes - 1d array containing number of conditions in each of the 
% datasets.

% Note that D and M must have condition scores in the same order

% The methd returns:
%
% Q - Quality scale. The difference of 1 corresponds to
%     75% of answers selecting one condition over another.
% a, b and c - parameters that indicate scale and noise. c is the relative 
% noisiness of rating versus pairwise comparisons scales, if c > 1 the 
% noise of rating is larger than that of pwc. 
%
% The condition with index 1 (the first row in D) has the score fixed at 
% value 0. Always put "reference" condition at index 1. 
%
% The method scaled the data by solving for maximum-likelihood-estimator
% explaining the collected data. For more details please refer to:

% For this sigma normal cummulative distrib is 0.75 @ 1
sigma_cdf = 1.4826; 
sigma = sigma_cdf/(sqrt(2));

% The number of compared conditions
N = size( D, 1 );  

if( size(D,1) ~= size(D,2) )
    error( 'The comparison matrix must be square' );
end

if( size(D,1) ~= size(M,1) )
    error( 'Matrices M and D must be of the same size' );
end

numb_datasets = numel(datasets_sizes);

options = optimset( 'Display', 'off', 'LargeScale', 'off', 'MaxIter', 5000 );

% Find non-zero elements in matrix D+D', i.e. compared conditions
Dt = D';
D_sum = D + Dt;
nnz_d = (D_sum)>0;
comp_made = D(nnz_d);

% Find measured elements in the MOS matrix
measured_os = ~isnan(M);

% Precomute N choose k for the MLE of the binomial, makes the code faster
NK = zeros(N,N);
for ii=1:N
    for jj=1:N
        NK(ii,jj) = nchoosek( D_sum(jj,ii), D(ii,jj) );
    end
end
% Use only non-zero elements
NK_nnz_d = NK(nnz_d);
Dt_nnz_d = Dt(nnz_d);

a_init = ones(1, numb_datasets);
b_init = ones(1, numb_datasets);
c_init = ones(1, numb_datasets);

q_init = zeros(N-numb_datasets,1);
initial_value = [q_init; a_init'; b_init'; c_init'];

[params,~,~,~] = fminunc( @exp_prob, initial_value, options);

% Add missing leading 0-score for the first condition (not optimized)
a = params(end-3*numb_datasets+1:end-2*numb_datasets);
b = params(end-2*numb_datasets+1:end-1*numb_datasets);
c = params(end-1*numb_datasets+1:end);

Q = [];
start_ii = 1;
for ii = 1:numb_datasets
    end_ii = (sum(datasets_sizes(1:ii))-ii);
    Q = [Q; 0; params(start_ii:end_ii)];
    start_ii = end_ii+1;
end

    function P = exp_prob( opt_params )

        q = [];
        start_id =1;
        for kk = 1:numb_datasets
            end_id = (sum(datasets_sizes(1:kk))-kk);
            q = [q; 0; opt_params(start_id:end_id)];
            start_id = end_id+1;
        end
        %q  = [0;opt_params(1:N-1)];
        
        at = opt_params(end-3*numb_datasets+1:end-2*numb_datasets);
        bt = opt_params(end-2*numb_datasets+1:end-1*numb_datasets);
        ct = opt_params(end-1*numb_datasets+1:end);
        a = [];
        b = [];
        c = [];
        for dd = 1:numb_datasets
            len_ds = datasets_sizes(dd);
            a = [a; ones(len_ds,1)*at(dd)];
            b = [b; ones(len_ds,1)*bt(dd)]; 
            c = [c; ones(len_ds,1)*ct(dd)]; 
        end
        
        Dd = repmat( q, [1 N] ) - repmat( q', [N 1] ); % Compute the distances
        Pd = normcdf( Dd, 0, sigma_cdf ); % and probabilities

        prior = normpdf(q, mean(q), sqrt(N)*sigma); 

        p_pwc = NK_nnz_d.*Pd(nnz_d).^comp_made.*(1-Pd(nnz_d)).^Dt_nnz_d;

        p_mos = normpdf(  M,  repmat(a.*q+b,1,size(M,2)), a.*c*sigma);
       
        p_mos(~ measured_os) =1.0;
        P1 = (-sum( log( max( p_pwc, 1e-200) ) ));
        P2 = (-sum(sum( log( max( p_mos , 1e-200) ) )));
        P3 = - sum(log(prior));
        P = P1 + P2 + P3;
    end

end

