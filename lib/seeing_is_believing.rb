require 'tmpdir'

require 'seeing_is_believing/result'
require 'seeing_is_believing/version'
require 'seeing_is_believing/debugger'
require 'seeing_is_believing/rewrite_code'
require 'seeing_is_believing/hash_struct'
require 'seeing_is_believing/evaluate_by_moving_files'
require 'seeing_is_believing/event_stream/debugging_handler'
require 'seeing_is_believing/event_stream/update_result_handler'

class SeeingIsBelieving
  class Options < HashStruct
    attribute(:filename)          { nil }
    attribute(:encoding)          { nil }
    attribute(:stdin)             { "" }
    attribute(:require)           { ['seeing_is_believing/the_matrix'] } # TODO: should rename to requires ?
    attribute(:load_path)         { [File.expand_path('..', __FILE__)] } # TODO: should rename to load_path_dirs ?
    attribute(:timeout_seconds)   { 0 }
    attribute(:debugger)          { Debugger::Null }
    attribute(:max_line_captures) { Float::INFINITY }
    attribute(:rewrite_code)      { RewriteCode }
  end

  def self.call(*args)
    new(*args).call
  end

  attr_reader :options
  def initialize(program, options={})
    @program = program
    @program += "\n" unless @program.end_with? "\n"
    @options = Options.new options
  end

  def call
    @memoized_result ||= Dir.mktmpdir("seeing_is_believing_temp_dir") { |dir|
      options.filename ||= File.join(dir, 'program.rb')
      new_program = options.rewrite_code.call @program,
                                              options.filename,
                                              options.max_line_captures

      options.debugger.context("TRANSLATED PROGRAM") { new_program }

      result        = Result.new
      event_handler = EventStream::UpdateResultHandler.new(result)
      event_handler = EventStream::DebuggingHandler.new(options.debugger, event_handler)
      EvaluateByMovingFiles.call \
        new_program,
        options.filename,
        event_handler:   event_handler,
        provided_input:  options.stdin,
        require:         options.require,
        load_path:       options.load_path,
        encoding:        options.encoding,
        timeout_seconds: options.timeout_seconds

      options.debugger.context("RESULT") { result.inspect }

      result
    }
  end
end
