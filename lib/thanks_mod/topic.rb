module ThanksMod
  # calculate score and percent_rank for topics
  class TopicCalculator
    def initialize(con, topic_id)
      @con = con
      @topic = topic_id
    end

    def score
      q = @con.exec("SELECT score FROM posts WHERE topic_id='#{@topic}'")
              .values.flatten.map!(&:to_f)
      q.inject(0) {|sum,x| sum + x} / q.size
    end

    def like_count
      q = @con.exec("SELECT like_count FROM posts WHERE topic_id='#{@topic}'")
              .values.flatten.map!(&:to_i)
      q.inject(0) {|sum,x| sum + x}
    end

    def percent_rank
      q = @con.exec("SELECT id,score FROM topics ORDER BY score DESC")
      rank = ThanksMod::PostCalculator.send(:rank, q, @topic)
      size = q.cmdtuples
      (rank - 1) / (size - 1).to_f
    end
  end
end
