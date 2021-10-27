require 'mysql2'
require 'bundler/setup'

#Метод для случая когда в строке только запятая
def only_comma(sentence)
    sentence1, sentence2 = sentence.split(',')
    ready = "#{sentence1.downcase} (#{sentence2.strip})"
    return ready
end

#Если имеется сокращения: Twp, Hwy, Highway highway  and Hwy hwy
def transformation sentence
    example = {"Twp" => "Township", "Hwy" => "Highway", "Highway highway" => "Highway", "Hwy hwy" => "Highway" }
    ready = sentence.strip
    example.each do |key, value|
        if sentence.include?(key)
            ready = sentence.gsub(key, value)
       end 
    end
    return ready
end

#Если запятая и слеш
def slash_and_comma(sentence)
    sentence1, sentence2 = sentence.split('/')
    sentence_part_1, sentence_part_2 = sentence1.split(',')

    sentence1 = "#{sentence_part_1.downcase} (#{sentence_part_2.strip})"
    ready = sentence2 + ' ' + sentence1
    return ready
end

#Если только слеш
def slash_only(sentence)
    sentence1 = sentence.split('/')
    nachalo = sentence1[-1]

#Проверим на дублирование слов
    first_words_parts = nachalo.split(' ')
    second_words_parts = sentence1[0].split(' ')

    if first_words_parts.last.downcase == second_words_parts.first.downcase
        second_words_parts.delete_at(0)
        sentence1[0] = second_words_parts.join(' ')
        sentence1.delete_at(-1)
        ready = first_words_parts.join(' ') + ' ' + sentence1.join(' and ').downcase
    else
        sentence1.delete_at(-1)
        ready = nachalo + ' ' + sentence1.join(' ').downcase
    end
    ready.strip
end



#Получаем готовую строку
def ready_string(sentence)
    #Удалим точки есди перед ними нет цифр
    ready = sentence.gsub(/(?<=[^\d])\./,"")
                   .gsub(/,\//, '/') #Форматирование неправильной строки State's Attorney,/Greene County
    ready = transformation(ready)

    if ready.include?('/') && ready.include?(',')
        ready = slash_and_comma(ready)
    elsif ready.include?('/')
        ready = slash_only(ready)
    elsif ready.include?(',')
        ready = only_comma(ready)
    elsif ready.empty?
        ready = ''
    else
        ready = ready.downcase
    end
    ready.gsub(/^us\s/, "US ")
end

client = Mysql2::Client.new(:host => "db09", :username => "loki", :password => "v4WmZip2K67J6Iq7NXC", :database => "applicant_tests")

results = client.query('SELECT id, candidate_office_name FROM hle_dev_test_alexey_glazkov')

results.each do |row|
    defolt = row["candidate_office_name"]
    finish = ready_string(defolt)
    sentence = finish.empty? ? '' : "The candidate is running for the #{finish} office." 
    parcel = "UPDATE hle_dev_test_alexey_glazkov SET clean_name = '#{client.escape(finish)}', sentence = '#{client.escape(sentence)}' WHERE id = #{row['id']}"
    client.query(parcel)
end










