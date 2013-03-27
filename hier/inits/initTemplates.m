function [templateStruct] = initTemplates()
    
    %make sizes odd
    templateStruct.app{1} = [0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1; ...
                             0.1,   0.9,   0.1];
                
    templateStruct.app{2} = [0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9];
    templateStruct.app{3} = 0.1; % background
    templateStruct.mix = [0.1,1,0.0001]';

end

