
__author__ = 'RassarinPro'
# Generation Date: 11 Oct 2015
# This program is originally created by Eunjin for smoothness mounthly temperature of weather scenario
# After receiving weather scenarios from DisAg program, we have to smooth the temperature in WTD file.
# The program read average monthly temperature from PRM file then calculate slope between month and month
# The slope is applied to daily temperature in WTD scenario for smoothness the data

import numpy as np
import matplotlib.pyplot as plt


# parameter from user input
startScenarioYear = 2014
stopScenarioYear = 2014

def weather_adjust(temp_wth,doy,slope):
    wth_variable=temp_wth
   # print wth_variable, doy #, slope
    if doy <= 16: #early half of January
        islope=slope[0]
        new_wth=wth_variable-(16-doy)*np.tan(islope)
    elif doy > 16 and doy <= 31: #late  half of January
        islope=slope[1]
        new_wth=wth_variable + (doy-16)*np.tan(islope)
    elif doy > 31 and doy <= 45: #early half of Feb
        islope=slope[1]
        new_wth=wth_variable-(45-doy)*np.tan(islope)
    elif doy > 45 and doy <= 59: #late  half of Feb
        islope=slope[2]
        new_wth=wth_variable + (doy-46)*np.tan(islope)
    elif doy > 59 and doy <= 75: #early half of Mar,
        islope=slope[2]
        new_wth=wth_variable-(75-doy)*np.tan(islope)
    elif doy > 75 and doy <= 90: #late  half of Mar ,
        islope=slope[3]
        new_wth=wth_variable + (doy-75)*np.tan(islope)
    elif doy > 90 and doy <= 105: #early half of Apr, T-(105-day)*np.tan(theta)
        islope=slope[3]
        new_wth=wth_variable-(105-doy)*np.tan(islope)
        #print slope
    elif doy > 105 and doy <= 120: #late  half of Apr, T+(day-106)*tan(theta)
        islope=slope[4]
        new_wth=wth_variable + (doy-106)*np.tan(islope)
    elif doy > 120 and doy <= 136: #early half of May, T-(136-day)*tan(theta)
        islope=slope[4]
        new_wth=wth_variable-(136-doy)*np.tan(islope)
    elif doy > 136 and doy <= 151: #late  half of May, T+(day-136)*tan(theta)
        islope=slope[5]
        new_wth=wth_variable + (doy-136)*np.tan(islope)
    elif doy > 151 and doy <= 166: #early half of June
        islope=slope[5]
        new_wth=wth_variable-(166-doy)*np.tan(islope)
    elif doy > 166 and doy <= 181: #late  half of June
        islope=slope[6]
        new_wth=wth_variable + (doy-167)*np.tan(islope)
    elif doy > 181 and doy <= 197: #early half of July
        islope=slope[6]
        new_wth=wth_variable-(197-doy)*np.tan(islope)
    elif doy > 197 and doy <= 212: #late  half of July
        islope=slope[7]
        new_wth=wth_variable + (doy-197)*np.tan(islope)
    elif doy > 212 and doy <= 228: #early half of August
        islope=slope[7]
        new_wth=wth_variable-(228-doy)*np.tan(islope)
    elif doy > 228 and doy <= 243: #late  half of August
        islope=slope[8]
        new_wth=wth_variable + (doy-228)*np.tan(islope)
    elif doy > 243 and doy <= 258: #early half of Sep
        islope=slope[8]
        new_wth=wth_variable-(258-doy)*np.tan(islope)
    elif doy > 258 and doy <= 273: #late  half of Sep
        islope=slope[9]
        new_wth=wth_variable + (doy-259)*np.tan(islope)
    elif doy > 273 and doy <= 289: #early half of Oct
        islope=slope[9]
        new_wth=wth_variable-(289-doy)*np.tan(islope)
    elif doy > 289 and doy <= 304: #late  half of Oct
        islope=slope[10]
        new_wth=wth_variable + (doy-289)*np.tan(islope)
    elif doy > 304 and doy <= 319: #early half of Nov
        islope=slope[10]
        new_wth=wth_variable-(319-doy)*np.tan(islope)
    elif doy > 319 and doy <= 334: #late  half of Nov
        islope=slope[11]
        new_wth=wth_variable + (doy-320)*np.tan(islope)
    elif doy > 334 and doy <= 350: #early half of Dec
        islope=slope[11]
        new_wth=wth_variable-(350-doy)*np.tan(islope)
    elif doy > 350 and doy <= 365: #late  half of Dec
        islope=slope[12]
        new_wth=wth_variable + (doy-350)*np.tan(islope)
 #   print new_wth , wth_variable  
    return new_wth
    

    
