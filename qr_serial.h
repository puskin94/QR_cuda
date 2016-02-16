void initMatrix(double *matrix, int N);
void gram(double* A, int M, int N, double *R);
void xTA (double *y, int k, double*A, int m, int lda, double *x, int ldx);
void scale(double *d, int m, int ld);
void r1_update(double *A, int m, int n, int lda, double *col, int ldc, double *row);
