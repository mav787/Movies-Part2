require "./validator.rb"
class Control
  ######################################################
  # Has one key method, run, which instantiates and    #
  # invokes the other two classes. It’s the top level  #
  # of your program.                                   #
  ######################################################
  def initialize(base_file, test_file)
    ##
    @base_ratings = Ratings.new(base_file)
    @test_ratings = Ratings.new(test_file)

    @validator = Validator.new(@base_ratings, @test_ratings)
  end
  def run()
    @validator.validate
  end
end


test_start = Control.new('./ml-100k/u1.base', './ml-100k/u1.test')
test_start.run
