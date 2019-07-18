# -*- coding: utf-8 -*-
"""
Created on Mon Jul 15 10:31:05 2019

@author: guillaume
"""
import xarray as xr
import numpy as np
import pandas as pd
from netCDF4 import Dataset


model='DAYMET_1km_subset_BV'
yi = 2017
yf = 2017
tot=(yf-yi)+1
#########################################################
rep='K:/DATA/DONNEES_AMERIQUE_DU_NORD/DAYMET/CLEMENCE/BV/'
          
def HWDI(tmin, tmax, hum, ind1, ind2, ind3, seq):    
    actualCount = 0
    sequence = 0
    i = 0
    while (i <= len(tmin)-1):
             while (i+1 < len(tmin)) and (tmin[i] >= ind1) and (tmin[i+1] >= ind1) and (tmax[i] >= ind2) and (tmax[i+1] >= ind2) and (hum[i] >= ind3) and (hum[i+1] >= ind3):
                 i += 1
                 if actualCount == 0 :
                    actualCount += 2
                 else:
                    actualCount += 1
                 
             if actualCount == 0:
                 i += 1
                 actualCount = 0
             elif (actualCount == 1) or  (actualCount == 2) :
                 actualCount = 0
             elif actualCount >= seq:
                  sequence += 1 
                  actualCount = 0
                 
    return(sequence)            
            
for year in range(yi,yf+1):
  
    data = rep + model + '_tmax_'+str(year) +'_*.nc4'
    tmax = xr.open_mfdataset(data)
     
    data = rep + model + '_tmin_'+str(year) +'_*.nc4'
    tmin = xr.open_mfdataset(data)
     
    data = rep + model + '_humidex_'+str(year) +'_*.nc4'
    hum = xr.open_mfdataset(data)
   
    DS = xr.merge([tmax,tmin, hum])

    DS_date_range = DS.sel(time=slice(str(year) + '-05-01', str(year) + '-09-30'))
    DS_date_range.to_netcdf('./tmp.nc')                   
    # Calcul de l'indice 
       
    nt=0
    IND = np.zeros((tot,678,702),dtype=float)
    ###### ouverture et lecture des fichiers Netcdf
    nc_Modc=Dataset('./tmp.nc','r')
    lats=nc_Modc.variables['lat'][:]
    lons=nc_Modc.variables['lon'][:]
    tmax=nc_Modc.variables['tmax'][:]
    tmin=nc_Modc.variables['tmin'][:]
    humidex=nc_Modc.variables['humidex'][:]
    
    
    ###### boucle sur tous les points de grille et calcul de l'indice
    for ni in range(0, len(tmax[0])):
        for nj in range(0, len(tmax[0][0])):           
            IND[nt,ni,nj]=HWDI(tmin[:,ni,nj],tmax[:,ni,nj],humidex[:,ni,nj], 20, 33, 40, 3 )
            description='Heat Wave Index'
            unite='days'

        ###### Écriture du fichier Netcdf en sortie
    C = Dataset('./output/python/'+model+'_HWDI_'+str(yi)+'-'+str(yf)+'_Mai_Septembre.nc', 'w')
    C.description = 'Heat Wave Index'
    C.conventions = 'CF-1.0'  
    C.model_id = model
    C.institution = 'UQAM - ESCER Center, University of Quebec in Montreal'
    C.contact = 'Guillaume Dueymes'
    ########################################
    # Dimensions
    C.createDimension('x', len(tmin[0][0]))
    C.createDimension('y', len(tmin[0]))
    C.createDimension('time', tot)
    
    var=C.createVariable('HWDI', np.float32, ('time','y','x')) 
    var.long_name = str(description)
    var.unit = str(unite)
    lat=C.createVariable('lat', np.float32, ('y','x'))
    lon=C.createVariable('lon', np.float32, ('y','x')) 
    
    time = C.createVariable('time', np.float64, ('time',))
    time.long_name = 'time'
    
    nc_Modr=Dataset(rep + model + '_tmin_'+str(year) +'_01.nc4','r')
    lats=nc_Modr.variables['lat'][:]
    lons=nc_Modr.variables['lon'][:]

    
    for var in ['lon','lat','time']:
        for att in nc_Modr.variables[var].ncattrs():
            setattr(C.variables[var],att,getattr(nc_Modr.variables[var],att))
    
    time[:]=range(1,nt+1)
    lat[:,:] = lats
    lon[:,:] = lons
    C.variables['HWDI'][:,:,:] = IND[::]
    C.close()   

            
        
            
            
            
            