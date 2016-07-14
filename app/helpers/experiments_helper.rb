module ExperimentsHelper

  # https://gist.github.com/gareth/1349891
  def self.normdist(x, mean, std, cumulative)
    if cumulative
      phi_around x, mean, std
    else
      tmp = 1/((Math.sqrt(2*Math::PI)*std))
      tmp * Math.exp(-0.5 * ((x-mean)/std ** 2))
    end
  end

  # fractional error less than 1.2 * 10 ^ -7.
  def self.erf(z)
    t = 1.0 / (1.0 + 0.5 * z.abs);

    # use Horner's method
    ans = 1 - t * Math.exp(-z*z - 1.26551223 + t * (1.00002368 + t * (0.37409196 +
        t * (0.09678418 + t * (-0.18628806 + t * (0.27886807 + t * (-1.13520398 +
            t * (1.48851587 + t * (-0.82215223 + t * (0.17087277))))))))))

    z >= 0 ? ans : -ans
  end

  # cumulative normal distribution
  def self.phi(z)
    return 0.5 * (1.0 + erf(z / (Math.sqrt(2.0))));
  end

  # cumulative normal distribution with mean mu and std deviation sigma
  def self.phi_around(z, mu, sigma)
    return phi((z - mu) / sigma);
  end

end
