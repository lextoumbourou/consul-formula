# consul-formula

Salt formula to setup and configure [Consul](https://www.consul.io/docs/index.html).

## Status

Not production ready (out of the box). Close, but not there just yet. To get it working will require a bit of fiddling until I get a chance to test this 100%. Sorry, just mad busy right now...

***

## Configuration overview

The Consul agent will usually be run on every host in your environment, so your top.sls file may look something like this:

```
base:
  '*':
    - consul
```

## Setting the Datacenter

You may optionally set the desired [datacenter](https://www.consul.io/docs/guides/datacenters.html) from a pillar or a grain. By default
consul.io will put the nodes in DC1.

To specify a datacenter for a group of nodes, add the ``datacenter`` field to the ``consul`` object in Pillar:
```
consul:
  datacenter: 'datacenter6'
```

You may also set a specifc node to a datacenter via a grain:
```
salt <node> grains.setval datacenter dev
```
which will populate /etc/salt/grains with the key of datacenter and value of "dev"

To delete the grain 
```
salt <node> grains.delval datacenter destructive=True 
```

## Targeting servers and ui hosts

To specify which nodes will behave as Consul [servers](http://www.consul.io/docs/guides/servers.html), add the ``server_target`` field to the ``consul`` object in Pillar. Which, by default, accepts a Glob match of servers:

```
consul:
  server_target: 'consul-server*'
```

The same applies to the minions that should serve the Consul UI, the field ``ui_target`` specifies the Web UI target:

```
consul:
  # ..
  ui_target: 'consul-web01'
```
Setting this will bring up the UI bound to localhost and available via a SSH tunnel. The default install directory is /opt/consul/ui.

If you wish to make a minion a public facing UI (ie bind's to eth0 and not localhost) then set ``ui_public_target``:
```
consul:
  # ..
  ui_target: 'consul-web01'
  ui_public_target: 'consul-web01'
```
and UI will be available on http://consul-web01:8500/ui

If you would prefer to do a ``compound`` or ``grain`` match or some other match type, you can add the ``targeting_method`` field to Pillar:

```
consul:
  # ..
  server_target: 'consul:server'
  targeting_method: 'grain'
```

## Bootstrapping a datacenter (first run)

Because Bootstraping is a one off task and should only be run on the first node in the cluster, you can perform a Bootstrap on one node by manually pass in a ``consul_bootstrap`` Pillar arg using ``state.sls``.

```
salt 'consul-server01' state.sls consul pillar={'consul_bootstrap': true}
```

*Note: do not set ``consul_boostrap`` to ``true`` in your Pillar files!*

Then, you should deploy you other server nodes as per the ``Joining servers`` section.

## Joining servers

Servers are automatically joined to the cluster if more than 1 server node is discovered in the ``server_target`` match. However, for this to work, you'll need to setup the Salt Mine on each minion by editing ``/etc/salt/minion.d/mine_functions.conf`` and adding these lines:

```
mine_functions:
  network.get_hostname: []
  grains.items: []
```

Then, you can add servers like so:

```
salt 'consul-server0[2-5]' state.sls consul
```

Once the datacentre is bootstraped and you have more than 1 node, you can reapply the Salt state the the first, bootstrapped node without setting the ``consul_bootstrap`` Pillar, to take it out of bootstrap mode.

```
salt 'consul-server01' state.sls consul
```
