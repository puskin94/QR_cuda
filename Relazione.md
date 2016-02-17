# Relezione progetto Algoritmi per il calcolo Parallelo
### Giovanni Bucci

## Analisi del Problema
La consegna richiede la risoluzione di una fattorizzazione *QR* utilizzando l'algotitmo di **Gram-Schmidt** (modificato) utilizzando due appocci: un codice seriale ed una versione dello stesso parallelizzata attraverso il framework CUDA.

### Analisi dei dati
Questo algoritmo di fattorizzazione consente di riscrivere una matrice  **A (M*N)** come la moltiplicazione di due matrici **Q (M*N)** e **R (N*N)** (*con M > N, e con A, Q, R ∈ R*)
La consegna suggerisce di effettuare due test distinti utilizzando dimensioni diverse della matrice A: 400 x 300 e 1000 x 800.

## Approccio pratico
Ritenendo più semplice l'approccio seriale a quello parallelo, ho iniziato a sviluppare la versione in C puro. Questa scelta mi ha permesso di comprendere meglio le dinamiche dell'algoritmo rendendo il passaggio dall'approccio seriale a quello parallelo meno doloroso.
Una volta completata la prima versione del codice, ho iniziato a realizzare la conformazione della struttura necessaria ad un approccio parallelo. Infatti, una volta compreso il funzionamento dei blocchi di Threads, la composizione del secondo algoritmo e' risultata relativamente semplice.

## Analisi dei risultati
La consegna richiede di indicare i seguenti valori sia per l'approccio seriale sia per quello parallelo:
Il tempo di CPU, il tempo di GPU, gli speedUp e le bande di processamento. Qua sotto vengono elencati i vari risultati:
### 400 x 300
Tempo di Cpu : 0.310 secondi
Tempo di Gpu : 0.167 secondi
SpeedUp : 1.85
Banda di Processamento (GPU) : (400x300) / 0.167 = 7.18 GB/s

### 1000 x 800
Tempo di Cpu : 5.390 secondi
Tempo di Gpu : 1.706 secondi
SpeedUp : 3.15
Banda di Processamento (GPU) : (1000x800) / 1.706 = 4.68 GB/s
