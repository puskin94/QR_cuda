#include <cuda.h>

void initMatrix(double *matrix, int N);
void gram(double* A, int M, int N, double *R, int threadsN);
__global__ void xTA (double *y, int k, double*A, int m, int lda, double *x, int ldx);
__global__ void scale(double *d, int m, int ld, double *s);
__global__ void r1_update(double *A, int m, int n, int lda, double *col, int ldc, double *row);
