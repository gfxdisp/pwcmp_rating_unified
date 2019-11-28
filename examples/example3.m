clear all

% Add path to the mixing code
addpath ('../')

% Number of conditions in each of the datasets
params.dataset_sizes = [4,5];

% Number of observers per dataset in rating experiment
params.rating_per_ds = [5,4];

% Number of cross dataset pairs
% Size of the array must be (number_of_datasets - 1) 
params.numb_cross_ds_pairs = [6];

% Number of times each cross dataset pair is compared 
% Size of the array must be (number_of_datasets - 1) 
params.numb_comps_per_cross_ds_pair = [6];

% Number of within dataset comparisons
params.within_ds_comparisons = 6;

% If the merged datasets have reference conditions
params.ref = true;

% Number of bootstrap experiments
n_exps = 10;

% Generate true quality scores for the first datast between 0 and 1
Q_true = sort(rand(1,params.dataset_sizes(1)));

% By default the first condition is set to 0
Q_true(1) = 0;
% Sort the scores within each of the dataset, set the first one to 0;
for dataset=params.dataset_sizes(2:end)
    q_true_ds_ii = sort(rand(1,dataset));
    if params.ref 
        q_true_ds_ii(1) = 0;
    end
    Q_true = [Q_true,q_true_ds_ii];
end

RMSE = [];
SROCC = [];
for ii =1:n_exps
    % Generate pairwise comparison and rating matrices
    [pwc_mat, mos_mat] = generate_pwc_mos(Q_true,params);
    
    % Unify the scores 
    [Q_mixing, a, b, c] = mixing_with_ref(pwc_mat, mos_mat, params.dataset_sizes);
    
    SROCC = [SROCC, corr(Q_true(2:end)', Q_mixing(2:end), 'Type', 'Spearman')];
    RMSE = [RMSE, sqrt(mean((Q_true(2:end) - Q_mixing(2:end)').^2))];
end

display (['Spearman Rank Order Correlation: ', num2str(mean(SROCC))])
display (['Root Mean Squared Error: ', num2str(mean(RMSE))])

% Scale only pairwise comparisons separately
Q_pwc = pw_scale(pwc_mat);

% Average mean opinion scores per condition
Q_mos = nanmean(mos_mat');

% Plot the results
plot_results (params, Q_true, Q_mixing, Q_mos, Q_pwc)


