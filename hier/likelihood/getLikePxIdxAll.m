function likePxIdxCells = getLikePxIdxAll(cellParams,posesStruct,pxStr)
    % generates indices that indicate which poses this cell can take on.
    % This is different than the poses that OVERLAP with this cell; such
    % poses may not be a value this call can take.

    if(exist([pxStr,'.mat'],'file'))
        display('loading pxIdxCell file');
        load(pxStr,'likePxIdxCells');
    else
        tic
        display(['File does not exist: ', pxStr]);
        display('Starting likePxIdxCells computation');
        likePxIdxCells = cell(cellParams.nTypes,1);
        for (n=1:cellParams.nTypes)
            likePxIdxCells{n}= doGetLikePxIdxAll(cellParams.centres{n}, ...
                                                 cellParams.dims(n,:), ...
                                                 posesStruct.poses{n});
        end
        display('Done likePxIdxCells computation');
        save(pxStr,'likePxIdxCells'); % something goes wrong with '-v7.3' flag on cluster?
        toc
    end
    
end
function res = doGetLikePxIdxAll(cellCentre,cellDims,poseCentres)

    NBATCH = 20;

    lowCell = bsxfun(@minus,cellCentre(:,1:2),(cellDims(1:2)-1)/2)';
    highCell = bsxfun(@plus,cellCentre(:,1:2),(cellDims(1:2)-1)/2)'; 
    
    poseCentres = reshape(poseCentres',[3,1,numel(poseCentres)/3]);
    % size: #cellCentres x # pixels (size(poseCentres,3))
    
    sz = size(lowCell,2);
    batchSize = ceil(sz/NBATCH);
    res = cell(size(lowCell,2),1);
    
    ags = squeeze(poseCentres(3,1,:)); % only 1 angle anyway

    ct = 1;
    for (n=1:NBATCH)
        display(['On batch ', int2str(n) '/', int2str(NBATCH)]);
        %tic
        nStart = (n-1)*batchSize+1;
        nEnd = min(n*batchSize,sz);
        
        spatialLow = sum(bsxfun(@ge,poseCentres(1:2,1,:),lowCell(:,nStart:nEnd)),1)==2;
        spatialHigh = sum(bsxfun(@le,poseCentres(1:2,1,:),highCell(:,nStart:nEnd)),1)==2;
        resSpatial = bsxfun(@and,spatialLow,spatialHigh);

        angleLow = cellCentre(nStart:nEnd,3)-cellDims(3)/2;
        angleHigh = cellCentre(nStart:nEnd,3)+cellDims(3)/2;

        for (i=1:nEnd-nStart+1)
           resAngle = checkAngle(ags,angleLow(i),angleHigh(i));
           temp = bsxfun(@and,resAngle,squeeze(resSpatial(1,i,:)));
           
           res{ct} = find(temp==1);
           assert(size(res{ct},1) > 0);
           
           ct = ct+1;
        end
        %toc
    end
    
%     nCell = size(lowCell,2);
%     for (n=1:nCell)
%         
% 
%         spatialLow = squeeze(sum(bsxfun(@ge,poseCentres(1:2,:),lowCell(:,n)),1));
%         spatialLow = spatialLow == 2; % any of the 2 spatial dimensions outside of range?
% 
%         %a = poseCentres(1,:) >= lowCell(1,n) & poseCentres(2,:) >= lowCell(2,n)
%         
%         % size: #cellCentres x # pixels (size(poseCentres,3))
%         spatialHigh = squeeze(sum(bsxfun(@le,poseCentres(1:2,:),highCell(:,n)),1));
%         spatialHigh = spatialHigh == 2; % any of the 2 spatial dimensions outside of range?
% 
%         resSpatial = bsxfun(@and,spatialLow,spatialHigh);
% 
%         angleLow = cellCentre(n,3)-cellDims(3)/2;
%         angleHigh = cellCentre(n,3)+cellDims(3)/2;
% 
%         
%         resAngle = checkAngle(ags,angleLow,angleHigh);
%         temp = bsxfun(@and,resSpatial',resAngle);
%         
%         res2{n} = find(temp==1);
%     end

end


