require 'i18n/ruby/translate_call'
require 'pp'

module I18n
  module Ripper
    module Collectors
      module TranslateCalls
        # [:command, :on_command_call, :on_call, :on_fcall].each do |method|
        [:on_stmts_add].each do |method|
          self.class_eval <<-eoc
            def #{method}(target, statement)
              super.tap do
                collect_translate_call(statement.to_translate_call) if statement.is_a?(Ruby::Call)
              end
            end
          eoc
        end
      
        def translate_calls
          @translate_calls ||= []
        end
      
        def collect_translate_call(call)
          call.tap { |c| translate_calls << c } if is_translate_call?(call)
        end
      
        KEY_CLASSES = [Ruby::Symbol, Ruby::DynaSymbol, Ruby::String, Ruby::Array]
      
        def is_translate_call?(call)
          call.identifier.try(:token) == 't' &&
          (!call.target.respond_to?(:token) || call.target.token == 'I18n') && 
          call.arguments && KEY_CLASSES.include?(call.arguments.first.arg.class)
        end
      end
    end
  end
end