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
      SUBROUTINE DMUMPS_SOL_R(N, A, LA, IW, LIW, WCB, LWCB,
     &    NRHS,
     &    PTRICB, IWCB, LIWCB, 
     &    RHSCOMP, LRHSCOMP, POSINRHSCOMP_FWD, 
     &    NE_STEPS, NA, LNA, STEP,
     &    FRERE, DAD, FILS,
     &    NSTK_S, IPOOL, LPOOL, PTRIST, PTRFAC, MYLEAF, INFO,
     &    KEEP,KEEP8,
     &    PROCNODE_STEPS,
     &    SLAVEF, COMM, MYID, BUFR, LBUFR, LBUFR_BYTES,
     &    RHS_ROOT, LRHS_ROOT, MTYPE, 
     &
     &    ISTEP_TO_INIV2, TAB_POS_IN_PERE
     &    , RHS_BOUNDS, LRHS_BOUNDS, DO_NBSPARSE 
     &    )
      USE DMUMPS_OOC
      IMPLICIT NONE
      INTEGER MTYPE
      INTEGER(8) :: LA
      INTEGER, INTENT(IN) :: N, LIW, LWCB, LPOOL, LIWCB, LNA
      INTEGER SLAVEF, MYLEAF, COMM, MYID
      INTEGER INFO( 40 ), KEEP(500)
      INTEGER(8) KEEP8(150)
      INTEGER PROCNODE_STEPS( KEEP(28) )
      INTEGER NRHS
      DOUBLE PRECISION A( LA ), WCB( LWCB )
      INTEGER LRHS_ROOT
      DOUBLE PRECISION RHS_ROOT( LRHS_ROOT )
      INTEGER LBUFR, LBUFR_BYTES
      INTEGER BUFR( LBUFR )
      INTEGER NA( LNA ), NE_STEPS( KEEP(28) )
      INTEGER STEP( N ), FRERE( KEEP(28) ), FILS( N ),
     &        DAD( KEEP(28) )
      INTEGER NSTK_S(KEEP(28)), IPOOL( LPOOL )
      INTEGER PTRIST(KEEP(28))
      INTEGER(8) :: PTRFAC(KEEP(28))
      INTEGER PTRICB( KEEP(28) ) 
      LOGICAL, intent(in) :: DO_NBSPARSE
      INTEGER, intent(in) :: LRHS_BOUNDS
      INTEGER, intent(in) :: RHS_BOUNDS(LRHS_BOUNDS)
      INTEGER IW( LIW ), IWCB( LIWCB )
      INTEGER ISTEP_TO_INIV2(KEEP(71)), 
     &        TAB_POS_IN_PERE(SLAVEF+2,max(1,KEEP(56)))
      INTEGER, intent(in) ::  POSINRHSCOMP_FWD(N), LRHSCOMP 
#if defined(RHSCOMP_BYROWS)
      DOUBLE PRECISION, intent(inout) :: RHSCOMP(NRHS,LRHSCOMP)
#else
      DOUBLE PRECISION, intent(inout) :: RHSCOMP(LRHSCOMP,NRHS)
