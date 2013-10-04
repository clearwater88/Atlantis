function [ res ] = getRotMat( angle )
    res = [cos(angle), sin(angle); -sin(angle), cos(angle)];
end

