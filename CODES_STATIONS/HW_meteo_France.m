%% Script pour detecter les vagues de chaleurs selon les critËres de Meteo France
% 
%  Pour HWDI:plus de 3 jours consecutifs minimum
%
% Spic: 99.5 percentile de tasmoy
% Sdeb: 97.5 percentile de tasmoy
% Sint: 95.0 percentile de tasmoy 
%
% Spic, Sdeb et Sint sont calculÈs par stations sur une pÈriode
% climatologique de 30 ans.
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;

%% chemins a initialiser
moy_dir='J:\Donnees_Stations\VAGUES_CHALEURS\DATA\MJJAS\tasmoy\';

out_dir='J:\Donnees_Stations\VAGUES_CHALEURS\DATA\MJJAS\HWDI_METEO_F\';
InFile='MONTREAL_TAVISH_SERIES_MJJAS_tasmoy';
station='MONTREAL_TAVISH_SERIES';

% Definition des seuils
Spic = 27.9 ;
Sdeb = 26.3 ;
Sint = 25.3 ;

% Periode d'analyse
start_year=1981;
end_year=2010;
ny=(end_year-start_year)+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time=start_year:end_year;
%% Chargement des donnees entrantes

Tmoy=dlmread(strcat(moy_dir,InFile,'_',num2str(start_year),'_',num2str(end_year),'.txt'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iy=1:ny;     %boucle sur les annees

curr_year=num2str(time(iy))
signal=Tmoy(iy,:)';

i=1;                                        % increment sur le numero de la vague
dtemp=1;                                    % increment sur la saison (dtemp de 1 a 153 ici)
dtemp_max=size(signal,1);                    % longueur max de la saison

 while(dtemp < dtemp_max)
%Detection de Spic 
signal_bis=signal(dtemp:dtemp_max);
Spic_tt=find(signal_bis>=Spic,1,'first');          %condition sur le depassement de seuil Spic 
  if isempty(Spic_tt);                                          %si pas de depassement de seuil: on va  a la fin de la saison
      disp('PAS DE VAGUE')
    dtemp=dtemp_max;
  else                                                         %si depassement, on rentre dans la vague 
tt=Spic_tt;                                                    %jour du depassement 
%Detection de Sint
     while(signal_bis(tt)>= Sint);                                 %on detecte le moment ou on depasse Sint
        tt=tt+1
     end 
%%%%%%%%%%%%%%%A verifier la duree 
%        t_end=tt-1;
         t_end=tt;
%%%%%%%               
 %Detection de Sdeb    
tt=Spic_tt;     
     while(signal_bis(tt)>= Sdeb);                                 %on detecte le moment ou on depasse Sdeb avant Spic 
        tt=tt-1;
     end 
 %%%%%%%%%%%%%%%A verifier la duree  
%      t_ini=tt+1;
     t_ini=tt;
     
     
%Calcul de la duree de la vague         
duree=(t_end-t_ini)+1 ;    
%Condition sur la duree: VAGUE si duree>=3jours
%Si condition verifiee, on va sauvegarder la portion du signal et les
%caracteristues de la vagues
     if duree>=3
            disp(strcat('VAGUE CHALEUR DETECTEE: VAGUE NUMERO ',num2str(i),' ANNEE ',num2str(curr_year)))
Vague(i,1)=duree;
Vague(i,2)=t_ini+dtemp-1;
Vague(i,3)=t_end+dtemp-1;
Sig_Vague=signal_bis(t_ini:t_end);
save(strcat(out_dir,char(station),'_Tmoy_',num2str(curr_year),'-VAGUE-',num2str(i),'.txt'),'Sig_Vague','-ASCII');
save(strcat(out_dir,char(station),'_CARACTERISTIQUES_',num2str(curr_year),'-VAGUE-',num2str(i),'.txt'),'Vague','-ASCII');

save

%Visualisation de la vague avec les seuils
plot(Sig_Vague,'r','LineWidth',2); hold on
plot([1 duree+1],[Spic Spic],'b','LineWidth',2); hold on
plot([1 duree+1],[Sdeb Sdeb],'green','LineWidth',2); hold on
plot([1 duree+1],[Sint Sint],'--green','LineWidth',2); hold on
grid on 
titre=strcat(num2str(curr_year),'-VAGUE-NUMERO-',num2str(i));
xlabel('Duree');
ylabel('∞Celcius');
 title(titre);
SAVE_file=strcat('figures\',char(station),'_VAGUE_NUMERO_',num2str(i),'_ANNEE_',curr_year);   
              saveFigure(gcf,SAVE_file)
close(gcf);
dtemp=dtemp+t_end; %on repart apres la premiere vague
i=i+1
     elseif duree<3
 disp('VAGUE inferieure a 3 jours')
 dtemp=dtemp+t_end; %on repart apres la premiere vague
     end
  end
  
  clear signal_bis duree t_ini t_end Spic_tt tt
end                 %fin de la boucle sur la saison courante 

plot(signal,'r','LineWidth',2); hold on
plot([1 153],[Spic Spic],'b','LineWidth',2); hold on
plot([1 153],[Sdeb Sdeb],'green','LineWidth',2); hold on
plot([1 153],[Sint Sint],'--green','LineWidth',2); hold on
titre=num2str(curr_year);
xlabel('Duree');
ylabel('∞Celcius');
title(titre);
grid on
SAVE_file=strcat('figures\',char(station),'T_moy_',curr_year);   
              saveFigure(gcf,SAVE_file)
close(gcf);

clear dtemp dtemp_max duree signal Spic_tt t_end t_ini tt Sig_Vague Vague
end

clear all
