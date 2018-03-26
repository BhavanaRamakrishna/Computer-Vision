clear all;
close all;
clc;
img = imread('shapes-bw.jpg');
dices = rgb2gray(img);
doubleImage = double(dices);
templateImg = imread('shape-bw.jpg');
template= rgb2gray(templateImg);

%mean intensity is calculated and deducted from the template
doubleTemplate = double(template);
meanT = mean2(doubleTemplate);
doubleTemplate = doubleTemplate - meanT;

ir = size(doubleImage,1);
ic = size(doubleImage,2);
tr = size(doubleTemplate,1);
tc = size(doubleTemplate,2);
newImage = double(zeros(ir,ic));
row = round(tr/2);
col = round(tc/2);

%pad the original image to manage boundaries
padImage = padarray(doubleImage,[row+1 row+1],'both');

%fitering the image with the template
for i=1:size(padImage,1)-tr
    for j=1:size(padImage,2)-tc
        tempImage = double(zeros(tr,tc));
        tempImage = padImage(i:i+tr-1,j:j+tc-1);
        meanW = mean2(tempImage);
        tempImage = tempImage - meanW;
        C=tempImage.*doubleTemplate;
        pixel_sum = sum(C(:));
        %to obtain normalized correlation image
        w = tempImage.^2;
        nw = sqrt(sum(w(:)));
        f = doubleTemplate.^2;
        nf = sqrt(sum(f(:)));
        n = nf*nw;
        newImage(i,j) = pixel_sum*(1/n);
    end
end
display1Image = double(zeros(size(newImage,1),size(newImage,2)));
for i= 1:ir
    for j=1:ic
            display1Image(i,j) = interp1([-1,1],[0,225],newImage(i,j));
    end
end
%thresholding
display2Image = double(zeros(size(newImage,1),size(newImage,2)));
for i= 1:ir
    for j=1:ic
            if newImage(i,j) > 0.9
                display2Image(i,j) = 1
            else
                display2Image(i,j) = newImage(i,j);
            end
    end
end
%smoothing before applying laplacian
h = ones(3,3)/9;
ir = size(display2Image,1);
ic = size(display2Image,2);
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
                sum = sum + h(ii,jj)*display2Image(i-row+ii,j-col+jj);
            end
        end
        outputImage(i,j) = sum;
    end
end
%using lapalacian fileter as peak detector
h = [0,-1,0;-1,4,-1;0,-1,0];
ir = size(display1Image,1);
ic = size(display1Image,2);
kr = 3;
kc = 3;
row = round(kr/2);
col = round(kc/2);
laplacianImage = double(zeros(ir,ic));
for i=row:ir-row+1
    for j=col:ic-col+1
        sum2 = 0.0
        for ii=1:kr
            for jj=1:kc
                sum2 = sum2 + h(ii,jj)* outputImage(i-row+ii,j-col+jj);
            end
        end
        laplacianImage(i,j) = sum2;
    end
end

display4Image = double(zeros(size(display2Image,1),size(display2Image,2)));
for i= 1:ir
    for j=1:ic
                display4Image(i,j) = interp1([-1,1],[0,225],laplacianImage(i,j));
    end
end
display3Image = double(zeros(size(display2Image,1),size(display2Image,2)));
for i= 1:ir
    for j=1:ic
            display3Image(i,j) = interp1([-1,1],[0,225],display2Image(i,j));
    end
end


subplot(2,2,1)
imshow(uint8(doubleImage)), title('Original Image');
subplot(2,2,2)
imshow(uint8(display1Image)), title('Normalized Correlation Image');
subplot(2,2,3)
imshow(uint8(display3Image)), title('Thresholded Correlation Image');
subplot(2,2,4)
imshow(uint8(display4Image)), title('Laplacian Correlation Image') ;
