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
      SUBROUTINE SMUMPS_FREETOPSO( N, KEEP28, IWCB, LIWW,
     &       W, LWC,
     &       POSWCB,IWPOSCB,PTRICB,PTRACB)
      IMPLICIT NONE
      INTEGER N,LIWW,LWC,POSWCB,IWPOSCB, KEEP28
      INTEGER IWCB(LIWW),PTRICB(KEEP28),PTRACB(KEEP28)
      REAL W(LWC)
      INTEGER SIZFI, SIZFR
      IF ( IWPOSCB .eq. LIWW ) RETURN
      DO WHILE ( IWCB( IWPOSCB + 2 ) .eq. 0 )
        SIZFR = IWCB( IWPOSCB + 1 )
        SIZFI =  2  
        IWPOSCB = IWPOSCB + SIZFI
        POSWCB  = POSWCB  + SIZFR
        IF ( IWPOSCB .eq. LIWW ) RETURN
      END DO
      RETURN
      END SUBROUTINE SMUMPS_FREETOPSO
      SUBROUTINE SMUMPS_COMPSO(N,KEEP28,IWCB,LIWW,W,LWC,
     &       POSWCB,IWPOSCB,PTRICB,PTRACB)
      IMPLICIT NONE
      INTEGER N,LIWW,LWC,POSWCB,IWPOSCB,KEEP28
      INTEGER IWCB(LIWW),PTRICB(KEEP28),PTRACB(KEEP28)
      REAL W(LWC)
      INTEGER IPTIW,IPTA,SIZFI,SIZFR,LONGI,LONGR
      INTEGER I
      IPTIW = IWPOSCB
      IPTA  = POSWCB
      LONGI = 0
      LONGR = 0
      IF ( IPTIW .EQ. LIWW ) RETURN
10    CONTINUE
       IF (IWCB(IPTIW+2).EQ.0) THEN
        SIZFR  = IWCB(IPTIW+1)
        SIZFI =  2  
        IF (LONGI.NE.0) THEN
          DO 20 I=0,LONGI-1
            IWCB(IPTIW + SIZFI - I) = IWCB (IPTIW - I )
 20       CONTINUE 
          DO 30 I=0,LONGR-1
            W(IPTA + SIZFR - I)   = W(IPTA - I )
 30       CONTINUE
        ENDIF
        DO 40 I=1,KEEP28
          IF ((PTRICB(I).LE.(IPTIW+1)).AND.
     &        (PTRICB(I).GT.IWPOSCB) ) THEN
            PTRICB(I) = PTRICB(I) + SIZFI
            PTRACB(I) = PTRACB(I) + SIZFR
          ENDIF 
