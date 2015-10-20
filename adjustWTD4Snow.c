/*

	This program adjust .WTD weather file for DSSAT for under snow condition

*/

#define	PRGNAME	"adjustWTD4Snow"
//#define WINDOWS
#define VERBOSE

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#if defined (WINDOWS)
#include<malloc.h>
#endif

#include<time.h>

#include"utilHonda.h"
#include"cropUtil.h"


#define	MON1	12
#define	DAY1	 1	
#define	MON2	 3
#define	DAY2	31	
#define	SNOW_TEMP_MIN	-0.1
#define	SNOW_TEMP_MAX	 0.1
#define	SOLAR_REDUCTION	0.95

void usage( void )
{
	fprintf( stderr, "usage: " PRGNAME " INPUT_WTD Snow_Ajudsted_WTD_File\n" );
	fprintf( stderr, "\t e.g. " PRGNAME " MEMU.WTD MEMS.WTD\n");
	fprintf( stderr, "\t if INPUT and/or OUTPUT files are not specified, standard input and output are used\n");
	fprintf( stderr, "\tSnow adjusting period %d / %d to %d / %d (mm/dd)\n", MON1, DAY1, MON2, DAY2 );
	fprintf( stderr, "\tSnow adjusting adjusting to %lf(min) - %lf(max) celsius\n", SNOW_TEMP_MIN, SNOW_TEMP_MAX );
	fprintf( stderr, "\tSolar radiation reduction rate %lf\n", SOLAR_REDUCTION );
}

#define	BUFLEN 2048
#define	MAXPARM 24

#define	WTDEXT ".WTD"

int main( int argc, char *argv[] )
{

	int	mon1 = MON1;
	int	day1 = DAY1;
	int	mon2 = MON2;
	int	day2 = DAY2;
	double	snowTempMax = SNOW_TEMP_MAX;
	double	snowTempMin = SNOW_TEMP_MIN;
	double	solarReduction = SOLAR_REDUCTION;

	char buf[BUFLEN];
	char *parm[MAXPARM];
	int ntoken;

	char *wtdFileName1 = NULL;
	char *wtdFileName2 = NULL;

	FILE *wtdFp1 = stdin, *wtdFp2 = stdout;

	int	year, doy, doy1, doy2;
	double	srad, tmax, tmin, rain;

	if( argc > 3 ){
		usage();
		return 0; 
	}
	if( argc == 2 || argc == 3 ){
		wtdFileName1 = argv[1];
	}
	if( argc == 3 ){
		wtdFileName2 = argv[2];
	}


// Open WTD file for reading & writing
	if( wtdFileName1 ){
		wtdFp1 = fopen( wtdFileName1, "rt" );
		if( ! wtdFp1 ){
				fprintf(stderr, PRGNAME ": WTD file [%s] cannot be opened for reading: exit\n", wtdFileName1 );
				return 0;
		}
	}

	if( wtdFileName2 ){
		wtdFp2 = fopen( wtdFileName2, "wt" );
		if( ! wtdFp2 ){
				fprintf(stderr, PRGNAME ": WTD file [%s] cannot be opened for writing: exit\n", wtdFileName2 );
				return 0;
		}
	}


//	fprintf( wtdFp2, "@  DATE  SRAD  TMAX  TMIN  RAIN\n");

	while( fgets( buf, BUFLEN, wtdFp1 ) ){
		if( buf[0] == '@' ){
			fputs( buf, wtdFp2 );
		} else {
			ntoken = tokens( buf, parm, " \t,\n", MAXPARM );
			year = atoi ( parm[0] ) / 1000;
			doy =  atoi ( parm[0] )  - year * 1000;
			srad = atof( parm[1] );
			tmax = atof ( parm[2] );
			tmin = atof ( parm[3] );	
			rain = atof ( parm[4] );	

			doy1 = dayOfYear( year, mon1, day1 );
			doy2 = dayOfYear( year, mon2, day2 );

			if( doy <= doy2  || doy >= doy1 ){
				if( srad != atof( ND_WTD ) ){
					srad *= 1. - solarReduction;
				}
				if( tmax != atof( ND_WTD ) && tmax < snowTempMax){
					tmax = snowTempMax;	
				}
				if( tmin != atof( ND_WTD ) && tmin < snowTempMin){
					tmin = snowTempMin;	
				}
			}
			fprintf( wtdFp2, "%4.4d%3.3d", year, doy );

			if( ! WTDvalidData( parm[1] )  )
				fprintf( wtdFp2, "%6s", ND_WTD );
			else
				fprintf( wtdFp2, "%6.1lf", srad );

			if( ! WTDvalidData( parm[2] )  )
				fprintf( wtdFp2, "%6s", ND_WTD );
			else
				fprintf( wtdFp2, "%6.1lf", tmax);

			if( ! WTDvalidData( parm[3] )  )
				fprintf( wtdFp2, "%6s", ND_WTD );
			else
				fprintf( wtdFp2, "%6.1lf", tmin);

			if( ! WTDvalidData( parm[4] )  )
				fprintf( wtdFp2, "%6s", ND_WTD );
			else
				fprintf( wtdFp2, "%6.1lf", rain);

			fprintf( wtdFp2, "\n");
		}
	}
	fclose( wtdFp2 );
	fclose( wtdFp1 );

	return 1;
}
