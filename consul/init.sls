{%- from 'consul/settings.sls' import consul with context %}
{%- set is_bootstrap = salt['pillar.get']('consul_bootstrap') %}

consul|install-system-pkgs:
  pkg.installed:
    - names:
      - wget

consul|create-user-and-group:
  group.present:
    - name: {{ consul.group }}
  user.present:
    - name: {{  consul.user }}
    - gid: {{ consul.group }}
    - require:
      - group: consul|create-user-and-group

{%- for dir in 'data', 'dist' %}
consul|prepare-{{ dir }}-directory:
  file.directory:
    - name: {{ consul.home_dir }}/{{ dir }}
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - makedirs: True
    - recurse:
      - user
      - group
{%- endfor %}

consul|prepare-config-directory:
  file.directory:
    - name: {{ consul.config_dir }}
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - recurse:
      - user
      - group

consul|deploy-config:
  file.managed:
    - name: {{ consul.config_file }}
    - source: salt://consul/files/consul.json
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - template: jinja
    - context:
      is_server: {{ consul.is_server }} 
      is_ui: {{ consul.is_ui }}
      home_dir: {{ consul.home_dir }}
      domain: {{ consul.domain }}
      is_bootstrap: {{ is_bootstrap }}

consul|install-consul:
  archive.extracted:
  - name: {{ consul.install_path }}
  - source: {{ consul.source_url }}
  - source_hash: {{ consul.source_hash }}
  - archive_format: zip
  - if_missing: {{ consul.install_path }}/consul

consul|deploy-upstart-config:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://consul/files/upstart.consul.conf
    - template: jinja
    - context:
      user: {{ consul.user }}
      group: {{ consul.group }}
      install_path: {{ consul.install_path }}
      config_dir: {{ consul.config_dir }}
      config_file: {{ consul.config_file }}
      log_file: {{ consul.log_file }}

consul|ensure-started:
  service.running:
    - name: consul
    - enable: True
    - reload: True
    - watch:
      - file: consul|deploy-config
      - file: consul|deploy-upstart-config

{% if consul.is_server and consul.join_server %}
consul|join-cluster:
  cmd.run:
    - name: consul join {{ consul.join_server }}
{%- endif %}
