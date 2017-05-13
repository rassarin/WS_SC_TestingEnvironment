subroutine Errflg(enit,iost,stationName,fname,expName)

integer:: enit, iost
character(len=32):: fileNames,fname,stationName,expName,line3
logical:: EXISTS

if(enit==10)then
	fileNames=stationName(1:4)//'.WTD'
elseif(enit==11)then
	fileNames='BASE0000'//'.WTD'
elseif(enit==12)then
	fileNames=expName(1:8)//'.OSU'
elseif(enit==20)then  !EJ(5/5/2014)
	fileNames='D4Batch_template'//'.DV4'
elseif(enit==21)then !EJ(5/5/2014)
	fileNames='D4Batch'//'.DV4'
elseif(enit==30)then  !EJ(5/5/2014)
	fileNames='Exp_file_template'//'.ccX'
elseif(enit==31)then !EJ(5/5/2014)
	fileNames=expName(1:12)
elseif(enit .gt. 99 .and. enit .lt. 999)then
	fileNames=fname(1:8)//'.WTD'
elseif(enit .gt. 999)then
	fileNames=fname(1:8)//'.WTDE'
else 
	continue
endif 

if(iost .lt. 0)then
     write(6,300) 'ERROR, parser cannot find/read/process the file:',trim(fileNames)
stop
endif

return

300 format(a,1x,a,/)

return
end subroutine Errflg