40      CONTINUE 
        IWPOSCB = IWPOSCB + SIZFI
        IPTIW   = IPTIW + SIZFI
        POSWCB = POSWCB + SIZFR
        IPTA   = IPTA + SIZFR     
       ELSE
        SIZFR  = IWCB(IPTIW+1)
        SIZFI  = 2
        IPTIW = IPTIW + SIZFI
        LONGI = LONGI + SIZFI
        IPTA  = IPTA + SIZFR
        LONGR = LONGR + SIZFR
       ENDIF
       IF (IPTIW.NE.LIWW) GOTO 10
       RETURN
       END SUBROUTINE SMUMPS_COMPSO
      SUBROUTINE SMUMPS_SOL_X(A, NZ, N, IRN, ICN, Z, KEEP,KEEP8)
      INTEGER NZ, N, I, J, K, KEEP(500)
      INTEGER(8) KEEP8(150)
      INTEGER IRN(NZ), ICN(NZ)
      REAL A(NZ)
      REAL Z(N)
      REAL, PARAMETER :: ZERO = 0.0E0
      INTRINSIC     abs
      DO 10 I = 1, N
        Z(I) = ZERO
   10 CONTINUE
      IF (KEEP(264).EQ.0) THEN
       IF (KEEP(50) .EQ.0) THEN
         DO K = 1, NZ
          I = IRN(K)
          J = ICN(K)
          IF ((I .LT. 1) .OR. (I .GT. N)) CYCLE
          IF ((J .LT. 1) .OR. (J .GT. N)) CYCLE
          Z(I) = Z(I) + abs(A(K))
         ENDDO
        ELSE
         DO K = 1, NZ
          I = IRN(K)
          J = ICN(K)
          IF ((I .LT. 1) .OR. (I .GT. N)) CYCLE
          IF ((J .LT. 1) .OR. (J .GT. N)) CYCLE
          Z(I) = Z(I) + abs(A(K))
          IF (J.NE.I) THEN 
            Z(J) = Z(J) + abs(A(K))
          ENDIF
         ENDDO
        ENDIF
      ELSE
       IF (KEEP(50) .EQ.0) THEN
         DO K = 1, NZ
          I = IRN(K)
          J = ICN(K)
          Z(I) = Z(I) + abs(A(K))
         ENDDO
        ELSE
         DO K = 1, NZ
          I = IRN(K)
          J = ICN(K)
          Z(I) = Z(I) + abs(A(K))
          IF (J.NE.I) THEN 
            Z(J) = Z(J) + abs(A(K))
          ENDIF
         ENDDO
        ENDIF
      ENDIF
      RETURN
      END SUBROUTINE SMUMPS_SOL_X
      SUBROUTINE SMUMPS_SCAL_X(A, NZ, N, IRN, ICN, Z,
     &            KEEP, KEEP8, COLSCA)
      INTEGER,   intent(in)  :: NZ, N, KEEP(500)
      INTEGER(8), intent(in)  :: KEEP8(150)
      INTEGER,   intent(in)  :: IRN(NZ), ICN(NZ)
      REAL,   intent(in)  :: A(NZ)
      REAL,      intent(in)  :: COLSCA(N)
      REAL,      intent(out) :: Z(N)
      REAL, PARAMETER :: ZERO = 0.0E0
      INTEGER I, J, K
      DO 10 I = 1, N
        Z(I) = ZERO
   10 CONTINUE
      IF (KEEP(50) .EQ.0) THEN
       DO K = 1, NZ
        I = IRN(K)
        J = ICN(K)
        IF ((I .LT. 1) .OR. (I .GT. N)) CYCLE
        IF ((J .LT. 1) .OR. (J .GT. N)) CYCLE
        Z(I) = Z(I) + abs(A(K)*COLSCA(J))
       ENDDO
      ELSE
       DO K = 1, NZ
        I = IRN(K)
        J = ICN(K)
        IF ((I .LT. 1) .OR. (I .GT. N)) CYCLE
        IF ((J .LT. 1) .OR. (J .GT. N)) CYCLE
        Z(I) = Z(I) + abs(A(K)*COLSCA(J))
        IF (J.NE.I) THEN
          Z(J) = Z(J) + abs(A(K)*COLSCA(I))
        ENDIF
       ENDDO
      ENDIF
      RETURN
      END SUBROUTINE SMUMPS_SCAL_X
      SUBROUTINE SMUMPS_SOL_Y(A, NZ, N, IRN, ICN, RHS, X, R, W,
     &           KEEP,KEEP8)
      IMPLICIT NONE
      INTEGER,   intent(in)   :: NZ, N, KEEP(500)
      INTEGER(8), intent(in)   ::  KEEP8(150)
      INTEGER,   intent(in)   :: IRN(NZ), ICN(NZ)
      REAL,   intent(in)   :: A(NZ), RHS(N), X(N)
      REAL,      intent(out)  :: W(N)
      REAL,   intent(out)  :: R(N)
      INTEGER I, K, J
      REAL, PARAMETER :: ZERO = 0.0E0
      REAL D
      DO I = 1, N
        R(I) = RHS(I)
        W(I) = ZERO
      ENDDO
      IF (KEEP(264).EQ.0) THEN
       IF (KEEP(50) .EQ.0) THEN
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            IF ((I .GT. N) .OR. (J .GT. N) .OR. (I .LT. 1) .OR. 
     &       (J .LT. 1)) CYCLE
            D = A(K) * X(J)
            R(I) = R(I) - D
            W(I) = W(I) + abs(D)
          ENDDO
       ELSE
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            IF ((I .GT. N) .OR. (J .GT. N) .OR. (I .LT. 1) .OR. 
     &       (J .LT. 1)) CYCLE
            D = A(K) * X(J)
            R(I) = R(I) - D
            W(I) = W(I) + abs(D)
            IF (I.NE.J) THEN
              D = A(K) * X(I)
              R(J) = R(J) - D
              W(J) = W(J) + abs(D)
            ENDIF
          ENDDO
       ENDIF
      ELSE
       IF (KEEP(50) .EQ.0) THEN
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            D = A(K) * X(J)
            R(I) = R(I) - D
            W(I) = W(I) + abs(D)
          ENDDO
       ELSE
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            D = A(K) * X(J)
            R(I) = R(I) - D
            W(I) = W(I) + abs(D)
            IF (I.NE.J) THEN
              D = A(K) * X(I)
              R(J) = R(J) - D
              W(J) = W(J) + abs(D)
            ENDIF
          ENDDO
       ENDIF
      ENDIF
      RETURN
      END SUBROUTINE SMUMPS_SOL_Y
      SUBROUTINE SMUMPS_SOL_MULR(N, R, W)
      INTEGER, intent(in)  :: N
      REAL,    intent(in)  :: W(N)
      REAL, intent(inout) :: R(N)
      INTEGER I
      DO 10 I = 1, N
        R(I) = R(I) * W(I)
   10 CONTINUE
      RETURN
      END SUBROUTINE SMUMPS_SOL_MULR
      SUBROUTINE SMUMPS_SOL_B(N, KASE, X, EST, W, IW)
      INTEGER, intent(in)    :: N
      INTEGER, intent(inout) :: KASE
      INTEGER IW(N)
      REAL W(N), X(N)
      REAL, intent(inout)    :: EST
      INTRINSIC abs, nint, real, sign
      INTEGER SMUMPS_IXAMAX
      EXTERNAL SMUMPS_IXAMAX
      INTEGER ITMAX
      PARAMETER (ITMAX = 5)
      INTEGER I, ITER, J, JLAST, JUMP
      REAL ALTSGN
      REAL TEMP
      SAVE ITER, J, JLAST, JUMP
      REAL ZERO, ONE
      PARAMETER( ZERO = 0.0E0 )
      PARAMETER( ONE = 1.0E0 )
      REAL, PARAMETER :: RZERO = 0.0E0
      REAL, PARAMETER :: RONE = 1.0E0
      IF (KASE .EQ. 0) THEN
        DO 10 I = 1, N
          X(I) = ONE / real(N)
   10   CONTINUE
        KASE = 1
        JUMP = 1
        RETURN
      ENDIF
      SELECT CASE (JUMP)
      CASE (1)
        GOTO 20
      CASE(2)
        GOTO 40
      CASE(3)
        GOTO 70
      CASE(4)
        GOTO 120
      CASE(5)
        GOTO 160
      CASE DEFAULT
      END SELECT
   20 CONTINUE
      IF (N .EQ. 1) THEN
        W(1) = X(1)
        EST = abs(W(1))
        GOTO 190
      ENDIF
      DO 30 I = 1, N
        X(I)  = sign( RONE,real(X(I)) )
        IW(I) = nint(real(X(I)))
   30 CONTINUE
      KASE = 2
      JUMP = 2
      RETURN
   40 CONTINUE
      J = SMUMPS_IXAMAX(N, X, 1)
      ITER = 2
   50 CONTINUE
      DO 60 I = 1, N
        X(I) = ZERO
   60 CONTINUE
      X(J) = ONE
      KASE = 1
      JUMP = 3
      RETURN
   70 CONTINUE
      DO 80 I = 1, N
        W(I) = X(I)
   80 CONTINUE
      DO 90 I = 1, N
        IF (nint(sign(RONE, real(X(I)))) .NE. IW(I)) GOTO 100
   90 CONTINUE
      GOTO 130
  100 CONTINUE
      DO 110 I = 1, N
        X(I) = sign(RONE, real(X(I)))
        IW(I) = nint(real(X(I)))
  110 CONTINUE
      KASE = 2
      JUMP = 4
      RETURN
  120 CONTINUE
      JLAST = J
      J = SMUMPS_IXAMAX(N, X, 1)
      IF ((abs(X(JLAST)) .NE. abs(X(J))) .AND. (ITER .LT. ITMAX)) THEN
        ITER = ITER + 1
        GOTO 50
      ENDIF
  130 CONTINUE
      EST = RZERO
      DO 140 I = 1, N
        EST = EST + abs(W(I))
  140 CONTINUE
      ALTSGN = RONE
      DO 150 I = 1, N
        X(I) = ALTSGN * (RONE + real(I - 1) / real(N - 1))
        ALTSGN = -ALTSGN
  150 CONTINUE
      KASE = 1
      JUMP = 5
      RETURN
  160 CONTINUE
      TEMP = RZERO
      DO 170 I = 1, N
        TEMP = TEMP + abs(X(I))
  170 CONTINUE
      TEMP = 2.0E0 * TEMP / real(3 * N)
      IF (TEMP .GT. EST) THEN
        DO 180 I = 1, N
          W(I) = X(I)
  180   CONTINUE
        EST = TEMP
      ENDIF
  190 KASE = 0
      RETURN
      END SUBROUTINE SMUMPS_SOL_B
      SUBROUTINE SMUMPS_QD2( MTYPE, N, NZ, ASPK, IRN, ICN,
     &    LHS, WRHS, W, RHS, KEEP,KEEP8)
      IMPLICIT NONE
      INTEGER MTYPE, N, NZ
      INTEGER IRN( NZ ), ICN( NZ )
      INTEGER KEEP(500)
      INTEGER(8) KEEP8(150)
      REAL, intent(in) :: ASPK( NZ )
      REAL, intent(in) :: LHS( N ), WRHS( N )
      REAL, intent(out):: RHS( N )
      REAL,    intent(out):: W( N )
      INTEGER K, I, J
      REAL DZERO
      PARAMETER(DZERO = 0.0E0)
      DO 10 K = 1, N
        W(K) = DZERO
        RHS(K) = WRHS(K)
   10 CONTINUE
      IF ( KEEP(50) .EQ. 0 ) THEN
       IF (MTYPE .EQ. 1) THEN
        IF (KEEP(264).EQ.0) THEN
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            IF ((I .LE. 0) .OR. (I .GT. N) .OR. (J .LE. 0) .OR. 
     &        (J .GT. N)) CYCLE
            RHS(I) = RHS(I) - ASPK(K) * LHS(J)
            W(I) = W(I) + abs(ASPK(K))
          ENDDO
        ELSE
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            RHS(I) = RHS(I) - ASPK(K) * LHS(J)
            W(I) = W(I) + abs(ASPK(K))
          ENDDO
        ENDIF
       ELSE
        IF (KEEP(264).EQ.0) THEN
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            IF ((I .LE. 0) .OR. (I .GT. N) .OR. (J .LE. 0) .OR. 
     &        (J .GT. N)) CYCLE
            RHS(J) = RHS(J) - ASPK(K) * LHS(I)
            W(J) = W(J) + abs(ASPK(K))
          ENDDO
        ELSE
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            RHS(J) = RHS(J) - ASPK(K) * LHS(I)
            W(J) = W(J) + abs(ASPK(K))
          ENDDO
        ENDIF
       ENDIF
      ELSE
        IF (KEEP(264).EQ.0) THEN
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            IF ((I .LE. 0) .OR. (I .GT. N) .OR. (J .LE. 0) .OR. 
     &        (J .GT. N)) CYCLE
            RHS(I) = RHS(I) - ASPK(K) * LHS(J)
            W(I) = W(I) + abs(ASPK(K))
            IF (J.NE.I) THEN
                RHS(J) = RHS(J) - ASPK(K) * LHS(I)
                W(J) = W(J) + abs(ASPK(K))
            ENDIF
          ENDDO
        ELSE
          DO K = 1, NZ
            I = IRN(K)
            J = ICN(K)
            RHS(I) = RHS(I) - ASPK(K) * LHS(J)
            W(I) = W(I) + abs(ASPK(K))
            IF (J.NE.I) THEN
                RHS(J) = RHS(J) - ASPK(K) * LHS(I)
                W(J) = W(J) + abs(ASPK(K))
            ENDIF
          ENDDO
        ENDIF
      ENDIF
      RETURN
      END SUBROUTINE SMUMPS_QD2
      SUBROUTINE SMUMPS_ELTQD2( MTYPE, N, 
     &    NELT, ELTPTR, LELTVAR, ELTVAR, NA_ELT, A_ELT,
     &    LHS, WRHS, W, RHS, KEEP,KEEP8)
      IMPLICIT NONE
      INTEGER MTYPE, N, NELT, LELTVAR, NA_ELT
      INTEGER ELTPTR(NELT+1), ELTVAR(LELTVAR)
      INTEGER KEEP(500)
      INTEGER(8) KEEP8(150)
      REAL A_ELT(NA_ELT)
      REAL LHS( N ), WRHS( N ), RHS( N )
      REAL W(N)
      CALL SMUMPS_MV_ELT(N, NELT, ELTPTR, ELTVAR, A_ELT,
     &                         LHS, RHS, KEEP(50), MTYPE )
      RHS = WRHS - RHS
      CALL SMUMPS_SOL_X_ELT( MTYPE, N, 
     &    NELT, ELTPTR, LELTVAR, ELTVAR, NA_ELT, A_ELT,
     &    W, KEEP,KEEP8 )
      RETURN
      END SUBROUTINE SMUMPS_ELTQD2
      SUBROUTINE SMUMPS_SOL_X_ELT( MTYPE, N, 
     &    NELT, ELTPTR, LELTVAR, ELTVAR, NA_ELT, A_ELT,
     &    W, KEEP,KEEP8 )
      IMPLICIT NONE
      INTEGER MTYPE, N, NELT, LELTVAR, NA_ELT
      INTEGER ELTPTR(NELT+1), ELTVAR(LELTVAR)
      INTEGER KEEP(500)
      INTEGER(8) KEEP8(150)
      REAL A_ELT(NA_ELT)
      REAL TEMP
      REAL W(N)
      INTEGER K, I, J, IEL, SIZEI, IELPTR
      REAL DZERO
      PARAMETER(DZERO = 0.0E0)
      W = DZERO
      K = 1
      DO IEL = 1, NELT
        SIZEI  = ELTPTR( IEL + 1 ) - ELTPTR( IEL )
        IELPTR = ELTPTR( IEL ) - 1
        IF ( KEEP(50).EQ.0 ) THEN
         IF (MTYPE.EQ.1) THEN
           DO J = 1, SIZEI
              DO I = 1, SIZEI
               W( ELTVAR( IELPTR + I) ) = 
     &           W( ELTVAR( IELPTR + I) )
     &           + abs(A_ELT( K ))
               K = K + 1
              END DO
            END DO
         ELSE
           DO J = 1, SIZEI
              TEMP = W( ELTVAR( IELPTR + J ) )
              DO I = 1, SIZEI
               TEMP = TEMP + abs( A_ELT(K))
               K = K + 1
              END DO
              W(ELTVAR( IELPTR + J )) = 
     &          W(ELTVAR( IELPTR + J )) + TEMP
            END DO
         ENDIF
        ELSE
         DO J = 1, SIZEI
          W(ELTVAR( IELPTR + J )) = 
     &        W(ELTVAR( IELPTR + J )) + abs(A_ELT( K ))
          K = K + 1
          DO I = J+1, SIZEI
              W(ELTVAR( IELPTR + J )) = 
     &           W(ELTVAR( IELPTR + J )) + abs(A_ELT( K ))
              W(ELTVAR( IELPTR + I ) ) = 
     &           W(ELTVAR( IELPTR + I )) + abs(A_ELT( K ))
              K = K + 1
          END DO
         ENDDO
        ENDIF
      ENDDO
      RETURN
      END SUBROUTINE SMUMPS_SOL_X_ELT
      SUBROUTINE SMUMPS_SOL_SCALX_ELT(MTYPE, N, 
     &    NELT, ELTPTR, LELTVAR, ELTVAR, NA_ELT, A_ELT,
     &    W, KEEP,KEEP8, COLSCA )
      IMPLICIT NONE
      INTEGER MTYPE, N, NELT, LELTVAR, NA_ELT
      INTEGER ELTPTR(NELT+1), ELTVAR(LELTVAR)
      INTEGER KEEP(500)
      INTEGER(8) KEEP8(150)
      REAL COLSCA(N)
      REAL A_ELT(NA_ELT)
      REAL W(N)
      REAL TEMP, TEMP2
      INTEGER K, I, J, IEL, SIZEI, IELPTR
      REAL DZERO
      PARAMETER(DZERO = 0.0E0)
      W = DZERO
      K = 1
      DO IEL = 1, NELT
        SIZEI  = ELTPTR( IEL + 1 ) - ELTPTR( IEL )
        IELPTR = ELTPTR( IEL ) - 1
        IF ( KEEP(50).EQ.0 ) THEN
         IF (MTYPE.EQ.1) THEN
           DO J = 1, SIZEI
              TEMP2 = abs(COLSCA(ELTVAR( IELPTR + J) ))
              DO I = 1, SIZEI
               W( ELTVAR( IELPTR + I) ) =
     &           W( ELTVAR( IELPTR + I) )
     &           + abs(A_ELT( K )) * TEMP2
               K = K + 1
              END DO
            END DO
         ELSE
           DO J = 1, SIZEI
              TEMP = W( ELTVAR( IELPTR + J ) )
              TEMP2= abs(COLSCA(ELTVAR( IELPTR + J) ))
              DO I = 1, SIZEI
               TEMP = TEMP + abs(A_ELT( K )) * TEMP2
               K = K + 1
              END DO
              W(ELTVAR( IELPTR + J )) =
     &          W(ELTVAR( IELPTR + J )) + TEMP
            END DO
         ENDIF
        ELSE
         DO J = 1, SIZEI
          W(ELTVAR( IELPTR + J )) =
     &        W(ELTVAR( IELPTR + J )) + 
     &        abs( A_ELT( K )*COLSCA(ELTVAR( IELPTR + J)) )
          K = K + 1
          DO I = J+1, SIZEI
              W(ELTVAR( IELPTR + J )) =
     &           W(ELTVAR( IELPTR + J )) + 
     &           abs(A_ELT( K )*COLSCA(ELTVAR( IELPTR + J)))
              W(ELTVAR( IELPTR + I ) ) =
     &           W(ELTVAR( IELPTR + I )) + 
     &           abs(A_ELT( K )*COLSCA(ELTVAR( IELPTR + I)))
              K = K + 1
          END DO
         ENDDO
        ENDIF
      ENDDO
      RETURN
      END SUBROUTINE SMUMPS_SOL_SCALX_ELT
      SUBROUTINE SMUMPS_ELTYD( MTYPE, N, NELT, ELTPTR, 
     &                     LELTVAR, ELTVAR, NA_ELT, A_ELT,
     &                     SAVERHS, X, Y, W, K50 )
      IMPLICIT NONE
      INTEGER N, NELT, K50, MTYPE, LELTVAR, NA_ELT
      INTEGER ELTPTR( NELT + 1 ), ELTVAR( LELTVAR )
      REAL A_ELT( NA_ELT ), X( N ), Y( N ), 
     &                 SAVERHS(N)
      REAL W(N)
      INTEGER IEL, I , J, K, SIZEI, IELPTR
      REAL ZERO
      REAL TEMP
      REAL TEMP2
      PARAMETER( ZERO = 0.0E0 )
      Y = SAVERHS
      W = ZERO
      K = 1
      DO IEL = 1, NELT
        SIZEI  = ELTPTR( IEL + 1 ) - ELTPTR( IEL )
        IELPTR = ELTPTR( IEL ) - 1
        IF ( K50 .eq. 0 ) THEN
          IF ( MTYPE .eq. 1 ) THEN
            DO J = 1, SIZEI
              TEMP = X( ELTVAR( IELPTR + J ) )
              DO I = 1, SIZEI
                Y( ELTVAR( IELPTR + I ) ) =
     &          Y( ELTVAR( IELPTR + I ) ) -
     &             A_ELT( K ) * TEMP
                W( ELTVAR( IELPTR + I ) ) =
     &          W( ELTVAR( IELPTR + I ) ) +
     &             abs( A_ELT( K ) * TEMP )
                K = K + 1
              END DO
            END DO
          ELSE
            DO J = 1, SIZEI
              TEMP = Y( ELTVAR( IELPTR + J ) )
              TEMP2 = W( ELTVAR( IELPTR + J ) )
              DO I = 1, SIZEI
                TEMP = TEMP - 
     &          A_ELT( K ) * X( ELTVAR( IELPTR + I ) )
                TEMP2 = TEMP2 +  abs(
     &          A_ELT( K ) * X( ELTVAR( IELPTR + I ) ) )
                K = K + 1
              END DO
              Y( ELTVAR( IELPTR + J ) ) = TEMP
              W( ELTVAR( IELPTR + J ) ) = TEMP2
            END DO
          END IF
        ELSE
          DO J = 1, SIZEI
            Y( ELTVAR( IELPTR + J ) ) =
     &      Y( ELTVAR( IELPTR + J ) ) -
     &           A_ELT( K ) * X( ELTVAR( IELPTR + J ) )
            W( ELTVAR( IELPTR + J ) ) =
     &      W( ELTVAR( IELPTR + J ) ) + abs(
     &           A_ELT( K ) * X( ELTVAR( IELPTR + J ) ) )
            K = K + 1
            DO I = J+1, SIZEI
              Y( ELTVAR( IELPTR + I ) ) =
     &        Y( ELTVAR( IELPTR + I ) ) -
     &           A_ELT( K ) * X( ELTVAR( IELPTR + J ) )
              Y( ELTVAR( IELPTR + J ) ) =
     &        Y( ELTVAR( IELPTR + J ) ) -
     &           A_ELT( K ) * X( ELTVAR( IELPTR + I ) )
              W( ELTVAR( IELPTR + I ) ) =
     &        W( ELTVAR( IELPTR + I ) ) + abs(
     &           A_ELT( K ) * X( ELTVAR( IELPTR + J ) ) )
              W( ELTVAR( IELPTR + J ) ) =
     &        W( ELTVAR( IELPTR + J ) ) + abs(
     &           A_ELT( K ) * X( ELTVAR( IELPTR + I ) ) )
              K = K + 1
            END DO
          END DO
        END IF
      END DO
      RETURN
      END SUBROUTINE SMUMPS_ELTYD
      SUBROUTINE SMUMPS_SOLVE_GET_OOC_NODE(
     &     INODE,PTRFAC,KEEP,A,LA,STEP,
     &     KEEP8,N,MUST_BE_PERMUTED,IERR)
      USE SMUMPS_OOC
      IMPLICIT NONE
      INTEGER INODE,KEEP(500),N
      INTEGER(8) KEEP8(150)
      INTEGER(8) :: LA
      INTEGER(8) :: PTRFAC(KEEP(28))
      INTEGER STEP(N)
      INTEGER IERR
      REAL A(LA)      
      INTEGER RETURN_VALUE
      LOGICAL MUST_BE_PERMUTED
      RETURN_VALUE=SMUMPS_SOLVE_IS_INODE_IN_MEM(INODE,PTRFAC,
     &     KEEP(28),A,LA,IERR)
      IF(RETURN_VALUE.EQ.OOC_NODE_NOT_IN_MEM)THEN
         IF(IERR.LT.0)THEN
            RETURN
         ENDIF
         CALL SMUMPS_SOLVE_ALLOC_FACTOR_SPACE(INODE,PTRFAC,
     &        KEEP,KEEP8,A,IERR)
         IF(IERR.LT.0)THEN
            RETURN
         ENDIF
         CALL SMUMPS_READ_OOC(
     &        A(PTRFAC(STEP(INODE))),
     &        INODE,IERR
     &        )
         IF(IERR.LT.0)THEN
            RETURN
         ENDIF
      ELSE
         IF(IERR.LT.0)THEN
            RETURN
         ENDIF
      ENDIF
      IF(RETURN_VALUE.NE.OOC_NODE_PERMUTED)THEN
         MUST_BE_PERMUTED=.TRUE.
         CALL SMUMPS_SOLVE_MODIFY_STATE_NODE(INODE)
      ELSE
         MUST_BE_PERMUTED=.FALSE.
      ENDIF
      RETURN
      END SUBROUTINE SMUMPS_SOLVE_GET_OOC_NODE
      SUBROUTINE SMUMPS_BUILD_MAPPING_INFO(id)
      USE SMUMPS_STRUC_DEF
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      TYPE(SMUMPS_STRUC), TARGET :: id
      INTEGER, ALLOCATABLE, DIMENSION(:) :: LOCAL_LIST
      INTEGER :: I,IERR,TMP,NSTEPS,N_LOCAL_LIST
      INTEGER :: MASTER,TAG_SIZE,TAG_LIST
      INTEGER :: STATUS(MPI_STATUS_SIZE)
      LOGICAL :: I_AM_SLAVE
      PARAMETER(MASTER=0, TAG_SIZE=85,TAG_LIST=86)
      I_AM_SLAVE = (id%MYID .NE. MASTER
     &     .OR. ((id%MYID.EQ.MASTER).AND.(id%KEEP(46).EQ.1)))
      NSTEPS = id%KEEP(28)
      ALLOCATE(LOCAL_LIST(NSTEPS),STAT=IERR)
      IF(IERR.GT.0) THEN
         WRITE(*,*)'Problem in solve: error allocating LOCAL_LIST'
         CALL MUMPS_ABORT()
      END IF
      N_LOCAL_LIST = 0
      IF(I_AM_SLAVE) THEN
         DO I=1,NSTEPS
            IF(id%PTLUST_S(I).NE.0) THEN
               N_LOCAL_LIST = N_LOCAL_LIST + 1
               LOCAL_LIST(N_LOCAL_LIST) = I
            END IF
         END DO
         IF(id%MYID.NE.MASTER) THEN 
            CALL MPI_SEND(N_LOCAL_LIST, 1,
     &           MPI_INTEGER, MASTER, TAG_SIZE, id%COMM,IERR)
            CALL MPI_SEND(LOCAL_LIST, N_LOCAL_LIST,
     &           MPI_INTEGER, MASTER, TAG_LIST, id%COMM,IERR)
            DEALLOCATE(LOCAL_LIST)
            ALLOCATE(id%IPTR_WORKING(1),
     &           id%WORKING(1),
     &           STAT=IERR)
            IF(IERR.GT.0) THEN
               WRITE(*,*)'Problem in solve: error allocating ',
     &              'IPTR_WORKING and WORKING'
               CALL MUMPS_ABORT()
            END IF
         END IF
      END IF
      IF(id%MYID.EQ.MASTER) THEN
         ALLOCATE(id%IPTR_WORKING(id%NPROCS+1), STAT=IERR)
         IF(IERR.GT.0) THEN
            WRITE(*,*)'Problem in solve: error allocating IPTR_WORKING'
            CALL MUMPS_ABORT()
         END IF
         id%IPTR_WORKING = 0
         id%IPTR_WORKING(1) = 1
         id%IPTR_WORKING(MASTER+2) = N_LOCAL_LIST
         DO I=1, id%NPROCS-1
            CALL MPI_RECV(TMP, 1, MPI_INTEGER, MPI_ANY_SOURCE,
     &           TAG_SIZE, id%COMM, STATUS, IERR)
            id%IPTR_WORKING(STATUS(MPI_SOURCE)+2) = TMP
         END DO
         DO I=2, id%NPROCS+1
            id%IPTR_WORKING(I) = id%IPTR_WORKING(I)
     &           + id%IPTR_WORKING(I-1)
         END DO
         ALLOCATE(id%WORKING(id%IPTR_WORKING(id%NPROCS+1)-1),STAT=IERR)
         IF(IERR.GT.0) THEN
            WRITE(*,*)'Problem in solve: error allocating LOCAL_LIST'
            CALL MUMPS_ABORT()
         END IF
         TMP = MASTER + 1
         IF (I_AM_SLAVE) THEN
            id%WORKING(id%IPTR_WORKING(TMP):id%IPTR_WORKING(TMP+1)-1)
     &           = LOCAL_LIST(1:id%IPTR_WORKING(TMP+1)
     &           -id%IPTR_WORKING(TMP))
         ENDIF
         DO I=1,id%NPROCS-1
            CALL MPI_RECV(LOCAL_LIST, NSTEPS, MPI_INTEGER,
     &           MPI_ANY_SOURCE, TAG_LIST, id%COMM, STATUS, IERR)
            TMP = STATUS(MPI_SOURCE)+1
            id%WORKING(id%IPTR_WORKING(TMP):id%IPTR_WORKING(TMP+1)-1)
     &           = LOCAL_LIST(1:id%IPTR_WORKING(TMP+1)-
     &           id%IPTR_WORKING(TMP))
         END DO
         DEALLOCATE(LOCAL_LIST)
      END IF
      END SUBROUTINE SMUMPS_BUILD_MAPPING_INFO
      SUBROUTINE SMUMPS_SOL_OMEGA(N, RHS,
     &    X, Y, R_W, C_W, IW, IFLAG,
     &    OMEGA, NOITER, TESTConv, 
     &    LP, ARRET )
      IMPLICIT NONE
      INTEGER N,  IFLAG
      INTEGER IW(N,2)
      REAL RHS(N)
      REAL X(N), Y(N)
      REAL R_W(N,2)
      REAL C_W(N)
      INTEGER LP, NOITER
      LOGICAL TESTConv
      REAL OMEGA(2)
      REAL ARRET
      REAL, PARAMETER :: CGCE=0.2E0
      REAL, PARAMETER :: CTAU=1.0E3
      INTEGER I, IMAX
      REAL OM1, OM2, DXMAX
      REAL TAU, DD
      REAL OLDOMG(2)
      REAL, PARAMETER :: ZERO=0.0E0
      REAL, PARAMETER :: ONE=1.0E0
      INTEGER SMUMPS_IXAMAX
      INTRINSIC  abs, max
      SAVE  OM1, OLDOMG
      IMAX = SMUMPS_IXAMAX(N, X, 1)
      DXMAX = abs(X(IMAX))
      OMEGA(1) = ZERO
      OMEGA(2) = ZERO
      DO I = 1, N
        TAU = (R_W(I, 2) * DXMAX + abs(RHS(I))) * real(N) * CTAU
        DD = R_W(I, 1) + abs(RHS(I))
        IF (DD .GT. TAU * epsilon(CTAU)) THEN
          OMEGA(1) = max(OMEGA(1), abs(Y(I)) / DD)
          IW(I, 1) = 1
        ELSE
          IF (TAU .GT. ZERO) THEN
            OMEGA(2) = max(OMEGA(2),
     &                     abs(Y(I)) / (DD + R_W(I, 2) * DXMAX))
          ENDIF
          IW(I, 1) = 2
        ENDIF
      ENDDO
      IF (TESTConv) THEN
        OM2 = OMEGA(1) + OMEGA(2)
        IF (OM2 .LT. ARRET ) THEN
           IFLAG = 1
           GOTO 70
        ENDIF
        IF (NOITER .GE. 1) THEN
           IF (OM2 .GT. OM1 * CGCE) THEN
             IF (OM2 .GT. OM1) THEN
               OMEGA(1) = OLDOMG(1)
               OMEGA(2) = OLDOMG(2)
               DO I = 1, N
                 X(I) = C_W(I)
               ENDDO
               IFLAG = 2
               GOTO 70
             ENDIF
             IFLAG = 3
             GOTO 70
           ENDIF
        ENDIF
        DO I = 1, N
             C_W(I) = X(I)
        ENDDO
        OLDOMG(1) = OMEGA(1)
        OLDOMG(2) = OMEGA(2)
        OM1 = OM2
      ENDIF
      IFLAG = 0
      RETURN
   70 CONTINUE
      RETURN
      END SUBROUTINE SMUMPS_SOL_OMEGA
      SUBROUTINE SMUMPS_SOL_LCOND(N, RHS,
     &    X, Y, D, R_W, C_W, IW, KASE,
     &    OMEGA, ERX, COND, 
     &    LP, KEEP,KEEP8 )
      IMPLICIT NONE
      INTEGER N, KASE, KEEP(500)
      INTEGER(8) KEEP8(150)
      INTEGER IW(N,2)
      REAL RHS(N)
      REAL X(N), Y(N)
      REAL D(N)
      REAL R_W(N,2)
      REAL C_W(N)
      INTEGER LP
      REAL COND(2),OMEGA(2)
      LOGICAL LCOND1, LCOND2
      INTEGER JUMP, I, IMAX
      REAL ERX, DXMAX
      REAL DXIMAX
      REAL, PARAMETER :: ZERO = 0.0E0
      REAL, PARAMETER :: ONE  = 1.0E0
      INTEGER SMUMPS_IXAMAX
      INTRINSIC     abs, max
      SAVE LCOND1, LCOND2, JUMP,  DXIMAX, DXMAX
      IF (KASE .EQ. 0) THEN
        LCOND1 = .FALSE.
        LCOND2 = .FALSE.
        COND(1) = ONE
        COND(2) = ONE
        ERX = ZERO
        JUMP = 1
      ENDIF
      SELECT CASE (JUMP)
      CASE (1)
        GOTO 30
      CASE(2)
        GOTO 10
      CASE(3)
        GOTO 110
      CASE(4)
        GOTO 150
      CASE(5)
        GOTO 35
      CASE DEFAULT
      END SELECT
   10 CONTINUE
   30 CONTINUE
   35 CONTINUE
      IMAX = SMUMPS_IXAMAX(N, X, 1)
      DXMAX = abs(X(IMAX))
      DO I = 1, N
        IF (IW(I, 1) .EQ. 1) THEN
          R_W(I, 1) = R_W(I, 1) + abs(RHS(I))
          R_W(I, 2) = ZERO
          LCOND1 = .TRUE.
        ELSE
          R_W(I, 2) = R_W(I, 2) * DXMAX + R_W(I, 1)
          R_W(I, 1) = ZERO
          LCOND2 = .TRUE.
        ENDIF
      ENDDO
      DO I = 1, N
        C_W(I) = X(I) * D(I)
      ENDDO
      IMAX = SMUMPS_IXAMAX(N, C_W(1), 1)
      DXIMAX = abs(C_W(IMAX))
      IF (.NOT.LCOND1) GOTO 130
  100 CONTINUE
      CALL SMUMPS_SOL_B(N, KASE, Y, COND(1), C_W, IW(1, 2))
      IF (KASE .EQ. 0) GOTO 120
      IF (KASE .EQ. 1) CALL SMUMPS_SOL_MULR(N, Y, D)
      IF (KASE .EQ. 2) CALL SMUMPS_SOL_MULR(N, Y, R_W)
      JUMP = 3
      RETURN
  110 CONTINUE
      IF (KASE .EQ. 1) CALL SMUMPS_SOL_MULR(N, Y, R_W)
      IF (KASE .EQ. 2) CALL SMUMPS_SOL_MULR(N, Y, D)
      GOTO 100
  120 CONTINUE
      IF (DXIMAX .GT. ZERO) COND(1) = COND(1) / DXIMAX
      ERX = OMEGA(1) * COND(1)
  130 CONTINUE
      IF (.NOT.LCOND2) GOTO 170
      KASE = 0
  140 CONTINUE
      CALL SMUMPS_SOL_B(N, KASE, Y, COND(2), C_W, IW(1, 2))
      IF (KASE .EQ. 0) GOTO 160
      IF (KASE .EQ. 1) CALL SMUMPS_SOL_MULR(N, Y, D)
      IF (KASE .EQ. 2) CALL SMUMPS_SOL_MULR(N, Y, R_W(1, 2))
      JUMP = 4
      RETURN
  150 CONTINUE
      IF (KASE .EQ. 1) CALL SMUMPS_SOL_MULR(N, Y, R_W(1, 2))
      IF (KASE .EQ. 2) CALL SMUMPS_SOL_MULR(N, Y, D)
      GOTO 140
  160 IF (DXIMAX .GT. ZERO) THEN
        COND(2) = COND(2) / DXIMAX
      ENDIF
      ERX = ERX + OMEGA(2) * COND(2)
  170 CONTINUE
      RETURN
      END SUBROUTINE SMUMPS_SOL_LCOND
      SUBROUTINE SMUMPS_SOL_CPY_FS2RHSCOMP( JBDEB, JBFIN, NBROWS,
     &   RHSCOMP, NRHS, LRHSCOMP, FIRST_ROW_RHSCOMP, W, LD_W,
     &   FIRST_ROW_W )
         INTEGER :: JBDEB, JBFIN, NBROWS
         INTEGER :: NRHS, LRHSCOMP
         INTEGER :: FIRST_ROW_RHSCOMP
