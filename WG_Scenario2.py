__author__ = 'RassarinPro'
# Generation Date: 17 September 2015
# Scenario 2 Generating Weather Scenarios based on
#   Input
#       CLI file ( is prepared by USER )
#       WTD file ( is prepared by USER )
#       MTH file ( is filled with -99.0 meaning do not concern about seasonal forecast )
#           Allow user to input startYear startMonth stopYear stopMonth of scenario
#           genMth is used for generating MTH file
#       PRM file is generated from EstimatePrm
#           Filename will be named as first four characters of CLI filename
#   Related Program
#       EstimatePrm is used to generate PRM file for inputting to Disas program
#       Disag is used to generate weather scenarios
#       geMth is used to generate MTH file by receiving startMonth stopYear stopMonth from user
#   Final result
#       WTD file for weather scenario. File name will be same as the first four characters PRM file

# weatherScenarioComponentPATH = '/Users/RassarinPro/Documents/Workspace/WeatherGen/WeatherScenarioServiceComponent/'

import os

stationMetadata = "MEMU.CLI"
histWeatherWTD = "MEMU.WTD"
seasonalForecast = "MEMU.MTH"
paramOutput = "MEMU.PRM"
numScenario = "10"

#User input parameters
#   Parameter for generating MTH file. It is a time window of weather scenario
startYear = "2014"
startMonth = "01"
stopYear = "2014"
stopMonth = "12"

#Step 1: execute EstimatePrm program
#   Input argument CLI file, WTD file
#   Output PRM file
os.system(r"./EstimatePrm " +stationMetadata +" " +histWeatherWTD)
print("running: ")
print("./EstimatePrm " +stationMetadata +" " +histWeatherWTD)

#Step 2: execute genMth program
#   Input argument startYear, startMonth, stopYear, stopMonth, outputfile
#   Output MTH file
os.system(r"./genMth " +startYear +" " +startMonth+" " +stopYear +" " +stopMonth + " " + ">" + " " +seasonalForecast)
print("running: ")
print("./genMth " +startYear +" " +startMonth+" " +stopYear +" " +stopMonth + " " + ">" + " " +seasonalForecast)

#Step 3: execute Disag program
#   Input argument PRM file, MTH file, number of scenario
#   Output
os.system(r"./Disag " +paramOutput +" " +seasonalForecast +" " +numScenario)
print("running: ")
print("./Disag " +paramOutput +" " +seasonalForecast +" " +numScenario)
