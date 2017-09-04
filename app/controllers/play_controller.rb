require 'open-uri'
require 'json'

class PlayController < ApplicationController
  def game
  	# @start_time = Time.now
  	# @player = params[:my_game]
  	@grid = generate_grid(10).join(" ")

  end

  # define all the variables through the following steps
  # get the attempt from the params
  # pas the start_time and the grid through hidden fields also in the params
  # then grab start_time and grid from the params as well
  # make sure everything is in the right format (Time class, array)

  def score
  	@end_time = Time.now
  	@attempt = params[:my_game]
  	@start_time = params[:start_time]
  	@grid1 = params[:grid]
  	# raise
  	@result = run_game(@attempt, @grid1, @start_time.to_i, @end_time.to_i)
  end

private 

def generate_grid(grid_size)
  Array.new(grid_size) { ('A'..'Z').to_a.sample }
end

def included?(guess, grid)
  guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time - start_time }

  score_and_message = score_and_message(attempt, grid, result[:time])
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last

  result
end

def score_and_message(attempt, grid, time)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end

def english_word?(word)
  response = open("https://wagon-dictionary.herokuapp.com/#{word}")
  json = JSON.parse(response.read)
  return json['found']
end

end
