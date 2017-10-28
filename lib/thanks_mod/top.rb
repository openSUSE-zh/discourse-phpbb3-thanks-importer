require 'date'

module ThanksMod
  # calculate likes_count and score for top_topics
  class TopCalculator
    def initialize(con, topic_id)
      @con = con
      @topic = topic_id
    end

    def scores
      # yearly, monthly, weekly, daily, quarterly
      scores = []

      created_at, posts_count = @con.exec("SELECT created_at,posts_count FROM topics WHERE id='#{@topic}'").values[0]
      created_at = Date.parse(created_at)
      posts_count = posts_count.to_i

      periods.each do |k, v|
        scores << 0 if created_at < v
        a, b, c, d = @con.exec("SELECT #{k}_views_count,#{k}_likes_count,#{k}_posts_count,#{k}_op_likes_count FROM top_topics WHERE topic_id='#{@topic}'").values[0].map!(&:to_i)
        scores << calculate(a, b, c, d, posts_count)
      end

      # append all_score
      e, f, g = all.map(&:to_i)
      [calculate(e, f, posts_count, g, posts_count)] + scores
    end

    def op_like_count
      q = @con.exec("SELECT like_count FROM posts WHERE post_number=1 AND topic_id='#{@topic}'")
              .values.flatten.map!(&:to_i)
      q.inject(0) { |sum, x| sum + x }
    end

    private

    def calculate(a, b, c, d, e)
      a = 1 if a < 1
      views = a * 2
      likes = if b > 0 && c > 0
                (b / c) < 3 ? b / c : 3
              else
                0
              end
      posts = if e < 10
                0 - ((10 - e) / 20) * d
              else
                10
              end
      posts = c > 1 ? posts + c : posts + 1
      views + likes + posts
    end

    def periods
      d = Date.today
      # yearly, monthly, weekly, daily, quarterly
      { 'yearly' => d - 365, 'monthly' => d - 30, 'weekly' => d - 7, 'daily' => d - 1, 'quarterly' => d - 90 }
    end

    def all
      views, likes = @con.exec("SELECT views,like_count FROM topics WHERE id='#{@topic}'").values[0]
      op = @con.exec("SELECT like_count FROM posts WHERE topic_id='#{@topic}' AND post_number=1").values[0][0]
      [views, likes, op]
    end
  end
end
