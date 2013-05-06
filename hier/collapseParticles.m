function [ output_args ] = collapseParticles(particles,



    %%% Now collapse particle representation
    [samp_xF] = unique(samp_x,'rows');
    
    nUnique = size(samp_xF,1);
    
    totalPostF = zeros(nUnique,1);
    countsF = zeros([size(counts,1),size(counts,2),nUnique]);
    likeF = zeros([size(like,1),size(like,2),nUnique]);
    
    for (i=1:size(samp_xF,1))
        mems = (ismember(samp_x,samp_xF(i,:),'rows'));
        id = find(mems,1,'first');
        nId = sum(mems);
        
        countsF(:,:,i) = counts(:,:,id);
        likeF(:,:,i) = like(:,:,id);
        totalPostF(i) = totalPost(id)*nId;
    end
    totalPost = totalPostF;
    counts = countsF;
    like = likeF;
    samp_x = samp_xF;
end

