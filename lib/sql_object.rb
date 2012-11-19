require 'sql_object/sql_template'
require 'sql_object/utils'
require 'sql_object/template_file_dir'
require 'sql_object/template_file'
require 'sql_object/abstract_object'
require 'sql_object/view'
require 'sql_object/stored_procedure'
require 'sql_object/trigger'

module SqlObject
  def self.sql_source_path
    Rails.root.join("db","sql_object","sql_source")
  end

  def self.templates_path
    Rails.root.join("db","sql_object","templates")
  end
end
