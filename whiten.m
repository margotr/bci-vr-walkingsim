function W = whiten(Sig)
% 1) do eigen decomposition of covariance matrix
[U, S, V] = svd(Sig);  % for symmetrical matrices equivalent to eigen decomp
                       % but it *automatically sorts eigenvalues*.
assert(min(diag(S)) > 1e-15, 'covariance matrix is singular');

% 2) take square root of inverse of eigenvalues to rescale stddev
S2 = diag(diag(S).^(-.5)); 

% 3) combine rotation U + scale S2:
W = S2 * U';
