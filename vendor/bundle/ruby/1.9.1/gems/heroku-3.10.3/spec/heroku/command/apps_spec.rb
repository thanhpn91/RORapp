require "spec_helper"
require "heroku/command/apps"

module Heroku::Command
  describe Apps do

    before(:each) do
      stub_core
      stub_organizations
    end

    context("info") do

      before(:each) do
        api.post_app("name" => "example", "stack" => "cedar")
      end

      after(:each) do
        api.delete_app("example")
      end

      it "displays impicit app info" do
        stderr, stdout = execute("apps:info")
        expect(stderr).to eq("")
        expect(stdout).to eq <<-STDOUT
=== example
Git URL:       git@heroku.com:example.git
Owner Email:   email@example.com
Stack:         cedar
Web URL:       http://example.herokuapp.com/
STDOUT
      end

      it "gets explicit app from --app" do
        stderr, stdout = execute("apps:info --app example")
        expect(stderr).to eq("")
        expect(stdout).to eq <<-STDOUT
=== example
Git URL:       git@heroku.com:example.git
Owner Email:   email@example.com
Stack:         cedar
Web URL:       http://example.herokuapp.com/
STDOUT
      end

      it "shows shell app info when --shell option is used" do
        stderr, stdout = execute("apps:info --shell")
        expect(stderr).to eq("")
        expect(stdout).to match Regexp.new(<<-STDOUT)
create_status=complete
created_at=\\d{4}/\\d{2}/\\d{2} \\d{2}:\\d{2}:\\d{2} [+-]\\d{4}
dynos=0
git_url=git@heroku.com:example.git
id=\\d{1,5}
name=example
owner_email=email@example.com
repo_migrate_status=complete
repo_size=
requested_stack=
slug_size=
stack=cedar
web_url=http://example.herokuapp.com/
workers=0
STDOUT
      end

    end

    context("create") do

      it "without a name" do
        name = nil
        with_blank_git_repository do
          stderr, stdout = execute("apps:create")
          name = api.get_apps.body.first["name"]
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating #{name}... done, stack is bamboo-mri-1.9.2
http://#{name}.herokuapp.com/ | git@heroku.com:#{name}.git
Git remote heroku added
STDOUT
        end
        api.delete_app(name)
      end

      it "with a name" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create example")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating example... done, stack is bamboo-mri-1.9.2
http://example.herokuapp.com/ | git@heroku.com:example.git
Git remote heroku added
STDOUT
        end
        api.delete_app("example")
      end

      it "with -a name" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create -a example")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating example... done, stack is bamboo-mri-1.9.2
http://example.herokuapp.com/ | git@heroku.com:example.git
Git remote heroku added
STDOUT
        end
        api.delete_app("example")
      end

      it "with --no-remote" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create example --no-remote")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating example... done, stack is bamboo-mri-1.9.2
http://example.herokuapp.com/ | git@heroku.com:example.git
STDOUT
        end
        api.delete_app("example")
      end

      it "with addons" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create addonapp --addon custom_domains:basic,releases:basic")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating addonapp... done, stack is bamboo-mri-1.9.2
Adding custom_domains:basic to addonapp... done
Adding releases:basic to addonapp... done
http://addonapp.herokuapp.com/ | git@heroku.com:addonapp.git
Git remote heroku added
STDOUT
        end
        api.delete_app("addonapp")
      end

      it "with a buildpack" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create buildpackapp --buildpack http://example.org/buildpack.git")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating buildpackapp... done, stack is bamboo-mri-1.9.2
BUILDPACK_URL=http://example.org/buildpack.git
http://buildpackapp.herokuapp.com/ | git@heroku.com:buildpackapp.git
Git remote heroku added
STDOUT
        end
        api.delete_app("buildpackapp")
      end

      it "with an alternate remote name" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create alternate-remote --remote alternate")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating alternate-remote... done, stack is bamboo-mri-1.9.2
http://alternate-remote.herokuapp.com/ | git@heroku.com:alternate-remote.git
Git remote alternate added
STDOUT
        end
        api.delete_app("alternate-remote")
      end

    end

    context("index") do

      before(:each) do
        api.post_app("name" => "example", "stack" => "cedar")
      end

      after(:each) do
        api.delete_app("example")
      end

      it "succeeds" do
        stub_core.list.returns([["example", "user"]])
        stderr, stdout = execute("apps")
        expect(stderr).to eq("")
        expect(stdout).to eq <<-STDOUT
=== My Apps
example

STDOUT
      end

    end

    context("index with orgs") do
      context("when you are a member of the org") do
        before(:each) do
          Excon.stub({ :method => :get, :path => '/v1/user/info' }, { :status => 200, :body => Heroku::OkJson.encode({
            "user" => {"default_organization" => "test-org"}
          })})
        end

        after(:each) do
          Excon.stub({ :method => :get, :path => '/v1/user/info' }, { :status => 404 })
        end

        it "displays a message when the org has no apps" do
          Excon.stub({ :method => :get, :path => '/v1/organization/test-org/app' }, { :status => 200, :body => Heroku::OkJson.encode([]) })
          stderr, stdout = execute("apps")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
