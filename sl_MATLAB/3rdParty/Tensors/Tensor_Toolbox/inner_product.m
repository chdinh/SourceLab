function R = inner_product(T1, T2, n)
% Computes the n - inner product of 2 tensors.
%
% |----------------------------------------------------------------
% | (C) 2006 TU Ilmenau, Communications Research Laboratory
% |
% |     Martin Weis
% |     
% |     Advisors:
% |        Dipl.-Ing. Giovanni Del Galdo
% |        Univ. Prof. Dr.-Ing. Martin Haardt
% |
% |     Last modifications: 07.28.2006
% |----------------------------------------------------------------
%
% R = inner_product(T1, T2, n)
%
% computes the inner product of the tensors T1 and T2 along 
% dimension n. Therefor T1 and T2 must be of same length anlong 
% this dimension. The resulting tensor will be of dimension 
% N + M - 2 if N and M are the dimensions of T1 and T2.
%
% Inputs: T1 - tensor 1
%         T2 - tensor 2
%         n  - dimension index
%          
% Output: R  - inner product of T1 and T2

% get tensor sizes
st1  = size(T1); 
st2  = size(T2); 

% ignore singletons
st1(st1==1) = [];
st2(st2==1) = [];

% get tensor dimensions
dim1 = length(st1); 
dim2 = length(st2);

% check dimension condition
if (n > dim1) | (n > dim2)
    disp(' ');
    disp('Error, orders of tensors do not fit!');
    disp(' ');
    return
end
if st1(n) ~= st2(n)
    disp(' ');
    disp(['Error, tensors must have same size along dimension ', int2str(n), '!']);
    disp(' ');
    return
end

% get last summation index
sum_end = st1(n);

% get dimensions of resulting tensor
st1(n) = [];
st2(n) = [];
R_size = [st1, st2];
if length(R_size) == 1
    R_size = [R_size, 1];
end

% get evaluation - string
eval_str = 'R = R + outer_product( { squeeze(T1(';

str1 = '';
for s = 1:(n-1)
    str1 = [str1, ':,'];
end

str1 = [str1, 's'];
str2 = str1;

for s = (n+1):dim1
    str1 = [str1, ',:'];
end

for s = (n+1):dim2
    str2 = [str2, ',:'];
end

eval_str = [eval_str, str1, ')), squeeze(T2(', str2, ')) } );'];

% build inner product
R = zeros(R_size);
for s =1:sum_end
    eval(eval_str);
end
