require 'openssl'
require 'base64'

module Obfuscable
  extend ActiveSupport::Concern

  included do
    def self.decrypt(value)
      new.decrypt(value)
    end
  end

  def cipher
    OpenSSL::Cipher::Cipher.new('aes-256-cbc')
  end

  def cipher_key
    'apidae'
  end

  def decrypt(value)
    c = cipher.decrypt
    c.key = Digest::SHA256.digest(cipher_key)
    c.update(Base64.urlsafe_decode64(value.to_s)) + c.final
  end

  def encrypt(value)
    c = cipher.encrypt
    c.key = Digest::SHA256.digest(cipher_key)
    Base64.urlsafe_encode64(c.update(value.to_s) + c.final, padding: false)
  end
end