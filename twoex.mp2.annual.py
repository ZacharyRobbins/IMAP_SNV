#!/usr/bin/env python
"""
Computes a sample using templated run, example usage:

    mpirun -n 16 python parallel.run.py -c 'BCI.ICLM45ED.wolf.intel.Cb14cb81-F812a621.'  -r /lustre/scratch3/turquoise/cxu/ACME/cases  -f clm2.h0.2003-12.nc -n 1 -s 1 -t 1000 -l ./R/Missing.txt
        
Phillip J. Wolfram
08/25/2017

Modified by Chonggang Xu
Feb 4,2018
"""

from mpi4py import MPI
import numpy as np
import pandas as pd
import xarray as xr
from os import path
import os
import argparse

root='/lustre/scratch5/zjrobbins/E3SM_run/scratch/'
nameofthing='IMAP_SNV.IELMFATES'
outputfolder="IMAP_tester2"   # idk


parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-s', '--start', dest='start',
                     help='base name of a case (casename=casebase${samplenumber+start_it', metavar='INT', required=True)
#parser.add_argument('-r', '--runroot', dest='runroot',
#                     help='base name of a case (casename=casebase${samplenumber+start_it', metavar='FOLDER', required=True)
parser.add_argument('-ys', '--Yearstart', dest='Years',
                     help='base name of a case (casename=casebase${samplenumber+start_it', metavar='INT', required=True)
parser.add_argument('-ye', '--Yearend', dest='Yeare',
                     help='base name of a case (casename=casebase${samplenumber+start_it', metavar='INT', required=True)
parser.add_argument('-n', '--write', dest='write',
                     help='base name of a case (casename=casebase${samplenumber+start_it', metavar='STRING', required=True)				 
args = parser.parse_args()

runroot=root+nameofthing
outdir=root+outputfolder


comm = MPI.COMM_WORLD
rank = comm.Get_rank()
totalprocs = comm.Get_size()
overall = False
if totalprocs < 2:
    overall = True
print('Computing using rank {} of {}'.format(rank, totalprocs))

outdir=outdir
Case=int(args.start)+int(rank)
#Case=""
print(Case)
wdir=runroot#+"."+str(Case)
#wdir=runroot
print(wdir)


mod='h0'
#i=str(99)
Yearset=list(range(int(args.Years),int(args.Yeare)+1))
#var=['FATES_LEAF_H2OPOT_SZPF','FATES_STOMATAL_COND_AP']
#var=['FATES_GPP','QVEGE','QVEGT','QSOIL','QRUNOFF','H2OSOI']
var=['FATES_GPP','QVEGE','QVEGT','QSOIL','QRUNOFF','H2OSOI','FATES_LEAF_H2OPOT_SZPF',
	'FATES_NPP_PF','FATES_STOREC_PF','FATES_STOREC_TF','FATES_STOREC_TF_USTORY_SZPF','FATES_STOREC_TF_CANOPY_SZPF','FATES_STRUCTC','FATES_VEGC_ABOVEGROUND','FATES_STOMATAL_COND','FATES_NPP','FATES_GROWTH_RESP','FATES_MAINT_RESP','FATES_AUTORESP_CANOPY','FATES_EXCESS_RESP',
	'FATES_STOREC_PF','FATES_REPROC','FATES_NONSTRUCTC', 'FATES_STORE_ALLOC_SZPF','FATES_MORTALITY_CSTARV_SZPF','FATES_STOREC_USTORY_SZPF','FATES_STOREC_CANOPY_SZPF',
	'FATES_SAPFLOW','FATES_STEM_CONDFRAC_SZPF','FATES_TRANSROOT_CONDFRAC_SZPF'] #,'FATES_STEM_H2OPOT_SZPF']
Monthset=["01","02","03","04","05","06","07","08","09","10","11","12"]
Finishedblock=pd.DataFrame([])
Missing=[]
if os.path.isdir(outdir):
		print("Exists")
else:
		print("Doesn't exists")
		os.mkdir(outdir)
#print(wdir+"/run/"+wdir+"."+str(Case)+".elm.h0."+str(args.Yeare)+"-12.nc")

#print(wdir+"/run/"+nameofthing+"."+str(Case)+".elm.h1."+str(args.Yeare)+"-01.nc")

