#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <strings.h>
#include <cuda.h>

// in this file we have all the prototypes, including 3 mandatory kernels
#include "qr_cuda.h"

int main() {
  //int m = 400;
  //int n = 300;
  int m = 1000;
  int n = 800;
  int threadsN = 512;
  double *A, *R;

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  float time;

  // starting the timer
  cudaEventRecord(start, 0);
  // allocating the necessary memory
  A = NULL;
  A = (double*)malloc(m * n * sizeof(double));
  bzero(A, m * n);
  R = NULL;
  R = (double*)malloc(n * n * sizeof(double));
  bzero(R, n * n);

  initMatrix(A, n);
  // starting the algorithm
  gram(A, m, n, R, threadsN);

  free(A);
  free(R);
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&time, start, stop);

  // time is in ms
  printf("Elapsed time %6.3f s [p]\n", time/1000);
  printf("Bandwidth: %6.3f GB/s\n", m * n * sizeof(double) / (time / 1000)); 
  return 0;
}

void gram(double* A, int m, int n, double *R, int threadsN){
  if (m < n) {
    printf("m must be higher than n");
    return;
  }

  double *ADevice, *RDevice;
  // setting `threadsN` threads per block
  dim3 dimBlock(threadsN, 1, 1);
  dim3 dimGrid(threadsN, (m + threadsN - 1) / threadsN, 1);
  // Allocating some space to the device
  // ** -> pointing to a pointer of GPU
  if (cudaSuccess != cudaMalloc((void **) &ADevice, m * n * sizeof(double))) {
    printf("[!] Error allocating space to the device for the matrix A\n");
    return;
  }
  if (cudaSuccess != cudaMalloc((void **) &RDevice, n * n * sizeof(double))) {
    printf("[!] Error allocating space to the device for the matrix R\n");
    return;
  }
  // copying the A matrix to the device
  if (cudaSuccess != cudaMemcpy(ADevice, A, m * n * sizeof(double), cudaMemcpyHostToDevice)) {
    printf("[!] Error copying the matrix A to the device\n");
    return;
  }

  for (int i = 0; i < n; ++i) {
    // dimGrid is `n - i`. Every MP uses 1 || > 1 blocks
    xTA <<< n - i, dimBlock >>> (&RDevice[i * n + i], n - i, &ADevice[i], m, n, &ADevice[i], n);
    scale <<< m, dimBlock >>> (&ADevice[i], m, n, &RDevice[i * n + i]);
    scale <<< n - i, dimBlock >>> (&RDevice[i * n + i], n - i, 1, &RDevice[i * n + i]);
    r1_update <<< dimGrid, dimBlock >>> (&ADevice[i + 1], m, n - i - 2, n, &ADevice[i], n, &RDevice[i]);
  }

  if (cudaSuccess != cudaMemcpy(A, ADevice, m * n * sizeof(double), cudaMemcpyDeviceToHost)) {
    printf("[!] Error copying the matrix ADevice to the host\n");
    return;
  }
  if (cudaSuccess != cudaMemcpy(R, RDevice, n * n * sizeof(double), cudaMemcpyDeviceToHost)) {
    printf("[!] Error copying the matrix RDevice to the host\n");
    return;
  }

  cudaFree(ADevice);
  cudaFree(RDevice);

}

/**
* Rank 1 update of columns of A
* A     m x n lda
* col   m x 1 ldc
* coeff 1 x n
*/
__global__ void r1_update(double *A, int m, int n, int lda, double *col, int ldc, double *row) {
  int indexX = blockIdx.x * blockDim.x + threadIdx.x;
  int indexY = blockIdx.y * blockDim.y +threadIdx.y;
  if (indexX < m && indexY < m) {
    for (int j = 0; j < n; ++j) {
      A[indexX * lda + j] -= row[j] * col[indexY * ldc];
    }
  }
}

/**
* Mult. for constant s
* d vector
* m number of elements to change
* ld leading dimension (distance from elements)
*
*/
__global__ void scale(double *d, int m, int ld, double *s) {
  int index = blockIdx.x * blockDim.x + threadIdx.x;

  if (index < m)
    d[index * ld] /= sqrt(*s);
}

__global__ void xTA (double *y, int k, double*A, int m, int lda, double *x, int ldx){
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  double sum;
  if (index < k) {
    for (int i = 0; i < m; ++i) {
      sum += x[i * ldx] * A[index + i * lda];
    }
    y[index] = sum;
  }
}

void initMatrix(double *matrix, int n) {
  /* filling the A matrix using this rule
  A(ii, ii) = ii + 1
  ii = 0, N − 1 */
  for (int i = 0; i < n; ++i)
    matrix[i + i * n] = (double)i + 1.0;
}
