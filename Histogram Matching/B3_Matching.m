clear all;
close all;
clc;
%reference image
reference = imread('Reference.png');
referenceImage = rgb2gray(reference);
%target image
image = imread('Shoe.jpg');
supportImage = rgb2gray(image);

%calculate cdf for reference image
hashref = containers.Map('KeyType','int64', 'ValueType','int64')
for ii=1:size(referenceImage,1)
    for jj=1:size(referenceImage,2)
        if(isKey(hashref,referenceImage(ii,jj)))
            hashref(referenceImage(ii,jj)) = double(hashref(referenceImage(ii,jj)) +1);
        else
            hashref(referenceImage(ii,jj)) = double(1);
        end
    end
end 
freqref = values(hashref);
qref = double(cell2mat(freqref));
total = 0;
for i = 1:size(qref,2)
    total = total + qref(i);
end
s=0
for j= 1:size(qref,2)
        value = qref(j);
        pdfref(j) = double(value/total);
        cdfref(j) = s + pdfref(j)
        s = s + pdfref(j)
end


%calculate cdf for support image
hashtar = containers.Map('KeyType','int64', 'ValueType','int64')
for ii=1:size(supportImage,1)
    for jj=1:size(supportImage,2)
        if(isKey(hashtar,supportImage(ii,jj)))
            hashtar(supportImage(ii,jj)) = double(hashtar(supportImage(ii,jj)) +1);
        else
            hashtar(supportImage(ii,jj)) = double(1);
        end
    end
end 
freqtar = values(hashtar);
qtar = double(cell2mat(freqtar));
total = 0;
for i = 1:size(qtar,2)
    total = total + qtar(i);
end
s=0
for j= 1:size(qtar,2)
        value = qtar(j);
        pdftar(j) = double(value/total);
        cdftar(j) = s + pdftar(j)
        s = s + pdftar(j)
end




%perform matching
Match = uint8(zeros(256,1));
for i=1:256
    [~, matchedIntensity] = min(abs(cdfref(i) - cdftar));
    Match(i) = matchedIntensity;
end

outImage = Match(double(referenceImage)+1);


%calculate pdf & cdf for output image
hashout = containers.Map('KeyType','int64', 'ValueType','int64')
for ii=1:size(outImage,1)
    for jj=1:size(outImage,2)
        if(isKey(hashout,outImage(ii,jj)))
            hashout(outImage(ii,jj)) = double(hashout(outImage(ii,jj)) +1);
        else
            hashout(outImage(ii,jj)) = double(1);
        end
    end
end 
freqout = values(hashout);
qout = double(cell2mat(freqout));
total = 0;
for i = 1:size(qout,2)
    total = total + qout(i);
end
s=0
for j= 1:size(qout,2)
        value = qout(j);
        pdfout(j) = double(value/total);
        cdfout(j) = s + pdfout(j)
        s = s + pdfout(j)
end


%plotting reference imgae, support image and output images' histogram, PDF
% and CDF

figure
subplot(2,2,1)
imshow(referenceImage),title('Reference Image');
subplot(2,2,2)
imshow(supportImage), title('Support Image');
subplot(2,2,3)
bar(qref), title('Histogram of Reference Image')
subplot(2,2,4)
bar(qtar), title('Histogram of Support Imgae')

figure
subplot(2,2,1)
bar(pdfref),title('PDF of Reference Image');
subplot(2,2,2)
bar(pdftar), title('PDF of Support Image');
subplot(2,2,3)
bar(cdfref), title('CDF of Reference Image')
subplot(2,2,4)
bar(cdftar), title('CDF of Support Imgae')

figure
subplot(2,2,1)
imshow(outImage), title('Output Image');
subplot(2,2,2)
bar(qout), title('Histogram of Output Image');
subplot(2,2,3)
bar(pdfout), title('PDF of Output Image')
subplot(2,2,4)
bar(cdfout), title('CDF of Output Imgae')

figure
subplot(1,2,1)
imshow(referenceImage),title('Reference Image');
subplot(1,2,2)
imshow(outImage), title('Output Image');
