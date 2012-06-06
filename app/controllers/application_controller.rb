class ApplicationController < ActionController::Base
  protect_from_forgery

  def exec(code, version, filename = 'line')
    data = {}
    data[:c] = code 
    data[:v] = version
    data[:name] = filename
    res = ''
    Net::HTTP.start(INTERPRETER[:host], INTERPRETER[:port]) do |h|
      req = Net::HTTP::Post.new(INTERPRETER[:uri])
      req.set_form_data(data, '&')
      res = h.request(req).body
    end
    res
  end
end
