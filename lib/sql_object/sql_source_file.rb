module SqlObject
  class SqlSourceFile

    def self.create(file_path, sql)
      file_path.dirname.mkpath unless file_path.dirname.exist?
      File.open(file_path, "w") do |f|
        f.puts sql
      end
    end

  end
end
