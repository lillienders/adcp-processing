%% principal_axis: determine principal axis from directional scatter

function [PA, varxp_PA] = principal_axis(u,v)

U = [u, v];                             %create velocity matrix
U = U(~isnan(U(:,1)),:);                %eliminate NaN values
U = U - repmat(mean(U,1),length(U),1);  %convert matrix to deviate form
R = U'*U/(length(U)-1);                 %compute covariance matrix (alternatively - cov(U))
[V,lambda]=eig(R);                      %calculate eigenvalues and eigenvectors for covariance matrix

%sort eignvalues in descending order so that major axis is given by first eigenvector
[lambda, ilambda]=sort(diag(lambda),'descend');     %sort in descending order with indices
lambda=diag(lambda);                                %reconstruct the eigenvalue matrix
V=V(:,ilambda);                                     %reorder the eigenvectors

ra = atan2(V(2,1),V(2,2));   %rotation angle of major axis in radians relative to cartesian coordiantes

PA = -ra*180/pi+90;                         %express principal axis in compass coordinates
varxp_PA = diag(lambda(1))/trace(lambda);   %variance captured by principal axis

end