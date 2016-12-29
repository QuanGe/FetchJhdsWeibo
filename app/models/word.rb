#encoding: utf-8
class Word < ActiveRecord::Base
  attr_accessible :text, :level    # 1 低级别；2 高级别

  scope :highs, -> { where(level: 2)}
  scope :lows, -> {where(level: 1)}
  scope :search, ->(key) {
    where(text: /#{key}/)
  }

  class << self
    def match(*contents)
      low_words = []
      high_words = []
      if contents.present?
        contents.each do |content|
          Word.all.each do |word|
            index = (content =~ /#{word.text.gsub('[s]*', '\s{0,3}').gsub('*', '\s{0,3}')}/)
            unless index.nil?
              if word.level.to_i == 2
                high_words << word.text
              elsif word.level.to_i == 1
                low_words << word.text
              end
            end
          end
        end
      end
      [low_words, high_words]
    end
  end

end
