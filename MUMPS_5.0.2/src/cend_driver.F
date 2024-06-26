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
      SUBROUTINE CMUMPS_END_DRIVER( id )
      USE CMUMPS_OOC
      USE CMUMPS_STRUC_DEF
      USE CMUMPS_COMM_BUFFER
      IMPLICIT NONE
      include 'mpif.h'
      TYPE( CMUMPS_STRUC ) :: id
      LOGICAL I_AM_SLAVE
      INTEGER IERR, MASTER
      PARAMETER ( MASTER = 0 )
C
      I_AM_SLAVE = ( id%MYID .ne. MASTER .OR. id%KEEP(46) .NE. 0 )
C     ----------------------------------
C     Special stuff for implementations
C     where MPI_CANCEL does not exist or
C     is not correctly implemented.
C     At the moment, this is only
C     required for the slaves.
C     ----------------------------------
      IF (id%KEEP(201).GT.0 .AND. I_AM_SLAVE) THEN
        CALL CMUMPS_CLEAN_OOC_DATA(id,IERR)
        IF (IERR < 0) THEN
          id%INFO(1) = -90
          id%INFO(2) = 0
        ENDIF
      END IF
      CALL MUMPS_PROPINFO(id%ICNTL(1), id%INFO(1),
     &     id%COMM, id%MYID)
      IF (id%root%gridinit_done) THEN
        IF ( id%KEEP(38).NE.0 .and. id%root%yes ) THEN
          CALL blacs_gridexit( id%root%CNTXT_BLACS )
          id%root%gridinit_done = .FALSE.
        END IF
      END IF
      IF ( id%MYID .NE. MASTER .OR. id%KEEP(46) .ne. 0 ) THEN
C       Note that on some old platforms, COMM_NODES would have been
C       freed inside BLACS_GRIDEXIT, which may cause problems
C       in the call to MPI_COMM_FREE. (This was the case on the
C       old SP2 in Bonn.)
        CALL MPI_COMM_FREE( id%COMM_NODES, IERR )
C       Free communicator related to load messages.
        CALL MPI_COMM_FREE( id%COMM_LOAD, IERR )
      END IF
C     -----------------------------------
C     Right-hand-side is always user data
C     We do not free it.
C     -----------------------------------
      IF (associated(id%MEM_DIST))  THEN
         DEALLOCATE(id%MEM_DIST)
         NULLIFY(id%MEM_DIST)
      ENDIF
C
C
C
C  ---------------------------------
C  Allocated by CMUMPS, Used by user.
C  CMUMPS deallocates. User should
C  use them before CMUMPS_END_DRIVER or
C  copy.
C  ---------------------------------
      IF (associated(id%MAPPING)) THEN
        DEALLOCATE(id%MAPPING)
        NULLIFY(id%MAPPING)
      END IF
      NULLIFY(id%SCHUR_CINTERFACE)
C
C     -------------------------------------
C     Always deallocate scaling arrays
C     if they are associated, except
C     when provided by the user (on master)
C     -------------------------------------
      IF ( id%KEEP(52) .NE. -1 .or. id%MYID .ne. MASTER ) THEN
        IF (associated(id%COLSCA)) THEN
          DEALLOCATE(id%COLSCA)
          NULLIFY(id%COLSCA)
        ENDIF
        IF (associated(id%ROWSCA)) THEN
          DEALLOCATE(id%ROWSCA)
          NULLIFY(id%ROWSCA)
        ENDIF
      END IF
      IF (associated(id%PTLUST_S)) THEN
        DEALLOCATE(id%PTLUST_S)
        NULLIFY(id%PTLUST_S)
      END IF
      IF (associated(id%PTRFAC)) THEN
        DEALLOCATE(id%PTRFAC)
        NULLIFY(id%PTRFAC)
      END IF
      IF (associated(id%POIDS)) THEN
        DEALLOCATE(id%POIDS)
        NULLIFY(id%POIDS)
      ENDIF
      IF (associated(id%IS)) THEN
        DEALLOCATE(id%IS)
        NULLIFY(id%IS)
      ENDIF
      IF (associated(id%IS1)) THEN
        DEALLOCATE(id%IS1)
        NULLIFY(id%IS1)
      ENDIF
      IF (associated(id%STEP))      THEN
        DEALLOCATE(id%STEP)
        NULLIFY(id%STEP)
      ENDIF
