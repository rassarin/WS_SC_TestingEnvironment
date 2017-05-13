!----------------------------
!subroutines
! this is a test for doy, which month it belongs
subroutine Month2doy_start(leapflag,month,doy)

implicit none

integer			::month,doy,i,leapflag

!index month number

if (month .eq. 1) then
	doy=1
elseif (month .eq. 2) then
	doy=32
elseif (month .eq. 3) then
	doy=60+leapflag
elseif (month .eq. 4) then
	doy=91+leapflag
elseif (month .eq. 5) then
	doy=121+leapflag
elseif (month .eq. 6) then
	doy=152+leapflag
elseif (month .eq. 7) then
	doy=182+leapflag
elseif (month .eq. 8) then
	doy=213+leapflag
elseif (month .eq. 9) then
	doy=244+leapflag
elseif (month .eq. 10) then
	doy=274+leapflag
elseif (month .eq. 11) then
	doy=305+leapflag
else
	doy=335+leapflag
endif

return

end subroutine Month2doy_start