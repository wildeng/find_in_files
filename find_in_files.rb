# #!/usr/bin/env ruby
#
# @author Alain Mauri
#
# This simple script tries to replicate grep without all the options
# grep provides.
# It's just a way to learn what the optparse gem is doing
#

require 'optparse'
require 'ostruct'
require 'pp'

class Parser
  attr_accessor :options
  attr_accessor :optparse

  def  self.parse_options(args)
    @options = OpenStruct.new
    @options.base_folder = File.expand_path('~')
    
    @opt_parser = OptionParser.new do |opts|
      opts.banner = "usage find_in_files.rb [options]"
      opts.on("-nTERM", "--name=TERM", "Term to look for") do |n|
        @options.term = n
      end

      opts.on("-dDIR", "--dir=DIR", "Folder to look into, defaults to HOME") do |n|  
        @options.dir = n
      end

      opts.on("-h", "--help", "print this help") do
        puts opts
        exit
      end
    end
    
    @opt_parser.parse!(args)
  rescue OptionParser::MissingArgument
    puts "Missing Argument:"
  end

  def self.find_term(folder, term)
    Dir.glob(folder + "**/*").each do |name|
      if File.directory?(name)
        next if Dir.empty?(name)
        self.find_term(name, term)
      end
    
      next if File.directory?(name)
      IO.foreach(name).with_index do |line, index|
        line = line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        pp "line #{index} #{name}: " + line if line.match /#{term}/
      end  
    end
  end

  def self.missing_term?
    return true unless @options.term
    false      
  end
  
  def self.is_folder_missing?
    @options.base_folder = @options.dir if @options.dir
    puts @options.base_folder
    return false if Dir.exists?(@options.base_folder)
    true
  end


  def self.init(args)
    self.parse_options(args)
    if self.missing_term?
      puts "Missing a term to find:"
      puts @opt_parser
      abort
    end

    if self.is_folder_missing?
      puts "The folder does not exists:"
      puts @optparse
      abort
    end


    Dir.glob(@options.base_folder + "**/*").each do |name|
      self.find_term(name, @options.term)
    end
  end

end

Parser.init(ARGV)

#abort "Nothing to search for" unless options[:term]

#abort "No such folder #{options[:dir]}" unless Dir.exists?(base_folder)



