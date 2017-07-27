function T = outer_product(tensor_cell)
% Computes the outer product of some tensors.
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
% T = outer_product(tensor_cell)
%
% computes the outer product of all tensors in tensor_cell.
% if tensor_cell contains N vectors the result will be a tensor 
% of dimension N containing all possible products of the 
% vectorelements. For tensors this works in an analogical way.
%
% Inputs: tensor_cell - cell array with tensors
%          
% Output: T           - outer product of given tensors

% get number of input tensors
input_num = length(tensor_cell);

% init loop
T = tensor_cell{1};

for n = 2:input_num
    
    %get tensor - pairs
    T_next = tensor_cell{n};
    
    % get tensor sizes
    st1  = size(T); 
    st2  = size(T_next);
    
    % transpose vectors to column vectors, if necessary
    if (length(st1) == 2) & (st1(1) == 1)
        T = T.';
    end
    
    if (length(st2) == 2) & (st1(1) == 1)
        T_next = T_next.';
    end
    
    % ignore singletons
    st1(st1==1) = [];
    st2(st2==1) = [];
    
    % get tensor dimensions
    dim1 = length(st1); 
    dim2 = length(st2);
    
    % only scalar product?
    if dim1 == 0
        T = T .* T_next;
        continue
    end
    
    if dim2 == 0
        T = T_next .* T;
        continue
    end
    
    % replicate tensors
    temp1 = repmat(T, [ones(1, dim1), st2]);
    temp2 = repmat(T_next, [ones(1, dim2), st1]);
    
    % get permute - vector for tensor 2
    permute_vec = 1:(dim2+dim1);
    permute_vec = [permute_vec, permute_vec(1:dim2)];
    permute_vec(1:dim2) = [];
    
    % reorder tensor 2
    temp2 = permute(temp2, permute_vec);
     
    % build outer product
    T = temp1 .* temp2;

end
