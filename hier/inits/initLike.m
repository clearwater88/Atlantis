function [like,counts] = initLike(data,templateStruct)

    like = evalLikePixels(templateStruct.app{end},data,[],templateStruct.mix(end));
    counts = templateStruct.mix(end)*ones(size(data));
    
end