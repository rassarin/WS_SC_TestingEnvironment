!---------------------------
!subroutines
subroutine leapyear(year,leapflag)

integer     :: year, leapflag !, jj, jump
!a general test!
      if (((mod(year,4)==0).and.(mod(year,100)/=0)).or.(mod(year,400)==0))then
	   leapflag=1   
        else
	   leapflag=0
      endif
return

end subroutine leapyear
