clear all;
close all;
clc;
%read the image
img = imread('desT.png');
%obtain the gray scale image
original_image = rgb2gray(img);

%specifying parameters
degree = 30;
transX = -50;
transY = -50;
scalX = 1.2;
scalY = 1.2;
shear = 0.2;

%setting the matrices
theta = degtorad(degree);
rotation = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
translation = [1,0,transX;0,1,transY;0,0,1];
scaling = [scalX,0,0;0,scalY,0;0,0,1];
shear = [1,0,0;shear,1,0;0,0,1];

figure('Name','Using Nearest Neighbor','NumberTitle','off')
subplot(2,3,1)
imshow(uint8(original_image)),title('Original Image');
subplot(2,3,2)
NN(original_image, translation, 'Translation');
subplot(2,3,3)
NN(original_image, rotation, 'Rotation');
subplot(2,3,4)
NN(original_image, scaling, 'Scaling');
subplot(2,3,5)
NN(original_image, shear, 'Shear');


figure('Name','Using Bilinear Interpolation','NumberTitle','off')
subplot(2,3,1)
imshow(uint8(original_image)),title('Original Image');
subplot(2,3,2)
bilinear(original_image, translation, 'Translation');
subplot(2,3,3)
bilinear(original_image, rotation, 'Rotation');
subplot(2,3,4)
bilinear(original_image, scaling, 'Scaling');
subplot(2,3,5)
bilinear(original_image, shear, 'Shear');

function NN(image, transformation_matrix,type)
    %set variables
    rows = size(image,1);
    cols = size(image,2);
    new_image = double(zeros(rows,cols));
    r = size(new_image,1);
    c = size(new_image,2);
    if (strcmp(type,'Rotation'))
        x0 = ceil(rows/2);
        y0 = ceil(cols/2);
        for x=1:r
            for y=1:c
                o = [x-x0;y-y0;1];
                n = inv(transformation_matrix)*o
                n = n + [x0;y0;1];
                n = round(n)
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
                %obtain nearest neighbor
                n = round(n);
                new_image(x,y) = image(n(1,1), n(2,1));
            end
        end
        imshow(uint8(new_image)),title(type);
    else
         for x=1:r
            for y=1:c
                o = [x;y;1];
                n = inv(transformation_matrix)*o;
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
                %obtain nearest neighbor
                n = round(n);
                new_image(x,y) = image(n(1,1), n(2,1));

            end
         end
        imshow(uint8(new_image)),title(type);
    end
        
end  
   

function bilinear(image, transformation_matrix,type)
    %set variables
    rows = size(image,1);
    cols = size(image,2);
    new_image = double(zeros(rows,cols));
    r = size(new_image,1);
    c = size(new_image,2);
    if (strcmp(type,'Rotation'))
        x0 = ceil(rows/2);
        y0 = ceil(cols/2);
        for x=1:r
            for y=1:c
                o = [x-x0;y-y0;1];
                n = inv(transformation_matrix)*o;
                n = n + [x0;y0;1];
                %bilinear interpolation
                if (n(1,1) < 1) 
                    n(1,1) = 1;
                end
                if (n(2,1) < 1)
                    n(2,1) = 1;
                end
                if (n(1,1) > rows-1) 
                    n(1,1) = rows - 1;
                end
                if (n(2,1) > cols-1) 
                    n(2,1) = cols - 1;
                end
                x1 = round(n(1,1));
                x2 = x1 + 1;
                y1 = round(n(2,1));
                y2 = y1 + 1;
                p1 = double((x2-n(1,1))/double(x2-x1));
                p2 = double((n(1,1)-x1)/double(x2-x1));
                r1 = p1*image(x1,y1) + p2*image(x2,y1);
                r2 = p1*image(x1,y2) + p2*image(x2,y2);
                q1 = double((y2-n(2,1))/double(y2-y1));
                q2 = double((n(2,1)-y1)/double(y2-y1));
                nv = double(q1*r1) + double(q2*r2);
                new_image(x,y) = nv;
            end
        end
        imshow(uint8(new_image)),title(type);
    else
         for x=1:r
            for y=1:c
                o = [x;y;1];
                n = inv(transformation_matrix)*o;
                %bilinear interpolation
                if (n(1,1) < 1) 
                    n(1,1) = 1;
                end
                if (n(2,1) < 1)
                    n(2,1) = 1;
                end
                if (n(1,1) > rows-1) 
                    n(1,1) = rows - 1;
                end
                if (n(2,1) > cols-1) 
                    n(2,1) = cols - 1;
                end
                x1 = round(n(1,1));
                x2 = x1 + 1;
                y1 = round(n(2,1));
                y2 = y1 + 1;
                p1 = double((x2-n(1,1))/double(x2-x1));
                p2 = double((n(1,1)-x1)/double(x2-x1));
                r1 = p1*image(x1,y1) + p2*image(x2,y1);
                r2 = p1*image(x1,y2) + p2*image(x2,y2);
                q1 = double((y2-n(2,1))/double(y2-y1));
                q2 = double((n(2,1)-y1)/double(y2-y1));
                nv = double(q1*r1) + double(q2*r2);
                new_image(x,y) = nv;

            end
         end
        imshow(uint8(new_image)),title(type);
    end
        
end  