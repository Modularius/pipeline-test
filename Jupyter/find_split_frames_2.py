# look for split frames

# count and asymmetry spectra vs elapsed time
import h5py
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import sys
import argparse
import itertools
import scipy.optimize


#filepath=r"smb:\\ISISARVR55.isis.cclrc.ac.uk\SuperMusrTestDataBackup$\incoming\hifi\HIFI{:08d}.nxs"
#filepath=r"\\isisarvr55.isis.cclrc.ac.uk\supermusrtestdatabackup$\incoming\{:s}\HIFI{:08d}.nxs"
#filepath2=r"\\isisarvr55.isis.cclrc.ac.uk\supermusrtestdatabackup$\incoming\hifi\via-local\HIFI{:08d}.nxs"
filepath=r"../archive/incoming/{:s}/HIFI{:08d}.nxs"

DAEpath="//hifi/data/HIFI{:08d}.nxs"

parser=argparse.ArgumentParser()
parser.add_argument("-r",type=int,help="(First) Run number")
parser.add_argument("-R",type=int,default=0,help="Last run number")

parser.add_argument("-p",default="hifi",help="Instrument subdirectory")

#parser.add_argument("-c",type=int,help="Histogram to analyse",default=9)
#parser.add_argument("-C",action="store_true",help="Invert histogram selection")

#parser.add_argument("-s",action="store_true",help="Sum pulse heights across spectra")
#parser.add_argument("-S",action="store_true",help="Sum pulse heights across runs")

parser.add_argument("-b",type=int,default=8,help="Block size for grouping detectors, e.g. 8")
#parser.add_argument("-B",type=float,default=5.0,help="Bin size for elapsed-time spectrum (minutes)")

#parser.add_argument("-N",type=int,default=10,help="Number of error frames to print, -1 just to sum")

#parser.add_argument("-f",type=int,default=100000000,help="Max number of frames to analyse")

#parser.add_argument("-t",type=int,nargs=2,default=(500,10000),help="Time window for good pulses")
# parser.add_argument("-a",type=int,nargs=2,default=(0,4097),help="Amplitude window for good pulses") # not used yet?

parser.add_argument("-m",action="store_true",help="Print matrix strip")

parser.add_argument("-M",type=int,nargs=2,help="Print detailed matrix strip")

parser.add_argument("-v",action="store_true",help="Verbose listings")

parser.add_argument("-q",action="store_true",help="No extraneous printing")

args=parser.parse_args()

run1=args.r
run2=args.R
if run2==0:
	run2=run1

blocker=args.b

mask=np.zeros([64],dtype=np.longlong)
fullmask=0
for i in range(64):
	mask[i]=1<<(i//blocker)
	fullmask |= mask[i]

def contents(fr):
	return np.unique(eid[eix2[fr]:eix2[fr+1]]//blocker)

def qcontents(fr):
	s=contents(fr)
	return "".join("{:1X}".format(i) for i in s)

print ("run","start_time","Nfull","Npartial","Nsingles","Ndoubles","Nhigher","Nclose")

for run in range(run1,run2+1):
	try:
		path = filepath.format(args.p,run)
		f=h5py.File(path,"r")
	except OSError:
		print (run,"can't_open")
	else:
		eix=f["raw_data_1/detector_1/event_index"]
		eid=f["raw_data_1/detector_1/event_id"]
		etim=f["raw_data_1/detector_1/event_time_offset"]
		eph=f["raw_data_1/detector_1/pulse_height"]
		etz=np.array(f["raw_data_1/detector_1/event_time_zero"])
		eix2=list(eix)
		eix2.append(len(eid))
		start=str(f["raw_data_1/start_time"][()],encoding='utf-8',errors='strict')
		if len(eix)==0:
			print (run,"empty")
		else:
			runlen=int(np.max(etz)//19500000+2) # short frames to avoid accidental overlap
			#print ("run has space for",runlen,"possible short frames")
			accum=np.zeros([runlen],dtype=np.uint32)
			accum2=np.zeros([runlen],dtype=np.ulonglong)
			pieces=np.zeros([runlen],dtype=np.uint32)
			tz2=np.zeros([runlen],dtype=np.ulonglong)
			src=np.zeros([runlen])
			Nclose=0

			for i in range(len(eix)):
				npu=np.unique(eid[eix2[i]:eix2[i+1]]//blocker)
				a=np.sum(np.left_shift(1,npu))
				a2=np.sum(np.left_shift(1,4*npu))
				#for j in range(eix2[i],eix2[i+1]):
				#	a=a|mask[eid[j]]
				k=int(etz[i]//19500000)
				accum[k] |= a
				accum2[k] |= a2*(pieces[k]+np.ulonglong(1))
				pieces[k] +=1
				if tz2[k]==0:
					tz2[k]=etz[i]
				elif tz2[k]!=etz[i]:
					Nclose+=1
					if not args.q:
						print ("two close events,",src[k],i,tz2[k],etz[i],"delta=",(etz[i]-tz2[k]))
				src[k]=i

			Nsome=np.count_nonzero(accum)
			Nfull=np.count_nonzero(accum==fullmask)
			Nsingles=np.count_nonzero(pieces==1)
			Ndoubles=np.count_nonzero(pieces==2)
			Nhigher=np.count_nonzero(pieces>2)

			if Nhigher>0 and not args.q:
				k=np.argmax(pieces)
				print ("max pieces",pieces[k],"at",k,"with dets",accum2[k])
				for i in range(len(eix)):
					if int(etz[i]//19500000)==k:
						print ("frame",i,"time",etz[i],contents(i))

			bc=np.bincount(accum)
			if args.v:
				print ("zeros",bc[0],"full",bc[255])
				for j in range(1,255):
					if bc[j]:
						print (j,":",bc[j])

				for k in range(len(accum)):
					if accum[k]>0 and accum[k]<255:
						for i in range(len(eix)):
							if int(etz[i]//19500000)==k:
								print ("frame",i,"time",etz[i],contents(i))
								print (eid[eix2[i]:eix2[i+1]])
						break

			print (run,start,Nfull,Nsome-Nfull,Nsingles,Ndoubles,Nhigher,Nclose)
			f.close()
			if args.m:
				a=-1
				for k in range(len(accum)):
					if pieces[k]>0 and accum2[k]!=a:
						print ("{:7.1f} {:08x}".format(tz2[k]/20.E6,accum2[k]))
						a=accum2[k]
			if args.M:
				a=-1
				for k in range(args.M[0],min(len(accum2),args.M[1])):
					if pieces[k]>0:
						print ("{:7.1f} {:08x}".format(tz2[k]/20.E6,accum2[k]))
						