# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "kitchen/terraform/command_flag/color"
require "kitchen/terraform/command_flag/lock_timeout"
require "kitchen/terraform/command_flag/lock"
require "kitchen/terraform/command_flag/parallelism"
require "kitchen/terraform/command_flag/variable_files"
require "kitchen/terraform/command_flag/variables"
require "kitchen/terraform/shell_out"

module Kitchen
  module Terraform
    module Command
      # Destroy is the class of objects which represent the <tt>terraform destroy</tt> command.
      class Destroy
        class << self
          # Initializes an instance by running `terraform destroy`.
          #
          # @param options [::Hash] the command options.
          # @option options [true, false] :color a toggle for colored output.
          # @option options [::String] :directory the directory in which to run the command.
          # @option options [true, false] :lock a toggle for locking the state.
          # @option options [::Integer] :lock_timeout the maximum duration in seconds to wait for the lock.
          # @option options [::Integer] :parallelism the maximum number of concurrent operations to perform while
          # running the command.
          # @option options [::Integer] :timeout the maximum duration in seconds to run the command.
          # @option options [::Array<::String>] :variable_files files containing variables for the configuration.
          # @option options [::Hash{::String => ::String}] :variables varibales for the configuration.
          # @raise [::Kitchen::Terraform::Error] if the result of running the command is a failure.
          # @return [self]
          # @yieldparam destroy [::Kitchen::Terraform::Command::Destroy] an instance initialized with the output of the
          #   command.
          def run(options)
            new(options).tap do |destroy|
              ::Kitchen::Terraform::ShellOut.run(
                command: destroy,
                directory: options.fetch(:directory),
                timeout: options.fetch(:timeout),
              )
              yield destroy: destroy
            end

            self
          end
        end

        def ==(destroy)
          to_s == destroy.to_s
        end

        def store(output:)
          @output = output

          self
        end

        def to_s
          ::Kitchen::Terraform::CommandFlag::VariableFiles.new(
            command: ::Kitchen::Terraform::CommandFlag::Variables.new(
              command: ::Kitchen::Terraform::CommandFlag::Parallelism.new(
                command: ::Kitchen::Terraform::CommandFlag::LockTimeout.new(
                  command: ::Kitchen::Terraform::CommandFlag::Lock.new(
                    command: ::Kitchen::Terraform::CommandFlag::Color.new(
                      command: ::String.new(
                        "terraform destroy " \
                        "-auto-approve " \
                        "-input=false " \
                        "-refresh=true"
                      ),
                      color: @color,
                    ),
                    lock: @lock,
                  ),
                  lock_timeout: @lock_timeout,
                ),
                parallelism: @parallelism,
              ),
              variables: @variables,
            ),
            variable_files: @variable_files,
          ).to_s
        end

        private

        def initialize(options)
          @color = options.fetch :color
          @lock = options.fetch :lock
          @lock_timeout = options.fetch :lock_timeout
          @parallelism = options.fetch :parallelism
          @variable_files = options.fetch :variable_files
          @variables = options.fetch :variables
        end
      end
    end
  end
end
