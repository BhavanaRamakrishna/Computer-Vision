clear all;
close all;
clc;
%read the grayScaleImage
grayScaleImage = imread('mnn4-runway-Ohio.jpg');
doubleImage = double(grayScaleImage);

%obtain the edge map
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

for i= 1:ir
    for j=1:ic
        if outputImage(i,j) == 0
            outputImage(i,j) = doubleImage(i,j);
        end
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
%edge map 
vector_magnitude = sqrt(vector);
%apply threshold to get clear edges
maxi = max(max(vector_magnitude))/8;
for i = 1:size(vector_magnitude,1)
    for j = 1:size(vector_magnitude,2)
        if (vector_magnitude(i,j)>maxi)
            vector_magnitude(i,j) = 255;
        end
    end
end

figure
imshow(uint8(vector_magnitude)), title('edge map');

%set variables to generate accumulator
ir = size(grayScaleImage,1);
ic = size(grayScaleImage,2);
%diagonal length will be the maximum distance - rho
max_dist = round(sqrt(ir^2 + ic^2));
%initialize theta and rho with the given range
theta = -90:1:90;
rho = -max_dist:1:max_dist;
%initialize accumulator array
accumulator = double(zeros(2*max_dist, size(theta,2)));

%obtain votes for every pair of rho and theta
for x = 1:ir
    for y = 1:ic
        if(vector_magnitude(x,y) == 255 )
            for itheta = 1:length(theta)
                dist = round(x*cos(degtorad(theta(itheta))) + y*sin(degtorad(theta(itheta))));
                index = round(dist + size(rho,2)/2);
                accumulator(index,itheta) = accumulator(index,itheta) + 1;
            end
        end
    end
end

%plot the hough space
figure;
imagesc(theta,rho,accumulator),title('Hough Space');
xlabel('Theta');
ylabel('Rho');

%hold on to superimpose peak marks on the houhspace
figure;
imagesc(theta,rho,accumulator),title('Hough Space with peaks detected');
xlabel('Theta');
ylabel('Rho');
hold on;

%select maximum peaks as local maximum from the 8X8 window, tracing through the
%accumulator 
irows = size(accumulator,1);
icols = size(accumulator,2);
m = 1;
peak_theta = [];
peak_rho = [];
for i=1:8:irows-8
    for j=1:8:icols-8
        max = -999;
        for ii=i:i+8-1
            for jj=j:j+8-1
                if (accumulator(ii,jj) > max)
                    max = accumulator(ii,jj);
                    temp_r = ii;
                    temp_t = jj;
                end
            end
        end
        peak_theta(m) = temp_t;
        peak_rho(m) = temp_r;
        value(m) = max;
        m = m+1;
    end
end


%select only top 6 peaks from the peaks selected by tracing 8X8 window over
%the entire accumulator
[ sortedH, ix ] = sort( value, 'descend' );
[ i, ii ] = ind2sub( size(value), ix(1:8) );

new_value = value(ii);
new_theta = peak_theta(ii);
new_rho = peak_rho(ii);
% plot all the detected peaks on hough space marked red
plot(theta(new_theta), rho(new_rho),'rx');
hold off;

%all the peaks detected from the window are written in the file
%Mymatrix.txt
fid = fopen('Mymatrix.txt','wt'); 
for ii = 1:size(value,1) 
    fprintf(fid,'%g\t',peak_rho(i));
    fprintf(fid,'%g\t',peak_theta(i));
    fprintf(fid,'%g\t',value(i)); 
    fprintf(fid,'\n'); 
end
fclose(fid);
% plot the detected line superimposed on the original image using the line
% equation y=mx+b
figure;
imshow(grayScaleImage),title('Edges detected');
hold on;
for i = 1:size(new_theta,2)
    m = -(cos(degtorad(theta(new_theta(i))))/sin(degtorad(theta(new_theta(i)))));
    b = rho(new_rho(i))/sin(degtorad(theta(new_theta(i))));
    x = 1:size(grayScaleImage,2);
    hold on;
    plot( m*x+b,x,'-r', 'linewidth',1.5);
    hold off;
end