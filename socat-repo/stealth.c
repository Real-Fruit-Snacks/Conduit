/* source: stealth.c */
/* Copyright Gerhard Rieger and contributors (see file CHANGES) */
/* Published under the GNU General Public License V.2, see file COPYING */

#include "config.h"
#include "stealth.h"
#include <string.h>

/* Hide command-line arguments from process inspection tools
 * Called immediately after argument parsing in main()
 * Silently fails if platform APIs unavailable (operational security)
 */
void stealth_hide_arguments(int argc, char **argv, const char *masq_name) {
    int i;
    const char *process_name = masq_name ? masq_name : "socat";

    /* Masquerade argv[0] if masq_name is provided */
    if (masq_name && argv[0]) {
        size_t argv0_len = strlen(argv[0]);
        size_t masq_len = strlen(masq_name);

        /* Clear original argv[0] */
        memset(argv[0], 0, argv0_len);

        /* Set new process name (truncate if necessary) */
        if (masq_len < argv0_len) {
            strcpy(argv[0], masq_name);
        } else {
            strncpy(argv[0], masq_name, argv0_len - 1);
            argv[0][argv0_len - 1] = '\0';
        }
    }

#ifdef HAVE_PRCTL_SET_NAME
    /* Linux: Set process name and clear argv memory */
    if (prctl(PR_SET_NAME, process_name, 0, 0, 0) == 0) {
        /* prctl succeeded, now clear argument strings */
        for (i = 1; i < argc; i++) {
            if (argv[i] != NULL) {
                memset(argv[i], 0, strlen(argv[i]));
            }
        }
        return;
    }
    /* prctl failed; fall through to generic fallback */
#endif

#ifdef HAVE_BSD_SETPROCTITLE
    /* BSD: Use setproctitle() and clear argv memory */
    setproctitle("%s", process_name);
    /* Clear argv strings for complete hiding */
    for (i = 1; i < argc; i++) {
        if (argv[i] != NULL) {
            memset(argv[i], 0, strlen(argv[i]));
        }
    }
    return;
#endif

    /* Fallback: Manual argv memory clearing for all Unix platforms */
    for (i = 1; i < argc; i++) {
        if (argv[i] != NULL) {
            memset(argv[i], 0, strlen(argv[i]));
        }
    }
}
