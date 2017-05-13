__author__ = 'RassarinPro'
# Generation Date: 4 Jan 2016
# Scenario 7 PredictWTD WG is used in this scenario. Seasonal forecast projection is required as input parameter.
# All input pamameters are in param_WTD.txt file

#   Input
#       param_WTD.txt parameter file
#       CLI file ( This file will be returned from historical weather service (Tesla) )
#       WTD file ( This file will be returned from historical weather service (Tesla) )
#       MTH file ( is filled with -99.0 meaning do not concern about seasonal forecast )
#           Allow user to input startYear startMonth stopYear stopMonth of scenario
#           genMth is used for generating MTH file
#   Related Program
#       seasonalProjWGen is a combination of Disag and EstimatePrm
#           EstimatePrm is used to generate PRM file for inputting to Disas program
#           Disag is used to generate weather scenarios
#       genPredictWTDparam is a program for generating param_WTD.txt file
#   Final result
#       WTDE file for weather scenario. File name will be same as the first four characters PRM file

# weatherScenarioComponentPATH = '/Users/RassarinPro/Documents/Workspace/WeatherGen/WS_SC_TestingEnvironment/'

import os


locationName = "MEMU"
weatherExtension = "WTDE"


workingDir = '/Users/RassarinPro/Documents/Workspace/WeatherGen/WS_SC_TestingEnvironment/PredictWTD-WG'
#User input parameters for querying historical weather data
#   Parameter for generating MTH file. It is a time window of weather scenario
# 42.900  143.050
targetLatitude = "42.901"
targetLongitude = "143.051"
# simulation horizon
startYearSIM = "2012"
startDOYSIM = "250"
endYearSIM = "2013"
endDOYSIM = "180"
# prediction horizon
startYearPredict = "2012"
startMonthPredict = "11"
endYearPredict = "2013"
endMonthPredict = "1"

numScenario = "10"

# seasonal climate forecast
BN = "33"
NN = "34"
AN = "33"

flagForecast = "100"

simMode = "0"

# Directory for outputing weather scenarios
outputDir = './working'
wthDir = './wthDir'

paramFile = "param_WTD.txt"



#Step 1: query historical weather data
# call tesla service for getting historical weather data (WTD) and weather station metadata (CLI)
# start from the beginning of available data in the station up to present

# Default of starting date is beginning of data from that station
# Default of ending date is beginning of data from that station


histWeatherWTD = locationName+".WTD"
stationMetadata = locationName+".CLI"

# These 2 files must be in outputDir

#Step 2: generate param_WTD.txt
#   Input argument CLI file, WTD file
#   Output param_WTD.txt file

os.system(r"./genPredictWTDparam " +locationName +" "+ startYearSIM +" " + startDOYSIM +" " + endYearSIM +" " + endDOYSIM +" " + startYearPredict +" " + startMonthPredict + " " + endYearPredict + " " + endMonthPredict + " " + numScenario + " " + BN + " " + NN + " " + AN + " " + flagForecast + " " + simMode + " " + outputDir + " " + ">" + " " + paramFile)
print("generating: parameter file ")
print("./genPredictWTDparam " +locationName +" "+ startYearSIM +" " + startDOYSIM +" " + endYearSIM +" " + endDOYSIM +" " + startYearPredict +" " + startMonthPredict + " " + endYearPredict + " " + endMonthPredict + " " + numScenario + " " + BN + " " + NN + " " + AN + " " + flagForecast + " " + simMode + " " + outputDir + " " + ">" + " " + paramFile)



#Step 3: execute predictWTD weather generator which is under seasonalProjWGen
#   Input paramFile
#   Weather Scenarios in outputDir
os.system(r"./seasonalProjWGen " + paramFile)
print("running weather generator: ")
print("./seasonalProjWGen " + paramFile)
