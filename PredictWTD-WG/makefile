all: seasonalProjWGen genPredictWTDparam param_WTD.sample.txt

seasonalProjWGen: predictWTD_main.o ModuleGEN.o fileNamGenTool.o ReadInput.o Month2doy_start.o Month2doy_end.o leapyear.o Jump_Label.o INT2CHAR.o ERROR_flg.o Dynamic_MTH.o doytest.o day_count.o convert_day_doy.o Analin.o
	gfortran -o seasonalProjWGen predictWTD_main.o ModuleGEN.o fileNamGenTool.o ReadInput.o Month2doy_start.o Month2doy_end.o leapyear.o Jump_Label.o INT2CHAR.o ERROR_flg.o Dynamic_MTH.o doytest.o day_count.o convert_day_doy.o Analin.o

genPredictWTDparam: genPredictWTDparam.c
	gcc -o genPredictWTDparam genPredictWTDparam.c

param_WTD.sample.txt: genPredictWTDparam
	./genPredictWTDparam MEMU 2012 250 2013 180 2012 11 2013 1 100 33 34 33 100 0 '/Users/RassarinPro/Documents/Workspace/WeatherGen/predict_WTD/sample_data_MEMU' > param_WTD.sample.txt

predictWTD_main.o: predictWTD_main.f90 ModuleGEN.o
	gfortran -c predictWTD_main.f90
ModuleGEN.o: ModuleGEN.f90
	gfortran -c ModuleGEN.f90
fileNamGenTool.o: fileNamGenTool.f90
	gfortran -c fileNamGenTool.f90
ReadInput.o: ReadInput.f90
	gfortran -c ReadInput.f90
Month2doy_end.o: Month2doy_end.f90
	gfortran -c Month2doy_end.f90
Month2doy_start.o: Month2doy_start.f90
	gfortran -c Month2doy_start.f90
leapyear.o: leapyear.f90
	gfortran -c leapyear.f90
Jump_Label.o: Jump_Label.f90
	gfortran -c Jump_Label.f90
INT2CHAR.o: INT2CHAR.f90
	gfortran -c INT2CHAR.f90
ERROR_flg.o: ERROR_flg.f90
	gfortran -c ERROR_flg.f90
Dynamic_MTH.o: Dynamic_MTH.f90
	gfortran -c Dynamic_MTH.f90
doytest.o: doytest.f90
	gfortran -c doytest.f90
day_count.o: day_count.f90
	gfortran -c day_count.f90
convert_day_doy.o: convert_day_doy.f90
	gfortran -c convert_day_doy.f90
Analin.o: Analin.f90
	gfortran -c Analin.f90

clean:
	rm *.o
