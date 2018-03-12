class Proxy < ActiveRecord::Base

  TYPE = {
    :unknown => 1,
    :http => 2,
    :https => 3,
    :socks4 => 4,
    :socks5 => 5,
  }

  include AASM
  aasm :column => 'status' do
    state :invalid, :intial => true
    state :use_valid

    event :set_valid do
      transitions :to => :use_valid
    end

    event :set_invalid do
      transitions :to => :invalid
    end
  end
end
