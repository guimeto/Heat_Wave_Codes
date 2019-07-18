
import os
from zipfile import ZipFile

def create_zip(path,zipf):
    #path is the directory address (i.e. /Home/Documents/Test_files)
    for root, dirs, files in os.walk('K:/DATA/DONNEES_AMERIQUE_DU_SUD/CORDEX-SAM44/REMO2009_MPI-M-MPI-ESM-LR_rcp45/pr'):
        for file in files:
            if file.endswith(".nc"):
                print(file)
                zipf.write(os.path.join(root, file), arcname=file)
                os.remove(os.path.join(root, file))