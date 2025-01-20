!#/bin/bash

{{RCC}} "$@" | sed '/^\s*\/\/.*$/d' > "{{OUTPUT}}"
