function [ res ] = toStringProbMap( params,probMapStruct )
    res = ['probMapCells',int2str(params.imSize(1)),'x',int2str(params.imSize(2)),'strat', int2str(probMapStruct.strat), 'v',int2str(probMapStruct.version)];

end

