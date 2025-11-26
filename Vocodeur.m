%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VOCODEUR : Programme principal réalisant un vocodeur de phase 
% et permettant de :
%
% 1- modifier le tempo (la vitesse de "prononciation")
%   sans modifier le pitch (fréquence fondamentale de la parole)
%
% 2- modifier le pitch 
%   sans modifier la vitesse 
%
% 3- "robotiser" une voix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Récupération d'un signal audio
%--------------------------------

% [y,Fs]=audioread('Diner.wav');   %signal d'origine
% [y,Fs]=audioread('Extrait.wav');   %signal d'origine
% [y,Fs]=audioread('Halleluia.wav');   %signal d'origine
[y,Fs]=audioread('Violon.wav');   %signal d'origine

% Remarque : si le signal est en stéréo, ne traiter qu'une seule voie à la
% fois
y = y(:,1);

%% Courbes
%--------
N = length(y);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(1)
subplot(311),plot(t,y)
title('Signal original')
subplot(312),plot(f,abs(fftshift(fft(y))))
subplot(313),spectrogram(y,128,120,128,Fs,'yaxis')


%% Ecoute
%-------
disp('------------------------------------')
disp('SON ORIGINAL')
soundsc(y,Fs);

%-------------------------------
%% 1- MODIFICATION DE LA VITESSE
% (sans modification du pitch)
%-------------------------------
% PLUS LENT
rapp = 2/3;
ylent = PVoc(y,rapp,1024); 

% % % Ecoute
% % %-------
% disp('------------------------------------')
pause
disp('1- MODIFICATION DE LA VITESSE SANS MODIFIER LE PITCH')
% 
disp('Son en diminuant la vitesse sans modifier le pitch')
soundsc(ylent,Fs);

% Observation
%-------------
N = length(ylent);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(2)
subplot(311),plot(t,ylent)
title('Signal "plus lent"')
subplot(312),plot(f,abs(fftshift(fft(ylent))))
subplot(313),spectrogram(ylent,128,120,128,Fs,'yaxis')

% 
% % PLUS RAPIDE
rapp = 3/2;
yrapide = PVoc(y,rapp,1024); 


% Ecoute 
% %-------
pause
disp('Son en augmentant la vitesse sans modifier le pitch')
soundsc(yrapide,Fs);

% Observation
%-------------
N = length(yrapide);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(3)
subplot(311),plot(t,yrapide)
title('Signal "plus rapide"')
subplot(312),plot(f,abs(fftshift(fft(yrapide))))
subplot(313),spectrogram(yrapide,128,120,128,Fs,'yaxis')

%% 1.1 Tracé de comparaison du Tempo (Signaux + Spectres)
%------------------------------------

figure(4); 
% 1. Calculer les vecteurs temps pour chaque signal
t_orig = (0:length(y)-1) / Fs;
t_lent = (0:length(ylent)-1) / Fs;
t_rapide = (0:length(yrapide)-1) / Fs;

% 2. Normaliser l'amplitude pour une meilleure comparaison
y_norm = y / max(abs(y));
ylent_norm = ylent / max(abs(ylent));
yrapide_norm = yrapide / max(abs(yrapide));

% Observation
plot(t_orig, y_norm, 'b'); 
hold on; 
plot(t_lent, ylent_norm, 'r'); 
plot(t_rapide, yrapide_norm, 'g'); 

% 6. Ajouter les légendes et titres
title('Comparaison de la forme d''onde : Time Stretching');
xlabel('Temps (s)');
ylabel('Amplitude normalisée');
legend('Original', 'Plus Lent (rapp = 2/3)', 'Plus Rapide (rapp = 3/2)', 'Location', 'best');
grid on;
hold off;

figure(5); 
% Signal Original (y) 
N_orig = length(y);
f_orig = [0:N_orig-1]*Fs/N_orig; 
f_orig = f_orig - Fs/2; 
S_orig = abs(fftshift(fft(y)));
S_orig_norm = S_orig / max(S_orig);
plot(f_orig, S_orig_norm, 'b'); 
hold on; 

