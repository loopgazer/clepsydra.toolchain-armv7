# GNU ARM Embedded Toolchain 10 for Platform.IO

> **DISCLAIMER**: This experimental toolchain is not meant to be used in production.

This project produces a **Platform.IO** toolchain
of [GNU ARM Embedded Toolchain 10-2020-q4-preview](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
, providing access to gcc-10.2, and applies fixes for current Cortex-Mx Processors.

With a more recent compiler, the `--std=c++20` compiler flag is introduced and enables
all [C++20 Features](https://en.cppreference.com/w/cpp/compiler_support#cpp20) available in GCC 10.2, e.g:

- [Concepts and Constraints](https://en.cppreference.com/w/cpp/language/constraints)
- [Three-way comparison operator](https://en.cppreference.com/w/cpp/language/operator_comparison#Three-way_comparison)
- [Immediate Functions](https://en.cppreference.com/w/cpp/language/consteval)
- [Co-routines](https://en.cppreference.com/w/cpp/language/coroutines)
- [constinit](https://en.cppreference.com/w/cpp/language/constinit)
- [Descriptive [[nodiscard]]](https://en.cppreference.com/w/cpp/language/attributes/nodiscard)
- ...

Keep in mind, that you will encounter various warnings during the compilation of framework libraries, since most
deprecations have not been taken into account, yet.

Also, it cannot be guaranteed that all the new features work as expected.

## Usage

### Generation

`generate.sh` provides a way to forge a new toolchain for Platform.IO, based on the latest GNU GCC ARM compiler.

Therefore, the raw toolchain is obtained from official sources, extracted and later enhanced with metadata and required
dependency fixes to work in conjunction with Cortex-Mx MCUs.

Executing the script will generate a new toolchain at `${HOME}/.platformio/packages/toolchain-gccarmnoneeabi@10.2`:

```shell
./generate.sh
```

### PlatformIO integration

After generating the toolchain, it may be referenced in `platform_packages` of project's `platform.ini`.

Furthermore, build (un-)flags can be added.

> For an exemplary use, see the [example file](platformio.example.ini).

A re-run of `platformio init --ide clion` will update the CMake configuration to use the new toolchain.

## Fix for Cortex M Processors

The Code, which uses idioms from the C++ standard library, requires the linker to access one of the following archives:

| Library                    | Model                                              |
| -------------------------- | -------------------------------------------------- |
| `libarm_cortexM0l_math.a`    | M0/M0+, Little endian                              |
| `libarm_cortexM4l_math.a`    | M4, Little endian                                  |
| `libarm_cortexM4lf_math.a`   | M4, Little endian, Floating Point Unit             |
| `libarm_cortexM7lfsp_math.a` | M7, Little endian, Single Precision Floating Point |

For example, when using `std::vector`s on a Teensy 4.x, which runs a Cortex-M7, the linker seems to be
missing `libarm_cortexM7lfsp_math.a`.

As a workaround for those cases, the listed archives were extracted
from [`toolchain-gccarmnoneeabi@1.50401.190816`](https://bintray.com/platformio/dl-packages/toolchain-gccarmnoneeabi/1.50401.190816)
and moved to the toolchain's `/lib` folder.