#        if defined(RHSCOMP_BYROWS)
         REAL, INTENT(INOUT) :: RHSCOMP(NRHS,LRHSCOMP)
#        else
         REAL, INTENT(INOUT) :: RHSCOMP(LRHSCOMP,NRHS)
#        endif
         INTEGER :: LD_W, FIRST_ROW_W
         REAL :: W(LD_W*(JBFIN-JBDEB+1))
         INTEGER :: JJ, K, ISHIFT
#if defined(RHSCOMP_BYROWS)
         DO JJ = 0, NBROWS-1
           ISHIFT = FIRST_ROW_W+JJ
           DO K = JBDEB, JBFIN
             RHSCOMP(K,FIRST_ROW_RHSCOMP+JJ) =
     &       W(ISHIFT+LD_W*(K-JBDEB))
           END DO
         END DO
#else
         DO K = JBDEB, JBFIN
           ISHIFT = FIRST_ROW_W + LD_W * (K-JBDEB)
           DO JJ = 0, NBROWS-1
              RHSCOMP(FIRST_ROW_RHSCOMP+JJ,K) = W(ISHIFT+JJ)
           END DO
         END DO
#endif
      RETURN
      END SUBROUTINE SMUMPS_SOL_CPY_FS2RHSCOMP
      SUBROUTINE SMUMPS_SOL_BWD_GTHR( JBDEB, JBFIN, J1, J2,
     &   RHSCOMP, NRHS, LRHSCOMP, W, LD_W, FIRST_ROW_W,
     &   IW, LIW, KEEP, N, POSINRHSCOMP_BWD )
      INTEGER, INTENT(IN) :: JBDEB, JBFIN, J1, J2
      INTEGER, INTENT(IN) :: NRHS, LRHSCOMP
      INTEGER, INTENT(IN) :: FIRST_ROW_W, LD_W, LIW
      INTEGER, INTENT(IN) :: IW(LIW)
      INTEGER, INTENT(IN) :: KEEP(500)
