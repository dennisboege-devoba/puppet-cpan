require 'spec_helper'

describe 'cpan::config' do
  on_supported_os.each do |os, os_facts|
    context "On #{os}" do
      let(:facts) { os_facts }

      let(:config_file) do
        case os_facts[:os]['family']
        when 'Debian' then '/etc/perl/CPAN/Config.pm'
        when 'RedHat' then '/usr/share/perl5/vendor_perl/CPAN/Config.pm'
        end
      end

      context 'With default ::cpan parameters' do
        let(:pre_condition) { 'include cpan' }

        it { is_expected.to contain_file(config_file).with_owner('root').with_group('root').with_mode('0644') }
        it { is_expected.to contain_file(config_file).with_content(%r{^  'http_proxy' => q\[\],$}) }
        it { is_expected.to contain_file(config_file).with_content(%r{^  'ftp_proxy' => q\[\],$}) }

        it { is_expected.to contain_file(config_file).with_content(%r{^  'urllist' => \[\n\n  \],$}) }

        it { is_expected.to contain_file('/etc/perl/CPAN').with_ensure('directory') } if os_facts[:os]['family'] == 'Debian'
      end

      context 'with proxies set' do
        let(:pre_condition) do
          'class { "cpan":
             ftp_proxy  => "http://your_ftp_proxy.com",
             http_proxy => "http://your_http_proxy.com",
           }'
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^  'ftp_proxy' => q\[http://your_ftp_proxy\.com\],$}) }
        it { is_expected.to contain_file(config_file).with_content(%r{^  'http_proxy' => q\[http://your_http_proxy\.com\],$}) }
      end

      context 'with a custom string in config_hash' do
        let(:pre_condition) { 'class { "cpan": config_hash => { "foo" => "bar" } }' }

        it { is_expected.to contain_file(config_file).with_content(%r{^  'foo' => q\[bar\],$}) }
      end

      context 'with a custom array in config_hash' do
        let(:pre_condition) { 'class { "cpan": config_hash => { "foo" => ["baz", "bar"] } }' }

        it { is_expected.to contain_file(config_file).with_content(%r{^  'foo' => \[\n    q\[baz\],\n    q\[bar\]\n \],$}) }
      end

      context 'with two urls in urllist' do
        let(:pre_condition) do
          'class { "cpan":
            urllist => ["http://httpupdate3.cpanel.net/CPAN/", "ftp://cpan.cse.msu.edu/"],
          }'
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^  'urllist' => \[\n    q\[http://httpupdate3\.cpanel\.net/CPAN/\],\n    q\[ftp://cpan\.cse\.msu\.edu/\]\n  \],$}) }
      end
    end
  end
end