%Signal Plus Lent (ylent)
N_lent = length(ylent);
f_lent = [0:N_lent-1]*Fs/N_lent; 
f_lent = f_lent - Fs/2; 
S_lent = abs(fftshift(fft(ylent)));
S_lent_norm = S_lent / max(S_lent);

plot(f_lent, S_lent_norm, 'r'); 

% Signal Plus Rapide (yrapide) 
N_rapide = length(yrapide);
f_rapide = [0:N_rapide-1]*Fs/N_rapide; 
f_rapide = f_rapide - Fs/2; 
S_rapide = abs(fftshift(fft(yrapide)));
S_rapide_norm = S_rapide / max(S_rapide);

plot(f_rapide, S_rapide_norm, 'g'); 

% Graphique 
title('Comparaison des Spectres : Time Stretching');
xlabel('Fréquence (Hz)');
ylabel('Magnitude normalisée');
legend('Original', 'Plus Lent (Tempo 2/3)', 'Plus Rapide (Tempo 3/2)', 'Location', 'best');
grid on;
xlim([-Fs/2, Fs/2]);
hold off;

%----------------------------------
%% 2- MODIFICATION DU PITCH
% (sans modification de vitesse)
%----------------------------------
% Paramètres généraux:
%---------------------
% Nombre de points pour la FFT/IFFT
Nfft = 256;

% Nombre de points (longueur) de la fenêtre de pondération 
% (par défaut fenêtre de Hanning)
Nwind = Nfft;

% 2.1- Augmentation 
%-------------------
a = 2;
b = 3;
yvoc = PVoc(y, a/b,Nfft,Nwind);

% Ré-échantillonnage du signal temporel afin de garder la même vitesse
ypitch1 = resample(yvoc,a,b);

%Somme de l'original et du signal modifié
%Attention : on doit prendre le même nombre d'échantillons
%Remarque : vous pouvez mettre un coefficient à ypitch pour qu'il
%intervienne + ou - dans la somme...
lmin = min(length(y),length(ypitch1));
ysomme = y(1:lmin)/max(abs(y(1:lmin))) + ypitch1(1:lmin)/max(abs(ypitch1(1:lmin)));

% % Ecoute
% %-------
% disp('------------------------------------')
pause
disp('2- MODIFICATION DU PITCH SANS MODIFIER LA VITESSE')
%  
disp('Son en augmentant le pitch sans modification de vitesse')
soundsc(ypitch1, Fs);
pause
disp('Somme du son original et du précédent')
soundsc(ysomme, Fs);

% Observation
%-------------
N = length(ypitch1);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(6)
subplot(311),plot(t,ypitch1)
title('Signal avec "pitch" augmenté')
subplot(312),plot(f,abs(fftshift(fft(ypitch1))))
subplot(313),spectrogram(ypitch1,128,120,128,Fs,'yaxis')
%% 2.2- Diminution 
%-----------------

a = 3;
b = 2;
yvoc = PVoc(y, a/b,Nfft,Nwind); 

% Ré-échantillonnage du signal temporel afin de garder la même vitesse
ypitch2 = resample(yvoc,a,b);  

%Somme de l'original et du signal modifié
%Attention : on doit prendre le même nombre d'échantillons
%Remarque : vous pouvez mettre un coefficient à ypitch pour qu'il
%intervienne + ou - dans la somme...
lmin = min(length(y),length(ypitch2));
ysomme = y(1:lmin)/max(abs(y(1:lmin))) + ypitch2(1:lmin)/max(abs(ypitch2(1:lmin)));

% Ecoute
%-------
 pause
 disp('Son en diminuant le pitch sans modification de vitesse')
 soundsc(ypitch2, Fs);
 pause
 disp('Somme du son original et du précédent')
 soundsc(ysomme, Fs);

% Observation
%-------------
N = length(ypitch2);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(7)
subplot(311),plot(t,ypitch2)
title('Signal avec "pitch" diminué')
subplot(312),plot(f,abs(fftshift(fft(ypitch2))))
subplot(313),spectrogram(ypitch2,128,120,128,Fs,'yaxis')


