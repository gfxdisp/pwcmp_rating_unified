function [M] = simulate_pwc_choice(q,id1,id2,M)

    prob = normcdf( q(id1)-q(id2), 0, 1.4865);
    if rand() < prob
        M(id1,id2)=M(id1,id2)+1;
    else
        M(id2,id1)=M(id2,id1)+1;
    end
end

