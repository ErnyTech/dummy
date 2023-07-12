/*
    Copyright Ernesto Castellotti <ernesto@castellotti.net>
    SPDX-License-Identifier: GPL-3.0-only
*/

enum YIELD = 24;
enum NANOSLEEP = 35;
enum PAUSE = 34;

extern(C) void _start() {
    long timesleep = 60;

    while (true) {
        ulong ret;

        // YIELD!
        asm {
            "syscall"
            : "=a" (ret)
            : "0" (cast(ulong) YIELD)
            : "rcx", "r11", "memory";
        }

        // This should wait forever
        asm {
            "syscall"
            : "=a" (ret)
            : "0" (cast(ulong) PAUSE)
            : "rcx", "r11", "memory";
        }

        // How the fuck did you come here?
        // Sleep 60s in case of runaway loop (It shouldn't happen)
        asm {
            "syscall"
            : "=a" (ret)
            : "0" (cast(ulong) NANOSLEEP), "D" (cast(ulong) &timesleep) // Seriously, don't copy this
            : "rcx", "r11", "memory";
        }
    }
}
