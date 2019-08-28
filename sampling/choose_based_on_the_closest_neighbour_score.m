function [rr,cc] = choose_based_on_the_closest_neighbour_score(scores, new_N)
    rr = randi([1 new_N],1,1);
    cc = randi([1 new_N],1,1);
    range = 0;

    if (rr == 1)
        range = scores((rr+1),2)-scores(rr,2);
    elseif (rr == new_N)
        range = scores(rr,2) - scores((rr-1),2);
    else
        range = min(scores((rr+1),2) - scores(rr,2),...
                    scores(rr,2) - scores((rr-1),2));
    end
    % Find different ids such that they are not further away than 4
    % can have different condition for 4
    while (rr==cc) || abs(scores(rr,2)-scores(cc,2))>range
        cc = randi([1 new_N],1,1);
    end
end