require 'pg'

module PhpbbThanks
  # map thanks data from phpbb to discourse's postgresql
  class Map
    attr_reader :data
    def initialize(config, txt)
      @config = PhpbbThanks::Config.new(config).hash
      @struct = @config['dest']
      @con = PG.connect :dbname => @struct.db,
                        :user => @struct.username,
                        :host => @struct.host,
                        :password => @struct.password
      @data = []
      open(txt, 'r:UTF-8') do |f|
        f.each_line do |l|
          @data << eval(l.strip)
        end
      end
      @data = map(@data)
    end

    def write
      open('mapped.txt', 'w:UTF-8') do |f|
        @data.each do |i|
          f.write "#{i}\n"
        end
      end
    end

    private

    def map(data)
      # map the thanks data with the IDs in the postgresql db
      data.map! do |i|
        # post_text, poster_id, user_id, topic_title, forum_name, thanks_time
        post_id = get_post_id(i[0])
        receiver = get_user_id(i[1])
        giver = get_user_id(i[2])
        topic_id = get_topic_id(i[3])
        forum_id = get_forum_id(i[4])
        [post_id, receiver, giver, topic_id, forum_id, i[5]]
      end
    end

    def get_post_id(id)
      ids = @con.exec "SELECT post_id FROM post_custom_fields WHERE name='import_id' AND value=\'#{id}\'"
      data = []
      ids.each do |row|
        data << row['post_id']
      end
      data[0]
    end

    def get_user_id(username)
      ids = @con.exec "SELECT id FROM users WHERE username_lower=\'#{username}\'"
      data = []
      ids.each do |row|
        data << row['id']
      end
      data[0]
    end

    def get_topic_id(title)
      ids = @con.exec "SELECT id FROM topics WHERE title=\'#{@con.escape_string(title)}\'"
      data = []
      ids.each { |row| data << row['id'] }
      data[0]
    end

    def get_forum_id(name)
      ids = @con.exec "SELECT id FROM categories WHERE name=\'#{name}\'"
      data = []
      ids.each { |row| data << row['id'] }
      data[0]
    end
  end
end
