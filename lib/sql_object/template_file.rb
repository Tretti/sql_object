module SqlObject
  class TemplateFile

    EXTENSION = ".sql.erb"

    attr_accessor :path, :basename

    def initialize(path)
      self.path = path.extname.empty? ? path.sub_ext(EXTENSION) : path
    end

    def object_name_from_path
      path.basename.to_s.gsub(/\.erb$/,"").gsub(/\.sql$/,"")
    end

    def read
      path.read
    end
  end
end
