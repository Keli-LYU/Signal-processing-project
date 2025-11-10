function x = TFCTInv(d, Nfft, Nwin, hop)

% D = TFCTInv(d,Nfft,w,hop)     
% Transformée de Fourier à court terme inverse(TFCT inverse)
%
% d : signal dont on veut calculer la TFCT inverse
% Nfft : nombre de points pour la FFT inverse
% win : nombre de points de la fenêtre de pondération
% hop : nombre de points de recouvrement des fenêtres
%
% x : résultat de la TFCT inverse 
% 
% Programme largement inspiré de celui de D. Marshall 


%Initialisation des paramètres
N = size(d);
cols = N(2);
xlen = Nfft + (cols-1)*hop;

%Initialisation du vecteur de sortie (la TFCT inverse)
x = zeros(1,xlen);

%création de la fenêtre de pondération
    if rem(Nwin, 2) == 0   
      Nwin = Nwin + 1;  %pour avoir un nombre impair d'échantillons
    end
    halflen = (Nwin-1)/2;
    halff = Nfft/2;   % point central de la fenêtre
    halfwin = 0.5 * ( 1 + cos( pi * (0:halflen)/halflen));
    win = zeros(1, Nfft);
    acthalflen = min(halff, halflen);
    win((halff+1):(halff+acthalflen)) = halfwin(1:acthalflen);
    win((halff+1):-1:(halff-acthalflen+2)) = halfwin(1:acthalflen);

%Calcul    
for b = 0:hop:(hop*(cols-1))
  ft = d(:,1+b/hop)';
  ft = [ft, conj(ft([((Nfft/2)):-1:2]))];
  px = real(ifft(ft));
  x((b+1):(b+Nfft)) = x((b+1):(b+Nfft))+px.*win;
end;