# This library hides the internal details of running a process-based command in Rails.
#
# Due to Ruby's GIL, it's not possible to run some commands (e.g. acceptance tests)
# using threads. So, we run the command in a different processor instead. However,
# communicating between multiple processors requires low level communication tools.
#
# The API is targeted towards polling-based web-server actions.

require 'tempfile'

class Tasky
  class CommandError < StandardError
    def initialize(msg="The command is invalid or the program missing.")
      super(msg)
    end
  end

  class Task
    def initialize(cmd)
      @output_log = Tempfile.new('tasky_output')

      begin
        @pid = Process.spawn cmd, [:out, :err] => @output_log
      rescue StandardError => e
          raise CommandError, e.inspect
      end
    end

    def success?
      @successful
    end

    def error_log
      @error_log
    end

    # Returns true if task has finished executing, false otherwise.
    def finished?
      # use cached results
      return true unless @successful.nil?
      _pid, status = Process.waitpid2 @pid, Process::WNOHANG

      if status.nil?
        false
      else # this will only be executed once
        @output_log.rewind # read from the beginning of file
        @error_log = @output_log.read
        @output_log.close! # delete it

        @successful = status.success?
        true
      end
    end
  end

  @@tasks = {}

  # Returns task id to fetch the command at a later time.
  def self.run(cmd)
    task = Task.new cmd
    @@tasks[task.object_id] = task
    return task.object_id
  end

  # Returns a Task object that provides methods to check the status of the task.
  def self.fetch_task(task_id)
    return @@tasks[task_id.to_i]
  end
end
