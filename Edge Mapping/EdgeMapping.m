clear all;
close all;
clc;
img = imread('capitol.jpg');
grayScaleImage = img;
doubleImage = double(grayScaleImage);
%smoothening the image
h = ones(5,5)/25;
ir = size(grayScaleImage,1);
ic = size(grayScaleImage,2);
kr = 5;
kc = 5;
row = round(kr/2);
col = round(kc/2);
outputImage = double(zeros(ir,ic));
for i=row:ir-row+1
    for j=col:ic-col+1
        sum = 0
        for ii=1:kr
            for jj=1:kc
                sum = sum + h(ii,jj)*doubleImage(i-row+ii,j-col+jj);
            end
        end
        outputImage(i,j) = sum;
    end
end
%1X3 mask to obtain x derivative
h  = [-1,0,1];
ir = size(outputImage,1);
ic = size(outputImage,2);
kr = 1;
kc = 3;
row = 1;
col = round(kc/2);
dx = double(zeros(ir,ic));

%filtering with 1X3 mask
for i=row:ir-row+1
    for j=col:ic-col+1
        sum = 0
        for ii=1:kr
            for jj=1:kc
                sum = sum + h(ii,jj)*outputImage(i-row+ii,j-col+jj);
            end
        end
        dx(i,j) = sum;
    end
end

%3X1 mask to obtain derivative of y
h  = [-1;0; 1];
ir = size(outputImage,1);
ic = size(outputImage,2);
kr = 3;
kc = 1;
row = round(kr/2);
col = 1;
dy = double(zeros(ir,ic));
%smoothening with 3X1 mask
for i=row:ir-row+1
    for j=col:ic-col+1
        sum = 0
        for ii=1:kr
            for jj=1:kc
                sum = sum + h(ii,jj)*outputImage(i-row+ii,j-col+jj);
            end
        end
        dy(i,j) = sum;
    end
end

%vector magnitude
vector = dx.^2 + dy.^2;
vector_magnitude = sqrt(vector)
orientation = double(zeros(ir,ic));
for i=1:ir
    for j=1:ic
            %atand is used to calculate tan inverse in degrees
            orientation(i,j) = atand(dy(i,j)/dx(i,j));
    end
end
mini = min(min(orientation))
maxi = max(max(orientation))
displayImage = double(zeros(ir,ic));
for i= 1:ir
    for j=1:ic
            displayImage(i,j) = interp1([-255,255],[0,225],dy(i,j));
    end
end
display1Image = double(zeros(ir,ic));
for i= 1:ir
    for j=1:ic
            display1Image(i,j) = interp1([-255,255],[0,225],dx(i,j));
            
    end
end

display3Image = double(zeros(ir,ic));
for i= 1:ir
    for j=1:ic
            display3Image(i,j) = abs(orientation(i,j));
    end
end
display4Image = double(zeros(ir,ic));
for i= 1:ir
    for j=1:ic
            display4Image(i,j) = interp1([-90,90],[0,255],orientation(i,j));
    end
end
subplot(2,3,1)
imshow(grayScaleImage), title('Image');
subplot(2,3,2)
imshow(uint8(outputImage)), title('Smoothed Image');
subplot(2,3,3)
imshow(uint8(display1Image)), title('df/dx Image');
subplot(2,3,4)
imshow(uint8(displayImage)), title('df/dy Image');
subplot(2,3,5)
imshow(uint8(vector_magnitude)), title('edge map');
subplot(2,3,6)
imshow(uint8(display3Image)), title('orientation map');
