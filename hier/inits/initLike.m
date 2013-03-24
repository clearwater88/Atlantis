function [like,counts] = initLike(templateStruct,data)
    bg = templateStruct.app{end};
    like = templateStruct.mix(end)*((bg.^data).*((1-bg).^(1-data)));
    counts = templateStruct.mix(end)*ones(size(data));
end

