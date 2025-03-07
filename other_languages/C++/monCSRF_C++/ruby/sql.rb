# ********************************************************************
#
#  The same parse in ruby. It's working but no utility so far.
#
#                         (nov/2011)
#
# ********************************************************************



class Sql

  attr_accessor :sql_command
  attr_accessor :sql_info

  REGEXP_COMMAND = /^([A-Za-z]+)\s/

  def initialize(sql)
    @sql_command = sql
  end

  # Parse the sql
  def parse
    @sql_info and return if @sql_info
    @sql_info = {}

    # MAtching command type
    @sql_command.match(Sql::REGEXP_COMMAND)
    @sql_info[:command_type] = $1
    #@sql_info[:sql] = @sql_command

    # Calling parser by command type
    case(@sql_info[:command_type])
    when 'UPDATE'
      return get_sql_info_for_update(@sql_command.gsub(Sql::REGEXP_COMMAND, ""))
    when 'CREATE'
      return get_sql_info_for_create(@sql_command.gsub(Sql::REGEXP_COMMAND, ""))
    when 'DELETE'
      return get_sql_info_for_delete(@sql_command.gsub(Sql::REGEXP_COMMAND, ""))
    else
      return false
    end
  end

  private

  def get_sql_info_for_update(sql_command)
    # Matching Table Name ######################
    regexp_table_name = /^([_A-Za-z]+)\sSET\s/
    sql_command.match(regexp_table_name)
    @sql_info[:table_name] = $1
    sql_command.gsub!(regexp_table_name, "")

    # Matching Fields ##########################
    regexp_fields = /^(.*)\sWHERE\s/
    sql_command.match(regexp_fields)
    #@sql_info[:fields_hash] = extract_fields_to_hash($1)
    @sql_info[:update_columns] = extract_fields_to_hash($1).keys.sort
    sql_command.gsub!(regexp_fields, "")

    # Matching Where Fields ####################
    #@sql_info[:raw_where] = sql_command
    @sql_info[:where] = extract_values_from_where(sql_command)
    @sql_info
  end

  # Remove values from the updated fields and put them on an array
  def extract_fields_to_hash(fields)
    fields_hash = {}
    fields = fields.split(',').map {|b| b.split('=') }
    fields.each do |field|
      fields_hash[field[0].strip] = field[1].strip
    end
    fields_hash
  end

  # Removes values from the WHERE
  def extract_values_from_where(raw_where)
    raw_where.gsub!(/\s\'[^']*\'\s/, "")
    raw_where.gsub!(/\s\"[^"]*\"\s/, "")
    raw_where.gsub!(/\s[0-9]*\s/, "")
    raw_where
  end


  def get_sql_info_for_create

  end

  def get_sql_info_for_delete

  end

  def remove_command_from_query

  end


end

#sql = File.read("sql_update")

sql = "UPDATE phpbb_sessions
		SET session_user_id = -1, session_start = 1319238613, session_time = 1319238613, session_page = 0, session_logged_in = 0
		WHERE session_id = '1'
			AND session_ip = '7f000001'"
sql.gsub!("\n", " ")
sql.gsub!(/\s+/, " ")
puts sql


sql_analyser = Sql.new(sql)
puts sql_analyser.parse
