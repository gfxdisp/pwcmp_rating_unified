clear all
addpath('./sampling/')

% Define the size of the dataset, i.e. we have 2 datasets of sizes 4 and 5
datasets = [10, 14];
q_true_ds_1 = sort(rand(1,datasets(1)));
q_true_ds_1(1) = 0;
q_true_ds_2 = sort(rand(1,datasets(2)));
q_true = [q_true_ds_1,q_true_ds_2];
exp_data.rating_obs = [10,10];
exp_data.pwc_wd = [datasets(1)^2-datasets(1),datasets(2)^2-datasets(2)];
exp_data.pwc_cdpairs = [10];
exp_data.pwc_cdcompspp = [6];
exp_data.a =[];
exp_data.b =[];
exp_data.c =[];
n_exps = 1000;
% Generate simulated data from the true quality scores
rmse_arr = [];
cdcmps_arr = [2,4,6,8,10,12,14,16,18,20];
for jj = 1:numel(cdcmps_arr)
    disp(num2str(jj))
    cdcmps = cdcmps_arr(jj);
    RMSE = 0;
    for ii =1:n_exps
        exp_data.pwc_cdcompspp = [cdcmps];
        [PWC,M,a_gen,b_gen,c_gen]  = gen_data(q_true,datasets,exp_data);
        [Q, a, b, c,d] = mixing(PWC,M,datasets);
        RMSE =RMSE+ sqrt(mean((q_true(2:end) - Q(2:end)').^2));
    end
    rmse_arr= [rmse_arr,RMSE/n_exps];
end
figure()
plot(cdcmps_arr,rmse_arr)
grid on
xlabel('cdcmps')
ylabel('RMSE')

% Perform mixing of the quality scores
%[Q, a, b, c,d] = mixing(PWC,M,datasets);
Q_pwc=pw_scale(PWC);
mos = nanmean(M');
% Plot the true quality scores versus predicted and calculate errors
figure
subplot(1,3,1)
plot(q_true(1:datasets(1)),Q(1:datasets(1)),'g*')
hold on 
plot(q_true(datasets(1)+1:end),Q(datasets(1)+1:end),'b*')
pbaspect([1 1 1])
grid on
xlabel('True quality scores (JOD)')
ylabel('Predicted quality scores (JOD)')
subplot(1,3,2)
plot(q_true(1:datasets(1)),mos(1:datasets(1)),'g*')
hold on
plot(q_true(datasets(1)+1:end),mos(datasets(1)+1:end),'b*')

pbaspect([1 1 1])
grid on
xlabel('True quality scores (JOD)')
ylabel('MOS')
subplot(1,3,3)
plot(q_true(1:datasets(1)),Q_pwc(1:datasets(1)),'g*')
hold on 
plot(q_true(datasets(1)+1:end),Q_pwc(datasets(1)+1:end),'b*')

pbaspect([1 1 1])
grid on
xlabel('True quality scores (JOD)')
ylabel('Q pw scale')

% Calculate both RMSE and SROCC without the first element, since it is set
% to always be 0
SROCC = corr(q_true(2:end)', Q(2:end), 'Type', 'Spearman');
RMSE = sqrt(mean((q_true(2:end) - Q(2:end)').^2));
disp (['Spearman Rank Order Correlation: ', num2str(SROCC)])
disp (['Root Mean Squared Error: ', num2str(RMSE)])




