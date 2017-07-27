function mycircle(cx, cy, r)

N = 361;
Phi = linspace(0, 2.*pi, N);
plot(r.*cos(Phi)+cx, r.*sin(Phi)+cy);
