{%- if consul.manage_firewall != False and grains['os'] == 'CentOS' or grains['os'] == 'RedHat'  %}
{%- if consul.is_server %}
consul|configure-serf-firewall:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8301
    - proto: tcp
consul|configure-server-firewall:
  iptables.append:
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

{% if consul.ui_public_target %}
consul|configure-ui-firewall:
  iptables.append:
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
