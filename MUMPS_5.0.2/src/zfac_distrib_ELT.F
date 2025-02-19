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
      SUBROUTINE ZMUMPS_ELT_DISTRIB(
     &            N, NELT, NA_ELT,
     &            COMM, MYID, SLAVEF,
     &            IELPTR_LOC, RELPTR_LOC,
     &            ELTVAR_LOC, ELTVAL_LOC,
     &            KEEP,KEEP8, MAXELT_SIZE,
     &            FRTPTR, FRTELT, A, LA, FILS,
     &            id, root )
      USE ZMUMPS_STRUC_DEF
      IMPLICIT NONE
      INTEGER N, NELT, NA_ELT
      INTEGER COMM, MYID, SLAVEF, MAXELT_SIZE, MSGLEN
      INTEGER(8), intent(IN) :: LA
      INTEGER FRTPTR( N+1 )
      INTEGER FRTELT( NELT ), FILS ( N )
      INTEGER KEEP(500)
      INTEGER(8) KEEP8(150)
      INTEGER IELPTR_LOC( NELT + 1 ), RELPTR_LOC( NELT + 1 )
      INTEGER ELTVAR_LOC( max(1,KEEP(14)) )
      COMPLEX(kind=8) ELTVAL_LOC( max(1,KEEP(13)) )
      COMPLEX(kind=8) A( LA )
      TYPE(ZMUMPS_STRUC)     :: id
      TYPE(ZMUMPS_ROOT_STRUC) :: root
      INTEGER numroc
      EXTERNAL numroc
      INCLUDE 'mpif.h'
      INCLUDE 'mumps_tags.h'
      INTEGER :: IERR_MPI
      INTEGER :: STATUS(MPI_STATUS_SIZE)
      INTEGER MSGTAG
      INTEGER allocok
      INTEGER I, DEST, MAXELT_REAL_SIZE, MPG, IEL, SIZEI, SIZER
      INTEGER NBRECORDS, NBUF
      INTEGER RECV_IELTPTR, RECV_RELTPTR
      INTEGER IELTPTR, RELTPTR, INODE
      LOGICAL FINI, PROKG, I_AM_SLAVE
      INTEGER(8) :: PTR_ROOT
      INTEGER LOCAL_M, LOCAL_N, LP, IBEG, IGLOB, JGLOB
      INTEGER ARROW_ROOT
      INTEGER IELT, J, K, NB_REC, IREC
      INTEGER ILOCROOT, JLOCROOT, IPOSROOT, JPOSROOT, IPTR
      INTEGER JCOL_GRID, IROW_GRID
      INTEGER IVALPTR
      INTEGER NBELROOT
      INTEGER MASTER
      PARAMETER( MASTER = 0 )
      COMPLEX(kind=8)  VAL
      COMPLEX(kind=8) ZERO
      PARAMETER( ZERO = (0.0D0,0.0D0) )
      INTEGER, DIMENSION( :, : ), ALLOCATABLE :: BUFI
      COMPLEX(kind=8), DIMENSION( :, : ), ALLOCATABLE :: BUFR
      COMPLEX(kind=8), DIMENSION( : ), ALLOCATABLE :: TEMP_ELT_R
      INTEGER, DIMENSION( : ), ALLOCATABLE :: TEMP_ELT_I
      INTEGER, DIMENSION( : ), ALLOCATABLE :: ELROOTPOS
      INTEGER, DIMENSION( : ), ALLOCATABLE, TARGET :: RG2LALLOC
      INTEGER, DIMENSION( : ), POINTER     :: RG2L
      MPG = id%ICNTL(3)
      LP  = id%ICNTL(1)
      I_AM_SLAVE = ( KEEP(46) .eq. 1 .or. MYID .ne.MASTER )
      PROKG = ( MPG > 0 .and. MYID .eq. MASTER )
      PROKG   = (PROKG.AND.(id%ICNTL(4).GE.2))
      KEEP(49) = 0
      ARROW_ROOT = 0
      IF ( MYID .eq. MASTER ) THEN
        IF ( KEEP(46) .eq. 0 ) THEN
          NBUF = SLAVEF
        ELSE
          NBUF = SLAVEF - 1
        END IF
        NBRECORDS = min(KEEP(39),NA_ELT)
        IF ( KEEP(50) .eq. 0 ) THEN
          MAXELT_REAL_SIZE = MAXELT_SIZE * MAXELT_SIZE
        ELSE
          MAXELT_REAL_SIZE = MAXELT_SIZE * (MAXELT_SIZE+1)/2
        END IF
        IF ( MAXELT_REAL_SIZE .GT. KEEP(39) ) THEN
          NBRECORDS = MAXELT_REAL_SIZE
          IF ( MPG .GT. 0 ) THEN
            WRITE(MPG,*)
     & ' ** Warning : For element distrib NBRECORDS set to ',
     & MAXELT_REAL_SIZE,' because one element is large'
          END IF
        END IF
        ALLOCATE( BUFI( 2*NBRECORDS+1, NBUF ), stat=allocok )
        IF ( allocok .gt. 0 ) THEN
          id%INFO(1) = -13
          id%INFO(2) = 2*NBRECORDS + 1
          GOTO 100
        END IF
        ALLOCATE( BUFR( NBRECORDS+1, NBUF ), stat=allocok )
        IF ( allocok .gt. 0 ) THEN
          id%INFO(1) = -13
          id%INFO(2) = NBRECORDS + 1
          GOTO 100
        END IF
        IF ( KEEP(52) .ne. 0 ) THEN
          ALLOCATE( TEMP_ELT_R( MAXELT_REAL_SIZE ), stat =allocok )
          IF ( allocok .gt. 0 ) THEN
            id%INFO(1) = -13
            id%INFO(2) = MAXELT_REAL_SIZE
            GOTO 100
          END IF
        END IF
        ALLOCATE( TEMP_ELT_I( MAXELT_SIZE ), stat=allocok )
        IF ( allocok .gt. 0 ) THEN
            id%INFO(1) = -13
            id%INFO(2) = MAXELT_SIZE
            GOTO 100
        END IF
        IF ( KEEP(38) .ne. 0 ) THEN
          NBELROOT = FRTPTR(KEEP(38)+1)-FRTPTR(KEEP(38))
          ALLOCATE( ELROOTPOS( max(NBELROOT,1) ),
     &              stat = allocok )
          IF ( allocok .gt. 0 ) THEN
              id%INFO(1) = -13
              id%INFO(2) = NBELROOT
              GOTO 100
          END IF
          IF (KEEP(46) .eq. 0 ) THEN
           ALLOCATE( RG2LALLOC( N ), stat = allocok )
           IF ( allocok .gt. 0 ) THEN
               id%INFO(1) = -13
               id%INFO(2) = N
               GOTO 100
           END IF
           INODE = KEEP(38)
           I     = 1
           DO WHILE ( INODE .GT. 0 )
             RG2LALLOC( INODE ) = I
             INODE = FILS( INODE )
             I = I + 1
           END DO
           RG2L => RG2LALLOC
          ELSE 
           RG2L => root%RG2L_ROW
          END IF
        END IF
        DO I = 1, NBUF
          BUFI( 1, I ) = 0
          BUFR( 1, I ) = ZERO
        END DO
      END IF
 100  CONTINUE
      CALL MUMPS_PROPINFO( id%ICNTL(1), id%INFO(1), COMM, MYID )
      IF ( id%INFO(1) .LT. 0 ) RETURN
      CALL MPI_BCAST( NBRECORDS, 1, MPI_INTEGER, MASTER,
     &                COMM, IERR_MPI )
      RECV_IELTPTR = 1
      RECV_RELTPTR = 1
      IF ( MYID .eq. MASTER ) THEN
        NBELROOT = 0
        RELTPTR = 1
        RELPTR_LOC(1) = 1
        DO IEL = 1, NELT
          IELTPTR = id%ELTPTR( IEL )
          SIZEI   = id%ELTPTR( IEL + 1 ) - IELTPTR
          IF ( KEEP( 50 ) .eq. 0 ) THEN
            SIZER = SIZEI * SIZEI
          ELSE
            SIZER = SIZEI * ( SIZEI + 1 ) / 2
          END IF
          DEST = id%ELTPROC( IEL )
          IF ( DEST .eq. -2 ) THEN
            NBELROOT = NBELROOT + 1
            FRTELT( FRTPTR(KEEP(38)) + NBELROOT - 1 ) = IEL
            ELROOTPOS( NBELROOT ) = RELTPTR
            GOTO 200
          END IF
          IF ( DEST .ge. 0 .and. KEEP(46) .eq. 0 ) DEST = DEST + 1
          IF ( KEEP(52) .ne. 0 ) THEN
            CALL ZMUMPS_SCALE_ELEMENT( N, SIZEI, SIZER,
     &               id%ELTVAR( IELTPTR ), id%A_ELT( RELTPTR ),
     &               TEMP_ELT_R(1), MAXELT_REAL_SIZE,
     &               id%ROWSCA(1), id%COLSCA(1), KEEP(50) )
          END IF
          IF ( DEST .eq. 0 .or. ( DEST .eq. -1 .and. KEEP(46) .ne. 0 ) )
     &      THEN
            ELTVAR_LOC( RECV_IELTPTR: RECV_IELTPTR + SIZEI - 1 )
     &      = id%ELTVAR( IELTPTR: IELTPTR + SIZEI - 1 )
            RECV_IELTPTR = RECV_IELTPTR + SIZEI
            IF ( KEEP(52) .ne. 0 ) THEN
              ELTVAL_LOC( RECV_RELTPTR: RECV_RELTPTR + SIZER - 1)
     &        = TEMP_ELT_R( 1: SIZER )
              RECV_RELTPTR = RECV_RELTPTR + SIZER
            END IF
          END IF
          IF ( DEST .NE. 0 .AND. DEST. NE. -3 ) THEN
            IF ( KEEP(52) .eq. 0 ) THEN
              CALL ZMUMPS_ELT_FILL_BUF(
     &           id%ELTVAR(IELTPTR),
     &           id%A_ELT (RELTPTR),
     &           SIZEI, SIZER,
     &
     &           DEST, NBUF, NBRECORDS,
     &           BUFI, BUFR, COMM )
            ELSE
              CALL ZMUMPS_ELT_FILL_BUF(
     &           id%ELTVAR(IELTPTR),
     &           TEMP_ELT_R( 1 ),
     &           SIZEI, SIZER,
     &
     &           DEST, NBUF, NBRECORDS,
     &           BUFI, BUFR, COMM )
            END IF
          END IF
 200      CONTINUE
          RELTPTR = RELTPTR + SIZER
          IF ( KEEP(46) .eq. 0 .OR. KEEP(52) .eq. 0 ) THEN
            RELPTR_LOC( IEL + 1 ) = RELTPTR
          ELSE
            RELPTR_LOC( IEL + 1 ) = RECV_RELTPTR
          ENDIF
        END DO
        IF ( KEEP(46) .eq. 0 .OR. KEEP(52) .eq. 0 ) THEN
          KEEP(13) = RELTPTR - 1
        ELSE
          KEEP(13) = RECV_RELTPTR - 1
        ENDIF
        IF ( RELTPTR - 1 .ne. id%NA_ELT ) THEN
          WRITE(*,*) ' ** ERROR ELT DIST: RELPTR - 1 / id%NA_ELT=',
     &               RELTPTR - 1,id%NA_ELT
          CALL MUMPS_ABORT()
        END IF
        DEST = -2
        IELTPTR = 1
        RELTPTR = 1
        SIZEI   = 1
        SIZER   = 1
        CALL ZMUMPS_ELT_FILL_BUF(
     &           id%ELTVAR(IELTPTR),
     &           id%A_ELT (RELTPTR),
     &           SIZEI, SIZER,
     &
     &           DEST, NBUF, NBRECORDS,
     &           BUFI, BUFR, COMM )
        IF ( KEEP(52) .NE. 0 ) DEALLOCATE( TEMP_ELT_R )
      ELSE
        FINI = ( RECV_IELTPTR .eq. IELPTR_LOC( NELT+1 )
     &     .and. RECV_RELTPTR .eq. RELPTR_LOC( NELT+1 ) )
        DO WHILE ( .not. FINI )
          CALL MPI_PROBE( MASTER, MPI_ANY_TAG,
     &                    COMM, STATUS, IERR_MPI )
          MSGTAG = STATUS( MPI_TAG    )
          SELECT CASE ( MSGTAG )
             CASE( ELT_INT )
               CALL MPI_GET_COUNT( STATUS, MPI_INTEGER,
     &                             MSGLEN, IERR_MPI )
               CALL MPI_RECV( ELTVAR_LOC( RECV_IELTPTR ), MSGLEN,
     &            MPI_INTEGER, MASTER, ELT_INT,
     &            COMM, STATUS, IERR_MPI )
               RECV_IELTPTR = RECV_IELTPTR + MSGLEN
             CASE( ELT_REAL )
                CALL MPI_GET_COUNT( STATUS, MPI_DOUBLE_COMPLEX,
     &                              MSGLEN, IERR_MPI )
                CALL MPI_RECV( ELTVAL_LOC( RECV_RELTPTR ), MSGLEN,
     &            MPI_DOUBLE_COMPLEX, MASTER, ELT_REAL,
     &            COMM, STATUS, IERR_MPI )
                RECV_RELTPTR = RECV_RELTPTR + MSGLEN
          END SELECT
          FINI = ( RECV_IELTPTR .eq. IELPTR_LOC( NELT+1 )
     &       .and. RECV_RELTPTR .eq. RELPTR_LOC( NELT+1 ) )
        END DO
      END IF
      IF ( KEEP(38) .NE. 0 ) THEN
         IF ( I_AM_SLAVE .and. root%yes ) THEN
          IF (KEEP(60)==0) THEN
           LOCAL_M = numroc( root%ROOT_SIZE, root%MBLOCK,
     &             root%MYROW, 0, root%NPROW )
           LOCAL_M = max( 1, LOCAL_M )
           LOCAL_N = numroc( root%ROOT_SIZE, root%NBLOCK,
     &               root%MYCOL, 0, root%NPCOL )
           PTR_ROOT = LA - int(LOCAL_M,8) * int(LOCAL_N,8) + 1_8
           IF ( PTR_ROOT .LE. LA ) THEN
             A( PTR_ROOT:LA ) = ZERO
           END IF
          ELSE
           DO I = 1, root%SCHUR_NLOC
            root%SCHUR_POINTER((I-1)*root%SCHUR_LLD+1:
     &      (I-1)*root%SCHUR_LLD+root%SCHUR_MLOC)=ZERO
           ENDDO
          ENDIF
         END IF
        IF ( MYID .NE. MASTER ) THEN
          ALLOCATE( BUFI( NBRECORDS * 2 + 1, 1 ), stat = allocok )
          IF ( allocok .GT. 0 ) THEN
            id%INFO(1) = -13
            id%INFO(2) = NBRECORDS * 2 + 1
            GOTO 250
          END IF
          ALLOCATE( BUFR( NBRECORDS, 1 )        , stat = allocok )
          IF ( allocok .GT. 0 ) THEN
            id%INFO(1) = -13
            id%INFO(2) = NBRECORDS
          END IF
        END IF
 250    CONTINUE
        CALL MUMPS_PROPINFO( id%ICNTL(1), id%INFO(1), COMM, MYID )
        IF ( id%INFO(1) .LT. 0 ) RETURN
        IF ( MYID .eq. MASTER ) THEN
        DO IPTR = FRTPTR(KEEP(38)), FRTPTR(KEEP(38)+1) - 1
          IELT = FRTELT( IPTR )
          SIZEI = id%ELTPTR( IELT + 1 ) - id%ELTPTR( IELT )
          DO I = 1, SIZEI
            TEMP_ELT_I( I ) = RG2L
     &              ( id%ELTVAR( id%ELTPTR(IELT) + I - 1 ) )
          END DO
          IVALPTR = ELROOTPOS( IPTR - FRTPTR(KEEP(38)) + 1 ) - 1
          K = 1
          DO J = 1, SIZEI
            JGLOB = id%ELTVAR( id%ELTPTR( IELT ) + J - 1 )
            IF ( KEEP(50).eq. 0 ) THEN
              IBEG = 1
            ELSE
              IBEG = J
            END IF
            DO I = IBEG, SIZEI
              IGLOB = id%ELTVAR( id%ELTPTR( IELT ) + I - 1 )
              IF ( KEEP(52) .eq. 0 ) THEN
                VAL = id%A_ELT( IVALPTR + K )
              ELSE
                VAL = id%A_ELT( IVALPTR + K ) *
     &                id%ROWSCA( IGLOB ) * id%COLSCA( JGLOB )
              END IF
              IF ( KEEP(50).eq.0 ) THEN
                IPOSROOT = TEMP_ELT_I( I )
                JPOSROOT = TEMP_ELT_I( J )
              ELSE
                IF ( TEMP_ELT_I(I) .GT. TEMP_ELT_I(J) ) THEN
                  IPOSROOT = TEMP_ELT_I(I)
                  JPOSROOT = TEMP_ELT_I(J)
                ELSE
                  IPOSROOT = TEMP_ELT_I(J)
                  JPOSROOT = TEMP_ELT_I(I)
                END IF
              END IF
              IROW_GRID = mod( ( IPOSROOT - 1 )/root%MBLOCK,
     &                           root%NPROW )
              JCOL_GRID = mod( ( JPOSROOT - 1 )/root%NBLOCK,
     &                           root%NPCOL )
              IF ( KEEP(46) .eq. 0 ) THEN
                DEST = IROW_GRID * root%NPCOL + JCOL_GRID + 1
              ELSE
                DEST = IROW_GRID * root%NPCOL + JCOL_GRID
              END IF
              IF ( DEST .eq. MASTER ) THEN
                ARROW_ROOT = ARROW_ROOT + 1
                ILOCROOT = root%MBLOCK * ( ( IPOSROOT - 1 ) /
     &                 ( root%MBLOCK * root%NPROW ) )
     &               + mod( IPOSROOT - 1, root%MBLOCK ) + 1
                JLOCROOT = root%NBLOCK * ( ( JPOSROOT - 1 ) /
     &                 ( root%NBLOCK * root%NPCOL ) )
     &               + mod( JPOSROOT - 1, root%NBLOCK ) + 1
              IF (KEEP(60)==0) THEN
                A( PTR_ROOT
     &             + int(JLOCROOT - 1,8) * int(LOCAL_M,8)
     &             + int(ILOCROOT - 1,8) )
     &          =  A( PTR_ROOT
     &             + int(JLOCROOT - 1,8) * int(LOCAL_M,8)
     &             + int(ILOCROOT - 1,8) )
     &          + VAL
              ELSE
                root%SCHUR_POINTER( int(JLOCROOT-1,8)
     &                            * int(root%SCHUR_LLD,8)
     &                            + int(ILOCROOT,8) )
     &          = root%SCHUR_POINTER( int(JLOCROOT-1,8)
     &                            * int(root%SCHUR_LLD,8)
     &                            + int(ILOCROOT,8) )
     &          + VAL
              ENDIF
              ELSE
                CALL ZMUMPS_ARROW_FILL_SEND_BUF(
     &          IPOSROOT, JPOSROOT, VAL, DEST, BUFI, BUFR, NBRECORDS,
     &          NBUF, LP, COMM, KEEP(46) )
              END IF
              K = K + 1
            END DO
          END DO
        END DO
        CALL ZMUMPS_ARROW_FINISH_SEND_BUF(
     &          BUFI, BUFR, NBRECORDS,
     &          NBUF, LP, COMM, KEEP(46) )
        ELSE
          FINI = .FALSE.
          DO WHILE ( .not. FINI )
            CALL MPI_RECV( BUFI(1,1), 2*NBRECORDS+1,
     &                MPI_INTEGER, MASTER,
     &                ARROWHEAD,
     &                COMM, STATUS, IERR_MPI )
            NB_REC = BUFI(1,1)
            IF (NB_REC.LE.0) THEN
              FINI = .TRUE.
              NB_REC = -NB_REC
            ENDIF
            IF (NB_REC.EQ.0) EXIT
            CALL MPI_RECV( BUFR(1,1), NBRECORDS, MPI_DOUBLE_COMPLEX,
     &                     MASTER, ARROWHEAD,
     &                     COMM, STATUS, IERR_MPI )
            ARROW_ROOT = ARROW_ROOT + NB_REC
            DO IREC = 1, NB_REC
              IPOSROOT = BUFI( IREC * 2, 1 )
              JPOSROOT = BUFI( IREC * 2 + 1, 1 )
              VAL      = BUFR( IREC, 1 )
              ILOCROOT = root%MBLOCK * ( ( IPOSROOT - 1 ) /
     &                 ( root%MBLOCK * root%NPROW ) )
     &               + mod( IPOSROOT - 1, root%MBLOCK ) + 1
              JLOCROOT = root%NBLOCK * ( ( JPOSROOT - 1 ) /
     &                 ( root%NBLOCK * root%NPCOL ) )
     &               + mod( JPOSROOT - 1, root%NBLOCK ) + 1
              IF (KEEP(60).eq.0) THEN
                 A( PTR_ROOT + int(JLOCROOT-1,8) * int(LOCAL_M,8)
     &                       + int(ILOCROOT-1,8))
     &        =  A( PTR_ROOT + int(JLOCROOT-1,8) * int(LOCAL_M,8)
     &                       + int(ILOCROOT-1,8))
     &           + VAL
              ELSE
                root%SCHUR_POINTER(int(JLOCROOT-1,8)
     &                         * int(root%SCHUR_LLD,8)
     &                         + int(ILOCROOT,8) )
     &        = root%SCHUR_POINTER( int(JLOCROOT - 1,8)
     &                         * int(root%SCHUR_LLD,8)
     &                         + int(ILOCROOT,8))
     &          + VAL
              ENDIF
            END DO
          END DO
          DEALLOCATE( BUFI )
          DEALLOCATE( BUFR )
        END IF
      END IF
      IF ( MYID .eq. MASTER ) THEN
        DEALLOCATE( BUFI )
        DEALLOCATE( BUFR )
        IF (KEEP(38).ne.0) THEN 
          DEALLOCATE(ELROOTPOS)
          IF (KEEP(46) .eq. 0 ) THEN
             DEALLOCATE(RG2LALLOC)
          ENDIF
        ENDIF
        DEALLOCATE( TEMP_ELT_I )
      END IF
      KEEP(49) = ARROW_ROOT
      RETURN
      END SUBROUTINE ZMUMPS_ELT_DISTRIB
      SUBROUTINE ZMUMPS_ELT_FILL_BUF(
     &       ELNODES, ELVAL, SIZEI, SIZER,
     &       DEST, NBUF, NBRECORDS, BUFI, BUFR, COMM )
      IMPLICIT NONE
      INTEGER SIZEI, SIZER, DEST, NBUF, NBRECORDS, COMM
      INTEGER ELNODES( SIZEI ), BUFI( 2*NBRECORDS + 1, NBUF )
      COMPLEX(kind=8) ELVAL( SIZER ), BUFR( NBRECORDS + 1, NBUF )
      INCLUDE 'mumps_tags.h'
      INCLUDE 'mpif.h'
      INTEGER I, IBEG, IEND, IERR_MPI, NBRECR
      INTEGER NBRECI
      COMPLEX(kind=8) ZERO
      PARAMETER( ZERO = (0.0D0,0.0D0) )
      IF ( DEST .lt. 0 ) THEN
        IBEG = 1
        IEND = NBUF
      ELSE
        IBEG = DEST
        IEND = DEST
      END IF
      DO I = IBEG, IEND
        NBRECI = BUFI(1,I)
        IF ( NBRECI .ne.0  .and.
     &       ( DEST.eq.-2 .or.
     &         NBRECI + SIZEI .GT. 2*NBRECORDS ) ) THEN
           CALL MPI_SEND( BUFI(2, I), NBRECI, MPI_INTEGER,
     &                    I, ELT_INT, COMM, IERR_MPI )
           BUFI(1,I) = 0
           NBRECI    = 0
        END IF
        NBRECR = int(dble(BUFR(1,I))+0.5D0)
        IF ( NBRECR .ne.0  .and.
     &       ( DEST.eq.-2 .or.
     &         NBRECR + SIZER .GT. NBRECORDS ) ) THEN
           CALL MPI_SEND( BUFR(2, I), NBRECR, MPI_DOUBLE_COMPLEX,
     &                    I, ELT_REAL, COMM, IERR_MPI )
           BUFR(1,I) = ZERO
           NBRECR    = 0
        END IF
        IF ( DEST .ne. -2 ) THEN
          BUFI( 2 + NBRECI : 2 + NBRECI + SIZEI - 1, I ) =
     &    ELNODES( 1: SIZEI )
          BUFR( 2 + NBRECR : 2 + NBRECR + SIZER - 1, I ) =
     &    ELVAL( 1: SIZER )
          BUFI(1,I) = NBRECI + SIZEI
          BUFR(1,I) = cmplx( NBRECR + SIZER, kind=kind(BUFR) )
        END IF
      END DO
      RETURN
      END SUBROUTINE ZMUMPS_ELT_FILL_BUF
      SUBROUTINE ZMUMPS_MAXELT_SIZE( ELTPTR, NELT, MAXELT_SIZE )
      INTEGER NELT, MAXELT_SIZE
      INTEGER ELTPTR( NELT + 1 )
      INTEGER I, S
      MAXELT_SIZE = 0
      DO I = 1, NELT
        S = ELTPTR( I + 1 ) - ELTPTR( I )
        MAXELT_SIZE = max( S, MAXELT_SIZE )
      END DO
      RETURN
      END SUBROUTINE ZMUMPS_MAXELT_SIZE
      SUBROUTINE ZMUMPS_SCALE_ELEMENT( N, SIZEI, SIZER,
     &               ELTVAR, ELTVAL,
     &               SELTVAL, LSELTVAL,
     &               ROWSCA, COLSCA, K50 )
      INTEGER N, SIZEI, SIZER, LSELTVAL, K50
      INTEGER ELTVAR( SIZEI )
      COMPLEX(kind=8) ELTVAL( SIZER )
      COMPLEX(kind=8) SELTVAL( LSELTVAL )
      DOUBLE PRECISION ROWSCA( N ), COLSCA( N )
      INTEGER I, J, K
      K = 1
      IF ( K50 .eq. 0 ) THEN
        DO J = 1, SIZEI
          DO I = 1, SIZEI
            SELTVAL(K) = ELTVAL(K) *
     &                   ROWSCA(ELTVAR(I)) *
     &                   COLSCA(ELTVAR(J))
            K = K + 1
          END DO
        END DO
      ELSE
        DO J = 1, SIZEI
          DO I = J, SIZEI
            SELTVAL(K) = ELTVAL(K) *
     &                   ROWSCA(ELTVAR(I)) *
     &                   COLSCA(ELTVAR(J))
            K = K + 1
          END DO
        END DO
      END IF
      RETURN
      END SUBROUTINE ZMUMPS_SCALE_ELEMENT