C     Begin PRUN_NODES
C     Info for pruning tree 
      IF (associated(id%Step2node))      THEN
        DEALLOCATE(id%Step2node)
        NULLIFY(id%Step2node)
      ENDIF
C     END PRUN_NODES
c     --------------------- 
      IF (associated(id%NE_STEPS))  THEN
        DEALLOCATE(id%NE_STEPS)
        NULLIFY(id%NE_STEPS)
      ENDIF
      IF (associated(id%ND_STEPS))  THEN
        DEALLOCATE(id%ND_STEPS)
        NULLIFY(id%ND_STEPS)
      ENDIF
      IF (associated(id%FRERE_STEPS))  THEN
        DEALLOCATE(id%FRERE_STEPS)
        NULLIFY(id%FRERE_STEPS)
      ENDIF
      IF (associated(id%DAD_STEPS))  THEN
        DEALLOCATE(id%DAD_STEPS)
        NULLIFY(id%DAD_STEPS)
      ENDIF
      IF (associated(id%SYM_PERM))  THEN
        DEALLOCATE(id%SYM_PERM)
        NULLIFY(id%SYM_PERM)
      ENDIF
      IF (associated(id%UNS_PERM))  THEN
        DEALLOCATE(id%UNS_PERM)
        NULLIFY(id%UNS_PERM)
      ENDIF
      IF (associated(id%PIVNUL_LIST))  THEN
        DEALLOCATE(id%PIVNUL_LIST)
        NULLIFY(id%PIVNUL_LIST)
      ENDIF
      IF (associated(id%FILS))      THEN
        DEALLOCATE(id%FILS)
        NULLIFY(id%FILS)
      ENDIF
      IF (associated(id%PTRAR))     THEN
        DEALLOCATE(id%PTRAR)
        NULLIFY(id%PTRAR)
      ENDIF
      IF (associated(id%FRTPTR))    THEN
        DEALLOCATE(id%FRTPTR)
        NULLIFY(id%FRTPTR)
      ENDIF
      IF (associated(id%FRTELT))    THEN
        DEALLOCATE(id%FRTELT)
        NULLIFY(id%FRTELT)
      ENDIF
      IF (associated(id%NA))        THEN
        DEALLOCATE(id%NA)
        NULLIFY(id%NA)
      ENDIF
      IF (associated(id%PROCNODE_STEPS)) THEN
        DEALLOCATE(id%PROCNODE_STEPS)
        NULLIFY(id%PROCNODE_STEPS)
      ENDIF
      IF (associated(id%PROCNODE)) THEN
        DEALLOCATE(id%PROCNODE)
        NULLIFY(id%PROCNODE)
      ENDIF
      IF (associated(id%RHSCOMP)) THEN
        DEALLOCATE(id%RHSCOMP)
        NULLIFY(id%RHSCOMP)
      ENDIF
      IF (associated(id%POSINRHSCOMP_ROW)) THEN
        DEALLOCATE(id%POSINRHSCOMP_ROW)
        NULLIFY(id%POSINRHSCOMP_ROW)
      ENDIF
      IF (id%POSINRHSCOMP_COL_ALLOC) THEN
        DEALLOCATE(id%POSINRHSCOMP_COL)
        NULLIFY(id%POSINRHSCOMP_COL)
      ENDIF
