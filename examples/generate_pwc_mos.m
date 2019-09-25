function [pwc_mat, mos_mat] = generate_pwc_mos(q_true, params)
% Function to generate simulated data - pairwise comparisons and mean
% opinion scores from the true quality scores
% 
% [pwc_mat, mos_mat, a, b, c] = gen_data(q_true, params)
% 
% q_true - ground truth quality scores (for all datasets)
% params - structure explaining
%
% returns:
% pwc_mat - NxN matrix of pairwise comparisons, where N - is the total number of
% conditions. The order of elements corresponds to the order in q. Every
% element pwc_mat(ii,jj) is the number of times condition ii was selected over
% condition jj
% mos_mat - NxO matrix with rating measurements, where N - number of conditions,
% and O is the number of observers. Each element is either mos_mat(ii,oo) -
% rating score assigned by an observer oo to condition ii, or NaN - if the
% observer did not rate the conditions.
% a,b,c are the parameters relating ground truth quality scores q, rating
% and pairwise comparison data.

% Sigma cumulative density function defines the relationship between
% the probability of being better and distance in the quality scale

    if numel(params.dataset_sizes)-1 ~= numel(params.numb_cross_ds_pairs)
        error('Size of cross dataset comparisons must be one less than the number of datasets');
    end

    if numel(params.numb_cross_ds_pairs) ~= numel(params.numb_comps_per_cross_ds_pair)
        error('Number of comparisons per pair should be equal to the number of pairs');
    end

    if numel(params.dataset_sizes) ~= numel(params.rating_per_ds)
        error('Number of rating measurements must be equal to the number of datasets');
    end

    sigma_cdf = 1.4826;
    
    %% Generate PWC matrix
    
    pwc_mat = zeros(sum(params.dataset_sizes));
    % Within dataset comparisons = 2*(n^2 - n), where n is the size of the
    % dataset, everything compared to everything
    for ii=1:numel(params.dataset_sizes)
        C_ds = zeros(params.dataset_sizes(ii));
        rid_st = sum(params.dataset_sizes(1:(ii-1)))+1; 
        rid_end = rid_st+params.dataset_sizes(ii)-1; 
        q = q_true(rid_st:rid_end);
        for tt = 1:2
            for kk = 1:params.dataset_sizes(ii)
                for jj = 1:kk-1
                    C_ds = simulate_pwc_choice(q,kk,jj,C_ds);
                end
            end
        end
        
        pwc_mat(rid_st:rid_end,rid_st:rid_end)=C_ds;
    end

    % Generate cross-dataset comparisons - overall number of comparisons is
    % total number of conditions in two datasets being connected, i.e.
    % datasets(ii) + datasets(ii+1)
    start_id1 = 1;
    for ii = 1:(numel(params.dataset_sizes)-1)
        start_id2 = start_id1+params.dataset_sizes(ii);
        q_ids1 = start_id1:start_id1+params.dataset_sizes(ii)-1;
        q_ids2 = start_id2:start_id2+params.dataset_sizes(ii+1)-1;

        for jj=1:params.numb_cross_ds_pairs(ii)
            cmps = 0;
            q_ids1s = q_ids1(randperm(length(q_ids1)));
            q_ids2s = q_ids2(randperm(length(q_ids2)));
            id1 = q_ids1s(1);
            id2 = q_ids2s(1);
            while cmps<params.numb_comps_per_cross_ds_pair(ii)
                [pwc_mat] = simulate_pwc_choice(q_true,id1,id2,pwc_mat);
                cmps = cmps+1;
            end
        end

        start_id1 = start_id2;

    end

    %% Generate MOS matrix 
    % Each dataset has the rating scores generated from
    % N(a*q_true+b,c*sigma/sqrt(2))
    % Generate a for each dataset at random from 0 5 interval
    a = randi([5,10],1,numel(params.dataset_sizes));
    % Generate bs at random
    b = a*rand();
    % Generate cs at random
    c = rand(1,numel(params.dataset_sizes))+rand(1,numel(params.dataset_sizes));

    % Matrix with rating scores
    mos_mat = NaN(sum(params.dataset_sizes),sum(params.rating_per_ds));

    ds_id = 1;
    for ii=1:numel(params.dataset_sizes)

        numb_obs_ii = params.rating_per_ds(ii);
        M_ds = NaN(params.dataset_sizes(ii),numb_obs_ii);
        for jj=ds_id:sum(params.dataset_sizes(1:(ii)))
            M_ds(jj-ds_id+1,:) = normrnd(a(ii)*q_true(jj)+b(ii),c(ii)*sigma_cdf/sqrt(2),1,numb_obs_ii);
        end
        rid_st = sum(params.rating_per_ds(1:(ii-1)))+1; 
        rid_end = rid_st+params.rating_per_ds(ii)-1;
        if params.ref 
            M_ds = M_ds - M_ds(1,:);
        end
        mos_mat(ds_id:ds_id+params.dataset_sizes(ii)-1,rid_st:rid_end) = M_ds;
        ds_id = params.dataset_sizes(ii)+1;
        
    end
end