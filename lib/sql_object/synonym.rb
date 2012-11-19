module SqlObject
  class Synonym < AbstractObject
    OBJECT_CODE = 'SN'
    OBJECT_NAME = 'SYNONYM'

    private

    def create_template_source
      <<-SQL
        CREATE SYNONYM <%= name %>
        FOR <%= source_object %>
      SQL
    end

    def default_options
      {
        template_source: ""
      }
    end
  end
end
