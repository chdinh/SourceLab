function savevar(filename, varname, value)

% SAVEVAR is a helper function for cfg.outputfile

% Copyright (C) 2010, Robert Oostenveld
%
% $Id: savevar.m 4516 2011-10-19 09:25:55Z roboos $

fprintf('writing ''%s'' to file ''%s''\n', varname, filename);

eval(sprintf('%s = value;', varname));

s = whos(varname);

% if variable < ~500 MB, store it in old (uncompressed) format, which is
% faster
if (s.bytes < 500000000)
  save(filename, varname, '-v6');
else
  save(filename, varname, '-v7.3');
end