#     if defined(RHSCOMP_BYROWS)
      REAL, INTENT(INOUT) :: RHSCOMP(NRHS,LRHSCOMP)
#     else
      REAL, INTENT(INOUT) :: RHSCOMP(LRHSCOMP,NRHS)
#     endif
      REAL :: W(LD_W*(JBFIN-JBDEB+1))
      INTEGER, INTENT(IN) :: N
      INTEGER, INTENT(IN) :: POSINRHSCOMP_BWD(N)
      INTEGER :: ISHIFT, JJ, K, IPOSINRHSCOMP
#if defined(RHSCOMP_BYROWS)
             DO JJ = J1, J2-KEEP(253)   
               ISHIFT = FIRST_ROW_W+JJ-J1
               IPOSINRHSCOMP =  abs(POSINRHSCOMP_BWD(IW(JJ)))
               DO K=JBDEB, JBFIN
                 W(ISHIFT+(K-JBDEB)*LD_W) = RHSCOMP(K,IPOSINRHSCOMP)
               ENDDO
             ENDDO
#else
             DO K=JBDEB, JBFIN
               ISHIFT = FIRST_ROW_W+(K-JBDEB)*LD_W
               DO JJ = J1, J2-KEEP(253)   
                 IPOSINRHSCOMP =  abs(POSINRHSCOMP_BWD(IW(JJ)))
                 W(ISHIFT+JJ-J1)= RHSCOMP(IPOSINRHSCOMP,K)
               ENDDO
             ENDDO
