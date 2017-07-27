function out = unfoldings(T, order)
% Computes all Unfoldings of a Tensor.
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
% |     Last modifications: 04.23.2007
% |----------------------------------------------------------------
%
% out = unfoldings(T)
%
% computes all unfoldings of the given tensor T.
% Thereby out will be a cell array containing N matrices
% if the tensor T was of dimensionality N. The n'th matrix
% of the cell array out will contain the n - mode 
% vectors of T, with an ordering as defined by de Lathauwer.
%
% out = unfoldings(T, order)
%
% computes the all matrices of n - mode vectors with the following order:
%
%   order = 1: indices of n - mode vectors go faster with increasing index
%   order = 2: indices of n - mode vectors go slower with increasing index
%   order = 3: de Lathauwer: indices go slower with I_n+1, ... I_N, I_1, ... I_n-1
%   order = 4: flipped de Lathauwer ordering
%
% Inputs: T - tensor
%         order - defines the ordering of the n - mode vectors (optional)
%                  
% Output: out - matrix unfouldings of T

% get dimensions
sizes = size(T);
dimension = length(sizes);

% Set standard Lathauwer unfolding
if nargin == 1
    order = 3;
end

% initialize out
out = cell(1, dimension);

% compute all unfoldings
for n = 1:dimension
       
    % permute tensor T for reshape - command
    switch order
        case 1
            P = permute(T, [n, 1:(n-1), (n+1):dimension]); % indices go faster with increasing index
        case 2
            P = permute(T, [n, fliplr( [1:(n-1), (n+1):dimension] )] ); % indices go slower with increasing index
        case 3
            P = permute(T, [n, fliplr( 1:(n-1) ), fliplr( (n+1):dimension )]); % Lathauwer: indices go slower with I_n+1, ... I_N, I_1, ... I_n-1
        case 4
            P = permute(T, [n, fliplr( [ fliplr( 1:(n-1) ), fliplr( (n+1):dimension ) ])]); % flipped Lathauwer
        otherwise
            disp('Error: unknown ordering for n--mode vectors');
            return
    end

    % compute n'th unfolding
    out{n} = reshape(P, [sizes(n), prod(sizes)./sizes(n)]);
    
end