# Read data monthly avg Tmin and Tmax from PRM file
#

Tmax_avg = [-2.75,-1.78,2.77,10.62,16.91,20.66,23.23,24.84,20.90,14.96,7.33,0.42] #==========
Tmin_avg = [-15.84,-15.68,-8.19,-0.54,4.85,9.87,14.27,15.83,11.14,3.80,-2.28,-10.40] #==========


# Instant variable
dx=[16,30,30,31,31,31,31,32,31,31,31,31,16]
mid_days=[16,16,45,46,75,75,105,106,136,136,166,167,197,197,228,228,258,259,289,289,319,320,350,350]

slope=[[0.0]]*13

for n in range(0,11):
    slope[n+1]=(Tmax_avg[n+1]-Tmax_avg[n])/dx[n+1]
slope[0]=slope[1] #fill the slope for half of Jan with the slope between Jan and Feb
slope[12]=slope[11]

# start date of scenario
# have to convert date to DOY
frst_start_doy = 91 #==========April 1st
numScenario = 101
pathWTD = ''
fName = 'MEMU'



#load data
for nrealiz in range(1,numScenario):
    fnumber=str(nrealiz).zfill(3)
    fname1 = 'C:\\IRI\\PH\\CAMDT\\predict_WTD\\predWTD_sub\\predWTD_sub\\MEMU0'+fnumber+'.WTDE'
    fr = open(fname1,"r") #opens summary.out to read
    Tmax_list=[]
    new_Tmax_list=[]
    for line in range(0,1): #read headers
        temp_str=fr.readline()

# Original idea start_day is start day of planting, end_day is end of planting
# To be more flexible, we can apply smoothing from start date of scenario and end date of scenario
# We need to consider
#   1. if the scenario is for one year, there is no problem.
#           In case, the scenario is for 2 years then we have to calculate year by year and number of day have to
#           be calculated in difference way.
#   2. a leap year?  365 or 366

# Check scenario period is which in one year?



# ----------------------------------------------------------------

	start_day = 60
	end_day = 365

# if weather scenario is for more than a year then we

	ndays = end_day-start_day+1
	doy_list=list(range(start_day, end_day+1))

	for line in range(0,ndays): #read actual simulated data
		temp_str = fr.readline()
		Tmax_list.append(float(temp_str[14:20]))
	fr.close()

    #adjust forecast daily weather
    new_Tmax_list[:]=Tmax_list[:]  #copy
    for line in range(0,ndays):
        doy=start_day+line
        if doy >= frst_start_doy:
            temp_wth=Tmax_list[line]
           # print doy, new_Tmax_list[line], Tmax_list[line], temp_wth, temp_wth2
            temp_wth2 = weather_adjust(temp_wth,doy,slope)
            new_Tmax_list[line] = temp_wth2
         #   print doy, new_Tmax_list[line], Tmax_list[line] #, temp_wth, temp_wth2

    if nrealiz == 1:
        #Tmax_array=Tmax_list
        Tmax_array=new_Tmax_list
    else:
        #Tmax_array = np.vstack((Tmax_array,Tmax_list))
        Tmax_array = np.vstack((Tmax_array,new_Tmax_list))
        
#transpose array before plotting       
Tmax_array=np.transpose(Tmax_array)
Tmax_avg=np.mean(Tmax_array, axis=1)

#======read historical avg
fname1 = 'C:\IRI\Japan\EJ_CHUBU_2015_Oct\WG_datacheck\hist_daily_Tmax.txt'
temp_data = np.loadtxt(fname1)
hist_Tmax=temp_data[start_day-1:end_day]

#Plotting
fig = plt.figure()
#fig.suptitle('sum. Water Stress Index', fontsize=14, fontweight='bold')
fig.suptitle('MEMU-Tmax ADJUSTED forecast', fontsize=14, fontweight='bold')


ax = fig.add_subplot(111)
#fig.subplots_adjust(top=0.85)
#ax.set_title('Yield Forecast')
ax.set_xlabel('DOY',fontsize=14)
ax.set_ylabel('Tmax',fontsize=14)

ax.plot(doy_list,Tmax_array,'-') #, label='test')
#plt.plot(myXList, obs, 'o-')
ax.plot(doy_list,Tmax_avg,'ko-', label='avg of forecasted ens')
ax.plot(doy_list,hist_Tmax,'ro-', label='historical avg')
legend = ax.legend(loc='lower left', shadow=True, fontsize='large')
plt.show()
print 'non'
