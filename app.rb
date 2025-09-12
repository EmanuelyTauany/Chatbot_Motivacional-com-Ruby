require 'sinatra'

set :bind, '0.0.0.0'
enable :sessions



MOTIVATIONAL_QUOTES = [ 
    "Acredite em si mesmo!",
    "Você é mais capaz do que imagina.",
    "Não desista, a vitória logo chegará!",
    "Você é incrivel à sua maneira.",
    "Você é vitorioso.",
    "Anime-se! Está um dia lindo!",
    "Vai na fé!"
]

helpers do
    def system_message(text)
        { name: "Cláudia", msg: text}

    end
end

get '/' do
    session[:messages] ||= []
    @messages = session[:messages].last(20)
    erb :index
end

post '/send' do
    session[:messages] ||= []
    name = params[:name].strip
    msg = params[:msg].strip

    unless name.empty? || msg.empty?
    if msg == "/inspira"
        quote = MOTIVATIONAL_QUOTES.sample
        session[:messages] << { name: name, msg: msg }
        session[:messages] << system_message(quote)

      
        
    else
        session[:messages]<< { name: name, msg: msg }
    end
  end
    
    redirect '/'
end