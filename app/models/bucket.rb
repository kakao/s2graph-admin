class Bucket < ActiveRecord::Base
  belongs_to :experiment
  def ratio
    limits = modular.split("~")
    
    res = limits[1].to_i - limits[0].to_i + 1
    res = 0 if (res == 1)
    res

  end

end
