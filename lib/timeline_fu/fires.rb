module TimelineFu
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def fires(event_type, opts)
        raise ArgumentError, "Argument :on is mandatory" unless opts.has_key?(:on)
        opts[:subject] = :self unless opts.has_key?(:subject)

        on = opts.delete(:on)
        _if = opts.delete(:if)

        method_name = :"fire_#{event_type}_after_#{on}"
        define_method(method_name) do
          create_options = opts.keys.inject({}) do |memo, sym|
            case opts[sym]
            when :self
              memo[sym] = self
            else
              memo[sym] = send(opts[sym]) if opts[sym]
            end
            memo
          end
          create_options[:event_type] = event_type.to_s

          TimelineEvent.create!(create_options)
        end

        send(:"after_#{on}", method_name, :if => _if)
      end
    end
  end
end
