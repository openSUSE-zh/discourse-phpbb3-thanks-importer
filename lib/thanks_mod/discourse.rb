module ThanksMod
  class Discourse
    def initialize(con, txt)
      @con = con
      @data = []
      open(txt, "r:UTF-8") do |f|
        f.each_line do |l|
          @data << eval(l.strip)
        end
      end
    end

    def push
      @data.each do |i|
        # update post_actions table
        #@con.exec "INSERT INTO post_actions (post_id, user_id, post_action_type_id, created_at, updated_at, staff_took_action, targets_topic)VALUES('#{i[0]}', '#{i[2]}', '2', '#{i[5]}', '#{i[5]}', 'f', 'f')"

        # update posts table
        post_calculator = ThanksMod::PostCalculator.new(@con, i[0], i[1], i[3])
        like_count = post_calculator.like_count
        like_score = post_calculator.like_score
        score = post_calculator.score(like_score)
        pr = post_calculator.percent_rank
        #@con.exec "UPDATE posts SET like_count='#{like_count}', like_score='#{like_score}', score='#{score}', percent_rank='#{pr}' WHERE id='#{i[0]}'"

        # update topic_users table
        #@con.exec "UPDATE topic_users SET liked='t' WHERE user_id='#{i[2]}' AND topic_id='#{i[3]}'"

        # update topics table
        topic_calculator = ThanksMod::TopicCalculator.new(@con, i[3])
        topic_likes = topic_calculator.like_count
        topic_score = topic_calculator.score
        topic_pr = topic_calculator.percent_rank
        #@con.exec "UPDATE topics SET like_count='#{topic_likes}',score='#{topic_score}',percent_rank='#{topic_pr}' WHERE id='#{i[3]}'"

        # update top_topics table
        top_calculator = ThanksMod::TopCalculator.new(@con, i[3])
        op_likes = top_calculator.op_like_count
        scores = top_calculator.scores
        #@con.exec "UPDATE top_topics SET yearly_likes_count='#{topic_likes}',monthly_likes_count='#{topic_likes}',weekly_likes_count='#{topic_likes}',daily_likes_count='#{topic_likes}',quarterly_likes_count='#{topic_likes}' WHERE topic_id='#{i[3]}'"
        #@con.exec "UPDATE top_topics SET yearly_op_likes_count='#{op_likes}',monthly_op_likes_count='#{op_likes}',weekly_op_likes_count='#{op_likes}',daily_op_likes_count='#{op_likes}',quarterly_op_likes_count='#{op_likes}' WHERE topic_id='#{i[3]}'" 
        #@con.exec "UPDATE top_topics SET daily_score='#{scores[0]}',weekly_score='#{scores[1]}',monthly_score='#{scores[2]}',quarterly_score='#{scores[3]}',yearly_score='#{scores[4]}',all_score='#{scores[5]}' WHERE topic_id='#{i[3]}'"
      end
    end
  end
end

require './config.rb'
require './db.rb'
require './post.rb'
require './topic.rb'
require './top.rb'
pg = ThanksMod::DB.new("config").pg

#p ThanksMod::Discourse.new(pg, "mapped.txt").push
