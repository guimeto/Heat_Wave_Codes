%% INDICE_CALCULATION_TAS_EC
%
%% DESCRIPTION DU CODE   (Tasmax>30degC - Tasmin>20degC et Humidex>40degC) pdt plus de 3 jours consecutifs
%
% Ce code permet de calculer les indices de vagues de chaleur sur une base mensuelle.
% Une matrice de dimension
% nombre d'annees X 12 mois est donc generer (1ere colonne pour janvier,
% 12eme colonne pour decembre).
%
% Entrees:  - Jan1: Serie temporelle (vecteur) des donnees quotidiennes de
%                   tous les mois de janvier (de chaque annee)
%           - start_year: nombre entier, qui correspond a l'annee du debut
%                         de la serie temporelle;
%           - end_year: nombre entier, qui correspond a l'annee de la fin
%                         de la serie temporelle;
%           - y_length: nombre entier qui correspond au nombre maximal de 
%                       jours par annee pour le type de serie temporelle 
%                       analyse (choix disponible: 366, 365 or 360)
%
% Sortie: - b: Une matrice de dimension nombre de points de grille * nombre
% d annees : une matrice par mois de l annee 
% Sous-fonction(s)/code(s): HWDI3d_EC
%
%
%
% Instruction(s): NA
% Instruction(s): NA
function b = indice_calculation_HWDI_HUM1(tmin,tmax,hum,y_length)

temp_tmin=1;
temp_tmax=1;
temp_hum=1;
tmp=y_length-1;
i=1;

 %pour tmin
 temp_tmin1=tmin(temp_tmin:temp_tmin+tmp);
 %pour tmax
 temp_tmax1=tmax(temp_tmax:temp_tmax+tmp);
 %pour humidex
 temp_hum1=hum(temp_hum:temp_hum+tmp);
                     
 b(i,1)=HWDI_HUM1(temp_tmin1,temp_tmax1,temp_hum1);
 

clear temp_tmax1 temp_tmin1 temp_hum1
i=i+1;
end
   