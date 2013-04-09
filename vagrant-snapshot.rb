# Place this file in the same directory as `Vagrantfile'
# then simply require "vagrant-snapshot.rb" at the top of Vagrantfile.

require 'optparse'

Vagrant.commands.register(:snap) { Snap::Commands }

# Provide rake-like desc() 'inflected' documentation
# See http://stackoverflow.com/questions/2948328/access-attributes-methods-comments-programmatically-in-ruby
class Module
  private

  old_method_added = instance_method :method_added
  define_method :method_added do |meth|
    (@__doc__ ||= {})[meth] = @__last_doc__ if @__last_doc__
    @__last_doc__ = nil
    old_method_added.bind(self).(meth)
  end

  def doc(usage, description)
    @__last_doc__ = [usage, description]
  end

end

module Kernel
  private

  def get_doc(klass, meth)
    klass.instance_variable_get(:@__doc__)[meth]
  end
end

# Snap commands
module Snap
  class Commands < ::Vagrant::Command::Base

    def initialize(argv,env)
      super
      @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)
    end

    def execute
      if @main_args.include?("-h") || @main_args.include?("--help")
        # Print the help for all the box commands.
        return help
      end

      # If we reached this far then we must have a subcommand. If not,
      # then we also just print the help and exit.
      command = sub_commands[@sub_command.to_sym] if @sub_command
      return help if !command || !@sub_command

      # If the command has wrong args.
      # Word count is used to determine if args required.
      if command[0].split.size - 1 != @sub_args.size
        return help command[0], command[1]
      end

      # Finally run the command
      @logger.debug("Invoking command : #{command} #{@sub_args.inspect}")
      self.send(@sub_command, *@sub_args)
    end

    def vmname
      @vagrant_env ||= Vagrant::Environment.new
      @instance_name ||= "#{@vagrant_env.vms[:default].uuid}"
      @instance_name
    end

    def sub_commands
      subs = {}
      methods.each do |m|
        doc_data = get_doc(Snap::Commands, m.to_sym)
        if doc_data
          subs[m] = doc_data
        end
      end
      subs
    end

    doc "help", "Show this help"
    def help command = nil, description = nil
      options = OptionParser.new do |opts|
        if command && description
          opts.banner = description
          opts.separator ""
          opts.separator "Usage: vagrant snap #{command}"
        else
          opts.banner = "Usage: vagrant snap <command> [<args>]"
          opts.separator ""
          opts.separator "Available subcommands:"

          # Add the available subcommands as separators in order to print them
          # out as well.
          sub_commands.each do |sub_command, doc_data|
            opts.separator "     #{doc_data[0].ljust(18)} #{doc_data[1]}"
          end
        end
      end

      @env.ui.info(options.help, :prefix => false)
    end

    doc "list", "List snapshots"
    def list
      system "VBoxManage snapshot #{vmname} list --details"
    end

    doc "go [SNAPNAME]", "Go to specified snapshot"
    def go(snapshot_name)
      system "VBoxManage controlvm #{vmname} poweroff"
      system "VBoxManage snapshot  #{vmname} restore #{snapshot_name}"
      system "VBoxManage startvm   #{vmname} --type headless"
    end

    doc "back", "Back to current snapshot"
    def back
      system "VBoxManage controlvm #{vmname} poweroff"
      system "VBoxManage snapshot  #{vmname} restorecurrent"
      system "VBoxManage startvm   #{vmname} --type headless"
    end

    doc "take [SNAPNAME]", "Take snapshot"
    def take(snapshot_name)
      system "VBoxManage snapshot #{vmname} take #{snapshot_name} --pause"
    end

    doc "delete [SNAPNAME]", "Delete snapshot"
    def delete(snapshot_name)
      system "VBoxManage snapshot #{vmname} delete #{snapshot_name}"
    end
  end

end
