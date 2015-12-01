module ModelLabel
  class ApplicationController < ActionController::Base
    layout "model_label/application"

    if defined? PlayAuth
      helper PlayAuth::SessionsHelper
    end
  end
end