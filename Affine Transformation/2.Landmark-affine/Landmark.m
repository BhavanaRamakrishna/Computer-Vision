clear all;
close all;
clc;
%read the original image
img = imread('paint-orig.jpeg');
%obtain gray scale image
original_image = rgb2gray(img);
%read the rotated image
img = imread('image-rotate.jpeg');
%obtain gray scale image
result_image = rgb2gray(img);

%display original image and retrieve 3 coordinates
figure
imshow(original_image),title('Select three points');
[x,y] = getpts

%display rotated image and retrieve the corresponding coordinates
figure
imshow(result_image),title('Select the corresponding points');
[xl,yl] = getpts
x1 = x(1,1);
x2 = x(2,1);
x3 = x(3,1);
y1 = y(1,1);
y2 = y(2,1);
y3 = y(3,1);

%generate linear equation
bigx = [x1,y1,1,0,0,0; 0,0,0,x1,y1,1;x2,y2,1,0,0,0;0,0,0,x2,y2,1;x3,y3,1,0,0,0;0,0,0,x3,y3,1];
smallx = [xl(1,1);yl(1,1);xl(2,1);yl(2,1);xl(3,1);yl(3,1)];
%obtain affine transformation
affine = inv(bigx)*smallx;

%use the obtained affine transformation
nm = [affine(1,1), affine(2,1),affine(3,1); affine(4,1), affine(5,1), affine(6,1);0,0,1];
rows = size(result_image,1);
cols = size(result_image,2);
%obatin the resultant image
new_image = double(zeros(rows,cols));
for i = 1: rows
    for j = 1:cols
        %multiply original coordinates with the obatined affine
        %transformation matrix
        o = [i;j;1];
        n = inv(nm)*o;
        %using nearest neighbor to obatin the cordinates
        if (n(1,1) < 1) 
            n(1,1) = 1;
        end
        if (n(2,1) < 1)
            n(2,1) = 1;
        end
        if (n(1,1) > size(original_image,1) - 1) 
            n(1,1) = size(original_image,1) - 1;
        end
        if (n(2,1) > size(original_image,2) - 1) 
            n(2,1) = size(original_image,2) - 1;
        end
        n = round(n);
        new_image(i,j) = original_image(n(1,1),n(2,1));
    end
end
new_image
figure
subplot(1,2,1)
imshow(result_image),title('Target image');
subplot(1,2,2)
imshow(new_image),title('Image obtained after affine transformation');
