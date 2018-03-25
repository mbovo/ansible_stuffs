import os
import pytest

import testinfra.utils.ansible_runner


testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


@pytest.fixture(scope="module")
def get_vars(host):
    return host.ansible("include_vars", "../../defaults/main.yml")['ansible_facts']


def test_create_user(host, get_vars):
    assert host.user(get_vars['nexus_user']).uid == int(get_vars['nexus_uid'])


def test_create_group(host,get_vars):
    u = host.user(get_vars['nexus_group'])
    assert u.gid == int(get_vars['nexus_gid'])


def test_download_latest_version(host):
    f = host.file('/opt/latest-unix.tar.gz')
    assert f.exists
    assert f.sha256sum == 'd055006ce90778ca7441efcccb2c979429fe296d1871642b99da2e97c04724a5'


def test_extract_nexus(host):
    found = host.ansible("find", 'paths="/opt" patterns="nexus-*" file_type="directory"' )
    matched = found['matched']
    filenames = found['files']

    assert matched > 0
    f = host.file(filenames[0]['path'])
    assert f.exists
    assert f.is_directory


def test_find_target_directory():
    pass


def test_set_ownership(host,get_vars):
    found = host.ansible("find", 'paths="/opt" patterns="nexus-*" file_type="directory"' )
    matched = found['matched']
    filenames = found['files']

    assert matched > 0
    f = host.file(filenames[0]['path'])
    assert f.user == get_vars['nexus_user']
    assert f.group == get_vars['nexus_group']

    path = get_vars['nexus_data_path']

    f = host.file(path)
    assert f.user == get_vars['nexus_user']
    assert f.group == get_vars['nexus_group']


def test_symlink(host, get_vars):
    f = host.file(get_vars['nexus_path'])
    assert f.exists
    assert f.is_symlink
    assert f.user == get_vars['nexus_user']
    assert f.group == get_vars['nexus_group']


def test_install_systemd_service_file(host, get_vars):
    f = host.file('/usr/lib/systemd/system/nexus.service')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_installing_keystore_for_ssl_certs(host, get_vars):
    path = get_vars['nexus_path']
    u, g = get_vars['nexus_user'], get_vars['nexus_group']
    f = host.file(path + '/etc/ssl/keystore.jks')
    assert f.exists
    assert f.user == u
    assert f.group == g


def test_enabling_https_on_jetty(host, get_vars):
    path = get_vars['nexus_path']
    f = host.file(path + '/etc/jetty/jetty-https.xml')
    assert f.exists
    nksp = get_vars['nexus_keystore_passwd']
    nkmp = get_vars['nexus_keymanager_passwd']
    nktp = get_vars['nexus_truststore_passwd']
    assert f.contains('<Set name=\"KeyStorePassword\">' + nksp + '</Set>')
    assert f.contains('<Set name=\"KeyManagerPassword\">' + nkmp + '</Set>')
    assert f.contains('<Set name=\"TrustStorePassword\">' + nktp + '</Set>')


def test_create_data_path(host, get_vars):
    path = get_vars['nexus_path']
    f = host.file( path + '/etc/')
    assert f.exists
    assert f.is_directory


def test_enabling_https_port_8443(host, get_vars):
    path = get_vars['nexus_data_path']
    f = host.file(path + '/etc/nexus.properties')
    assert f.exists
    assert f.contains('application-port-ssl=8443')
    assert f.contains('${jetty.etc}/jetty-https.xml')


def test_enable_and_start_nexus_as_service(host):
    s = host.service('nexus')
    assert s.is_running
    assert s.is_enabled
