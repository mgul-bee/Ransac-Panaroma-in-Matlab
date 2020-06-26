clc 
close all 
clear all

image1 = imread('P1.png');
image2 = imread('P2.png');
 
[R1, C1, ~ ] = size(image1);
[R2, C2, ~ ] = size(image2);
 
% imshow(image1)
% [X1, Y1] = ginput(4);
% figure, imshow(image2);
% [X2, Y2] = ginput(4);
 
X1 = [267;285;305;318;570;584];
Y1 = [194;194;232;196;142;102];
X2 = [102;120;141;155;404;417];
Y2 = [212;213;250;215;167;132];
 
A = zeros(8, 9);
 
for i = 1:6
xd = [X1(i),Y1(i), 1];
K = [-xd , zeros(1, 3), X2(i)*xd ; zeros(1, 3), -xd, Y2(i)* xd];
if i ~= 1
A = [A;K];
else
    A = K;
end
end
 
[U,S,V] = svd(A, 0);
H = reshape(V(:,end),3,3);
H = H';
H = H./H(3,3);
 
p1 = zeros(4,3);
for i=1:4
    p1(i,:) = [X1(i), Y1(i), 1];
end
 
p2 = zeros(4,3);
for j=1:4
    p2(j,:) = [X2(j), Y2(j), 1];
end
 
options = optimset('GradObj','off','MaxIter', 400,'Display','iter');
[final_h,cost] = fminunc(@(h)costHomography(h,p1,p2),H,options)
 
H = final_h/final_h(3,3);
 
 
corner1 = [1;1;1];
corner2 = [1;R2;1];
corner3 = [C2;R2;1];
corner4 = [C2;1;1];
 
n1 = H\corner1;
n1 = n1./n1(3);
n2 = H\corner2;
n2 = n2./n2(3);
n3 = H\corner3;
n3 = n3./n3(3);
n4 = H\corner4;
n4 = n4./n4(3);
 
x_bound = [1 C2 n1(1) n2(1) n3(1) n4(1)];
y_bound = [1 R2 n1(2) n2(2) n3(2) n4(2)];
 
x_min = floor(min(x_bound));
y_min = floor(min(y_bound));
x_max = ceil(max(x_bound));
y_max = ceil(max(y_bound));
 
col = x_max - x_min;
row = y_max - y_min;
 
tX = 0;
tY = 0;
 
if x_min <= 0
    tX = abs(x_min) + 1;
end
if y_min <= 0
    tY = abs(y_min) + 1;
end
 
panorama = zeros(row+1,col+1,3);
 
for i = 1 : R1
    for j = 1 : C1
        panorama(i + tY ,j + tX,:) = image1(i,j,:);
    end
end
 
imshow(uint8(panorama));
 
for i = 1: R2
    for j = 1 : C2
        point = H\([j;i;1]);
        point = point./point(3);
        newY = floor(point(2)) + tY;
        newX = floor(point(1)) + tX;
        if(panorama(newY, newX, :) == 0)
            panorama(newY, newX, :) = image2(i, j, :);
        end
    end
end
 
figure
imshow(uint8(panorama))
 
panorama_final = panorama;
 
for i = 2 : row-2
    for j = 2 : col-2
            if (panorama(i,j,:) == 0)
            for k = 1 : 3
                panorama_final(i,j,k) = interp2(panorama(i-1:i+1, j-1:j+1, k), 1, 1);
            end
            end
    end
end
 
figure
imshow(uint8(panorama_final))