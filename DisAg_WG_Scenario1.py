__author__ = 'RassarinPro'
# Generation Date: 11 September 2015
# Updatged : 26 Jan 2016
# Scenario 1 Generating Weather Scenarios using DisAg weather generator
#   Description: User provides cli file, WTD file (historical), and MTH file
#   Input
#       CLI file ( is prepared by USER )
#       WTD file ( is prepared by USER )
#       MTH file ( is filled with -99.0 meaning do not concern about seasonal forecast )
#       PRM file is generated from EstimatePrm
#           Filename will be named as first four characters of CLI filename
#   Related Program
#       EstimatePrm is used to generate PRM file for inputting to Disas program
#       Disag is used to generate weather scenarios
#   Final result
#       WTD file of weather scenario. File name will be same as the first four characters PRM file

# weatherScenarioComponentPATH = '/Users/RassarinPro/Documents/Workspace/WeatherGen/WeatherScenarioServiceComponent/'

import os

# Service Parameters
# User provide CLI, WTD, MTH and number of scenario
stationName = "MEMU"
stationMetadata = stationName+".CLI"
histWeatherWTD = stationName+".WTD"
seasonalForecast = stationName+".MTH"
paramOutput = stationName+".PRM"
numScenario = "10"

#Step 1: execute EstimatePrm program
#   Input argument CLI file, WTD file
#   Output PRM file
os.system(r"./EstimatePrm " +stationMetadata +" " +histWeatherWTD)

#Step 2: execute Disag program
#   Input argument PRM file, MTH file, number of scenario
#   Output WTD file into working directory
#       stationName+ 4 digits of number in sequence. eq. MEMU0001.WTD
os.system(r"./Disag " +paramOutput +" " +seasonalForecast +" " +numScenario)