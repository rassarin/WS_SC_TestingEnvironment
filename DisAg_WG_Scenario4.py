__author__ = 'RassarinPro'
# Generation Date: 10 Oct 2015
# Modified: 26 Jan 2016
# Scenario 4 User want to request historical data based on time window and specific location
#   Description: User specify target area in lat and long, radius , historical weather time window and weather scenario time window
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
#   Final result
#       WTD file for weather scenario. File name will be same as the first four characters PRM file

# weatherScenarioComponentPATH = '/Users/RassarinPro/Documents/Workspace/WeatherGen/WeatherScenarioServiceComponent/'

import os

# Service Parameter
targetLatitude = "42.901"
targetLongitude = "143.051"
# radius distance in meter
radiusDistance = "1000"
# Default of starting date can be beginning of data from that station
startHistoricalYear = ""
startHistoricalMonth = ""
startHistoricalDate = ""
# Default of ending date can be latest data from that station
endHistoricalYear = ""
endHistoricalMonth = ""
endHistoricalDate = ""

startScenarioYear = "2014"
startScenarioMonth = "01"
stopScenarioYear = "2014"
stopScenarioMonth = "12"
numScenario = "10"

# assuming that
locationName = "MEMU"


#Step 1: call service for generating historical weather data and CLI file
# call tesla service for getting historical weather data (WTD) and weather station metadata (CLI)
# start from the beginning of available data in the station up to present
# generated WTD file
histWeatherWTD = locationName+".WTD"
# generate CLI file from weather station metadata
stationMetadata = locationName+".CLI"

# ----------------------------------------------------------------------------------------


#Step 2: execute EstimatePrm program
#   Input argument CLI file, WTD file
#   Output PRM file


#   Filename will be named as first four characters of CLI filename
paramOutput = locationName+".PRM"
os.system(r"./EstimatePrm " +stationMetadata +" " +histWeatherWTD)
print("running: ")
print("./EstimatePrm " +stationMetadata +" " +histWeatherWTD)

#Step 3: execute genMth program
#   Input argument startYear, startMonth, stopYear, stopMonth, outputfile
#   Output MTH file

#   Prepare blank files for
seasonalForecast = locationName+".MTH"
os.system(r"./genMth " +startScenarioYear +" " +startScenarioMonth+" " +stopScenarioYear +" " +stopScenarioMonth + " " + ">" + " " +seasonalForecast)
print("running: ")
print("./genMth " +startScenarioYear +" " +startScenarioMonth+" " +stopScenarioYear +" " +stopScenarioMonth + " " + ">" + " " +seasonalForecast)

#Step 4: execute Disag program
#   Input argument PRM file, MTH file, number of scenario
#   Output
os.system(r"./Disag " +paramOutput +" " +seasonalForecast +" " +numScenario)
print("running: ")
print("./Disag " +paramOutput +" " +seasonalForecast +" " +numScenario)
