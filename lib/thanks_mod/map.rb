module ThanksMod
  # map thanks data from phpbb to discourse's postgresql
  class Map
    def initialize(con, data)
      @con = con
      @data = map(data)
    end

    def write
      open('mapped.txt', 'w:UTF-8') do |f|
        @data.each do |i|
          f.write "#{i}\n"
        end
      end
    end

    def get
      @data
    end

    private

    def map(data)
      # map the thanks data with the IDs in the postgresql db
      data.map! do |i|
        # post_text, poster_id, user_id, thanks_time
        post_id = get_post_id(i[0])
        receiver = get_user_id(i[1])
        giver = get_user_id(i[2])
        topic_id = get_topic_id(post_id)
        category_id = get_forum_id(topic_id)
        [post_id, receiver, giver, topic_id, category_id, i[3]]
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

    def get_user_id(id)
      ids = @con.exec "SELECT user_id FROM user_custom_fields WHERE name='import_id' AND value=\'#{id}\'"
      data = []
      return "-1" if ids.cmd_tuples.zero?
      ids.each do |row|
        data << row['user_id']
      end
      data[0]
    end

    def get_topic_id(post_id)
      ids = @con.exec "SELECT topic_id FROM posts WHERE id=\'#{post_id}\'"
      data = []
      ids.each { |row| data << row['topic_id'] }
      data[0]
    end

    def get_forum_id(topic_id)
      ids = @con.exec "SELECT category_id FROM topics WHERE id=\'#{topic_id}\'"
      data = []
      ids.each { |row| data << row['category_id'] }
      data[0]
    end
  end
end
