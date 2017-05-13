!----------------------------
!subroutines
! this is a test for doy, which month it belongs
subroutine doytest(leapflag,month,doy)

implicit none

integer			::month,doy,i,leapflag

!index month number

if ((doy.ge.1).and.(doy.lt.32)) then
	month=1 
elseif ((doy.ge.32).and.(doy.lt.60+leapflag)) then
	month=2
elseif ((doy.ge.60+leapflag).and.(doy.lt.91+leapflag)) then
	month=3
elseif ((doy.ge.91+leapflag).and.(doy.lt.121+leapflag)) then
	month=4
elseif ((doy.ge.121+leapflag).and.(doy.lt.152+leapflag)) then
	month=5
elseif ((doy.ge.152+leapflag).and.(doy.lt.182+leapflag)) then
	month=6
elseif ((doy.ge.182+leapflag).and.(doy.lt.213+leapflag)) then
	month=7
elseif ((doy.ge.213+leapflag).and.(doy.lt.244+leapflag)) then
	month=8
elseif ((doy.ge.244+leapflag).and.(doy.lt.274+leapflag)) then
	month=9
elseif ((doy.ge.274+leapflag).and.(doy.lt.305+leapflag)) then
	month=10
elseif ((doy.ge.305+leapflag).and.(doy.lt.335+leapflag)) then
	month=11
else
	month=12
endif

return

end subroutine doytest