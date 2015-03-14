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
  server_target: 'consul-server*'
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

## Bootstrapping a datacenter (first run)

Because Bootstraping is a one off task, you can manually pass in a ``consul_bootstrap`` Pillar arg using ``state.sls``.

```
salt 'consul-server01' state.sls consul pillar={'consul_bootstrap': true}
```

Then, you should deploy you other server nodes as follows:

```
salt 'consul-server0[2-5]' state.sls consul
```

Allowing them to join the cluster before rerun the state on the first node without ``consul_bootstrap`` set, removing it from Bootstrap mode.

```
salt 'consul-server01' state.sls consul
```

You can now perform Highstates across all agents with impunity.

*Note: do not set ``consul_boostrap`` to ``true`` in your Pillar files!*
