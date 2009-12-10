module SimpleForm
  module Components
    class Input < Base
      include RequiredHelpers
      extend I18nCache
      extend MapType

      map_type :boolean,  :to => :check_box
      map_type :text,     :to => :text_area
      map_type :datetime, :to => :datetime_select, :options => true
      map_type :date,     :to => :date_select, :options => true
      map_type :time,     :to => :time_select, :options => true
      map_type :password, :to => :password_field
      map_type :hidden,   :to => :hidden_field
      map_type :select,   :to => :collection_select, :options => true, :collection => true
      map_type :radio,    :to => :collection_radio, :collection => true
      map_type :string,   :to => :text_field

      # Numeric types
      map_type :integer, :float, :decimal, :to => :text_field

      def self.boolean_collection
        i18n_cache :boolean_collection do
          [ [I18n.t(:"simple_form.true", :default => 'Yes'), true],
            [I18n.t(:"simple_form.false", :default => 'No'), false] ]
        end
      end

      def generate
        html_options = @options[:html] || {}
        html_options[:class] = default_css_classes(html_options[:class])
        @options[:options] ||= {}

        mapping = self.class.mappings[@input_type]
        raise "Invalid input type #{@input_type.inspect}" unless mapping

        args = [ @attribute ]

        if mapping.collection
          collection = (@options[:collection] || self.class.boolean_collection).to_a
          detect_collection_methods(collection, @options)
          args.push(collection, @options[:value_method], @options[:label_method])
        end

        args << @options[:options] if mapping.options
        args << html_options

        @builder.send(mapping.method, *args)
      end

      def detect_collection_methods(collection, options)
        case collection.first
          when Array
            options[:label_method] ||= :first
            options[:value_method] ||= :last
          when String
            options[:label_method] ||= :to_s
            options[:value_method] ||= :to_s
          when Integer
            options[:label_method] ||= :to_s
            options[:value_method] ||= :to_i
          else
            options[:label_method] ||= :to_s
            options[:value_method] ||= :to_s
        end
      end
    end
  end
end