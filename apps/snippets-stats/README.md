# snippets-stats provisioning

1. Install the application
    1. Ensure your Kubernetes and Deis Workflow environments are set correctly!
    2. run `./setup.sh`
    3. load a Deis configuration using a command similar to the following:

        ```
        deis config:push -p ./foo.cfg -a snippets-stats
        ```

    4. run `./scale.sh`

3. [Create an ELB](https://github.com/mozmar/infra/tree/master/elbs) for the app in the new region.

> Note: if the application is reinstalled via Deis Workflow, the snippets ELB **must** be recreated as the port #'s have changed.

### Project Source

https://github.com/mozmar/snippets-stats-proxy