#endif
      RETURN
      END SUBROUTINE SMUMPS_SOL_BWD_GTHR
      SUBROUTINE SMUMPS_SOL_Q(MTYPE, IFLAG, N, NZ,
     &    LHS, WRHS, W, RES, GIVNORM, ANORM, XNORM, SCLNRM,
     &    MPRINT, ICNTL, KEEP,KEEP8)
      INTEGER MTYPE,N,NZ,IFLAG,ICNTL(40), KEEP(500)
      INTEGER(8) KEEP8(150)
      REAL RES(N),LHS(N)
      REAL WRHS(N)
      REAL W(N)
      REAL RESMAX,RESL2,XNORM, SCLNRM
      REAL ANORM,DZERO
      LOGICAL GIVNORM,PROK
      INTEGER MPRINT, MP
      INTEGER K
      INTRINSIC abs, max, sqrt
      MP = ICNTL(2)
      PROK = (MPRINT .GT. 0)
      DZERO = 0.0E0
      IF (.NOT.GIVNORM) ANORM = DZERO
      RESMAX = DZERO
      RESL2  = DZERO
      DO 40 K = 1, N
        RESMAX = max(RESMAX, abs(RES(K)))
        RESL2 = RESL2 + abs(RES(K)) * abs(RES(K))
        IF (.NOT.GIVNORM) ANORM = max(ANORM, W(K))
   40 CONTINUE
      XNORM = DZERO
      DO 50 K = 1, N
        XNORM = max(XNORM, abs(LHS(K)))
   50 CONTINUE
      IF ( XNORM .EQ. DZERO .OR. (exponent(XNORM) .LT.
     &      minexponent(XNORM) + KEEP(122) ) 
     &     .OR.
     &        ( exponent(ANORM)+exponent(XNORM) .LT.
     &           minexponent(XNORM) + KEEP(122) )
     &     .OR.
     &       ( exponent(ANORM) + exponent(XNORM) -exponent(RESMAX) 
     &       .LT. minexponent(XNORM) + KEEP(122) )
     &      ) THEN
            IF (mod(IFLAG/2,2) .EQ. 0) THEN
              IFLAG = IFLAG + 2
            ENDIF
            IF ((MP .GT. 0) .AND. (ICNTL(4) .GE. 2)) WRITE( MP, * )
     &    ' max-NORM of computed solut. is zero or close to zero. '
      ENDIF
      IF (RESMAX .EQ. DZERO) THEN
        SCLNRM = DZERO
      ELSE
        SCLNRM = RESMAX / (ANORM * XNORM)
      ENDIF
      RESL2 = sqrt(RESL2)
      IF (PROK) WRITE( MPRINT, 90 ) RESMAX, RESL2, ANORM, XNORM, 
     &      SCLNRM
   90  FORMAT (/' RESIDUAL IS ............ (MAX-NORM)        =',1PD9.2/
     &       '                       .. (2-NORM)          =',1PD9.2/
     &       ' RINFOG(4):NORM OF input  Matrix  (MAX-NORM)=',1PD9.2/
     &       ' RINFOG(5):NORM OF Computed SOLUT (MAX-NORM)=',1PD9.2/
     &       ' RINFOG(6):SCALED RESIDUAL ...... (MAX-NORM)=',1PD9.2)
      RETURN
      END SUBROUTINE SMUMPS_SOL_Q
