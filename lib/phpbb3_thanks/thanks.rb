require 'mysql2'

module PHPBB3_Thanks
  # extract thanks from database
  class Thanks
    def initialize(conf)
      # {'source'=>ostruct, 'dest'=>ostruct}
      @conf = PHPBB3_Thanks::Config.new(conf).hash
    end


  end
end
