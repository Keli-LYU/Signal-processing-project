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
 [y,Fs]=audioread('Extrait.wav');   %signal d'origine
% [y,Fs]=audioread('Halleluia.wav');   %signal d'origine

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

% 1.1- Augmentation 
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

figure(4)
subplot(311),plot(t,ypitch1)
title('Signal avec "pitch" augmenté')
subplot(312),plot(f,abs(fftshift(fft(ypitch1))))
subplot(313),spectrogram(ypitch1,128,120,128,Fs,'yaxis')
%% 1.2- Diminution 
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

figure(5)
subplot(311),plot(t,ypitch2)
title('Signal avec "pitch" diminué')
subplot(312),plot(f,abs(fftshift(fft(ypitch2))))
subplot(313),spectrogram(ypitch2,128,120,128,Fs,'yaxis')


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

figure(6)
subplot(311),plot(t,yrob)
title('Signal "robotisé"')
subplot(312),plot(f,abs(fftshift(fft(yrob))))
subplot(313),spectrogram(yrob,128,120,128,Fs,'yaxis')