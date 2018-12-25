class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
  def hello
    render html: "hello, world!"
  end
  def dat
    render html: "Pham Ba Dat"
  end
end