C     ------------------------------------------------
C     For hybrid host and element entry,
C     and DBLARR have not been allocated
C     on the master except if there was scaing.
C     ------------------------------------------------
      IF (id%KEEP(46).eq.1 .and.
     &    id%KEEP(55).ne.0 .and.
     &    id%MYID .eq. MASTER .and.
     &    id%KEEP(52) .eq. 0 ) THEN
        NULLIFY(id%DBLARR)
      ELSE
        IF (associated(id%DBLARR)) THEN
          DEALLOCATE(id%DBLARR)
          NULLIFY(id%DBLARR)
        ENDIF
      END IF
      IF (associated(id%INTARR))       THEN
        DEALLOCATE(id%INTARR)
        NULLIFY(id%INTARR)
      ENDIF
      IF (associated(id%root%RG2L_ROW))THEN
        DEALLOCATE(id%root%RG2L_ROW)
        NULLIFY(id%root%RG2L_ROW)
      ENDIF
      IF (associated(id%root%RG2L_COL))THEN
        DEALLOCATE(id%root%RG2L_COL)
        NULLIFY(id%root%RG2L_COL)
      ENDIF
C     IPIV is used both for ScaLAPACK and RR
C     Keep it outside CMUMPS_RR_FREE_POINTERS
      IF (associated(id%root%IPIV))    THEN
        DEALLOCATE(id%root%IPIV)
        NULLIFY(id%root%IPIV)
      ENDIF
      IF (associated(id%root%RHS_CNTR_MASTER_ROOT)) THEN
        DEALLOCATE(id%root%RHS_CNTR_MASTER_ROOT)
        NULLIFY(id%root%RHS_CNTR_MASTER_ROOT)
      ENDIF
      IF (associated(id%root%RHS_ROOT))THEN
        DEALLOCATE(id%root%RHS_ROOT)
        NULLIFY(id%root%RHS_ROOT)
      ENDIF
      CALL CMUMPS_RR_FREE_POINTERS(id)
      IF (associated(id%ELTPROC))     THEN
        DEALLOCATE(id%ELTPROC)
        NULLIFY(id%ELTPROC)
      ENDIF
C     id%CANDIDATES,id%I_AM_CAND and id%ISTEP_TO_INIV2
C     can be allocated on non-working master
C     in the case of arrowheads distribution
      IF (associated(id%CANDIDATES)) THEN
        DEALLOCATE(id%CANDIDATES)
        NULLIFY(id%CANDIDATES)
      ENDIF
      IF (associated(id%I_AM_CAND)) THEN
        DEALLOCATE(id%I_AM_CAND)
        NULLIFY(id%I_AM_CAND)
      ENDIF
      IF (associated(id%ISTEP_TO_INIV2)) THEN
        DEALLOCATE(id%ISTEP_TO_INIV2)
        NULLIFY(id%ISTEP_TO_INIV2)
      ENDIF
C     Node partitionning (only allocated on slaves)
      IF (I_AM_SLAVE) THEN
       IF (associated(id%TAB_POS_IN_PERE)) THEN
        DEALLOCATE(id%TAB_POS_IN_PERE)
        NULLIFY(id%TAB_POS_IN_PERE)
       ENDIF
       IF (associated(id%FUTURE_NIV2)) THEN
        DEALLOCATE(id%FUTURE_NIV2)
        NULLIFY(id%FUTURE_NIV2)
       ENDIF
      ENDIF
      IF(associated(id%DEPTH_FIRST))THEN
        DEALLOCATE(id%DEPTH_FIRST)
        NULLIFY(id%DEPTH_FIRST)
      ENDIF
      IF(associated(id%DEPTH_FIRST_SEQ))THEN
        DEALLOCATE(id%DEPTH_FIRST_SEQ)
        NULLIFY(id%DEPTH_FIRST_SEQ)
      ENDIF
      IF(associated(id%SBTR_ID))THEN
        DEALLOCATE(id%SBTR_ID)
        NULLIFY(id%SBTR_ID)
      ENDIF
      IF(associated(id%SCHED_DEP))THEN
        DEALLOCATE(id%SCHED_DEP)
        NULLIFY(id%SCHED_DEP)
      ENDIF
      IF(associated(id%SCHED_SBTR))THEN
        DEALLOCATE(id%SCHED_SBTR)
        NULLIFY(id%SCHED_SBTR)
      ENDIF
      IF(associated(id%SCHED_GRP))THEN
        DEALLOCATE(id%SCHED_GRP)
        NULLIFY(id%SCHED_GRP)
      ENDIF
      IF(associated(id%CROIX_MANU))THEN
        DEALLOCATE(id%CROIX_MANU)
        NULLIFY(id%CROIX_MANU)
      ENDIF
      IF (associated(id%MEM_SUBTREE)) THEN
        DEALLOCATE(id%MEM_SUBTREE)
        NULLIFY(id%MEM_SUBTREE)
      ENDIF
      IF (associated(id%MY_ROOT_SBTR)) THEN
        DEALLOCATE(id%MY_ROOT_SBTR)
        NULLIFY(id%MY_ROOT_SBTR)
      ENDIF
      IF (associated(id%MY_FIRST_LEAF)) THEN
        DEALLOCATE(id%MY_FIRST_LEAF)
        NULLIFY(id%MY_FIRST_LEAF)
      ENDIF
      IF (associated(id%MY_NB_LEAF)) THEN
        DEALLOCATE(id%MY_NB_LEAF)
        NULLIFY(id%MY_NB_LEAF)
      ENDIF
      IF (associated(id%COST_TRAV)) THEN
        DEALLOCATE(id%COST_TRAV)
        NULLIFY(id%COST_TRAV)
      ENDIF
