#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=8

# Handle name change for netcdf
EXAWIND_MODMAP[netcdf]=netcdf-c

exawind_spack_env ()
{
    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack

    local compiler_arg=$1
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-$compiler_arg}
    export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}

    if [[ $OSTYPE = "darwin"* ]] ; then
        local brew_prefix=$(brew config | awk -F: '/HOMEBREW_PREFIX/ {print $2;}')
        if [ -f ${brew_prefix}/opt/modules/init/bash ]; then
            source ${brew_prefix}/opt/modules/init/bash
        else
            echo "ERROR: Cannot find module command. brew install modules"
        fi
        export EXAWIND_NUM_JOBS_DEFAULT=4
    fi
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)

    echo "==> Using spack configuration: ${SPACK_ROOT}"
}

exawind_env_gcc ()
{
    exawind_spack_env gcc

    if [[ $OSTYPE = "darwin"* ]] ; then
        exawind_load_deps mpi cmake netlib-lapack
    fi
}

exawind_env_intel ()
{
    if [[ $OSTYPE = "darwin"* ]] ; then
        echo "ERROR: Intel compiler not supported on OSX"
        exit 1
    else
        exawind_spack_env intel
    fi
}

exawind_env_clang ()
{
    exawind_spack_env clang

    if [[ $OSTYPE = "darwin"* ]] ; then
        exawind_load_deps mpi cmake netlib-lapack
    fi
}
