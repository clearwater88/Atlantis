function [tp,fp,auc] = getROC(input,labels)

    r = sortrows([-input,labels]);
    r(:,1) = -r(:,1);

    % tp = zeros(numel(input),1);
    % fp = zeros(numel(input),1);
    
    nTrue = sum(labels==1);
    nFalse = sum(labels==0);
    
    tp = cumsum(r(:,2)==1)/nTrue;
    fp = cumsum(r(:,2)==0)/nFalse;

    auc = diff(fp)'*(tp(1:end-1)+tp(2:end))/2;
end

