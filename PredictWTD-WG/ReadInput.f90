    !DATE        : 1/15/2015 (by Eunjin Han at IRI)
    !Modified predictWTD_DyInput for PH-CAMDAT
    !=====================
    !DATE        : 9/11/2014 (by Eunjin Han at IRI)
    !Modified predictWTD_DyInput for Mirian's Spain field (maize and wheat)!
    !   which doesn't need to use several soil types
    !=====================
    !EJ modified Amor's ReadInput.f90
    !to take monthly input instead doy for forecasting period
    !!Date: 5/2/2014
    !=================
    !Author: Amor V.M. Ines
    !Institute: IRI-Columbia University, NY
    subroutine ReadInput(fparam)
    use ModuleGEN
    IMPLICIT NONE

    integer:: iost
    character(len=32):: temp
    character(len=200):: temp_line,temp_dir,temp_command !EJ(5/7/2015)
    character(len=50):: fparam
    integer:: fyear1,fyear2,fdoy1,fdoy2
    integer(kind=2):: results,delfilesQQ
    character(len=8) :: fmt ! format descriptor      !!!EJ(5/7/2015)
    integer :: sdoy1,sdoy2   !!!EJ(5/7/2015)

    !initialize
    Soil_ID='NULL'
    Soil_wgt=-99

    open(unit=9,file=fparam,iostat=iost)
    !open(unit=9,file=trim(fparam),iostat=iost)
    if(iost .gt. 0)then
        write(6,'(a,1x,a,/)') 'ERROR, parser cannot find the param.txt'
        stop
    endif
    !read(9,'(a)')temp
    rewind(9)
    read(9,'(a)',err=100)temp
    read(9,*,err=100)temp,stationName
    read(9,'(a)',err=100)temp
    read(9,'(a)',err=100)temp
    read(9,*,err=100)temp,bnYear;backspace(9)
    !
    read(9,*,err=100)temp,beginYear
    !
    read(9,*,err=100)temp,bnDayOfYear
    read(9,*,err=100)temp,enYear;backspace(9)
    !
    read(9,*,err=100)temp,endYear
    !
    read(9,*,err=100)temp,enDayOfYear
    read(9,'(a)',err=100)temp
    read(9,'(a)',err=100)temp
    read(9,*,err=100)temp,fbnYear;backspace(9)
    !
    read(9,*,err=100)temp,forecastYear
    read(9,*,err=100)temp,fbnMonth
    !read(9,*,err=100)temp,fbnDayOfYear
    read(9,*,err=100)temp,fenYear
    !read(9,*,err=100)temp,fenDayOfYear
    read(9,*,err=100)temp,fenMonth
    read(9,'(a)',err=100)temp
    read(9,'(a)',err=100)temp
    read(9,*,err=100)temp,nRealz
    read(9,'(a)',err=100)temp
    read(9,'(a)',err=100)temp
    read(9,*,err=100)temp,belowN
    read(9,*,err=100)temp,nearN
    read(9,*,err=100)temp,aboveN
    !EJ(5/6/2014)
    read(9,'(a)',err=100)temp_line
    read(9,'(a)',err=100)temp_line
    read(9,'(a)',err=100)temp_line
    read(9,*,err=100)temp,fcst_flag
    read(9,'(a)',err=100)temp
    read(9,'(a)',err=100)temp
    read(9,*,err=100)temp,sim_mode
    read(9,'(a)',err=100)temp
    read(9,'(a)',err=100)temp
    read(9,'(a11,a)',err=100)temp,sim_dir
    !write(*,'(1H ,a10,1H])') sim_dir
    !stop

    !EJ==========
    !Convert MONTH (in integer) to DOY (in char(3digit)) (e.g. October => 274)
    ! KH:
    !read(fbnYear(1:4),'(i)') fyear1 !char to int
    !read(fenYear(1:4),'(i)') fyear2 !char to int
    read(fbnYear(1:4),'(i4)') fyear1 !char to int
    read(fenYear(1:4),'(i4)') fyear2 !char to int
    call leapyear(fyear1,leapflag)
    call Month2doy_start(leapflag,fbnMonth,fdoy1) !out: fdoy1
    call Month2doy_end(leapflag,fenMonth,fdoy2) !out: fdoy2

    !convert integer(DOY) to char
    !write(fbnDayOfYear,'(i3)') fdoy1  !char to int
    !write(fenDayOfYear,'(i3)') fdoy2  !char to int
    !!!EJ(5/7/2015)
    fmt = '(I3.3)' ! an integer of width 3 with zeros at the left
    write (fbnDayOfYear,fmt) fdoy1 ! converting integer to string using a 'internal file'
    write (fenDayOfYear,fmt) fdoy2 ! converting integer to string using a 'internal file'
    !call INT2CHAR(fdoy1,3,fbnDayOfYear) !courtesy of NNDas, NASA-JPL.
    !call INT2CHAR(fdoy2,3,fenDayOfYear) !courtesy of NNDas, NASA-JPL.
    ! KH: change i -> i3
    !read(bnDayOfYear,'(i)') sdoy1 !char to int
    !read(enDayOfYear,'(i)') sdoy2 !char to int
    !read(bnDayOfYear,'(i)') sdoy1 !char to int
    !read(enDayOfYear,'(i)') sdoy2 !char to int
    read(bnDayOfYear,'(i3)') sdoy1 !char to int
    read(enDayOfYear,'(i3)') sdoy2 !char to int
    read(bnDayOfYear,'(i3)') sdoy1 !char to int
    read(enDayOfYear,'(i3)') sdoy2 !char to int
    write (bnDayOfYear,fmt) sdoy1 ! converting integer to string using a 'internal file'
    write (enDayOfYear,fmt) sdoy2 ! converting integer to string using a 'internal file'
    !EJ==============
    close(9)


    !!!!!****************
    !EJ (5/6/2014)
    !Delete all *.WTH and *WTD, *.WTDE files from previouis runs
    write(6,'(/,(a))')'Cleaning weather directory...'
    !temp_dir=trim(sim_dir)//'0*.WTH'
    !results=delfilesQQ(trim(sim_dir)//'\0*.WTH')
    write(*,*) 'perfoming: ','rm '//trim(sim_dir)//'/0*.WTH'
    results=system('rm '//trim(sim_dir)//'/0*.WTH')
    ! KH
    !results=delfilesQQ(trim(sim_dir)//'\*.WTDE')
    write(*,*) 'perfoming: ','rm '//trim(sim_dir)//'/*.WTDE'
    results=system('rm '//trim(sim_dir)//'/*.WTDE')

    !KH
    !temp_command=trim(sim_dir)//'\'//trim(stationName)//'0*.WTD'   !EJ(5/7/2015)
    temp_command='rm '//trim(sim_dir)//'/'//trim(stationName)//'0*.WTD'   !EJ(5/7/2015)
    ! KH:
    !results=delfilesQQ(trim(temp_command))
    write(*,*) 'perfoming: ',trim(temp_command)
    results=system(trim(temp_command))
    !results=delfilesQQ(trim(sim_dir)//trim(stationName)//'\00*.WTD')
    !results=delfilesQQ(trim(sim_dir)//'\*.OUT')
    !results=delfilesQQ(trim(sim_dir)//'\*.OSU')
    !results=delfilesQQ(trim(sim_dir)//'\yield.txt')
    ! KH:
    !results=delfilesQQ(trim(sim_dir)//'\BASE0000.WTD')
    ! KH:
    !results=delfilesQQ(trim(sim_dir)//'/BASE0000.WTD')
    write(*,*) 'perfoming: ', 'rm '//trim(sim_dir)//'/BASE0000.WTD'
    results=system('rm '//trim(sim_dir)//'/BASE0000.WTD')
    !c:\dssat4\weather
    !write(*,*) 'Hit a key to proceed'
    !read(*,*) temp


    return
100 Stop 'Error reading parameter file, please check...'
    end subroutine ReadInput

    !Example
    !!Station Information
    !stationName:               LERI
    !DSSATexperimentfile:       C:\IRI\predictWTD_DyInput_Mirian\predWTD_DyInput\predWTD_DyInput\LERI0001.MZX
    !!
    !!Simulation horizon
    !StartYear:                 2010
    !StartDayOfYear(3digit):    001
    !EndYear:                   2010
    !EndDayOfYear:              365
    !!
    !!Prediction horizon
    !StartYear:                 2010
    !StartMonth:                03
    !EndYear:                   2010
    !EndMonth:                  06
    !!
    !!Number of Realizations - Weather genertions
    !nRealz:                    100
    !!
    !Seasonal_climate_forecasts:
    !Below_Normal: 33
    !Near_Normal:  34
    !Above_Normal: 33
    !!
    !!Flag for target forecast (Rainfall amount, frequency, intensity)
    !!e.g. combination of frequency and intensity(1/0=select/no-select)=>011
    !Flag:                      011
    !!
    !!Simulation mode (hindercast(1) or forecst(0)?)
    !mode:                      1
    !!
    !!Working directory where DSSAT4 (or 4.5) is installed and weather or soil files can be found
    !Directory:                 C:\IRI\predictWTD_DyInput_Mirian\predWTD_DyInput\predWTD_DyInput
    !!
    !Crop_type:                 Maize
    !!
    !Planting_year:             2010
    !Planting_date:               90
