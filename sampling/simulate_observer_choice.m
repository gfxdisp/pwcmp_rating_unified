function [M] = simulate_observer_choice(q,id1,id2,M)

    %normcdf( q(id1)-q(id2), 0, 1.4826) ;
    prob = prob_being_better(q,id1,id2);
    if rand() < prob
        M(id1,id2)=M(id1,id2)+1;
    else
        M(id2,id1)=M(id2,id1)+1;
    end
end

