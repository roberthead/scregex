#!/usr/bin/ruby

class String

  SCRABBLE_POINTS = {
    'a' => 1,
    'b' => 3,
    'c' => 3,
    'd' => 2,
    'e' => 1,
    'f' => 4,
    'g' => 2,
    'h' => 4,
    'i' => 1,
    'j' => 8,
    'k' => 5,
    'l' => 1,
    'm' => 3,
    'n' => 1,
    'o' => 1,
    'p' => 3,
    'q' => 10,
    'r' => 1,
    's' => 1,
    't' => 1,
    'u' => 1,
    'v' => 4,
    'w' => 4,
    'x' => 8,
    'y' => 4,
    'z' => 10,
  }
  
  WORDS_WITH_FRIENDS_POINTS = {
    'a' => 1,
    'b' => 3,
    'c' => 4,
    'd' => 2,
    'e' => 1,
    'f' => 4,
    'g' => 3,
    'h' => 3,
    'i' => 1,
    'j' => 8,
    'k' => 5,
    'l' => 2,
    'm' => 3,
    'n' => 1,
    'o' => 1,
    'p' => 4,
    'q' => 10,
    'r' => 1,
    's' => 1,
    't' => 1,
    'u' => 1,
    'v' => 4,
    'w' => 4,
    'x' => 8,
    'y' => 4,
    'z' => 10,
  }

  def score
    p = 0
    self.each_char do |c|
      p += (WORDS_WITH_FRIENDS_POINTS[c] rescue -100)
    end
    p
  end
  
end

def regex(rack_letters, wildcard_count, board_letters = '')
  rack_letters_uniq = rack_letters.split(//).uniq.to_s
  if wildcard_count > 0
    if board_letters.length > 0
      if rack_letters.length > 0
        regex = /^[#{rack_letters_uniq}]{0,#{rack_letters.length}}(\w([#{rack_letters_uniq}]){0,#{rack_letters.length}}){0,#{wildcard_count}}#{board_letters}[#{rack_letters_uniq}]{0,#{rack_letters.length}}(\w[#{rack_letters_uniq}]{0,#{rack_letters.length}}){0,#{wildcard_count}}$/
      else
        regex = /^\w{0,#{wildcard_count}}#{board_letters}\w{0,#{wildcard_count}}$/
      end
    else
      regex = /^[#{rack_letters_uniq}]{0,#{rack_letters.length}}(\w[#{rack_letters_uniq}]{0,#{rack_letters.length}}){0,#{wildcard_count}}$/
    end
  else
    regex = board_letters.length > 0 ?
      /^[#{rack_letters_uniq}]{0,#{rack_letters.length}}#{board_letters}[#{rack_letters_uniq}]{0,#{rack_letters.length}}$/ :
      /^[#{rack_letters_uniq}]{0,#{rack_letters.length}}$/
  end
  puts "Regex: #{regex}"
  regex
end

def matching_words(rack_letters, wildcard_count, board_letters = '')
  regex = regex(rack_letters, wildcard_count, board_letters)
  file = File.open('/usr/share/dict/words', 'r')
  all_letters = (rack_letters + board_letters)
  min_length = [2, board_letters.length + 1].max
  max_length = (all_letters.length + wildcard_count)
  min_length = [min_length, max_length].min
  puts "length: #{min_length} - #{max_length}"
  words = file.select do |word|
    w = word.strip
    if (
        w.length >= min_length  &&
        w.length <= max_length &&
        w.match(regex)
      )
      remaining_letters = all_letters
      wildcard_usages = 0
      w.split(//).each do |letter_in_word|
        if remaining_letters.include?(letter_in_word)
          remaining_letters = remaining_letters.sub(letter_in_word, '')
        else
          wildcard_usages += 1
        end
      end
      if wildcard_usages <= wildcard_count
        true
      else
        false
      end
    else
      false
    end
  end.collect {|w| w.strip.downcase}.sort.sort_by { |w| -(w.score + w.length * 100) }
end

rack_letters = ARGV[0].strip.downcase
board_letter_array = ARGV.slice(1, 99).collect {|s| s.strip.downcase}
wildcard_count = rack_letters.count("?")
rack_letters = rack_letters.gsub(/\?/, '')
puts "#{wildcard_count} wildcard(s) detected"

for board_letters in ([''] + board_letter_array)
  puts "Searching for: #{[(rack_letters.length > 0 ? rack_letters : nil), (wildcard_count > 0 ? (wildcard_count.to_s + ' wildcard(s)') : nil)].select {|e| !e.nil?}.join(' plus ')}#{board_letters.length > 0 ? ' incorporating ' + board_letters : nil}"
  matching_words(rack_letters, wildcard_count, board_letters).each {|w| puts "  #{w} (#{w.score})"}
end
