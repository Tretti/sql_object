module SqlObject
  class AbstractObject

    @template_path = self.to_s
    attr_reader :name

    class << self
      def connection
        ActiveRecord::Base.connection
      end

      def template_file_dir
        SqlObject::TemplateFileDir.new(self.search_path)
      end

      def template_files
        template_file_dir.template_files
      end

      def all
        template_files.map{|template_file| new(template_file.read, template_file.object_name_from_path) }
      end

      def search_path
        self.name.split('::').last.snakecase.pluralize
      end

      def from_name_fragments(path_fragments, options = {})
      	file_candidates = []
        file_candidates << options[:default_template_file] if options[:default_template_file]
        file_candidates += combine_fragments(path_fragments)
        options[:name] ||= file_candidates.first
        template_file = template_file_dir.find_best_match(options[:base_path], file_candidates)
        raise "No files found matching #{file_candidates.join(", ")}" if template_file.blank?
        from_template_file(template_file, options)
      end

      def combine_fragments(path_fragments, separator= "_")
      	variations = []
        path_fragments.each_index do | i |
          variations[i] = path_fragments[0..i].join(separator)
        end
        variations
      end

      def from_template_file(template_file_name, options = {})
        raise ArgumentError, "First argument must be a file path" unless template_file_name
        options[:name] = options[:name] || template_file_name.gsub(/\//,'_')
        options[:template_source] = template_file_dir.template_file(template_file_name)
        new(options)
      end

      def sql_object_name
        const_get('OBJECT_NAME')
      end

      def sql_object_initial
        const_get('OBJECT_CODE')
      end

      def required_options
        [:name, :template_source]
      end

    end

    def create_template_source
      "CREATE #{self.class.sql_object_name} #{@name}\nAS\n<%= body %>"
    end

    def drop_template_source
      "DROP #{self.class.sql_object_name} #{@name}"
    end

    # def get_sys_row_sql(name)
    #     "select * from sys.objects where object_id = OBJECT_ID(N'#{name}') and type = N'#{self.const_get("OBJECT_CODE")}'"
    # end

    def arel_source
      Arel::Table.new(:'sys.objects')
    end

    def arel_find
      arel_source.project(Arel.sql('*'))
    end

    def db_all
      arel_find.where(arel_source[:type].eq(self.const_get("OBJECT_CODE")))
    end

    def db_by_name(name)
      self.connection.select_all(db_all.where(arel_source[:name].eq(name)))
    end

    def exists?(name)
      db_by_name.size > 0
    end

    def initialize(options={})
      @options = default_options.merge(options)
      @name = options[:name]

    end

    def find_in_db
      self.class.db_by_name(self.name)
    end

    def exist_in_db?
      find_in_db.size > 0
    end

    def to_sql(options = {})
    	SqlTemplate.new(default_create_options.merge(@options)).render
    end

    def create_sql(options = {})
      create_template.render
    end

    def drop_sql(options = {})
      drop_template.render
    end

    def db_create(options = {})
      db_drop! if options[:force]
      self.class.connection.execute to_sql
    end

    def db_drop!(options = {})
      self.class.connection.execute drop_sql rescue nil
    end

    def generate_sql_file(options={})
      SqlSourceFile.create(source_path, to_sql)
    end

    private

    def source_path
      SqlObject.sql_source_path.join(self.class.search_path, @name + ".sql")
    end

    def default_options
      {
        search_path: self.class.search_path,
        required_options: self.class.required_options
      }
    end

    def default_create_options
      {
        #sql: @template.render,
        create_template_source: create_template_source,
        name: @name
      }
    end

    def default_drop_options
      options = {
        name: @name
      }
    end

    def drop_template(options={})
      options = default_drop_options.merge(options)
      SqlTemplate.new(options)
    end

    def create_template(options={})
      options = default_create_options.merge(options)
      SqlTemplate.new(options)
    end
  end

end

