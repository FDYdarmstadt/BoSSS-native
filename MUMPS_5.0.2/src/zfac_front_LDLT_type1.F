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
      MODULE ZMUMPS_FAC1_LDLT_M
      CONTAINS
      SUBROUTINE ZMUMPS_FAC1_LDLT( N, INODE, IW, LIW, A, LA,
     &                           IOLDPS, POSELT, IFLAG,
     &                           UU, NNEG, NPVW,
     &                           KEEP,KEEP8,
     &                           MYID, SEUIL, AVOID_DELAYED, ETATASS,
     &     DKEEP,PIVNUL_LIST,LPN_LIST, IWPOS
     &     )
      USE ZMUMPS_FAC_FRONT_AUX_M
      USE ZMUMPS_OOC
      IMPLICIT NONE
      INTEGER(8) :: LA, POSELT
      INTEGER N, INODE, LIW, IFLAG, NNEG, NPVW
      INTEGER MYID, IOLDPS
      INTEGER KEEP( 500 )
      INTEGER(8) KEEP8(150)
      DOUBLE PRECISION UU, SEUIL
      COMPLEX(kind=8) A( LA )
      INTEGER, TARGET :: IW( LIW )
      LOGICAL AVOID_DELAYED
      INTEGER ETATASS, IWPOS
      INTEGER LPN_LIST
      INTEGER PIVNUL_LIST(LPN_LIST)
      DOUBLE PRECISION DKEEP(130)
      INTEGER INOPV, IFINB, NFRONT, NPIV, IBEG_BLOCK, IEND_BLOCK
      INTEGER NASS, NBKJIB_ORIG, XSIZE
      INTEGER :: LDA
      DOUBLE PRECISION UUTEMP
      LOGICAL STATICMODE
      DOUBLE PRECISION SEUIL_LOC
      LOGICAL POSTPONE_COL_UPDATE, IS_MAXFROMM_AVAIL
      DOUBLE PRECISION MAXFROMM
      INTEGER(8) :: LAFAC
      INTEGER LIWFAC, STRAT, NextPiv2beWritten, IFLAG_OOC,
     &        IDUMMY, PP_FIRST2SWAP_L, PP_LastPIVRPTRFilled
      TYPE(IO_BLOCK) :: MonBloc 
      LOGICAL LAST_CALL
      LOGICAL LASTBL
      INTEGER GROUPLOC, CURRENT_BLR
      LOGICAL LR_ACTIVATED 
      INCLUDE 'mumps_headers.h'
      INTEGER NBLR_ORIG, IBEG_BLR, IEND_BLR
      INTEGER Inextpiv
      INTEGER PIVSIZ,IWPOSP2
      IS_MAXFROMM_AVAIL = .FALSE.
      IF (KEEP(206).GE.1) THEN
        Inextpiv = 1   
      ELSE 
        Inextpiv = 0   
      ENDIF
      INOPV = 0
      IF(KEEP(97) .EQ. 0) THEN
         STATICMODE = .FALSE.
      ELSE
         STATICMODE = .TRUE.
      ENDIF
      IF (AVOID_DELAYED) THEN
        STATICMODE = .TRUE.
        UUTEMP=UU
        SEUIL_LOC = max(SEUIL,epsilon(SEUIL))
      ELSE
        UUTEMP=UU
        SEUIL_LOC = SEUIL
      ENDIF
      POSTPONE_COL_UPDATE = (UUTEMP == 0.0D0 .AND. KEEP(201).NE.1)
      LAFAC  = -9999_8  
      XSIZE  = KEEP(IXSZ)
      NFRONT = IW(IOLDPS+XSIZE)
      LDA    = NFRONT
      NASS   = iabs(IW(IOLDPS+2+XSIZE))
      IW(IOLDPS+3+XSIZE) =  -99999
      LR_ACTIVATED= .FALSE.        
      IF (NASS.LT.KEEP(4)) THEN
        NBKJIB_ORIG = NASS
      ELSE IF (NASS .GT. KEEP(3)) THEN
        NBKJIB_ORIG = min( KEEP(6), NASS )
      ELSE
        NBKJIB_ORIG = min( KEEP(5), NASS )
      ENDIF
      IF (.not.LR_ACTIVATED) THEN
          NBLR_ORIG     = KEEP(488)
          IF (KEEP(486) .EQ. -1) THEN
             GROUPLOC = 1
             write(6,*) ' FR facto with LR grouping not validated yet'
             write(6,*) ' try with KEEP(486) = 0 or 1 '
             CALL MUMPS_ABORT()
          ELSE
             GROUPLOC = 0
          ENDIF
      ELSE
          NBLR_ORIG  = -9999 
          GROUPLOC    = KEEP(486)
      ENDIF
      IEND_BLOCK  = 0
      IEND_BLR    = 0
      CURRENT_BLR = 0
      LASTBL      = .FALSE.
      IF (KEEP(201).EQ.1) THEN 
          IDUMMY    = -8765
          CALL MUMPS_GETI8(LAFAC,IW(IOLDPS+XXR))
          LIWFAC    = IW(IOLDPS+XXI)
          NextPiv2beWritten = 1 
          PP_FIRST2SWAP_L = NextPiv2beWritten 
          MonBloc%LastPanelWritten_L = 0 
          PP_LastPIVRPTRFilled       = 0
          MonBloc%INODE    = INODE
          MonBloc%MASTER   = .TRUE.
          MonBloc%Typenode = 1
          MonBloc%NROW     = NFRONT
          MonBloc%NCOL     = NFRONT
          MonBloc%NFS      = NASS
          MonBloc%Last     = .FALSE.   
          MonBloc%LastPiv  = -77777    
          MonBloc%INDICES  =>
     &              IW(IOLDPS+6+NFRONT+XSIZE:
     &                 IOLDPS+5+NFRONT+XSIZE+NFRONT)
      ENDIF
      DO WHILE (IEND_BLR < NASS ) 
        CURRENT_BLR = CURRENT_BLR + 1
        IBEG_BLR = IW(IOLDPS+1+KEEP(IXSZ)) + 1 
        IF (.NOT. LR_ACTIVATED .AND. GROUPLOC .EQ. 0)THEN
          IEND_BLR = min(IEND_BLR + NBLR_ORIG, NASS)
        ENDIF
        DO WHILE (IEND_BLOCK < IEND_BLR ) 
          IBEG_BLOCK = IW(IOLDPS+1+KEEP(IXSZ)) + 1
          IEND_BLOCK = min(IEND_BLOCK + NBKJIB_ORIG, IEND_BLR)
  50      CONTINUE  
            CALL ZMUMPS_FAC_I_LDLT(NFRONT,NASS,INODE,IEND_BLOCK,
     &                IW,LIW,A,LA,
     &                INOPV, NNEG, IFLAG,IOLDPS,POSELT,UUTEMP,
     &                SEUIL_LOC,KEEP,KEEP8,PIVSIZ,
     &      DKEEP(1),PIVNUL_LIST(1),LPN_LIST, XSIZE,
     &      PP_FIRST2SWAP_L, MonBloc%LastPanelWritten_L,
     &      PP_LastPIVRPTRFilled, MAXFROMM, IS_MAXFROMM_AVAIL,
     &      Inextpiv, IEND_BLR )
            IF (IFLAG.LT.0) GOTO 500
            IF(KEEP(109).GT. 0) THEN
              IF(PIVNUL_LIST(KEEP(109)).EQ.-1) THEN
                IWPOSP2 = IOLDPS+IW(IOLDPS+1+XSIZE)+6+XSIZE
     &                  +IW(IOLDPS+5+XSIZE)
                PIVNUL_LIST(KEEP(109)) = IW(IWPOSP2)
              ENDIF
            ENDIF
          IF (INOPV.EQ.1) THEN
            IF(STATICMODE) THEN
              INOPV = -1
              GOTO 50 
            ENDIF
            LASTBL = .TRUE.
          ELSE IF ( INOPV.LE.0 ) THEN 
            NPVW = NPVW + PIVSIZ
            CALL ZMUMPS_FAC_MQ_LDLT(IEND_BLOCK,
     &             NFRONT, NASS, IW(IOLDPS+1+XSIZE),
     &             INODE,A,LA,
     &             LDA, POSTPONE_COL_UPDATE, 
     &             POSELT,IFINB,
     &             PIVSIZ, MAXFROMM,
     &             IS_MAXFROMM_AVAIL, (UUTEMP.NE.0.0D0),
     &             KEEP(253) )
            IF(PIVSIZ .EQ. 2) THEN
              IWPOSP2 = IOLDPS+IW(IOLDPS+1+XSIZE)+6
              IW(IWPOSP2+NFRONT+XSIZE) =
     &                              -IW(IWPOSP2+NFRONT+XSIZE)
            ENDIF
            IW(IOLDPS+1+XSIZE) = IW(IOLDPS+1+XSIZE) + PIVSIZ
            IF (IFINB.EQ.0) THEN
              GOTO 50 
            ELSE IF (IFINB.EQ.-1) THEN
              LASTBL = .TRUE.
            ENDIF
          ENDIF
          IF (KEEP(201).EQ.1.AND. .NOT. POSTPONE_COL_UPDATE) THEN
            MonBloc%Last = LASTBL
            MonBloc%LastPiv= IW(IOLDPS+1+XSIZE)
            LAST_CALL=.FALSE.
            CALL ZMUMPS_OOC_IO_LU_PANEL(
     &        STRAT_TRY_WRITE,
     &        TYPEF_L, A(POSELT),
     &        LAFAC, MonBloc, NextPiv2beWritten, IDUMMY,
     &        IW(IOLDPS), LIWFAC,
     &        MYID, KEEP8(31), IFLAG_OOC,LAST_CALL )
            IF (IFLAG_OOC < 0 ) THEN
              IFLAG=IFLAG_OOC
              GOTO 500
            ENDIF
          ENDIF
          NPIV       =  IW(IOLDPS+1+XSIZE)
          IF ( IEND_BLR .GT. IEND_BLOCK ) THEN
            CALL ZMUMPS_FAC_SQ_LDLT(IBEG_BLOCK,IEND_BLOCK,
     &             NPIV, NFRONT,NASS,IEND_BLR,INODE,A,LA,
     &             LDA, POSELT,
     &             POSTPONE_COL_UPDATE,
     &             KEEP,KEEP8)
          ENDIF
        END DO 
        NPIV   =  IW(IOLDPS+1+XSIZE)
        IF (
     &       (.NOT. LR_ACTIVATED) 
     &     )
     &  THEN
          CALL ZMUMPS_FAC_SQ_LDLT(IBEG_BLR,IEND_BLR,NPIV,
     &             NFRONT,NASS,NASS,INODE,A,LA,
     &             LDA, POSELT,
     &             POSTPONE_COL_UPDATE,
     &             KEEP,KEEP8)
        ENDIF
        IF (KEEP(201) .EQ. 1 .AND. .NOT. POSTPONE_COL_UPDATE) THEN 
             MonBloc%Last = LASTBL
             MonBloc%LastPiv= NPIV
             LAST_CALL=.FALSE.
             CALL ZMUMPS_OOC_IO_LU_PANEL(
     &          STRAT_TRY_WRITE,
     &          TYPEF_L, A(POSELT),
     &          LAFAC, MonBloc, NextPiv2beWritten, IDUMMY, IW(IOLDPS),
     &          LIWFAC, MYID, KEEP8(31), IFLAG_OOC,LAST_CALL )
             IF (IFLAG_OOC < 0 ) THEN
                IFLAG=IFLAG_OOC
                GOTO 500
             ENDIF
        ENDIF
      END DO 
      IF ( LR_ACTIVATED
     &   )  THEN
        IF ( POSTPONE_COL_UPDATE ) THEN
          WRITE(*,*) "Internal error 1 in ZMUMPS_FACTO_NIV1"
          CALL MUMPS_ABORT()
        ENDIF
      ELSE
        CALL ZMUMPS_FAC_T_LDLT(NFRONT,NASS,IW,LIW,A,LA,
     &         LDA, IOLDPS,POSELT, KEEP,KEEP8,
     &         POSTPONE_COL_UPDATE, ETATASS,
     &         TYPEF_L, LAFAC, MonBloc, NextPiv2beWritten,
     &         LIWFAC, MYID, IFLAG)
      ENDIF
      IF (KEEP(201).EQ.1) THEN 
          STRAT        = STRAT_WRITE_MAX   
          MonBloc%Last = .TRUE.
          MonBloc%LastPiv  = IW(IOLDPS+1+XSIZE)
          LAST_CALL    = .TRUE.
          CALL ZMUMPS_OOC_IO_LU_PANEL
     &          ( STRAT, TYPEF_L, 
     &           A(POSELT), LAFAC, MonBloc,
     &           NextPiv2beWritten, IDUMMY,
     &           IW(IOLDPS), LIWFAC, 
     &           MYID, KEEP8(31), IFLAG_OOC,LAST_CALL )
          IF (IFLAG_OOC < 0 ) THEN
            IFLAG=IFLAG_OOC
            GOTO 500
          ENDIF
          CALL ZMUMPS_OOC_PP_TRYRELEASE_SPACE (IWPOS, 
     &      IOLDPS, IW, LIW, MonBloc , NFRONT, KEEP)
      ENDIF
 500  CONTINUE
      RETURN
      END SUBROUTINE ZMUMPS_FAC1_LDLT
      END MODULE ZMUMPS_FAC1_LDLT_M
