# -*- coding: utf-8 -*-
"""
Created on Thu May  2 09:59:07 2019

@author: guillaume
"""
import pandas as pd
import numpy as np



##########################-- Partie du code à modifier --######################
yearmin = 1872                                                             
yearmax = 2015  
                                                         
varin = 'Tasmoy'                                                                     
path = 'K:/PROJETS/PROJET_CANICULE/CODES_STATIONS/Input/' 
station = 'MONTREAL_TAVISH'      
                                               
#############################################################################     
data_in = pd.read_csv(path + station + '_daily_' + varin + '_' +  str(yearmin) + '-' + str(yearmax) + '.csv' )
data_in['Date']=pd.to_datetime(data_in['datetime'])
data_in = data_in.set_index("Date", drop=True)
data_in.rename(columns={'0': 'Temperature'}, inplace=True)

data_in['rollingmean3']=  data_in['Temperature'].rolling(window=3).mean()


Spic = np.nanpercentile(data_in['Temperature'], 99.5)  # existence de la VC
Sdeb = np.nanpercentile(data_in['Temperature'], 97.5) # identidie le debut et la fin de la VC (duree >= 3 jours consecutifs)
Sint = np.nanpercentile(data_in['Temperature'], 95.0) # interrompt l'episode de VC des lors que la temperature 

Spic = 27
Sint = 23.2660
Sdeb = 24.5

# Detection des vagues de chaleur et estimation de la severite

myList = []

for y in range(yearmin, yearmax+1): 
    # on extrait la période entre le 1er mai et le 1er septembre
    signal = data_in[str(y) + '-05': str(y) + '-09'] 
    # si le signal présente des valeurs manquantes on les remplace par la moyenne mobile du signal 
    signal['rollmean3'] = signal['Temperature'].rolling(3,center=False,min_periods=1).mean()  
    signal['Temperature'] = signal['Temperature'].fillna(signal['rollmean3'])
     
    signal['rollingmean3']=  signal['Temperature'].rolling(window=3).mean()    # calcul de la moyenne mobile sur 3 jours 
     
        # 1 Détection des seuils  Spic, Sint et Sdeb du signal entrant    
    signal['Sig_Spic'] = signal['rollingmean3'][signal['rollingmean3'] >= Spic]
    signal['Sig_Sint'] = signal['rollingmean3'][signal['rollingmean3'] >= Sint]
    signal['Sig_Sdeb'] = signal['rollingmean3'][signal['rollingmean3'] >= Sdeb]    
    
    i = 1                                                                     # increment sur le numero de la vague   
    row = signal.index[0]
    while row < signal.index[-1]: 
        signalbis = signal[row:signal.index[-1]]
        # Condition de début de vague si nous dépassons Spic
        if signalbis['Sig_Spic'].isnull().all() : 
            row = signal.index[-1]
        else:
            
            # 2 ---- Vague potentielle
            #         Détection de Sint       
            debut = signalbis['rollingmean3'][signalbis['rollingmean3'] >= Spic].index[0]      # début de la vague 
            tt = debut        
            while  signalbis[signalbis.index == tt]['rollingmean3'][0] >= Spic :
                tt =  tt + pd.DateOffset(days=1)        
            t_end = tt   # Fin de la vague  
            
           # 3 Détection de Sdeb   
            tt = debut
            while  signal[signal.index == tt]['rollingmean3'][0] >= Sdeb:
                tt =  tt - pd.DateOffset(days=1)
            
            t_ini = tt
            
            # 4 Durée de la vague  d
            duree =(t_end-t_ini).days + 1 
            
            # Si la durée de la séquence est >= à 3 jours ==> Une vague de chaleur est détecté
            # on va extraire la portion du signal de la vague pour calculer ses caractéristiques
            
            if duree >= 3 : 
                print('Vague de chaleur détectée: Vague no ' + str(i) + ' en ' + str(y) )
                sig_vague        =  signalbis[t_ini:t_end]
                max_sig_vague    = sig_vague['rollingmean3'].max()
                intensite_max_HW = (max_sig_vague - Sdeb) / (Spic - Sdeb)
                
                # Calcul de l'air sous la courbe et calcul de l indice de severite
                A = pd.DataFrame([list(sig_vague['rollingmean3']), [Sdeb]*duree ]).T
                A =  A[A[0]>A[1]] # dans le calcul de l'air, il faut que le signal soit au-dessus la constante
                #np.trapz( A[1].values, x = A[1].index.values)                      # courbe théorique avec Sdeb
                #np.trapz( A[0].values, x = A[0].index.values)                      # courbe du signal
                Amoy = np.trapz( A[0].values, x = A[0].index.values) - np.trapz( A[1].values, x = A[1].index.values)            
                severite = Amoy / (Spic - Sdeb)
                
                myList.append([t_ini.year, t_ini.month, t_ini.strftime("%d-%b-%Y"), t_end.strftime("%d-%b-%Y"), duree, i,   max_sig_vague, intensite_max_HW, Amoy, severite ])
                
            row = t_end 
            i += 1
          
df = pd.DataFrame(myList, columns=['Annee','Mois','Date Debut','Date Fin', 'Duree Vague', 'No', 'Tmax enregistree', 'Intensite vague', 'Aire', 'Severite'])     
df.to_csv('Vagues_Chaleurs_'+str(station)+'_from_'+str(yearmin)+'_to_'+str(yearmax)+'.csv', index = False, header = True, sep = ',')    
    

