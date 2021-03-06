require "fpm/namespace"

# Some utility functions
module FPM::Util
  # Raised if safesystem cannot find the program to run.
  class ExecutableNotFound < StandardError; end

  # Raised if a safesystem program exits nonzero
  class ProcessFailed < StandardError; end

  # Is the given program in the system's PATH?
  def program_in_path?(program)
    # Scan path to find the executable
    # Do this to help the user get a better error message.
    envpath = ENV["PATH"].split(":")
    return envpath.select { |p| File.executable?(File.join(p, program)) }.any?
  end # def program_in_path

  # Run a command safely in a way that gets reports useful errors.
  def safesystem(*args)
    program = args[0]

    # Scan path to find the executable
    # Do this to help the user get a better error message.
    if !program.include?("/") and !program_in_path?(program)
      raise ExecutableNotFound.new(program)
    end

    @logger.debug("Running command", :args => args)
    success = system(*args)
    if !success
      raise ProcessFailed.new("#{program} failed (exit code #{$?.exitstatus})" \
                              ". Full command was:#{args.inspect}")
    end
    return success
  end # def safesystem

  # Get the recommended 'tar' command for this platform.
  def tar_cmd
    # Rely on gnu tar for solaris and OSX.
    case %x{uname -s}.chomp
    when "SunOS"
      return "gtar"
    when "Darwin"
      return "gnutar"
    else
      return "tar"
    end
  end # def tar_cmd

  # Run a block with a value.
  # Useful in lieu of assigning variables 
  def with(value, &block)
    block.call(value)
  end # def with
end # module FPM::Util
