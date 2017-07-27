function C = krp(A,B)

% KRP   Khathri-Rao (column-wise Kronecker) product of two matrices.
%
%   C = KRP(A,B) returns the Khathri-Rao product of A and B. The input
%   matrices A and B must have the same number of columns. 
%   For A of size M x P and B of size N x P, the resulting matrix will be
%   of size M*N x P.
%
% Author:
%    Florian Roemer, Communications Resarch Lab, TU Ilmenau
% Date:
%    Dec 2007

if size(A,2) ~= size(B,2)
    error('Khathri-Rao product requires two matrices with equal number of columns.');
end

C = zeros(size(A,1)*size(B,1),size(A,2));

for n = 1:size(A,2)
    C(:,n) = kron(A(:,n),B(:,n));
end