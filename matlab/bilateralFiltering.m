function [ outImg, time ] = bilateralFiltering( img, depth, fplane, dEye)
% Runs the algorithm from Zhou 2007 on the image and depth provided
%   img     -- RGB image to be filtered
%   depth   -- depth map
%   fplane  -- distance to the plane in focus
%   dEye    -- diameter of pupil (effective aperture)

sizeIm = size(img);

tic
% Pad Image and Depth Buffer
cocMatrix = calculateCoC(dEye, depth, fplane)*1000;
maxCoC = min([max(ceil(cocMatrix(:))) 10]);

img = padarray(img, [maxCoC maxCoC], 'replicate');
depth = padarray(depth, [maxCoC maxCoC], 'replicate');
cocMatrix = padarray(cocMatrix, [maxCoC maxCoC], 'replicate');

% Algorithm Parameters
sigmaS = 10.0;
sigmaR = 10.0;


outImg = zeros(sizeIm);
for i = maxCoC+1:size(img,1)-maxCoC-1
    if(i == 310)
           disp('hi'); 
        end
    for j = maxCoC+1:size(img,2) - maxCoC-1
        if(j == 650)
           disp('hi2'); 
        end
        pDepth = depth(i,j);
        pCoC = cocMatrix(i,j);
        roundCoC = min([round(pCoC) 10]);
        weights = zeros(roundCoC);
        if(roundCoC == 0)
            outImg(i-maxCoC, j-maxCoC,:) = img(i,j,:);
            continue;
        end
               
        for x = -roundCoC:roundCoC
            for y = -roundCoC:roundCoC
                S = sqrt(x^2 + y^2);
                if(S > roundCoC)
                    continue;
                end
                qDepth = depth(i+x, j+y);
                weights(x+roundCoC+1, y+roundCoC+1) = ...
                    bilateral(S, sigmaS, pDepth-qDepth, sigmaR);
            end
        end
        imgPiece = img(i-roundCoC:i+roundCoC, j-roundCoC:j+roundCoC,:);
        weightedImg = repmat(weights, [1 1 3]) .* imgPiece;
        outImg(i-maxCoC, j-maxCoC,:) = sum(sum(weightedImg)) / sum(weights(:));
    end
    i
end
time = toc;
% display(['The bilateral filtering algorithm took ' num2str(time) ' seconds to compute']);
% figure; imshow(outImg,[]);

end

% Calculates the circle of confusion radius
function [coc] = calculateCoC(dEye, depthFrag, depthFocal)
    coc = abs(dEye * (depthFrag - depthFocal) ./ depthFrag)/2;
end

% Calculates value of gaussian at point d
function [val] = gaussian(d, sigma)
    val = 1/(sqrt(2*pi)*sigma) * exp(-d^2/(2*sigma^2));
end

% Calculates value of filateral filer at points S and R
function [val] = bilateral(S, sigmaS, R, sigmaR)
   val =  gaussian(S,sigmaS)*gaussian(R,sigmaR); %don't forget to normalize after
end