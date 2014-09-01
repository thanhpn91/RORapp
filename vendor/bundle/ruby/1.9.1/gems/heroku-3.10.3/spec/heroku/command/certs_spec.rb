require "spec_helper"
require "heroku/command/certs"

module Heroku::Command
  describe Certs do
    let(:certificate_details) {
      <<-CERTIFICATE_DETAILS.chomp
Common Name(s): example.org
Expires At:     2013-08-01 21:34 UTC
Issuer:         /C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org
Starts At:      2012-08-01 21:34 UTC
Subject:        /C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org
SSL certificate is self signed.
      CERTIFICATE_DETAILS
    }

    let(:endpoint) {
      { 'cname'          => 'tokyo-1050.herokussl.com',
        'ssl_cert' => {
          'ca_signed?'   => false,
          'cert_domains' => [ 'example.org' ],
          'starts_at'    => "2012-08-01 21:34:23 UTC",
          'expires_at'   => "2013-08-01 21:34:23 UTC",
          'issuer'       => '/C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org',
          'subject'      => '/C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org',
        }
      }
    }
    let(:endpoint2) {
      { 'cname'          => 'akita-7777.herokussl.com',
        'ssl_cert' => {
          'ca_signed?'   => true,
          'cert_domains' => [ 'heroku.com' ],
          'starts_at'    => "2012-08-01 21:34:23 UTC",
          'expires_at'   => "2013-08-01 21:34:23 UTC",
          'issuer'       => '/C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org',
          'subject'      => '/C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org',
        }
      }
    }

    describe "certs" do
      it "shows a list of certs" do
        stub_core.ssl_endpoint_list("example").returns([endpoint, endpoint2])
        stderr, stdout = execute("certs")
        expect(stdout).to eq <<-STDOUT
Endpoint                  Common Name(s)  Expires               Trusted
------------------------  --------------  --------------------  -------
tokyo-1050.herokussl.com  example.org     2013-08-01 21:34 UTC  False
akita-7777.herokussl.com  heroku.com      2013-08-01 21:34 UTC  True
STDOUT
      end

      it "warns about no SSL Endpoints if the app has no certs" do
        stub_core.ssl_endpoint_list("example").returns([])
        stderr, stdout = execute("certs")
        expect(stdout).to eq <<-STDOUT
example has no SSL Endpoints.
Use `heroku certs:add CRT KEY` to add one.
        STDOUT
      end
    end

    describe "certs:add" do
      it "adds an endpoint" do
        expect(File).to receive(:read).with("pem_file").and_return("pem content")
        expect(File).to receive(:read).with("key_file").and_return("key content")
        stub_core.ssl_endpoint_add('example', 'pem content', 'key content').returns(endpoint)

        stderr, stdout = execute("certs:add --bypass pem_file key_file")
        expect(stdout).to eq <<-STDOUT
Adding SSL Endpoint to example... done
example now served by tokyo-1050.herokussl.com
Certificate details:
#{certificate_details}
        STDOUT
      end

      it "shows usage if two arguments are not provided" do
        expect { execute("certs:add --bypass") }.to raise_error(CommandFailed, /Usage:/)
      end
    end

    describe "certs:info" do
      it "shows certificate details" do
        stub_core.ssl_endpoint_list("example").returns([endpoint])
        stub_core.ssl_endpoint_info('example', 'tokyo-1050.herokussl.com').returns(endpoint)

        stderr, stdout = execute("certs:info")
        expect(stdout).to eq <<-STDOUT
Fetching SSL Endpoint tokyo-1050.herokussl.com info for example... done
Certificate details:
#{certificate_details}
        STDOUT
      end

      it "allows an endpoint to be specified" do
        stub_core.ssl_endpoint_info('example', 'tokyo-1050').returns(endpoint)

        stderr, stdout = execute("certs:info --endpoint tokyo-1050")
        expect(stdout).to eq <<-STDOUT
