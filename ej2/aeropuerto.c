#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/types.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

int rem_pas = 100;
int rem_ofi = 15;

// devuelve: 1 = OFICINISTA, 0 = PASAJERO, -1 = no queda nadie
int next_accion(void) {
    int total = rem_pas + rem_ofi;
    if (total == 0) return -1;

    int r = rand() % total;         
    if (r < rem_ofi) {              
        rem_ofi--;
        return 1;
    } else {                        
        rem_pas--;
        return 0;
    }
}


// Funcion que genera un numero random entre 1 y 5, hecha con chatgpt
int rand_1_5(void) {
    unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 5;
    unsigned r;
    do { r = (unsigned)rand(); } while (r > limit);
    return 1 + (r % 5);
}

// Funcion que genera un numero random entre 1 y 3, hecha con chatgpt
int rand_1_3(void) {
    unsigned limit = RAND_MAX - (RAND_MAX + 1u) % 3;
    unsigned r;
    do { r = (unsigned)rand(); } while (r > limit);
    return 1 + (r % 3);
}

void* pasajero(void* arg){
    srand((unsigned)time(NULL));  
    int tiempo = rand_1_3();
    int id = (int)(intptr_t)arg;
    printf("Pasajero %d esta mirando el cartel... \n", id);
    sleep(tiempo);
    pthread_exit(0);
}

void* oficinista(void* arg){
    srand((unsigned)time(NULL));    
    int tiempo = rand_1_5();
    int id = (int)(intptr_t)arg;
    printf("Oficinista %d esta cambiando el cartel... \n", id);
    sleep(tiempo);
    pthread_exit(0);

}

int main(){
    srand((unsigned)time(NULL) ^ (unsigned)getpid()); 
    int quienVa = 0;
    int pas=1;
    int ofi=1;
    int modOfi=1;
    while ((quienVa = next_accion()) != -1)
    {
        if (quienVa == 1)
        {
            pthread_t hilo;
            pthread_create(&hilo, NULL, oficinista, (void*)(intptr_t)ofi);
            pthread_join(hilo, NULL);
            modOfi++;
            if (modOfi > 3)
            {
                modOfi=1;
                ofi++;
            }
        } else if(quienVa == 0){ 
            pthread_t hilo2;
            pthread_create(&hilo2, NULL, pasajero, (void*)(intptr_t)pas);
            pthread_join(hilo2, NULL);
            pas++;
        }
    }
    return 0;
}