# audioskim

Sinatra application to take file uploads and transcribe them via speech2text gem.

## installation

```bash
# installing passenger:
sudo gem install unicorn sinatra #dont know if we need this

sudo apt-get install libcurl4-openssl-dev
sudo gem install passenger

passenger start # installs a bunch of stuff the first time, takes a while
passenger start -p 9093 # apparently passenger ignores sinatra config
mkdir -p public/files # for uploads

# http://stackoverflow.com/questions/1247125/how-to-get-sinatra-to-auto-reload-the-file-after-each-change#8187001
mkdir -p tmp/ && touch tmp/always_restart.txt 

# install gems, run the migrations
cd /vagrant/basic-sinatra
bundle install
sequel -m db/migrations sqlite://db/audioskim.db

# debug running speech2text gem as standalone
speech2text public/files/message.flac

```


## Dev notes 

* vagrant-snap is broken: https://github.com/mitchellh/vagrant/issues/143
** workaround: https://gist.github.com/tombh/5142237#vagrant-snapshot.rb
* forward_port confusion, resolved by `set :bind, '0.0.0.0'`
* use resource() to modify chef resources
* overriding attributes of other cookbooks
    - http://docs.opscode.com/essentials_cookbook_attribute_files.html
    - use include_attribute("cookbook::recipe") to pull in other cookbooks attributes (to read!)
    - use `node.set['cookbook']['attribute'] = ...` instead of `default['cookbook']['attribute'] = ...`
    - I'm not sure if `node.set` still allows overriding in Vagrantfile; ideally it would

### speech2text

* https://github.com/taf2/speech2text
* hacked audio_splitter.rb to change chunk_size from 5s to 15s; google errors at 35s
* http://fennb.com/fast-free-speech-recognition-using-googles-in
* setting max=5 increases number of "hypotheses" to 5
* we decided that it was unlikely we could do a JS only solution to transcribing audio; except maybe as embedded FORM post
  - http://bl.ocks.org/dergachev/4540158
* found an asterisk google-speech-api module: https://github.com/zaf/asterisk-speech-recog
* http://src.chromium.org/viewvc/chrome/trunk/src/content/browser/speech/ chrome source code
* undefined method `first' for nil:NilClass audio_inspector.rb:55
  - this means no ffmpeg is installed


### sinatra

* validation of fields: see http://stackoverflow.com/questions/3949026/datamapper-validation-errors-with-sinatra?rq=1
* tutorials for sinatra file uploads: https://github.com/tbuehlmann/sinatra-fileupload/blob/master/file_upload.rb
* sinatra-bootstrap-starter: https://github.com/pokle/sinatra-bootstrap/blob/master/app.rb
* https://github.com/SFEley/sinatra-flash

### mailgun

* http://blog.mailgun.net/post/12482374892/handle-incoming-emails-like-a-pro-mailgun-api-2-0
* https://mailgun.net/cp/log?domain=audioskim.mailgun.org
* https://mailgun.net/cp/routes?domain=audioskim.mailgun.org
* `bash script/scripts/test-send-email.sh`

To test mailbug via localtunnel:

```bash
# on host, copy over my public key and ensure ssh-agent is running
cp ~/.ssh/id_rsa.pub ~/tmp/goog-voice-api/vagrant_sinatra/ # on host, copy pub key
eval `ssh-agent` && ssh-add

sudo gem install localtunnel
localtunnel -k /vagrant/id_rsa.pub 9093
```

### TODO

* transcribe in background using resqueue
  - http://railscasts.com/episodes/271-resque?view=asciicast
  - https://github.com/kylefritz/resque-sinatra-foreman-example
  - https://github.com/jeffkreeftmeijer/navvy/wiki/getting-started
* FLAC files aren't working for some reason!! 
    - `ffmpeg -i FILENAME.flac FILENAME.flac.mp3`

### rvm, nginx, passenger and sudo... fun!

* from https://rvm.io/rvm/basics/
    - For non-interactive shells RVM will be added to PATH only, not loaded. This means using rubies is not possible in this mode, but there are simple methods to load ruby:
        - source $(rvm 1.9.3 do rvm env --path)
        - source /usr/local/rvm/environments/ruby-1.8.7-p330
    - https://groups.google.com/forum/#!msg/vagrant-up/3UGRFiAuVPQ/5WOkhfmoNYYJ
    - https://gist.github.com/thbar/803820#vagrant-tweaks-rvm.rb
    - http://stackoverflow.com/questions/12550603/how-do-i-run-a-chef-command-using-rvmsudo-installing-passenger-with-rvm
    - http://craiccomputing.blogspot.ca/2010/10/passenger-3-nginx-and-rvm-on-mac-os-x.html
    - http://blog.ninjahideout.com/posts/the-path-to-better-rvm-and-passenger-integrationG
* https://gist.github.com/mrsweaters/1742642#vagrant-box-setup-ruby-1.9.3/nginx/passenger/mysql
* http://stackoverflow.com/questions/15297564/how-to-debug-rvm-setup-from-chef-and-vagrant
* https://github.com/fnichol/chef-rvm_passenger
* https://gist.github.com/mrsweaters/1742642
* http://blog.phusion.nl/2010/09/21/phusion-passenger-running-multiple-ruby-versions/
* http://docs.opscode.com/resource_common_notifications.html
* http://tickets.opscode.com/browse/CHEF-2308#comment-23011 (about editing other resources)
* https://gist.github.com/fujin/1713157#template-override-between-cookbooks
* https://github.com/fnichol/chef-rvm
* http://stackoverflow.com/questions/15708916/use-rvmrc-or-ruby-version-file-to-set-a-project-gemset-with-rvm
* http://gembundler.com/v1.3/man/bundle-install.1.html
* http://stackoverflow.com/questions/4036255/how-to-automatically-run-bundle-install-if-the-gemfile-is-updated-after-a-git-pu
* https://github.com/opscode-cookbooks/application_ruby

## vagrant-snap in between recipes

* use "next" keyword to exit Vagrantfile config block early
* use "return" keyword to exit a recipe file early (without chef failure)
* use "runlist_modifiers" cookbook to easily remove recipes from runlist
    - https://github.com/hw-cookbooks/runlist_modifiers
    - http://code.chrisroberts.org/blog/2012/05/09/cooking-up-partial-run-lists-with-chef/
* use "raise" to exit early (with chef failure)
    - do this from a ruby_block resource to raise error at resource execution time 
      (instead of compile time)
    - ```
      ruby_block "stop now" do
        code do
          raise "This is really okay, man"
        end
        action :nothing
        end
      end
      ```
    - http://lists.opscode.com/sympa/arc/chef/2012-04/msg00292.html
* use multiple Vagrantfile chef_solo blocks to segment recipes 
    - both blocks will have the same chef.cookbook_folders
    - uniquely set "chef.provisioning_path" in each block to avoid conflict
* consider writing a "vm.config.provisioner :snapshot"
    - https://github.com/mitchellh/vagrant/blob/master/plugins/provisioners/shell/provisioner.rb
    - method to specify via Vagrantfile where to take snapshots, relative to other provisioners
    - only works if other provisioners exit with success (eg incompatible with raise)
