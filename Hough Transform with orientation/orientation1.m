clear all;
close all;
clc;
img = imread('mnn4-runway-Ohio.jpg');
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
vector_magnitude = sqrt(vector);
maxi = max(max(vector_magnitude))/8;
orientation = double(zeros(ir,ic));

for i=1:ir
    for j=1:ic
            if vector_magnitude(i,j) > maxi
                vector_magnitude(i,j) = 255;
            end
            %atand is used to calculate tan inverse in degrees
            if (dy(i,j)==0)
                dy(i,j) = 0.1;
            end
            orientation(i,j) = atand(dx(i,j)/dy(i,j));
    end
end
figure
imshow(uint8(vector_magnitude)), title('edge map');
figure
imshow(uint8(orientation)), title('orientation');
max_theta = max(max(orientation));
min_theta = min(min(orientation));
orientation
%set variables to generate accumulator
ir = size(orientation,1);
ic = size(orientation,2);
%diagonal length will be the maximum distance - rho
max_dist = round(sqrt(ir^2 + ic^2));
%initialize theta and rho with the given range
theta = -90:1:91;
rho = -max_dist:1:max_dist;
%initialize accumulator array
accumulator = double(zeros(2*max_dist, size(theta,2)));

for x = 1:ir
    for y = 1:ic
        if(vector_magnitude(x,y) ~= 0 )
                    the = orientation(x,y);
                    dist = round(x*cos(degtorad(the)) + y*sin(degtorad(the)));
                    index = round(dist + size(rho,2)/2-1);
                    index_t = round(the + 91);
                    accumulator(index,index_t) = accumulator(index,index_t) + 1;
        end
    end
end

%plot the hough space
figure;
imagesc(theta,rho,accumulator),title('Hough Space');
xlabel('Theta');
ylabel('Rho');

figure;
imagesc(theta,rho,accumulator),title('Hough Space with peaks detected');
xlabel('Theta');
ylabel('Rho');
hold on;
%get top 10 peaks
[ sortedH, ix ] = sort( accumulator(:), 'descend' );
[ peak_rho, peak_theta ] = ind2sub( size(accumulator), ix(1:10) );

% plot all the detected peaks on hough space marked red
plot(theta(peak_theta), rho(peak_rho),'rx');
hold off;

degtorad(theta(peak_theta))
figure;
imshow(grayScaleImage),title('Edges detected');
hold on;
for i=1:size(peak_rho,1)
    a = cos(degtorad(peak_theta(i)-91));
    b = sin(degtorad(peak_theta(i)-91));
    x0 = a.*rho(peak_rho(i));
    y0 = b.*rho(peak_rho(i));
    x =[ round(x0 + 1000*(-b)),round(x0 - 1000*(-b))];
    y =[ round(y0 + 1000*(a)),round(y0 - 1000*(a))];
    plot(y,x,'-r','linewidth',1);
end