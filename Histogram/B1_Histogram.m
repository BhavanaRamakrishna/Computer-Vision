clear all;
close all;
clc
img = imread('Reference.png');
%convert to gray scale image
grayScaleImage = rgb2gray(img);
figure
subplot(1,2,1)
imshow(img), title('Original Image')
subplot(1,2,2)
imshow(grayScaleImage), title('Gray Scale Image')
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
row = size(grayScaleImage,1)
col = size(grayScaleImage,2)
%1D array that stores relative frequencies of occurrence of greylevels in
%the image, and normaize
frequency = values(hashmap);
freq = double(cell2mat(frequency));
%normalizing frequency to be between 0-1
scaledP = freq/(row*col);

%plot histogram from frequencies 256 bins
figure
bar(scaledP), title('Histogram');

%calculating pdf & cdf from histogram
total = 0;
for j= 1:size(scaledP,2)
        value = scaledP(j);
        pdf(j) = double(value/sum(scaledP));
        cdf(j) = total + pdf(j)
        total = total + pdf(j)
end
figure
subplot(2,1,1)
plot(pdf),title('pdf');
subplot(2,1,2);
plot(cdf),title('cdf');

figure
subplot(2,2,1)
imshow(grayScaleImage), title('Image')
subplot(2,2,2)
bar(scaledP), title('Histogram');
subplot(2,2,3)
plot(pdf),title('pdf');
subplot(2,2,4);
plot(cdf),title('cdf');
