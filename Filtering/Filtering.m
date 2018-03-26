clear all;
close all;
clc;
img = imread('butterfly.jpeg');
grayScaleImage = rgb2gray(img);
doubleImage = double(grayScaleImage);
%filtering with 3X3 filter
h = ones(3,3)/9;
ir = size(grayScaleImage,1);
ic = size(grayScaleImage,2);
kr = 3;
kc = 3;
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
%correcting the borders
for i= 1:ir
    for j=1:ic
        if outputImage(i,j) == 0
            outputImage(i,j) = doubleImage(i,j);
        end
    end
end
figure
subplot(1,2,1)
imshow(grayScaleImage), title('Image');
subplot(1,2,2)
imshow(uint8(outputImage)), title('3X3 Filtered Image');
%5X5 filter
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
for i= 1:ir
    for j=1:ic
        if outputImage(i,j) == 0
            outputImage(i,j) = doubleImage(i,j);
        end
    end
end
figure
subplot(1,2,1)
imshow(grayScaleImage), title('Image');
subplot(1,2,2)
imshow(uint8(outputImage)), title('5X5 Filtered Image');
