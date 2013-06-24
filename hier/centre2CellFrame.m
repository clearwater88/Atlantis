function [res] = centre2CellFrame(centres,strides,origin)

        res =  bsxfun(@plus, ...
                      bsxfun(@rdivide, ...
                             bsxfun(@minus, ...
                                    centres, ...
                                    origin), ...
                                    strides), ...
                      ones(size(centres)));

end

