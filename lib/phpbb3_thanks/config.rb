require 'yaml'
require 'ostruct'

module PhpbbThanks
  # Parse yaml config
  class Config
    attr_reader :hash
    def initialize(conf)
      path = File.expand_path(File.dirname(__FILE__)) + '/../../config/'
      file = path + conf + '.yml'
      raise 'no such config' unless File.exist?(file)
      @hash = to_struct(YAML.safe_load(open(file, 'r:UTF-8').read))
    end

    private

    def to_struct(hash)
      hash.each do |k, v|
        s = OpenStruct.new
        v.each do |m, n|
          s[m] = n
        end
        hash[k] = s
      end
    end
  end
end
