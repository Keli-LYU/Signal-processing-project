function y = Vibrato(x, Fs, Fmod, D, Nfft, Nwind)
% y = Vibrato(x, Fs, Fmod, D, Nfft, Nwind)
% 
% Applique un effet de vibrato (modulation périodique du pitch)
% en utilisant le vocodeur de phase.
%
% x     : signal audio d'origine
% Fs    : Fréquence d'échantillonnage
% Fmod  : Fréquence de modulation (Hz) pour le vibrato (e.g., 5 Hz)
% D     : Profondeur de modulation (amplitude de l'indice de trame) (e.g., 0.01)
% Nfft  : Nombre de points pour la FFT (par défaut 1024)
% Nwind : Longueur de la fenêtre de pondération (par défaut Nfft)

% --- Paramètres par défaut et constantes ---
if nargin < 5
  Nfft = 1024;
end

if nargin < 6
  Nwind = Nfft;
end

% On choisit un recouvrement de 25% (comme dans PVoc.m)
Nov = Nfft/4; 
% Facteur d'échelle (pris à 1.0 comme dans PVoc.m)
scf = 1.0; 

% On s'assure que x est un vecteur ligne pour TFCT
if size(x, 1) > 1
    x = x';
end


% --- 1. CALCUL DE LA TFCT ---
X = scf * TFCT(x, Nfft, Nwind, Nov);


% --- 2. Calcul du vecteur d'interpolation (Vibrato) ---

% L'objectif est de ne pas changer le tempo, donc le rapport de vitesse (rapp) est implicitement 1.
[nl, nc] = size(X);
L_trame = Nov; % Temps en échantillons entre les trames (Hop)

% Index de temps des trames originales (en unité de "trame")
index_trame = 0:1:(nc-1);

% Fréquence de modulation convertie en cycles/trame
Fmod_trame = Fmod * L_trame / Fs;

% Calcul du décalage sinusoïdal de l'index de trame (la modulation)
% Cette modulation sinusoïdale de l'indice de temps crée le vibrato.
modulation = D * sin(2 * pi * Fmod_trame * index_trame);

% Le nouveau vecteur de temps interpolé (Nt) est le temps normal plus la modulation.
Nt = index_trame + modulation;

% Nettoyer les bords pour TFCT_Interp (la fonction s'attend à ne pas dépasser nc-2)
Nt(Nt > (nc-2)) = (nc-2);
Nt(Nt < 0) = 0; 


% --- 3. Interpolation des échantillons fréquentiels ---
X2 = TFCT_Interp(X, Nt, Nov);


% --- 4. CALCUL DE LA TFCT INVERSE ---
% Le résultat doit être un vecteur colonne
y = TFCTInv(X2, Nfft, Nwind, Nov)';

end