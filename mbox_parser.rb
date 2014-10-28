#!/usr/bin/env ruby

def parse_aliases
  aliases_arr = []
  x = 0
  ARGF.each do |line|
    aliases_arr[x] = []
    words = line.split(' ')
    words.each do |word|
      if /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.match(word).nil?
        aliases_arr[x][0] = word
      elsif aliases_arr[x].size == 0
        aliases_arr[x][aliases_arr[x].size + 1] = word
      else
        aliases_arr[x][aliases_arr[x].size] = word
      end
    end
    x += 1
  end
  return aliases_arr
end

def find_ind(email, senders_list)
  x = 0
  while x < senders_list.size
    return x if senders_list[x][1].downcase == email.downcase
    x += 1
  end
  return -1
end

def add_to_list(name=nil, email, senders_list)
  if senders_list.empty?
    senders_list[0] = []
    senders_list[0][0] = name
    senders_list[0][1] = email
    senders_list[0][2] = 1
  else
    ind = find_ind(email, senders_list)
    if ind > -1
      senders_list[ind][2] += 1
    else
      senders_list[senders_list.size] = []
      senders_list[senders_list.size - 1][0] = name
      senders_list[senders_list.size - 1][1] = email
      senders_list[senders_list.size - 1][2] = 1
    end
  end
end

def find_in_aliases(aliases, email)
  x = 1
  while x < aliases.size
    if aliases[x].any?{ |e| e.casecmp(email) == 0 }
      unless aliases[x][0] == nil
        return aliases[x][0], aliases[x][1]
      else
        return nil, aliases[x][1]
      end
    else
      return nil, email
    end
    x +=1
  end
end

def output_senders_list(senders_list)
  x = 0
  while x < senders_list.size
    if senders_list[x][0].nil?
      print("#{senders_list[x][1]}: ")
    else
      print("#{senders_list[x][0]}: ")
    end
    puts senders_list[x][2]
    x += 1
  end
end

if ARGV.size > 0
  ARGV.shift while ARGV.size > 1
  aliases = parse_aliases
end
senders_list = []
no_email = false
while ln = $stdin.gets
  if (ln =~ /From:/) || (no_email == true)
    no_email = false
    if (/<(.*?)>/.match(ln)).nil?
      no_email = true
    else
      email = /<(.*?)>/.match(ln)[1]
      if aliases.nil?
        add_to_list(email, senders_list)
      else
        name, email = find_in_aliases(aliases, email)
        add_to_list(name, email, senders_list)
      end
    end
  end
end
senders_list.sort! { |a,b| a[2] <=> b[2] }
output_senders_list(senders_list)
