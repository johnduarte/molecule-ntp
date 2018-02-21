import os
import re

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_ntp_package(host):
    assert host.package("ntp").is_installed


def test_ntp_file(host):
    f = host.file("/etc/ntp.conf")
    assert f.exists
    assert f.is_file


def test_ntp_file_content(host):
    f = host.file("/etc/ntp.conf")
    assert f.contains("0.us.pool.ntp.org")


def test_ntp_service(host):
    if host.system_info.distribution == "debian":
        ntp_daemon = "ntp"
    elif host.system_info.distribution == "centos":
        ntp_daemon = "ntpd"

    s = host.service(ntp_daemon)
    assert s.is_running
    assert s.is_enabled


def test_cinder_service(host):
    cmd = "sudo bash -c \"source /root/openrc; cinder service-list\""
    output = host.run(cmd)
    assert ("cinder-volume" in output.stdout)


def test_cinder_lvm_volume(host):
    cmd = "sudo bash -c \"source /root/openrc; " \
          "pushd /opt/openstack-ansible; " \
          "ansible storage_hosts -m shell -a 'vgs cinder-volumes'\""
    output = host.run(cmd)
    assert re.search("cinder-volumes\s+[0-9]*\s+[0-9]*\s+", output.stdout)


def test_cinder_volume_group(host):
    cmd = "sudo bash -c \"source /root/openrc; " \
          "pushd /opt/openstack-ansible; " \
          "ansible cinder_volume -m shell -a " \
          "'grep volume_group /etc/cinder/cinder.conf'\""
    output = host.run(cmd)
    assert ("SUCCESS" in output.stdout)
    assert ("volume_group=cinder-volumes" in output.stdout)
