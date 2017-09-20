require 'mysql2'
require 'suse_typo'
require 'latincjk'
require 'csv'

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
      CSV.open('thanks.csv', 'w') do |csv|
        data.each do |d|
          csv << d
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
        post_title = get_post_title(row['post_id'])
        receiver = get_username(row['poster_id'])
        giver = get_username(row['user_id'])
        topic_title = get_topic_title(row['topic_id'])
        forum_name = get_forum_name(row['forum_id'])
        thanks_time = get_thanks_time(row['thanks_time'])
        data << [post_title, receiver, giver,
                 topic_title, forum_name, thanks_time]
      end
      data
    end

    def get_post_title(id)
      posts = @mysql.query("SELECT post_subject FROM #{@source_ostruct.table_prefix}posts WHERE post_id=\"#{id}\"")
      data = []
      posts.each do |row|
        data << row['post_subject']
      end
      data[0]
    end

    def get_username(id)
      users = @mysql.query("SELECT username_clean FROM #{@source_ostruct.table_prefix}users WHERE user_id=\"#{id}\"")
      data = []
      users.each do |row|
        data << row['username_clean']
      end
      data[0]
    end

    def get_topic_title(id)
      topics = @mysql.query("SELECT topic_title FROM #{@source_ostruct.table_prefix}topics WHERE topic_id=\"#{id}\"")
      data = []
      topics.each do |row|
        data << row['topic_title']
      end
      data[0]
    end

    def get_forum_name(id)
      forums = @mysql.query("SELECT forum_name FROM #{@source_ostruct.table_prefix}forums WHERE forum_id=\"#{id}\"")
      data = []
      forums.each do |row|
        data << row['forum_name']
      end
      data[0]
    end

    def get_thanks_time(str)
      Time.at(str.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end
