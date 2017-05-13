!---------------------------------------------------------------------------
      subroutine ran3(idum,rand)
!
!  Returns a uniform random deviate between 0.0 and 1.0.  Set idum to
!  any negative value to initialize or reinitialize the sequence.
!  This function is taken from W.H. Press', "Numerical Recipes" p. 199.
!
      IMPLICIT NONE
      save
!      implicit real*4(m)
      real(8),parameter		:: mbig=4000000.,mseed=1618033.,mz=0.,fac=1./mbig
!     parameter (mbig=1000000000,mseed=161803398,mz=0,fac=1./mbig)
!
!  According to Knuth, any large mbig, and any smaller (but still large)
!  mseed can be substituted for the above values.
      real,dimension(55)		:: ma
	  
	  integer		:: iff,idum,i,ii,k,inext,inextp
	  real		:: rand,mj,mk
	  
      data iff /0/
      if (idum.lt.0 .or. iff.eq.0) then
         iff=1
         mj=mseed-dble(iabs(idum))
         mj=dmod(mj,mbig)
         ma(55)=mj
         mk=1.0d0
         do 11 i=1,54
            ii=mod(21*i,55)
            ma(ii)=mk
            mk=mj-mk
            if(mk.lt.mz) mk=mk+mbig
            mj=ma(ii)
 11      continue
         do 13 k=1,4
            do 12 i=1,55
               ma(i)=ma(i)-ma(1+mod(i+30,55))
               if(ma(i).lt.mz) ma(i)=ma(i)+mbig
 12         continue
 13      continue
         inext=0
         inextp=31
         idum=1
      endif
      inext=inext+1
      if(inext.eq.56) inext=1
      inextp=inextp+1
      if(inextp.eq.56) inextp=1
      mj=ma(inext)-ma(inextp)
      if(mj.lt.mz) mj=mj+mbig
      ma(inext)=mj
      rand=mj*fac
      return
      end subroutine ran3
!
