!----------------------------
!subroutines
! this subroutine returns total nuumber of days for target month
subroutine day_count(leapflag,month,n_day)

implicit none

integer			::month,n_day,i,leapflag

!index month number

if (month .eq. 1) then
	n_day=31
elseif ((month .eq. 2).and.(leapflag .eq. 1)) then
	n_day=29
elseif ((month .eq. 2).and.(leapflag .ne. 1)) then
	n_day=28
elseif (month .eq. 3) then
	n_day=31
elseif (month .eq. 4) then
	n_day=30
elseif (month .eq. 5) then
	n_day=31
elseif (month .eq. 6) then
	n_day=30
elseif (month .eq. 7) then
	n_day=31
elseif (month .eq. 8) then
	n_day=31
elseif (month .eq. 9) then
	n_day=30
elseif (month .eq. 10) then
	n_day=31
elseif (month .eq. 11) then
	n_day=30
else
	n_day=31
endif

return

end subroutine day_count