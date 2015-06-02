clear all;
close all;

% Function Definitions
calculateCoC =  @(D_eye, depthFrag, depthFocal) ...
                abs(D_eye * (depthFrag - depthFocal) ./ depthFrag)/2;
gaussian = @(d,sigma) 1/(2*pi*sigma^2) * exp(-d/(2*sigma^2));            
bilateral = @(S, sigmaS, R, sigmaR) gaussian(S,sigmaS)*gaussian(R,sigmaR); %don't forget to normalize after

initialize;

tic
% Pad Image and Depth Buffer
cocMatrix = calculateCoC(D_eye, depthW, focalDepth)*1000;
maxCoC = max(ceil(cocMatrix(:)));

img = padarray(img, [maxCoC maxCoC], 'replicate');
depthW = padarray(depthW, [maxCoC maxCoC], 'replicate');
cocMatrix = padarray(cocMatrix, [maxCoC maxCoC], 'replicate');

% Algorithm Parameters
sigmaS = 1.0;
sigmaR = 1.0;


outImg = zeros(sizeIm);
for i = maxCoC+1:size(img,1)-maxCoC
    for j = maxCoC+1:size(img,2) - maxCoC
        pDepth = depthW(i,j);
        pCoC = cocMatrix(i,j);
        roundCoC = round(pCoC);
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
                qDepth = depthW(i+x, j+y);
                weights(x+roundCoC+1, y+roundCoC+1) = ...
                    bilateral(S^2, sigmaS, (pDepth-qDepth)^2, sigmaR);
            end
        end
        imgPiece = img(i-roundCoC:i+roundCoC, j-roundCoC:j+roundCoC,:);
        weightedImg = repmat(weights, [1 1 3]) .* imgPiece;
        outImg(i-maxCoC, j-maxCoC,:) = sum(sum(weightedImg)) / sum(weights(:));
    end
end
time = toc;
display(['The bilateral filtering algorithm took ' num2str(time) ' seconds to compute']);
figure; imshow(outImg,[]);
