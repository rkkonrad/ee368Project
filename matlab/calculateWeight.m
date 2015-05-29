function [ weight ] = calculateWeight( distToCenter, sampleCoC, centerCoC, ...
                                            sampleDepth, focalDepth)
% Calculates the weight of one sample in filter
%   distToCenter -- distance from the sample pixel to the center of filter
%   sampleCoC   -- Circle of Confusion of sample pixel
%   centerCoC   -- Circle of Confusion of center pixel
%   depthSample -- depth of sample pixel
%   depthFocal  -- depth of focal plane
    weight =    overlapFactor(sampleCoC,distToCenter) * ...
                intensityFactor(sampleCoC) * ...
                leakageFactor( sampleDepth, focalDepth, centerCoC);

end

function [ weight ] = overlapFactor( sampleCoC, distToCenter)
% Caclulates the overlap factor
    if( sampleCoC <= distToCenter)
       weight = 0.0; 
    elseif (distToCenter <= sampleCoC && sampleCoC <= distToCenter + 1)
        weight = sampleCoC - distToCenter;
    else
        weight = 1.0;
    end
end

function [weight] = intensityFactor( CoC )
% Caculates the intensity factor
    weight = 1/(CoC^2);
end

function [weight] = leakageFactor( sampleDepth, focalDepth, centerCoC)
    if( sampleDepth <= focalDepth)
        weight =  1.0;
    else
        weight = min([centerCoC, 1.0]);
    end
end
