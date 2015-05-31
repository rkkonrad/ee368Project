function [ alpha ] = calculateAlpha(pCoC, qCoC, maxCoC, pRegion, qRegion)
%Function which calculates the alpha for the recursive step 
%   Detailed explanation goes here

    % Determine case
    if(pRegion == qRegion)
        regionCase = 1;
    elseif( (pRegion == 2 && qRegion == 1) || (pRegion == 1 && qRegion == 2))
        regionCase = 2;
    elseif( (pRegion == 2 && qRegion == 3) || (pRegion == 3 && qRegion == 2))
        regionCase = 3;
    elseif( (pRegion == 1 && qRegion == 3) || (pRegion == 3 && qRegion == 1))
        regionCase = 2;
    end
    
    switch regionCase
        case 1
            alpha = case1(pCoC, qCoC);
        case 2
            alpha = case2(maxCoC);
        case 3
            alpha = case3(pCoC, qCoC);
    end

end

function [ alpha ] = case1(pCoC,qCoC)
    alpha = 0;
    avgCoC = mean([pCoC qCoC]);
    if( avgCoC > 1e-5 )
        alpha = exp(-1/avgCoC);
    end
end

function [ alpha ] = case2(maxCoC)
    alpha = 0;
    if( maxCoC >= 1e-5)
        alpha = exp(-1/maxCoC);
    end
end

function [ alpha ] = case3(pCoC,qCoC)
    alpha = 0;
    minCoC = min([pCoC qCoC]);
    if( minCoC > 1e-5)
        alpha = exp(-1/minCoC);
    end
end