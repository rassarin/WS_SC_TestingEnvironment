/*
	this program generate a parameter file to be read by predict_WTD written by Eunjin

	written by K.Honda 2 Jan 2016

*/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define	PRGNAME	"genPredictWTDparam"

void usage()
{
	fprintf(stderr,
	"This program generates a parameter file to be read by predict_WTD written by Eunjin\n"
	" Written by K.Honda 2016-01-02\n");
	fprintf(stderr, 
		"usage: " PRGNAME " stationNameIn4Char simulationStartYear simulationStartDOY simulationEndYear simulationEndDOY preditionStartYear predictionStartMonth predictionEndYear predictionEndMonth numberOfRealization belowNormal(0-100) nearNormal(0-100) aboveNormal(0-100) targetFlag simulationMode workingDirectory\n"

		"\n"
		"\ttargetFlag is a Flag for target forecast (Rainfall amount, frequency, intensity)\n"
		"\te.g. combination of frequency and intensity(1/0=select/no-select)=>011\n\n"
		"\tSimulation mode should be hindercast(1) or forecst(0)\n"
		"\tIf working directory name includes spaces then directory name should be quoted\n"
		"\n"
		"\te.g.\n"
		"\t" PRGNAME " MEMU 2012 250 2013 180 2012 11 2013 1 100 33 34 33 100 0 '/Users/WorkSpace'\n"
		);
}
main( int argc, char **argv )
{
	char	*station;
	int	simulationStartYear, simulationStartDOY, simulationEndYear, simulationEndDOY;
	int	predictionStartYear, predictionStartMonth, predictionEndYear, predictionEndMonth;
	int	numberOfRealization;
	int	belowNormal, nearNormal, aboveNormal;
	int	targetFlag;
	int	simulationMode;
	char	*workingDir;

	int	err = 0;

	int	targetFlag1, targetFlag2, targetFlag3;

	if( argc != 17 ){
		usage();
		exit(1);
	}

	station = argv[1];

	simulationStartYear	= atoi( argv[2] );
	simulationStartDOY	= atoi( argv[3] );
	simulationEndYear	= atoi( argv[4] );
	simulationEndDOY	= atoi( argv[5] );

	predictionStartYear	= atoi( argv[6] );
	predictionStartMonth	= atoi( argv[7] );
	predictionEndYear	= atoi( argv[8] );
	predictionEndMonth	= atoi( argv[9] );

	numberOfRealization	= atoi( argv[10] );

	belowNormal		= atoi( argv[11] );
	nearNormal		= atoi( argv[12] );
	aboveNormal		= atoi( argv[13] );

	targetFlag		= atoi( argv[14] );
	simulationMode		= atoi( argv[15] );

	workingDir		= argv[16];

	//printf("argv[16] = [%s]\n", workingDir);
	//exit(1);

	if( strlen( station ) != 4 ){
		fprintf(stderr, PRGNAME ": station name must be 4 character string\n");
		err += 1;

	}
	if( simulationStartYear > simulationEndYear  ){
		fprintf(stderr, PRGNAME ": simulationEndYear is earlier than simlationStartyear %d %d\n", simulationStartYear, simulationEndYear);
		err += 1;
	}
	if( simulationStartDOY < 1 || simulationStartDOY > 366  ){
		fprintf(stderr, PRGNAME ": simulationStartDOY is out of rage %d\n", simulationStartDOY);
		err += 1;
	}
	if( simulationEndDOY < 1 || simulationEndDOY > 366  ){
		fprintf(stderr, PRGNAME ": simulationEndDOY is out of rage %d\n", simulationEndDOY);
		err += 1;
	}
	if( simulationStartYear*1000+simulationStartDOY >= simulationEndYear*1000+simulationEndDOY  ){
		fprintf(stderr, PRGNAME ": simulation End Date is earlier than Start Date %d %d\n",
	simulationStartYear*1000+simulationStartDOY, simulationEndYear*1000+simulationEndDOY  );
		err += 1;
	}

	if( predictionStartYear > predictionEndYear  ){
		fprintf(stderr, PRGNAME ": predictionEndYear is earlier than predictionStartyear %d %d\n", predictionStartYear, predictionEndYear);
		err += 1;
	}
	if( predictionStartMonth < 1 || predictionStartMonth > 12  ){
		fprintf(stderr, PRGNAME ": predictionStartMonth is out of rage %d\n", predictionStartMonth);
		err += 1;
	}
	if( predictionEndMonth < 1 || predictionEndMonth > 12  ){
		fprintf(stderr, PRGNAME ": predictionEndMonth is out of rage %d\n", predictionEndMonth);
		err += 1;
	}
	if( predictionStartYear*100+predictionStartMonth >= predictionEndYear*100+predictionEndMonth  ){
		fprintf(stderr, PRGNAME ": prediction End Date is earlier than Start Date %d %d\n",
	predictionStartYear*100+predictionStartMonth, predictionEndYear*100+predictionEndMonth  );
		err += 1;
	}

	if( numberOfRealization < 1 ){
		fprintf(stderr, PRGNAME ": numberOfRealization must be more than 0 %d\n", numberOfRealization);
		err += 1;
	}
	if( belowNormal+nearNormal+aboveNormal != 100 ){
		fprintf(stderr, PRGNAME ": sum of below, near and above normal must be 100. %d %d %d\n", belowNormal, nearNormal, aboveNormal );
		err += 1;
	}

	targetFlag1 = (targetFlag/100) % 10;
	if( targetFlag1 != 0 && targetFlag1 != 1 ){
		fprintf(stderr, PRGNAME ": targetFlag for rainfall amount must be 0 or 1 %d\n", targetFlag );
		err += 1;
	}
	targetFlag2 = (targetFlag/10) % 10;
	if( targetFlag2 != 0 && targetFlag2 != 1 ){
		fprintf(stderr, PRGNAME ": targetFlag for rainfall frequency must be 0 or 1 %d\n", targetFlag );
		err += 1;
	}
	targetFlag3 = targetFlag % 10;
	if( targetFlag3 != 0 && targetFlag3 != 1 ){
		fprintf(stderr, PRGNAME ": targetFlag for rainfall intensity must be 0 or 1 %d\n", targetFlag );
		err += 1;
	}
	if( targetFlag1 + targetFlag2 + targetFlag3 < 1 ){
		fprintf(stderr, PRGNAME ": targetFlag indicate at least one %d\n", targetFlag );
		err += 1;
	}
	

	if( simulationMode != 0 && simulationMode !=1 ){
		fprintf(stderr, PRGNAME ": simulationMode must be 0 or 1 %d\n", simulationMode );
		err += 1;
	}

	if( err ){
		fprintf( stderr, PRGNAME ": error count %d, exit\n", err);
		exit(1);
	}

	printf(
"!Station Information\n"
"Station:  %4s\n"
"!\n"
"!Simulation horizon\n"
"StartYear:                 %4.4d\n"
"StartDayOfYear(3digit):    %d\n"
"EndYear:                   %4.4d\n"
"EndDayOfYear:              %d\n"
"!\n"
"!Prediction horizon\n"
"StartYear:                 %4.4d\n"
"StartMonth:                 %d\n"
"EndYear:                   %4.4d\n"
"EndMonth:                   %d\n"
"!\n"
"!Number of Realizations - Weather genertions\n"
"nRealz:                      %d\n"
"!\n"
"Seasonal_climate_forecasts:\n"
"Below_Normal:           %d\n"
"Near_Normal:            %d\n"
"Above_Normal:           %d\n"
"!\n"
"!Flag for target forecast (Rainfall amount, frequency, intensity)\n"
"!e.g. combination of frequency and intensity(1/0=select/no-select)=>011\n"
"Flag:                      %3.3d\n"
"!\n"
"!Simulation mode (hindercast(1) or forecst(0)?)\n"
"mode:                      %d\n"
"!\n"
"!Working directory where *.WTD, *.CLI can be found\n"
"Directory: %s\n"
	,	station
	,	simulationStartYear, simulationStartDOY, simulationEndYear, simulationEndDOY
	,	predictionStartYear, predictionStartMonth, predictionEndYear, predictionEndMonth
	,	numberOfRealization
	,	belowNormal, nearNormal, aboveNormal
	,	targetFlag
	,	simulationMode
	,	workingDir
);
	return 0;

}

