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

model='CANRCM4_NAM-44_ll_CanESM2_historical'

yi = 1970
yf = 2000
tot=(yf-yi)+1

#########################################################
rep_data='./data/'
          
def HWDI_2(ds):
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

        where = (tasmin_i >= 20) & (tasmin_ip1 >= 20)
        where = where & (tasmax_i >= 33) & (tasmax_ip1 >= 33)
        where = where & (humidex_i >= 40) & (humidex_ip1 >= 40)
       # sequence[where] += 1
        sequence[i] += where.values
        
    def count_sequence(s):
        """Compute sequences of consecutive days"""
        seq = [len(list(g[1])) for g in groupby(s) if g[0]==1]
        seq2 = sum(i >= 3 for i in seq)
        return seq2
          
    result = np.apply_along_axis(count_sequence, 0, sequence)
    
    return result

for year in range(yi,yf+1):

    print(f"year={year}")
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
    DS_date_range.lon   
    #DS_date_range.to_netcdf('./tmp.nc')
    # print(DS)

    # res = DS_date_range.apply(HWDI, dim="time")
    res = HWDI_2(DS_date_range)
    print("result ---")
    print(res)
    
 
    DS_date_range.assign(temperature_f = res)
    argo = xr.Dataset(
        data_vars={'HWDI': (('y','x'), res)},
        coords={'lon': DS_date_range.lon ,
                'lat': DS_date_range.lat})
    
    plt.figure()

    im = plt.pcolormesh(res)
    plt.colorbar(im)
    plt.show()