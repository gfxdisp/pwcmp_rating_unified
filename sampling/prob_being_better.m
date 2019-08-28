function [prob] = prob_being_better(q,id1,id2)
    MAT = q.MAT;
    q = q.q;

    if size(MAT,1)>0  
        prob = (MAT(id1,id2)+1)/(MAT(id1,id2)+MAT(id2,id1)+2);
    else
        prob = normcdf( q(id1)-q(id2), 0, 1.4865);
    end
end