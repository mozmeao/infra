check_meao_env() {
    if [ -z "$DEIS_PROFILE" ]; then
        echo "Please set DEIS_PROFILE"
        exit 1
    fi


    if [ -z "$KUBECONFIG" ]; then
        echo "Please set KUBECONFIG"
        exit 1
    fi
}

check_neres_bin() {
    which neres > /dev/null
    if [ $? -ne 0 ]; then
        echo "Please install neres:"
        echo "https://github.com/glogiotatidis/neres/"
        exit 1
    fi
}

check_neres_env() {
    if [ -z "$NERES_EMAIL_1" ]; then
        echo "Please set NERES_EMAIL_1"
        echo "More information here: https://github.com/mozmar/ee-infra-private/tree/master/synthetics"
        exit 1
    fi

    if [ -z "$NERES_EMAIL_2" ]; then
        echo "Please set NERES_EMAIL_2"
        echo "More information here: https://github.com/mozmar/ee-infra-private/tree/master/synthetics"
        exit 1
    fi
    check_neres_bin
}

monitor_exists() {
    all_monitors=$(neres list-monitors --raw)
    monitor_name="${1}"
    jq -r -e ".[] | select(.name == \"${monitor_name}\")" <<< "${all_monitors}" > /dev/null
}

create_monitor_if_missing() {
    NAME=$1
    URL=$2
    LOCATION=$3
    VALIDATION=$4
    echo "Checking ${NAME}..."
    if ! monitor_exists "${NAME}" ; then
        neres add-monitor "${NAME}" \
            "${URL}" \
            --location "${LOCATION}" \
            --frequency 5 \
            --email "${NERES_EMAIL_1}" \
            --email "${NERES_EMAIL_2}" \
            ${VALIDATION:+ --validation-string "${VALIDATION}"}
            # only pass VALIDATION if it's set
    else

        echo "Monitor '${NAME}' already exists, skipping."
    fi
}

# get a newrelic monitor id based on its name
get_newrelic_monitor_id() {
    neres list-monitors --raw | jq -er ".[] | select(.name == \"$1\") | .id"
}
