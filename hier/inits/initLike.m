function [like,counts] = initLike(data,templateStruct,alpha)
    bg = templateStruct.app{end};
    like = (bg.^data).*((1-bg).^(1-data));
    like = templateStruct.mix(end)*(like.^alpha);
    counts = templateStruct.mix(end)*ones(size(data));
end