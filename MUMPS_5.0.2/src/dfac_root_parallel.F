C
C  This file is part of MUMPS 5.0.2, released
C  on Fri Jul 15 09:12:54 UTC 2016
C
C
C  Copyright 1991-2016 CERFACS, CNRS, ENS Lyon, INP Toulouse, Inria,
C  University of Bordeaux.
C
C  This version of MUMPS is provided to you free of charge. It is
C  released under the CeCILL-C license:
C  http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html
C
      SUBROUTINE DMUMPS_FACTO_ROOT( MYID, MASTER_OF_ROOT,
     &           root, N, IROOT,
     &           COMM, IW, LIW, IFREE,
     &           A, LA, PTRAST, PTLUST_S, PTRFAC,
     &           STEP, INFO, LDLT, QR,
     &           WK, LWK, KEEP,KEEP8,DKEEP,OPELIW)
      IMPLICIT NONE
      INCLUDE 'dmumps_root.h'
      INCLUDE 'mpif.h'
      TYPE ( DMUMPS_ROOT_STRUC ) :: root
      INTEGER N, IROOT, COMM, LIW, MYID, IFREE, MASTER_OF_ROOT
      INTEGER(8) :: LA
      INTEGER(8) :: LWK
      DOUBLE PRECISION WK( LWK )
      INTEGER KEEP(500)
      DOUBLE PRECISION    DKEEP(130)
      INTEGER(8) KEEP8(150)
      INTEGER(8) :: PTRAST(KEEP(28))
      INTEGER(8) :: PTRFAC(KEEP(28))
      INTEGER PTLUST_S(KEEP(28)), STEP(N), IW( LIW )
      INTEGER INFO( 2 ), LDLT, QR
      DOUBLE PRECISION A( LA )
      DOUBLE PRECISION, intent(inout) :: OPELIW
      INTEGER IOLDPS
      INTEGER(8) :: IAPOS
      INTEGER(8) :: ENTRIES_ROOT
      INTEGER LOCAL_M, LOCAL_N, LPIV, IERR, allocok
      INTEGER FWD_LOCAL_N_RHS, FWD_MTYPE 
      INCLUDE 'mumps_headers.h'
      EXTERNAL numroc
      INTEGER numroc
        IF ( .NOT. root%yes ) RETURN
        IF ( KEEP(60) .NE. 0 ) THEN
          IF ((LDLT == 1 .OR. LDLT == 2) .AND. KEEP(60) == 3 ) THEN
            CALL DMUMPS_SYMMETRIZE( WK, root%MBLOCK,
     &      root%MYROW, root%MYCOL, root%NPROW, root%NPCOL,
     &      root%SCHUR_POINTER(1),
     &      root%SCHUR_LLD, root%SCHUR_NLOC,
     &      root%TOT_ROOT_SIZE, MYID, COMM )
          ENDIF
        RETURN
        ENDIF
        IOLDPS  = PTLUST_S(STEP(IROOT))+KEEP(IXSZ)
        IAPOS   = PTRAST(STEP(IROOT))
        LOCAL_M = IW( IOLDPS + 2 )
        LOCAL_N = IW( IOLDPS + 1 )
        IAPOS = PTRFAC(IW ( IOLDPS + 4 ))
        IF ( LDLT.EQ.0 .OR. LDLT.EQ.2 .OR. QR.ne.0 ) THEN
         LPIV = LOCAL_M + root%MBLOCK
        ELSE
         LPIV = 1
        END IF
        IF (associated( root%IPIV )) DEALLOCATE(root%IPIV)
        root%LPIV = LPIV
        ALLOCATE( root%IPIV( LPIV ), stat = allocok )
        IF ( allocok .GT. 0 ) THEN
          INFO(1) = -13
          INFO(2) = LPIV
          WRITE(*,*) MYID,': problem allocating IPIV(',LPIV,') in root'
          CALL MUMPS_ABORT()
        END IF
        CALL DESCINIT( root%DESCRIPTOR(1), root%TOT_ROOT_SIZE,
     &      root%TOT_ROOT_SIZE, root%MBLOCK, root%NBLOCK,
     &      0, 0, root%CNTXT_BLACS, LOCAL_M, IERR )
        IF ( LDLT.EQ.2 ) THEN
            IF(root%MBLOCK.NE.root%NBLOCK) THEN
              WRITE(*,*) ' Error: symmetrization only works for'
              WRITE(*,*) ' square block sizes, MBLOCK/NBLOCK=',
     &        root%MBLOCK, root%NBLOCK
              CALL MUMPS_ABORT()
            END IF
            IF ( LWK .LT. min(
     &           int(root%MBLOCK,8) * int(root%NBLOCK,8),
     &           int(root%TOT_ROOT_SIZE,8)* int(root%TOT_ROOT_SIZE,8 )
     &         )) THEN
               WRITE(*,*) 'Not enough workspace for symmetrization.'
               CALL MUMPS_ABORT()
            END IF
            CALL DMUMPS_SYMMETRIZE( WK, root%MBLOCK,
     &      root%MYROW, root%MYCOL, root%NPROW, root%NPCOL,
     &      A( IAPOS ), LOCAL_M, LOCAL_N,
     &      root%TOT_ROOT_SIZE, MYID, COMM )
        END IF
        IF (LDLT.EQ.0.OR.LDLT.EQ.2) THEN
          CALL pdgetrf( root%TOT_ROOT_SIZE, root%TOT_ROOT_SIZE,
     &      A( IAPOS ),
     &      1, 1, root%DESCRIPTOR(1), root%IPIV(1), IERR )
          IF ( IERR .GT. 0 ) THEN
              INFO(1)=-10
              INFO(2)=IERR-1
          END IF
        ELSE
          CALL pdpotrf('L',root%TOT_ROOT_SIZE,A(IAPOS),
     &      1,1,root%DESCRIPTOR(1),IERR)
            IF ( IERR .GT. 0 ) THEN
              INFO(1)=-40
              INFO(2)=IERR-1
            END IF
        END IF
        IF (IERR .GT. 0) THEN
          CALL MUMPS_UPDATE_FLOPS_ROOT( OPELIW, LDLT,
     &                          root%TOT_ROOT_SIZE, INFO(2),
     &                          root%NPROW, root%NPCOL, MYID )
        ELSE
          CALL MUMPS_UPDATE_FLOPS_ROOT( OPELIW, LDLT,
     &                          root%TOT_ROOT_SIZE, root%TOT_ROOT_SIZE,
     &                          root%NPROW, root%NPCOL, MYID )
        ENDIF
        IF ( LDLT .EQ. 0 ) THEN
          ENTRIES_ROOT = int(root%TOT_ROOT_SIZE,8)
     &                 * int(root%TOT_ROOT_SIZE,8)
        ELSE
          ENTRIES_ROOT = int(root%TOT_ROOT_SIZE,8)
     &                 * int(root%TOT_ROOT_SIZE,8)
        ENDIF
        KEEP8(10)=KEEP8(10) + ENTRIES_ROOT /
     &                        int(root%NPROW * root%NPCOL,8)
        IF (MYID .eq. MASTER_OF_ROOT) THEN
          KEEP8(10)=KEEP8(10) +
     &    mod(ENTRIES_ROOT, int(root%NPROW*root%NPCOL,8))
        ENDIF
        IF (KEEP(258).NE.0) THEN
          IF (root%MBLOCK.NE.root%NBLOCK) THEN
            write(*,*) "Internal error in DMUMPS_FACTO_ROOT:",
     &      "Block size different for rows and columns",
     &      root%MBLOCK, root%NBLOCK
            CALL MUMPS_ABORT() 
          ENDIF
          CALL DMUMPS_GETDETER2D(root%MBLOCK, root%IPIV(1),root%MYROW,
     &         root%MYCOL, root%NPROW, root%NPCOL, A(IAPOS), LOCAL_M,
     &         LOCAL_N, root%TOT_ROOT_SIZE, MYID, DKEEP(6), KEEP(259),
     &         LDLT)
        ENDIF
        IF (KEEP(252) .NE. 0) THEN
          FWD_LOCAL_N_RHS = numroc(KEEP(253), root%NBLOCK,
     &                      root%MYCOL, 0, root%NPCOL)
          FWD_LOCAL_N_RHS = max(1,FWD_LOCAL_N_RHS)
          FWD_MTYPE       = 1 
          CALL DMUMPS_SOLVE_2D_BCYCLIC(
     &         root%TOT_ROOT_SIZE,
     &         KEEP(253),          
     &         FWD_MTYPE,
     &         A(IAPOS),
     &         root%DESCRIPTOR(1),
     &         LOCAL_M, LOCAL_N, FWD_LOCAL_N_RHS,
     &         root%IPIV(1), LPIV,
     &         root%RHS_ROOT(1,1), LDLT,
     &         root%MBLOCK, root%NBLOCK,
     &         root%CNTXT_BLACS, IERR)
        ENDIF
        RETURN
      END SUBROUTINE DMUMPS_FACTO_ROOT
