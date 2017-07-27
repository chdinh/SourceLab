% tensor toolbox functions
%
% |----------------------------------------------------------------
% | (C) 2006 TU Ilmenau, Communications Research Laboratory
% |
% |     Martin Weis, Florian Römer
% |     
% |     Advisors:
% |        Dipl.-Ing. Giovanni Del Galdo
% |        Univ. Prof. Dr.-Ing. Martin Haardt
% |
% |     Last modifications: 04.24.2006
% |----------------------------------------------------------------
%
% core_tensor        - Calculates the core tensor.
% fast_dimred	     - Computes a fast (suboptimal) lower n - rank approximation of a tensor.
% ho_norm	         - Computes the Frobenius norm of a tensor.
% hosvd	             - Computes the higher order singular value decomposition of a tensor.
% inner_product      - Computes the n - inner product of 2 tensors.
% iunfolding	     - Reconstructs a tensor out of it's n'th unfolding.
% nmode_product	     - Computes the n - mode Product of a Tensor and a Matrix.
% nrank	             - Computes the n - rank of a tensor.
% nranks	         - Computes all n - ranks of a tensor.
% opt_dimred         - Computes the best rank - (R1, R2, ..., RN) approximation of a tensor.
% outer_product	     - Computes the outer product of some tensors.
% reconstruct	     - Reconstructs a Tensor out of it's higher order singular value decomposition.
% scalar_product     - Computes the scalar product of 2 tensors.
% subtensor_norm     - Computes from a tensor the Frobenius norms of all subtensors along dimension n.
% subtensors_norm    - Computes from a tensor the Frobenius norms of all subtensors.
% tensor_demo	     - Tensor toolbox demonstration (script).
% testtensor	     - Creates a real valued test tensor (script).
% unfolding	         - Computes the n'th Unfolding of a Tensor.
% unfoldings	     - Computes all Unfoldings of a Tensor.
% hermitianunfold    - Compute "Hermitian unfolding" of a Hermitian tensor.
% hermitianinvunfold - Compute inverse "Hermitian unfolding" of Hermitian matrix