% Plot aperture
clear;

apSamples = csvread('apertureLocations.txt');
apSamples = apSamples(:,1:2);

x = 0;
y = 0;
r = 0.002;

ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
figure; hold;
plot(x+xp,y+yp);
plot(apSamples(:,1), apSamples(:,2), '*');
