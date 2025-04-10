# Define the default task
export NAME := "unicode-symbols"
export BUILD_DIR := ".build"
export RESULT_DIR := ".results"
export ROOT_DIR := `git rev-parse --show-toplevel`
export TEST_DIR := ROOT_DIR + "/tests"
export TEXMF_DIR := "texmf"
export DEV_DIR := ROOT_DIR + "/dev"
# use the C locale for numeric formatting
export LC_NUMERIC := "C"


default:
  @just --list


install:  # install the LaTeX package
    cp -r src/* "$(kpsewhich -var-value TEXMFHOME)/tex/latex/"


clean:  # remove all .build directories
    find . -type d -name '{{BUILD_DIR}}' -prune -exec rm -rf {} \;
    find . -type d -name '{{RESULT_DIR}}' -prune -exec rm -rf {} \;
    find "{{TEST_DIR}}" -type f -name "*.pdf" -delete
    find "{{DEV_DIR}}" -type f -name "*.pdf" -delete


test_setup:  # create the build and result directories
    # cleanup the test directories
    rm -rf "{{TEST_DIR}}/{{BUILD_DIR}}"
    rm -rf "{{TEST_DIR}}/{{RESULT_DIR}}"
    rm -rf "{{TEST_DIR}}/{{TEXMF_DIR}}"
    rm -rf "{{ROOT_DIR}}/{{TEXMF_DIR}}"
    # remove pdf files from the test and dev directory
    find "{{TEST_DIR}}" -type f -name "*.pdf" -delete
    find "{{DEV_DIR}}" -type f -name "*.pdf" -delete
    # create the test directories
    mkdir -p "{{TEST_DIR}}/{{BUILD_DIR}}"
    mkdir -p "{{TEST_DIR}}/{{RESULT_DIR}}"
    mkdir -p "{{TEST_DIR}}/{{TEXMF_DIR}}/tex/latex"
    mkdir -p "{{ROOT_DIR}}/{{TEXMF_DIR}}/tex/latex"
    # simlink all files from src/ to texmf/
    ln -sr "{{ROOT_DIR}}/src/"* "{{TEST_DIR}}/{{TEXMF_DIR}}/tex/latex/"
    ln -sr "{{ROOT_DIR}}/src/"* "{{ROOT_DIR}}/{{TEXMF_DIR}}/tex/latex/"
    # simlink tests/utils to texmf/
    ln -sr "{{ROOT_DIR}}/tests/utils" "{{TEST_DIR}}/{{TEXMF_DIR}}/tex/latex/"
    ln -sr "{{ROOT_DIR}}/tests/utils" "{{ROOT_DIR}}/{{TEXMF_DIR}}/tex/latex/"


[no-exit-message]
[working-directory: 'tests']  # FIXME: doesn't seem to support {{TEST_DIR}}
test_compile $file $compiler:
    #!/usr/bin/env bash
    # Tries to compile a LaTeX file with a given compiler
    # Exit code: 0 if successful, 1 if failed
    # stdout: "✅" if successful, "⚠️" if successful with warnings, "❌" if failed
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
        echo -e "✅"
        cp "$OUTPUT_DIR/$name.pdf" "$TARGET_DIR/$name.pdf"
        exit 0
    # compile without -Werror
    elif latexmk "${options[@]}" "$file" > /dev/null 2>&1; then
        echo -e "⚠️"
        cp "$OUTPUT_DIR/$name.pdf" "$TARGET_DIR/$name.pdf"
        exit 0
    else
        echo -e "❌"
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

    # run the setup task
    just test_setup

    # detect all test files
    shopt -s globstar
    files=(**/test_$case.tex)
    echo "Found ${#files[@]} test files."

    # run the tests in parallel
    start_time=$(date +%s.%N)
    pids=()
    for file in "${files[@]}"; do
        just test_one "$file" &
        pids+=($!)
    done

    # collect the exit codes of all child processes
    fail_count=0
    for pid in "${pids[@]}"; do
        wait "$pid" || ((fail_count++))
    done
    end_time=$(date +%s.%N)
    runtime=$(echo "$end_time - $start_time" | bc)

    # print the summary
    total=${#pids[@]}
    pass_count=$(( total - fail_count ))
    echo "$pass_count/$total passed"
    printf "Total runtime: %.1f seconds\n" "$runtime"

    # Exit with non-zero if any test failed
    exit "$fail_count"
