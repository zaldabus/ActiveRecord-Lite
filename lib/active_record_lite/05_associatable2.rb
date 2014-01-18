require_relative '04_associatable'
require 'debugger'
# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
    
     through_options = self.class.assoc_options[through_name]

     source_options =
       through_options.model_class.assoc_options[source_name] 
   
     key_val = self.send(through_options.foreign_key)
     results = DBConnection.execture(<<-SQL, key_val)
     SELECT
       #{source_options.table_name}.*
     FROM
       #{through_options.table_name}
     JOIN
       #{source_options.table_name}
      ON
       #{through_options.table_name}.#{foreign_key} = 
       #{source_options.table_name}.#{primary_key}
     WHERE
       #{through_options.table_name}.#{primary_key} = ?
     SQL

     source_options.model_class.parse_all(results).first
    end 
  end
end
