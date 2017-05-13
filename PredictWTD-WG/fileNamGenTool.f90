subroutine ZeroGen(i,sizeR,zero)

integer(kind=4) :: i,sizeR
character(len=3) :: zero

	if(i .lt. 10)then
		sizeR=1;zero='000'
		elseif(i .le. 99 .and. i .ge. 10)then
			sizeR=2;zero='00'
		elseif (i .le. 999 .and. i .ge. 100)then
			sizeR=3;zero='0'
		else
			sizeR=4;zero=''
		write(6,'(a)')'Max. size of realizations is on the 1 x 10^3 level'
	endif	

return
end subroutine ZeroGen