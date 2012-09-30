function learnParams(nParts,data,gtBrick)

    imSize = [size(data,1),size(data,2)];
    
    % extra 1 for background
    qParams = 0.2*rand(nParts+1,1) + 0.4;

    cts = zeros([imSize,size(data,3)]);
    for (n=1:size(gtBrick,1))
        ctsIm = zeros(imSize);
        for (j=1:size(gtBrick,2))
           for(k=1:size(gtBrick,3))
               temp = gtBrick{n,j,k};
               if(isempty(temp)) continue; end;
               
               ctsIm(temp) = ctsIm(temp)+1;
               
           end
        end
        cts(:,:,n) = ctsIm;
    end
    
    Bnk = computeBnk(data,gtBrick,qParams(1:end-1);
    
end

function res = computeBnk(data,gtBrick,qParams)


    

end