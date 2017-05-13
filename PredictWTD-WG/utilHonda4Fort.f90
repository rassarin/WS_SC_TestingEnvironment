module utilHonda4Fort
implicit none
contains

	! pause is obsolete in f90.
      subroutine pause( statement )
      character*(*) statement
      write (*,'("1")') statement
	! standard error output unit number is 0 https://gcc.gnu.org/onlinedocs/gcc-4.1.2/gfortran.pdf
      read(*,*)
      return
      end

end module utilHonda4Fort
