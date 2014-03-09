close all

[filename, pathname] = uigetfile( ...
{'*.BMP;*.GIF;*.JPG;*.PNG;*.TIF','All Graphics files (*.BMP,*.GIF,*.JPG,*.PNG,*.TIF)';
   '*.BMP',  'Windows Bitmap files (*.BMP)'; ...
   '*.GIF','Graphics Interchange Format files (*.GIF)'; ...
   '*.JPG;*.JPEG','Joint Photographic Experts Group files (*.JPG,*.JPEG)'; ...
   '*.PNG','Portable Network Graphics files (*.PNG)'; ...
   '*.TIF;*.TIFF','Tagged Image File Format files (*.TIF,*.TIFF)'; ...
   '*.*',  'All Files (*.*)'}, ...
   'Pick a file');

image = imread([pathname filename]);

bits = 4;

A=image;

%Plot Image and RGB Separations
figure
subplot(2,2,1)
imagesc(A)

subplot(2,2,2)
red = A;
red(:,:,2) = ones(size(red(:,:,2)));
red(:,:,3) = ones(size(red(:,:,3)));
imagesc(red)

subplot(2,2,3)
green = A;
green(:,:,1) = ones(size(green(:,:,1)));
green(:,:,3) = ones(size(green(:,:,3)));
imagesc(green)

subplot(2,2,4)
blue = A;
blue(:,:,1) = ones(size(blue(:,:,1)));
blue(:,:,2) = ones(size(blue(:,:,2)));
imagesc(blue)

drawnow

dimension = size(image);
pic_width=dimension(2);
pic_height=dimension(1);

image = double(A);
A=zeros(120,160);

[X,Y] = meshgrid(1:pic_width,1:pic_height);
[XI,YI] = meshgrid(1:(pic_width/160.1):pic_width,1:(pic_height/120.1):pic_height);
A(:,:,1) = interp2(X,Y,image(:,:,1),XI,YI,'spline');
A(:,:,2) = interp2(X,Y,image(:,:,2),XI,YI,'spline');
A(:,:,3) = interp2(X,Y,image(:,:,3),XI,YI,'spline');

A = uint8(A);

i=0;
dimension = size(A);
pic_width=dimension(2);
pic_height=dimension(1);

depth = pic_width*pic_height;
sampled = A;

fid = fopen('display.mif', 'wt');
fprintf(fid, '-- MatLab generated Memory Initialization File (.mif)\n');
fprintf(fid, '\n');
fprintf(fid, 'WIDTH=%i;\n',bits*3);
fprintf(fid, 'DEPTH=%i;\n\n',depth);
fprintf(fid, 'ADDRESS_RADIX=UNS;\n');
fprintf(fid, 'DATA_RADIX=UNS;\n');
fprintf(fid, '\n');
fprintf(fid, 'CONTENT BEGIN\n');

for h=1:pic_height
    for w=1:pic_width
        
        %Calculate HEX values for MIF data
        R=dec2bin(A(h,w,1),8);
        G=dec2bin(A(h,w,2),8);
        B=dec2bin(A(h,w,3),8);
        MIF = bin2dec([ '0' B(1:bits) G(1:bits) R(1:bits) ]);
        sampled(h,w,1) = bin2dec( [ '0' R(1:bits) char(ones(1,8-bits)+48)]);
        sampled(h,w,2) = bin2dec( [ '0' G(1:bits) char(ones(1,8-bits)+48)]);
        sampled(h,w,3) = bin2dec( [ '0' B(1:bits) char(ones(1,8-bits)+48)]);
        fprintf(fid, '\t%i\t:\t%i;\n',i,MIF);
        i=i+1;
        
    end
end
fprintf(fid, 'END;\n');
fclose(fid);

%Plot Image and RGB Separations
figure
subplot(2,2,1)
imagesc(sampled)

subplot(2,2,2)
red = sampled;
red(:,:,2) = ones(size(red(:,:,2)));
red(:,:,3) = ones(size(red(:,:,3)));
imagesc(red)

subplot(2,2,3)
green = sampled;
green(:,:,1) = ones(size(green(:,:,1)));
green(:,:,3) = ones(size(green(:,:,3)));
imagesc(green)

subplot(2,2,4)
blue = sampled;
blue(:,:,1) = ones(size(blue(:,:,1)));
blue(:,:,2) = ones(size(blue(:,:,2)));
imagesc(blue)