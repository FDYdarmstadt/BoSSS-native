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
      SUBROUTINE DMUMPS_CREATEPARTVEC(MYID, NUMPROCS, COMM,
     & IRN_loc, JCN_loc, NZ_loc,
     & IPARTVEC, ISZ, OSZ,
     & IWRK, IWSZ)
      IMPLICIT NONE
      EXTERNAL DMUMPS_BUREDUCE
      INTEGER MYID, NUMPROCS, COMM
      INTEGER NZ_loc, ISZ, IWSZ, OSZ
      INTEGER IRN_loc(NZ_loc), JCN_loc(NZ_loc)
      INTEGER IPARTVEC(ISZ)
      INTEGER IWRK(IWSZ)
      INCLUDE 'mpif.h'
C
C     LOCAL VARS
      INTEGER I
      INTEGER OP, IERROR
      INTEGER IR, IC
C
      IF(NUMPROCS.NE.1) THEN
C     CHECK done outsize
C     IF(IWSZ < 4*ISZ) THEN
C     CHECK ENDS
         CALL MPI_OP_CREATE(DMUMPS_BUREDUCE, .TRUE., OP, IERROR)
C     PERFORM THE REDUCTION
         CALL DMUMPS_IBUINIT(IWRK, 4*ISZ, ISZ)
C     WE FIRST ZERO OUT  
         DO I=1,ISZ
            IWRK(2*I-1) = 0
            IWRK(2*I) = MYID
         ENDDO
         DO I=1,NZ_loc
            IR = IRN_loc(I)
            IC = JCN_loc(I)
            IF((IR.GE.1).AND.(IR.LE.ISZ).AND.
     &           (IC.GE.1).AND.(IC.LE.OSZ)) THEN
               IWRK(2*IR-1) = IWRK(2*IR-1) + 1
            ENDIF
         ENDDO
         CALL MPI_ALLREDUCE(IWRK(1), IWRK(1+2*ISZ), ISZ,
     &        MPI_2INTEGER, OP, COMM, IERROR)      
         DO I=1,ISZ
            IPARTVEC(I) = IWRK(2*I+2*ISZ)
         ENDDO
C     FREE THE OPERATOR
         CALL MPI_OP_FREE(OP, IERROR)
      ELSE
         DO I=1,ISZ
            IPARTVEC(I) = 0
         ENDDO
      ENDIF
      RETURN
      END SUBROUTINE DMUMPS_CREATEPARTVEC
C
C     SEPARATOR: Another function begins
C
C 
      SUBROUTINE DMUMPS_FINDNUMMYROWCOL(MYID, NUMPROCS, COMM,
     &     IRN_loc, JCN_loc, NZ_loc,
     &     ROWPARTVEC, COLPARTVEC, M, N,
     &     INUMMYR,
     &     INUMMYC,     
     &     IWRK, IWSZ)
      IMPLICIT NONE
      INTEGER MYID, NUMPROCS, NZ_loc, M, N
      INTEGER IRN_loc(NZ_loc), JCN_loc(NZ_loc)
      INTEGER ROWPARTVEC(M)
      INTEGER COLPARTVEC(N)
      INTEGER INUMMYR, INUMMYC
      INTEGER IWSZ
      INTEGER IWRK(IWSZ)
      INTEGER COMM
C
      INTEGER I, IR, IC
C check done outsize     
C     IF(IWSZ < M) THEN ERROR
C     IF(IWSZ < N) THEN ERROR
      INUMMYR = 0
      INUMMYC = 0
C     MARK MY ROWS. FIRST COUNT,
C          IF DYNAMIC MEMORY ALLOCATIOn WILL USED
      DO I=1,M
         IWRK(I) = 0
         IF(ROWPARTVEC(I).EQ.MYID) THEN
            IWRK(I)=1
            INUMMYR = INUMMYR + 1
         ENDIF
      ENDDO
      DO I=1,NZ_loc
         IR = IRN_loc(I)
         IC = JCN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.M).AND.
     &        ((IC.GE.1).AND.(IC.LE.N)) ) THEN
            IF(IWRK(IR) .EQ. 0) THEN
               IWRK(IR)= 1
               INUMMYR = INUMMYR + 1
            ENDIF
         ENDIF
      ENDDO
C     DO THE SMAME THING FOR COLS
      DO I=1,N
         IWRK(I) = 0
         IF(COLPARTVEC(I).EQ.MYID) THEN
            IWRK(I)= 1
            INUMMYC = INUMMYC + 1
         ENDIF
      ENDDO
      DO I=1,NZ_loc
         IC = JCN_loc(I)
         IR = IRN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.M).AND.
     &        ((IC.GE.1).AND.(IC.LE.N)) ) THEN
            IF(IWRK(IC) .EQ. 0) THEN
               IWRK(IC)= 1
               INUMMYC = INUMMYC + 1
            ENDIF
         ENDIF
      ENDDO
C
      RETURN
      END SUBROUTINE DMUMPS_FINDNUMMYROWCOL
      SUBROUTINE DMUMPS_FILLMYROWCOLINDICES(MYID, NUMPROCS,COMM,    
     &     IRN_loc, JCN_loc, NZ_loc,
     &     ROWPARTVEC, COLPARTVEC, M, N,
     &     MYROWINDICES, INUMMYR,
     &     MYCOLINDICES, INUMMYC,     
     &     IWRK, IWSZ  )
      IMPLICIT NONE
      INTEGER MYID, NUMPROCS, NZ_loc, M, N
      INTEGER INUMMYR, INUMMYC, IWSZ
      INTEGER IRN_loc(NZ_loc), JCN_loc(NZ_loc)
      INTEGER ROWPARTVEC(M)
      INTEGER COLPARTVEC(N)
      INTEGER MYROWINDICES(INUMMYR)
      INTEGER MYCOLINDICES(INUMMYC)
      INTEGER IWRK(IWSZ)
      INTEGER COMM
C
      INTEGER I, IR, IC, ITMP, MAXMN
C      
      MAXMN = M
      IF(N > MAXMN) MAXMN = N
C check done outsize
C      IF(IWSZ < MAXMN) THEN ERROR
C     MARK MY ROWS. 
      DO I=1,M
         IWRK(I) = 0
         IF(ROWPARTVEC(I).EQ.MYID) IWRK(I)=1
      ENDDO
      DO I=1,NZ_loc
         IR = IRN_loc(I)         
         IC = JCN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.M).AND.
     &      ((IC.GE.1).AND.(IC.LE.N))  ) THEN
            IF(IWRK(IR) .EQ. 0) IWRK(IR)= 1
         ENDIF
      ENDDO
C     PUT MY ROWS INTO MYROWINDICES
      ITMP = 1
      DO I=1,M
         IF(IWRK(I).EQ.1) THEN
            MYROWINDICES(ITMP) = I
            ITMP  = ITMP + 1
         ENDIF
      ENDDO
