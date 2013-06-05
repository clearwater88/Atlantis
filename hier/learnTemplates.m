function [ output_args ] = learnTemplates(trainData)

    for (i=1:size(trainData,3))
       dataUse = trainData(:,:,i);
       [dX,dY] = gradient(double(dataUse));
       angle = atan(dY./dX);
       angle(isnan(angle)) = 0;
    end


end

