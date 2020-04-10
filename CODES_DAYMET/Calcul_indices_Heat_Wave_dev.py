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
rep_data='./data/'

def HWDI(ds):
    actualCount = 0
    sequence = 0
    i = 0
    while (i <= len(ds.tasmin)-1):
             while (i+1 < len(ds.tasmin)) and (ds.tasmin[i] >= 20) and (ds.tasmin[i+1] >= 20) and (ds.tasmax[i] >= 33) and (ds.tasmax[i+1] >= 33) and (ds.humidex[i] >= 40) and (ds.humidex[i+1] >= 40):
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
             elif actualCount >= 3:
                  sequence += 1 
                  actualCount = 0
                 
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
    DS_date_range.to_netcdf('./tmp.nc')     
    
    res = DS_date_range.apply(HWDI)
    