print(wdir+"/run/"+nameofthing+".elm.h0."+str(args.Yeare)+"-01-01-00000.nc")
if path.exists(wdir+"/run/"+nameofthing+".elm.h0."+str(args.Yeare)+"-01-01-00000.nc")==True:
	for Year in Yearset:
		Year=str(Year)
		print(Year)
		#for month in Monthset:
		        #print(month)
		data_path=wdir+"/run/"+nameofthing+".elm.h0."+Year+"-01-01-00000.nc"
		print(data_path)
		Fileblock=xr.open_dataset(data_path)
		Template=pd.DataFrame({'Date':Fileblock.coords['time'].values,'Model':Case})
			#Template=pd.DataFrame({'Date':Fileblock.coords['time'].values,'Model':Case})
		thing=["Date","Model"]  
			#print(Fileblock.coords['time'].values)
		for v in var:
				print(v)

				#print(list(Fileblock[v].dims))
				if len(list(Fileblock[v].dims))== 2 :
					print(v)
					Template=Template.merge(pd.DataFrame({'Date':Fileblock.coords['time'].values,
						v:np.array(Fileblock[v].values).flatten()}).reset_index(drop=True), on="Date")       
			#print(Template)
#			if len(Fileblock[v].dims)> 2 :
				if list(Fileblock[v].dims)[1]=='fates_levscpf':		
					grnd=Fileblock.coords['fates_levscpf'].values
					for g in grnd: 
						T2=pd.DataFrame({'Date':Fileblock.coords['time'].values,
						'value1':np.array(Fileblock[v].sel(fates_levscpf=g).values).flatten()})
						T2.rename(columns={ T2.columns[0]: "Date",T2.columns[1]:(v+"_"+str(g)) }, inplace = True)
#					print(T2)
						Template=Template.merge(T2,on="Date")
				if list(Fileblock[v].dims)[1]=='fates_levage':		
					grnd=Fileblock.coords['fates_levage'].values
					for g in grnd: 
						T2=pd.DataFrame({'Date':Fileblock.coords['time'].values,
						'value1':np.array(Fileblock[v].sel(fates_levage=g).values).flatten()})
						T2.rename(columns={ T2.columns[0]: "Date",T2.columns[1]:(v+"_"+str(g)) }, inplace = True)
				#	print(T2)
						Template=Template.merge(T2,on="Date")
					
				if list(Fileblock[v].dims)[1]=='levgrnd':
					#print(Fileblock.coords['time'].values)
					#print(np.array(Fileblock[v].sel(fates_levscpf=1).values).flatten())		
					#print(np.array(Fileblock[v].sel(fates_levscpf=1).values).flatten())		
					grnd=Fileblock.coords['levgrnd'].values
					#print(np.array(Fileblock[v].sel(fates_levscpf=1).values).flatten())		
					print(grnd)
					T2=pd.DataFrame({'Date':Fileblock.coords['time'].values,
					'value1':np.array(Fileblock[v].sel(levgrnd=grnd[0]).values).flatten(),
					'value2':np.array(Fileblock[v].sel(levgrnd=grnd[1]).values).flatten(),
					'value3':np.array(Fileblock[v].sel(levgrnd=grnd[2]).values).flatten(),
					'value4':np.array(Fileblock[v].sel(levgrnd=grnd[3]).values).flatten(),
					'value5':np.array(Fileblock[v].sel(levgrnd=grnd[4]).values).flatten(),
					'value6':np.array(Fileblock[v].sel(levgrnd=grnd[5]).values).flatten(),
					'value7':np.array(Fileblock[v].sel(levgrnd=grnd[6]).values).flatten(),
					'value8':np.array(Fileblock[v].sel(levgrnd=grnd[7]).values).flatten(),
					'value9':np.array(Fileblock[v].sel(levgrnd=grnd[8]).values).flatten(),
					'value10':np.array(Fileblock[v].sel(levgrnd=grnd[9]).values).flatten(),
					'value11':np.array(Fileblock[v].sel(levgrnd=grnd[10]).values).flatten(),
					'value12':np.array(Fileblock[v].sel(levgrnd=grnd[11]).values).flatten(),
					'value13':np.array(Fileblock[v].sel(levgrnd=grnd[12]).values).flatten(),
					'value14':np.array(Fileblock[v].sel(levgrnd=grnd[13]).values).flatten(),
					'value15':np.array(Fileblock[v].sel(levgrnd=grnd[14]).values).flatten()})
					T2.columns = [v+ str(col)  for col in T2.columns]
					T2.rename(columns={ T2.columns[0]: "Date" }, inplace = True)
					Template=Template.merge(T2,on="Date")
		Finishedblock=pd.concat([Finishedblock,Template]) 
#		print(Finishedblock)
	print(outdir+"/"+nameofthing+".csv")
	Finishedblock.to_csv(outdir+"/"+nameofthing+".csv")
else:
    print("Missing"+wdir) 
