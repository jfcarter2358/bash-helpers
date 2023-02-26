#! /usr/bin/env bash
# shellcheck disable=SC1091

# Initialize variables
debug_function_associations=""
debug_main_file=""

################
# Setup error trap at a desired location
################
function debug_setup_trap {
    trap 'debug_halt_and_catch_fire $? $LINENO $FUNCNAME' ERR
}

################
# Print out useful errors to the user
################
function debug_halt_and_catch_fire {
    # Collect infromation about where the error happened
    exit_code="$1"
    line_number="$2"
    function_name=""
    file_path="${debug_main_file}"
    if [[ "$#" == "3" ]]; then
        function_name="$3"
        file_path=$(debug_get_file_path "${function_name}")
    fi

    # Grab the line that threw the error
    line_contents=$(debug_get_errored_line "${file_path}" "${line_number}")

    # Print out error information
    if [[ "${function_name}" == "" ]]; then
        # shellcheck disable=SC2154
        _log "ERROR" "Error on line ${blue}${line_number}${no_color} in file ${green}${file_path}${no_color} with exit code ${blue}${exit_code}${no_color}:"
    else
        # shellcheck disable=SC2154
        _log "ERROR" "Error on line ${blue}${line_number}${no_color} in file ${green}${file_path}${no_color} in function ${cyan}${function_name}${no_color} with exit code ${blue}${exit_code}${no_color}:"
    fi

    # Replace any variable references that might be in the line
    subbed_line=$(debug_replace_variables "${line_contents}")

    # Print out error line
    # shellcheck disable=SC2154
    echo -e "    ${yellow}${subbed_line}${no_color}"
    exit "${exit_code}"
}

################
# Replace variable references in a line of code
################
function debug_replace_variables {
    raw_line="$1"
    subbed_line=$(
        # Grab all defined variables, stripping out function definitions
        set | grep '^\S*=.*' | (
            # Loop through each variable
            while read -r variable_line; do
                # Get the name and contents
                variable_name=$(echo "${variable_line}" | awk -F= '{print $1}')
                variable_value=$(echo "${variable_line}" | awk -F= '{print $2}')
                substring_end=$(( ${#variable_value} - 1 ))
                # Strip out single quotes if they're present
                if [[ "${variable_value:0:1}" == "'" ]] && [[ "${variable_value:$substring_end}" == "'" ]]; then
                    substring_end=$(( ${#variable_value} - 2 ))
                    variable_value="${variable_value:1:$substring_end}"
                fi
                # Replace the variable in the line (if it exists)
                raw_line="${raw_line//\$\{${variable_name}\}/${variable_value}}"
            done
            # Return the line with variable substitutions
            echo "${raw_line}"
        )
    )
    # Return the line with variable substitutions
    echo "${subbed_line}"
}

################
# Get the contents of the specific line in a file that errored
################
function debug_get_errored_line {
    file_path="$1"
    line_number="$2"
    # Grab the line at ${line_number} in the file at ${file_path}
    erorred_line=$(sed -n "${line_number}p" "${file_path}")
    # Return the line contents
    echo "${erorred_line}" | xargs
}

################
# Lookup which file contains a specific function
################
function debug_get_file_path {
    function_name="$1"
    # Search function associations for the function name and grab the corresponding file path
    file_path=$(echo -e "${debug_function_associations}" | grep "${function_name}:" | awk -F: '{print $2}')
    # Return the file path
    echo "${file_path}"
}

################
# Register a file and its functions with the debugger
################
function debug_register_file {
    file_pattern="$1"
    for file_path in $file_pattern; do
        debug_function_associations=$(
            # Look through the file for patterns matching a function definition
            grep '^function .*' "${file_path}" | awk '{print $2}' | (
                while read -r function_name; do
                    # Add the funciton name and the file it's in to the function associations
                    debug_function_associations+="${function_name}:${file_path}\n"
                done
                echo "${debug_function_associations}"
            )
        )
    done
}
