# careers provisioning

### Additional app installation steps

#### MySQL read replica

- until we automate this part, create an RDS read replica using params from similar read replicas in other regions.
- The username/password will remain the same, but the host part of the `DATABASE_URL` value will change.

#### Environment setup

In addition to the standard set of app variables (which can be found in our private repo), set the following values:

- `DATABASE_URL`
- `NEW_RELIC_APP_NAME`
- `SECRET_KEY`

Once you have the config file ready with the correct values, use a command similar to the following to load the new values:

```
deis config:push -p ./foo.cfg -a careers-prod
```

### Project Source

https://github.com/mozmar/lumbergh