C
C
C     DO THE SMAME THING FOR COLS
      DO I=1,N
         IWRK(I) = 0
         IF(COLPARTVEC(I).EQ.MYID) IWRK(I)= 1
      ENDDO
      DO I=1,NZ_loc
         IR = IRN_loc(I)         
         IC = JCN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.M).AND.
     &      ((IC.GE.1).AND.(IC.LE.N))  ) THEN
            IF(IWRK(IC) .EQ. 0) IWRK(IC)= 1
         ENDIF
      ENDDO
C     PUT MY ROWS INTO MYROWINDICES
      ITMP = 1
      DO I=1,N
         IF(IWRK(I).EQ.1) THEN
            MYCOLINDICES(ITMP) = I
            ITMP  = ITMP + 1
         ENDIF
      ENDDO
C
      RETURN
      END SUBROUTINE DMUMPS_FILLMYROWCOLINDICES
C
C     SEPARATOR: Another function begins
C
C 
      INTEGER FUNCTION DMUMPS_CHK1LOC(D, DSZ, INDX, INDXSZ, EPS)
      IMPLICIT NONE
      INTEGER DSZ, INDXSZ
      DOUBLE PRECISION D(DSZ)
      INTEGER INDX(INDXSZ)
      DOUBLE PRECISION EPS
C     LOCAL VARS
      INTEGER I, IID
      DOUBLE PRECISION RONE
      PARAMETER(RONE=1.0D0)
      DMUMPS_CHK1LOC = 1
      DO I=1, INDXSZ
         IID = INDX(I)
         IF (.NOT.( (D(IID).LE.(RONE+EPS)).AND.
     &        ((RONE-EPS).LE.D(IID)) )) THEN
            DMUMPS_CHK1LOC = 0         
         ENDIF
      ENDDO
      RETURN
      END FUNCTION DMUMPS_CHK1LOC
      INTEGER FUNCTION DMUMPS_CHK1CONV(D, DSZ, EPS)
      IMPLICIT NONE
      INTEGER DSZ
      DOUBLE PRECISION D(DSZ)
      DOUBLE PRECISION EPS
C     LOCAL VARS
      INTEGER I
      DOUBLE PRECISION RONE
      PARAMETER(RONE=1.0D0)
      DMUMPS_CHK1CONV = 1
      DO I=1, DSZ
         IF (.NOT.( (D(I).LE.(RONE+EPS)).AND.
     &        ((RONE-EPS).LE.D(I)) )) THEN
            DMUMPS_CHK1CONV = 0         
         ENDIF
      ENDDO
      RETURN
      END FUNCTION DMUMPS_CHK1CONV
C
C     SEPARATOR: Another function begins
C
      INTEGER FUNCTION DMUMPS_CHKCONVGLO(DR, M, INDXR, INDXRSZ,
     &     DC, N, INDXC, INDXCSZ, EPS, COMM)
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      INTEGER M, N, INDXRSZ, INDXCSZ
      DOUBLE PRECISION DR(M), DC(N)
      INTEGER INDXR(INDXRSZ), INDXC(INDXCSZ)
      DOUBLE PRECISION EPS
      INTEGER COMM
      EXTERNAL DMUMPS_CHK1LOC
      INTEGER  DMUMPS_CHK1LOC
      INTEGER GLORES, MYRESR, MYRESC, MYRES
      INTEGER IERR
      MYRESR =  DMUMPS_CHK1LOC(DR, M, INDXR, INDXRSZ, EPS)
      MYRESC =  DMUMPS_CHK1LOC(DC, N, INDXC, INDXCSZ, EPS)
      MYRES = MYRESR + MYRESC
      CALL MPI_ALLREDUCE(MYRES, GLORES, 1, MPI_INTEGER,
     &     MPI_SUM, COMM, IERR)
      DMUMPS_CHKCONVGLO = GLORES
      RETURN
      END FUNCTION DMUMPS_CHKCONVGLO
C
C     SEPARATOR: Another function begins
C
      DOUBLE PRECISION FUNCTION DMUMPS_ERRSCALOC(D, TMPD, DSZ,
     &     INDX, INDXSZ)
C     THE VAR D IS NOT USED IN COMPUTATIONS.
C     IT IS THERE FOR READIBLITY OF THE *simScaleAbs.F
      IMPLICIT NONE 
      INTEGER DSZ, INDXSZ
      DOUBLE PRECISION D(DSZ)
      DOUBLE PRECISION TMPD(DSZ)
      INTEGER INDX(INDXSZ)
C     LOCAL VARS
      DOUBLE PRECISION RONE
      PARAMETER(RONE=1.0D0)
      INTEGER I, IIND
      DOUBLE PRECISION ERRMAX
      INTRINSIC abs
      ERRMAX = -RONE
      DO I=1,INDXSZ
         IIND = INDX(I)
         IF(abs(RONE-TMPD(IIND)).GT.ERRMAX) THEN
            ERRMAX = abs(RONE-TMPD(IIND))
         ENDIF
      ENDDO           
      DMUMPS_ERRSCALOC = ERRMAX
      RETURN
      END FUNCTION DMUMPS_ERRSCALOC
      DOUBLE PRECISION FUNCTION DMUMPS_ERRSCA1(D, TMPD, DSZ)
      IMPLICIT NONE 
      INTEGER DSZ
      DOUBLE PRECISION D(DSZ)
      DOUBLE PRECISION TMPD(DSZ)
C     LOCAL VARS
      DOUBLE PRECISION RONE
      PARAMETER(RONE=1.0D0)
      INTEGER I
      DOUBLE PRECISION ERRMAX1
      INTRINSIC abs
      ERRMAX1 = -RONE
      DO I=1,DSZ
         IF(abs(RONE-TMPD(I)).GT.ERRMAX1) THEN
            ERRMAX1 = abs(RONE-TMPD(I))
         ENDIF
      ENDDO
      DMUMPS_ERRSCA1 = ERRMAX1
      RETURN
      END FUNCTION DMUMPS_ERRSCA1
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_UPDATESCALE(D,  TMPD, DSZ,
     &        INDX, INDXSZ)
      IMPLICIT NONE
      INTEGER DSZ, INDXSZ
      DOUBLE PRECISION D(DSZ)
      DOUBLE PRECISION TMPD(DSZ)
      INTEGER INDX(INDXSZ)
      INTRINSIC sqrt
C     LOCAL VARS
      INTEGER I, IIND
      DOUBLE PRECISION RZERO
      PARAMETER(RZERO=0.0D0)
      DO I=1,INDXSZ
         IIND = INDX(I)
         IF (TMPD(IIND).NE.RZERO) D(IIND) = D(IIND)/sqrt(TMPD(IIND))
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_UPDATESCALE
      SUBROUTINE DMUMPS_UPSCALE1(D,  TMPD, DSZ)
      IMPLICIT NONE
      INTEGER DSZ
      DOUBLE PRECISION D(DSZ)
      DOUBLE PRECISION TMPD(DSZ)
      INTRINSIC sqrt
