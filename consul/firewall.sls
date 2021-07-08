{%- from 'consul/settings.sls' import consul with context %}

{%- if consul.manage_firewall == True and grains['os'] == 'CentOS' or grains['os'] == 'RedHat'  %}
{%- if consul.is_server %}
consul|configure-serf-firewall:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8301
    - proto: tcp
consul|configure-server-firewall:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8300
    - proto: tcp
{% else %}
consul|remove-serf-server-firewall:
  iptables.delete:
    - name: consul.io_remove_serf_lan
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8301
    - proto: tcp
consul|remove-server-firewall:
  iptables.delete:
    - name: consul.io_remove_server
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8300
    - proto: tcp
{%- endif %}

{% if consul.is_ui and consul.ui_public_target %}
consul|configure-ui-firewall:
  iptables.insert:
    - position: 1
    - name: consul.io_configure_ui_firewall
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8500
    - proto: tcp
{% else %}
consul|remove-ui-firewall:
  iptables.delete:
    - name: consul.io_remove_ui_firewall
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8500
    - proto: tcp
{%- endif %}

{%- endif %}
