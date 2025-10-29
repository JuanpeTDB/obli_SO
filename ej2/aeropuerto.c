#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/types.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

int rand_1_5(void){ unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 5; unsigned r; do { r = (unsigned)rand(); } while (r > limit); return 1 + (r % 5); }
int rand_1_3(void){ unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 3; unsigned r; do { r = (unsigned)rand(); } while (r > limit); return 1 + (r % 3); }

void* pasajero(void* arg){
    int id = (int)(intptr_t)arg;
    pthread_mutex_lock(&mutex);
    printf("Pasajero %d esta mirando el cartel...\n", id);
    sleep(rand_1_3());
    pthread_mutex_unlock(&mutex);
    return NULL;
}

void* oficinista(void* arg){
    int id = (int)(intptr_t)arg;
    for (int i = 1; i <= 3; i++) {
        pthread_mutex_lock(&mutex);
        printf("Oficinista %d esta cambiando el cartel en iteracion %d...\n", id, i);
        sleep(rand_1_5());
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

int main(void){
    srand((unsigned)time(NULL));
    pthread_t ofi[5], pas[100];

    for (int i = 0; i < 5; i++) pthread_create(&ofi[i], NULL, oficinista, (void*)(intptr_t)(i + 1));
    for (int i = 0; i < 100; i++) pthread_create(&pas[i], NULL, pasajero, (void*)(intptr_t)(i + 1));

    for (int i = 0; i < 5; i++) pthread_join(ofi[i], NULL);
    for (int i = 0; i < 100; i++) pthread_join(pas[i], NULL);

    return 0;
}
