/*
    Copyright Ernesto Castellotti <ernesto@castellotti.net>
    SPDX-License-Identifier: GPL-3.0-only
*/

import gcc.attributes : register, always_inline;

version (X86_64) {
    enum YIELD = 24;
    enum PAUSE = 34;
    enum NANOSLEEP = 35;
    enum HAVE_PAUSE = true;
} else version (AArch64) {
    enum YIELD = 124;
    enum PPOLL = 73;
    enum NANOSLEEP = 101;
    enum HAVE_PAUSE = false;    // aarch64 doesn't have pause, need to use ppoll
} else {
    static assert(0, "CPU architecture not supported.");
}

long syscall0(long num) @always_inline {
    version (X86_64) {
        long ret;
        @register("rax") long _num = num;

        asm {
            "syscall"
            : "=a" (ret)
            : "0" (_num)
            : "rcx", "r11", "memory", "cc";
        }

        return ret;
    } else version (AArch64) {
        @register("x8") long _num = num;
        @register("x0") long _arg1;

        asm {
            "svc #0"
            : "=r" (_arg1)
            : "r" (_num)
            : "memory", "cc";
        }

        return _arg1;
    }
}

long syscall1(long num, long arg1) @always_inline {
    version (X86_64) {
        long ret;
        @register("rax") long _num = num;
        @register("rdi") long _arg1 = arg1;

        asm {
            "syscall"
            : "=a" (ret)
            : "r" (_arg1),
              "0" (_num)
            : "rcx", "r11", "memory", "cc";
        }

        return ret;
    } else version (AArch64) {
        @register("x8") long _num = num;
        @register("x0") long _arg1 = arg1;

        asm {
            "svc #0"
            : "=r" (_arg1)
            : "r" (_arg1),
              "r"(_num)
            : "memory", "cc";
        }

        return _arg1;
    }
}

long syscall4(long num, long arg1, long arg2, long arg3, long arg4) @always_inline {
    version (X86_64) {
        long ret;
        @register("rax") long _num = num;
        @register("rdi") long _arg1 = arg1;
        @register("rsi") long _arg2 = arg2;
        @register("rdx") long _arg3 = arg3;
        @register("r10") long _arg4 = arg4;

        asm {
            "syscall"
            : "=a" (ret)
            : "r" (_arg1), "r" (_arg2), "r" (_arg3), "r" (_arg4),
              "0" (_num)
            : "rcx", "r11", "memory", "cc";
        }

        return ret;
    } else version (AArch64) {
        @register("x8") long _num = num;
        @register("x0") long _arg1 = arg1;
        @register("x1") long _arg2 = arg2;
        @register("x2") long _arg3 = arg3;
        @register("x3") long _arg4 = arg4;

        asm {
            "svc #0"
            : "=r" (_arg1)
            : "r" (_arg1), "r" (_arg2), "r" (_arg3), "r" (_arg4),
              "r" (_num)
            : "memory", "cc";
        }

        return _arg1;
    }
}


extern(C) void _start() {
    long timesleep = 60;

    while (true) {
        // YIELD!
        syscall0(YIELD);

        // This should wait forever
        static if (HAVE_PAUSE) {
            syscall0(PAUSE);
        } else {
            syscall4(PPOLL, 0, 0, 0, 0);
        }

        // How the fuck did you come here?
        // Sleep 60s in case of runaway loop (It shouldn't happen)
        syscall1(NANOSLEEP, cast(long) &timesleep);
    }
}
