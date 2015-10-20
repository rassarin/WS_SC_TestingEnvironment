startScenarioYear = 2011
startScenarioMonth = 3
stopScenarioYear = 2014
stopScenarioMonth = 12


nYearStartDOYbyMonth = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335]
lYearStartDOYbyMonth = [1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336]
nYearEndDOYbyMonth = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
lYearEndDOYbyMonth = [31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]


numYear = stopScenarioYear - startScenarioYear
numYear = numYear+1
countYear = numYear

print("number of year = ", numYear)

totalDaysYearList = []
for i in range(0,numYear):
    # Python program to check if the input year is a leap year or not
    print("i : ", i)
    if ((startScenarioYear+i) % 4) == 0:
       if ((startScenarioYear+i) % 100) == 0:
           if ((startScenarioYear+i) % 400) == 0:
               leapYear = 'Y'
               totalDaysYearList.append(366)
               print("1 input for: ", startScenarioYear+i)
               end_day = 366
           else:
               leapYear = 'N'
               totalDaysYearList.append(365)
               print("2 input for: ", startScenarioYear+i)
               end_day = 365
       else:
           leapYear = 'Y'
           totalDaysYearList.append(366)
           print("3 input for: ", startScenarioYear+i)
           end_day = 366
    else:
       leapYear = 'N'
       totalDaysYearList.append(365)
       print("4 input for: ", startScenarioYear+i)
       end_day = 365
    #================================================================
    if (i+1) == 1 and (i+1) == numYear:
        # for only 1 year of scenario
        if leapYear == 'Y':
            start_day = lYearStartDOYbyMonth[startScenarioMonth-1]
            end_day = lYearEndDOYbyMonth[stopScenarioMonth-1]

        else:
            start_day = nYearStartDOYbyMonth[startScenarioMonth-1]
            end_day = nYearStartDOYbyMonth[stopScenarioMonth-1]
        print("Only 1 year scenario : start DOY ", start_day, " end DOY : ", end_day)
    elif (i+1) == 1 and (i+1) != numYear:
        # for 1st year in many years of scenario
        if leapYear == 'Y':
            start_day = lYearStartDOYbyMonth[startScenarioMonth-1]
            end_day = lYearEndDOYbyMonth[11]
            print("DOY of starting month : ", start_day)
        else:
            start_day = nYearStartDOYbyMonth[startScenarioMonth-1]
            end_day = nYearStartDOYbyMonth[11]
        print(" 1 year scenario in many years : start DOY ", start_day, " end DOY : ", end_day)

    elif (i+1) != 1 and (i+1) != numYear:
        # in between
        if leapYear == 'Y':
            start_day = lYearStartDOYbyMonth[0]
            end_day = lYearEndDOYbyMonth[11]
            print("DOY of starting month : ", start_day)
        else:
            start_day = nYearStartDOYbyMonth[0]
            end_day = nYearStartDOYbyMonth[11]
        print("Year in between : start DOY ", start_day, " end DOY : ", end_day)
    else:
       # last year of many years scenario
        if leapYear == 'Y':
            start_day = lYearStartDOYbyMonth[0]
            end_day = lYearEndDOYbyMonth[stopScenarioMonth-1]
            print("DOY of starting month : ", start_day)
        else:
            start_day = nYearStartDOYbyMonth[0]
            end_day = nYearStartDOYbyMonth[stopScenarioMonth-1]
        print("Last year scenario : start DOY ", start_day, " end DOY : ", end_day)

for numofday in totalDaysYearList:
    print("num day in year: ",numofday)