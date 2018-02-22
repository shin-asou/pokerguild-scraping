require 'nokogiri'
require 'open-uri'

base_url = 'http://pokerguild.jp/players/80513'

charset = nil

tournament_result = {}

1.step do |i|
  begin
    html = open("#{base_url}?page=#{i}") do |f|
        charset = f.charset
        f.read
    end
  rescue OpenURI::HTTPError
    break
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)
  doc.xpath('//div[@class="table-pg-responsive"]/table[@class="table table-striped"]/tbody').each do |node|
    node.children.select{|t| t.kind_of?(Nokogiri::XML::Element) }.each do |tournament|
      node_list = tournament.children
      key = node_list[1].text + node_list[3].text
      tournament_result[key] ||= []
      results = node_list[5].text.split(' ')
      tournament_result[key] << { date: node_list[1].text, name: node_list[3].text, rank: results[0].to_i, players: results[2].to_i }
    end
  end
end

result_list = tournament_result.values

#p tournament_result
p "純粋回数"
p tournament_result.count
p "エントリ20以上回数"
p entry_20over = result_list.select { |a| a[0][:players] >= 20 }.count
p "総回数"
max_entry = result_list.inject(0) { |r, a| r += a.length }
p max_entry
p "maxリエントリ"
max_count = 0
result_list.each { |a| max_count = a.length if max_count < a.length }
p max_count
result_list.select { |a| a.length == max_count }.each do |tournament|
  p "#{tournament[0][:date]}, #{tournament[0][:name]}"
end

p "ファイナル率(10max想定)"
final_ex_tournament = result_list.select { |a| a.any?{ |t| t[:rank] <= 10 } }
p final_tournament_count = final_ex_tournament.inject(0) { |count, finals| count += finals.count { |entry| entry[:rank] <= 10 } }
p (final_tournament_count / max_entry.to_f) * 100

p "リエントリ無しファイナル率(10max想定)"
final_ex_tournament = result_list.select { |a| a.count == 1 }
p final_tournament_count = final_ex_tournament.inject(0) { |count, finals| count += finals.count { |entry| entry[:rank] <= 10 } }
p (final_tournament_count / tournament_result.count.to_f) * 100

p "エントリ20以上回数ファイナル率(10max想定)"
final_ex_tournament = result_list.select { |a| a[0][:players] >= 20 }
p final_tournament_count = final_ex_tournament.inject(0) { |count, finals| count += finals.count { |entry| entry[:rank] <= 10 } }
p (final_tournament_count / entry_20over.to_f) * 100





