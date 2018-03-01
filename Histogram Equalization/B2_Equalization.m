clear all;
close all;
clc
img = imread('Fruits.jpeg');
grayScaleImage = rgb2gray(img);
row = size(grayScaleImage,1);
col = size(grayScaleImage,2);
dimension = row*col;
hashmap = containers.Map('KeyType','int64', 'ValueType','int64')
for ii=1:size(grayScaleImage,1)
    for jj=1:size(grayScaleImage,2)
        if(isKey(hashmap,grayScaleImage(ii,jj)))
            hashmap(grayScaleImage(ii,jj)) = double(hashmap(grayScaleImage(ii,jj)) +1);
        else
            hashmap(grayScaleImage(ii,jj)) = double(1);
        end
    end
end 
%1D array that stores relative frequencies of occurrence of greylevels in
%the image, and normaize
frequency = values(hashmap);
freq = double(cell2mat(frequency));
%normalizing frequency to be between 0-1
scaledP = freq/dimension;
%Histogram equalization- here I am calculating PDF and CDF again but this
%time from the pixel matrix
temp = zeros(256,1);
pdf1 = zeros(256,1);
%calculate PDF, CDF and corresonding intensity values
for i = 1:row
    for j= 1:col
        intensity = grayScaleImage(i,j);
        %because intensity starts from 0 and arrays are indexed from 1
        temp(intensity+1) = temp(intensity+1)+1;
        pdf1(intensity+1) = temp(intensity+1)/dimension;
    end
end
sum = 0; 

cdf1 = zeros(256,1);
output = zeros(256,1);
%considering 255 bins since that gave the best result for the pictures
L = 255;
for i = 1:size(pdf1)
    sum = sum+temp(i);
    cdf1(i) = sum/dimension;
    output(i) = cdf1(i)*L;
end
%map the obtained intensity values with the old image
outputImage = uint8(zeros(row,col));
for i = 1:row
    for j=1:col
        outputImage(i,j) = output(grayScaleImage(i,j)+1);
    end
end

%to calculate new histigram after equilization
map = containers.Map('KeyType','int64', 'ValueType','int64')
for ii=1:size(outputImage,1)
    for jj=1:size(outputImage,2)
        if(isKey(map,outputImage(ii,jj)))
            map(outputImage(ii,jj)) = double(map(outputImage(ii,jj)) +1);
        else
            map(outputImage(ii,jj)) = double(1);
        end
    end
end 
%1D array that stores relative frequencies of occurrence of greylevels in
%the image, and normaize
pp = values(map);
qq = double(cell2mat(pp));
scaledPp = qq/(row*col);

temp1 = zeros(256,1);
pdfout = zeros(256,1);
%calculate PDF, CDF and corresonding intensity values
for i = 1:row
    for j= 1:col
        intensity = outputImage(i,j);
        %because intensity starts from 0 and arrays are indexed from 1
        temp1(intensity+1) = temp1(intensity+1)+1;
        pdfout(intensity+1) = temp1(intensity+1)/dimension;
    end
end
sum = 0; 

cdfout = zeros(256,1);
%considering 255 bins since that gave the best result for the pictures
L = 255;
for i = 1:size(pdf1)
    sum = sum+temp1(i);
    cdfout(i) = sum/dimension;
end

%plotting images and its corresponding histograms with 255 bins
figure
subplot(2,2,1)
imshow(grayScaleImage),title('Old Image')
subplot(2,2,2)
imshow(outputImage),title('New Image')
subplot(2,2,3)
bar(scaledP),title('Histogram before equalization')
subplot(2,2,4)
bar(scaledPp), title('Histogram after equalization')

%plotting its PDF and CDF
figure
subplot(2,2,1)
bar(pdf1),title('PDF before equalization')
subplot(2,2,2)
bar(pdfout),title('PDF after equalization')
subplot(2,2,3)
bar(cdf1),title('CDF before equalization')
subplot(2,2,4)
bar(cdfout), title('CDF after equalization')
