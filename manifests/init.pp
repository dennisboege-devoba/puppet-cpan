# == Class: cpan
#
# Installs cpan
#
# === Parameters
#
# [*manage_config*]
#
# [*manage_package*]
#
# [*installdirs*]
#
# [*local_lib*]
#
# [*config_template*]
#
# [*config_hash*]
#
# [*package_ensure*]
#
# [*ftp_proxy*]
#
# [*http_proxy*]
#
# === Examples
#
# class {'::cpan':
#   manage_config  => true,
#   manage_package => true,
#   package_ensure => 'present',
#   installdirs    => 'site',
#   local_lib      => false,
#   config_hash    => { 'build_requires_install_policy' => 'no' },
#   ftp_proxy      => 'http://your_ftp_proxy.com',
#   http_proxy     => 'http://your_http_proxy.com',
# }
#
class cpan (
  $manage_package,
  $config_hash,
  $package_name,
  Optional[Array[String[1]]] $config_file = undef,
  Optional[Array[String[1]]] $config_dir = undef,
  $package_ensure    = 'present',
  $manage_config     = true,
  $installdirs       = 'site',
  $local_lib         = false,
  $config_template   = 'cpan/cpan.conf.erb',
  $ftp_proxy         = undef,
  $http_proxy        = undef,
  $urllist           = [],
) {
  assert_type(Boolean, $manage_config)
  assert_type(Boolean, $manage_package)
  assert_type(String, $installdirs)
  assert_type(Boolean, $local_lib)
  assert_type(String, $config_template)
  assert_type(String, $package_ensure)
  if $ftp_proxy {
    assert_type(String, $ftp_proxy)
  }
  if $http_proxy {
    assert_type(String, $http_proxy)
  }
  assert_type(Array, $urllist)

  anchor { 'cpan::begin': }
  -> class { 'cpan::install': }
  -> class { 'cpan::config': }
  -> anchor { 'cpan::end': }
}
