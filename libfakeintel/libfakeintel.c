/* 
 * See also: https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
 * Compile into a shared library: 
 *  gcc -shared -fPIC -o libfakeintel.so fakeintel.c
 */

int mkl_serv_intel_cpu_true() {
  return 1;
}
