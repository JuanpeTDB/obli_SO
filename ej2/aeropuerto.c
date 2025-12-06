#include <stdio.h> 
#include <unistd.h> 
#include <pthread.h>
#include <sys/types.h> 
#include <stdlib.h> 
#include <time.h> 
#include <stdint.h> 
#include <semaphore.h> 

sem_t mutex; // Se declara un semáforo global que se usará como exclusión mutua

// Función que devuelve un número aleatorio entre 1 y 5
int rand_1_5(void) {
    unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 5; 
    unsigned r;
    do {
        r = (unsigned)rand(); // Genera un número aleatorio hasta que esté dentro del rango aceptable
    } while (r > limit);
    return 1 + (r % 5); // Se ajusta el valor para que esté entre 1 y 5
}

// Función que devuelve un número aleatorio entre 1 y 3
int rand_1_3(void) {
    unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 3; // Igual que arriba, pero para rango de 1 a 3
    unsigned r;
    do {
        r = (unsigned)rand();
    } while (r > limit);
    return 1 + (r % 3);
}

// Función que ejecuta cada hilo de pasajero
void* pasajero(void* arg){
    int id = (int)(intptr_t)arg; // Se obtiene el ID del pasajero desde el argumento
    sleep(rand() % 5 + 2); // El pasajero espera entre 2 y 6 segundos antes de intentar ver el cartel

    sem_wait(&mutex); // Solicita acceso exclusivo al cartel (sección crítica)
    printf("Pasajero %d esta mirando el cartel...\n", id); // Muestra que el pasajero está usando el cartel
    sleep(rand_1_3()); // Se queda mirando entre 1 y 3 segundos
    sem_post(&mutex); // Libera el acceso al cartel para que otro lo pueda usar

    return NULL; // Finaliza el hilo
}

// Función que ejecuta cada hilo de oficinista
void* oficinista(void* arg){
    int id = (int)(intptr_t)arg; // Se obtiene el ID del oficinista desde el argumento
    sleep(rand() % 3 + 1); // Espera entre 1 y 3 segundos antes de comenzar

    for (int i = 1; i <= 3; i++) { // Repite el proceso de actualizar el cartel 3 veces
        sem_wait(&mutex); // Solicita acceso exclusivo al cartel
        printf("Oficinista %d esta cambiando el cartel en iteracion %d...\n", id, i); // Muestra que lo está editando
        sleep(rand_1_5()); // Tarda entre 1 y 5 segundos en hacer el cambio
        sem_post(&mutex); // Libera el acceso al cartel
    }

    return NULL; // Finaliza el hilo
}

int main(){
    srand((unsigned)time(NULL)); // Inicializa la semilla del generador de números aleatorios con el tiempo actual
    sem_init(&mutex, 0, 1); // Inicializa el semáforo mutex como binario (valor inicial 1, uso entre hilos del mismo proceso)

    pthread_t ofi[5];   // Arreglo de 5 hilos para los oficinistas
    pthread_t pas[100]; // Arreglo de 100 hilos para los pasajeros

    // Se crean los 5 hilos de oficinistas
    for (int i = 0; i < 5; i++)
        pthread_create(&ofi[i], NULL, oficinista, (void*)(intptr_t)(i + 1));

    // Se crean los 100 hilos de pasajeros
    for (int i = 0; i < 100; i++)
        pthread_create(&pas[i], NULL, pasajero, (void*)(intptr_t)(i + 1));

    // Se espera a que terminen todos los oficinistas
    for (int i = 0; i < 5; i++)
        pthread_join(ofi[i], NULL);

    // Se espera a que terminen todos los pasajeros
    for (int i = 0; i < 100; i++)
        pthread_join(pas[i], NULL);

    sem_destroy(&mutex); // Se destruye el semáforo al final del programa

    return 0; // Fin del programa
}