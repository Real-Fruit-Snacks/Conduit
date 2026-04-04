#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "stealth.h"

int main(int argc, char **argv) {
    printf("=== STEALTH FUNCTIONALITY TEST ===\n");
    printf("Initial arguments:\n");
    for (int i = 0; i < argc; i++) {
        printf("  argv[%d]: %s\n", i, argv[i]);
    }

    printf("\nCalling stealth_hide_arguments()...\n");
    stealth_hide_arguments(argc, argv);

    printf("Arguments after stealth call:\n");
    for (int i = 0; i < argc; i++) {
        printf("  argv[%d]: %s\n", i, argv[i]);
    }

    printf("Process name should now be 'socat' in process listings\n");
    printf("Test PID: %d\n", getpid());
    printf("Check with: ps -p %d -o pid,comm,args\n", getpid());

    sleep(5);  // Give time to check process listing
    return 0;
}