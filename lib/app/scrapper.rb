require 'open-uri'
require 'pp'

class Ville
	attr_accessor :mairie

	#initialisation de l'objet
	def initialize
		puts "création array de base..."
		@mairie = scrap
		puts "creation du fichier spreadshee..."
		save_as_spreadshee(hachierMode)
		puts "creation du fichier CSV..."
		save_as_csv(hachierMode)
		puts "creation du fichier json..."
		save_as_JSON(hachierMode)
	end

	#adaptation de l'array de base pour les saves
	def hachierMode
		a = @mairie
		return a.reduce :merge
	end

	#save dans spreadshee
	def save_as_spreadshee(hachier_google)
		i = 0
		session = GoogleDrive::Session.from_config("config.json")
		ws = session.spreadsheet_by_key("1w-yHyu13NN6FZOoVeFUwNgMHYmUqEw8LsCOynzZkEh4").worksheets[0]

		hachier_google.each {|key, value|i = i + 1 
			ws[i,1]=("#{key}") 
			ws[i,2]=("#{value}")}
		ws.save
	end

	#save dans fichier.csv
	def save_as_csv(hachier_csv)
		a = []
		i = 0
		File.open("db/emails_csv.csv", "w") do |f|
			hachier_csv.each {|key, value| i = i + 1 
				a << ("#{i},#{key},#{value}\n")}
 		 	f.write(a.flatten.join)
		end
	end

	#save dans fichier.json
	def save_as_JSON(hachier_json)
		File.open("db/emails_jeson.json","w") do |f|
			hachier_json.each {|key, value| f.write("#{key} => #{value}".to_json+"\n")}
		end
	end

	# scrap du site : http://annuaire-des-mairies.com/val-d-oise.html
	def scrap
		def get_townhall_email(townhall_url)
			page = Nokogiri::HTML(open(townhall_url))
			email = page.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').text

			if email.size < 1
				email = "nill"
			end
			return email
		end

		def get_townhall_urls
			i = 0
			page = Nokogiri::HTML(open('http://annuaire-des-mairies.com/val-d-oise.html'))
			array_ville = []
			array_mail = []
			hachier = {}
			array = []
			ville = page.xpath('//a[@class="lientxt"]')

			ville.each do |a|
		      	array_ville[i] = a['href'][1..-1]
		      	array_mail = get_townhall_email("http://annuaire-des-mairies.com#{array_ville[i].downcase}")
		      	hachier = {}
		      	hachier[a.text] = array_mail
		      	array[i] = hachier
		      	i = i + 1
		      	puts hachier
		    end
		    return array
		end
		return get_townhall_urls
	end
end
