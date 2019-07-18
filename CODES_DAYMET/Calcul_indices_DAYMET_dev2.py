# -*- coding: utf-8 -*-
"""
Created on Mon Jul 15 10:31:05 2019

@author: guillaume
"""
import xarray as xr
import numpy as np
import pandas as pd

model='CANRCM4_NAM-44_ll_CanESM2_historical'

yi = 2000
yf = 2000
tot=(yf-yi)+1

#########################################################
rep_data='K:/PROJETS/PROJET_CORDEX/CORDEX-NAM44/DONNEES/CANRCM4_CanESM2_historical/MONTH/'


def HWDI(tmin, tmax, hum, seq):    
    maxCount = seq
    actualCount = 0
    sequence = 0
    i = 0
    while (i < len(tmin)-1):
             while (i < len(tmin)-1 ) and (tmin[i] == 1) and (tmax[i] == 1) and (hum[i] == 1):
                 i += 1
                 actualCount +=1
             if actualCount >= maxCount:
                 sequence += 1
             actualCount = 0
             i += 1 
    return(sequence)
    
for year in range(yi,yf+1):
  
    data = rep_data + 'tasmax/' + model + '_tasmax_'+str(year) +'*.nc'
    tmax = xr.open_mfdataset(data)
    data = rep_data + 'tasmin/' + model + '_tasmin_'+str(year) +'*.nc'
    tmin = xr.open_mfdataset(data)
    data = rep_data + 'humidex/' + model + '_humidex_'+str(year) +'*.nc'
    hum = xr.open_mfdataset(data) 
    
    DS = xr.merge([tmax,tmin, hum])
    
     # get the datetime range
    times = pd.date_range(str(year)+"-01-01", str(year)+"-12-31", name="time")
    times = times[~((times.month == 2) & (times.day == 29))]
    DS['time'] = times
    
    DS_date_range = DS.sel(time=slice(str(year) + '-05-01', str(year) + '-09-30'))
    
    IND_hum = xr.where(DS_date_range.humidex>=40, 1, 0)
    IND_tmax = xr.where(DS_date_range.tasmax>=33, 1, 0)
    IND_tmin = xr.where(DS_date_range.tasmin>=20, 1, 0)
    
    IND = np.zeros((1,IND_tmin.shape[1],IND_tmin.shape[2]),dtype=float)
    nt=0
    for i in range(0,IND_tmin.shape[1]):
        for j in range(0,IND_tmin.shape[2]):
            IND[nt,i,j] = HWDI(IND_tmin[:,i,j].values, IND_tmax[:,i,j].values, IND_hum[:,i,j].values, 3)
    
    DS['Heat Wave'] = IND
    ds = xr.Dataset({'dss': dss, 'nmap': (('y', 'x'), nmap)})
