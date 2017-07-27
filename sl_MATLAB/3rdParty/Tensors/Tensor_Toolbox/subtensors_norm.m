function SD = subtensors_norm(T)
% Computes from a tensor the Frobenius norms of all subtensors.
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
% |     Last modifications: 06.20.2006
% |----------------------------------------------------------------
%
% SD = subtensors_norm(T)
%
% computes a cell array SD containing the frobenius norms of all possible 
% subtensors of T. If T is of dimension N, then SD will contain N vectors.
% The n'th vector gives the norms of the subtensors of T along the dimension n.
% If the elements of T are T(I1, I2, ..., IN) then a subtensors along 
% dimension n are build by keeping the In'th index of T fixed.
%
% Inputs: T - tensor
%         
% Output: SD - cell array with the norms of subtensors of T

% get dimesion
dimension = length(size(T));

% initialize output
SD = cell(1, dimension);

% compute Forbenius norms of subtensors
for n = 1:dimension
    SD{n} = subtensor_norm(T, n);
end