C     LOCAL VARS
      INTEGER I
      DOUBLE PRECISION RZERO
      PARAMETER(RZERO=0.0D0)
      DO I=1,DSZ
         IF (TMPD(I) .NE. RZERO) D(I) = D(I)/sqrt(TMPD(I))
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_UPSCALE1
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_INITREALLST(D, DSZ, INDX, INDXSZ, VAL)
      IMPLICIT NONE
      INTEGER DSZ, INDXSZ
      DOUBLE PRECISION D(DSZ)
      INTEGER INDX(INDXSZ)
      DOUBLE PRECISION VAL
C     LOCAL VARS
      INTEGER I, IIND
      DO I=1,INDXSZ
         IIND = INDX(I)
         D(IIND) = VAL
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_INITREALLST
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_INVLIST(D, DSZ, INDX, INDXSZ)
      IMPLICIT NONE
      INTEGER DSZ, INDXSZ
      DOUBLE PRECISION D(DSZ)
      INTEGER INDX(INDXSZ)
C     LOCALS
      INTEGER I, IIND
      DO I=1,INDXSZ
         IIND  = INDX(I)
         D(IIND) = 1.0D0/D(IIND)
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_INVLIST
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_INITREAL(D, DSZ, VAL)
      IMPLICIT NONE
      INTEGER DSZ
      DOUBLE PRECISION D(DSZ)
      DOUBLE PRECISION VAL
C     LOCAL VARS
      INTEGER I
      DO I=1,DSZ
         D(I) = VAL
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_INITREAL
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_ZEROOUT(TMPD, TMPSZ, INDX, INDXSZ)
      IMPLICIT NONE
      INTEGER TMPSZ,INDXSZ 
      DOUBLE PRECISION TMPD(TMPSZ)
      INTEGER INDX(INDXSZ)
C     LOCAL VAR
      INTEGER I
      DOUBLE PRECISION DZERO
      PARAMETER(DZERO=0.0D0)
      DO I=1,INDXSZ
         TMPD(INDX(I)) = DZERO
      ENDDO      
      RETURN
      END SUBROUTINE DMUMPS_ZEROOUT
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_BUREDUCE(INV, INOUTV, LEN, DTYPE)
C
C    Like MPI_MINLOC operation (with ties broken sometimes with min 
C                               and sometimes with max)
C     The objective is find for each entry row/col
C     the processor with largest number of entries in its row/col
C     When 2 procs have the same number of entries in the row/col
C     then
C         if this number of entries is odd we take the proc with largest id
C         if this number of entries is even we take the proc with smallest id
C     
      IMPLICIT NONE
      INTEGER LEN
      INTEGER INV(2*LEN) 
      INTEGER INOUTV(2*LEN)
      INTEGER DTYPE
      INTEGER I
      INTEGER DIN, DINOUT, PIN, PINOUT
      DO I=1,2*LEN-1,2
         DIN = INV(I)     ! nb of entries in row/col
         PIN = INV(I+1)   ! proc number
         DINOUT = INOUTV(I)
         PINOUT = INOUTV(I+1)
         IF (DINOUT < DIN) THEN
            INOUTV(I) = DIN
            INOUTV(I+1) = PIN
         ELSE IF (DINOUT == DIN) THEN
C           --INOUTV(I) = DIN
C           --even number I take smallest Process number (pin)
            IF ((mod(DINOUT,2).EQ.0).AND.(PIN<PINOUT)) THEN
              INOUTV(I+1) = PIN
            ELSE IF ((mod(DINOUT,2).EQ.1).AND.(PIN>PINOUT)) THEN
C           --odd number I take largest Process number (pin)
              INOUTV(I+1) = PIN
            ENDIF
         ENDIF
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_BUREDUCE
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_IBUINIT(IW, IWSZ, IVAL)
      IMPLICIT NONE
      INTEGER IWSZ
      INTEGER IW(IWSZ)
      INTEGER IVAL
      INTEGER I
      DO I=1,IWSZ
         IW(I)=IVAL
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_IBUINIT
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_FINDMYROWCOLINDICES(MYID, NUMPROCS,
     & IRN_loc, JCN_loc, NZ_loc,
     & ROWPARTVEC, COLPARTVEC, M, N,
     & MYROWINDICES, INUMMYR,
     & MYCOLINDICES, INUMMYC,     
     & IWRKROW, IWRKCOL, IWSZR, IWSZC, COMM    )
      IMPLICIT NONE
      INTEGER MYID, NUMPROCS, NZ_loc, M, N
      INTEGER IRN_loc(NZ_loc), JCN_loc(NZ_loc)
      INTEGER ROWPARTVEC(M)
      INTEGER COLPARTVEC(N)
      INTEGER MYROWINDICES(M)
      INTEGER MYCOLINDICES(N)
      INTEGER INUMMYR, INUMMYC
      INTEGER IWSZR, IWSZC
      INTEGER IWRKROW(IWSZR)
      INTEGER IWRKCOL(IWSZC)
      INTEGER COMM
      INTEGER I, IR, IC, ITMP
      INUMMYR = 0
      INUMMYC = 0
C     MARK MY ROWS. FIRST COUNT,
C          IF DYNAMIC MEMORY ALLOCATIOn WILL USED
      DO I=1,M
         IWRKROW(I) = 0
         IF(ROWPARTVEC(I).EQ.MYID) THEN
            IWRKROW(I)=1
            INUMMYR = INUMMYR + 1
         ENDIF
      ENDDO
      DO I=1,NZ_loc
         IR = IRN_loc(I)
         IC = JCN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.M).AND.
     &        ((IC.GE.1).AND.(IC.LE.N))) THEN
            IF(IWRKROW(IR) .EQ. 0) THEN
               IWRKROW(IR)= 1
               INUMMYR = INUMMYR + 1
            ENDIF
         ENDIF
      ENDDO
C     PUT MY ROWS INTO MYROWINDICES
      ITMP = 1
      DO I=1,M
         IF(IWRKROW(I).EQ.1) THEN
            MYROWINDICES(ITMP) = I
            ITMP  = ITMP + 1
         ENDIF
      ENDDO
C
C
C     DO THE SMAME THING FOR COLS
      DO I=1,N
         IWRKCOL(I) = 0
         IF(COLPARTVEC(I).EQ.MYID) THEN
            IWRKCOL(I)= 1
            INUMMYC = INUMMYC + 1
         ENDIF
      ENDDO
      DO I=1,NZ_loc
         IR = IRN_loc(I)
         IC = JCN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.M).AND.
     &        ((IC.GE.1).AND.(IC.LE.N))) THEN
            IF(IWRKCOL(IC) .EQ. 0) THEN
               IWRKCOL(IC)= 1
               INUMMYC = INUMMYC + 1
            ENDIF
         ENDIF
      ENDDO
