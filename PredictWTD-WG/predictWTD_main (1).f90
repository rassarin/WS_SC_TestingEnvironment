    !DATE        : 1/12/2015
    ! Eunjin Han updated her previous "predictWTD_DyMTH" for Philippines CAMDT
    !Note: this code includes only the followings (NOT running dscsm040.exe B D4Batch.DV4)
    ! 1) run DisAg.ext creating *.WTDE
    !**NOTE**: This version uses 10 different target values (0.1 0.2 ....0.99) in the forecast CDF
    !  to create monthly target (*.MTH) (previous version used only median value)
    !**NOTE**: Running exportPHNT.exe is implemented in the subroutine RunPredWTD in the main CAMDT program
    !===================================================================================================!
    !PROGRAM NAME: predictWTD_DyMTH								                                        !									                                        !
    !DATE        : 5/2/2014
    !Modified Amor's predictWTD to incorporate dynamic_MTH (to create *.MTH from sensonal forecast)
    !In addition, there are some changes as follows:
    !1)Remove all existing *.WTD realizations (excluding original ****.WTD), *.WTDE, *.WTH,*.MTH
    !2)Create weather file (e.g. MEMU1102.WTH) for reference simulation  (?????)
    !3)for Dynamic_MTH, additional input (probability of BN, NN, AN) are required
    !4)Param.txt takes starting MONTH (instead of doy) for seasonal forecast
    !5? 				                                    !
    !===================================================================================================!
    !===================================================================================================!
    !PROGRAM NAME: predictWTD									                                        !
    !Version     : 0.1a											                                        !
    !DATE        : 7/14/2012										                                    !
    !===================================================================================================!
    !---------------------------------------------------------------------------------------------------
    !PURPOSE: to make multiple weather files combining observed weather until current day,
    !         the rest are forecasts/generated
    !		: And RUN simulations - extended capability
    !AUTHOR:  Amor VM Ines, IRI-Columbia University, NY
    !in collaboration with Chubu University, Japan (Dr. Kiyoshi HONDA)
    !and IHI Co., Japan
    !---------------------------------------------------------------------------------------------------
    !NOTES:
    !date of sowing happens in Sept previous year, emergence Oct previous year.
    !date of flowering happens in the next year, maturity happens in the next year.
    !www.agri.hro.or.jp/tokachi/sakukyo/index_saku_list.html
    !---------------------------------------------------------------------------------------------------
    !Algorithm:!
    !provide season or months to predict for the current year
    !extract base year (2 years, previous and current, until today) for attaching predicted weather data
    !make a MTH file for the simulations (new program)
    !Run Stochastic Disaggregation (assuming PRM file is now created) by CALLING DisAg.EXE
    !From the generated WTD files, attached them to the Base WTD file
    !Export to multiple WTH files, by CALLING ExportPHNT.EXE
    !Call DSSAT-CSM-Wheat Experiment by CALLING dssatCSM4
    !Analyze results....
    !Can be REPEATED
    !---------------------------------------------------------------------------------------------------
    program predictWTD

    use ModuleGEN !EJ: for common variable, use module
    ! use DFLIB
    ! use DFPORT
    IMPLICIT NONE

    integer(kind=4):: i,j,k,iost,sizeR,files,fnum,count,ii
    integer(kind=2):: results
    character(len=120):: SZ,fileName,argDisAg,argExportWTD,argCopyWTD,WTHdir,argDSSATrun,argDelWTD
    !KH: Add for RunQQ
    character(len=120):: runCmd 
    character(len=80):: line1,header,line2 !, !cut3
    character(len=7)::cut1,cut2,cut3,cut4   !EJ try
    character(len=3)::zero
    character(len=32),allocatable:: fname(:)
    character(len=32)   :: fname0 !for reading file name from base WTD file
    character(len=120):: argPRM
    character(len=4)::temp_yr1,temp_yr2

    !for the command line
    character(len=120)   :: fparam
    integer(kind=2)     :: n1,status
    character(len=120)   :: buf
    real :: target_cdf   !EJ(1/13/2015) to change "target" in the FCST CDF (e.g., can be 10%, 20%, 50% etc.)
    character(len=8) :: fmt ! format descriptor
    character(len=8) :: x1
    logical:: EXISTS
    character(len=80) :: file_name1,file_name2
    integer :: f_count  !to make consecutive file names (EJ: 5/7/2015)

    !initialize
    f_count=0

    !Retrieves command line using Module DFLIB.F90
    !n1=0
    !do while(n1 .le. 1)
    !    call getarg(n1,buf,status)
    !    !Error flag for command line
    !    if(status == -1)then
    !        write(6,*)'ERROR in the command line:'
    !        write(6,*)'USAGE: <Command> <file1>'
    !        write(6,*)'<file1>: Parameter file - where data for simulations are given'
    !        stop
    !    endif
    !    if(n1==1)fparam=buf
    !    n1=n1+1
    !enddo
    !----End command line syntax-----

    write(6,'(a)')'<!---------------------------!>'
    write(6,'(a)')'<! predictWTD version for PH-CAMDT  !>'
    write(6,'(a)')'<! All rights reserved 2015  !>'
    write(6,'(a,/)')'<!---------------------------!>'


    !EJ: for compling without any inputargument
    !buf='param_CTR2_S123.txt'
    !fparam=buf

    !KH: for compling without any inputargument
    buf='param_WTD.txt'
    fparam=buf


    !EJ(5/6/2014):
    call ReadInput(fparam)

	!print *, 'trim(sim_dir) =[', trim(sim_dir),']'
	!stop
    !Extracting a base WTD file, accessing the long-term historical data
    open(unit=10,file=trim(sim_dir)//'/'//trim(stationName)//'.WTD',status='old',iostat=iost)
    write(6,'(a,1x,a)')'Opening historical climate data:',trim(sim_dir)//'/'//trim(stationName)//'.WTD'
    fnum=10; call Errflg(fnum,iost,stationName,fname0,expName)

    !creates a base WTD file, preferable contains 2 years of daily data (year before, and current)
    open(unit=11,file=trim(sim_dir)//'/'//'BASE0000.WTD')
    write(6,'(a,1x,a)')'Creating base weather file:',trim(sim_dir)//'/'//'BASE0000.WTD'

    !reads header from motherWTD file, get header
    read(10,'(a)',iostat=iost)line1
    !write(6,'(a)') line1
    fnum=10; call Errflg(fnum,iost,stationName,fname0,expName)
    rewind(10) !go back

    !writes header to baseWTD
    header=trim(line1)
    write(11,'(a)')header

    !where to cookie cut?
    cut1=trim(bnYear)//trim(bnDayOfYear);write(6,'(a,1x,a)'),'beginDate:',trim(cut1)
    cut2=trim(enYear)//trim(enDayOfYear);write(6,'(a,1x,a)'),'endDate:',trim(cut2)

    call Jump_label(10,trim(cut1),80)!reading selected location, writing to baseWTD
    !KH: change do while for linux
    !do while(.not. EOF(10))
    do while(.true.)
        read(10,'(a)',iostat=iost)line1
	if( is_iostat_end(iost)) exit
        fnum=10; call Errflg(fnum,iost,stationName,fname0,expName)
        write(11,'(a)')line1
        if(line1(1:7)==trim(cut2))exit
    enddo

    !go back beginning of baseWTD file
    rewind(11)

    !again cookie-cutter
    cut3=trim(fbnYear)//trim(fbnDayOfYear);write(6,'(a,1x,a)'),'predictbeginDate:',trim(cut3)
    cut4=trim(fenYear)//trim(fenDayOfYear)

    !ADD ESTIMATE PRM AUTOMATIC HERE!!!! TrICKY .CLI!!!
    !Basically from here we can use Stocahstic Weather Generator
    !call INT2CHAR(nRealz,sizeOF(nRealz),SZ) !courtesy of NNDas, NASA-JPL.
    !!!
    close(10)
    close(11)
    !write(SZ,'(i4)') nRealz
    !write(6,*) trim(SZ)
    argPRM=trim(sim_dir)//'/'//trim(stationName)//'.CLI'//' '//trim(sim_dir)//'/'//trim(stationName)//'.WTD' !//' '//trim(SZ)

    ! KH: 
    !results=runQQ('EstimatePrm.exe',argPRM) !run Export tool
    runCmd = './EstimatePrm ' //argPRM
    write(*,*) 'Executing :', runCmd
    results=system(runCmd) !run Export tool

    !results2=systemQQ('EstimatePARAM.BAT') !run Export tool
    if(results .lt. 0)stop 'EstimatePRM.exe execution failed'
    !stop 'back from EstimatePrm'

    !===EJ(1/13/2015): Run DisAg.exe for 10 different target values with 100 (default) realization
    target_loop: do ii=1,10
        write(*,*) 'ii =', ii
        nRealz2=int(nRealz/10) !10*10 times = 100 realization
        !if(nRealz2 .lt. 1) stop 'Too small numbers of realizations!'
        if(nRealz2 .lt. 1) pause 'PredictWTD: Too small numbers of realizations (should be > 10)!'

        target_cdf=0.05 + 0.1*(ii-1) !target_cdf=0.05, 0.15, 0.25,0.35,...0.95

        !Consider making MTH file dynamically here
        write(*,*)'calling dynamic_MTH'
        call dynamic_MTH(target_cdf,ii)
        write(*,*)'back from dynamic_MTH'

        !Basically from here we can use Stocahstic Weather Generator
        call INT2CHAR(nRealz2,sizeOF(nRealz2),SZ) !courtesy of NNDas, NASA-JPL.
        ! KH Debuggin
        SZ=''
        write(*,*) 'nRealz2 =', nRealz2, 'sizeOF(nRealz2)=', sizeOF(nRealz2), 'SZ=',SZ, 'trim(SZ)=', trim(SZ)
        write(SZ,'(i4)') nRealz2 
        write(*,*) 'nRealz2 =', nRealz2, 'SZ=',SZ, 'trim(SZ)=', trim(SZ)
        argDisAg=trim(sim_dir)//'/'//trim(stationName)//'.PRM'//' '//trim(sim_dir)//'/'//trim(stationName)//'.MTH'//' '//trim(SZ)

        write(6,'(a)')'Executing Stochastic Weather Generator (DisAg), please wait...'
        write(6,'(a,1x,a,/)') 'DisAg.EXE', trim(argDisAg)
        ! KH: 
        ! results=runQQ('DisAg.exe',argDisAg)
        runCmd = './Disag '//argDisAg
        results=system(runCmd)
        if(results .lt. 0)stop 'DisAg.exe execution failed'

        !concatinate portion of base WTD file and predictions with all generated *.WTD
        allocate(fname(nRealz2)) !filanearrays
        FILE_NAME: do i=1,nRealz2
            !create a file name: e.g., UYEL0001.WTD
            call ZeroGen(i,sizeR,zero)
            call INT2CHAR(i,sizeR,SZ) !courtesy of NNDas, NASA-JPL.
            fileName=trim(stationName)//trim(zero)//trim(SZ)
            fname(i)=fileName
        enddo FILE_NAME

        !EJ: open again BASE**.WTD
        open(unit=11,file=trim(sim_dir)//'/'//'BASE0000.WTD')
        !reads header
        read(11,'(a)',iostat=iost)line1
        fnum=11; call Errflg(fnum,iost,stationName,fname0,expName)

        !open files for read/write then merge...
        write(6,'(/,a)')'Merging weather data, upto current date, and predictions for the rest of season...'
        MainDO_processing: do i=1,nRealz2
            write(6,'(a,1x,a)')'Processing predicted',trim(fname(i)(1:8))//'.WTD'
            open(unit=99+i,file=trim(sim_dir)//'/'//fname(i)(1:8)//'.WTD',iostat=iost) !predicted file
            fnum=99+i; call Errflg(fnum,iost,stationName,fname(i),expName)

            write(6,'(a,1x,a)')'Processing merged',trim(fname(i)(1:8))//'.WTDE'
            open(unit=999+i,file=trim(sim_dir)//'/'//fname(i)(1:8)//'.WTDE',iostat=iost) !merged file
            fnum=999+i; call Errflg(fnum,iost,stationName,fname(i),expName)
            rewind(11) !base WTD file

            read(11,'(a)',iostat=iost)line1 !advance, ready to read data
            fnum=11; call Errflg(fnum,iost,stationName,fname(i),expName)
            read(99+i,'(a)',iostat=iost)line2 !;print*,line2;pause
            fnum=99+i; call Errflg(fnum, iost, stationName, fname(i),expName)
            !write header
            write(999+i,'(a)')trim(header)

            ! Inner_DO_predict: do while (.not. EOF(11))
            Inner_DO_predict: do while (.true.)
                read(11,'(a)',iostat=iost)line1
		if( is_iostat_end(iost)) exit
                fnum=11; call Errflg(fnum,iost,stationName,fname(i),expName)
                !		if(line1(1:7) .eq. trim(cut3)) exit Inner_Do_predict
                if(line1(1:7)==trim(cut3))exit Inner_Do_predict
                write(999+i,'(a)')line1
            enddo Inner_DO_predict


            call Jump_label(99+i,trim(cut3),80)	!reading selected location, writing to baseWTD

            ! Inner_DO_merge: do while (.not. EOF(99+i))
            Inner_DO_merge: do while (.true.)
                read(99+i,'(a)',iostat=iost)line2
	        if( is_iostat_end(iost)) exit
                fnum=99+i; call Errflg(fnum,iost,stationName,fname(i),expName)
                write(999+i,'(a)')line2
            enddo Inner_DO_merge

            close(99+i);close(999+i)
        enddo MainDO_processing
        deallocate (fname)

        !Change *####.WTD so that they are in order for 100 realization
        fmt = '(I4.4)' ! an integer of width 5 with zeros at the left
        if(ii .eq. 1) then  !copy the original 10 *.WTDE to temporary files
            do j=1,nRealz2
                write (x1,fmt) j ! converting integer to string using a 'internal file'
                file_name1=trim(sim_dir)//'/'//trim(stationname)//trim(x1)//'.WTDE'
                file_name2=trim(sim_dir)//'/'//'temp'//trim(x1)//'.WTDE'

                !argCopyWTD='copy'//' '//trim(file_name1)//' '//trim(file_name2)
                ! results=systemQQ(argCopyWTD) !copy *.WTDE to temporary files
                ! KH: Change for Linux
                argCopyWTD='cp'//' '//trim(file_name1)//' '//trim(file_name2)
                !print *, 'predictWTD_main issuing command in 1 ', argCopyWTD
                results=system(argCopyWTD) !copy *.WTDE to temporary files
                if(results .lt. 0)stop 'copying *.WTDE files failed'

                !Delete existing *.WTD and *.WTDE created at this loop
                !argDelWTD='del'//' '//trim(file_name1)
                ! results=systemQQ(argDelWTD)
                ! KH: Change for Linux
                argDelWTD='rm'//' '//trim(file_name1)
                !print *, 'predictWTD_main issuing command in 1.1 ', argDelWTD
                results=system(argDelWTD)
                f_count=f_count+1  !to make consecutive file names (EJ: 5/7/2015)
            end do
        else
            do j=1,nRealz2
                write (x1,fmt) j ! converting integer to string using a 'internal file'
                file_name1=trim(sim_dir)//'/'//trim(stationname)//trim(x1)//'.WTDE'
                !  write (x1,fmt) j+(ii-1)*10 ! converting integer to string using a 'internal file'
                write (x1,fmt) (f_count+1) !to make consecutive file names (EJ: 5/7/2015)
                file_name2=trim(sim_dir)//'/'//trim(stationname)//trim(x1)//'.WTDE'

                !argCopyWTD='copy'//' '//trim(file_name1)//' '//trim(file_name2)
                ! results=systemQQ(argCopyWTD) !copy *.WTDE to temporary files
                ! KH: Change for Linux
                argCopyWTD='cp'//' '//trim(file_name1)//' '//trim(file_name2)
                !print *, 'predictWTD_main issuing command in 2 ', argCopyWTD
                results=system(argCopyWTD) !copy *.WTDE to temporary files
                if(results .lt. 0)stop 'copying *.WTDE files failed'
                !Delete existing *.WTD and *.WTDE created at this loop
                !argDelWTD='del'//' '//trim(file_name1)
                ! results=systemQQ(argDelWTD)
                ! KH: Change for Linux
                argDelWTD='rm'//' '//trim(file_name1)
                !print *, 'predictWTD_main issuing command in 2.1 ', argDelWTD
                results=system(argDelWTD)
                f_count=f_count+1  !to make consecutive file names (EJ: 5/7/2015)
            end do

        end if

    enddo target_loop

    !convert temporary *.WTDE to original order
    do j=1,nRealz2
        write (x1,fmt) j ! converting integer to string using a 'internal file'
        file_name1=trim(sim_dir)//'/'//trim(stationname)//trim(x1)//'.WTDE'
        file_name2=trim(sim_dir)//'/'//'temp'//trim(x1)//'.WTDE'

        !argCopyWTD='copy'//' '//trim(file_name2)//' '//trim(file_name1)
        !results=systemQQ(argCopyWTD) !copy *.WTDE to temporary files
        ! KH: Change for Linux
        argCopyWTD='cp'//' '//trim(file_name2)//' '//trim(file_name1)
        !print *, 'predictWTD_main issuing command in 3 ', argCopyWTD
        results=system(argCopyWTD) !copy *.WTDE to temporary files
        if(results .lt. 0)stop 'copying *.WTDE files failed'
        !Delete existing *.WTD and *.WTDE created at this loop
        !argDelWTD='del'//' '//trim(file_name2)
        ! results=systemQQ(argDelWTD)
        ! KH: Change for Linux
        argDelWTD='rm'//' '//trim(file_name2)
        !print *, 'predictWTD_main issuing command in 3.1 ', argDelWTD
        results=system(argDelWTD)
        ! results=system(argCopyWTD) !copy *.WTDE to temporary files
        ! KH: Change for Linux
        !print *, 'predictWTD_main issuing command in 3.2 ', argCopyWTD
        !results=system(argCopyWTD) !copy *.WTDE to temporary files
    end do
    !==========end of EJ(1/13/2015)




    close(10);close(11);close(12)
    !write(6,'(/,a)')'Processing completed...'
    end program predictWTD
    !End of program-------------------------------------------------------------------------------------
