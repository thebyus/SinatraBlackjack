require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

BLACKJACK = 21
DEALER_STAY = 17
INITIAL_POT = 250

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
			break if total <= BLACKJACK
			total -= 10
		end

		total
	end

	def card_image(card) #['Hearts', '4']
		suit = card[0]
		value = card[1]

		"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
	end

	def winner!(msg)
		@success = "<strong>Congratulations, you win!</strong> #{msg}"
		@show_hit_or_stay = false
		@play_again = true
		session[:player_pot] = session[:player_pot] + session[:player_bet]
	end

	def loser!(msg)
		@error = "<strong>You lose.</strong> #{msg}"
		@show_hit_or_stay = false
		@play_again = true
		session[:player_pot] = session[:player_pot] - session[:player_bet]

	end

	def tie!(msg)
		@success = "<strong>It's a tie!</strong> #{msg}"
		@show_hit_or_stay = false
		@play_again = true
		session[:player_pot] = session[:player_pot]

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
	session[:player_pot] = INITIAL_POT
	erb :new_player
end

post '/new_player' do
	if params[:player_name].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end

	session[:player_name] = params[:player_name]
	redirect '/bet'
end

get '/bet' do
	session[:player_bet] = nil
	erb :bet
end

post '/bet' do
	if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
		@error = "You must make a wager."
		halt erb(:bet)
	elsif params[:bet_amount].to_i > session[:player_pot]
		@error = "Bets cannot be larger than what you currently have in your wallet. You currently have #{session[:player]} left. Please bet again."
		halt erb(:bet)
	else
		session[:player_bet] = params[:bet_amount].to_i
		redirect '/game'
	end
		
end


get '/game' do
session[:turn] = session[:player_name]
#@dealer_turn = false

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
	if player_total == BLACKJACK
			winner!("You hit Blackjack!")
	elsif player_total> BLACKJACK
		loser!("You have busted with a total of #{player_total}.")
	end
	erb :game
end

post '/game/player/stay' do
	@success = "You have decided to stay"
	@show_hit_or_stay = false

	redirect '/game/dealer'
end

get '/game/dealer' do
	session[:turn] = "dealer"
	#@dealer_turn = true
	@show_hit_or_stay = false

	dealer_total = calculate_total(session[:dealer_cards])

	if dealer_total == BLACKJACK
		loser!("The Dealer has hit Blackjack.")
	elsif dealer_total > BLACKJACK
		winner!("The Dealer has busted with a total of #{dealer_total}.")
	elsif dealer_total >= DEALER_STAY
		#dealer stays
		redirect '/game/compare'
	else
		#dealer_hit
		@show_dealer_hit = true
	end	
	erb :game
end

post '/game/dealer/hit' do
	session[:dealer_cards]<< session[:deck].pop
	redirect '/game/dealer'
end

get '/game/compare' do
	player_total = calculate_total(session[:player_cards])
	dealer_total = calculate_total(session[:dealer_cards])

	if player_total > dealer_total
		#@success = "Congratulations. You win!"
		winner!("You have #{player_total} which beats the Dealer's #{dealer_total}.")
	elsif player_total < dealer_total
		#@error = "Sorry, you lose. The Dealer had #{dealer_total}!"
		loser!("The Dealer has #{dealer_total} which beats your #{player_total}.")
	else
		#@success = "It's a tie!"
		tie!("You and the Dealer both have #{player_total}.")
	end

	erb :game
end

get '/game_over' do
	erb :game_over
end