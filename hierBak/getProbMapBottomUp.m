%function [resInds,resProbs] = getProbMapBottomUp(cellMapStruct,cellParams,ruleInd,slot,centre)
function [res,resInds] = getProbMapBottomUp(cellMapStruct,cellParams,ruleInd,slot,centre)

    % we need to talk about parent coords here
    parType = cellMapStruct.parentType(ruleInd);
    parStrides = cellParams.strides(parType,:);
    %parOrigin = cellParams.origins(parType,:);
    parLocFramePar = cellMapStruct.refPoints(:,ruleInd,slot);
    %parRefPoint = cellMapStruct.refPoints(:,ruleInd,slot);
    %parLocFramePar = centre2CellFrame(parRefPoint',parStrides(1:2),parOrigin(1:2));
    
    parCoordsSize = cellParams.coordsSize(parType,:);
    
    chType = cellMapStruct.childType(ruleInd,slot);
    chStrides = cellParams.strides(chType,:);
    chOrigin = cellParams.origins(chType,:);
    
    child2ParentFrameFactor = cellParams.strides(chType,1:2) ./ cellParams.strides(parType,1:2);
    
    [~,angleInd] = min(abs(cellMapStruct.angles{parType} - centre(3)));
    
    % parent probMaps, childLocs
    probMapsSpatial = cellMapStruct.probMapSpatial(ruleInd,slot,:);
    nParentAngles = size(probMapsSpatial,3);
    locsFrameChild = cellMapStruct.locs{ruleInd,slot,angleInd};
    bottomRightFrameChild = [max(locsFrameChild(:,1)), ...
                             max(locsFrameChild(:,2))];
                         
    childLocFrameChild = centre2CellFrame(centre(1:2),chStrides(1:2),chOrigin(1:2));
    toShiftFrameChild = childLocFrameChild-bottomRightFrameChild;
    
    
    toShiftFrameParent = ceil(toShiftFrameChild.*child2ParentFrameFactor);
    
    misAlignChildFrame = (toShiftFrameChild.*child2ParentFrameFactor - ...
                          toShiftFrameParent)./child2ParentFrameFactor;
                      
    %bottomRightProbParent = prob
    
    bottomRightFrameParent = parLocFramePar+toShiftFrameParent;
    shiftParent = floor(cellParams.dims(parType,1:2)./parStrides(1:2));
    
    [x,y] = meshgrid([0;shiftParent(1)], [0;shiftParent(2)]);
    pts = [y(:),x(:)];
    shiftAlignChild = bsxfun(@plus, ...
                             -bsxfun(@rdivide,pts,child2ParentFrameFactor), ...
                             misAlignChildFrame);
    sz = size(probMapsSpatial{:,:,1});
    temp = bsxfun(@plus,shiftAlignChild,sz(1:2));
    probMapInds = sz(1)*(temp(:,2)-1)+temp(:,1);                  
    probMapInds(probMapInds<1) = [];
    
    parentLocs = bsxfun(@plus,bottomRightFrameParent,pts);
    resLocs = zeros(size(parentLocs,1)*nParentAngles,3);
    resProbs = zeros(size(parentLocs,1)*nParentAngles,1);
    
    locsSz = numel(probMapInds);
    for (i=1:nParentAngles)
        probMap = probMapsSpatial{:,:,i}(:,:,angleInd);
        vals = probMap(probMapInds);
        
        resProbs((i-1)*locsSz+1:i*locsSz) = vals;
        resLocs((i-1)*locsSz+1:i*locsSz,1:2) = parentLocs;
        resLocs((i-1)*locsSz+1:i*locsSz,3) = i;
    end
    
    badInds = resLocs(:,1) < 1 | ...
              resLocs(:,2) < 1 | ...
              resLocs(:,1) > parCoordsSize(1) | ...
              resLocs(:,2) > parCoordsSize(2);
    resLocs(badInds,:) = [];
    resProbs(badInds) = [];
    
    resInds = sub2ind(parCoordsSize,resLocs(:,1),resLocs(:,2),resLocs(:,3));
    
    res = zeros(size(cellParams.centres{parType},1),1);
    res(resInds) = resProbs;
    
end

