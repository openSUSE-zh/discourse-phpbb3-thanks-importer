require 'mysql2'

module PhpbbThanks
  # extract thanks from phpbb3 mysql database
  class Pool
    def initialize(conf)
      # {'source'=>ostruct, 'dest'=>ostruct}
      @conf = PhpbbThanks::Config.new(conf).hash
      @source_ostruct = @conf['source']
      @mysql = Mysql2::Client.new(host: @source_ostruct.host,
                                  port: @source_ostruct.port,
                                  database: @source_ostruct.schema,
                                  username: @source_ostruct.username,
                                  password: @source_ostruct.password)
    end

    def fill
      data = read_data_from_thanks_table
      open('thanks.txt', 'w:UTF-8') do |t|
        data.each do |d|
          t.write "#{d}\n"
        end
      end
    end

    private

    def read_data_from_thanks_table
      thanks_data = @mysql.query("SELECT * FROM #{@source_ostruct.table_prefix}thanks")
      data = []
      thanks_data.each do |row|
        # post_id, poster_id, user_id, topic_id, forum_id, thanks_time
        # 4936, 2, 280, 591, 19, 1366386854
        receiver = get_username(row['poster_id'])
        giver = get_username(row['user_id'])
        thanks_time = get_thanks_time(row['thanks_time'])
        data << [row['post_id'], receiver, giver, thanks_time]
      end
      data
    end

    def get_username(id)
      users = @mysql.query("SELECT username FROM #{@source_ostruct.table_prefix}users WHERE user_id=\"#{id}\"")
      data = []
      users.each do |row|
        data << row['username']
      end
      data[0]
    end

    def get_thanks_time(str)
      Time.at(str.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end
