# Restart Operator

Restarts a resource its dependency also restarts.

Example usage:

```
local_resource(
    name='public-api-restarter',
    resource_deps=['backend-api-1', 'backend-api-2', 'public-api'], 
    serve_cmd=['./restart-operator.sh', 'public-api', 'backend-api-1', 'backend-api-2'], 
    deps=['./restart-operator.sh']);
```

Will restart `public-api` whenever `backend-api-1` or `backend-api-2` restarts.

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
    serve_cmd=['./restart-operator.sh', 'public-api-tests', 'public-api'], 
    deps=['./restart-operator.sh']);
```

## Future Work

1. See if there is a way to define the dependency information on the original resource and have the operator read that.
