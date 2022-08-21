# Restart Operator

Restarts a resource its dependency also restarts.

Example usage:

```
local_resource(
    name='public-api-restarter',
    resource_deps=['backend-api', 'public-api'], 
    serve_cmd=['./restart-operator.sh', 'backend-api', 'public-api'], 
    deps=['./restart-operator.sh']);
```

Will restart `public-api` whenever `backend-api` restarts.

This can be useful for resources that source some of their configuration from their dependencies during startup.

It can also be useful to re-run integration tests whenever the component it tests restarts. For example:

```
local_resource(
    name='public-api-tests',
    resource_deps=['public-api'], 
    cmd='RUN YOUR TESTS', 
    deps=['./test/public-api']);

local_resource(
    name='public-api-restarter',
    resource_deps=['public-api'], 
    serve_cmd=['./restart-operator.sh', 'public-api', 'public-api-tests'], 
    deps=['./restart-operator.sh']);
```

## Future Work

1. Support multiple dependencies.
2. See if there is a way to define the dependency information on the original resource and have the operator read that.