require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

helpers do
	def calculate_total(cards)
		arr = cards.map{|element| element[1]}

		total = 0
		arr.each do |a|
			if a == "Ace"
				total +=11
			else
				total += a.to_i == 0 ? 10 : a.to_i
			end
		end

		#correct for Ace's
		arr.select{|element| element == "Ace"}.count.times do
			break if total <= 21
			total -= 10
		end

		total
	end
end

before do
	@show_hit_or_stay = true
end

get '/home' do
	if session[:player_name]
		redirect '/game'
	else
		redirect '/new_player'
	end
end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
	#create deck and put it in session
	suits = ['Hearts', 'Clubs', 'Diamonds', 'Spades']
	values = ['2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace']
	session[:deck] = suits.product(values).shuffle!
	#	deal cards
	session[:dealer_cards] = []
	session[:player_cards] = []
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop

	erb :game
end


post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	if calculate_total(session[:player_cards]) > 21
		@error = "Sorry :( Looks like you have busted!"
		@show_hit_or_stay =false
	end


	erb :game

end

post '/game/player/stay' do
	@success = "You have decided to stay"
	@show_hit_or_stay = false

	erb :game
end