C     PUT MY ROWS INTO MYROWINDICES
      ITMP = 1
      DO I=1,N
         IF(IWRKCOL(I).EQ.1) THEN
            MYCOLINDICES(ITMP) = I
            ITMP  = ITMP + 1
         ENDIF
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_FINDMYROWCOLINDICES
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_NUMVOLSNDRCV(MYID, NUMPROCS, ISZ, IPARTVEC,
     &     NZ_loc, INDX, OSZ, OINDX,ISNDRCVNUM,ISNDRCVVOL,
     &     OSNDRCVNUM,OSNDRCVVOL,
     &     IWRK,IWRKSZ, SNDSZ, RCVSZ, COMM)
      IMPLICIT NONE
      INTEGER MYID, NUMPROCS, NZ_loc, ISZ, IWRKSZ, OSZ
      INTEGER ISNDRCVNUM, ISNDRCVVOL
      INTEGER OSNDRCVNUM, OSNDRCVVOL
      INTEGER COMM
      INTEGER INDX(NZ_loc)
      INTEGER OINDX(NZ_loc)
      INTEGER IPARTVEC(ISZ)
      INTEGER IWRK(IWRKSZ)
      INTEGER SNDSZ(NUMPROCS)
      INTEGER RCVSZ(NUMPROCS)
      INCLUDE 'mpif.h'
C     LOCAL VARS
      INTEGER I
      INTEGER IIND, IIND2, PIND
      INTEGER IERROR
C check done outsize
C      IF(ISZ>IWRKSZ) THEN ERROR
      DO I=1,NUMPROCS
         SNDSZ(I) = 0
         RCVSZ(I) = 0
      ENDDO
      DO I=1,IWRKSZ
         IWRK(I) = 0
      ENDDO
      DO I=1,NZ_loc
         IIND = INDX(I)
         IIND2 = OINDX(I)
         IF((IIND.GE.1).AND.(IIND.LE.ISZ).AND.
     &        (IIND2.GE.1).AND.(IIND2.LE.OSZ))THEN
            PIND = IPARTVEC(IIND)
            IF(PIND .NE. MYID) THEN
               IF(IWRK(IIND).EQ.0) THEN
                  IWRK(IIND) = 1
                  SNDSZ(PIND+1) = SNDSZ(PIND+1)+1
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      CALL MPI_ALLTOALL(SNDSZ, 1, MPI_INTEGER,
     & RCVSZ, 1, MPI_INTEGER, COMM, IERROR)
      ISNDRCVNUM = 0 
      ISNDRCVVOL = 0
      OSNDRCVNUM = 0
      OSNDRCVVOL = 0
      DO I=1, NUMPROCS
         IF(SNDSZ(I) > 0) OSNDRCVNUM = OSNDRCVNUM + 1
         OSNDRCVVOL = OSNDRCVVOL + SNDSZ(I)
         IF(RCVSZ(I) > 0) ISNDRCVNUM = ISNDRCVNUM + 1
         ISNDRCVVOL = ISNDRCVVOL + RCVSZ(I)
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_NUMVOLSNDRCV
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_SETUPCOMMS(MYID, NUMPROCS, ISZ, IPARTVEC,
     &     NZ_loc, INDX, OSZ, OINDX,
     &     ISNDRCVNUM, ISNDVOL, INGHBPRCS, ISNDRCVIA, ISNDRCVJA,
     &     OSNDRCVNUM, OSNDVOL, ONGHBPRCS, OSNDRCVIA, OSNDRCVJA,
     &     SNDSZ, RCVSZ, IWRK, 
     &     ISTATUS, REQUESTS,
     &     ITAGCOMM, COMM )
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      INTEGER MYID, NUMPROCS, NZ_loc, ISZ, ISNDVOL, OSNDVOL, OSZ
C     ISZ is either M or N
      INTEGER INDX(NZ_loc)
      INTEGER OINDX(NZ_loc)
C     INDX is either IRN_loc or JCN_col
      INTEGER IPARTVEC(ISZ)
C     IPARTVEC is either rowpartvec or colpartvec
      INTEGER ISNDRCVNUM, INGHBPRCS(ISNDRCVNUM)
      INTEGER ISNDRCVIA(NUMPROCS+1)
      INTEGER ISNDRCVJA(ISNDVOL)
      INTEGER OSNDRCVNUM, ONGHBPRCS(OSNDRCVNUM)
      INTEGER OSNDRCVIA(NUMPROCS+1)
      INTEGER OSNDRCVJA(OSNDVOL)
      INTEGER SNDSZ(NUMPROCS)
      INTEGER RCVSZ(NUMPROCS)
      INTEGER IWRK(ISZ)
      INTEGER ISTATUS(MPI_STATUS_SIZE, ISNDRCVNUM)
      INTEGER REQUESTS(ISNDRCVNUM)
      INTEGER ITAGCOMM, COMM
C     LOCAL VARS
      INTEGER I, IIND, IIND2, IPID, OFFS 
      INTEGER IWHERETO, POFFS, ITMP, IERROR
C     COMPUATIONs START      
      DO I=1,ISZ
         IWRK(I) = 0
      ENDDO
C     INITIALIZE ONGHBPRCS using SNDSZ
C     INITIALIZE THE OSNDRCVIA using SNDSZ 
      OFFS = 1
      POFFS = 1
      DO I=1,NUMPROCS
         OSNDRCVIA(I) = OFFS + SNDSZ(I)
         IF(SNDSZ(I) > 0) THEN
            ONGHBPRCS(POFFS)=I
            POFFS = POFFS + 1
         ENDIF         
         OFFS  = OFFS +  SNDSZ(I)
      ENDDO
      OSNDRCVIA(NUMPROCS+1) = OFFS
C     CHECK STARTS
C check done outsize
C      IF(POFFS .NE. OSNDRCVNUM + 1)THEN ERROR
C     INIT DONE. FILL UP THE OSNDRCVJA(OSNDVOL)
      DO I=1,NZ_loc
         IIND=INDX(I)
         IIND2 = OINDX(I)
         IF((IIND.GE.1).AND.(IIND.LE.ISZ).AND.
     &        (IIND2.GE.1).AND.(IIND2.LE.OSZ) ) THEN
            IPID=IPARTVEC(IIND)
            IF(IPID.NE.MYID) THEN
               IF(IWRK(IIND).EQ.0) THEN
                  IWHERETO = OSNDRCVIA(IPID+1)-1
                  OSNDRCVIA(IPID+1) = OSNDRCVIA(IPID+1)-1
                  OSNDRCVJA(IWHERETO) = IIND
                  IWRK(IIND) = 1
               ENDIF
            ENDIF
         ENDIF
      ENDDO
