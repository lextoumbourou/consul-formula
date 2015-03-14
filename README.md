# consul-formula

Salt formula to setup and configure [Consul](https://www.consul.io/docs/index.html).

***

## Configuration overview

Firstly, the Consul agent will usually be run on every server in your environment, so your top.sls file may look something like this:

```
base:
  '*':
    - consul
```

## Specifying servers and ui hosts

To specify which nodes will behave as Consul servers, add the ``server_target`` field to the ``consul`` object in Pillar. Which, by default, accepts a Compound match of servers:

```
consul:
  server_target: 'consul-servers*'
```

The same applies to the hosts that should serve the Consul UI, the field ``ui_target`` specifies the Web UI target:

```
consul:
  # ..
  ui_target: 'consul-web01'
```

If you would prefer to do a ``glob`` match or some other match type, you can add the ``targeting_method`` field to Pillar:

```
consul:
  # ..
  targetting_method: 'glob'
```
