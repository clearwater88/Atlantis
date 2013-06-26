function [res,resInds] = getProbMapTopDown(cellMapStruct,cellParams,ruleInd,slot,centre)

    % remember, we're talking about child coordinates, not parents
    chType = cellMapStruct.childType(ruleInd,slot);

    strides = cellParams.strides(chType,:);
    origin = cellParams.origins(chType,:);
    coordsSize = cellParams.coordsSize(chType,:);
    
    [~,angleInd] = min(abs(cellMapStruct.angles{chType} - centre(3)));
    
    probMap = cellMapStruct.probMap{ruleInd,slot,angleInd};
    locs = cellMapStruct.locs{ruleInd,slot,angleInd};
    
    % Ok if these are decimals. Their difference must be integer though
    centreLoc = centre2CellFrame(centre(1:2),strides(1:2),origin(1:2));
    refLoc = centre2CellFrame(cellMapStruct.refPoints(:,ruleInd,slot)',strides(1:2),origin(1:2));
    
    idx = int32(bsxfun(@plus,locs,[centreLoc-refLoc,0]));
    
    badInds = find(idx(:,1) < 1 | ...
                   idx(:,2) < 1 | ...
                   idx(:,1) > coordsSize(1) | ...
                   idx(:,2) > coordsSize(2));
    idx(badInds,:) = [];
    probMap(badInds) = [];
          
    resInds = sub2ind(coordsSize,idx(:,1),idx(:,2),idx(:,3));
    
    res = zeros(size(cellParams.centres{chType},1),1);
    res(resInds) = probMap;

%     a = reshape(res,coordsSize);
%     figure(1); imagescGray(sum(a,3));
% 
%     inds2 =  sub2ind(coordsSize,locs(:,1),locs(:,2),locs(:,3));
%     res2= zeros(size(cellParams.centres{chType},1),1);
%     res2(inds2) =cellMapStruct.probMap{ruleInd,slot,angleInd};
%     res2 = reshape(res2,coordsSize);
%     figure(2); imagescGray(sum(res2,3));
end

