%DEMO_AUDIOCOMPRESSION  Audio compression using N-term approx.
% 
%   This demos shows how to do audio compression using best N-term
%   approximation of WMDCT transform.
% 
%   The signal is transformed using an orthonormal WMDCT transform.
%   Then approximations with fixed number N of coefficients are obtained
%   by:
% 
%     Linear approximation     - N coefficients with lowest frequency index
% 
%     Non-linear approximation - N largest coefficients (in magnitude)
% 
%   The corresponding approximated signal is computed with inverse WMDCT.
% 
%   FIGURE 1 Rate-distortion
% 
%     The figure shows the output Signal to Noise Ratio (SNR) as a function of
%     the number of retained coefficients.
%     Nota: actually, inverse WMDCT is not used, as Parseval theorem states
%     that the norm of a signal equals the norm of the sequence of its wmdct
%     coefficients. The latter is used for computing SNRs.
% 

% Copyright (C) 2005-2011 Peter L. Soendergaard.
% This file is part of LTFAT version 0.98
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Load audio signal
% Use the 'glockenspiel' signal.
sig=gspi;

% Shorten signal
SigLength = 2^16;
sig = sig(1:SigLength);

% Initializations
NbFreqBands = 1024;
NbTimeSteps = SigLength/NbFreqBands;

% Generate window
gamma = wilorth(NbFreqBands,SigLength);

% Compute wmdct coefficients
c = wmdct(sig,gamma,NbFreqBands);


% L2 norm of signal
InputL2Norm = norm(c,'fro');

% Approximate, and compute SNR values
kmax = NbFreqBands;
kmin = kmax/32;             % 32 is an arbitrary choice
krange = kmin:32:(kmax-1);  % same remark

for k = krange,
    ResL2Norm_NL = norm(c-largestn(c,k*NbTimeSteps),'fro');
    SNR_NL(k) = 20*log10(InputL2Norm/ResL2Norm_NL);
    ResL2Norm_L = norm(c(k:kmax,:),'fro');
    SNR_L(k) = 20*log10(InputL2Norm/ResL2Norm_L);
end


% Plot
figure(1);

if isoctave
  plot(krange*NbTimeSteps,SNR_NL(krange),'x-b');
  hold on;
  plot(krange*NbTimeSteps,SNR_L(krange),'o-r');
  axis tight; grid;
  hold off;
  xlabel('Number of Samples');
  ylabel('SNR (dB)');
  
else

  set(gca,'fontsize',14);
  plot(krange*NbTimeSteps,SNR_NL(krange),'x-b',...
       krange*NbTimeSteps,SNR_L(krange),'o-r');
  axis tight; grid;
  legend('Best N-term','Linear');
  xlabel('Number of Samples', 'fontsize',14);
  ylabel('SNR (dB)','fontsize',14);
end;




