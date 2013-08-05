function res = getProbOn(particles)
    res = zeros(3,size(particles{1},2)); %cellType,cellIdx,probOn
    if(isempty(particles{1})) return; end;
    
    
    res(1:2,:) = particles{1}(2:3,:);

    for (i=1:numel(particles))
        res(3,:) = res(3,:) + particles{i}(1,:);
    end
    res(3,:) = res(3,:)/numel(particles);
end