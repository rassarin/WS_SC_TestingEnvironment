!Author: Amor VM Ines
!Purpose: convert doy to day given month and leapflag (0,1)
!--------
subroutine convert_doy_day(day,doy,month,leapflag)

integer			::month,day,doy,i
integer			::fdm365(12),fdm366(12)

data fdm365/1,32,60,91,121,152,182,213,244,274,305,335/ 
data fdm366/1,32,61,92,122,153,183,214,245,275,306,336/

if (leapflag == 0) then
!	doy=day+fdm365(month)-1 !converts day to doy
day=doy-fdm365(month)+1 !converts doy to day

elseif (leapflag==1) then 
!	doy=day+fdm366(month)-1 !converts day to doy
day=doy-fdm366(month)+1 !converts doy to day

endif

return
end subroutine convert_doy_day
