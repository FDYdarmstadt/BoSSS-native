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
      SUBROUTINE DMUMPS_F77( JOB, SYM, PAR, COMM_F77, N, ICNTL, CNTL,
     &                      KEEP, DKEEP, KEEP8,
     &                      NZ, IRN, IRNhere, JCN, JCNhere, A, Ahere,
     &                      NZ_loc, IRN_loc, IRN_lochere,
     &                      JCN_loc, JCN_lochere,
     &                      A_loc, A_lochere,
     &                      NELT, ELTPTR, ELTPTRhere,  ELTVAR,
     &                      ELTVARhere, A_ELT, A_ELThere,
     &                      PERM_IN, PERM_INhere,
     &                      RHS, RHShere, REDRHS, REDRHShere,
     &                      INFO, RINFO, INFOG, RINFOG,
     &                      DEFICIENCY, LWK_USER,
     &                      SIZE_SCHUR, LISTVAR_SCHUR,
     &                      LISTVAR_SCHURhere, SCHUR, SCHURhere,
     &                      WK_USER, WK_USERhere,
     &                      COLSCA, COLSCAhere, ROWSCA, ROWSCAhere,
     &                      INSTANCE_NUMBER, NRHS, LRHS, LREDRHS,
     &
     &                      RHS_SPARSE, RHS_SPARSEhere,
     &                      SOL_loc, SOL_lochere,
     &                      IRHS_SPARSE, IRHS_SPARSEhere,
     &                      IRHS_PTR, IRHS_PTRhere,
     &                      ISOL_loc, ISOL_lochere,
     &                      NZ_RHS, LSOL_loc
     &                      , 
     & SCHUR_MLOC,
     & SCHUR_NLOC,
     & SCHUR_LLD,
     & MBLOCK,
     & NBLOCK,
     & NPROW,
     & NPCOL,
     &
     & OOC_TMPDIR,
     & OOC_PREFIX,
     & WRITE_PROBLEM,
     & TMPDIRLEN,
     & PREFIXLEN,
     & WRITE_PROBLEMLEN
     &
     & )
      USE DMUMPS_STRUC_DEF
      IMPLICIT NONE
      INTEGER OOC_PREFIX_MAX_LENGTH, OOC_TMPDIR_MAX_LENGTH
      INTEGER PB_MAX_LENGTH
      PARAMETER(OOC_PREFIX_MAX_LENGTH=63, OOC_TMPDIR_MAX_LENGTH=255)
      PARAMETER(PB_MAX_LENGTH=255)
      INTEGER JOB, SYM, PAR, COMM_F77, N, NZ, NZ_loc, NELT,
     &        DEFICIENCY, LWK_USER, SIZE_SCHUR, INSTANCE_NUMBER,
     &        NRHS, LRHS,
     &        NZ_RHS, LSOL_loc, LREDRHS
      INTEGER ICNTL(40), INFO(40), INFOG(40), KEEP(500)
      INTEGER SCHUR_MLOC, SCHUR_NLOC, SCHUR_LLD
      INTEGER MBLOCK, NBLOCK, NPROW, NPCOL
      INTEGER TMPDIRLEN, PREFIXLEN, WRITE_PROBLEMLEN
      DOUBLE PRECISION CNTL(15), RINFO(40), RINFOG(40), DKEEP(130)
      INTEGER(8) KEEP8(150)
      INTEGER, TARGET :: IRN(*), JCN(*), ELTPTR(*), ELTVAR(*)
      INTEGER, TARGET :: PERM_IN(*), IRN_loc(*), JCN_loc(*)
      INTEGER, TARGET :: LISTVAR_SCHUR(*)
      INTEGER, TARGET :: IRHS_PTR(*), IRHS_SPARSE(*), ISOL_loc(*)
      DOUBLE PRECISION, TARGET :: A(*), A_ELT(*), A_loc(*), RHS(*)
      DOUBLE PRECISION, TARGET :: WK_USER(*)
      DOUBLE PRECISION, TARGET :: REDRHS(*)
      DOUBLE PRECISION, TARGET :: ROWSCA(*), COLSCA(*)
      DOUBLE PRECISION, TARGET :: SCHUR(*)
      DOUBLE PRECISION, TARGET :: RHS_SPARSE(*), SOL_loc(*)
      INTEGER, INTENT(in) :: OOC_TMPDIR(OOC_TMPDIR_MAX_LENGTH)
      INTEGER, INTENT(in) :: OOC_PREFIX(OOC_PREFIX_MAX_LENGTH)
      INTEGER, INTENT(in) :: WRITE_PROBLEM(PB_MAX_LENGTH)
      INTEGER IRNhere, JCNhere, Ahere, ELTPTRhere, ELTVARhere,
     &        A_ELThere, PERM_INhere, WK_USERhere,
     &        RHShere, REDRHShere, IRN_lochere,
     &        JCN_lochere, A_lochere, LISTVAR_SCHURhere,
     &        SCHURhere, COLSCAhere, ROWSCAhere, RHS_SPARSEhere,
     &        SOL_lochere, IRHS_PTRhere, IRHS_SPARSEhere, ISOL_lochere
      INCLUDE 'mpif.h'
      TYPE DMUMPS_STRUC_PTR
          TYPE (DMUMPS_STRUC), POINTER :: PTR
      END TYPE DMUMPS_STRUC_PTR
      TYPE (DMUMPS_STRUC), POINTER :: mumps_par
      TYPE (DMUMPS_STRUC_PTR), DIMENSION (:), POINTER, SAVE ::
     &  mumps_par_array
      TYPE (DMUMPS_STRUC_PTR), DIMENSION (:), POINTER ::
     &  mumps_par_array_bis
      INTEGER, SAVE :: DMUMPS_STRUC_ARRAY_SIZE = 0
      INTEGER, SAVE :: N_INSTANCES = 0
      INTEGER A_ELT_SIZE, I, Np, IERR
      INTEGER DMUMPS_STRUC_ARRAY_SIZE_INIT
      PARAMETER (DMUMPS_STRUC_ARRAY_SIZE_INIT=10)
      EXTERNAL MUMPS_ASSIGN_MAPPING,
     &         MUMPS_ASSIGN_PIVNUL_LIST,
     &         MUMPS_ASSIGN_SYM_PERM,
     &         MUMPS_ASSIGN_UNS_PERM
      EXTERNAL DMUMPS_ASSIGN_COLSCA,
     &         DMUMPS_ASSIGN_ROWSCA
      IF (JOB == -1) THEN
        DO I = 1, DMUMPS_STRUC_ARRAY_SIZE
          IF ( .NOT. associated(mumps_par_array(I)%PTR) ) GOTO 10
        END DO
        ALLOCATE( mumps_par_array_bis(DMUMPS_STRUC_ARRAY_SIZE +
     &  DMUMPS_STRUC_ARRAY_SIZE_INIT), stat=IERR)
        IF (IERR /= 0) THEN
          WRITE(*,*) ' ** Allocation Error 1 in DMUMPS_F77.'
          CALL MUMPS_ABORT()
        END IF
        DO I = 1, DMUMPS_STRUC_ARRAY_SIZE
          mumps_par_array_bis(I)%PTR=>mumps_par_array(I)%PTR
        ENDDO
        IF (associated(mumps_par_array)) DEALLOCATE(mumps_par_array)
        mumps_par_array=>mumps_par_array_bis
        NULLIFY(mumps_par_array_bis)
        DO I = DMUMPS_STRUC_ARRAY_SIZE+1, DMUMPS_STRUC_ARRAY_SIZE +
     &  DMUMPS_STRUC_ARRAY_SIZE_INIT
          NULLIFY(mumps_par_array(I)%PTR)
        ENDDO
        I = DMUMPS_STRUC_ARRAY_SIZE+1
        DMUMPS_STRUC_ARRAY_SIZE = DMUMPS_STRUC_ARRAY_SIZE +
     &  DMUMPS_STRUC_ARRAY_SIZE_INIT
 10     CONTINUE
        INSTANCE_NUMBER = I
        N_INSTANCES = N_INSTANCES+1
        ALLOCATE( mumps_par_array(INSTANCE_NUMBER)%PTR,stat=IERR )
        IF (IERR /= 0) THEN
          WRITE(*,*) '** Allocation Error 2 in DMUMPS_F77.'
          CALL MUMPS_ABORT()
        ENDIF
        mumps_par_array(INSTANCE_NUMBER)%PTR%KEEP(40) = 0
        mumps_par_array(INSTANCE_NUMBER)%PTR%INSTANCE_NUMBER =
     &  INSTANCE_NUMBER
      END IF
      IF ( INSTANCE_NUMBER .LE. 0 .OR. INSTANCE_NUMBER .GT.
     &     DMUMPS_STRUC_ARRAY_SIZE ) THEN
        WRITE(*,*) ' ** Instance Error 1 in DMUMPS_F77',
     &             INSTANCE_NUMBER
        CALL MUMPS_ABORT()
      END IF
      IF ( .NOT. associated ( mumps_par_array(INSTANCE_NUMBER)%PTR ) )
     &  THEN
        WRITE(*,*) ' Instance Error 2 in DMUMPS_F77',
     &             INSTANCE_NUMBER
        CALL MUMPS_ABORT()
      END IF
      mumps_par => mumps_par_array(INSTANCE_NUMBER)%PTR
      mumps_par%SYM = SYM
      mumps_par%PAR = PAR
      mumps_par%JOB = JOB
      mumps_par%N   = N
      mumps_par%NZ  = NZ
      mumps_par%NZ_loc  = NZ_loc
      mumps_par%LWK_USER = LWK_USER
      mumps_par%SIZE_SCHUR  = SIZE_SCHUR
      mumps_par%NELT= NELT
      mumps_par%ICNTL(1:40)=ICNTL(1:40)
      mumps_par%CNTL(1:15)=CNTL(1:15)
      mumps_par%KEEP(1:500)=KEEP(1:500)
      mumps_par%DKEEP(1:130)=DKEEP(1:130)
      mumps_par%KEEP8(1:150)=KEEP8(1:150)
      mumps_par%NRHS  = NRHS
      mumps_par%LRHS  = LRHS
      mumps_par%LREDRHS = LREDRHS
      mumps_par%NZ_RHS   = NZ_RHS
      mumps_par%LSOL_loc = LSOL_loc
      mumps_par%SCHUR_MLOC   = SCHUR_MLOC
      mumps_par%SCHUR_NLOC   = SCHUR_NLOC
      mumps_par%SCHUR_LLD    = SCHUR_LLD
      mumps_par%MBLOCK = MBLOCK
      mumps_par%NBLOCK = NBLOCK
      mumps_par%NPROW  = NPROW
      mumps_par%NPCOL  = NPCOL
      IF ( COMM_F77 .NE. -987654 ) THEN
        mumps_par%COMM = COMM_F77
      ELSE
        mumps_par%COMM = MPI_COMM_WORLD
      ENDIF
      CALL MPI_BCAST(NRHS,1,MPI_INTEGER,0,mumps_par%COMM,IERR)
      IF ( IRNhere /= 0 ) mumps_par%IRN => IRN(1:NZ)
      IF ( JCNhere /= 0 ) mumps_par%JCN => JCN(1:NZ)
      IF ( Ahere /= 0 )   mumps_par%A   => A(1:NZ)
      IF ( IRN_lochere /= 0 ) mumps_par%IRN_loc => IRN_loc(1:NZ_loc)
      IF ( JCN_lochere /= 0 ) mumps_par%JCN_loc => JCN_loc(1:NZ_loc)
      IF ( A_lochere /= 0 )   mumps_par%A_loc   => A_loc(1:NZ_loc)
      IF ( ELTPTRhere /= 0 ) mumps_par%ELTPTR => ELTPTR(1:NELT+1)
      IF ( ELTVARhere /= 0 ) mumps_par%ELTVAR =>
     &   ELTVAR(1:ELTPTR(NELT+1)-1)
      IF ( A_ELThere /= 0 ) THEN
        A_ELT_SIZE = 0
        DO I = 1, NELT
          Np = ELTPTR(I+1) -ELTPTR(I)
          IF (SYM == 0) THEN
            A_ELT_SIZE = A_ELT_SIZE + Np * Np
          ELSE
            A_ELT_SIZE = A_ELT_SIZE + Np * ( Np + 1 ) / 2
          END IF
        END DO
        mumps_par%A_ELT => A_ELT(1:A_ELT_SIZE)
      END IF
      IF ( PERM_INhere /= 0) mumps_par%PERM_IN => PERM_IN(1:N)
      IF ( LISTVAR_SCHURhere /= 0)
     &   mumps_par%LISTVAR_SCHUR =>LISTVAR_SCHUR(1:SIZE_SCHUR)
      IF ( SCHURhere /= 0 ) THEN
        mumps_par%SCHUR_CINTERFACE=>SCHUR(1:1)
      ENDIF
      IF (NRHS .NE. 1) THEN
        IF ( RHShere /= 0 ) mumps_par%RHS => RHS(1:NRHS*LRHS)
        IF (REDRHShere /= 0)mumps_par%REDRHS=>REDRHS(1:NRHS*LREDRHS)
      ELSE
        IF ( RHShere /= 0 ) mumps_par%RHS => RHS(1:N)
        IF (REDRHShere /= 0)mumps_par%REDRHS=>REDRHS(1:SIZE_SCHUR)
      ENDIF
      IF ( WK_USERhere /=0 ) THEN
        IF (LWK_USER > 0 ) THEN
          mumps_par%WK_USER => WK_USER(1:LWK_USER)
        ELSE
          mumps_par%WK_USER => WK_USER(1_8:-int(LWK_USER,8)*1000000_8)
        ENDIF
      ENDIF
      IF ( COLSCAhere /= 0) mumps_par%COLSCA => COLSCA(1:N)
      IF ( ROWSCAhere /= 0) mumps_par%ROWSCA => ROWSCA(1:N)
      IF ( RHS_SPARSEhere /=0 ) mumps_par%RHS_SPARSE=>
     &                          RHS_SPARSE(1:NZ_RHS)
      IF ( IRHS_SPARSEhere /=0 ) mumps_par%IRHS_SPARSE=>
     &                          IRHS_SPARSE(1:NZ_RHS)
      IF ( SOL_lochere /=0 ) mumps_par%SOL_loc=>
     &                          SOL_loc(1:LSOL_loc*NRHS)
      IF ( ISOL_lochere /=0 ) mumps_par%ISOL_loc=>
     &                          ISOL_loc(1:LSOL_loc)
      IF ( IRHS_PTRhere /=0 ) mumps_par%IRHS_PTR=>
     &                          IRHS_PTR(1:NRHS+1)
      DO I=1,TMPDIRLEN
        mumps_par%OOC_TMPDIR(I:I)=char(OOC_TMPDIR(I))
      ENDDO
      DO I=TMPDIRLEN+1,OOC_TMPDIR_MAX_LENGTH
        mumps_par%OOC_TMPDIR(I:I)=' '
      ENDDO
      DO I=1,PREFIXLEN
        mumps_par%OOC_PREFIX(I:I)=char(OOC_PREFIX(I))
      ENDDO
      DO I=PREFIXLEN+1,OOC_PREFIX_MAX_LENGTH
        mumps_par%OOC_PREFIX(I:I)=' '
      ENDDO
      DO I=1,WRITE_PROBLEMLEN
        mumps_par%WRITE_PROBLEM(I:I)=char(WRITE_PROBLEM(I))
      ENDDO
      DO I=WRITE_PROBLEMLEN+1,PB_MAX_LENGTH
        mumps_par%WRITE_PROBLEM(I:I)=' '
      ENDDO
      CALL DMUMPS( mumps_par )
      INFO(1:40)=mumps_par%INFO(1:40)
      INFOG(1:40)=mumps_par%INFOG(1:40)
      RINFO(1:40)=mumps_par%RINFO(1:40)
      RINFOG(1:40)=mumps_par%RINFOG(1:40)
      ICNTL(1:40) = mumps_par%ICNTL(1:40)
      CNTL(1:15) = mumps_par%CNTL(1:15)
      KEEP(1:500) = mumps_par%KEEP(1:500)
      DKEEP(1:130) = mumps_par%DKEEP(1:130)
      KEEP8(1:150) = mumps_par%KEEP8(1:150)
      SYM = mumps_par%SYM
      PAR = mumps_par%PAR
      JOB = mumps_par%JOB
      N   = mumps_par%N
      NZ  = mumps_par%NZ
      NRHS = mumps_par%NRHS
      LRHS = mumps_par%LRHS
      LREDRHS = mumps_par%LREDRHS
      NZ_loc  = mumps_par%NZ_loc
      NZ_RHS  = mumps_par%NZ_RHS
      LSOL_loc= mumps_par%LSOL_loc
      SIZE_SCHUR  = mumps_par%SIZE_SCHUR
      LWK_USER = mumps_par%LWK_USER
      NELT= mumps_par%NELT
      DEFICIENCY = mumps_par%Deficiency
      SCHUR_MLOC   = mumps_par%SCHUR_MLOC
      SCHUR_NLOC   = mumps_par%SCHUR_NLOC
      SCHUR_LLD    = mumps_par%SCHUR_LLD
      MBLOCK       = mumps_par%MBLOCK
      NBLOCK       = mumps_par%NBLOCK
      NPROW        = mumps_par%NPROW
      NPCOL        = mumps_par%NPCOL
      IF ( associated (mumps_par%MAPPING) ) THEN
         CALL MUMPS_ASSIGN_MAPPING(mumps_par%MAPPING(1))
      ELSE
         CALL MUMPS_NULLIFY_C_MAPPING()
      ENDIF
      IF ( associated (mumps_par%PIVNUL_LIST) ) THEN
         CALL MUMPS_ASSIGN_PIVNUL_LIST(mumps_par%PIVNUL_LIST(1))
      ELSE
         CALL MUMPS_NULLIFY_C_PIVNUL_LIST()
      ENDIF
      IF ( associated (mumps_par%SYM_PERM) ) THEN
         CALL MUMPS_ASSIGN_SYM_PERM(mumps_par%SYM_PERM(1))
      ELSE
         CALL MUMPS_NULLIFY_C_SYM_PERM()
      ENDIF
      IF ( associated (mumps_par%UNS_PERM) ) THEN
         CALL MUMPS_ASSIGN_UNS_PERM(mumps_par%UNS_PERM(1))
      ELSE
         CALL MUMPS_NULLIFY_C_UNS_PERM()
      ENDIF
      IF (associated( mumps_par%COLSCA)) THEN
          CALL DMUMPS_ASSIGN_COLSCA(mumps_par%COLSCA(1))
      ELSE
          CALL DMUMPS_NULLIFY_C_COLSCA()
      ENDIF
      IF (associated( mumps_par%ROWSCA)) THEN
          CALL DMUMPS_ASSIGN_ROWSCA(mumps_par%ROWSCA(1))
      ELSE
          CALL DMUMPS_NULLIFY_C_ROWSCA()
      ENDIF
      IF ( JOB == -2 ) THEN
         IF (associated(mumps_par_array(INSTANCE_NUMBER)%PTR))THEN
           DEALLOCATE(mumps_par_array(INSTANCE_NUMBER)%PTR)
           NULLIFY   (mumps_par_array(INSTANCE_NUMBER)%PTR)
           N_INSTANCES = N_INSTANCES - 1
           IF ( N_INSTANCES == 0 ) THEN
             DEALLOCATE(mumps_par_array)
             DMUMPS_STRUC_ARRAY_SIZE = 0
           END IF
         ELSE
           WRITE(*,*) "** Warning: instance already freed"
           WRITE(*,*) "            this should normally not happen."
         ENDIF
      END IF
      RETURN
      END SUBROUTINE DMUMPS_F77
