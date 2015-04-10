class PublicAuthRequestData
  attr_accessor :entity, :expires_at, :current_user_token, :subdomain, :context

  def initialize(entity:nil, expires_at:nil, current_user_token:nil, subdomain:nil, context:nil)
    @entropy = SecureRandom.hex((4..16).to_a.sample)
    @entity = entity
    @expires_at = expires_at
    @current_user_token = current_user_token
    @subdomain = subdomain
    @context = context
  end

  def to_h
   Hash[*instance_variables.map { |v|
     [v.to_s.gsub(/@/, "").to_sym, instance_variable_get(v)]
    }.flatten]
  end

  def hash_keys
    self.to_h.keys.reject { |k| k == :entropy }
  end

  def to_s
    crypttext = self.class.encryptor.encrypt(JSON.generate(self.to_h))
    Base64.encode64(crypttext).tr("+/=", "-_~").tr("\n", "")
  end
  alias_method :encrypt, :to_s

  def self.encryptor
    Mcrypt.new(:rijndael_256, :ecb, ENV["ENCRYPTION_KEY"], nil, :zeros)
  end

  def self.from_string(data)
    raise "Invalid authorization data" unless data.respond_to?(:to_str)
    data = data.to_str

    block_size = 4
    mod4 = data.size % block_size
    unless mod4 == 0
      data += ("=".to_s * (block_size - mod4))
    end

    begin
      crypttext = Base64.decode64(data.tr("-_~", "+/="))
      plaintext = encryptor.decrypt(crypttext)
      self.from_hash(JSON.parse(plaintext, symbolize_name: true))
    rescue Mcrypt::RuntimeError => e
      raise RuntimeError.new "The string data is invalid [#{e.message}]"
    end
  end

  def self.from_hash(hash)
    data = self.new
    data.hash_keys.each { |key| data.instance_variable_set("@#{key}", hash.fetch(key) { hash[key.to_s] }) }
    data
  end

  class << self
    alias_method :decrypt, :from_string
  end
end
