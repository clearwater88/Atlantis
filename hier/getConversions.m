function conversions = getConversions(nTypes, cellParams)
    conversions = zeros(2,nTypes,nTypes);
    for n=1:nTypes
        for n2=1:nTypes
            conversions(:,n,n2) = cellParams.strides(n,1:2)./cellParams.strides(n2,1:2) ;
        end
    end
end