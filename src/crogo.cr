require "logger"
require "json"
require "./crogo/utils"
require "./crogo/*"

module Crogo

  @@logger = ::Logger.new(STDOUT)

  # Set a new logger instance
  #
  # @param new_logger [Logger]
  # @return [Logger]
  def self.logger=(new_logger : Logger) : Logger
    @@logger = new_logger
  end

  # @return [Logger] global logger
  def self.logger
    @@logger
  end

end