C     FILLED UP, WHAT I WILL RECEIVE (My requests from others)
C     FILL UP ISNDRCVJA. It will be received to fill up
      CALL MPI_BARRIER(COMM,IERROR)
      OFFS = 1
      POFFS = 1
      ISNDRCVIA(1) = 1
      DO I=2,NUMPROCS+1
         ISNDRCVIA(I) = OFFS + RCVSZ(I-1)
         IF(RCVSZ(I-1) > 0) THEN
            INGHBPRCS(POFFS)=I-1
            POFFS = POFFS + 1
         ENDIF         
         OFFS  = OFFS +  RCVSZ(I-1)
      ENDDO
      CALL MPI_BARRIER(COMM,IERROR)      
      DO I=1, ISNDRCVNUM
         IPID = INGHBPRCS(I)
         OFFS = ISNDRCVIA(IPID)
         ITMP = ISNDRCVIA(IPID+1) - ISNDRCVIA(IPID)
         CALL MPI_IRECV(ISNDRCVJA(OFFS), ITMP, MPI_INTEGER,IPID-1,
     &     ITAGCOMM, COMM, REQUESTS(I),IERROR)   
      ENDDO
      DO I=1,OSNDRCVNUM
         IPID = ONGHBPRCS(I)
         OFFS = OSNDRCVIA(IPID)
         ITMP = OSNDRCVIA(IPID+1)-OSNDRCVIA(IPID)
         CALL MPI_SEND(OSNDRCVJA(OFFS), ITMP, MPI_INTEGER, IPID-1,
     &        ITAGCOMM, COMM,IERROR)
      ENDDO
      IF(ISNDRCVNUM > 0) THEN
         CALL MPI_WAITALL(ISNDRCVNUM, REQUESTS(1),ISTATUS(1,1),IERROR)
      ENDIF
      CALL MPI_BARRIER(COMM,IERROR)
      RETURN
      END SUBROUTINE DMUMPS_SETUPCOMMS
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_DOCOMMINF(MYID, NUMPROCS,TMPD, IDSZ, ITAGCOMM, 
     &     ISNDRCVNUM, INGHBPRCS,
     &     ISNDRCVVOL, ISNDRCVIA, ISNDRCVJA, ISNDRCVA,
     &     OSNDRCVNUM, ONGHBPRCS,
     &     OSNDRCVVOL, OSNDRCVIA, OSNDRCVJA, OSNDRCVA,
     &     ISTATUS, REQUESTS,
     &     COMM)
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      INTEGER MYID, NUMPROCS, IDSZ, ITAGCOMM
      INTEGER ISNDRCVNUM,OSNDRCVNUM, ISNDRCVVOL, OSNDRCVVOL
      DOUBLE PRECISION TMPD(IDSZ)
      INTEGER INGHBPRCS(ISNDRCVNUM), ONGHBPRCS(OSNDRCVNUM)
      INTEGER ISNDRCVIA(NUMPROCS+1), ISNDRCVJA(ISNDRCVVOL)
      DOUBLE PRECISION ISNDRCVA(ISNDRCVVOL)
      INTEGER OSNDRCVIA(NUMPROCS+1), OSNDRCVJA(OSNDRCVVOL)
      DOUBLE PRECISION OSNDRCVA(OSNDRCVVOL)
      INTEGER ISTATUS(MPI_STATUS_SIZE, max(ISNDRCVNUM,OSNDRCVNUM))
      INTEGER REQUESTS(max(ISNDRCVNUM,OSNDRCVNUM))
      INTEGER COMM, IERROR
C     LOCAL VARS
      INTEGER I, PID, OFFS, SZ, J, JS, JE, IID
      DO I=1,ISNDRCVNUM
         PID = INGHBPRCS(I)
         OFFS = ISNDRCVIA(PID)
         SZ = ISNDRCVIA(PID+1) -  ISNDRCVIA(PID) 
         CALL MPI_IRECV(ISNDRCVA(OFFS), SZ, 
     &        MPI_DOUBLE_PRECISION, PID-1, 
     &        ITAGCOMM,COMM,REQUESTS(I), IERROR)
      ENDDO
      DO I=1,OSNDRCVNUM
         PID = ONGHBPRCS(I)
         OFFS = OSNDRCVIA(PID)
         SZ = OSNDRCVIA(PID+1) - OSNDRCVIA(PID) 
         JS = OSNDRCVIA(PID) 
         JE =  OSNDRCVIA(PID+1) - 1
         DO J=JS, JE
            IID = OSNDRCVJA(J)
            OSNDRCVA(J) = TMPD(IID)
         ENDDO
         CALL MPI_SEND(OSNDRCVA(OFFS), SZ, MPI_DOUBLE_PRECISION, PID-1,
     &        ITAGCOMM, COMM, IERROR)
      ENDDO
      IF(ISNDRCVNUM > 0) THEN
         CALL MPI_WAITALL(ISNDRCVNUM, REQUESTS(1),ISTATUS(1,1),IERROR)
      ENDIF
C     FOLD INTO MY D
      DO I=1,ISNDRCVNUM
         PID = INGHBPRCS(I)
         JS = ISNDRCVIA(PID)
         JE = ISNDRCVIA(PID+1)-1
         DO J=JS,JE
            IID = ISNDRCVJA(J)
            IF(TMPD(IID) < ISNDRCVA(J)) TMPD(IID)= ISNDRCVA(J)
         ENDDO
      ENDDO
C     COMMUNICATE THE UPDATED ONES
      DO I=1,OSNDRCVNUM
         PID = ONGHBPRCS(I)
         OFFS = OSNDRCVIA(PID)
         SZ = OSNDRCVIA(PID+1) -  OSNDRCVIA(PID) 
         CALL MPI_IRECV(OSNDRCVA(OFFS), SZ, 
     &        MPI_DOUBLE_PRECISION, PID-1, 
     &        ITAGCOMM+1,COMM,REQUESTS(I), IERROR)
      ENDDO
      DO I=1,ISNDRCVNUM
         PID = INGHBPRCS(I)
         OFFS = ISNDRCVIA(PID)
         SZ = ISNDRCVIA(PID+1)-ISNDRCVIA(PID)
         JS = ISNDRCVIA(PID)
         JE = ISNDRCVIA(PID+1) -1
         DO J=JS, JE
            IID = ISNDRCVJA(J)
            ISNDRCVA(J) = TMPD(IID)
         ENDDO
         CALL MPI_SEND(ISNDRCVA(OFFS), SZ, MPI_DOUBLE_PRECISION, PID-1,
     &        ITAGCOMM+1, COMM, IERROR)
      ENDDO
      IF(OSNDRCVNUM > 0) THEN
         CALL MPI_WAITALL(OSNDRCVNUM, REQUESTS(1),ISTATUS(1,1),IERROR)
      ENDIF
      DO I=1,OSNDRCVNUM
         PID = ONGHBPRCS(I)
         JS = OSNDRCVIA(PID) 
         JE = OSNDRCVIA(PID+1) - 1
         DO J=JS,JE
            IID = OSNDRCVJA(J)
            TMPD(IID)=OSNDRCVA(J)
         ENDDO
      ENDDO
      RETURN
      END  SUBROUTINE DMUMPS_DOCOMMINF
