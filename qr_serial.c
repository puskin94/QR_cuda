#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <strings.h>

#include "qr_serial.h"


int main() {
  //int m = 400;
  //int n = 300;
  int m = 1000;
  int n = 800;

  double *A, *R;
  clock_t start,stop;

  // starting the timer
  start = clock();
  // allocating the necessary memory
  A = NULL;
  A = (double*)malloc(m * n * sizeof(double));
  bzero(A, m * n);
  R = NULL;
  R = (double*)malloc(n * n * sizeof(double));
  bzero(R, n * n);

  /* filling the A matrix using this rule
  A(ii, ii) = ii + 1
  ii = 0, N − 1 */
  initMatrix(A, n);
  // starting the algorithm
  gram(A, m, n, R);

  free(A);
  free(R);

  stop = clock();
  printf("Elapsed time %6.3f [s]\n", (stop-start)/(double)CLOCKS_PER_SEC);
  return 0;

}

void gram(double* A, int m, int n, double *R){
  double s;

  if (m < n) {
    printf("m must be higher than n");
    return;
  }

  for (int i = 0; i < n; ++i) {
    xTA(&R[i * n + i], n - i, &A[i], m, n, &A[i], n);
    s = sqrt(R[i * n + i]);
    scale(&A[i], m, n, s);
    scale(&R[i * n + i], n - 1, 1, s);
    r1_update(&A[i + 1], m, n - i - 2, n, &A[i], n, &R[i]);
  }

}

/**
  * Rank 1 update of columns of A
  * A     m x n lda
  * col   m x 1 ldc
  * coeff 1 x n
  */
void r1_update(double *A, int m, int n, int lda, double *col, int ldc, double *row){
  for (int i = 0; i < m; ++i)
    for (int j = 0; j < n; ++j)
      A[i * lda + j] -= row[j] * col[i * ldc];
}

/**
  * Mult. for constant s
  * d vector
  * m number of elements to change
  * ld leading dimension (distance from elements)
  *
  */
void scale(double *d, int m, int ld, double s){
  if (s != 0.0)
    return;

  // i * ld is the value's index on the column
  for (int i = 0; i < m; ++i)
    d[i * ld] /= s;
}

void xTA (double *y, int k, double*A, int m, int lda, double *x, int ldx){
  for (int i = 0; i < k; ++i) {
    double sum = 0;
    for (int j = 0; j < m; ++j) {
      sum += x[j * ldx] * A[i + lda * j];
    }
    y[i] = sum;
  }
}

void initMatrix(double *matrix, int n) {
  for (int i = 0; i < n; ++i)
    matrix[i + i * n] = (double)i + 1.0;
}
