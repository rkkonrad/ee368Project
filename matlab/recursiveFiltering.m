function [ outImg, time ] = recursiveFiltering( img, depth, fplane, dEye, scale)
% Renders DOF via recursive algorithm defined in Xu 2014
%   img     -- RGB image to be filtered
%   depth   -- depth map

 tic

fpixelSize = 0.00273843226;

sizeIm = size(img);
A = dEye/2 * scale; % adjust this to project COC on depth plane to screen
Cmin = 0.5;
cocMatrix = A * calculateCoC(depth, fplane);

% Generate Depth Thresholds: D1, D2
D1 = A*fplane / (A + Cmin);
D2 = A*fplane / (A - Cmin);

    
% Segment Image based on focus regions
% Foreground out-of-focus (FOR) -- 1
% In-focus (IR)                 -- 2
% Background out-of-focus (BOR) -- 3
FOR = (depth <= D1) * 1;
IR  = (depth > D1 & depth <= D2)* 2;
BOR = (depth > D2) * 3;
Regions = FOR+IR+BOR;

% Compute Weights
ALPHALR = zeros([size(img,1) size(img,2)-1]);
for i = 1:size(img,1)
    for j = 1:size(img,2)-1
        pCoC = cocMatrix(i,j);
        if( round(pCoC) >= j)
            pCoCs = cocMatrix(i, 1:j+round(pCoC));
        elseif (j+round(pCoC) >= size(img,2))
            pCoCs = cocMatrix(i, j-round(pCoC):end);
        else
            pCoCs = cocMatrix(i, j-round(pCoC):j+round(pCoC));
        end
        
        qCoC = cocMatrix(i,j+1);
        if( round(qCoC)+1 >= j)
            qCoCs = cocMatrix(i, 1:j+1+round(qCoC));
        elseif (j+1+round(qCoC) >= size(img,2))
            qCoCs = cocMatrix(i, j+1-round(qCoC):end);
        else
            qCoCs = cocMatrix(i, j+1-round(qCoC):j+1+round(qCoC));
        end
        
        maxCoC = max([pCoCs qCoCs]);
        
        ALPHALR(i,j) = calculateAlpha(pCoC, qCoC, maxCoC, Regions(i,j),Regions(i,j+1));
    end
end

ALPHAUD = zeros([size(img,1)-1 size(img,2)]);
for i = 1:size(img,1)-1
    for j = 1:size(img,2)
        pCoC = cocMatrix(i,j);
        if( round(pCoC) >= i)
            pCoCs = cocMatrix(1:i+round(pCoC), j);
        elseif (i+round(pCoC) >= size(img,1))
            pCoCs = cocMatrix(i-round(pCoC):end, j);
        else
            pCoCs = cocMatrix(i-round(pCoC):i+round(pCoC), j);
        end
        
        qCoC = cocMatrix(i+1,j);
        if( round(qCoC) >= i)
            qCoCs = cocMatrix(1:i+1+round(qCoC), j);
        elseif (i+1+round(qCoC) >= size(img,1))
            qCoCs = cocMatrix(i+1-round(qCoC):end, j);
        else
            qCoCs = cocMatrix(i+1-round(qCoC):i+1+round(qCoC), j);
        end
        
        maxCoC = max([pCoCs; qCoCs]);
        
        ALPHAUD(i,j) = calculateAlpha(pCoC, qCoC, maxCoC, Regions(i,j),Regions(i+1,j));
    end
end

% Recursive Filtering
imgRec(:,:,:,1) = img;
for pass = 1:3
   imgIt = imgRec(:,:,:,pass);
   % Filter Left to Right
   for i = 1:sizeIm(1)
       for j = 2:sizeIm(2)
           alpha = ALPHALR(i,j-1);
           imgIt(i,j,:) = (1-alpha)*imgIt(i,j,:) + alpha*imgIt(i, j-1,:);
       end
   end
   
   % Filter Right to Left
   for i = 1:sizeIm(1)
       for j = sizeIm(2)-1:1
           alpha = ALPHALR(i,j);
           imgIt(i,j,:) = (1-alpha)*imgIt(i,j,:) + alpha*imgIt(i, j+1,:);
       end
   end
   
   % Filter Top to Bottom
   for j = 1:sizeIm(2)
       for i = 2:sizeIm(1)
           alpha = ALPHAUD(i-1,j);
           imgIt(i,j,:) = (1-alpha)*imgIt(i,j,:) + alpha*imgIt(i-1,j,:);
       end 
   end
   
   % Filter Bottom to Top
   for j = 1:sizeIm(2)
       for i = sizeIm(1)-1:1
           alpha = ALPHAUD(i,j);
           imgIt(i,j,:) = (1-alpha)*imgIt(i,j,:) + alpha*imgIt(i+1,j,:);
       end 
   end
  
   imgRec(:,:,:,pass+1) = imgIt;
   pass
end

time = toc;
outImg = imgRec(:,:,:,end);
% display(['The recursive filtering algorithm took ' num2str(time) ' seconds to compute']);
% figure; imshow(outImg);

end

% Calculates the circle of confusion radius
function [coc] = calculateCoC(depthFrag, depthFocal)
    coc = abs(depthFrag - depthFocal) ./ depthFrag;
end
