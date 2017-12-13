#!/usr/bin/ruby

max_length = 80
if ARGV[0] == "-n"
  _, length = ARGV.shift(2)
  max_length = length.to_i
  throw "you must provide a positive width with -n" if max_length == 0
end
commentPatterns = [ '#', '//', '*' ]
lines = []
indentation = ""
ARGF.each_line do |line|
  line =~ /( *)(.*)/
  space, line = $1, $2
  indentation = space if space.length > indentation.length
  lines.push(line)
end

prefix = indentation
comment = commentPatterns.find { |pattern| lines.all? {|line| line.start_with? pattern } }
if comment
  prefix += "#{comment} "
  lines = lines.map { |line| line[comment.length..-1] }
end

max_length -= prefix.length
throw "prefix too long for max_length" if max_length < 1

lines = lines.lazy.map(&:strip)

# group lines split by one or more blank lines
paragraphs = lines.chunk { |line| line == "" }.flat_map { |blank, paragraph| blank ? [] : [paragraph] }

paragraphs.each_with_index do |paragraph, index|
  # separate paragraphs with blank line, or a commented blank line if we're commenting
  # we don't need this for the first paragraph
  puts comment ? prefix[0..-2] : "" unless index == 0

  output = ""
  paragraph.lazy.flat_map(&:split).each do |word|
    if output == ""
      output = word
    elsif output.length + 1 + word.length <= max_length
      output += " #{word}"
    else
      puts "#{prefix}#{output}"
      output = word
    end
  end
  puts "#{prefix}#{output}" if output != ""
end
