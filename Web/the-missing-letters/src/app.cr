require "log"
require "jwt"
require "crest"
require "kemal"
require "ecr/macros"
require "http/client"
require "crypto/bcrypt"

Kemal.config.logging = false
Kemal.config.env = "production"
Kemal.config.port = 9091
public_folder "public"
css_target = "style.css"
error_file = "/tmp/error.log"
File.write(error_file, "")

FLAG = "nullctf{secret}"

JWT_SECRET = Random::Secure.hex(32)
JWT_ALGORITHM = JWT::Algorithm::HS256

class User
  property id, username, password_hash

  def initialize(@id : Int32, @username : String, @password : String)
    @password_hash = Crypto::Bcrypt::Password.create(@password, cost: 10)
  end
end

USERS = [
  User.new(1, "admin", Random::Secure.hex(32))
]

def current_user(env)
  token = env.request.cookies["jwt"]?.try(&.value)
  return nil unless token

  begin
    payload, _ = JWT.decode(token, JWT_SECRET, JWT_ALGORITHM)
    user_id = payload["user_id"].as_i
    USERS.find { |u| u.id == user_id }
  rescue
    nil
  end
end

def generate_jwt(user)
  payload = {
    "user_id" => user.id,
    "exp"     => Time.utc.to_unix + 3600
  }
  JWT.encode(payload, JWT_SECRET, JWT_ALGORITHM)
end

before_all do |env|
  csp_policy = <<-POLICY
    default-src 'none';
    script-src 'self' 'unsafe-inline';
    style-src 'self' https://cdn.jsdelivr.net;
    img-src 'self';
    font-src 'self' https://cdn.jsdelivr.net;
    connect-src 'self' ws://localhost:3000;
    form-action 'self';
    frame-ancestors 'none';
    base-uri 'self';
    object-src 'none';
  POLICY

  env.response.headers["Content-Security-Policy"] = csp_policy.gsub(/\s+/, " ").strip
  env.response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
  env.response.headers["X-Content-Type-Options"] = "nosniff"
  env.response.headers["X-Frame-Options"] = "DENY"
  env.response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
end

def check_path(_path)
  allowed_paths = ["/login", "/submit", "/result", "/favicon.ico"]
  allowed_paths.each do |path|
    if _path.starts_with?(path)
      return false
    end
  end

  return true
end

before_all do |env|
  if !current_user(env) && check_path(env.request.path)
    env.redirect "/login"
  end
end

get "/" do
  page_title = "The Missing Letters"
  content = ECR.render("views/index.ecr")
  ECR.render("views/layout.ecr")
end

get "/login" do |env|
  page_title = "The Missing Letters | Login Panel"
  content = ECR.render("views/login.ecr")
  ECR.render("views/layout.ecr")
end

post "/login" do |env|
  username = env.params.body["username"]?.to_s.strip
  password = env.params.body["password"]?.to_s.strip

  if username.empty? || password.empty?
    "Invalid login."
  else
    user = USERS.find { |u| u.username == username }

    if user && password && user.password_hash.verify(password)
      jwt = generate_jwt(user)
      env.response.cookies << HTTP::Cookie.new("jwt", jwt, http_only: true)
      env.redirect "/"
    else
      env.redirect "/login?error=invalid_credentials"
    end
  end
end

get "/logout" do |env|
  env.response.cookies << HTTP::Cookie.new("jwt", "", expires: Time.utc(1990, 1, 1))
  env.redirect "/login"
end

get "/check" do |env|
  submitted_value = env.params.query["f"]?.to_s.strip
  if submitted_value.empty?
    "No value provided."
  else
    message = FLAG.starts_with?(submitted_value) ? "Congratulations!" : "Nope!"
    check_value = env.params.query["status"]?.to_s.strip
    if check_value.empty?
      env.redirect "/result?message=#{URI.encode_www_form(message)}"
    else
     env.redirect "/result?message=#{URI.encode_www_form(message)}&status=#{URI.encode_www_form(check_value)}"
    end
  end
end

get "/result" do
  page_title = "The Missing Letters | Result"
  content = ECR.render("views/result.ecr")
  ECR.render("views/layout.ecr")
end

get "/submit" do
  page_title = "The Missing Letters | Submit Url to Admin"
  content = ECR.render("views/submit.ecr")
  ECR.render("views/layout.ecr")
end


def is_localhost(url)
  uri = URI.parse(url)
  return false if url.includes?('\n') || url.includes?('\r')

  host = uri.host
  return false unless host

  return true if host.downcase == "localhost"

  begin
    ip = Socket::IPAddress.new(host, 0)
    ip.loopback?
  rescue Socket::Error
    false
  end
rescue URI::Error
  false
end

post "/submit" do |env|
  submitted_value = env.params.body["url"]?.to_s.strip
  if submitted_value.empty?
    "No url provided."
  else
    if is_localhost(submitted_value)
      begin
        user = USERS[0]
        jwt = generate_jwt(user)
        response = Crest.get(submitted_value, cookies: {"jwt" => jwt})
      rescue ex
        log_content = File.read(error_file)
        File.write(error_file, "#{log_content}\n#{ex.message}")
      ensure
        message = "Admin will check your url! 👀"
        env.redirect "/result?message=#{URI.encode_www_form(message)}"
      end
    else
      "Invalid url provided."
    end
  end
end

error 500 do
  "Internal server error 😭"
end

error 404 do
  "Not found."
end

error 403 do
  "Nope!"
end

Kemal.run
