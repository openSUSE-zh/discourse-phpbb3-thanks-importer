require 'date'

module ThanksMod
  # calculate likes_count and score for top_topics
  class TopCalculator
    def initialize(con, topic_id)
      @con = con
      @topic = topic_id
    end

    def scores
      # daily, weekly, monthly, quarterly, yearly
      scores = []

      created_at, posts_count = @con.exec("SELECT created_at,posts_count FROM topics WHERE id='#{@topic}'").values[0]
      created_at = Date.parse(d)

      periods.each do |k, v|
        scores << 0 if created_at < v
        a, b, c, d = @con.exec("SELECT #{k}_views_count,#{k}_likes_count,#{k}_posts_count,#{k}_op_likes_count FROM top_topics WHERE topic_id='#{@topic}'").values[0]
        scores << calculate(a, b, c, d)
      end

      # append all_score
      e, f, g = all
      scores << calculate(e, f, posts_count, g)

      scores
    end

    def op_like_count
      q = @con.exec("SELECT like_count FROM posts WHERE post_number=1 AND topic_id='#{@topic}'")
              .values.flatten.map!(&:to_i)
      q.inject(0) { |sum, x| sum + x }
    end

    private

    def calculate(a, b, c, d)
      a = 1 if a < 1
      views = a * 2
      likes = if b > 0 && c > 0
                (b / c) < 3 ? b / c : 3
              else
                0
              end
      posts = if posts_count < 10
                0 - ((10 - posts_count) / 20) * d
              else
                10
              end
      posts = c > 1 ? posts + c : posts + 1
      views + likes + posts
    end

    def periods
      d = Date.today
      { 'daily' => d - 1, 'weekly' => d - 7, 'monthly' => d - 30, 'quarterly' => d - 90, 'yearly' => d - 365 }
    end

    def all
      views, likes = @con.exec("SELECT views,like_count FROM topics WHERE id='#{@topic}'").values[0]
      op = @con.exec("SELECT like_count FROM posts WHERE topic_id='#{topic}' AND post_number=1").values[0][0]
      [views, likes, op]
    end
  end
end
