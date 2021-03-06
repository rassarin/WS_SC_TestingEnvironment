__author__ = 'RassarinPro'
# Generation Date: 16 Oct 2015
# Modified: 26 Jan 2016
# Post Service of weather scenario
# Scenario 6 We are assuming that user want to get weather scenario by calling weather generator service directly
# Internal mechanism is calling weather history service then runing weather generator service
# Monthly smoothing and snow adjustment is applied

#   Input
#       CLI file ( This file will be returned from historical weather service (Tesla) )
#       WTD file ( This file will be returned from historical weather service (Tesla) )
#       MTH file ( is filled with -99.0 meaning do not concern about seasonal forecast )
#           Allow user to input startYear startMonth stopYear stopMonth of scenario
#           genMth is used for generating MTH file
#       PRM file is generated from EstimatePrm
#           Filename will be named as first four characters of CLI filename
#   Related Program
#       WeatherQuery is used to query weather data from nearest weather station
#       EstimatePrm is used to generate PRM file for inputting to Disas program
#       Disag is used to generate weather scenarios
#       genMth is used to generate MTH file by receiving startMonth stopYear stopMonth from user
#       genCLI is used to generate CLI file.
#           The output from WeatherQuery program in the part of station metadata is extracted and formatted
#       genWTD is used to generate WTD file.
#           The output from WeatherQuery program is extracted and formatted.
#       monthlyTrend2WTD is used to adjust step of data between month and month in WTD file
#       adjustWTD4Snow is used to adjust snow effect for wheat

#   Final result
#       WTD files in adjSnow directory 

# weatherScenarioComponentPATH = '/Users/RassarinPro/Documents/Workspace/WeatherGen/WS_SC_TestingEnvironment/'

import os


locationName = "MEMU"



workingDir = '/Users/RassarinPro/Documents/Workspace/WeatherGen/WS_SC_TestingEnvironment/'
#User input parameters for querying historical weather data
#   Parameter for generating MTH file. It is a time window of weather scenario
# 42.900  143.050
targetLatitude = "42.901"
targetLongitude = "143.051"
startScenarioYear = "2014"
startScenarioMonth = "01"
stopScenarioYear = "2014"
stopScenarioMonth = "12"
numScenario = "10"




#Step 1: query historical weather data
# call tesla service for getting historical weather data (WTD) and weather station metadata (CLI)
# start from the beginning of available data in the station up to present

# Default of starting date is beginning of data from that station
# Default of ending date is beginning of data from that station


histWeatherWTD = locationName+".WTD"
stationMetadata = locationName+".CLI"



# ----------------------------------------------------------------------------------------

#User input parameters for running weather generation for getting weather scenario



#Step 2: execute EstimatePrm program
#   Input argument CLI file, WTD file
#   Output PRM file



#   Prepare blank files
seasonalForecast = locationName+".MTH"
paramOutput = locationName+".PRM"
#   Filename will be named as first four characters of CLI filename

os.system(r"./EstimatePrm " +stationMetadata +" " +histWeatherWTD)
print("running: ")
print("./EstimatePrm " +stationMetadata +" " +histWeatherWTD)

#Step 3: execute genMth program
#   Input argument startYear, startMonth, stopYear, stopMonth, outputfile
#   Output MTH file
os.system(r"./genMth " +startScenarioYear +" " +startScenarioMonth+" " +stopScenarioYear +" " +stopScenarioMonth + " " + ">" + " " +seasonalForecast)
print("running: ")
print("./genMth " +startScenarioYear +" " +startScenarioMonth+" " +stopScenarioYear +" " +stopScenarioMonth + " " + ">" + " " +seasonalForecast)

#Step 4: execute Disag program
#   Input argument PRM file, MTH file, number of scenario
#   Output
os.system(r"./Disag " +paramOutput +" " +seasonalForecast +" " +numScenario)
print("running: ")
print("./Disag " +paramOutput +" " +seasonalForecast +" " +numScenario)

print("DONE FOR STEP 4")
# smoothing step of data between month and month by monthlyTrend2WTD

#Step 5: monthly smoothing and following by snow adjustment
# Create directory for keeping adjusted files
adjWTDDir = workingDir+"adjWTD/"
os.mkdir(adjWTDDir)

adjSnowDir = workingDir+"adjSnow/"
os.mkdir(adjSnowDir)

totalRun = int(numScenario)+1

for i in range(1, totalRun):
        formatNum = '%04d' %i
        #monthly Trend adjustment
        os.system(r"./monthlyTrend2WTD.a " +paramOutput +" " +locationName+formatNum+".WTD" +" " +adjWTDDir+locationName+formatNum+".WTD")
        print("./monthlyTrend2WTD.a " +paramOutput +" " +locationName+"000"+str(i)+".WTD" +" " +adjWTDDir+locationName+formatNum+".WTD")
        #snow adjustment
        os.system(r"./adjustWTD4Snow.a " +adjWTDDir+locationName+formatNum+".WTD" +" " +adjSnowDir+locationName+formatNum+".WTD")
        print("./adjustWTD4Snow.a " +adjWTDDir+locationName+formatNum+".WTD" +" " +adjSnowDir+locationName+formatNum+".WTD")