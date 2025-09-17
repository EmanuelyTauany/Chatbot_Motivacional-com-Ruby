require 'sinatra'

set :bind, '0.0.0.0'
enable :sessions

MOTIVATIONAL_QUOTES = [ 
  "Acredite em si mesmo!",
  "Você é mais capaz do que imagina.",
  "Não desista, a vitória logo chegará!",
  "Você é incrível à sua maneira.",
  "Você é vitorioso.",
  "Anime-se! Está um dia lindo!",
  "Vai na fé!"
]

CUSTOM_RESPONSES = {
  triste: [
    "Não desanime , até os dias nublados têm seu valor!",
    "Você é forte, e esse momento vai passar. ",
    "Respira fundo, você vai superar isso. "
  ],
  cansado: [
    "Descansar também faz parte da jornada. ",
    "Você já fez muito, permita-se recarregar as energias. ⚡",
    "Respira, toma um café ☕ e continua aos poucos!"
  ],
  feliz: [
    "Que bom te ver assim! Continue espalhando essa energia ",
    "A felicidade é contagiante, obrigado por compartilhar! ",
    "Mantenha esse sorriso, ele ilumina o mundo "
  ]
}

helpers do
  def system_message(text)
    { name: "Cláudia 🤖", msg: text }
  end
end


get '/' do
  session[:messages] ||= []

  if session[:messages].empty?
    session[:messages] << system_message("Bem-vindo ao Chat Motivacional! Como você está hoje?")
  end

  @messages = session[:messages].last(20)
  erb :index
end

post '/send' do
  session[:messages] ||= []
  name = params[:name].strip
  msg = params[:msg].strip.downcase

  unless name.empty? || msg.empty?

    session[:messages] << { name: name, msg: msg }

    response = nil

    if msg.include?("triste") || msg.include?("depressivo") || msg.include?("mal")
      response = CUSTOM_RESPONSES[:triste].sample
    elsif msg.include?("cansado") || msg.include?("exausto") || msg.include?("desanimado")
      response = CUSTOM_RESPONSES[:cansado].sample
    elsif msg.include?("feliz") || msg.include?("animado") || msg.include?("alegre")
      response = CUSTOM_RESPONSES[:feliz].sample
    else
      response = MOTIVATIONAL_QUOTES.sample
    end

    session[:messages] << system_message(response)
  end

  redirect '/'
end
