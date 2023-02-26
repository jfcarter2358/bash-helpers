# bash-helpers
A repository for generic bash helpers to be sourced into other scripts

## Usage
In order to use any of these helpers in a bash script, simply add
```
source <(curl -s https://raw.githubusercontent.com/jfcarter2358/bash-helpers/main/path/to/helper.sh)
```
to the beginning of your script.

## Contents
### Logger

#### Description

This script provides logging functionality for bash scripts. It keys off of an environment variable named `LOG_LEVEL` with available values being
1. FATAL
2. SUCCESS
3. ERROR
4. WARN
5. INFO
6. DEBUG
7. TRACE

With the logging level increasing in the order shown above. By default, if the variable is not set, then the logger will assume a log level of `INFO`.

In addition, calling a log level of `FATAL` will automatically exit with status code 1 after displaying the message.

#### Usage

To write logs from inside your script, add the following line wherever you want logs printed out
```
_log "<desired log level for the message>" "Message to print"
```

For example, using
```
_log "INFO" "This is an example message"
```

would output
```shell
[INFO] :: This is an example message
```

NOTE: The logger outputs log level labels with specific colors, however the GitHub README is unable to display them. The following is the list of colors as they correspond to log level:

| Level     | Color  |
| --------- | ------ |
| `FATAL`   | red    |
| `SUCCESS` | green  |
| `ERROR`   | red    |
| `WARN`    | yellow |
| `INFO`    | green  |
| `DEBUG`   | cyan   |
| `TRACE`   | blue   |

### Debugger
#### Description

The Bash debugger adds stacktrace printing when an error occurs in your script

#### Usage

To use, ensure that you script/subscripts take the form of a main script which can contain code not in a function, and all other scripts only running code from functions which are written as such:

```bash
function <function name> {
    <function contents>
}
```

After that, add

```bash
# Grab the location of this file to use as the base for our paths
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Setup debug information
# shellcheck disable=SC2034
debug_main_file="${HERE}/<your main file>"
debug_register_file "${HERE}/<path to your subscripts>/*.sh"

debug_setup_trap
```

to the top of your main script and add

```bash
debug_setup_trap
```

to the top of each function you write and now the debugger is setup

If you run the `test.sh` in the examples/debugger directory you should see a stacktrace print
