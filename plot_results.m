function [] = plot_results (params, Q_true, Q_mixing, Q_mos, Q_pwc)
    % Plot the true quality scores versus predicted and calculate errors
    figure
    subplot(1,3,1)
    plot(Q_true(1:params.dataset_sizes(1)),Q_mixing(1:params.dataset_sizes(1)),'g*')
    hold on 
    plot(Q_true(params.dataset_sizes(1)+1:end),Q_mixing(params.dataset_sizes(1)+1:end),'b*')
    pbaspect([1 1 1])
    grid on
    xlabel('True quality scores (JOD)')
    ylabel('Unified quality scores (JOD)')

    % Plot the true quality scores versus mean opinion scores
    subplot(1,3,2)
    plot(Q_true(1:params.dataset_sizes(1)),Q_mos(1:params.dataset_sizes(1)),'g*')
    hold on
    plot(Q_true(params.dataset_sizes(1)+1:end),Q_mos(params.dataset_sizes(1)+1:end),'b*')
    pbaspect([1 1 1])
    grid on
    xlabel('True quality scores (JOD)')
    ylabel('MOS')

    % Plot the true quality scores versus scaled pairwise comparisons
    subplot(1,3,3)
    plot(Q_true(1:params.dataset_sizes(1)),Q_pwc(1:params.dataset_sizes(1)),'g*')
    hold on 
    plot(Q_true(params.dataset_sizes(1)+1:end),Q_pwc(params.dataset_sizes(1)+1:end),'b*')
    pbaspect([1 1 1])
    grid on
    xlabel('True quality scores (JOD)')
    ylabel('Scaled pairwise comparisons (JOD)')

end