Fetching SSL Endpoint tokyo-1050 info for example... done
Certificate details:
#{certificate_details}
        STDOUT
      end

      it "shows an error if an app has no endpoints" do
        stub_core.ssl_endpoint_list("example").returns([])

        stderr, stdout = execute("certs:info")
        expect(stderr).to eq <<-STDERR
 !    example has no SSL Endpoints.
        STDERR
      end
    end

    describe "certs:remove" do
      it "removes an endpoint" do
        stub_core.ssl_endpoint_list("example").returns([endpoint])
        stub_core.ssl_endpoint_remove('example', 'tokyo-1050.herokussl.com').returns(endpoint)

        stderr, stdout = execute("certs:remove --confirm example")
        expect(stdout).to include "Removing SSL Endpoint tokyo-1050.herokussl.com from example..."
        expect(stdout).to include "NOTE: Billing is still active. Remove SSL Endpoint add-on to stop billing."
      end

      it "allows an endpoint to be specified" do
        stub_core.ssl_endpoint_remove('example', 'tokyo-1050').returns(endpoint)

        stderr, stdout = execute("certs:remove --confirm example --endpoint tokyo-1050")
        expect(stdout).to include "Removing SSL Endpoint tokyo-1050 from example..."
        expect(stdout).to include "NOTE: Billing is still active. Remove SSL Endpoint add-on to stop billing."
      end

      it "requires confirmation" do
        stub_core.ssl_endpoint_list("example").returns([endpoint])

        stderr, stdout = execute("certs:remove")
        expect(stdout).to include "WARNING: Potentially Destructive Action"
        expect(stdout).to include "This command will remove the endpoint tokyo-1050.herokussl.com from example."
      end

      it "shows an error if an app has no endpoints" do
        stub_core.ssl_endpoint_list("example").returns([])

        stderr, stdout = execute("certs:remove")
        expect(stderr).to eq <<-STDERR
 !    example has no SSL Endpoints.
        STDERR
      end
    end

    describe "certs:update" do
      before do
        expect(File).to receive(:read).with("pem_file").and_return("pem content")
        expect(File).to receive(:read).with("key_file").and_return("key content")
      end

      it "updates an endpoint" do
        stub_core.ssl_endpoint_list("example").returns([endpoint])
        stub_core.ssl_endpoint_update('example', 'tokyo-1050.herokussl.com', 'pem content', 'key content').returns(endpoint)

        stderr, stdout = execute("certs:update --confirm example --bypass pem_file key_file")
        expect(stdout).to eq <<-STDOUT
Updating SSL Endpoint tokyo-1050.herokussl.com for example... done
Updated certificate details:
#{certificate_details}
        STDOUT
      end

      it "allows an endpoint to be specified" do
        stub_core.ssl_endpoint_update('example', 'tokyo-1050', 'pem content', 'key content').returns(endpoint)

        stderr, stdout = execute("certs:update --confirm example --bypass --endpoint tokyo-1050 pem_file key_file")
        expect(stdout).to eq <<-STDOUT
Updating SSL Endpoint tokyo-1050 for example... done
Updated certificate details:
#{certificate_details}
        STDOUT
      end

      it "requires confirmation" do
        stub_core.ssl_endpoint_list("example").returns([endpoint])

        stderr, stdout = execute("certs:update --bypass pem_file key_file")
        expect(stdout).to include "WARNING: Potentially Destructive Action"
        expect(stdout).to include "This command will change the certificate of endpoint tokyo-1050.herokussl.com on example."
      end

      it "shows an error if an app has no endpoints" do
        stub_core.ssl_endpoint_list("example").returns([])

        stderr, stdout = execute("certs:update --bypass pem_file key_file")
        expect(stderr).to eq <<-STDERR
 !    example has no SSL Endpoints.
        STDERR
      end
    end

    describe "certs:rollback" do
      it "performs a rollback on an endpoint" do
        stub_core.ssl_endpoint_list("example").returns([endpoint])
        stub_core.ssl_endpoint_rollback('example', 'tokyo-1050.herokussl.com').returns(endpoint)

        stderr, stdout = execute("certs:rollback --confirm example")
        expect(stdout).to eq <<-STDOUT
Rolling back SSL Endpoint tokyo-1050.herokussl.com for example... done
New active certificate details:
#{certificate_details}
        STDOUT
      end

      it "allows an endpoint to be specified" do
        stub_core.ssl_endpoint_rollback('example', 'tokyo-1050').returns(endpoint)

        stderr, stdout = execute("certs:rollback --confirm example --endpoint tokyo-1050")
        expect(stdout).to eq <<-STDOUT
Rolling back SSL Endpoint tokyo-1050 for example... done
New active certificate details:
#{certificate_details}
        STDOUT
      end

      it "requires confirmation" do
        stub_core.ssl_endpoint_list("example").returns([endpoint])

        stderr, stdout = execute("certs:rollback")
        expect(stdout).to include "WARNING: Potentially Destructive Action"
        expect(stdout).to include "This command will rollback the certificate of endpoint tokyo-1050.herokussl.com on example."
      end

      it "shows an error if an app has no endpoints" do
        stub_core.ssl_endpoint_list("example").returns([])

        stderr, stdout = execute("certs:rollback")
        expect(stderr).to eq <<-STDERR
 !    example has no SSL Endpoints.
        STDERR
      end
    end
  end
end
