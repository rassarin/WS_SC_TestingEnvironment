!Author: Amor VM Ines
!Institute: IRI-Columbia University
!Date: 9/Aug/2004
!Remark: More efficient than YieldParse.exe

subroutine ParseSubstring(inf)
!substring will be an argument here for portability

!real(8),allocatable   :: y_value (:) !///if you need to save data in buffer///
!save
character(len=300)	  :: line
integer               :: iost,i,j,result1,posit,inf, jump

assign 3000 to jump  

open(unit=14,file='YIELD.txt',status='unknown',access='sequential',action='readwrite',iostat=iost)
  if(iost .gt. 0)then
     write(6,'(a,1x,a,/)') 'ERROR, parser cannot access the file: YIELD.txt'
  stop
  endif
rewind(inf)

!--- this several reads allow the subroutine to step to the exact 
!--- data line in DSSAT output *.MZS
	  read(inf,'(A)',iostat=iost)line
		if (iost .lt. 0) goto jump
	  read(inf,'(A)',iostat=iost)line
		if (iost .lt. 0) goto jump
	  read(inf,'(A)',iostat=iost)line
		if (iost .lt. 0) goto jump
	  read(inf,'(A)',iostat=iost)line
		if (iost .lt. 0) goto jump
!--- it jumps to line containing data

!checks the position of substring(HWAH)
   result1=index(line(1:300),'HWAH')
!   posit=result1 !first position of data in line(:)  
   posit=result1-1 !first position of data in line(:)  !result1-1 to accomodate ##,### yield 4/9/2010
! Reading of the lines containing data 
i=1
do while(.not. eof(inf))
	read(inf,'(A)',iostat=iost)line
	if ((iost .lt. 0) .or. line == ' ') then
	  goto jump
    else
!      write(11,*) Trim(line(posit:posit+len('HWAH')-1))
      write(14,*) Trim(line(posit:posit+len('HWAH')))  !HWAH-1 to accomodate ##,### yield 4/9/2010
!      write(6,*) Trim(line(posit:posit+len('HWAH')))  !HWAH-1 to accomodate ##,### yield 4/9/2010

    endif
	i=i+1
enddo
j=i-1 !no. of data lines

!report no. of data
write(6,'(a,1x,i5)') 'Total # of data:',j

!///if you need to save data in buffer///
!/// uncomment these lines ////
!rewind(11)
!if(.not. allocated(y_value)) allocate (y_value(j))
!do i=1,j 
!  read(11,*) y_value(i)
!enddo
!do i=1,j !///not necessary/// 
!  write(6,'(f8.2)') y_value(i)
!enddo !///not necessary///
!deallocate (y_value)
!//// uncomment above ////

3000  close (14,status='keep')
return
endsubroutine ParseSubstring
