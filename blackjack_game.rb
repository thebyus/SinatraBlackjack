require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

helpers do
	def calculate_total(cards)
		arr = cards.map{|element| element[1]}

		total = 0
		arr.each do |a|
			if a == "ace"
				total +=11
			else
				total += a.to_i == 0 ? 10 : a.to_i
			end
		end

		#correct for Ace's
		arr.select{|element| element == "ace"}.count.times do
			break if total <= 21
			total -= 10
		end

		total
	end

	def card_image(card) #['Hearts', '4']
		suit = card[0]
		value = card[1]

		"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
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
	if params[:player_name].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end

	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
	#create deck and put it in session
	suits = ['hearts', 'clubs', 'diamonds', 'spades']
	values = ['2','3','4','5','6','7','8','9','10','jack','queen','king','ace']
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
	
	player_total =calculate_total(session[:player_cards]) 
	if player_total == 21
			@success = "Blackjack! You win!"
			@show_hit_or_stay = false
	elsif player_total> 21
		@error = "Sorry :( Looks like you have busted!"
		@show_hit_or_stay = false
	end


	erb :game

end

post '/game/player/stay' do
	@success = "You have decided to stay"
	@show_hit_or_stay = false

	erb :game
end