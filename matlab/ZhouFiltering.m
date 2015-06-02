function [ outImg, time ] = ZhouFiltering( img, depth, fplane, dEye)
% Runs the algorithm from Zhou 2007 on the image and depth provided
%   img     -- RGB image to be filtered
%   depth   -- depth map
%   fplane  -- distance to the plane in focus
%   dEye    -- diameter of pupil (effective aperture)

% Algorithm Parameters
filterWidth = 9;
filterR = (filterWidth-1)/2;

outImg = zeros(size(img));
img = padarray(img, [filterR, filterR], 'replicate');
depth = padarray(depth, [filterR, filterR], 'replicate');

% Precomputes coc Matrix
cocMatrix = calculateCoC(dEye, depth, fplane)*1000;

tic
for i = filterR+1 : size(depth,1) - filterR
    for j = filterR+1 : size(depth,2) - filterR

        weights = zeros(filterWidth);
        centerCoC = cocMatrix(i,j);
        weights(filterR+1, filterR+1) = intensityFactor(centerCoC);
        
        for x = -filterR:filterR
            for y = -filterR:filterR
                distToCenter = sqrt(x^2 + y^2);
                if(distToCenter > filterR || (x == 0 && y == 0))
                    continue;
                end
                sampleDepth = depth(i+x, j+y);
                sampleCoC = cocMatrix(i+x, j+y);
                weights(x+filterR+1, y+filterR+1) = ...
                calculateWeight(distToCenter, sampleCoC, centerCoC, ...
                                    sampleDepth, fplane);
            end
        end
        imgPiece = img(i-filterR:i+filterR, j-filterR:j+filterR, :);
        outImg(i-filterR,j-filterR,:) = sum(sum(imgPiece .* repmat(weights, [1 1 3]))) / sum(weights(:));
    end
    i
end
time = toc;

%display(['The Zhou:2007 algorithm took ' num2str(time) ' seconds to compute']);
%imshow(outImg);

end

% Calculates the circle of confusion radius
function [coc] = calculateCoC(dEye, depthFrag, depthFocal)
    coc = abs(dEye * (depthFrag - depthFocal) ./ depthFrag)/2;
end

% Calculates the intensity factor as a function of the CoC radius
function [weight] = intensityFactor(rp)
    weight = 1/rp^2;
end