C
C     SEPARATOR: Another function begins
C
      SUBROUTINE DMUMPS_DOCOMM1N(MYID, NUMPROCS,TMPD, IDSZ, ITAGCOMM, 
     &     ISNDRCVNUM, INGHBPRCS,
     &     ISNDRCVVOL, ISNDRCVIA, ISNDRCVJA, ISNDRCVA,
     &     OSNDRCVNUM, ONGHBPRCS,
     &     OSNDRCVVOL, OSNDRCVIA, OSNDRCVJA, OSNDRCVA,
     &     ISTATUS, REQUESTS,
     &     COMM)
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      INTEGER MYID, NUMPROCS, IDSZ, ITAGCOMM
      INTEGER ISNDRCVNUM,OSNDRCVNUM, ISNDRCVVOL, OSNDRCVVOL
      DOUBLE PRECISION TMPD(IDSZ)
      INTEGER INGHBPRCS(ISNDRCVNUM), ONGHBPRCS(OSNDRCVNUM)
      INTEGER ISNDRCVIA(NUMPROCS+1), ISNDRCVJA(ISNDRCVVOL)
      DOUBLE PRECISION ISNDRCVA(ISNDRCVVOL)
      INTEGER OSNDRCVIA(NUMPROCS+1), OSNDRCVJA(OSNDRCVVOL)
      DOUBLE PRECISION OSNDRCVA(OSNDRCVVOL)
      INTEGER ISTATUS(MPI_STATUS_SIZE, max(ISNDRCVNUM,OSNDRCVNUM))
      INTEGER REQUESTS(max(ISNDRCVNUM,OSNDRCVNUM))
      INTEGER COMM, IERROR
C     LOCAL VARS
      INTEGER I, PID, OFFS, SZ, J, JS, JE, IID
      DO I=1,ISNDRCVNUM
         PID = INGHBPRCS(I)
         OFFS = ISNDRCVIA(PID)
         SZ = ISNDRCVIA(PID+1) -  ISNDRCVIA(PID) 
         CALL MPI_IRECV(ISNDRCVA(OFFS), SZ, 
     &        MPI_DOUBLE_PRECISION, PID-1, 
     &        ITAGCOMM,COMM,REQUESTS(I), IERROR)
      ENDDO
      DO I=1,OSNDRCVNUM
         PID = ONGHBPRCS(I)
         OFFS = OSNDRCVIA(PID)
         SZ = OSNDRCVIA(PID+1) - OSNDRCVIA(PID) 
         JS = OSNDRCVIA(PID) 
         JE =  OSNDRCVIA(PID+1) - 1
         DO J=JS, JE
            IID = OSNDRCVJA(J)
            OSNDRCVA(J) = TMPD(IID)
         ENDDO
         CALL MPI_SEND(OSNDRCVA(OFFS), SZ, MPI_DOUBLE_PRECISION, PID-1,
     &        ITAGCOMM, COMM, IERROR)
      ENDDO
      IF(ISNDRCVNUM > 0) THEN
         CALL MPI_WAITALL(ISNDRCVNUM, REQUESTS(1),ISTATUS(1,1),IERROR)
      ENDIF
C     FOLD INTO MY D
      DO I=1,ISNDRCVNUM
         PID = INGHBPRCS(I)
         JS = ISNDRCVIA(PID)
         JE = ISNDRCVIA(PID+1)-1
         DO J=JS,JE
            IID = ISNDRCVJA(J)
            TMPD(IID)  = TMPD(IID)+ ISNDRCVA(J)
         ENDDO
      ENDDO
C     COMMUNICATE THE UPDATED ONES
      DO I=1,OSNDRCVNUM
         PID = ONGHBPRCS(I)
         OFFS = OSNDRCVIA(PID)
         SZ = OSNDRCVIA(PID+1) -  OSNDRCVIA(PID) 
         CALL MPI_IRECV(OSNDRCVA(OFFS), SZ, 
     &        MPI_DOUBLE_PRECISION, PID-1, 
     &        ITAGCOMM+1,COMM,REQUESTS(I), IERROR)
      ENDDO
      DO I=1,ISNDRCVNUM
         PID = INGHBPRCS(I)
         OFFS = ISNDRCVIA(PID)
         SZ = ISNDRCVIA(PID+1)-ISNDRCVIA(PID)
         JS = ISNDRCVIA(PID)
         JE = ISNDRCVIA(PID+1) -1
         DO J=JS, JE
            IID = ISNDRCVJA(J)
            ISNDRCVA(J) = TMPD(IID)
         ENDDO
         CALL MPI_SEND(ISNDRCVA(OFFS), SZ, MPI_DOUBLE_PRECISION, PID-1,
     &        ITAGCOMM+1, COMM, IERROR)
      ENDDO
      IF(OSNDRCVNUM > 0) THEN
         CALL MPI_WAITALL(OSNDRCVNUM, REQUESTS(1),ISTATUS(1,1),IERROR)
      ENDIF
      DO I=1,OSNDRCVNUM
         PID = ONGHBPRCS(I)
         JS = OSNDRCVIA(PID) 
         JE = OSNDRCVIA(PID+1) - 1
         DO J=JS,JE
            IID = OSNDRCVJA(J)
            TMPD(IID)=OSNDRCVA(J)
         ENDDO
      ENDDO
      RETURN
      END  SUBROUTINE DMUMPS_DOCOMM1N
      SUBROUTINE DMUMPS_CREATEPARTVECSYM(MYID, NUMPROCS, COMM,
     & IRN_loc, JCN_loc, NZ_loc,
     & IPARTVEC, ISZ,
     & IWRK, IWSZ)
      IMPLICIT NONE
      EXTERNAL DMUMPS_BUREDUCE
      INTEGER MYID, NUMPROCS, COMM
      INTEGER NZ_loc, ISZ, IWSZ
      INTEGER IRN_loc(NZ_loc), JCN_loc(NZ_loc)
      INTEGER IPARTVEC(ISZ)
      INTEGER IWRK(IWSZ)
      INCLUDE 'mpif.h'
C
C     LOCAL VARS
      INTEGER I
      INTEGER OP, IERROR
      INTEGER IR, IC
C
      IF(NUMPROCS.NE.1) THEN
C     CHECK done outsize
C     IF(IWSZ < 2*ISZ) THEN
C     CHECK ENDS
         CALL MPI_OP_CREATE(DMUMPS_BUREDUCE, .TRUE., OP, IERROR)
C     PERFORM THE REDUCTION
         CALL DMUMPS_IBUINIT(IWRK, 4*ISZ, ISZ)
         DO I=1,ISZ
            IWRK(2*I-1) = 0
            IWRK(2*I) = MYID
         ENDDO
         DO I=1,NZ_loc
            IR = IRN_loc(I)
            IC = JCN_loc(I)
            IF((IR.GE.1).AND.(IR.LE.ISZ).AND.
     &           (IC.GE.1).AND.(IC.LE.ISZ)) THEN
               IWRK(2*IR-1) = IWRK(2*IR-1) + 1
               IWRK(2*IC-1) = IWRK(2*IC-1) + 1
            ENDIF
         ENDDO
         CALL MPI_ALLREDUCE(IWRK(1), IWRK(1+2*ISZ), ISZ,
     &        MPI_2INTEGER, OP, COMM, IERROR)      
         DO I=1,ISZ
            IPARTVEC(I) = IWRK(2*I+2*ISZ)
         ENDDO
