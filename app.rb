require 'mysql2'

#hh = {name: "Village Clerk/East Hazel Crest", name: "Mayor/Posen", name: "School Board Rep", name:  "Twp Hwy Commissioner/Grafton Twp",
 #   name: "County Recorder/Bond County", name: "County Sheriff/Kankakee County", name: "State Representative 13th District",
 #   name: "Judge, Resident Circuit Court/Shelby Cou"}

#Метод для случая когда в строке только запятая
def only_comma sentence
    sentence1 = sentence.split(',')
    sentence2 = sentence.split(',')
    ready = "#{sentence1.downcase} (#{sentence2.strip})"
    return ready
end

#Если запятая и слеш
def slash_and_comma sentence
    sentence1 = sentence.split(',')
    sentence2 = sentence.split(',')

    sentence_part_1 = sentence1.split(',')
    sentence_part_2 = sentence1.split(',')

    sentence1 = "#{sentence_part_1.downcase} #{sentence_part_2.strip})"
    ready = sentence2 + ' ' + sentence1
    return ready
end

#Если только слеш
def slash_only sentence
    sentence1 = sentence.split('/')
    nachalo = sentence1.last

    ready = nachalo + ' ' + sentence1.join(' ').downcase
    return ready.strip
end

#Если имеется сокращения: Twp, Hwy, Highway highway  and Hwy hwy
def transformation sentence
    example = {"Twp" => "Township", "Hwy" => "Highway", "Highway highway" => "Highway", "Hwy hwy" => "Highway" }
    ready = sentence.strip
    example.each do |key, value|
        if sentence.include?(key)
            ready = sentence.gsub!(key, value)
       end 
    end
    return ready
end

#Получаем готовую строку
def ready_string name
    ready = transformation name

    if ready.include?('/') && ready.include?(',')
        ready = slash_and_comma ready
    elsif ready.include?('/')
        ready = slash_only ready
    elsif ready.include?(',')
        ready = only_comma ready
    end
    return ready
end

client = Mysql2::Client.new(:host => "db09", :username => "loki", :password => "v4WmZip2K67J6Iq7NXC", :database => "applicant_tests.hle_dev_test_alexey_glazkov")

results = client.query('SELECT id, candidate_office_name FROM hle_dev_test_alexey_glazkov')

results.each do |row|
    defolt = row["candidate_office_name"]
    finish = ready_string defolt
    sentence = "The candidate is running for the #{finish} office." 
    parcel = "UPDATE applicant_tests SET clean_name = '#{client.escape(finish)}', sentence = '#{client.escape(sentence)}' WHERE id = #{row['id']}"
    client.query parcel
end










