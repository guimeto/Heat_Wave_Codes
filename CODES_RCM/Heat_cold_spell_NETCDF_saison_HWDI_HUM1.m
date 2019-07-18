% Guillaume Dueymes 05 Mars 2015
%
%
% Calcul des indices: 
%      - 1: HWDI3d_HUMI_1: calcule les sequences d occurence ou :
% Tmax_norm_ij >= 30 degC, Tmin_norm_ij >= 20degC , Humidex_norm_ij>= 33degC pendant plus de 3 jours
% consecutifs
%    
% NOTES: - les entrees et sorties sont au format Netcdf
%        - les sorties sont sur la grille CORDEX-NAM44
%        - la saison de travail s etend de mai a septembre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

%%%%%%%%%%%definitions des chemins d entree et de sortie 
min_dir='K:\PROJETS\PROJET_CORDEX\CORDEX-NAM44\DONNEES\CANRCM4_CanESM2_historical\MONTH\tasmin\';
max_dir='K:\PROJETS\PROJET_CORDEX\CORDEX-NAM44\DONNEES\CANRCM4_CanESM2_historical\MONTH\tasmax\';
hum_dir='K:\PROJETS\PROJET_CORDEX\CORDEX-NAM44\DONNEES\CANRCM4_CanESM2_historical\MONTH\humidex\';
out_wave='D:\Utilisateurs\guillaume\Documents\GitHub\Heat_Wave\CODES_RCM\output\matlab\';



%definition du modele

varmin='CANRCM4_NAM-44_ll_CanESM2_historical_tasmin';
varmax='CANRCM4_NAM-44_ll_CanESM2_historical_tasmax';
varhum='CANRCM4_NAM-44_ll_CanESM2_historical_humidex';
Indice_name={'HWDI-HUM1'};
model='CANRCM4_NAM-44_ll_CanESM2_historical';
seuil='20_30_40';
long_name='Hot spell indice HWDI-HUM1';
unite='days';
%
%definitin de la fenetre temporelle
start_year=2000;
end_year=2000;
month={'05','06','07','08','09'};
ny=(end_year-start_year)+1;

tic;
nt=1;
for year=start_year:end_year ;

    curr_year = num2str(year);
    curr_ind=char(Indice_name);
   %% Ouverture et lecture de TASMAX    
 Fichiermax = char ( strcat(max_dir,char(varmax),'_',num2str(curr_year),char(month(1)),'.nc'));
 [TmaxArr1, LatArr, LonArr] = read_netcdf(Fichiermax);       
 clear Fichiermax
  Fichiermax = char ( strcat(max_dir,char(varmax),'_',num2str(curr_year),char(month(2)),'.nc'));
  [TmaxArr2, LatArr, LonArr] = read_netcdf(Fichiermax);       
  clear Fichiermax
  Fichiermax = char ( strcat(max_dir,char(varmax),'_',num2str(curr_year),char(month(3)),'.nc'));
  [TmaxArr3, LatArr, LonArr] = read_netcdf(Fichiermax);       
  clear Fichiermax
  Fichiermax = char ( strcat(max_dir,char(varmax),'_',num2str(curr_year),char(month(4)),'.nc'));
  [TmaxArr4, LatArr, LonArr] = read_netcdf(Fichiermax);       
  clear Fichiermax
 Fichiermax = char ( strcat(max_dir,char(varmax),'_',num2str(curr_year),char(month(5)),'.nc'));
 [TmaxArr5, LatArr, LonArr] = read_netcdf(Fichiermax);       
 clear Fichiermax 
 saison_max=cat(3,TmaxArr1,TmaxArr2,TmaxArr3,TmaxArr4,TmaxArr5);
 clear TmaxArr1 TmaxArr2 TmaxArr3 TmaxArr4 TmaxArr5  
s_length=size(saison_max,3);
sx=size(saison_max,1);
sy=size(saison_max,2);
  
