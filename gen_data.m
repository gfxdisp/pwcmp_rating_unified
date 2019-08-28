function [C, M, a,b,c] = gen_data(q,datasets,exp_data)
% Function to generate simulated data - pairwise comparisons and mean
% opinion scores from the true quality scores
% 
% [C, M, a,b,c] = gen_data(q,datasets)
% 
% q - true, ground truth quality scores (for all datasets)
% datasets - array with the number of conditions in each of the datasets in
% the same order as in q
%
% returns:
% C - NxN matrix of pairwise comparisons, where N - is the total number of
% conditions. The order of elements corresponds to the order in q. Every
% element c(ii,jj) is the number of times condition ii was selected over
% condition jj
% M - NxO matrix with rating measurements, where N - number of conditions,
% and O is the number of observers. Each element is either m(ii,oo) -
% rating score assigned by an observer oo to condition ii, or NaN - if the
% observer did not rate the condtios.
% a,b,c are the parameters relating ground truth quality scores q, rating
% and pairwise comparison data.

    %% Generate PWC matrix
    C = zeros(sum(datasets));
    % Sigma cumulative density function defines the relationship between
    % the probability of being better and distance in the quality scale
    sigma_cdf = 1.4826;

    ds_id = 1;
    % Generate within dataset comparisons at random
    for ii=1:numel(datasets)
        C_ds = zeros(datasets(ii));
        n_comp = exp_data.pwc_wd(ii);
        n_obs = ceil(n_comp/(4.5*datasets(ii)));

        rid_st = sum(datasets(1:(ii-1)))+1; 
        rid_end = rid_st+datasets(ii)-1; 
        q_mat.q = q(rid_st:rid_end);
        q_mat.MAT =[];
        [~,C_ds] = swiss_pairing(q_mat,n_obs,9,3);
        C(rid_st:rid_end,rid_st:rid_end)=C_ds;

    end
    
    % Generate cross-dataset comparisons - overall number of comparisons is
    % total number of conditions in two datasets being connected, i.e.
    % datasets(ii) + datasets(ii+1)
    
    start_id1 = 1;
    cmps =0;
    for ii = 1:(numel(datasets)-1)
        start_id2 = start_id1+datasets(ii);
        q_ids1 = start_id1:start_id1+datasets(ii)-1;
        q_ids2 = start_id2:start_id2+datasets(ii+1)-1;

        exp_data.pwc_cdpairs;
        exp_data.pwc_cdcompspp;

        
        for jj=1:exp_data.pwc_cdpairs(ii)
            cmps = 0;
            q_ids1s = q_ids1(randperm(length(q_ids1)));
            q_ids2s = q_ids2(randperm(length(q_ids2)));
            id1 = q_ids1s(1);
            id2 = q_ids2s(1);
            while cmps<exp_data.pwc_cdcompspp(ii)
                if normcdf(q(id1)-q(id2),0,sigma_cdf)>rand()
                    C(id1,id2) = C(id1,id2)+1;
                else
                    C(id2,id1) = C(id2,id1)+1;
                end
                cmps = cmps+1;
            end
        end
        
        start_id1 = start_id2;
        
    end
    
    %% Generate MOS matrix 
    
    % Generate a, b and c at random.
    a = randi([5,10],1,numel(datasets));
    b = a*rand();
    c = rand(1,numel(datasets))+rand(1,numel(datasets));
    
    % Matrix with rating scores
    M = NaN(sum(datasets),sum(exp_data.rating_obs));

    ds_id = 1;
    for ii=1:numel(datasets)
        
        numb_obs_ii = exp_data.rating_obs(ii);
        M_ds = NaN(datasets(ii),numb_obs_ii);
        for jj=ds_id:sum(datasets(1:(ii)))
            M_ds(jj-ds_id+1,:) = normrnd(a(ii)*q(jj)+b(ii),c(ii)*sigma_cdf/sqrt(2),1,numb_obs_ii);
        end
        rid_st = sum(exp_data.rating_obs(1:(ii-1)))+1; 
        rid_end = rid_st+exp_data.rating_obs(ii)-1;
        M(ds_id:ds_id+datasets(ii)-1,rid_st:rid_end) = M_ds;
        ds_id = datasets(ii)+1;
    end
    
end