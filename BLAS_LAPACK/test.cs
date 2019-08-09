using System;
using System.Runtime.InteropServices;

namespace test {
    class test {

        [DllImport("BLAS_LAPACK")]
        static extern void BoSSS_dgemm(ref int transa, ref int transb, ref int m, ref int n, ref int k, ref double alpha, double[] a, ref int lda, double[] b, ref int ldb, ref double beta, double[] c, ref int ldc);


        static void Main(string[] args) {
            int N = 100;
            int trans = 'N';
            double eins = 1.0;
            double[] A = new double[N * N];
            double[] B = new double[N * N];
            double[] C = new double[N * N];

            A[0] = 2;
            B[0] = 3;
            C[0] = 4;

            BoSSS_dgemm(ref trans, ref trans, ref N, ref N, ref N, ref eins, A, ref N, B, ref N, ref eins, C, ref N);

            Console.WriteLine("C[0,0] = " + C[0]);

        }
    }
}



