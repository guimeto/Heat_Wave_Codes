# -*- coding: utf-8 -*-
"""
Created on Mon Jul 15 10:31:05 2019

@author: guillaume
"""
import xarray as xr
import numpy as np
import pandas as pd
from itertools import groupby
import matplotlib.pyplot as plt

model = 'CANRCM4_NAM-44_ll_CanESM2_historical'
rep = 'CANRCM4_CanESM2_historical'

yi = 1971
yf = 2000
tot=(yf-yi)+1

#########################################################
rep_data='K:/PROJETS/PROJET_CORDEX/CORDEX-NAM44/DONNEES/'
          
def HWDI_2(ds,ind1,ind2,ind3,dur):
    nt = ds["time"].shape[0]
    print(nt)
    sequence = np.zeros(ds.tasmin.shape)
    result = np.zeros(ds.tasmin.shape[1:])
    print(result.shape)
    for i in range(nt - 1):
        tasmin_i = ds.tasmin[i]
        tasmin_ip1 = ds.tasmin[i + 1]

        tasmax_i = ds.tasmax[i]
        tasmax_ip1 = ds.tasmax[i + 1]

        humidex_i = ds.humidex[i]
        humidex_ip1 = ds.humidex[i + 1]

        where = (tasmin_i >= ind1) & (tasmin_ip1 >= ind1)
        where = where & (tasmax_i >= ind2) & (tasmax_ip1 >= ind2)
        where = where & (humidex_i >= ind3) & (humidex_ip1 >= ind3)
       # sequence[where] += 1
        sequence[i] += where.values
        
    def count_sequence(s):
        """Compute sequences of consecutive days"""
        seq = [len(list(g[1])) for g in groupby(s) if g[0]==1]
        seq2 = sum(i >= dur for i in seq)
        return seq2
          
    result = np.apply_along_axis(count_sequence, 0, sequence)
    
    return result
res = []
for year in range(yi,yf+1):

    print(f"year={year}")
    data = rep_data + rep + '/MONTH/tasmax/' + model + '_tasmax_'+str(year) +'*.nc'
    tmax = xr.open_mfdataset(data)
    data = rep_data + rep + '/MONTH/tasmin/' + model + '_tasmin_'+str(year) +'*.nc'
    tmin = xr.open_mfdataset(data)
    data = rep_data + rep + '/MONTH/humidex/' + model + '_humidex_'+str(year) +'*.nc'
    hum = xr.open_mfdataset(data)

    DS = xr.merge([tmax,tmin, hum])
    DS
     # get the datetime range
    times = pd.date_range(str(year)+"-01-01", str(year)+"-12-31", name="time")
    times = times[~((times.month == 2) & (times.day == 29))]
    DS['time'] = times

    DS_date_range = DS.sel(time=slice(str(year) + '-05-01', str(year) + '-09-30'))
    #DS_date_range.lon   
    #DS_date_range.to_netcdf('./tmp.nc')
    # print(DS)
    # res = DS_date_range.apply(HWDI, dim="time")
    res.append(HWDI_2(DS_date_range,20,33,40,3))
    tmp = np.stack(res)
    
    print("result ---")
    print(res)
    
    data_set = xr.Dataset( coords={'lon': (['y', 'x'], DS.lon),
                                 'lat': (['y', 'x'], DS.lat),
                                 'time': pd.date_range(str(yi)+'-01-01', periods=len(res), freq='Y')})
    
    data_set["Heat Wave"] = (['time','y', 'x'],  tmp)
    
    data_set.to_netcdf('./'+model+'_'+ind1+'_'+ind2+'_'+ind3+'_'+str(yi)+'_'+str(yf)+'.nc')
 
    plt.figure()

    im = plt.pcolormesh(res)
    plt.colorbar(im)
    plt.show()