C     FREE THE OPERATOR
         CALL MPI_OP_FREE(OP, IERROR)
      ELSE
         DO I=1,ISZ
            IPARTVEC(I) = 0
         ENDDO
      ENDIF
      RETURN
      END SUBROUTINE DMUMPS_CREATEPARTVECSYM
      SUBROUTINE DMUMPS_NUMVOLSNDRCVSYM(MYID, NUMPROCS, ISZ, IPARTVEC,
     & NZ_loc, INDX,OINDX,ISNDRCVNUM,ISNDRCVVOL,OSNDRCVNUM,OSNDRCVVOL,
     & IWRK,IWRKSZ, SNDSZ, RCVSZ, COMM)
      IMPLICIT NONE
      INTEGER MYID, NUMPROCS, NZ_loc, ISZ, IWRKSZ
      INTEGER ISNDRCVNUM, ISNDRCVVOL
      INTEGER OSNDRCVNUM, OSNDRCVVOL
      INTEGER COMM
      INTEGER INDX(NZ_loc), OINDX(NZ_loc)
      INTEGER IPARTVEC(ISZ)
      INTEGER IWRK(IWRKSZ)
      INTEGER SNDSZ(NUMPROCS)
      INTEGER RCVSZ(NUMPROCS)
      INCLUDE 'mpif.h'
C     LOCAL VARS
      INTEGER I
      INTEGER IIND, IIND2, PIND
      INTEGER IERROR
C check done outsize
C      IF(ISZ>IWRKSZ) THEN ERROR
      DO I=1,NUMPROCS
         SNDSZ(I) = 0
         RCVSZ(I) = 0
      ENDDO
      DO I=1,IWRKSZ
         IWRK(I) = 0
      ENDDO
      DO I=1,NZ_loc
         IIND = INDX(I)
         IIND2 = OINDX(I)
         IF((IIND.GE.1).AND.(IIND.LE.ISZ).AND.(IIND2.GE.1)
     &        .AND.(IIND2.LE.ISZ)) THEN
            PIND = IPARTVEC(IIND)
            IF(PIND .NE. MYID) THEN
               IF(IWRK(IIND).EQ.0) THEN
                  IWRK(IIND) = 1
                  SNDSZ(PIND+1) = SNDSZ(PIND+1)+1
               ENDIF
            ENDIF
            IIND = OINDX(I)
            PIND = IPARTVEC(IIND)
            IF(PIND .NE. MYID) THEN
               IF(IWRK(IIND).EQ.0) THEN
                  IWRK(IIND) = 1
                  SNDSZ(PIND+1) = SNDSZ(PIND+1)+1
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      CALL MPI_ALLTOALL(SNDSZ, 1, MPI_INTEGER,
     &     RCVSZ, 1, MPI_INTEGER, COMM, IERROR)
      ISNDRCVNUM = 0 
      ISNDRCVVOL = 0
      OSNDRCVNUM = 0
      OSNDRCVVOL = 0
      DO I=1, NUMPROCS
         IF(SNDSZ(I) > 0) OSNDRCVNUM = OSNDRCVNUM + 1
         OSNDRCVVOL = OSNDRCVVOL + SNDSZ(I)
         IF(RCVSZ(I) > 0) ISNDRCVNUM = ISNDRCVNUM + 1
         ISNDRCVVOL = ISNDRCVVOL + RCVSZ(I)
      ENDDO
      RETURN
      END SUBROUTINE DMUMPS_NUMVOLSNDRCVSYM
      SUBROUTINE DMUMPS_FINDNUMMYROWCOLSYM(MYID, NUMPROCS, COMM,
     &     IRN_loc, JCN_loc, NZ_loc,
     &     PARTVEC, N,
     &     INUMMYR,
     &     IWRK, IWSZ)
      IMPLICIT NONE
      INTEGER MYID, NUMPROCS, NZ_loc, N
      INTEGER IRN_loc(NZ_loc), JCN_loc(NZ_loc)
      INTEGER PARTVEC(N)
      INTEGER INUMMYR
      INTEGER IWSZ
      INTEGER IWRK(IWSZ)
      INTEGER COMM
C
      INTEGER I, IR, IC
C check done outsize     
C     IF(IWSZ < M) THEN ERROR
C     IF(IWSZ < N) THEN ERROR
      INUMMYR = 0
C     MARK MY ROWS. FIRST COUNT,
C          IF DYNAMIC MEMORY ALLOCATIOn WILL USED
      DO I=1,N
         IWRK(I) = 0
         IF(PARTVEC(I).EQ.MYID) THEN
            IWRK(I)=1
            INUMMYR = INUMMYR + 1
         ENDIF
      ENDDO
      DO I=1,NZ_loc
         IR = IRN_loc(I)
         IC = JCN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.N).AND.
     &        ((IC.GE.1).AND.(IC.LE.N))) THEN
            IF(IWRK(IR) .EQ. 0) THEN
               IWRK(IR)= 1
               INUMMYR = INUMMYR + 1
            ENDIF
         ENDIF
         IF((IR.GE.1).AND.(IR.LE.N).AND.
     &        ((IC.GE.1).AND.(IC.LE.N))) THEN
            IF(IWRK(IC).EQ.0) THEN
               IWRK(IC)= 1
               INUMMYR = INUMMYR + 1
            ENDIF
         ENDIF
      ENDDO
C     THE SMAME THING APPLIES FOR COLS
C     No need to do anything
C
      RETURN
      END SUBROUTINE DMUMPS_FINDNUMMYROWCOLSYM
      INTEGER FUNCTION DMUMPS_CHKCONVGLOSYM(D, N, INDXR, INDXRSZ,
     &     EPS, COMM)
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      INTEGER N, INDXRSZ
      DOUBLE PRECISION D(N)
      INTEGER INDXR(INDXRSZ)
      DOUBLE PRECISION EPS
      INTEGER COMM
      EXTERNAL DMUMPS_CHK1LOC
      INTEGER  DMUMPS_CHK1LOC
      INTEGER GLORES, MYRESR, MYRES
      INTEGER IERR
      MYRESR =  DMUMPS_CHK1LOC(D, N, INDXR, INDXRSZ, EPS)
      MYRES = 2*MYRESR 
      CALL MPI_ALLREDUCE(MYRES, GLORES, 1, MPI_INTEGER,
     &     MPI_SUM, COMM, IERR)
      DMUMPS_CHKCONVGLOSYM = GLORES
      RETURN
      END FUNCTION DMUMPS_CHKCONVGLOSYM
      SUBROUTINE DMUMPS_FILLMYROWCOLINDICESSYM(MYID, NUMPROCS,COMM,    
     &     IRN_loc, JCN_loc, NZ_loc,
     &     PARTVEC, N,
     &     MYROWINDICES, INUMMYR,
     &     IWRK, IWSZ  )
      IMPLICIT NONE
      INTEGER MYID, NUMPROCS, NZ_loc, N
      INTEGER INUMMYR, IWSZ
      INTEGER IRN_loc(NZ_loc), JCN_loc(NZ_loc)
      INTEGER PARTVEC(N)
      INTEGER MYROWINDICES(INUMMYR)
      INTEGER IWRK(IWSZ)
      INTEGER COMM
C
      INTEGER I, IR, IC, ITMP, MAXMN
C      
      MAXMN = N
