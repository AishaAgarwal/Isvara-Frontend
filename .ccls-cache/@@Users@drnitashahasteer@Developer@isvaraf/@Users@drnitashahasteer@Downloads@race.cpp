#include <stdio.h>
#include <pthread.h>

int counter = 0;

void *thread_function(void *arg) {
    int i;
    for (i = 0; i < 80000; i++) {
        counter++;
    }
    pthread_exit(NULL);
}

int main() {
    pthread_t thread1, thread2;

    pthread_create(&thread1, NULL, thread_function, NULL);
    pthread_create(&thread2, NULL, thread_function, NULL);

    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);

    printf("Counter value: %d\n", counter);

    return 0;
}

