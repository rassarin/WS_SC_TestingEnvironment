    !Eunjin Han
    !5/2/2014
    !Modified Amor's FResampler_main.f90
    !to generate *.MTH from seasonal forecast with Below_Normal, Near_Normal, Above_normal values
    !=======================================
    !Purpose: FResampler is a program that bootstraps historical records to match climate forecasts
    !Author: Amor V.M. Ines
    !Institute: IRI-Columbia University, NY
    !Date: 6/17/2013
    subroutine Dynamic_MTH(target_cdf,count)
    !
    use ModuleGEN
    IMPLICIT NONE
    !EJ
    integer:: sizeR, nMonth, m_count, numyear_2,n_tercile1,n_tercile2,n_day,obs_mnt_n !EJ
    real:: cdf,temp_cdf,s_fcst_rain,difference1,difference2 !EJ
    real:: avg_rain(12) !EJ
    real:: num_rain(12) !EJ
    character(len=6)::temp_char !EJ
    real,allocatable:: sumSeason_2(:), iyear_2(:),prop_rain(:) !EJ
    real,allocatable:: s_monthrain(:),s_numrain(:)!rain and RNum for target season from .PRM
    real,allocatable:: freq_clim(:),int_clim(:)!frequency and intensity for target season from .PRM (climatology)
    real,allocatable:: fcst_freq(:),fcst_int(:),fcst_rain(:)!frequency and intensity for forecast
    real,allocatable:: fcst_cdf(:),fcst_pdf(:)
    integer:: i,j,k,year1,year2,numyear,iost
    integer:: yeardoy,nyear,year,yearnot,doy,day,month,fnum
    real:: israd,itmax,itmin,irain
    real,allocatable:: rain(:,:,:), srad(:,:,:), tmin(:,:,:), tmax(:,:,:),sumMonth(:),sumSeason(:),sortSeason(:),sortSeason_temp(:)
    integer, allocatable:: iyear(:),sortYear(:),sortYear_temp(:)
    character(len=32):: line
    character(len=80):: line1
    real :: target_cdf   !EJ(1/13/2015) to change "target" in the FCST CDF (e.g., can be 10%, 20%, 50% etc.)
    integer :: count  !EJ(1/13/2015)
    character(len=8) :: fmt ! format descriptor  !EJ(1/13/2015)
    character(len=8) :: temp_str
    integer(kind=2):: results,delfilesQQ
    integer :: n_tercile

    !for the command line
    integer(kind=2)     :: status

    !to write .MTH
    integer:: w_year
    character(len=45) :: format_num,format1,format2,format3,format4,format5,format6
    integer, dimension(12):: w_month
    real, dimension(2,12):: w_srad,w_tmax,w_tmin,w_rain,w_pw,w_mui
    data w_month/1,2,3,4,5,6,7,8,9,10,11,12/

    !EJ:
    !Find starting year of the available historical data


    !EJ: opening *.WTD file to calculate seasonal climatology
    open(unit=10,file=trim(stationName)//'.WTD',status='old',iostat=iost)
    write(6,'(a,1x,a)')'Calculating seasonal climatology from :',trim(sim_dir)//'/'//trim(stationName)//'.WTD'
    !fnum=10; call Errflg(fnum,iost,stationName,fname0,expName)
    !reads header from motherWTD file, get header
    read(10,'(a)',iostat=iost)line1 !header
    read(10,'(a)',iostat=iost)line1 !first record
    rewind(10)
    close(10)

    temp_char=line1(1:4)
    !Convert char to int
    !read(temp_char(1:4),'(i)') year1 !first recorded year in historical climate data
    ! KH: i->i4
    read(temp_char(1:4),'(i4)') year1 !first recorded year in historical climate data
    !!!!***Need to check!
    year2=forecastYear !last recorded(available) year in historical climate data

    nyear=year2-year1 + 1 + 1 ! +1 is a buffer!will be dynamic

    allocate(rain(nyear,12,31))
    allocate(tmin(nyear,12,31))
    allocate(tmax(nyear,12,31))
    allocate(srad(nyear,12,31))
    allocate(iyear(nyear))
    allocate(sumMonth(nyear*12)) !EJ
    allocate(sumSeason(nyear))

    !!!!!****************
    !EJ (1/13/2015)
    !Delete *.MTH from previous run
    ! KH:
    !results=delfilesQQ(trim(stationName)//'.MTH')
    results=system('rm '//trim(sim_dir)//'/'//trim(stationName)//'.MTH')

    !initialize variables
    print *, 'Dynamic_MTH: Initializing variable'
    rain(:,:,:)=-99.
    tmin(:,:,:)=-99.
    tmax(:,:,:)=-99.
    srad(:,:,:)=-99.
    iyear=-99
    yearnot=-1800
    !KH
    !sortSeason(:)=-99.
    print *, 'Dynamic_MTH: Initializing variable end'
    !sortYear(:)=-99
    sumMonth(:)=-99.
    sumSeason(:)=0. !EJ

    write(6,'(a)')'Reading *.WTD, pls wait...'

    !----------
    !***
    !opening file
    open(unit=10,file=trim(sim_dir)//'/'//trim(stationName)//'.WTD')

    read(10,*,iostat=iost) line !reads header
    !print*,'iost:',iost;pause
    if(iost .lt. 0)then
        write(6,300) 'ERROR, parser cannot find/read/process the file:',trim(stationName)//'.WTD'
        stop
    endif
    !***
    i=0 !index for year
    !MainREAD: DO WHILE(.not. EOF(10))
    ! KH: Change of linux
    MainREAD: DO WHILE(.true.)

        !read(10,*)yeardoy,israd,itmax,itmin,irain
	! KH: use iostat
        read(10,*, iostat = iost )yeardoy,israd,itmax,itmin,irain
	if( is_iostat_end(iost)) exit
        doy=mod(yeardoy,1000) !determines day of year
        year=floor(float(yeardoy)/1000.) !determines year
        !test leapyear
        call leapyear(year,leapflag)
        !what month? 1-12
        call doytest(leapflag,month,doy)
        !what day? 1-31
        call convert_doy_day(day,doy,month,leapflag)

        IF(year .ne. yearnot)THEN
            i=i+1 !year 1
            yearnot=year
        ENDIF

        !EJ: Read historical data before starting forecast season
        if(year .eq. forecastYear .AND. month .eq. fbnMonth) exit

        !Archive data in 3D-arrays
        rain(i,month,day)=irain
        tmin(i,month,day)=itmin
        tmax(i,month,day)=itmax
        srad(i,month,day)=israd
        iyear(i)=year

        !EJ
        obs_mnt_n=month  !last recorded month **assuming no missing data

    ENDDO MainREAD
    !------------
    write(6,'(a)')'Done reading *.WTD data in Dynamic_MTH....'
    close(10)

    numyear=i
    write(6,'(a,1x,i4)'),'No. of years:',numyear

    !CALCULATION PROCESS STARTS HERE....
    write(6,'(a)')'Calculating monthly rainfall statistics...'
    !EJ: Monthly statistics
    k=1
    m_count=1
    do i=1,numyear
        do j=1,12 !can be modified for target season only
            !start to sum daily rainfall only if the first day of month has valid data
            if(rain(i,j,1) .ne. -99.) then
                sumMonth(m_count)=0
                do k=1,31
                    !!!****assuming no missing daily data for this month
                    if (rain(i,j,k) .ne. -99.) then
                        sumMonth(m_count)=sumMonth(m_count)+rain(i,j,k)
                    endif
                enddo
            endif
            m_count=m_count+1
            !		sumMonth(k)=sum(rain(i,j,1:31),MASK=rain(i,j,1:31) .ne. -99.)
            !		k=k+1
        enddo
    enddo

    write(6,'(a)')'Calculating seasonal rainfall statistics for target season...'

    !EJ: nMonth=number of months for forecast season (e.g. M,A,M,J,J,A => 6 months)
    if (fenMonth > fbnMonth)then
        nMonth=fenMonth-fbnMonth+1
    else
        nMonth=fenMonth-fbnMonth+12+1
    endif


    !EJ: Seasonal statistics: target season
    !check if the first year has full season data (e.g. 6 months)
    if (sumMonth(fbnMonth) .ne. -99.)then
        i=fbnMonth
        k=1 !index for the first season data
    else ! if season of the first year is not complete, skip to the second recorded year
        i=fbnMonth+12
        k=2 !index for the first season data
        sumSeason(1)=-99.
    endif

    !EJ: calcualte sum of each season from the historical data
    DO WHILE (i <= numyear*12)
        do j= i, (i + nMonth-1) !EJ(11/10/2014) added "-1"
            !!!****assuming no missing monthly data
            if (sumMonth(i) .ne. -99.) then
                sumSeason(k)=sumSeason(k)+sumMonth(j)
            endif
        enddo
        k=k+1
        i=i+12  !jump to next season (year)
        !if last season is not complete
        if((i + nMonth) .GT. ((numyear-1)*12+obs_mnt_n)) then
            sumSeason(k)=-99.
        endif
    END DO

    !EJ: Since the first and/or last year may have incomplete season,
    ! need to check actual number of year for counting the number of season
    !1) count actual number of seasons
    numyear_2=0
    do i=1, numyear
        if (sumSeason(i) .ne. -99.) then
            numyear_2=numyear_2+1
        endif
    enddo

    allocate(sumSeason_2(numyear_2)) !after removing first and/or last incomplete season
    allocate(iyear_2(numyear_2)) !after removing first and/or last incomplete season
    allocate(sortSeason(numyear_2))
    ! KH added initialising sortSeason
    sortSeason(:)=-99.
    allocate(sortYear(numyear_2))
    allocate(sortYear_temp(numyear_2))
    allocate(sortSeason_temp(numyear_2))
    allocate(fcst_cdf(numyear_2))
    allocate(fcst_pdf(numyear_2))
    allocate(s_monthrain(nMonth))
    allocate(s_numrain(nMonth))
    allocate(fcst_rain(nMonth))
    allocate(prop_rain(nMonth))
    allocate(freq_clim(nMonth))
    allocate(int_clim(nMonth))
    allocate(fcst_freq(nMonth))
    allocate(fcst_int(nMonth))

    !2)remove "-99" from the list
    k=1
    do i=1, numyear
        if (sumSeason(i) .ne. -99.) then
            sumSeason_2(k)=sumSeason(i)
            iyear_2(k)=iyear(i)
            k=k+1
        endif
    enddo

    !-------------------
    !SORT SEASONAL, with YEAR
    !assign values
    sortSeason=sumSeason_2
    sortYear=iyear_2

    write(6,'(a)')'Sorting seasonal rainfall...'
    !sort
    do i=1,numyear_2-1
        do j=i+1,numyear_2,1
            if(sortSeason(i) .le. sortSeason(j))then
                sortSeason(i)=sortSeason(i)
                sortYear(i)=sortYear(i)
            else
                sortSeason_temp(i)=sortSeason(i)
                sortYear_temp(i)=sortYear(i)
                sortSeason(i)=sortSeason(j)
                sortYear(i)=sortYear(j)
                sortSeason(j)=sortSeason_temp(i)
                sortYear(j)=sortYear_temp(i)
            endif
        enddo
    enddo

    ! EJ: Choose a "Target" in the FCST CDF
    !(e.g. the median of total seasonal amount)
    cdf=0.
    !target_cdf=0.5  !EJ(9/29/2014) to change "target" in the FCST CDF (e.g., can be 10%, 20%, 50% etc.)
    n_tercile=floor(numyear_2/3.)
    if(mod(numyear_2,3) .eq. 1) then
        n_tercile1=floor(numyear_2/3.)
        n_tercile2=floor(numyear_2/3.)+1
    elseif(mod(numyear_2,3) .eq. 2) then
        n_tercile1=floor(numyear_2/3.)+1
        n_tercile2=floor(numyear_2/3.)+1
    else
        n_tercile1=floor(numyear_2/3.)
        n_tercile2=floor(numyear_2/3.)
    endif
    do i=1,numyear_2
        temp_cdf=cdf !sum of previous step
        if(i <= n_tercile1)then !below normal
            cdf=cdf+belowN*0.01/(n_tercile1)
            !if(i .eq. 1) then
            !    fcst_cdf(i)=belowN*0.01/(n_tercile1)     !forecast pdf
            !else
            !    fcst_cdf(i)=fcst_cdf(i-1)+belowN*0.01/(n_tercile1)     !forecast pdf
            !endif
        else if(i > n_tercile1 .AND. i <= (n_tercile1+n_tercile2)) then
            cdf=cdf+nearN*0.01/(n_tercile2)
            !if (cdf > 0.5) then
            !    difference1=0.5-temp_cdf
            !    difference2=cdf-0.5
            !    if(difference1 > difference2) then
            !        s_fcst_rain=sortSeason(i) !found "Target" in the FCST CDF
            !    else
            !        s_fcst_rain=sortSeason(i-1)!found "Target" in the FCST CDF
            !    endif
            !    exit
            !endif
        else
            cdf=cdf+aboveN*0.01/(numyear_2-n_tercile1-n_tercile2)
            !if (cdf > 0.5) then
            !    difference1=0.5-temp_cdf
            !    difference2=cdf-0.5
            !    if(difference1 > difference2) then
            !        s_fcst_rain=sortSeason(i) !found "Target" in the FCST CDF
            !    else
            !        s_fcst_rain=sortSeason(i-1)!found "Target" in the FCST CDF
            !    endif
            !    exit
            !endif
        endif
        if (cdf > target_cdf) then  !EJ(9/29/2014) to change "target" in the FCST CDF (e.g., can be 10%, 20%, 50% etc.)
            difference1 = target_cdf - temp_cdf
            difference2=cdf - target_cdf
            if(difference1 > difference2) then
                s_fcst_rain=sortSeason(i) !found "Target" in the FCST CDF
            else
                s_fcst_rain=sortSeason(i-1)!found "Target" in the FCST CDF
            endif
            exit
        endif
    end do

    !EJ(5/7/2014): to get full cdf of forecast for 5% or 95%
    fcst_cdf=-99.
    fcst_pdf=-99.
    do i=1,numyear_2
        if(i <= n_tercile1)then !below normal
            fcst_pdf(i)=belowN*0.01/(n_tercile1)     !forecast pdf
            if(i .eq. 1) then
                fcst_cdf(i)=belowN*0.01/(n_tercile1)     !forecast pdf
            else
                fcst_cdf(i)=fcst_cdf(i-1)+belowN*0.01/(n_tercile1)     !forecast pdf
            endif
        else if(i > n_tercile1 .AND. i <= (n_tercile1+n_tercile2)) then
            fcst_pdf(i)=nearN*0.01/(n_tercile2)
            fcst_cdf(i)=fcst_cdf(i-1)+nearN*0.01/(n_tercile2)     !forecast pdf
        else
            fcst_pdf(i)=aboveN*0.01/(numyear_2-n_tercile1-n_tercile2)
            fcst_cdf(i)=fcst_cdf(i-1)+aboveN*0.01/(numyear_2-n_tercile1-n_tercile2)     !forecast pdf
        endif
    end do

    !DEBUG PRINT IT
    fmt = '(I2.2)' ! an integer of width 5 with zeros at the left
    write (temp_str,fmt) count ! converting integer to string using a 'internal file'

    open(unit=96,file=trim(sim_dir)//'/'//'Summary-season'//trim(temp_str)//'.txt')
    !write(96,'(a)')'Sorted seasonal rainfall of target season and corresponding year'
    write(96,'(a)')'No.  Sorted_Seasonal_Rain  Year Forecast_pdf Forecast_CDF'
    !if J, JF in NDJ and DJF seasons are from next year...
    !write(96,'(a)')'If NDJ (J next year), DJF (JF next year) seasons, first year row is not included in the category'
    do i=1,numyear_2
        write(96,79) i,sortSeason(i),sortYear(i),fcst_pdf(i),fcst_cdf(i)
    enddo
    close(96)
79  format(i3,5x,f8.1,9x,i5,2x,f10.5,2x,f8.2)

    !EJ: In .PRM file calculate the proportion of rainfall
    !in each month of the target season
    !open *.PRM file
    i=1
    open(unit=11,file=trim(sim_dir)//'/'//trim(stationName)//'.PRM')
    !ReadPRM: DO WHILE(.not. EOF(11))
    ! KH: change for linux
    ReadPRM: DO WHILE(.true.)
        if (i <=19 ) then  !line for Rain start from #29
            read(11,*,iostat=iost) line !reads header
            ! KH:
	    if( is_iostat_end(iost)) exit
            !write(6,*) line
            if(iost .lt. 0)then
                write(6,300) 'ERROR, parser cannot find/read/process the file:',trim(stationName)//'.PRM'
                stop
            endif
        elseif (i .eq. 20) then
            !Read "Rain"in the *.PRM file
            read(11,*)temp_char,avg_rain  !avg_rain(12) !EJ
        elseif (i .eq. 21) then
            !Read "RNum" in the *.PRM file
            read(11,*)temp_char,num_rain
        else
            exit
        endif
        i=i+1
    ENDDO ReadPRM
    close (11)


    !EJ: extract rainfall for target season from climatology (*.CLI)
    k=1
    if(fenMonth > fbnMonth)then
        do i=fbnMonth,fenMonth
            s_monthrain(k)=avg_rain(i) !Rain for target season (e.g. 6 months)
            s_numrain(k)=num_rain(i) !RNum
            k=k+1
        enddo
    else  !e.g. NDJF
        do i=fbnMonth,(fenMonth+12)
            if(i > 12)then  !e.g. JF
                s_monthrain(k)=avg_rain(i-12)
                s_numrain(k)=num_rain(i-12)
            else
                s_monthrain(k)=avg_rain(i)
                s_numrain(k)=num_rain(i)
            endif
            k=k+1
        enddo
    endif

    !EJ: Calculate the proportion of rainfall in each month of the season
    !sum_rain=sum(s_monthrain)
    do i=1,nMonth
        prop_rain(i)=s_monthrain(i)/sum(s_monthrain)
    enddo

    !EJ: Compute rainfall frequency and intensity from CLIMATOLOGY
    !And calculate the forecast rainfall for each month
    k=1
    do i=fbnMonth,(fbnMonth+nMonth-1)
        if(i <=12) then
            month=i
        else
            month=i-12
        endif
        call day_count(leapflag,month,n_day) !out=> n_day
        freq_clim(k)=s_numrain(k)/real(n_day) !frequency(wet_day/total_day)
        int_clim(k)=s_monthrain(k)/s_numrain(k) !intensity (total rain (mm)/wet_day)
        fcst_rain(k)=prop_rain(k)*s_fcst_rain/real(n_day) !(mm/day)
        k=k+1
    enddo

    !EJ: Calculate frequency and intensity for the forecast rainfall
    do i=1,nMonth
        fcst_freq(i)=fcst_rain(i)/int_clim(i)
        fcst_int(i)=fcst_rain(i)/freq_clim(i)
    enddo

    !==============write .MTH==================================================================
    !initialize
    w_srad=-99.0; w_tmax=-99.0; w_tmin=-99.0; w_rain=-99.0; w_pw=-99.0; w_mui=-99.0
    format1= '(i4,1x,i2,3(1x,f5.1),1x,f5.2,2(1x,f5.1))'  !100
    format2= '(i4,1x,i2,4(1x,f5.1),2(1x,f5.2))'        !011
    format3= '(i4,1x,i2,4(1x,f5.1),1x,f5.2,1x,f5.1)'     !010
    format4= '(i4,1x,i2,3(1x,f5.1),2(1x,f5.2),1x,f5.1)'  !110
    format5= '(i4,1x,i2,3(1x,f5.1),1x,f5.2,1x,f5.1,1x,f5.2)' !101
    format6= '(i4,1x,i2,5(1x,f5.1),1x,f5.2)'             !001

    !(Rainfall amount, frequency, intensity) =>
    if(fcst_flag .eq. 100) then
        fcst_freq = -99.0
        fcst_int = -99.0
        format_num = format1 !'80'
    elseif(fcst_flag .eq. 11) then !011
        fcst_rain = -99.0
        format_num = format2 !'81'
    elseif(fcst_flag .eq. 10) then !010
        fcst_rain = -99.0
        fcst_int = -99.0
        format_num = format3 !'82'
    elseif(fcst_flag .eq. 110) then
        fcst_int = -99.0
        format_num = format4 ! '83'
    elseif(fcst_flag .eq. 101) then
        fcst_freq = -99.0
        format_num = format5 !'84'
    elseif(fcst_flag .eq. 1) then !001
        fcst_rain = -99.0
        fcst_freq = -99.0
        format_num = format6 ! '85'
    elseif(fcst_flag .eq. 111) then
        write(6,'(a)')'Three rainfall targets cannot be chosen at the same time!!'
    endif


    open(unit=13,file=trim(sim_dir)//'/'//trim(stationName)//'.MTH')
    !write header
    write(13,'(a)')'@ StYr  StMn  SpYr  SpMn'
    !EJ: We need data to cover whole simulation years (beginYear to endYear)
    write(13,77)beginYear,w_month(1),endYear,w_month(12)

    write(13,'(a)')'@ yr mo  srad  tmax  tmin  rain  pw   mui'

    k=1 !index for season forecast
    MainDo:do i=1,endYear-beginYear+1
        if(i==1)then
            w_year=beginYear
        else
            w_year=endYear
        endif
        j=1
        Do While (j <= 12) !month loop
            if(fenMonth > fbnMonth)then
                if((w_year .eq. forecastYear) .AND. (j .ge. fbnMonth) .AND. (j .le. fenMonth)) then !start to write forecasted rain
!                    write(13,trim(format_num)) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),fcst_rain(k),fcst_freq(k),fcst_int(k)
! KH: divide the line into 2
                    write(13,trim(format_num)) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),fcst_rain(k),fcst_freq(k),&
                    fcst_int(k)
                    k=k+1
                else
                    write(13,78) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),w_rain(i,j),w_pw(i,j),w_mui(i,j)
                endif
            else !e.g. NDJ
                if((w_year .eq. beginYear) .AND. (j .ge. fbnMonth)) then
!                    write(13,trim(format_num)) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),fcst_rain(k),fcst_freq(k),fcst_int(k)
! KH: divide the line into 2
                    write(13,trim(format_num)) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),fcst_rain(k),fcst_freq(k),&
                    fcst_int(k)
                    k=k+1
                elseif((w_year .eq. endYear) .AND. (j .le. fenMonth)) then
