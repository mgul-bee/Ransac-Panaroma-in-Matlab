function MSE = costHomography(h,pts1,pts2)
 
im2 = h*transpose(pts1);
im2 = im2./im2(3);
 
im1 = inv(h)*transpose(pts2);
im1 = im1./im1(3);
 
pts1 = transpose(pts1);
pts2 = transpose(pts2);
sum = zeros(3,4);
sum = ((pts1(1,:)-im1(1,:)).^2)+((pts1(2,:)-im1(2,:)).^2)+((pts2(1,:)-im2(1,:)).^2)+((pts2(2,:)-im2(2,:)).^2);
MSE = mean(sum);