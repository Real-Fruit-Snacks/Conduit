/*
 * Conduit - Network Relay with Process Masquerading
 *
 * A derivative work based on SOCAT 1.7.3.3
 * Combines stealth SOCAT + process masquerading in one executable
 *
 * Copyright (C) 2026 Real-Fruit-Snacks
 * Copyright (C) 2001-2023 Gerhard Rieger and contributors (SOCAT)
 *
 * Licensed under GPLv2 with OpenSSL exception (see LICENSE file)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

// Embedded masquerade names
const char* masq_options[] = {
    "[kworker/0:1]",
    "systemd-logind",
    "/usr/sbin/sshd",
    "[migration/0]",
    "systemd-resolved",
    "/usr/bin/NetworkManager",
    "[rcu_gp]",
    "dbus-daemon"
};

void show_help() {
    printf("Conduit v1.0 - Network Relay with Process Masquerading\n");
    printf("Based on SOCAT 1.7.3.3\n\n");
    printf("Usage: conduit [--masq <name>] [--list-masq] [socat-args...]\n\n");
    printf("Masquerading Options:\n");
    printf("  --masq <name>    Masquerade as specific process\n");
    printf("  --masq-kernel    Masquerade as kernel worker\n");
    printf("  --masq-systemd   Masquerade as systemd service\n");
    printf("  --masq-ssh       Masquerade as SSH daemon\n");
    printf("  --masq-random    Random system process\n");
    printf("  --list-masq      Show available masquerade names\n");
    printf("  --no-masq        Use stealth without masquerading\n\n");
    printf("Examples:\n");
    printf("  conduit --masq-kernel TCP-LISTEN:80 TCP:target:80\n");
    printf("  conduit --masq '[custom]' TCP-LISTEN:443 TCP:backend:443\n");
    printf("  conduit --no-masq TCP-LISTEN:22 TCP:real-ssh:22\n\n");
    printf("Licensed under GPLv2 with OpenSSL exception\n");
}

void list_masquerade_options() {
    printf("Available masquerade process names:\n");
    for (int i = 0; i < sizeof(masq_options)/sizeof(masq_options[0]); i++) {
        printf("  %s\n", masq_options[i]);
    }
}

int main(int argc, char* argv[]) {
    const char* masq_name = NULL;
    int use_masq = 0;
    int socat_args_start = 1;

    // Check if we're being called with masquerading options
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--masq") == 0 && i + 1 < argc) {
            masq_name = argv[i + 1];
            use_masq = 1;
            socat_args_start = i + 2;
            break;
        } else if (strcmp(argv[i], "--masq-kernel") == 0) {
            masq_name = "[kworker/0:1]";
            use_masq = 1;
            socat_args_start = i + 1;
            break;
        } else if (strcmp(argv[i], "--masq-systemd") == 0) {
            masq_name = "systemd-logind";
            use_masq = 1;
            socat_args_start = i + 1;
            break;
        } else if (strcmp(argv[i], "--masq-ssh") == 0) {
            masq_name = "/usr/sbin/sshd";
            use_masq = 1;
            socat_args_start = i + 1;
            break;
        } else if (strcmp(argv[i], "--masq-random") == 0) {
            srand(getpid());
            masq_name = masq_options[rand() % (sizeof(masq_options)/sizeof(masq_options[0]))];
            use_masq = 1;
            socat_args_start = i + 1;
            break;
        } else if (strcmp(argv[i], "--list-masq") == 0) {
            list_masquerade_options();
            return 0;
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            show_help();
            return 0;
        } else if (strcmp(argv[i], "--no-masq") == 0) {
            use_masq = 0;
            socat_args_start = i + 1;
            break;
        } else {
            // Assume rest are socat arguments
            break;
        }
    }

    // Prepare arguments for stealth socat execution
    int new_argc = argc - socat_args_start + 1;
    char** new_argv = malloc((new_argc + 1) * sizeof(char*));

    if (use_masq && masq_name) {
        new_argv[0] = strdup(masq_name);  // Masqueraded name
        printf("[STEALTH] Masquerading as: %s\n", masq_name);
    } else {
        new_argv[0] = strdup("socat");    // Standard stealth
        printf("[STEALTH] Using argument hiding only\n");
    }

    // Copy socat arguments
    for (int i = 1; i < new_argc; i++) {
        new_argv[i] = strdup(argv[socat_args_start + i - 1]);
    }
    new_argv[new_argc] = NULL;

    // Execute stealth socat with prepared arguments
    // Note: In real deployment, embed the stealth socat binary
    printf("[CONDUIT] Executing stealth socat...\n");
    execv("./socat-repo/socat", new_argv);

    // If we get here, execv failed
    perror("[CONDUIT] Failed to execute stealth socat");
    return 1;
}