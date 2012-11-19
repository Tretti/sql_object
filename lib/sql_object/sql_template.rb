module SqlObject
  class SqlTemplate
    class Renderer
      class RenderContext

        def initialize(options)
          @options = options
          assert_no_missing_options
        end

        def get_binding
          binding
        end

        private

        def method_missing(m, *a, &blk)
          return @options[m] if @options.has_key? m

          if @options.has_key? :delegate_to_instance
            @options[:delegate_to_instance].public_send(m, *a, &blk)
          else
            raise NoMethodError, "Missing option '#{m}' for #{self.class} and nothing to delegate to"
          end
        end

        def respond_to?(m)
          super(m) or @options.has_key?(m) or @options[:delegate_to_instance].respond_to?(m)
        end

        def assert_no_missing_options
          if missing_options.any?
            raise ArgumentError, "Missing options: #{missing_options.join(', ')}"
          end
        end

        def missing_options
          return [] unless @options[:required_options]
          @options[:required_options].map{|opt| respond_to?(opt) ? nil : opt}.compact
        end
      end

      def initialize(source, options)
        @source = source
        @render_context = RenderContext.new(options)
        self
      end

      def get_erb_template
        ERB.new(@source, 0, '%')
      end

      def render(options={}, &blk)
        get_erb_template.result(@render_context.get_binding)
      end

    end

    def initialize(options)

      template_source = options[:template_source]
      template_wrapper = options[:create_template_source]

      if template_source.respond_to?(:read)
        template_source = template_source.read
      end

      if template_wrapper.respond_to?(:read)
        template_wrapper = template_wrapper.read
      end

      body = Renderer.new(template_source, options).render

      @renderer = Renderer.new(template_wrapper, options.merge(body: body))

      self
    end

    def render

      sql_source = @renderer.render
    	header = generate_header(
    		creation_time: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    		object_hash: Digest::MD5.hexdigest(sql_source)
    	)
    	header + sql_source
    end

    def generate_header(vars)
    	str = "-----------\n--\n"
    	vars.each{|param, val|
    		str +=	"-- #{param.to_s.ljust(20)} #{val}\n"
    	}
    	str += "--\n-----------\n\n"
    end
  end
end
