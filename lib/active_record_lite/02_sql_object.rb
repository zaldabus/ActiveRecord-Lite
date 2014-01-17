require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'
require 'debugger'

class MassObject
  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    # self = self.to_s.downcase.underscore + "s"
    # self.send(table_name)
  end

  def self.table_name
    self.to_s.downcase.underscore + "s"
  end

  def self.all
    returns = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    self.parse_all(returns)
  end

  def self.find(id)
    returns = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    self.parse_all(returns).first
  end

  def insert
    col_names = self.class.attributes.join(", ")
    question_marks = (["?"] * self.class.attributes.length).join(", ")
    results = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end
  # end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end

  def update
    set_line = self.class.attributes.map { |attr| "#{attr} = ?"}.join(", ")

    results = DBConnection.execute(<<-SQL, *attribute_values)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = #{self.id}
    SQL
  end

  def attribute_values
    self.class.attributes.map { |attribute| self.send(attribute) }
  end
end
