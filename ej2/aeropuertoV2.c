#include <stdio.h> 
#include <unistd.h> 
#include <pthread.h>
#include <sys/types.h> 
#include <stdlib.h> 
#include <time.h> 
#include <stdint.h> 
#include <semaphore.h> 

sem_t mutex; 

// Funcion que genera un numero random entre 1 y 5, hecha con chatgpt 
int rand_1_5(void) { unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 5; unsigned r; do { r = (unsigned)rand(); } while (r > limit); return 1 + (r % 5); } 

// Funcion que genera un numero random entre 1 y 3, hecha con chatgpt 
int rand_1_3(void) { unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 3; unsigned r; do { r = (unsigned)rand(); } while (r > limit); return 1 + (r % 3); } 

void* pasajero(void* arg){ 
    int id = (int)(intptr_t)arg; 
    sem_wait(&mutex); 
    printf("Pasajero %d esta mirando el cartel...\n", id); 
    sleep(rand_1_3()); 
    sem_post(&mutex); 
    return NULL; 
} 

void* oficinista(void* arg){ 
    int id = (int)(intptr_t)arg; 
    for (int i = 1; i <= 3; i++) { 
        sem_wait(&mutex); 
        printf("Oficinista %d esta cambiando el cartel en iteracion %d...\n", id, i); 
        sleep(rand_1_5()); 
        sem_post(&mutex); 
    } 
    return NULL; 
} 

int main(){ 
    srand((unsigned)time(NULL)); 
    sem_init(&mutex, 0, 1); 
    pthread_t ofi[5];
    pthread_t pas[100]; 
    // Crear oficinistas 
    for (int i = 0; i < 5; i++) pthread_create(&ofi[i], NULL, oficinista, (void*)(intptr_t)(i + 1));
    // Crear pasajeros 
    for (int i = 0; i < 100; i++) pthread_create(&pas[i], NULL, pasajero, (void*)(intptr_t)(i + 1)); 
    
    for (int i = 0; i < 5; i++) pthread_join(ofi[i], NULL); 
    for (int i = 0; i < 100; i++) pthread_join(pas[i], NULL);

    return 0; 
}