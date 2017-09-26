module ThanksMod
  class Pull
    def initialize(con, txt)
      @con = con
      @data = []
      open(txt, "r:UTF-8") do |f|
        f.each_line do |l|
          @data << eval(l.strip)
        end
      end
    end

    def pull
      @data.each do |i|
        # update post_actions table
        #@con.exec "INSERT INTO post_actions (post_id, user_id, post_action_type_id, created_at, updated_at, staff_took_action, targets_topic)VALUES('#{i[0]}', '#{i[2]}', '2', '#{i[5]}', '#{i[5]}', 'false', 'false')"
        # update posts table
        post_calculator = ThanksMod::PostCalculator.new(@con, i[0], i[1], i[3])
        like_count = post_calculator.like_count
        like_score = post_calculator.like_score
        score = post_calculator.score(like_score)
        percent_rank = post_calculator.percent_rank
        #@con.exec "UPDATE posts SET like_count='#{like_count}', like_score='#{like_score}', score='#{score}', percent_rank='#{percent_rank}' WHERE id='#{i[0]}'"
        # update topic_users table

        # update topic table

        # update top_topics table
      end
    end
  end
end

require './config.rb'
require './db.rb'
require './post.rb'
pg = ThanksMod::DB.new("config").pg

p ThanksMod::Pull.new(pg, "mapped.txt").pull
