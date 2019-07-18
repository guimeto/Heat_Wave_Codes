 % %     Script permettant de détecter une vague de chaleur selon les critères établies par météo-France
% %     Utilisation des 3 seuils fixés à partir des centiles de la distibution de températures moyennes quotidiennes
% %     établie selon une période de référence (ici 1986 à 2015)
% %
% %                  Spic (99,5C) = identifie l'existence de la VC
% %                  Sdeb (97,5C) = identidie le début et la fin de la VC (durée >= 3 jours consécutifs)
% %                  Sint (95,0C) = interrompt l'épisode de VC dès lors que la température 
% %                                 redescent ponctuellement en dessous de ce seuil
% % 
                          
%% Calcul des centiles de la distribution des températures moyennes sur la période 1986 à 2015 %%
%% Définir les seuils Spic, Sdeb et Sint qui représentent les centiles : 99,5 ; 97,5 ; 95,0    %%

clear all;

%% Chemins à initialiser

entree = './Input/'; %pour calcul des percentiles


out_dir ='./Output/';
MJJAS_Tmoy = './Input/'; %pour calcul de Tmoy
station = 'MONTREAL_TAVISH';
InFileTmoy='MONTREAL_TAVISH_SERIES_MJJAS_tasmoy';


%% Période d'analyse
start_year = 1872;
end_year = 2015;
ny = (end_year-start_year)+1;
time = start_year:end_year;

%% Chargement des données entrantes
Tmoy_totale = dlmread(strcat(entree,station,'_tasmoy_',num2str(start_year),'_',num2str(end_year),'.txt'));
% Tmoy_totale = dlmread(strcat(entree,station,'_Tmoy_','1981_2015','.txt'));
Tmoy = dlmread(strcat(MJJAS_Tmoy,InFileTmoy,'_',num2str(start_year),'_',num2str(end_year),'.txt'));

%% moyenne mobile TMOY
signaltot = Tmoy_totale';  
TNi = isnan(signaltot);
     for j = 1:12783
        if j ~= 12783 && j ~= 1 && TNi(j-1) == 0 && TNi(j+1) == 0
            signaltot(j) = (signaltot(j-1) + signaltot(j) + signaltot(j+1))/3;              
        end
     end
%% Calcul des centiles
Spic = prctile(signaltot,99.5);
Sdeb = prctile(signaltot,97.5);
Sint = prctile(signaltot,95.0);

%% Détecter les vagues de chaleur et estimer la sévérité
for iy = 1:ny    % boucle sur les annees (1:ny)
    iy = 139
    curr_year = num2str(time(iy));
    signal = Tmoy(iy,:)';
    s = Tmoy(iy,:)';
    i = 1;                            % increment sur le numero de la vague
    dtemp = 1;                        % increment sur la saison (dtemp de 1 a 153 ici)
    dtemp_max = size(signal,1);       % longueur max de la saison
    Amoy(iy,:) = 0;
    Amoy_s(iy,:) = 0;
    
 
    % Remplacer les NaN dans signal par la moyenne des T des jours
    % avant et après NaN en excluant le premier et dernier jour
    TN = isnan(signal);
    for j = dtemp:dtemp_max
        if TN(j) == 1 && j ~= 153 && j ~= 1
            signal(j) = (signal(j+1)+signal(j-1))/2;
        end
    end
    
%     Moyenne mobile, la temperature du jour = (J-1 + J + J+1)/3
    for j = dtemp:dtemp_max
        if j ~= 153 && j ~= 1 && TN(j-1) == 0 && TN(j+1) == 0
            signal(j) = (signal(j-1) + signal(j) + signal(j+1))/3;              
        end
    end


    while(dtemp < dtemp_max)    
    signal_bis = signal(dtemp:dtemp_max);
        
%%%% 1) Detection de Spic
    Spic_tt  = find(signal_bis>=Spic,1,'first'); % condition sur le depassement de seuil Spic 
        if isempty(Spic_tt)                     % si pas de depassement de seuil: on va  a la fin de la saison
            disp('PAS DE VAGUE')
            dtemp = dtemp_max;
        else                                   % si depassement, on rentre dans la vague 
            tt = Spic_tt;                      % jour du depassement 
            
%%%% 2) Detection de Sint
                while(signal_bis(tt)>= Sint)      % on detecte le moment ou on depasse Sint
                    tt = tt+1;
                end 
            t_end = tt; % numéro fin de la vague

%%%% 3) Detection de Sdeb    
            tt = Spic_tt;
                while(signal_bis(tt)>= Sdeb)      % on detecte le moment ou on depasse Sdeb avant Spic 
                    tt = tt-1;                    
                end
            t_ini = tt; % numéro début de la vague
          
%%%% 4) Calcul de la duree de la vague         
            duree =(t_end-t_ini)+1 ;    
