require "./ratings.rb"
class Validator
  ######################################################
  # Takes two instances of Ratings, one representing   #
  #  a base set and the other representing a test set. #
  ######################################################
  def initialize(base_ratings, test_ratings)
    @base = base_ratings    # Ratings.new(file_name)
    @test = test_ratings

    @base_user = base_ratings.user_dict
    @base_movie = base_ratings.movie_dict

    @test_user = test_ratings.user_dict     #{user_id: {movie_id: rating}}
    @test_movie = test_ratings.movie_dict   #{movie_id: {user_id, rating}}
  end

  ######################################################
  #  runs through all the entries in the test set and  #
  #  see what ratings would be predicted vs. which     #
  #  ones were given. Compute statistics about the     #
  #  prediction: how many predictions were exact,      #
  #  off by one, etc. Also the mean and stdev of       #
  #  the difference between the two.                   #
  ######################################################
  def validate
    ans = []
    predictions = []
    errs = []

    count0 = count1 = count2 = count3 = count4 = 0
    sum = 0.0
    stdev = 0.0
    @test_user.each do |user_id, value|
      value.each do |movie_id, rating|
        ans.push(rating)
        predict = @base.predict(user_id, movie_id)
        predictions.push(predict)
        err = (predict - rating).abs
        errs.push(err)
        sum += err
        if(err == 0)
          count0 += 1
        elsif err == 1
          count1 += 1
        elsif err == 2
          count2 += 1
        elsif err == 3
          count3 += 1
        elsif err == 4
          count4 += 1
        end
      end
    end

    puts "There are #{count0} exact predicts."
    puts "There are #{count1} predicts off by 1."
    puts "There are #{count2} predicts off by 2."
    puts "There are #{count3} predicts off by 3."
    puts "There are #{count4} predicts off by 4."

    mean = sum / errs.length
    errs.each do |err|
      stdev += (err - mean) ** 2
    end
    stdev = (stdev / errs.length) ** 0.5
    puts "The mean is #{mean}."
    puts "And the stdev is #{stdev}."
  end
end

# base_rating = Ratings.new('./ml-100k/u1.base')
# test_rating = Ratings.new('./ml-100k/u1.test')
# validator = Validator.new(base_rating, test_rating)
# validator.validate