%% Ouverture et lecture de TASMIN    
Fichiermin = char ( strcat(min_dir,char(varmin),'_',num2str(curr_year),char(month(1)),'.nc'));
 [TminArr1, LatArr, LonArr] = read_netcdf(Fichiermin);       
 clear Fichiermin
  Fichiermin = char ( strcat(min_dir,char(varmin),'_',num2str(curr_year),char(month(2)),'.nc'));
  [TminArr2, LatArr, LonArr] = read_netcdf(Fichiermin);       
  clear Fichiermin
  Fichiermin = char ( strcat(min_dir,char(varmin),'_',num2str(curr_year),char(month(3)),'.nc'));
  [TminArr3, LatArr, LonArr] = read_netcdf(Fichiermin);       
  clear Fichiermin
  Fichiermin = char ( strcat(min_dir,char(varmin),'_',num2str(curr_year),char(month(4)),'.nc'));
  [TminArr4, LatArr, LonArr] = read_netcdf(Fichiermin);       
  clear Fichiermin
 Fichiermin = char ( strcat(min_dir,char(varmin),'_',num2str(curr_year),char(month(5)),'.nc'));
 [TminArr5, LatArr, LonArr] = read_netcdf(Fichiermin);       
 clear Fichiermin 
 saison_min=cat(3,TminArr1,TminArr2,TminArr3,TminArr4,TminArr5);
 clear TminArr1 TminArr2 TminArr3 TminArr4 TminArr5  
  
   %% Ouverture et lecture de l HUMIDEX    
 Fichiermin = char ( strcat(hum_dir,char(varhum),'_',num2str(curr_year),char(month(1)),'.nc'));
 [HArr1, LatArr, LonArr] = read_netcdf(Fichiermin);       
 clear Fichiermin
  Fichiermin = char ( strcat(hum_dir,char(varhum),'_',num2str(curr_year),char(month(2)),'.nc'));
  [HArr2, LatArr, LonArr] = read_netcdf(Fichiermin);       
  clear Fichiermin
  Fichiermin = char ( strcat(hum_dir,char(varhum),'_',num2str(curr_year),char(month(3)),'.nc'));
  [HArr3, LatArr, LonArr] = read_netcdf(Fichiermin);       
  clear Fichiermin
  Fichiermin = char ( strcat(hum_dir,char(varhum),'_',num2str(curr_year),char(month(4)),'.nc'));
  [HArr4, LatArr, LonArr] = read_netcdf(Fichiermin);       
  clear Fichiermin
 Fichiermin = char ( strcat(hum_dir,char(varhum),'_',num2str(curr_year),char(month(5)),'.nc'));
 [HArr5, LatArr, LonArr] = read_netcdf(Fichiermin);       
 clear Fichiermin 
 saison_hum=cat(3,HArr1,HArr2,HArr3,HArr4,HArr5);
 clear HArr1 HArr2 HArr3 HArr4 HArr5  
  
  %%%%%%%%%%%%%%calcul de l indice de vague de chaleur: occurence conjointe
 sx=size(saison_min,1);
 sy=size(saison_min,2);
  for o=1:sx ;
        p=1;
        for p=1:sy       
HWDI = indice_calculation_HWDI_HUM1(saison_min(o,p,:),saison_max(o,p,:),saison_hum(o,p,:),s_length);
HWDI_season(o,p,nt)=HWDI(:,1);
HWDI_current(o,p,1)=HWDI(:,1);
    p=p+1;
        end
    o=o+1;
  end
  clear saison_min saison_max saison_hum HWDI
  
time=1;
%% ECRITURE DES SORTIES EN NETCDF 
filenc=strcat(out_wave,char(model),'_',curr_ind,'_Mai_Septembre_',curr_year,'.nc');
ncid = netcdf.create(filenc,'NC_WRITE');
% Definition des dimensions
dimid_x = netcdf.defDim(ncid,'x',sx);
dimid_y = netcdf.defDim(ncid,'y',sy); 
dimid_time = netcdf.defDim(ncid,'time',1); 
% Definition des variables
%%Longitude
varid_lon = netcdf.defVar(ncid,'lon','float',[dimid_x,dimid_y]);
netcdf.putAtt(ncid,varid_lon,'units','degrees_east');
netcdf.putAtt(ncid,varid_lon,'long_name','Longitude');
netcdf.putAtt(ncid,varid_lon,'CoordinateAxisType','Lon');
%%Latitude
varid_lat = netcdf.defVar(ncid,'lat','float',[dimid_x,dimid_y]);
netcdf.putAtt(ncid,varid_lat,'units','degrees_north')
netcdf.putAtt(ncid,varid_lat,'long_name','Latitude');
netcdf.putAtt(ncid,varid_lat,'CoordinateAxisType','Lat');
%%Temps
varid_time = netcdf.defVar(ncid,'time','double',dimid_time);
netcdf.putAtt(ncid,varid_time,'long_name','Time');
netcdf.putAtt(ncid,varid_time,'delta_t','');
%%Indice de vague de chaleur
varid_hwdi = netcdf.defVar(ncid,curr_ind,'float',[dimid_x,dimid_y,dimid_time]);
netcdf.putAtt(ncid,varid_hwdi,'long_name','long_name');
netcdf.putAtt(ncid,varid_hwdi,'units','unite');
netcdf.putAtt(ncid,varid_hwdi,'missing_value',-999);
netcdf.putAtt(ncid,varid_hwdi,'coordinates','lon lat');

%%fermeture du fichier netcdf 
netcdf.endDef(ncid)

% % % Ecrire les variables
netcdf.putVar(ncid,varid_lon,LonArr);
netcdf.putVar(ncid,varid_lat,LatArr);
netcdf.putVar(ncid,varid_time,1);
netcdf.putVar(ncid,varid_hwdi,HWDI_current);
netcdf.close(ncid);
year
clear HWDI_current
nt=nt+1
end  %fin de la boucle sur les domaines
TimeSpent = toc ; 
  disp('C*est fini !');  

 