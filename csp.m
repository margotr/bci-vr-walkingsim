function W = csp(Sig_A, Sig_B, m)
% 1) Get whitening transform B for average distribution. 
% See whiten.m. 
% Verify that B (\Sigma_a + \Sigma_b)/2 B^T = I
Sig = (Sig_A+Sig_B)/2;
B = whiten(Sig); % TODO
assert(norm(B * Sig * B' - eye(size(Sig_A))) < 1e-10, ...
  'B does not whiten correctly');

% 2) Get sorted eigenvectors U for whitened covariance of class A.
% Use \Sigma_{BA} = B \Sigma_A B^T, and lookup HELP SVD.
% Verify that U U^T = I
S_BA = B*Sig_A*B';
[U,~,~] = svd(S_BA); % TODO
assert(norm(U * U' - eye(size(U))) < 1e-10, ...
  'S_BA is not decomposed correctly');

% 3) Construct final CSP transform W by combining B with rotation U^T
% Verify that W (\Sigma_a + \Sigma_b)/2 W^T = I
% Verify that W \Sigma_a W^T = D where D is a diagonal matrix
W = U'*B; % TODO
assert(norm(W * Sig * W' - eye(size(Sig_A))) < 1e-10, ...
  'W does not whiten correctly');
assert(norm(W * Sig_A * W' - diag(diag(W * Sig_A * W'))) < 1e-10, ...
  'W is not eigenvector');

% 4) Select m discriminative components
subset = circshift((1:size(Sig_A, 1)) <= m, [0, -round(m/2)]);
W = W(subset,:);