% Condition sur la duree: VAGUE si duree>=3jours
% Si condition verifiee, on va sauvegarder la portion du signal et les
% caracteristues de la vagues
            if duree>=3
                disp(strcat('VAGUE CHALEUR DETECTEE: VAGUE NUMERO ',num2str(i),' ANNEE ',num2str(curr_year)))
                Vague(i,1) = duree;
                Vague(i,2) = t_ini+dtemp-1;
                Vague(i,3) = t_end+dtemp-1;
                Sig_Vague = signal_bis(t_ini:t_end);
                
                Max_Sig_Vag(iy,i) = max(Sig_Vague);
                Max_Sig_Vag(Max_Sig_Vag == 0) = NaN;
                indice_intensite_max_HW(iy,i) = (Max_Sig_Vag(iy,i) - Sdeb)/(Spic - Sdeb);
                indice_intensite_max_HW(indice_intensite_max_HW == 0) = NaN;               
% % 
                %save(strcat(out_dir,char(station),'_Nb-&-position_',num2str(curr_year),'-VAGUE-',num2str(i),'.txt'),'Vague','-ASCII');
              %  save(strcat(out_dir,char(station),'_Nb_',num2str(curr_year),'-VAGUE-',num2str(i),'.txt'),'duree','-ASCII');
                save(strcat(out_dir,char(station),'_Tmoymax_HW_',num2str(start_year),'-',num2str(end_year),'.txt'),'Max_Sig_Vag','-ASCII');
                save(strcat(out_dir,char(station),'_indice_intensite_max_HW_',num2str(start_year),'-',num2str(end_year),'.txt'),'indice_intensite_max_HW','-ASCII');
%                 
%%%% 5) calcul des aires sous les signaux par approche trapezoidale
                Amoy(iy,i)=trapz(1:Vague(i,1),signal(Vague(i,2):(Vague(i,2)+Vague(i,1)-1)));

%%%% 6)  calcul des aires entre Sdeb et la température moyenne maximale
                seuilSdeb = ones(Vague(i,1))*Sdeb;
                Amoy_s(iy,i) = trapz(1:Vague(i,1),seuilSdeb(:,1));

%%%% 7) Visualisation de la vague avec les seuils

                A = zeros(1,Vague(i,1))';
                duree2 = (Vague(i,2):(Vague(i,2)+Vague(i,1)-1));             
              
                B = signal(Vague(i,2):(Vague(i,2)+Vague(i,1)-1)); % boucle pour visualiser uniquement l'aire de Sdeb 
                for s = 1:length(B)                                 % jusqu'au signal à l'aide de shadeplot
                    if B(s)<Sdeb
                       Bis(s) = Sdeb;
                    else
                       Bis(s) = B(s);
                    end
                end
                
                dtemp = dtemp+t_end; % on repart apres la premiere vague
                duree_totale(iy,i) = duree;
                i = i+1;

            elseif duree<3
                
                disp('VAGUE inferieure a 3 jours')
                dtemp = dtemp+t_end; %on repart apres la premiere vague
            end
            
        end
  
%     clear signal_bis  t_ini t_end Spic_tt tt
        if exist('duree','var') == 0  
            duree_totale(iy,i) = NaN;  %remplace les valeurs manquantes par des NaN
        end

    end                 %fin de la boucle sur la saison courante
    
end


signal_bis(signal_bis==0) = NaN;
Amoy(Amoy==0) = NaN;
Amoy_s(Amoy_s==0) = NaN;
Amoybis = (Amoy - Amoy_s).^2;
Amoy2 = sqrt(Amoybis);
Amoy2(Amoy2==0) = NaN;
duree_totale(duree_totale==0) = NaN;
Severite = Amoy2 / ( Spic - Sdeb);

%%%%% Sauvegarde des données %%%%%%

save(strcat(out_dir,char(station),'_Spic_',num2str(start_year),'_',num2str(end_year),'.txt'),'Spic','-ASCII');
save(strcat(out_dir,char(station),'_Sdeb_',num2str(start_year),'_',num2str(end_year),'.txt'),'Sdeb','-ASCII');
save(strcat(out_dir,char(station),'_Sint_',num2str(start_year),'_',num2str(end_year),'.txt'),'Sint','-ASCII');

save(strcat(out_dir,char(station),'_INTENSITE_VAGUES_Tmoy_',num2str(start_year),'-',num2str(end_year),'.txt'),'Amoy','-ASCII');
save(strcat(out_dir,char(station),'_INTENSITE2_VAGUES_Tmoy_',num2str(start_year),'-',num2str(end_year),'.txt'),'Amoy2','-ASCII');
save(strcat(out_dir,char(station),'_duree_totale_',num2str(start_year),'-',num2str(end_year),'.txt'),'duree_totale','-ASCII');
save(strcat(out_dir,char(station),'_Indice_Severite_',num2str(start_year),'-',num2str(end_year),'.txt'),'Severite','-ASCII');


% clear all