!                   write(13,trim(format_num)) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),fcst_rain(k),fcst_freq(k),fcst_int(k)
! KH: divide the line into 2
                    write(13,trim(format_num)) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),fcst_rain(k),fcst_freq(k),&
                    fcst_int(k)
                    k=k+1
                else
                    write(13,78) w_year,w_month(j),w_srad(i,j),w_tmax(i,j),w_tmin(i,j),w_rain(i,j),w_pw(i,j),w_mui(i,j)
                endif
            endif
            j=j+1
        Enddo
    Enddo MainDo



    close(13,status='keep')
77  format(2x,i4,4x,i2,2x,i4,2x,i4)
78  format(i4,1x,i2,6(1x,f5.1)) !default
    !79 format(f5.3,1x,i5,f8.5,f8.2)
    !80 format(i4,1x,i2,3(1x,f5.1),1x,f5.2,2(1x,f5.1))  !100
    !81 format(i4,1x,i2,4(1x,f5.1),2(1x,f5.2))          !011
    !82 format(i4,1x,i2,4(1x,f5.1),1x,f5.2,1x,f5.1)     !010
    !83 format(i4,1x,i2,3(1x,f5.1),2(1x,f5.2),1x,f5.1)  !110
    !84 format(i4,1x,i2,3(1x,f5.1),1x,f5.2,1x,f5.1,1x,f5.2) !101
    !85 format(i4,1x,i2,5(1x,f5.1),1x,f5.2)             !001


    !==============End of writing .MTH==================================================================

    !
    !enddo Main3
    !close(99)
    !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    !RELEASING MEMORY....
    deallocate(rain)
    deallocate(tmin)
    deallocate(tmax)
    deallocate(srad)
    deallocate(iyear)
    deallocate(sumMonth)
    deallocate(sumSeason)

    deallocate(sumSeason_2)
    deallocate(iyear_2)
    deallocate(sortSeason)
    deallocate(sortYear_temp)
    deallocate(sortSeason_temp)
    deallocate(s_monthrain)
    deallocate(s_numrain)
    deallocate(fcst_rain)
    deallocate(prop_rain)
    deallocate(freq_clim)
    deallocate(int_clim)
    deallocate(fcst_freq)
    deallocate(fcst_int)

300 format(a,1x,a,/)

    write(6,'(a)')'DONE'

    end subroutine Dynamic_MTH
