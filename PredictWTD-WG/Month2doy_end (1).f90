!----------------------------
!subroutines
! this is a test for doy, which month it belongs
subroutine Month2doy_end(leapflag,month,doy)

implicit none

integer			::month,doy,i,leapflag

!index month number

if (month .eq. 1) then
	doy=31
elseif (month .eq. 2) then
	doy=59
elseif (month .eq. 3) then
	doy=90+leapflag
elseif (month .eq. 4) then
	doy=120+leapflag
elseif (month .eq. 5) then
	doy=151+leapflag
elseif (month .eq. 6) then
	doy=181+leapflag
elseif (month .eq. 7) then
	doy=212+leapflag
elseif (month .eq. 8) then
	doy=243+leapflag
elseif (month .eq. 9) then
	doy=273+leapflag
elseif (month .eq. 10) then
	doy=304+leapflag
elseif (month .eq. 11) then
	doy=334+leapflag
else
	doy=365+leapflag
endif

return

end subroutine Month2doy_end