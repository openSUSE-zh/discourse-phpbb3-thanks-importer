require 'mysql2'

module PHPBB3_Thanks
  # extract thanks from database
  class Thanks
    def initialize(conf)
      # {'source'=>ostruct, 'dest'=>ostruct}
      @conf = PHPBB3_Thanks::Config.new(conf).hash
      @source_ostruct = @conf['source']
      @mysql = Mysql2::Client.new(:host => @source_ostruct.host,
				   :port => @source_ostruct.port,
				   :database => @source_ostruct.schema,
				   :username => @source_ostruct.username,
				   :password => @source_ostruct.password)
    end

    def get
      get_data_from_thanks_table
    end

    def put

    end

    private

    def get_data_from_thanks_table
      thanks_data = @mysql.query("SELECT * FROM #{@source_ostruct.table_prefix}thanks")
      thanks_data.each do |row|
	hash = {}
        post_title = get_post_title
      end
    end

    def get_post_title(post_id)
    end
  end
end
#require './config.rb'
#p PHPBB3_Thanks::Thanks.new('config').get
