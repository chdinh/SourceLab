function []=resgram(f,varargin)
%RESGRAM  Reassigned spectrogram plot
%   Usage: resgram(f,op1,op2, ... );
%          resgram(f,fs,op1,op2, ... );
%
%   RESGRAM(f) plots a reassigned spectrogram of f.
%
%   RESGRAM(f,fs) does the same for a signal with sampling rate fs (sampled
%   with fs samples per second);
%
%   Because reassigned spectrograms can have an extreme dynamical range,
%   consider using the 'dynrange' or 'clim' options (see below) in
%   conjunction with the 'db' option (on by default). An example:
%
%     resgram(greasy,16000,'dynrange',40);
%
%   This will produce a reassigned spectrogram of the 'greasy' signal
%   without drowning the interesting features in noise.
%
%   Additional arguments can be supplied like this:
%   RESGRAM(f,'nf','tfr',2,'log'). The arguments must be character
%   strings possibly followed by an argument:
%
%   'tfr',v   - Set the ratio of frequency resolution to time resolution.
%               A value v=1 is the default. Setting v>1 will give better
%               frequency resolution at the expense of a worse time
%               resolution. A value of 0<v<1 will do the opposite.
%
%   'thr',r   - Keep only the largest fraction r of the coefficients, and
%               set the rest to zero.
%
%   'sharp',alpha - Set the sharpness of the plot. If alpha=0 the regular
%               spectrogram is obtained. alpha=1 means full
%               reassignment. Anything in between will produce a partially
%               sharpened picture. Default is alpha=1
%
%   'nf'      - Display negative frequencies, with the zero-frequency
%               centered in the middle. For real signals, this will just
%               mirror the upper half plane. This is standard for complex
%               signals.
%
%   'tc'      - Time centering. Move the beginning of the signal to the
%               middle of the plot. This is useful for visualizing the
%               window functions of the toolbox.
%
%   'db'      - Apply 20*log10 to the coefficients. This makes it possible to
%               see very weak phenomena, but it might show to much noise. A
%               logarithmic scale is more adapted to perception of sound.
%
%   'lin'     - Show the energy of the coefficients on a linear scale.
%
%   'image'   - Use 'imagesc' to display the spectrogram. This is the
%               default.
%
%   'clim',[clow,chigh] - Use a colormap ranging from clow to chigh. These
%               values are passed to IMAGESC. See the help on IMAGESC.
%
%   'dynrange',range - Use a colormap in the interval [chigh-range,chigh], where
%               chigh is the highest value in the plot.
%
%   'fmax',y  - Display y as the highest frequency.
%
%   'xres',xres - Approximate number of pixels along x-axis /time.
%               Default value is 800
%
%   'yres',yres - Approximate number of pixels along y-axis / frequency
%               Default value is 600
%
%   'contour' - Do a contour plot to display the spectrogram.
%          
%   'surf'    - Do a surf plot to display the spectrogram.
%
%   'mesh'    - Do a mesh plot to display the spectrogram.
%
%   'colorbar' - Display the colorbar. This is the default.
%
%   'nocolorbar' - Do not display the colorbar.
%
%   In Octave, the default colormap is greyscale. Change it to colormap(jet)
%   for something prettier.

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

%   AUTHOR : Peter Soendergaard.
%   TESTING: NA
%   REFERENCE: NA

% BUG: Setting the sharpness different from 1 produces a black line in the
% middle of the plot.
  
if nargin<1
  error('Too few input arguments.');
end;

if sum(size(f)>1)>1
  error('Input must be a vector.');
end;




% Define initial value for flags and key/value pairs.
definput.flags.wlen={'nowlen','wlen'};
definput.flags.thr={'nothr','thr'};
definput.flags.tc={'notc','tc'};
definput.flags.plottype={'image','contour','mesh','pcolor'};

definput.flags.clim={'noclim','clim'};
definput.flags.fmax={'nofmax','fmax'};
definput.flags.log={'db','lin'};
definput.flags.dynrange={'nodynrange','dynrange'};
definput.flags.colorbar={'colorbar','nocolorbar'};

if isreal(f)
  definput.flags.posfreq={'posfreq','nf'};
else
  definput.flags.posfreq={'nf','posfreq'};
end;

definput.keyvals.fs=[];
definput.keyvals.sharp=1;
definput.keyvals.tfr=1;
definput.keyvals.wlen=0;
definput.keyvals.thr=0;
definput.keyvals.clim=[0,1];
definput.keyvals.climsym=1;
definput.keyvals.fmax=0;
definput.keyvals.dynrange=100;
definput.keyvals.xres=800;
definput.keyvals.yres=600;

[flags,keyvals,fs]=ltfatarghelper({'fs'},definput,varargin);

if (keyvals.sharp<0 || keyvals.sharp >1)
  error(['RESGRAM: Sharpness parameter must be between (including) ' ...
	 '0 and 1']);
end;

% Downsample
resamp=1;
if flags.do_fmax
  if dofs
    resamp=fmax*2/fs;
  else
    resamp=fmax*2/length(f);
  end;

  f=fftresample(f,round(length(f)*resamp));
end;

Ls=length(f);

if flags.do_posfreq
   keyvals.yres=2*keyvals.yres;
end;

[a,M,L,N,Ndisp]=gabimagepars(Ls,keyvals.xres,keyvals.yres);

% Set an explicit window length, if this was specified.
if flags.do_wlen
  keyvals.tfr=keyvals.wlen^2/L;
end;

g={'gauss',keyvals.tfr};

[tgrad,fgrad,c]=gabphasegrad('dgt',f,g,a,M);          
coef=gabreassign(abs(c).^2,keyvals.sharp*tgrad,keyvals.sharp*fgrad,a);

if flags.do_posfreq
  coef=coef(1:floor(M/2)+1,:);
end;

% Cut away zero-extension.
coef=coef(:,1:Ndisp);

if flags.do_thr
  % keep only the largest coefficients.
  coef=largestr(coef,keyvals.thr);
end

tfplot(coef,a,M,L,resamp,keyvals,flags);

if nargout>0
  varargout={coef};
end;

