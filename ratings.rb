# file_name = './ml-100k/u.data || u?.base || u?.test'

# The main data set u.data consists of 100,000 rows where each row has 4 tab-separated items:
# user_id
# movie_id
# rating
# timestamp

class Ratings
  ###################################################
  #  contains one of the files of ratings, u.data,  #
  #  or u1.test or u1.base etc. Knows how to read   #
  #  the file while analyzing what it sees.         #
  ###################################################
  def initialize(file_name = nil)
      if(file_name == nil)
        file_name = './ml-100k/u.data'
      end
      data = IO.readlines(file_name)
      @movie_dict = {}    #{movie_id: {user_id, rating}}
      @user_dict = {}     #{user_id: {movie_id: rating}}
      data.each do |line|
          process(line)
      end
      # puts data
      @buddy_dict = {}    # {user_id: buddy_id}
      @user_dict.each do |key, _value|
        @buddy_dict[key] = most_similar(key, 1)[0]
      end
  end

  def user_dict
    return @user_dict
  end

  def movie_dict
    return @movie_dict
  end

  def process(line)
      list = line.split("\t")
      user_id = list[0].to_i
      movie_id = list[1].to_i
      rating = list[2].to_f

      # process @user.dict
      if(!@user_dict.has_key?(user_id))
          @user_dict[user_id] = {}
      end
      @user_dict[user_id][movie_id] = rating

      # process @movie_dict
      if(!@movie_dict.has_key?(movie_id))
          @movie_dict[movie_id] = {}
      end
      @movie_dict[movie_id][user_id] = rating
  end

  ################################################
  # generate a prediction, based on that file,   #
  # of what rating a user would give to a movie. #
  ################################################


  # def predict_buddy(user_id, movie_id)
  #   buddy_map = {}
  #   list = []
  #   @movie_dict[movie_id].each_key do |user_key|
  #     buddy_map[user_key] = similarity(user_key, user_id)
  #   end
  #   buddy_map.sort_by{|key, value| key}.reverse.each do |key, value|
  #     list.push(key)
  #   end
  #   buddy_id = list[0]
  #   return buddy_id
  # end

  # def predict(user_id, movie_id)
  #   # if(!@movie_dict.has_key?(movie_id))
  #   #   return 4
  #   # end
  #   # buddy_id = predict_buddy(user_id, movie_id)
  #   # if(!@movie_dict[movie_id].has_key?(buddy_id))
  #   #   return 4
  #   # end
  #   # return @movie_dict[movie_id][buddy_id]
  #   return 4
  # end

  def predict(user_id, movie_id)
    buddy_id = @buddy_dict[user_id]
    if(!@user_dict[buddy_id].has_key?(movie_id))
      return 4
    end
    return @user_dict[buddy_id][movie_id]
  end


  def popularity(movie_id)
      if(!@movie_dict.has_key?(movie_id))
          return 0
      end
      total = 0.0

      @movie_dict[movie_id].each do |_user_id, rating|
        total += rating
      end
      return (total / @movie_dict[movie_id].length).to_i
  end

  def popularity_list
    res = []
    map = {}
    @movie_dict.each_key do |movie_id|
      map[movie_id] = popularity(movie_id)
    end
    sorted = map.sort_by{|_key, value| value}.reverse
    sorted.each do |key, _value|
      res.push(key)
    end
    return res
  end

## cosine between two rating vectors
  def similarity(user1, user2)
    rating1 = @user_dict[user1]
    rating2 = @user_dict[user2]

    inner_product = 0
    (1..@movie_dict.length).each do |index|
      if(rating1.has_key?(index) && rating2.has_key?(index))
         inner_product += rating1[index] * rating2[index]
      end
    end

    len1 = len2 = 0
    rating1.each_value do |value|
      len1 += (value * value)
    end
    rating2.each_value do |value|
      len2 += (value * value)
    end
    return inner_product / ((len1 ** (1.0 / 2)) * (len2 ** (1.0 / 2)))
  end


  def most_similar(u, len = 10)
    res = []
    if(len < 1 || len > @movie_dict.length)
      return res
    end
    similarities = {}
    @user_dict.each_key do |user_id|
      similarities[user_id] = similarity(u, user_id)
    end
    similarities.sort{|a,b| b[1]<=>a[1]}[1..len].each do |key, _value| # exclude u itself
       res.push(key)
    end
    return res
  end
end

# my_ratings = Ratings.new('./ml-100k/u.data')
#
# # puts my_ratings.popularity_list
# puts my_ratings.most_similar(1)
# puts my_ratings.similarity(1,276)
# puts my_ratings.predict(1,1)
