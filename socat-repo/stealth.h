/* source: stealth.h */
/* Copyright Gerhard Rieger and contributors (see file CHANGES) */
/* Published under the GNU General Public License V.2, see file COPYING */

#ifndef __stealth_h_included
#define __stealth_h_included 1

/* Platform feature detection via autoconf */
#ifdef HAVE_PRCTL_SET_NAME
#include <sys/prctl.h>
#endif

/* Function prototypes */
extern void stealth_hide_arguments(int argc, char **argv, const char *masq_name);

#endif /* !defined(__stealth_h_included) */
