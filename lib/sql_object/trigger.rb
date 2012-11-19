module SqlObject
  class Trigger < AbstractObject
    OBJECT_CODE = 'TR'
    OBJECT_NAME = 'TRIGGER'

    def initialize(options)
       super
       @trigger_type = options[:trigger_type]
    end

    private

    def create_template_source
      <<-SQL
        CREATE TRIGGER <%= name %>
        ON <%= trigger_source %>
        <%= run_when %> <%= trigger_type %>
        <%= "NOT FOR REPLICATION" if not_for_replication %>
        AS
        <%= body %>
      SQL
    end

    def default_create_options
      super.merge(
        not_for_replication: false,
        run_when: "AFTER",
        trigger_type: @trigger_type
      )
    end

    def required_options
      super + [:trigger_type]
    end

  end
end
