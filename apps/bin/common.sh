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
