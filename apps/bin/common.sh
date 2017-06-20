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
e
