function y = PVoc(x, rapp, Nfft, Nwind)
% y = PVoc(x, rapp, Nfft , Nwind)
% Fonction du vocodeur de phase permettant de modifier un son audio 
% en interpolant dans le domaine fréquentiel en passant 
% par la TF à court terme.
%
% x: signal audio d'origine (on traite 1 seule voie à la fois --> x est un
% vecteur)
%
% rapp : est le rapport entre la vitesse d'origine et la vitesse d'arrivée
%
% Nfft : nombre de points (échantillons) sur lesquels on réalise la TF
% fenêtrée
%
% Nwind : longueur, en nombre d'échantillons, de la fenêtre de pondération lors de la TFCT



% Valeurs par défaut dans le cas où les paramètres d'entrée ne sont pas tous donnés
%----------------------------------------------------------------------------------
if nargin < 3
  Nfft = 1024;
end

if nargin < 4
  Nwind = Nfft;
end

% Paramètres utiles pour la TFCT
%--------------------------------
% On choisit une fenêtre de pondération de Hanning
% Afin d'avoir une bonne reconstruction avec une fenêtre de Hanning (signaux lissés), 
% nous prenons un recouvrement de 25% de la fenêtre 
Nov = Nfft/4;
% Facteur d'échelle 
%Remarque : pour retrouver la bonne amplitude lorsqu'on fait une 
% TFCT directe + une TFCT inverse, on le prend égal à 2/3... 
% nous ne détaillerons pas ici la démonstration. 
% Dans notre application, on peut le prendre = 1 
scf = 1.0;

% 1- CALCUL DE LA TFCT
%-----------------------
X = scf * TFCT(x', Nfft, Nwind, Nov);

% 2- Interpolation des échantillons fréquentiels
%------------------------------------------------
% Calcul de la nouvelle base de temps (en terme d'échantillons)
% cela correspond au nouveau nombre de trames (fenêtres temporelles)
[nl, nc] = size(X);
Nt = [0:rapp:(nc-2)];
% Remarque :
% on prend Ntmax à (nc-2) au lieu de (nc-1) car lors de l'interpolation,
% on travaille avec les colonnes n et n+1, n appartenent à Nt.

% Calcul de la nouvelle TFCT
X2 = TFCT_Interp(X, Nt, Nov);
% Remarque : vous devrez créer cette fonction "TFCT_Interp" !


% 3- CALCUL DE LA TFCT INVERSE
%------------------------------
y = TFCTInv(X2, Nfft, Nwind, Nov)';