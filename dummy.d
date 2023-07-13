/*
    Copyright Ernesto Castellotti <ernesto@castellotti.net>
    SPDX-License-Identifier: GPL-3.0-only
*/

import gcc.attributes : register, always_inline;

version (X86_64) {
    alias clong = long; // long == 64bit
    enum YIELD = 24;
    enum PAUSE = 34;
    enum NANOSLEEP = 35;
    enum HAVE_PAUSE = true;
} else version (ARM) {
    alias clong = int;  // long == 32 bit
    enum YIELD = 158;
    enum PAUSE = 29;
    enum NANOSLEEP = 162;
    enum HAVE_PAUSE = true;
} else version (AArch64) {
    alias clong = long; // long == 64 bit
    enum YIELD = 124;
    enum PPOLL = 73;
    enum NANOSLEEP = 101;
    enum HAVE_PAUSE = false;
} else version (ARM_Thumb) {
    static assert(0, "ARM Thumb mode not supported.");
} else {
    static assert(0, "CPU architecture not supported.");
}

clong syscall0(clong num) @always_inline {
    version (X86_64) {
        clong ret = void;
        @register("rax") clong _num = num;

        asm {
            "syscall"
            : "=a" (ret)
            : "0" (_num)
            : "rcx", "r11", "memory", "cc";
        }

        return ret;
    } else version (ARM) {
        @register("r7") clong _num = num;
        @register("r0") clong _arg1 = void;

        asm {
            "svc #0"
            : "=r"(_arg1), "=r"(_num)
            : "r"(_arg1),
              "r"(_num)
            : "memory", "cc", "lr";
        }

        return _arg1;
    } else version (AArch64) {
        @register("x8") clong _num = num;
        @register("x0") clong _arg1 = void;

        asm {
            "svc #0"
            : "=r" (_arg1)
            : "r" (_num)
            : "memory", "cc";
        }

        return _arg1;
    }
}

clong syscall1(clong num, clong arg1) @always_inline {
    version (X86_64) {
        clong ret = void;
        @register("rax") clong _num = num;
        @register("rdi") clong _arg1 = arg1;

        asm {
            "syscall"
            : "=a" (ret)
            : "r" (_arg1),
              "0" (_num)
            : "rcx", "r11", "memory", "cc";
        }

        return ret;
    } else version (ARM) {
        @register("r7") clong _num = num;
        @register("r0") clong _arg1 = arg1;

        asm {
            "svc #0"
            : "=r"(_arg1), "=r"(_num)
            : "r"(_arg1),
              "r"(_num)
            : "memory", "cc", "lr";
        }

        return _arg1;
    } else version (AArch64) {
        @register("x8") clong _num = num;
        @register("x0") clong _arg1 = arg1;

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

clong syscall4(clong num, clong arg1, clong arg2, clong arg3, clong arg4) @always_inline {
    version (X86_64) {
        clong ret = void;
        @register("rax") clong _num = num;
        @register("rdi") clong _arg1 = arg1;
        @register("rsi") clong _arg2 = arg2;
        @register("rdx") clong _arg3 = arg3;
        @register("r10") clong _arg4 = arg4;

        asm {
            "syscall"
            : "=a" (ret)
            : "r" (_arg1), "r" (_arg2), "r" (_arg3), "r" (_arg4),
              "0" (_num)
            : "rcx", "r11", "memory", "cc";
        }

        return ret;
    } else version (ARM) {
        @register("r7") clong _num = num;
        @register("r0") clong _arg1 = arg1;
        @register("r1") clong _arg2 = arg2;
        @register("r2") clong _arg3 = arg3;
        @register("r3") clong _arg4 = arg4;

        asm {
            "svc #0"
            : "=r"(_arg1), "=r"(_num)
            : "r" (_arg1), "r" (_arg2), "r" (_arg3), "r" (_arg4),
              "r"(_num)
            : "memory", "cc", "lr";
        }

        return _arg1;
    } else version (AArch64) {
        @register("x8") clong _num = num;
        @register("x0") clong _arg1 = arg1;
        @register("x1") clong _arg2 = arg2;
        @register("x2") clong _arg3 = arg3;
        @register("x3") clong _arg4 = arg4;

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
    clong timesleep = 60;

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
        syscall1(NANOSLEEP, cast(clong) &timesleep);
    }
}
