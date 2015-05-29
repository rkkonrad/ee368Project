clear;

% Function Definitions
DepthToNDC = @(z) -2*z + 1; % LOOK AT WHETHER THIS SHOULD BE NEGATED OR NOT

DepthToWorld = @(z, clipNear, clipFar) ...
            2*clipNear*clipFar ./ (clipNear + clipFar - DepthToNDC(z) * ...
            (clipNear - clipFar));
calculateCoC =  @(D_eye, depthFrag, depthFocal) ...
                abs(D_eye * (depthFrag - depthFocal) ./ depthFrag)/2;
intensityFactor = @(rp) 1/rp^2;

% Algorithm Parameters
zNear = 0.06;
zFar = 100.0;
focalDepth = 0.2545; % in negative world coordinates
filterWidth = 9;
filterR = (filterWidth-1)/2;
D_eye = 0.004;

% Read in Images
img = im2double(imread('imsmall.png'));
depth = im2double(imread('depthsmall.png'));
%depth = depth(:,:,3);

outImg = zeros(size(img));
img = padarray(img, [filterR, filterR], 'replicate');
depth = padarray(depth, [filterR, filterR], 'replicate');

[X Y] = meshgrid(-filterR:filterR);
mask = ( (X.^2 + Y.^2) <= (filterR)^2);

 

depth_w = DepthToWorld(depth, zNear, zFar);
cocMatrix = calculateCoC(D_eye, depth_w, focalDepth)*1000;

tic
for i = filterR+1 : size(depth,1) - filterR
    for j = filterR+1 : size(depth,2) - filterR

        weights = zeros(filterWidth);
        
        centerDepth = depth_w(i,j);
        centerCoC = cocMatrix(i,j);
        weights(filterR+1, filterR+1) = intensityFactor(centerCoC);
        
        for x = -filterR:filterR
            for y = -filterR:filterR
                distToCenter = sqrt(x^2 + y^2);
                if(distToCenter > filterR || (x == 0 && y == 0))
                    continue;
                end
                sampleDepth = depth_w(i+x, j+y);
                sampleCoC = cocMatrix(i+x, j+y);
                weights(x+filterR+1, y+filterR+1) = ...
                calculateWeight(distToCenter, sampleCoC, centerCoC, ...
                                    sampleDepth, focalDepth);
            end
        end
        imgPiece = img(i-filterR:i+filterR, j-filterR:j+filterR, :);
        outImg(i-filterR,j-filterR,:) = sum(sum(imgPiece .* repmat(weights, [1 1 3]))) / sum(weights(:));
    end
    i
end
time = toc;

display(['The Zhou:2007 algorithm took ' num2str(time) ' seconds to compute']);
imshow(outImg);
                            


