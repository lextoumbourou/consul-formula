{%- set install_path = salt['pillar.get']('consul:install_path', '/usr/local/bin') %}
{%- set version = salt['pillar.get']('consul:version', '0.5.0') %}
{%- set source_hash =  salt['pillar.get']('consul:source_hash', 'md5=9ce296fccaca3180e6911df7fcd641e9') %}
{%- set user = salt['pillar.get']('consul:user', 'consul') %}
{%- set group = salt['pillar.get']('consul:group', 'consul') %}
{%- set home_dir = salt['pillar.get']('consul:home', '/opt/consul') %}
{%- set domain = salt['pillar.get']('consul:domain', 'consul.') %}
{%- set source_url = 'https://dl.bintray.com/mitchellh/consul/' ~ version ~ '_linux_amd64.zip' %}

{%- set targeting_method = salt['pillar.get']('consul:targeting_method', 'compound') %}
{%- set server_target = salt['pillar.get']('consul:server_target') %}
{%- set ui_target = salt['pillar.get']('consul:ui_target') %}

{%- set is_server = salt['match.' ~ targeting_method](server_target) %}
{%- set is_ui = salt['match.' ~	targeting_method](server_target) %}

{%- set consul = {} %}
{%- do consul.update({

    'install_path': install_path,
    'version': version,
    'source_url': source_url,
    'source_hash': source_hash,
    'user': user,
    'group': group,
    'home_dir': home_dir,
    'config_dir': '/etc/consul.d',
    'config_file': '/etc/consul.conf',
    'log_file': '/var/log/consul.log',
    'is_server': is_server,
    'is_ui': is_ui,
    'domain': domain

}) %}
