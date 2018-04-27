clear all;
close all;
clc;
%reading the image
img = imread('desT.png');
%convert to grayscale
original_image = rgb2gray(img);
%obtain shape
rows = size(original_image,1);
cols = size(original_image,2);
%generate output image
new_image = double(zeros(rows,cols));
r = size(new_image,1);
c = size(new_image,2);
x0 = ceil(rows/2);
y0 = ceil(cols/2);

%specifying parameters
degree = 50;
transX = 10;
transY = 10;
scalX = 1.2;
scalY = 1.2;
shear = 0.2;

%setting the matrices
theta = degtorad(degree);
ro = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
tr = [1,0,transX;0,1,transY;0,0,1];
sc = [scalX,0,0;0,scalY,0;0,0,1];
sh = [1,0,0;shear,1,0;0,0,1];

%generating values for output matrix using nearest neighbour
for x=1:r
    for y=1:c
        %for each coordinate
        o = [x;y;1];
        %multiply scaling, shear matrices with original coordinate
        nw = inv(sc)*inv(sh);
        n1 = nw*o;
        %obtain coordiantes to rotate by translating the origin to centre
        %of the image
        o1 = [n1(1,1)-x0;n1(2,1)-y0;1];
        %multiply rotation matrix
        n2 = inv(ro)*o1
        n2 = n2 + [x0;y0;1];
        %perform translation 
        n = inv(tr)*n2;
        
        %obtain nearest neighbour for index within the limits
        n = round(n);
        if (n(1,1) < 1) 
            n(1,1) = 1;
        end
        if (n(2,1) < 1)
            n(2,1) = 1;
        end
        if (n(1,1) > rows - 1) 
            n(1,1) = rows - 1;
        end
        if (n(2,1) > cols - 1) 
            n(2,1) = cols - 1;
        end
        new_image(x,y) = original_image(n(1,1), n(2,1));

    end
end
figure
subplot(1,2,1)
imshow(uint8(original_image)), title('Given image');
subplot(1,2,2)
imshow(uint8(new_image)), title('Transformed image using nearest neighbour');

%generate output image using bilinear interpolation
for x=1:rows
    for y=1:cols
        o = [x;y;1];
        %multiply scaling, shear matrices with original coordinate
        nw = inv(sc)*inv(sh);
        n1 = nw*o;
        %obtain coordiantes to rotate by translating the origin to centre
        %of the image
        o1 = [n1(1,1)-x0;n1(2,1)-y0;1];
        %multiply rotation matrix
        n2 = inv(ro)*o1
        n2 = n2 + [x0;y0;1];
        %perform translation 
        n = inv(tr)*n2;
        %check index to be within the limits
        if (n(1,1) < 1) 
            n(1,1) = 1;
        end
        if (n(2,1) < 1)
            n(2,1) = 1;
        end
        if (n(1,1) > rows - 1) 
            n(1,1) = rows - 1;
        end
        if (n(2,1) > cols - 1) 
            n(2,1) = cols - 1;
        end
        %using bilinear equation
        x1 = round(n(1,1));
        x2 = x1 + 1;
        y1 = round(n(2,1));
        y2 = y1 + 1;
        p1 = double((x2-n(1,1))/double(x2-x1));
        p2 = double((n(1,1)-x1)/double(x2-x1));
        r1 = p1*original_image(x1,y1) + p2*original_image(x2,y1);
        r2 = p1*original_image(x1,y2) + p2*original_image(x2,y2);
        q1 = double((y2-n(2,1))/double(y2-y1));
        q2 = double((n(2,1)-y1)/double(y2-y1));
        nv = double(q1*r1) + double(q2*r2);
        new_image(x,y) = nv;
            
    end
end
figure
subplot(1,2,1)
imshow(uint8(original_image)), title('Given image');
subplot(1,2,2)
imshow(uint8(new_image)), title('Transformed image using bilinear');