There are no apps in organization test-org.
STDOUT

        end

        context("and the org has apps") do
          before(:each) do
            Excon.stub({ :method => :get, :path => '/v1/organization/test-org/app' },
              {
                :body   => Heroku::OkJson.encode([
                  {"name" => "org-app-1", "joined" => true},
                  {"name" => "org-app-2"}
                ]),
                :status => 200
              }
            )
          end

          it "lists joined apps in an organization" do
            stderr, stdout = execute("apps")
            expect(stderr).to eq("")
            expect(stdout).to eq <<-STDOUT
=== Apps joined in organization test-org
org-app-1

STDOUT
          end

          it "list all apps in an organization with the --all flag" do
            stderr, stdout = execute("apps --all")
            expect(stderr).to eq("")
            expect(stdout).to eq <<-STDOUT
=== Apps joined in organization test-org
org-app-1

=== Apps available to join in organization test-org
org-app-2

STDOUT
          end
        end
      end
    end

    context("rename") do

      context("success") do

        before(:each) do
          api.post_app("name" => "example", "stack" => "cedar")
        end

        after(:each) do
          api.delete_app("example2")
        end

        it "renames app" do
          with_blank_git_repository do
            stderr, stdout = execute("apps:rename example2")
            expect(stderr).to eq("")
            expect(stdout).to eq <<-STDOUT
Renaming example to example2... done
http://example2.herokuapp.com/ | git@heroku.com:example2.git
Don't forget to update your Git remotes on any local checkouts.
STDOUT
          end
        end

      end

      it "displays an error if no name is specified" do
        stderr, stdout = execute("apps:rename")
        expect(stderr).to eq <<-STDERR
 !    Usage: heroku apps:rename NEWNAME
 !    Must specify NEWNAME to rename.
STDERR
        expect(stdout).to eq("")
      end

    end

    context("destroy") do

      before(:each) do
        api.post_app("name" => "example", "stack" => "cedar")
      end

      it "succeeds with app explicitly specified with --app and user confirmation" do
        stderr, stdout = execute("apps:destroy --confirm example")
        expect(stderr).to eq("")
        expect(stdout).to eq <<-STDOUT
Destroying example (including all add-ons)... done
STDOUT
      end

      context("fails") do

        after(:each) do
          api.delete_app("example")
        end

        it "fails with explicit app but no confirmation" do
          stderr, stdout = execute("apps:destroy example")
          expect(stderr).to eq <<-STDERR
 !    Confirmation did not match example. Aborted.
STDERR
          expect(stdout).to eq("
 !    WARNING: Potentially Destructive Action
 !    This command will destroy example (including all add-ons).
 !    To proceed, type \"example\" or re-run this command with --confirm example

> ")

        end

        it "fails without explicit app" do
          stderr, stdout = execute("apps:destroy")
          expect(stderr).to eq <<-STDERR
 !    Usage: heroku apps:destroy --app APP
 !    Must specify APP to destroy.
STDERR
          expect(stdout).to eq("")
        end

      end

    end

    context "Git Integration" do

      it "creates adding heroku to git remote" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create example")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating example... done, stack is bamboo-mri-1.9.2
http://example.herokuapp.com/ | git@heroku.com:example.git
Git remote heroku added
STDOUT
          expect(`git remote`.strip).to match(/^heroku$/)
          api.delete_app("example")
        end
      end

      it "creates adding a custom git remote" do
        with_blank_git_repository do
          stderr, stdout = execute("apps:create example --remote myremote")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating example... done, stack is bamboo-mri-1.9.2
http://example.herokuapp.com/ | git@heroku.com:example.git
Git remote myremote added
STDOUT
          expect(`git remote`.strip).to match(/^myremote$/)
          api.delete_app("example")
        end
      end

      it "doesn't add a git remote if it already exists" do
        with_blank_git_repository do
          `git remote add heroku /tmp/git_spec_#{Process.pid}`
          stderr, stdout = execute("apps:create example")
          expect(stderr).to eq("")
          expect(stdout).to eq <<-STDOUT
Creating example... done, stack is bamboo-mri-1.9.2
http://example.herokuapp.com/ | git@heroku.com:example.git
STDOUT
          api.delete_app("example")
        end
      end

      it "renames updating the corresponding heroku git remote" do
        with_blank_git_repository do
          `git remote add github     git@github.com:test/test.git`
          `git remote add production git@heroku.com:example.git`
          `git remote add staging    git@heroku.com:example-staging.git`

          api.post_app("name" => "example", "stack" => "cedar")
          stderr, stdout = execute("apps:rename example2")
          api.delete_app("example2")

          remotes = `git remote -v`
          expect(remotes).to eq <<-REMOTES
github\tgit@github.com:test/test.git (fetch)
github\tgit@github.com:test/test.git (push)
production\tgit@heroku.com:example2.git (fetch)
production\tgit@heroku.com:example2.git (push)
staging\tgit@heroku.com:example-staging.git (fetch)
staging\tgit@heroku.com:example-staging.git (push)
REMOTES
        end
      end

      it "destroys removing any remotes pointing to the app" do
        with_blank_git_repository do
          `git remote add heroku git@heroku.com:example.git`

          api.post_app("name" => "example", "stack" => "cedar")
          stderr, stdout = execute("apps:destroy --confirm example")

          expect(`git remote`.strip).not_to include('heroku')
        end
      end
    end
  end
end
