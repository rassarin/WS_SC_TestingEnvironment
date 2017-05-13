!Eunjin Han
!Date: 5/2/2014
!==============
!Purpose: depository 
!Author: Amor VM Ines
!Institution: IRI-Columbia University, NY

module ModuleGEN

!DEPOSIT ALL DECLARATIONS HERE!!!
!IMPLICIT NONE
!SAVE

character(len=32):: stationName
character(len=4)::bnYear,bnDayOfYear,enYear,enDayOfYear,fbnYear,fbnDayOfYear,fenYear,fenDayOfyear
character(len=32):: expName
character(len=80):: sim_dir
integer:: fbnMonth, fenMonth  !starting and ending month of seasonal forecast
integer:: nRealz,fcst_flag,sim_mode,Num_soils
integer:: beginYear,endYear,forecastYear
integer:: Plt_date,Plt_year !planting date
character(len=10), dimension(10):: Soil_ID
real, dimension(10):: Soil_wgt
integer :: leapflag
integer :: nRealz2 !EJ(1/13/2015)

real:: belowN,nearN,aboveN,fac
!EJ(0505)
character(len=32):: Cr_type !crop type (e.g. soybean, maize etc.)


!
!common /years/ beginYear,endYear,forecastYear
!!EJ
!common /months/ fbnMonth, fenMonth !beginning and ending month for seasonal forecast 
!common /days/ bnDayOfYear,enDayOfYear

end module ModuleGEN