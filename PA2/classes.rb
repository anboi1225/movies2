class MovieData
#receive the file path and the training/test set name
  def initialize(path, name)
    @path = path
    @name = name
    @all = path + "/ml-100k/u.data"
    @training = path + "/ml-100k/" + name + ".base"
    @test = path + "/ml-100k/" + name + ".test"
  end
#list the rating that user u gives to movie m
  def rating(u, m)
    rating = 0
    file = open(@training)
    file.each_line do |line|
      attrs = line.split
      uid = attrs[0].to_i
      mid = attrs[1].to_i
      if uid == u && mid == m
        return attrs[2].to_i
      end
    end
    return rating
  end
#make a prediction of the rating which user u would give to movie m
  def predict(u, m)
    #prating = 0.0
    file = open(@training)
    avgur = 0.0
    ucount = 0
    avgmr = 0.0
    mcount = 0
    file.each_line do |line|
      attrs = line.split
      uid = attrs[0].to_i
      mid = attrs[1].to_i
      rating = attrs[2].to_i
      if uid == u
        ucount = ucount + 1
        avgur = avgur + rating
      end
      if mid == m
        mcount = mcount + 1
        avgmr = avgmr + rating
      end
    end

    avgur = avgur / ucount
    avgmr = avgmr / mcount

    prating = (0.1 * avgur + 0.9 * avgmr).round(1)

    return prating

  end

#list all movies that user u watched
  def movies(u)
    movie_list = []
    file = open(@all)
    file.each_line do |line|
      attrs = line.split
      uid = attrs[0].to_i
      mid = attrs[1].to_i
      if uid == u
        movie_list.push(mid)
      end
    end
    return movie_list
  end
#list all users that have watched movie m
  def viewers(m)
    viewer_list = []
    file = open(@all)
    file.each_line do |line|
      attrs = line.split
      uid = attrs[0].to_i
      mid = attrs[1].to_i
      if mid == m
        viewer_list.push(uid)
      end
    end
    return viewer_list
  end
#run the test of k lines of the test set
  def run_test(k = -1)
    file = open(@test)
    t = MovieTest.new()
    if k == -1
      file.each_line do |line|
        attrs = line.split
        uid = attrs[0].to_i
        mid = attrs[1].to_i
        rating = attrs[2].to_i
        prating = predict(uid, mid)
        t.predictions.push([uid, mid, rating, prating])
        difference = (rating - prating).abs
        t.difference.push(difference)
      end
    else
      (0..k-1).each do
        line = file.readline
        attrs = line.split
        uid = attrs[0].to_i
        mid = attrs[1].to_i
        rating = attrs[2].to_i
        prating = predict(uid, mid)
        t.predictions.push([uid, mid, rating, prating])
        difference = (rating - prating).abs
        t.difference.push(difference)
      end
    end

    return t
  end



end


class MovieTest
  attr_accessor :predictions, :difference
#declare some instance variables
  def initialize()
    @predictions = []
    @difference = []
    @mean = -1
  end
#return the mean error of the predictions
  def mean()
    sum = 0
    @difference.each do |item|
      sum += item
    end
    @mean = sum / @difference.length
    return @mean
  end
#return the standard deviation of the error
  def stddev()
    if mean == -1
      mean()
    end

    sum = 0
    @difference.each do |item|
      sum += (item - @mean) ** 2
    end

    stddev = (sum / difference.length) ** 0.5

    return stddev
  end
#return the root mean squared error
  def rms()
    sum = 0
    difference.each do |item|
      sum += item ** 2
    end

    rms = (sum / difference.length) ** 0.5

    return rms
  end
#return the prediction list in form of [user, movie, rating, predict_rating]
  def to_a()
    return @predictions
  end
end

#z = MovieData.new("/home/boyang/Dropbox/cosi166b_ban/movies-1", "u1")
#puts z.rating(1,7)
#puts z.movies(196)
#puts z.viewers(377)
#puts z.predict(406,318)

#puts z.run_test(100).mean()
#puts z.run_test(100).stddev()
#puts z.run_test(100).rms()
