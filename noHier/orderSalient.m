function [locs,locsScore] = orderSalient(salient,locs)

    locsOrder = zeros([size(locs,1),3]);

    for (i=1:size(locs,1))
        locsOrder(i,1) = salient(locs(i,1),locs(i,2));
        locsOrder(i,2:3) = locs(i,:);
    end

    locsOrder = sortrows(locsOrder,-1);
    locs = locsOrder(:,2:3);
    locsScore = locsOrder(:,1);
end

