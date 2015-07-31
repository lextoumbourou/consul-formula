{%- set install_path = salt['pillar.get']('consul:install_path', '/usr/local/bin') %}
{%- set ui_install_path = salt['pillar.get']('consul:ui_install_path', '/opt/consul/ui') %}
{%- set version = salt['pillar.get']('consul:version', '0.5.2') %}
{%- set user = salt['pillar.get']('consul:user', 'consul') %}
{%- set group = salt['pillar.get']('consul:group', 'consul') %}
{%- set home_dir = salt['pillar.get']('consul:home', '/opt/consul') %}
{%- set domain = salt['pillar.get']('consul:domain', 'consul.') %}

{%- set source_url = 'https://dl.bintray.com/mitchellh/consul/' ~ version ~ '_linux_amd64.zip' %}
{%- set source_hash =  salt['pillar.get']('consul:source_hash', 'md5=37000419d608fd34f0f2d97806cf7399') %}

{%- set ui_source_url = 'https://dl.bintray.com/mitchellh/consul/' ~ version ~ '_web_ui.zip' %}
{%- set ui_source_hash = salt['pillar.get']('consul:ui_source_hash', 'md5=eb98ba602bc7e177333eb2e520881f4f') %}

{%- set targeting_method = salt['pillar.get']('consul:targeting_method', 'glob') %}

{%- if salt['grains.get']('consul_server_target') != '': %}
       {%- set server_target = salt['grains.get']('consul_server_target') %}
       {%- set is_server = True %}
{%- else %}
       {%- set server_target = salt['pillar.get']('consul:server_target') %}
       {%- set is_server = salt['match.' ~ targeting_method](server_target) %}
{%- endif %}

{%- if salt['grains.get']('consul_ui_target') != '': %}
       {%- set ui_target = salt['grains.get']('consul_ui_target') %}
       {%- set is_ui = True %}
{%- else %}
       {%- set ui_target = salt['pillar.get']('consul:ui_target') %}
       {%- set is_ui = salt['match.' ~	targeting_method](ui_target) %}
{%- endif %}

{%- set ui_public_target = salt['pillar.get']('consul:ui_public_target') %}
{%- set bootstrap_target = salt['pillar.get']('consul:bootstrap_target') %}

{%- set ui_public_target = salt['match.' ~ targeting_method](ui_public_target) %}

{%- if salt['grains.get']('datacenter') != '': %}
       {%- set datacenter = salt['grains.get']('datacenter') %}
{%- else %}
       {%- set datacenter = salt['pillar.get']('consul:datacenter') %}

{%- endif %}

{%- set nodename = salt['grains.get']('nodename') %}
{%- set force_mine_update = salt['mine.send']('network.get_hostname') %}
{%- set servers = salt['mine.get'](server_target, 'network.get_hostname', targeting_method).values() %}

# Create a list of servers that can be used to join the cluster
{%- set join_server = None %}
{%- for server in servers if server != nodename %}
    {%- set join_server = server %}
{%- endfor %}

{%- set consul = {} %}
{%- do consul.update({

    'install_path': install_path,
    'ui_install_path': ui_install_path,
    'version': version,
    'source_url': source_url,
    'source_hash': source_hash,
    'ui_source_url': ui_source_url,
    'ui_source_hash': ui_source_hash,
    'user': user,
    'group': group,
    'home_dir': home_dir,
    'config_dir': '/etc/consul.d',
    'config_file': '/etc/consul.conf',
    'log_file': '/var/log/consul.log',
    'is_server': is_server,
    'is_ui': is_ui,
    'ui_public_target': ui_public_target,
    'domain': domain,
    'servers': server,
    'bootstrap_target': bootstrap_target,
    'join_server': join_server,
    'datacenter': datacenter

}) %}
