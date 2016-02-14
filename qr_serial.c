#include <stdio.h>
#include <stdlib.h>
#include "qr_serial.h"


int main() {
  int m = 400;
  int n = 300;
  // int M = 1000;
  // int N = 800;
  int ld = m;

  double *A, *R;

  A = NULL;
  A = (double*)malloc(m * n * sizeof(double));
  R = NULL;
  R = (double*)malloc(n * n * sizeof(double));

  initMatrix(A, n);
  gram(A, m, n, R);


  free(A);
  free(R);
  return 0;

}

void gram(double* A, int m, int n, double *R){
  if (m < n) {
    printf("m must be higher than n");
    return;
  }

  for (int i = 0; i < n; ++i) {
    xTA(&R[i * n + i], n - i, &A[i], m, n, &A[i], n);
    
  }
}

void initMatrix(double *matrix, int n) {
  for (int i = 0; i < n; ++i) {
    matrix[i + i * n] = (double)i + 1.0;
  }
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

void printMatrix(double *matrix, int m, int n, int ld) {
  for (int i = 0; i < m; ++i) {
    for (int j = 0; j < n; ++j) {
      printf("%f ", matrix[i * ld + j]);
    }
    printf("\n");
  }
}