C check done outsize
C      IF(IWSZ < MAXMN) THEN ERROR
C     MARK MY ROWS. 
      DO I=1,N
         IWRK(I) = 0
         IF(PARTVEC(I).EQ.MYID) IWRK(I)=1
      ENDDO
      DO I=1,NZ_loc
         IR = IRN_loc(I)   
         IC = JCN_loc(I)
         IF((IR.GE.1).AND.(IR.LE.N).AND.
     &        ((IC.GE.1).AND.(IC.LE.N))) THEN
            IF(IWRK(IR) .EQ. 0) IWRK(IR)= 1
         ENDIF
         IF((IR.GE.1).AND.(IR.LE.N).AND.
     &        ((IC.GE.1).AND.(IC.LE.N))) THEN
            IF(IWRK(IC) .EQ.0) IWRK(IC)=1
         ENDIF
      ENDDO
C     PUT MY ROWS INTO MYROWINDICES
      ITMP = 1
      DO I=1,N
         IF(IWRK(I).EQ.1) THEN
            MYROWINDICES(ITMP) = I
            ITMP  = ITMP + 1
         ENDIF
      ENDDO
C
C
C     THE SMAME THING APPLY TO COLS 
C
      RETURN
      END SUBROUTINE DMUMPS_FILLMYROWCOLINDICESSYM
      SUBROUTINE DMUMPS_SETUPCOMMSSYM(MYID, NUMPROCS, ISZ, IPARTVEC,
     & NZ_loc, INDX, OINDX,
     & ISNDRCVNUM, ISNDVOL, INGHBPRCS, ISNDRCVIA, ISNDRCVJA,
     & OSNDRCVNUM, OSNDVOL, ONGHBPRCS, OSNDRCVIA, OSNDRCVJA,
     & SNDSZ, RCVSZ, IWRK, 
     & ISTATUS, REQUESTS,
     &  ITAGCOMM, COMM )
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      INTEGER MYID, NUMPROCS, NZ_loc, ISZ, ISNDVOL, OSNDVOL
C     ISZ is either M or N
      INTEGER INDX(NZ_loc), OINDX(NZ_loc)
C     INDX is either IRN_loc or JCN_col
      INTEGER IPARTVEC(ISZ)
C     IPARTVEC is either rowpartvec or colpartvec
      INTEGER ISNDRCVNUM, INGHBPRCS(ISNDRCVNUM)
      INTEGER ISNDRCVIA(NUMPROCS+1)
      INTEGER ISNDRCVJA(ISNDVOL)
      INTEGER OSNDRCVNUM, ONGHBPRCS(OSNDRCVNUM)
      INTEGER OSNDRCVIA(NUMPROCS+1)
      INTEGER OSNDRCVJA(OSNDVOL)
      INTEGER SNDSZ(NUMPROCS)
      INTEGER RCVSZ(NUMPROCS)
      INTEGER IWRK(ISZ)
      INTEGER ISTATUS(MPI_STATUS_SIZE, ISNDRCVNUM)
      INTEGER REQUESTS(ISNDRCVNUM)
      INTEGER ITAGCOMM, COMM
C     LOCAL VARS
      INTEGER I, IIND,IIND2,IPID,OFFS,IWHERETO,POFFS, ITMP, IERROR
C     COMPUATIONs START      
      DO I=1,ISZ
         IWRK(I) = 0
      ENDDO
C     INITIALIZE ONGHBPRCS using SNDSZ
C     INITIALIZE THE OSNDRCVIA using SNDSZ 
      OFFS = 1
      POFFS = 1
      DO I=1,NUMPROCS
         OSNDRCVIA(I) = OFFS + SNDSZ(I)
         IF(SNDSZ(I) > 0) THEN
            ONGHBPRCS(POFFS)=I
            POFFS = POFFS + 1
         ENDIF         
         OFFS  = OFFS +  SNDSZ(I)
      ENDDO
      OSNDRCVIA(NUMPROCS+1) = OFFS
C CHECK STARTS
C check done outsize
C      IF(POFFS .NE. OSNDRCVNUM + 1)THEN ERROR
C     INIT DONE. FILL UP THE OSNDRCVJA(OSNDVOL)
      DO I=1,NZ_loc
         IIND=INDX(I)
         IIND2 = OINDX(I)
         IF((IIND.GE.1).AND.(IIND.LE.ISZ).AND.(IIND2.GE.1)
     &        .AND.(IIND2.LE.ISZ)) THEN            
            IPID=IPARTVEC(IIND)
            IF(IPID.NE.MYID) THEN
               IF(IWRK(IIND).EQ.0) THEN
                  IWHERETO = OSNDRCVIA(IPID+1)-1
                  OSNDRCVIA(IPID+1) = OSNDRCVIA(IPID+1)-1
                  OSNDRCVJA(IWHERETO) = IIND
                  IWRK(IIND) = 1
               ENDIF
            ENDIF
            IIND = OINDX(I)
            IPID=IPARTVEC(IIND)
            IF(IPID.NE.MYID) THEN
               IF(IWRK(IIND).EQ.0) THEN
                  IWHERETO = OSNDRCVIA(IPID+1)-1
                  OSNDRCVIA(IPID+1) = OSNDRCVIA(IPID+1)-1
                  OSNDRCVJA(IWHERETO) = IIND
                  IWRK(IIND) = 1
               ENDIF
            ENDIF
         ENDIF
      ENDDO
C     FILLED UP, WHAT I WILL RECEIVE (My requests from others)
C     FILL UP ISNDRCVJA. It will be received to fill up
      CALL MPI_BARRIER(COMM,IERROR)
      OFFS = 1
      POFFS = 1
      ISNDRCVIA(1) = 1
      DO I=2,NUMPROCS+1
         ISNDRCVIA(I) = OFFS + RCVSZ(I-1)
         IF(RCVSZ(I-1) > 0) THEN
            INGHBPRCS(POFFS)=I-1
            POFFS = POFFS + 1
         ENDIF         
         OFFS  = OFFS +  RCVSZ(I-1)
      ENDDO
      CALL MPI_BARRIER(COMM,IERROR)      
      DO I=1, ISNDRCVNUM
         IPID = INGHBPRCS(I)
         OFFS = ISNDRCVIA(IPID)
         ITMP = ISNDRCVIA(IPID+1) - ISNDRCVIA(IPID)
         CALL MPI_IRECV(ISNDRCVJA(OFFS), ITMP, MPI_INTEGER,IPID-1,
     &     ITAGCOMM, COMM, REQUESTS(I),IERROR)   
      ENDDO
      DO I=1,OSNDRCVNUM
         IPID = ONGHBPRCS(I)
         OFFS = OSNDRCVIA(IPID)
         ITMP = OSNDRCVIA(IPID+1)-OSNDRCVIA(IPID)
         CALL MPI_SEND(OSNDRCVJA(OFFS), ITMP, MPI_INTEGER, IPID-1,
     &        ITAGCOMM, COMM,IERROR)
      ENDDO
      IF(ISNDRCVNUM > 0) THEN
         CALL MPI_WAITALL(ISNDRCVNUM, REQUESTS(1),ISTATUS(1,1),IERROR)
      ENDIF
      CALL MPI_BARRIER(COMM,IERROR)
      RETURN
      END SUBROUTINE DMUMPS_SETUPCOMMSSYM
