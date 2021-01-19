function [] = plot_results (params, Q_true, Q_mixing, Q_mos, Q_pwc)
    % Plot the true quality scores versus predicted and calculate errors
    H = figure;
    width = 36;
    height = 12;
    oldUnits = get(H,'Units');
    set( H, 'Units', 'centimeters' );
    figPos = get(H,'Position');
    figPos(3) = width;
    figPos(4) = height;
    set(H,'Position', figPos);
    set(H,'PaperPosition', [0 0 width height] );
    set( H, 'Units', oldUnits );
    
    COLORs = lines( numel(params.dataset_sizes) );
    marker_style= {'>','o','*','s','+','x'};
    
    subplot(1,3,1)
    start_id  = 1;
    for ii = 1:numel(params.dataset_sizes)
        end_id  = sum(params.dataset_sizes(1:ii));
        scatter(Q_true(start_id:end_id),Q_mixing(start_id:end_id),'Marker', marker_style{mod(ii,size(marker_style,2))+1}, 'MarkerEdgeColor', COLORs(ii,:));

        hold on 
        start_id = end_id+1;
    end
    
    pbaspect([1 1 1])
    grid on
    xlabel('True quality scores (JOD)')
    ylabel('Unified quality scores (JOD)')

    % Plot the true quality scores versus mean opinion scores
    subplot(1,3,2)
    start_id  = 1;
    for ii = 1:numel(params.dataset_sizes)
        end_id  = sum(params.dataset_sizes(1:ii));
        scatter(Q_true(start_id:end_id),Q_mos(start_id:end_id),'Marker', marker_style{mod(ii,size(marker_style,2))+1}, 'MarkerEdgeColor', COLORs(ii,:));

        hold on 
        start_id = end_id+1;
        
    end
    
    pbaspect([1 1 1])
    grid on
    xlabel('True quality scores (JOD)')
    ylabel('MOS')

    % Plot the true quality scores versus scaled pairwise comparisons
    subplot(1,3,3)
    start_id  = 1;
    for ii = 1:numel(params.dataset_sizes)
        end_id  = sum(params.dataset_sizes(1:ii));
        scatter(Q_true(start_id:end_id),Q_pwc(start_id:end_id),'Marker', marker_style{mod(ii,size(marker_style,2))+1}, 'MarkerEdgeColor', COLORs(ii,:));
        hold on 
        start_id = end_id+1;
        
        LABELs{ii} =  strcat ('Dataset: ', num2str(ii));
    end
    legend( LABELs, 'Location', 'best');
    
    pbaspect([1 1 1])
    grid on
    xlabel('True quality scores (JOD)')
    ylabel('Scaled pairwise comparisons (JOD)')

    set(findall(H,'-property','FontSize'),'FontSize',14)
end