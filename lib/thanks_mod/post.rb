module ThanksMod
  # calculate score and percent_rank for posts
  class PostCalculator
    def initialize(con, post_id, user_id, topic_id)
      @con = con
      @id = post_id
      @user = user_id
      @topic = topic_id
    end

    def score(like_score)
      q = @con.exec("SELECT reply_count,incoming_link_count,bookmark_count,avg_time,reads FROM posts WHERE id='#{@id}'")[0].values.map!(&:to_i)
      15 * like_score + 5 * q[0] + 5 * q[1] + 2 * q[2] + 0.05 * q[3] + 0.2 * q[4]
    end

    def percent_rank
      q = @con.exec("SELECT id,score FROM posts WHERE topic_id='#{@topic}' ORDER BY score DESC")
      r = rank(q, @id)
      size = q.cmdtuples
      (r - 1) / (size - 1).to_f
    end

    def like_count
      @con.exec("SELECT like_count FROM posts WHERE id='#{@id}'")[0]['like_count'].to_i + 1
    end

    def like_score
      userstat = @con.exec("SELECT admin,moderator FROM users WHERE id='#{@user}'")[0]
      s = if userstat.values.include?('t')
            3
          else
            1
          end
      score = @con.exec("SELECT like_score FROM posts WHERE id='#{@id}'")
      s + score[0]['like_score'].to_i
    end

    private

    def rank(query, id)
      values = query.values
      ranks = []
      i = 1
      values.each_with_index do |v, j|
        ranks << if j.zero? || values[j - 1][1] != v[1]
                   (v << i)
                 else
                   (v << values[j - 1][2])
                 end
        i += 1
      end
      ranks.each do |r|
        return r[2] if r[0] == id
      end
    end
  end
end
