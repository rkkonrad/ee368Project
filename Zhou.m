clear;

zNear = 0.06;
zFar = 100.0;
focalDepth = 0.5; % in negative world coordinates
filterWidth = 9;
filterR = (filterWidth-1)/2;
D_eye = 0.004;

img = im2double(imread('image_.png'));

depth = im2double(imread('depth_.png'));
depth = depth(:,:,3);

img = padarray(img, [filterR, filterR], 'replicate');
depth = padarray(depth, [filterR, filterR], 'replicate');

% Function Definitions
DepthToNDC = @(z) -2*z + 1; % LOOK AT WHETHER THIS SHOULD BE NEGATED OR NOT

DepthToWorld = @(z, clipNear, clipFar) ...
            2*clipNear*clipFar / (clipNear + clipFar - DepthToNDC(z) * ...
            (clipNear - clipFar));
calculateCoC =  @(D_eye, depthFrag, depthFocal) ...
                (D_eye * (depthFrag - depthFocal) / depthFrag)/2;
intensityFactor = @(rp) 1/rp^2;
        
        

[X Y] = meshgrid(-filterR:filterR);
mask = ( (X.^2 + Y.^2) <= (filterR)^2);

depth_w = zeros(size(depth));        
tic


% for i = filterR+1 : size(depth,1) - filterR
%     for j = filterR+1 : size(depth,2) - filterR
%         weights = zeros(filterWidth);
%         
%         centerDepth = DepthToWorld(depth(i,j), zNear, zFar);
%         % Compute CoC of Center Pixel
%         centerCoC = calculateCoC(D_eye, centerDepth, focalDepth);
%         % Compute Weight of Center Pixel
%         weights(filterR+1, filterR+1) = intensityFactor(centerCoC);
%         
%         for x = -filterR:filterR
%             for y = -filterR:filterR
%                 distToCenter = sqrt(x^2 + y^2);
%                 if(distToCenter > filterR || (x == 0 && y == 0))
%                     continue;
%                 end
%                 sampleDepth = DepthToWorld(depth(i+x, j+y), zNear, zFar);
%                 sampleCoC = calculateCoC(D_eye, sampleDepth, focalDepth);
%                 weights(x+filterR+1, y+filterR+1) = ...
%                     calculateWeight(distToCenter, sampleCoC, centerCoC, ...
%                                     sampleDepth, focalDepth);
%             end
%         end
%         imgPiece = img(i-filterR:i+filterR, i-filterR:i+filterR);
%         outImg(i,j) = sum(sum(imgPiece .* weights)) / sum(weights(:));
%     end
%     i
% end
time = toc;

display(['The Zhou:2007 algorithm took ' num2str(time) ' seconds to compute']);
                            


