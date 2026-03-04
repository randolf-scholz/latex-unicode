# Define the default task
export NAME := "unicode-symbols"
export BUILD_DIR := ".build"
export RESULT_DIR := ".results"
export ROOT_DIR := `git rev-parse --show-toplevel`
export SOURCE_DIR := ROOT_DIR + "/src"
export TEST_DIR := ROOT_DIR + "/tests"
export TEXMF_DIR := "texmf"
export DEV_DIR := ROOT_DIR + "/dev"
# use the C locale for numeric formatting
export LC_NUMERIC := "C"


default:
  @just --list

# install the LaTeX package
install:
    cp -r src/* "$(kpsewhich -var-value TEXMFHOME)/tex/latex/"


# setup for local usage
setup target=".":
    mkdir -p "{{target}}/{{TEXMF_DIR}}/tex/latex"
    ln -sr "{{SOURCE_DIR}}/"* "{{target}}/{{TEXMF_DIR}}/tex/latex/"
    ln -sr "{{TEST_DIR}}/utils" "{{target}}/{{TEXMF_DIR}}/tex/latex/utils"


# remove all build and result directories
clean target=".":
    find "{{target}}" -type d -name "{{TEXMF_DIR}}" -prune -exec rm -rf {} \;
    find "{{target}}" -type d -name "{{BUILD_DIR}}" -prune -exec rm -rf {} \;
    find "{{target}}" -type d -name "{{RESULT_DIR}}" -prune -exec rm -rf {} \;
    find "{{target}}" -type f -name "*.pdf" -delete
    just setup {{ROOT_DIR}}
    just setup {{TEST_DIR}}


# create the build and result directories
test_setup:
    just clean {{ROOT_DIR}}
    just clean {{TEST_DIR}}
    just setup {{ROOT_DIR}}
    just setup {{TEST_DIR}}


[no-exit-message]
[working-directory: 'tests']  # FIXME: doesn't seem to support {{TEST_DIR}}
test_compile $file $compiler:
    #!/usr/bin/env bash
    # Tries to compile a LaTeX file with a given compiler
    # Exit code: 0 if successful, 1 if failed
    # stdout: "✅️" if successful, "⚠️" if successful with warnings, "❌️" if failed
    name="$(basename "$file" '.tex')"
    path="$(dirname "$file")"
    OUTPUT_DIR="$BUILD_DIR/$compiler/$path/$name"
    TARGET_DIR="$RESULT_DIR/$compiler/$path"
    mkdir -p "$TARGET_DIR"
    mkdir -p "$OUTPUT_DIR"

    # define array with compiler options "-shell-escape" "-interaction=nonstopmode"
    options=(
        "-$compiler"
        "-output-directory=$OUTPUT_DIR"
    )

    # try to compile with -Werror
    if latexmk -Werror "${options[@]}" "$file" > /dev/null 2>&1; then
        echo -e "✅️"
        cp "$OUTPUT_DIR/$name.pdf" "$TARGET_DIR/$name.pdf"
        exit 0
    # compile without -Werror
    elif latexmk "${options[@]}" "$file" > /dev/null 2>&1; then
        echo -e "⚠️"
        cp "$OUTPUT_DIR/$name.pdf" "$TARGET_DIR/$name.pdf"
        exit 0
    else
        echo -e "❌️"
        exit 1
    fi


[no-exit-message]
[working-directory: 'tests']  # FIXME: doesn't seem to support {{TEST_DIR}}
test_one $file:  # compile a single test file
    #!/usr/bin/env bash
    # EXIT CODE: equal to the number of failed compilers
    # STDOUT: the result of each compiler
    # compile the file, catch the errors in a variable

    # compile with pdfLaTeX
    result_pdf=$(just test_compile "$file" "pdf")
    exitcode_pdf=$?
    # compile with LuaLaTeX
    result_lua=$(just test_compile "$file" "pdflua")
    exitcode_lua=$?
    # compile with XeLaTeX
    result_xe=$(just test_compile "$file" "pdfxe")
    exitcode_xe=$?
    # print the results

    padded_name=$(printf "%-62s" "$file")
    echo -e "tests/$padded_name pdf=$result_pdf, lua=$result_lua, xe=$result_xe"
    # exit with the sum of the error codes (integer addition)

    error_count=$(( exitcode_pdf + exitcode_lua + exitcode_xe ))
    exit $error_count


[working-directory: 'tests']  # FIXME: doesn't seem to support {{TEST_DIR}}
test $case="*":  # run all tests
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s globstar

    # run the setup task
    just clean

    # detect all test files
    files=(**/test_${case}.tex)
    echo "Found ${#files[@]} test files."

    # setup PIDs and statuses arrays
    pids=()
    statuses=()

    interrupt_handler() {
        # Kill all children we started; already-finished ones will just error and be ignored
        for pid in "${pids[@]}"; do
            kill "$pid" 2>/dev/null || true
        done
        # IMPORTANT: do *not* exit here – we still want to print a summary
        echo
        echo
        echo -e "\033[1;33m⚠️ ⚠️ ⚠️  tests interrupted ⚠️ ⚠️ ⚠️\033[0m"
        echo
    }

    # On Ctrl+C (INT) or SIGTERM, mark interrupted and kill children
    trap interrupt_handler INT TERM

    # run the tests in parallel
    start_time=$(date +%s.%N)
    for file in "${files[@]}"; do
        just test_one "$file" 2>/dev/null &
        pids+=($!)
        statuses+=()   # placeholder for this test's status
    done

    # collect the exit codes of all child processes
    for i in "${!pids[@]}"; do
        pid="${pids[i]}"
        set +e
        wait "$pid"
        statuses[i]=$?     # raw exit status
        set -e
    done
    end_time=$(date +%s.%N)
    runtime=$(echo "$end_time - $start_time" | bc)

    # print horizontal line
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

    total=${#pids[@]}
    pass_count=0
    fail_count=0
    kill_count=0

    for status in "${statuses[@]}"; do
        case "$status" in
            0) pass_count=$((pass_count + 1));;
            [1-3]) fail_count=$((fail_count + 1));;
            *) kill_count=$((kill_count + 1));;
        esac
    done

    # print the summary
    printf "\033[1;33m%d/%d killed\033[0m  " "$kill_count" "$total"
    printf "\033[1;31m%d/%d failed\033[0m  " "$fail_count" "$total"
    printf "\033[1;32m%d/%d passed\033[0m  " "$pass_count" "$total"
    printf "\033[1mTotal runtime: %.1f seconds\033[0m\n" "$runtime"

    # Exit 1 if any test failed/killed
    if [ "$fail_count" -gt 0 ] || [ "$kill_count" -gt 0 ]; then
        exit 1
    fi
