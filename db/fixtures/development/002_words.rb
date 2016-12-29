# encoding: utf-8

Word.delete_all


# 添加高敏感词
file = File.open(File.join(Rails.root,"db/fixtures", "highs.txt"), "r")
file.each do |line|
  Word.new(text: line.strip, level: 2).save
end
file.close

# 添加低敏感词
file = File.open(File.join(Rails.root,"db/fixtures", "lows.txt"), "r")
file.each do |line|
  Word.new(text: line.strip, level: 1).save
end
file.close