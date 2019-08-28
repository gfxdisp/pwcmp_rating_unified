function [Q, a, b, c,d] = mixing(D, M_os, datasets)
% Scaling method for pairwise comparisons & rating
%
% [Q, a, b, c] = mixing(D, M_os, datasets)
%
% D - NxN matrix with positive integers. D(i,j) = k means that the
%     condition i was better than j in k number of trials.
% M_os - NxJ matrix with collected ratings, where J is the number of 
% observers. If a rating was no collected for a specific observer or object
% just fill it with NaNs.
% datasets - initial guess for the scale (used as first point for the 
% optimisation).

% Note that D and M_os need to be ordered in the same fashion

% Q - Quality scale. The difference of 1 corresponds to
%     75% of answers selecting one condition over another.
% a, b and c - trained parameters that indicate scale and noise. c is 
% associated to the noise of rating vs pairwise comparisons, if c > 1 the 
% noise of rating is larger than that of pwc. 
%
% The condition with index 1 (the first row in D) has the score fixed at 
% value 0. Always put "reference" condition at index 1. 
%
% The method scaled the data by solving for maximum-likelihood-estimator
% explaining the collected data. For more details please refer to:
%
% 
%


% For this sigma normal cummulative distrib is 0.75 @ 1
sigma_cdf = 1.4826; 
sigma = sigma_cdf/(sqrt(2));

% The number of compared conditions
N = size( D, 1 );  

if( size(D,1) ~= size(D,2) )
    error( 'The comparison matrix must be square' );
end

numb_datasets = numel(datasets);

options = optimset( 'Display', 'off', 'LargeScale', 'off', 'MaxIter', 1000 );

% Find non-zero elements in matrix D+D', i.e. compared conditions
Dt = D';
D_sum = D + Dt;
nnz_d = (D_sum)>0;
comp_made = D(nnz_d);

% Find measured elements in the MOS matrix
measured_os = ~isnan(M_os);


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
b_init  = ones(1, numb_datasets);
c_init  = ones(1, numb_datasets);
d_init  = ones(1, numb_datasets)*0.001;
q_init = zeros(N-1,1);
initial_value = [q_init; a_init'; b_init'; c_init'];
% The methods tend to be more robust if starting scores are 0
[Q,fval,~,output] = fminunc( @exp_prob, initial_value, options );
% Add missing leading 0-score for the first condition (not optimized)
a = Q(end-3*numb_datasets+1:end-2*numb_datasets);
b = Q(end-2*numb_datasets+1:end-1*numb_datasets);
c = Q(end-1*numb_datasets+1:end);
d = 1;
Q  = [0;Q(1:N-1)];


    function P = exp_prob( opt_params )
        q  = [0;opt_params(1:N-1)];
        
        at = opt_params(end-3*numb_datasets+1:end-2*numb_datasets);
        bt = opt_params(end-2*numb_datasets+1:end-1*numb_datasets);
        ct = opt_params(end-1*numb_datasets+1:end);
        a = [];
        b = [];
        c = [];
        for dd = 1:numb_datasets
            len_ds = datasets(dd);
            a = [a; ones(len_ds,1)*at(dd)];
            b = [b; ones(len_ds,1)*bt(dd)]; 
            c = [c; ones(len_ds,1)*ct(dd)]; 
        end
        
        Dd = repmat( q, [1 N] ) - repmat( q', [N 1] ); % Compute the distances
        Pd = normcdf( Dd, 0, sigma_cdf ); % and probabilities

        prior = normpdf(q, mean(q), sqrt(N)*sigma); 
        
        p_pwc = NK_nnz_d.*Pd(nnz_d).^comp_made.*(1-Pd(nnz_d)).^Dt_nnz_d;
        
        p_mos = normpdf(  M_os,  repmat(a.*q+b,1,size(M_os,2)), a.*c*sigma);
       
        p_mos(~ measured_os) =1.0;
        P1 = (-sum( log( max( p_pwc, 1e-200) ) ));
        P2 = (-sum(sum( log( max( p_mos , 1e-200) ) )));
        P3 = - sum(log(prior));
        P = P1 + P2 + P3;
    end

% % Pre-initialise the quantities being computed and merge them into one
% % variable. Note that q_init has N-1 elements. This is because the first
% % conditions score is set to 0.
% a_init = ones(1, numb_datasets);
% b_init  = ones(1, numb_datasets);
% c_init  = ones(1, numb_datasets);
% q_init = zeros(N-1,1);
% initial_value = [q_init; a_init'; b_init'; c_init'];
% 
% % The methods tend to be more robust if starting scores are 0
% [Q,~,~,~] = fminunc( @exp_prob, initial_value, options );
% 
% % Add missing leading 0-score for the first condition (not optimized) and
% % store the results.
% a = Q(end-3*numb_datasets+1:end-2*numb_datasets);
% b = Q(end-2*numb_datasets+1:end-numb_datasets);
% c = Q(end-numb_datasets+1:end);
% Q  = [0;Q(1:N-1)];


%     function P = exp_prob( opt_params )
%         
%         % Get quality scores
%         q  = [0;opt_params(1:N-1)];
%         % Get a,b and c
%         at = opt_params(end-3*numb_datasets+1:end-2*numb_datasets);
%         bt = opt_params(end-2*numb_datasets+1:end-numb_datasets);
%         ct = opt_params(end-numb_datasets+1:end);
%         
%         % Copy a, b and c into arrays e.g. for two datasets with k and n 
%         % elements a array is [a11,a12,...a1k,a21,a22,...a2n]. 
%         a = [];
%         b = [];
%         c = [];
%         for dd = 1:numb_datasets
%             len_ds = datasets(dd);
%             %uncoment to optimise a and b.
%             %a = [a; ones(len_ds,1)];
%             %b = [b; zeros(len_ds,1)*bt(dd)]; 
%             c = [c; ones(len_ds,1)*ct(dd)]; 
%             a = [a; ones(len_ds,1)*at(dd)];
%             b = [b; ones(len_ds,1)*bt(dd)]; 
%             
%         end
%         
%         % Compute the distances
%         Dd = repmat( q, [1 N] ) - repmat( q', [N 1] ); 
%         % And probabilities
%         Pd = normcdf( Dd, 0, sigma_cdf ); 
%         % Compute the prior
%         prior = normpdf(q, mean(q), sqrt(N)*sigma); 
%         % Compute binomial for the pairwise comparisons
%         p_pwc = NK_nnz_d.*Pd(nnz_d).^comp_made.*(1-Pd(nnz_d)).^Dt_nnz_d;
%         % Compute the probability distribution for mean opinion scores
%         
%         p_mos = normpdf(  M_os,  repmat(a.*q+b,1,size(M_os,2)), a.*c*sigma);
%         % Replace NaN with 1s (log turns them into 0s)
%         p_mos(~ measured_os) =1.0;
%         % Compute the Log likelihood for each of the terms and sum
%         P1 = (-sum( log( max( p_pwc, 1e-200) ) ));
%         P2 = (-sum(sum( log( max( p_mos , 1e-200) ) )));
%         P3 = - sum(log(prior));
%         P = P1 + P2 + P3;
%     end

end

