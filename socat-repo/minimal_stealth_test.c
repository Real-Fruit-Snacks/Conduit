#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/prctl.h>
#include "stealth.h"

int main(int argc, char **argv) {
    printf("=== MINIMAL STEALTH FUNCTION TEST ===\n");
    printf("Testing stealth_hide_arguments() function directly\n\n");

    // Show original arguments
    printf("BEFORE stealth_hide_arguments():\n");
    for (int i = 0; i < argc; i++) {
        printf("  argv[%d] = '%s'\n", i, argv[i]);
    }

    // Test the stealth function
    printf("\nCalling stealth_hide_arguments()...\n");
    stealth_hide_arguments(argc, argv);

    // Show arguments after stealth
    printf("\nAFTER stealth_hide_arguments():\n");
    for (int i = 0; i < argc; i++) {
        printf("  argv[%d] = '%s'\n", i, argv[i]);
    }

    // Check process name change
    printf("\nProcess verification:\n");
    printf("PID: %d\n", getpid());
    printf("Check process name with: ps -p %d -o comm,args\n", getpid());

    return 0;
}