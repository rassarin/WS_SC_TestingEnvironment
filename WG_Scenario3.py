__author__ = 'RassarinPro'
# Generation Date: 10 Oct 2015
# Scenario 3 User want to request historical data based on time window and specific location

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

locationName = "MEMU"




#User input parameters for querying historical weather data
#   Parameter for generating MTH file. It is a time window of weather scenario
# 42.900  143.050
targetLatitude = "42.901"
targetLongitude = "143.051"

# Default of starting date can be beginning of data from that station
startHistoricalYear = ""
startHistoricalMonth = ""
startHistoricalDate = ""

# Default of ending date can be beginning of data from that station
endHistoricalYear = ""
endHistoricalMonth = ""
endHistoricalDate = ""


#Step 1: query historical weather data
# call tesla service for getting historical weather data (WTD) and weather station metadata (CLI)
# start from the beginning of available data in the station up to present
histWeatherWTD = locationName+".WTD"
stationMetadata = locationName+".CLI"



# ----------------------------------------------------------------------------------------

#User input parameters for running weather generation for getting weather scenario

startScenarioYear = "2014"
startScenarioMonth = "01"
stopScenarioYear = "2014"
stopScenarioMonth = "12"
numScenario = "10"

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
