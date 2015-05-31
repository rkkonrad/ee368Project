% Function Definitions
DepthToNDC = @(z) -2*z + 1; % LOOK AT WHETHER THIS SHOULD BE NEGATED OR NOT
DepthToWorld = @(z, clipNear, clipFar) ...
            2*clipNear*clipFar ./ (clipNear + clipFar - DepthToNDC(z) * ...
            (clipNear - clipFar));

% Defines System Parameters
zNear = 0.06;
zFar = 100.0;
focalDepth = 0.2545; % in negative world coordinates
D_eye = 0.004;

% Read in Image and Depth Map
img = im2double(imread('imsmall.png'));
depth = im2double(imread('depthsmall.png'));
% img = im2double(imread('images/image_.png'));
% depth = im2double(imread('images/depth_.png'));
% depth = depth(:,:,3);
depthW = DepthToWorld(depth, zNear, zFar);
sizeIm = size(img);