%% 2.3 Tracé de comparaison du Pitch (Signaux + Spectres)
%------------------------------------
figure(8);

% 1. Trouver la longueur minimale des trois signaux
L_min = min([length(y), length(ypitch1), length(ypitch2)]);

% 2. Normaliser les trois signaux
y_orig_trunc = y(1:L_min) / max(abs(y(1:L_min)));
y_pitch1_trunc = ypitch1(1:L_min) / max(abs(ypitch1(1:L_min)));
y_pitch2_trunc = ypitch2(1:L_min) / max(abs(ypitch2(1:L_min)));
t_comp = (0:L_min-1) / Fs;

% Observation
plot(t_comp, y_orig_trunc, 'b'); 
hold on; 
plot(t_comp, y_pitch1_trunc, 'r'); 
plot(t_comp, y_pitch2_trunc, 'g'); 

title('Comparaison de la forme d''onde : Pitch Shifting');
xlabel('Temps (s)');
ylabel('Amplitude normalisée');
legend('Original', 'Pitch Augmenté (x3/2)', 'Pitch Diminué (x2/3)', 'Location', 'best');
grid on;
hold off;

figure(9);
N = L_min; % Nombre d'échantillons
f_comp = [0:N-1]*Fs/N; 
f_comp = f_comp - Fs/2; % Centrer le spectre autour de 0 Hz

% 2. Calcul et Normalisation des spectres
S_orig = abs(fftshift(fft(y(1:L_min))));
S_pitch1 = abs(fftshift(fft(ypitch1(1:L_min))));
S_pitch2 = abs(fftshift(fft(ypitch2(1:L_min))));
S_orig_norm = S_orig / max(S_orig);
S_pitch1_norm = S_pitch1 / max(S_pitch1);
S_pitch2_norm = S_pitch2 / max(S_pitch2);

% Observation
plot(f_comp, S_orig_norm, 'b');
hold on; 
plot(f_comp, S_pitch1_norm, 'r'); 
plot(f_comp, S_pitch2_norm, 'g'); 
title('Comparaison des Spectres : Pitch Shifting');
xlabel('Fréquence (Hz)');
ylabel('Magnitude normalisée');
legend('Original', 'Pitch Augmenté', 'Pitch Diminué', 'Location', 'best');
grid on;
xlim([-Fs/2, Fs/2]);
hold off;


%----------------------------
%% 3- ROBOTISATION DE LA VOIX
%-----------------------------
% Choix de la fréquence porteuse (2000, 1000, 500, 200)
Fc = 500; 

yrob = Rob(y,Fc,Fs);

% Ecoute
%-------
pause
disp('------------------------------------')
disp('3- SON "ROBOTISE"')
soundsc(yrob,Fs)

% Observation
%-------------
N = length(yrob);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(10)
subplot(311),plot(t,yrob)
title('Signal "robotisé"')
subplot(312),plot(f,abs(fftshift(fft(yrob))))
subplot(313),spectrogram(yrob,128,120,128,Fs,'yaxis')

%----------------------------
%% 4- EFFET VIBRATO
%----------------------------

% Paramètres du Vibrato
Fmod = 5.0;  % Fréquence de modulation: 5 Hz est classique pour le vibrato
D = 0.10;   % Profondeur de modulation (ajustez cette valeur)
Nfft_v = 1024;

yvibrato = Vibrato(y, Fs, Fmod, D, Nfft_v);

% Ecoute
%-------
pause
disp('------------------------------------')
disp('4- SON AVEC VIBRATO')
soundsc(yvibrato, Fs)

% Observation
%-------------
N = length(yvibrato);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(11)
subplot(311),plot(t,yvibrato)
title('Signal avec vibrato')
subplot(312),plot(f,abs(fftshift(fft(yvibrato))))
subplot(313),spectrogram(yvibrato,128,120,128,Fs,'yaxis')
