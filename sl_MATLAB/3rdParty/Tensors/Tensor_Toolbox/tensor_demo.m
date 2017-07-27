% Tensor toolbox demonstration (script).
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
% |     Last modifications: 06.26.2006
% |----------------------------------------------------------------
%

clc

disp('**************************************************');
disp('*               Tensor - Toolbox                 *');
disp('**************************************************');

disp(' ');
disp('Hello everybody...');
disp('Lets get a tensor for testing the functions of this toolbox:');

pause

disp(' ');
disp('_________________________________________________________________________________________')
disp('testtensor');
testtensor %T = rand(3, 3, 3) + j*rand(3, 3, 3);

pause

disp(' ');
disp('_________________________________________________________________________________________')
disp('Ok, our tensor T is 3 dimensional and of size:'); disp(' ');
disp('size(T)');
size(T)

pause

disp('_________________________________________________________________________________________')
disp('All right: Lets compute the higher order SVD of this tensor:'); disp(' ');
disp('[S, U_Cell, SD_Cell] = hosvd(T);');
[S, U_Cell, SD_Cell] = hosvd(T);

pause

disp(' ');
disp('_________________________________________________________________________________________')
disp('Note that the core tensor S has the same size as T'); disp(' ');
disp('size(S)');
size(S)

pause

disp(' ');
disp('_________________________________________________________________________________________')
disp('For every dimension in T we get one matrix in the cell array U_Cell.');
disp('These matrices are orthogonal, i. e. for the first vectors of U_Cell{1} this means:'); disp(' ');

pause

disp('_________________________________________________________________________________________')
disp('U_Cell{1}(:, 1)'' * U_Cell{1}(:, 2)'); disp(' ');
U_Cell{1}(:, 1)' * U_Cell{1}(:, 2)

pause

disp('_________________________________________________________________________________________')
disp(' ');
disp('Also we get a vector of singular values for every dimension in T.');
disp('These vectors can be found in the cell array SD_Cell.');
disp('Please note that the values in the vectors are sorted.');
disp(' ');
disp('SD_Cell{1}');
SD_Cell{1}'
disp('SD_Cell{2}');
SD_Cell{2}'
disp('SD_Cell{3}');
SD_Cell{3}'

pause

disp(' ');
disp('_________________________________________________________________________________________')
disp('The original tensor T is now decomposed into the form');
disp('T = S x1 U_Cell{1} x2 U_Cell{2} x3 U_Cell{3};');
disp(' ');
disp('Lets check this by using the function nmode_product:'); disp(' ');
disp('T2 = nmode_product(S, U_Cell{1}, 1);');
disp('T2 = nmode_product(T2, U_Cell{2}, 2);');
disp('T2 = nmode_product(T2, U_Cell{3}, 3);');
T2 = nmode_product(S, U_Cell{1}, 1);
T2 = nmode_product(T2, U_Cell{2}, 2);
T2 = nmode_product(T2, U_Cell{3}, 3);

pause

disp('_________________________________________________________________________________________')
disp('Now T and T2 should be the same. Lets check this by computing the Frobenius norm of their difference:');
disp(' ');
disp('ho_norm(T-T2)');
ho_norm(T-T2)

pause

disp('_________________________________________________________________________________________')
disp('Ok, this seems to be right (it is close to zero).');disp(' ');
disp('The calculation of T2 could be done faster by using the function reconstruct:');
disp(' ');
disp('T2 = reconstruct(S, U_Cell);')
disp('ho_norm(T-T2)');
T2 = reconstruct(S, U_Cell);
ho_norm(T-T2)

pause

disp('_________________________________________________________________________________________')
disp('Also you can use the Tucker decomposition, wich represents the original tensor T as a sum');
disp('of all possible outer products of the vectors in U_Cell. To do this we can use the');
disp('function outer_product.'); disp(' ');
disp('[I1, I2, I3] = size(T);');
disp('T_Tucker = zeros(I1, I2, I3);');
disp('for i1 = 1:I1');
disp('    for i2 = 1:I2');
disp('        for i3 = 1:I3');
disp('            T_Tucker = T_Tucker + S(i1, i2, i3) .* outer_product( { U_Cell{1}(:, i1), U_Cell{2}(:, i2), U_Cell{3}(:, i3) } );');
disp('        end');
disp('    end');
disp('end');

[I1, I2, I3] = size(T);
T_Tucker = zeros(I1, I2, I3);
for i1 = 1:I1
    for i2 = 1:I2
        for i3 = 1:I3
            T_Tucker = T_Tucker + S(i1, i2, i3) .* outer_product( { U_Cell{1}(:, i1), U_Cell{2}(:, i2), U_Cell{3}(:, i3) } );
        end
    end
end

pause

disp(' ');
disp('_________________________________________________________________________________________')
disp('Of course this implementation is moore computationally expensive (especially in Matlab)');
disp('but as you can see, now T_Tucker and T are equal:');
disp(' ');
disp('ho_norm(T-T_Tucker)');
ho_norm(T-T_Tucker)

pause

disp('_________________________________________________________________________________________')
disp('Lets have a look again at the singular values along the first dimension of T:');
disp(' ');
disp('SD_Cell{1}');
SD_Cell{1}'

pause

disp('_________________________________________________________________________________________')
disp('It seems that the tensor T is only of rank 2 along its first dimension');
disp('because of the very small last singular value');
disp('Lets check this assumption by using the function nranks:')
disp(' ');
disp('nranks(T, 10e-3)');
nranks(T, 10e-3)

pause

disp('_________________________________________________________________________________________')
disp('For higher order SVDs the singular values equal the norms of the');
disp('subtensors of S. They can be computed by using the function subtensors_norm');
disp(' ');
disp('SD_Cell_2 = subtensors_norm(S);');
SD_Cell_2 = subtensors_norm(S);
disp(' ');
disp('Lets show them:');
disp(' ');
disp('SD_Cell_2{1}');
SD_Cell_2{1}
disp('SD_Cell_2{2}');
SD_Cell_2{2}
disp('SD_Cell_2{3}');
SD_Cell_2{3}

pause

disp('_________________________________________________________________________________________')
disp('For comparison, here again the singular values:');
disp(' ');
disp('SD_Cell{1}');
SD_Cell{1}'
disp('SD_Cell{2}');
SD_Cell{2}'
disp('SD_Cell{3}');
SD_Cell{3}'

pause


disp('_________________________________________________________________________________________')
disp('Last, we can get an nrank = [2 2 2] approximation of T by using the function fast_dimred:');
disp(' ');
disp('[T_red, error] = fast_dimred(T, [2 2 2])');
[T_red, error] = fast_dimred(T, [2 2 2])

pause

disp('_________________________________________________________________________________________')
disp('Please note that T_red is not an optimum nrank = [2 2 2] approximation of T in a least');
disp('mean squares sence, but it is a good approximation if the distance between');
disp('the dominant singular values and the smaller ones is large enough.');
disp(' ');
disp('That the nrank of T_red is truely [2 2 2] we can check again by using nranks:');
disp(' ');
disp('nranks(T_red)');
nranks(T_red)

disp('_________________________________________________________________________________________')
disp('To get the optimum reduced rank - [2 2 2] tensor, you can use the function opt_dimred:');
disp(' ');
disp('[U_Cell, T_red, error] = opt_dimred(T, [2 2 2])');
[U_Cell, T_red, error] = opt_dimred(T, [2 2 2])

pause

disp('_________________________________________________________________________________________')
disp('Addition help for the functions in this little toolbox u can get by typing:');
disp('help "FUNCTION-NAME" in the Matlab Command window');
disp(' ');
disp('Thank u and good by');