#endif
      INCLUDE 'mpif.h'
      INCLUDE 'mumps_tags.h'
      INTEGER MSGTAG, MSGSOU, DUMMY(1)
      LOGICAL FLAG
      INTEGER NBFIN, MYROOT
      INTEGER POSIWCB,POSWCB,PLEFTWCB
      INTEGER INODE
      INTEGER I
      INTEGER III, NBROOT,LEAF
      LOGICAL BLOQ
      EXTERNAL MUMPS_PROCNODE
      INTEGER MUMPS_PROCNODE
      DUMMY(1) = 1
      KEEP(266)=0
      POSIWCB = LIWCB
      POSWCB  = LWCB
      PLEFTWCB= 1
      DO I = 1, KEEP(28)
        NSTK_S(I)   = NE_STEPS(I)
      ENDDO
      PTRICB = 0
      CALL MUMPS_INIT_POOL_DIST(N, LEAF, MYID,
     &     SLAVEF, NA, LNA, KEEP,KEEP8, STEP,
     &     PROCNODE_STEPS, IPOOL, LPOOL)
      CALL MUMPS_INIT_NROOT_DIST(N, NBROOT, MYROOT, MYID,
     &     SLAVEF, NA, LNA, KEEP, STEP,
     &     PROCNODE_STEPS)
      NBFIN = SLAVEF
      IF ( MYROOT .EQ. 0 ) THEN
        NBFIN = NBFIN - 1
        CALL DMUMPS_MCAST2(DUMMY, 1, MPI_INTEGER, MYID, COMM,
     &       RACINE_SOLVE, SLAVEF, KEEP)
        IF (NBFIN.EQ.0) GOTO 260
      END IF
      MYLEAF = LEAF - 1
      III    = 1
   50 CONTINUE
      IF (SLAVEF .EQ. 1) THEN
         CALL DMUMPS_GET_INODE_FROM_POOL
     &        ( IPOOL(1), LPOOL, III, LEAF, INODE,
     &          KEEP(208) )
        GOTO 60
      ENDIF
      BLOQ = ( ( III .EQ. LEAF )
     &     )
      CALL DMUMPS_SOLVE_RECV_AND_TREAT( BLOQ, FLAG,
     &     BUFR, LBUFR, LBUFR_BYTES,
     &     MYID, SLAVEF, COMM,
     &     N, NRHS, IPOOL, LPOOL, III, LEAF,
     &     NBFIN, NSTK_S, IW, LIW, A, LA, PTRIST, PTRFAC,
     &     IWCB, LIWCB,
     &     WCB, LWCB, POSWCB,
     &     PLEFTWCB, POSIWCB,
     &     PTRICB, INFO, KEEP,KEEP8, STEP,
     &     PROCNODE_STEPS,
     &     RHSCOMP, LRHSCOMP, POSINRHSCOMP_FWD
     &     )
      IF ( INFO( 1 ) .LT. 0 .OR. NBFIN .EQ. 0 ) GOTO 260
      IF (.not. FLAG) THEN
         IF (III .NE. LEAF) THEN
            CALL DMUMPS_GET_INODE_FROM_POOL
     &           (IPOOL(1), LPOOL, III, LEAF, INODE,
     &           KEEP(208) )
            GOTO 60
         ENDIF                  
      ENDIF                     
      GOTO 50
 60   CONTINUE
      CALL DMUMPS_SOLVE_NODE( INODE, BUFR, LBUFR, LBUFR_BYTES,
     &        MSGTAG, MSGSOU, MYID, SLAVEF, COMM,  N,
     &        IPOOL, LPOOL, III, LEAF, NBFIN, NSTK_S,
     &        IWCB, LIWCB, WCB, LWCB, A, LA,
     &        IW, LIW, NRHS, 
     &        POSWCB, PLEFTWCB, POSIWCB,
     &        PTRICB, PTRIST, PTRFAC, PROCNODE_STEPS,
     &        FILS, STEP, FRERE, DAD,
     &        MYROOT, INFO, KEEP,KEEP8, RHS_ROOT, MTYPE, 
     &        RHSCOMP, LRHSCOMP, POSINRHSCOMP_FWD,
     &        ISTEP_TO_INIV2, TAB_POS_IN_PERE
     &        , RHS_BOUNDS, LRHS_BOUNDS, DO_NBSPARSE 
     &     )
      IF ( INFO( 1 ) .LT. 0 .OR. NBFIN .EQ. 0 ) GOTO 260
      GOTO 50
  260 CONTINUE
      CALL DMUMPS_CLEAN_PENDING(INFO(1), KEEP, BUFR, LBUFR,LBUFR_BYTES,
     &     COMM, DUMMY(1),  
     &     SLAVEF, .TRUE., .FALSE.) 
      RETURN
      END SUBROUTINE DMUMPS_SOL_R
