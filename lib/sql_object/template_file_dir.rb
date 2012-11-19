module SqlObject


  class TemplateFileDir
    attr_reader :path, :search_path
    class << self

      def all_in_path(*paths)
        paths.map{| path | new(path) }
      end

      def all_template_files(*paths)
        all_in_path(paths).map {| template_file_dir | template_file_dir.template_files }.flatten
      end

      def all_sql_objects(*paths)
        all_template_files(paths).map do |template_file|
          #Template.new(template_file.object_name_from_path, template_file.read)
          ""
        end
      end

    end

    def initialize(path)
      @path = path
      @search_path = base_path.join(*path)
      raise "Missing directory: #{@search_path.dirname}" unless @search_path.dirname.exist?
    end

    def template_file_paths
      Pathname.glob(@search_path.join("*" + TemplateFile::EXTENSION))
    end

    def template_files
      template_file_paths.map do |path|
        TemplateFile.new(path)
      end
    end

    def find_best_match(base_path, file_candidates)
      # file_candidates = ["default"] + file_candidates
      file_candidates.reverse_each do | file_name |
        file_name << TemplateFile::EXTENSION
        rel_path = Pathname.new(base_path).join(file_name)
        full_file_path = @search_path.join(rel_path)
        #puts "path: #{full_file_path}"
        return rel_path if File.exists? full_file_path
      end
      puts "found none"
      nil
    end

    def template_file(sql_object_name)
      TemplateFile.new(@search_path.join(sql_object_name))
    end

    def template_partial_file(sql_object_name)
      TemplateFile.new(@search_path.join('partials/',('_' + sql_object_name)))
    end

    def base_path
      SqlObject.templates_path
    end


  end

end