c     IF (id%KEEP(201).GT.0) THEN
        IF(associated (id%OOC_INODE_SEQUENCE))THEN
           DEALLOCATE(id%OOC_INODE_SEQUENCE)
           NULLIFY(id%OOC_INODE_SEQUENCE)
        ENDIF
        IF(associated (id%OOC_TOTAL_NB_NODES))THEN
           DEALLOCATE(id%OOC_TOTAL_NB_NODES)
           NULLIFY(id%OOC_TOTAL_NB_NODES)
        ENDIF
        IF(associated (id%OOC_SIZE_OF_BLOCK))THEN
           DEALLOCATE(id%OOC_SIZE_OF_BLOCK)
           NULLIFY(id%OOC_SIZE_OF_BLOCK)
        ENDIF
        IF(associated (id%OOC_VADDR))THEN
           DEALLOCATE(id%OOC_VADDR)
           NULLIFY(id%OOC_VADDR)
        ENDIF
        IF(associated (id%OOC_NB_FILES))THEN
           DEALLOCATE(id%OOC_NB_FILES)
           NULLIFY(id%OOC_NB_FILES)
        ENDIF
c     ENDIF
C     ----------------------------------------------
C     Deallocate S only after finishing the receives
C     (S is normally the largest memory available)
C     ----------------------------------------------
      IF (id%KEEP8(24).EQ.0_8) THEN
C       -- deallocate only when not provided/allocated by the user
        IF (associated(id%S))        DEALLOCATE(id%S)
      ELSE
      ENDIF
      NULLIFY(id%S)
      IF (I_AM_SLAVE) THEN
C       ------------------------
C       Deallocate buffer for
C       contrib-blocks (facto/
C       solve). Note that this
C       will cancel all possible
C       pending requests.
C       ------------------------
        CALL CMUMPS_BUF_DEALL_CB( IERR )
C       Deallocate buffer for integers (facto/solve)
        CALL CMUMPS_BUF_DEALL_SMALL_BUF( IERR )
      END IF
C     --------------
C     Receive buffer
C     --------------
      IF ( associated( id%BUFR ) ) DEALLOCATE( id%BUFR )
      NULLIFY( id%BUFR )
C Mapping information used during solve
      IF (associated(id%IPTR_WORKING)) THEN
        DEALLOCATE(id%IPTR_WORKING)
        NULLIFY(id%IPTR_WORKING)
      END IF
      IF (associated(id%WORKING)) THEN 
        DEALLOCATE(id%WORKING)
        NULLIFY(id%WORKING)
      END IF
      RETURN
      END SUBROUTINE CMUMPS_END_DRIVER
