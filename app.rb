require 'sinatra'
require 'time'
require 'json'

set :bind, '0.0.0.0'
enable :sessions

# -----------------------
# Listas de respostas expandidas
# -----------------------
MOTIVATIONAL_QUOTES = [
  "Acredite em si mesmo! 💪",
  "Você é mais capaz do que imagina! ✨",
  "Não desista, a vitória logo chegará! 🏆",
  "Você é incrível à sua maneira! 🌈",
  "Anime-se! Está um dia lindo! ☀️",
  "Vai na fé! 🙌",
  "Cada pequeno passo conta! 👣",
  "Continue tentando, você vai conseguir! 🌟",
  "A persistência vence qualquer desafio! 🔥",
  "Você é único, nunca se esqueça disso! 💖"
]

CUSTOM_RESPONSES = {
  triste: [
    "Eu sei que você pode estar passando por um momento difícil agora, mas lembre-se: dias nublados também têm sua beleza, e o sol sempre volta a brilhar depois da tempestade. 🌦️ Você é mais forte do que imagina e já superou muitos desafios até aqui. 💪",
    "Às vezes, sentir-se triste é inevitável, mas isso não define quem você é. 🌸 Use esse momento para respirar fundo, acolher seus sentimentos e lembrar que eles vão passar. Você merece encontrar a paz dentro de si mesmo, e ela logo vai chegar. ✨",
    "Eu entendo que a tristeza pode parecer pesada, mas quero que saiba que você não está sozinho. 🤗 Cada lágrima pode regar o solo do seu coração, preparando-o para florescer em algo ainda mais bonito. 🌱",
    "Mesmo que agora as coisas pareçam escuras, nunca se esqueça de que a noite sempre dá lugar ao amanhecer. 🌅 Você tem uma luz dentro de si, e ela nunca se apaga, mesmo quando você não consegue enxergá-la. 🌟",
    "Você pode estar se sentindo frágil, mas lembre-se: até as árvores mais fortes já enfrentaram tempestades. 🌳 Essa fase é passageira, e o que você sente agora não vai te acompanhar para sempre. Continue caminhando, mesmo devagar. 👣"
  ],
  cansado: [
    "Sei que você deve estar exausto, mas não esqueça que descansar também faz parte da jornada. 🛌 Seu corpo e sua mente precisam de pausas para se renovarem, e tudo o que você conquistou até aqui já mostra a sua força. Permita-se recuperar suas energias, sem culpa. 🌿",
    "Você já fez muito até agora, e está tudo bem se precisar desacelerar um pouco. ⚡ Até as máquinas precisam de recarga para continuar funcionando, e você merece esse cuidado. Respire fundo, faça uma pausa e valorize cada pequena vitória que alcançou. ✨",
    "O cansaço pode estar pesando, mas não esqueça que ele é sinal de esforço e dedicação. 💪 Orgulhe-se da sua caminhada até aqui. Aproveite esse momento para relaxar, se hidratar e se permitir ser gentil consigo mesmo. 🍵",
    "Seu corpo e sua mente estão pedindo descanso, e isso não é sinal de fraqueza, mas de sabedoria. 🧘 Lembre-se de que cuidar de si é parte essencial do sucesso. Uma pausa agora pode ser o impulso que você precisa para seguir com ainda mais força depois. 🚀"
  ],
  feliz: [
    "Que alegria ver você assim! 😄 Sua felicidade ilumina não apenas o seu dia, mas também o de quem está ao seu redor. Continue valorizando os pequenos momentos e espalhando essa energia contagiante. O mundo precisa mais do seu sorriso! 🌈",
    "A felicidade que você sente agora é um reflexo da sua força interior e da sua jornada. ✨ Aproveite cada segundo, celebre suas conquistas e compartilhe esse brilho com quem você ama. Sua alegria inspira e transforma. 💖",
    "Sabe o que é lindo? Ver alguém vibrando coisas boas como você está agora. 🌞 A vida fica mais leve quando nos permitimos sentir alegria, e você está mostrando como isso é possível. Continue irradiando essa luz por onde passar! 🌟",
    "É tão bom sentir essa energia positiva vindo de você! 🎉 Essa felicidade é um combustível poderoso para alcançar ainda mais conquistas. Guarde esse momento no coração e lembre-se dele nos dias em que precisar de força extra. ❤️"
  ],
  ansioso: [
    "A ansiedade pode tentar te dominar, mas lembre-se: você tem mais controle do que imagina. 🌬️ Respire fundo, foque no presente e dê um passo de cada vez. Tudo vai se encaixar no momento certo, e você é totalmente capaz de lidar com isso. 🌱",
    "Quando o coração acelerar e os pensamentos ficarem confusos, pare um instante. 🧘 Inspire profundamente, solte devagar e traga sua mente de volta para o agora. Você não precisa resolver tudo de uma vez — cada pequena ação já faz a diferença. 👣",
    "A ansiedade não diminui a sua força, pelo contrário, mostra que você se importa. 💖 Mas não deixe que ela dite seu ritmo. Organize seus pensamentos, escolha uma prioridade e siga com calma. Você consegue! ✨",
    "Mesmo nos momentos de ansiedade, lembre-se de que você já superou situações difíceis antes. ⚡ Essa também vai passar. Acolha seus sentimentos, cuide de si mesmo e confie que dias mais leves estão por vir. 🌈"
  ],
  confuso: [
    "Tudo bem se sentir perdido às vezes, isso faz parte do processo de crescimento. 🌱 Respire fundo, organize suas ideias e escolha um pequeno passo para seguir adiante. Mesmo a menor das ações já traz clareza para o caminho. 👣",
    "Não se cobre por não ter todas as respostas agora. 🌟 Muitas vezes, a confusão é apenas o prelúdio de um grande aprendizado. Tenha paciência, confie no seu instinto e siga em frente, mesmo que devagar. 🚶",
    "A incerteza pode assustar, mas também abre espaço para novas possibilidades. 🌈 Lembre-se de que cada dúvida é um convite para explorar algo novo sobre você e sobre a vida. Você vai encontrar a direção certa no momento certo. ⏳",
    "Quando tudo parecer nebuloso, dê um tempo para respirar e observar. 🌬️ As respostas costumam aparecer quando paramos de forçar. Você já tem dentro de si a força necessária para transformar confusão em clareza. 💡"
  ],
  estressado: [
    "Eu sei que o estresse pode estar pesando, mas tente lembrar que você não precisa carregar tudo sozinho. 🌊 Respire fundo, desacelere e permita-se se desconectar um pouco. Às vezes, uma pausa curta pode mudar completamente sua energia. ✨",
    "O estresse é sinal de que você está dando o seu melhor, mas também de que precisa cuidar de si. 🌿 Que tal ouvir uma música, alongar o corpo ou dar uma breve caminhada? Coisas simples podem transformar o seu dia. 🎵🚶",
    "Respire fundo e solte lentamente. 🌬️ Lembre-se de que nem tudo está sob seu controle, e está tudo bem assim. Foque no que você pode mudar agora e deixe o resto fluir. Sua paz vale mais do que qualquer preocupação. 💖",
    "Cada desafio que causa estresse também traz a oportunidade de mostrar sua resiliência. 💪 Olhe para si mesmo com orgulho, reconheça seu esforço e permita-se descansar quando precisar. Você merece equilíbrio. ⚖️"
  ],
  motivado: [
    "Essa energia que você sente agora é poderosa! 🔥 Use-a como combustível para transformar seus sonhos em realidade. Dê passos firmes em direção ao que deseja e lembre-se: cada pequena ação já é uma vitória. 🚀",
    "A motivação que está dentro de você hoje é um presente precioso. ✨ Canalize essa força para conquistar seus objetivos e inspirar quem está ao seu redor. O que você tem em mente é totalmente possível! 🌈",
    "Continue nesse ritmo, porque sua determinação está transbordando. 💪 Quando estamos motivados, até os maiores desafios parecem menores. Aproveite esse momento e avance com confiança. 🌟",
    "Aproveite essa chama de motivação para dar vida às suas ideias. 🎯 Tudo o que você precisa já está dentro de você, e cada passo dado agora é um investimento no futuro que você deseja construir. 🌻"
  ],
  agradecido: [
    "A gratidão é uma força poderosa que transforma qualquer dia comum em algo extraordinário. 🙏 Continue reconhecendo as pequenas coisas boas ao seu redor, pois é delas que nasce a verdadeira felicidade. ✨",
    "Sinto uma energia incrível ao ver você valorizando as bênçãos da vida. 🌟 Quanto mais gratidão cultivamos, mais motivos encontramos para sorrir. Continue nutrindo esse sentimento lindo dentro de si. 💖",
    "Um coração grato é um coração leve. 🌈 Reconhecer o que você tem agora abre espaço para ainda mais coisas boas chegarem até você. Continue espalhando essa vibração positiva, ela é contagiante! 🌞",
    "A gratidão é como uma chave mágica que abre portas para novas oportunidades. 🗝️ Nunca subestime o poder desse sentimento. Continue praticando, pois ele eleva sua vida em todos os aspectos. 🌻"
  ]
}


DAILY_TIPS = [
  "Beba água! 💧 Um corpo hidratado ajuda na mente.",
  "Dê uma caminhada de 10 minutos, oxigênio para o cérebro! 🚶‍♂️",
  "Escreva seus pensamentos, clareza mental é essencial. 📝",
  "Medite por 5 minutos, respire e sinta o momento. 🧘",
  "Ouça sua música favorita, ela eleva o humor. 🎶",
  "Diga algo positivo para si mesmo hoje! 💖",
  "Planeje o dia de forma leve e flexível. 📅",
  "Faça algo criativo, mesmo que pequeno! 🎨",
  "Sorria para alguém, pequenas gentilezas transformam o dia! 😄",
  "Leia uma frase inspiradora e reflita sobre ela. ✨"
]

# Novas funcionalidades
BREATHING_EXERCISES = [
  "🌬️ Exercício 4-7-8: Inspire por 4 segundos, segure por 7, expire por 8. Repita 3 vezes.",
  "🫁 Respiração quadrada: Inspire 4s → Segure 4s → Expire 4s → Segure 4s. Faça 5 ciclos.",
  "🌊 Respiração do oceano: Inspire profundamente pelo nariz e expire fazendo som 'ahhhh'.",
  "⭐ Respiração das estrelas: Inspire imaginando luz entrando, expire soltando tensões."
]

QUICK_MEDITATIONS = [
  "🧘‍♀️ Feche os olhos e conte de 10 a 1, respirando entre cada número.",
  "🌅 Visualize um lugar calmo e respire profundamente por 2 minutos.",
  "🎵 Concentre-se apenas nos sons ao seu redor por 3 minutos.",
  "💆‍♀️ Relaxe cada parte do corpo, começando pelos pés até a cabeça."
]

GOAL_TEMPLATES = [
  "Hoje vou me focar em: ",
  "Minha prioridade é: ",
  "Quero alcançar: ",
  "Vou dedicar tempo para: "
]

AFFIRMATIONS = [
  "Eu sou capaz de superar qualquer desafio! 💪",
  "Mereço coisas boas e elas estão vindo! ✨",
  "Sou forte, corajoso e resiliente! 🦁",
  "Cada dia me torno uma versão melhor de mim! 🌱",
  "Confio na minha capacidade de tomar boas decisões! 🧠",
  "Sou grato pelas oportunidades que tenho! 🙏",
  "Minha energia positiva atrai coisas boas! 🌟",
  "Aceito os desafios como oportunidades de crescimento! 🚀"
]

MOOD_TRACKER = {}

# -----------------------
# Helpers expandidos
# -----------------------
helpers do
  def system_message(text, type = "normal")
    { name: "Cláudia", msg: text, time: Time.now.strftime("%H:%M"), type: type }
  end

  def user_message(name, text)
    { name: name, msg: text, time: Time.now.strftime("%H:%M"), type: "user" }
  end

  def generate_response(msg)
    sleep rand(1..3) # simula tempo de resposta natural

    msg_down = msg.downcase

    case
    when msg_down.match?(/triste|depressivo|mal|down/)
      CUSTOM_RESPONSES[:triste].sample
    when msg_down.match?(/cansado|exausto|desanimado|tired/)
      CUSTOM_RESPONSES[:cansado].sample
    when msg_down.match?(/feliz|animado|alegre|happy|bem/)
      CUSTOM_RESPONSES[:feliz].sample
    when msg_down.match?(/ansioso|preocupado|nervoso|anxiety/)
      CUSTOM_RESPONSES[:ansioso].sample
    when msg_down.match?(/confuso|perdido|não sei|dúvida/)
      CUSTOM_RESPONSES[:confuso].sample
    when msg_down.match?(/estressado|irritado|raiva|stress/)
      CUSTOM_RESPONSES[:estressado].sample
    when msg_down.match?(/motivado|energizado|determinado/)
      CUSTOM_RESPONSES[:motivado].sample
    when msg_down.match?(/obrigado|obrigada|agradec|grato|grata/)
      CUSTOM_RESPONSES[:agradecido].sample
    else
      MOTIVATIONAL_QUOTES.sample
    end
  end

  def daily_tip
    DAILY_TIPS.sample
  end

  def breathing_exercise
    BREATHING_EXERCISES.sample
  end

  def quick_meditation
    QUICK_MEDITATIONS.sample
  end

  def random_affirmation
    AFFIRMATIONS.sample
  end

  def mood_check_in
    "Como você se sente numa escala de 1-10? 1 sendo muito mal e 10 sendo excelente! 📊"
  end

  def save_mood(user, rating)
    date = Time.now.strftime("%Y-%m-%d")
    MOOD_TRACKER[user] ||= {}
    MOOD_TRACKER[user][date] = rating.to_i
  end

  def get_mood_trend(user)
    return "Ainda não temos dados suficientes! Continue registrando seu humor. 📈" unless MOOD_TRACKER[user]
    
    recent_moods = MOOD_TRACKER[user].values.last(7)
    return "Registre seu humor por mais alguns dias! 📊" if recent_moods.length < 3
    
    avg = recent_moods.sum.to_f / recent_moods.length
    case avg
    when 8..10
      "Seu humor tem estado ótimo! Continue assim! 😄⬆️"
    when 6..7.9
      "Seu humor está numa boa média! 😊➡️"
    when 4..5.9
      "Seu humor tem oscilado. Que tal algumas dicas para melhorar? 😐📈"
    else
      "Percebi que você não tem se sentido muito bem. Vamos trabalhar nisso juntos! 🤗💪"
    end
  end

  def generate_goal_suggestion
    GOAL_TEMPLATES.sample + "[escreva aqui seu objetivo] 🎯"
  end

  def get_encouragement_by_time
    hour = Time.now.hour
    case hour
    when 5..11
      "Bom dia! ☀️ Que tal começar o dia com energia positiva?"
    when 12..17
      "Boa tarde! 🌤️ Como está sendo seu dia? Continue firme!"
    when 18..21
      "Boa noite! 🌅 Hora de relaxar e refletir sobre as conquistas do dia!"
    else
      "Que horas são essas acordado? 🌙 Lembre-se de descansar bem!"
    end
  end
end

# -----------------------
# Rotas expandidas
# -----------------------
get '/' do
  session[:messages] ||= []
  if session[:messages].empty?
    welcome_msg = "Bem-vindo ao Chat Motivacional! #{get_encouragement_by_time} Como você está hoje? 🌟"
    session[:messages] << system_message(welcome_msg)
  end
  @messages = session[:messages].last(100)
  erb :index
end

post '/send' do
  session[:messages] ||= []
  name = params[:name].strip
  msg = params[:msg].strip

  unless name.empty? || msg.empty?
    session[:messages] << user_message(name, msg)
    
    # Detecta comandos especiais
    if msg.downcase.match?(/humor|mood/) && msg.match(/(\d+)/)
      rating = msg.match(/(\d+)/)[1]
      save_mood(name, rating)
      response = "Obrigada por compartilhar! Registrei seu humor como #{rating}/10. #{get_mood_trend(name)}"
    else
      response = generate_response(msg)
    end
    
    session[:messages] << system_message(response)
  end

  redirect '/'
end

get '/daily_tip' do
  session[:messages] ||= []
  tip = daily_tip
  session[:messages] << system_message("💡 Dica do dia: #{tip}", "tip")
  redirect '/'
end

# Novas rotas para funcionalidades expandidas
get '/breathing' do
  session[:messages] ||= []
  exercise = breathing_exercise
  session[:messages] << system_message("🌬️ Exercício de Respiração: #{exercise}", "exercise")
  redirect '/'
end

get '/meditation' do
  session[:messages] ||= []
  meditation = quick_meditation
  session[:messages] << system_message("🧘‍♀️ Meditação Rápida: #{meditation}", "meditation")
  redirect '/'
end

get '/affirmation' do
  session[:messages] ||= []
  affirmation = random_affirmation
  session[:messages] << system_message("✨ Afirmação Positiva: #{affirmation}", "affirmation")
  redirect '/'
end

get '/mood_check' do
  session[:messages] ||= []
  check = mood_check_in
  session[:messages] << system_message(check, "mood")
  redirect '/'
end

get '/mood_trend' do
  session[:messages] ||= []
  name = params[:user] || "Usuario"
  trend = get_mood_trend(name)
  session[:messages] << system_message("📊 Análise do seu humor: #{trend}", "analysis")
  redirect '/'
end

get '/goal' do
  session[:messages] ||= []
  suggestion = generate_goal_suggestion
  session[:messages] << system_message("🎯 Defina uma meta: #{suggestion}", "goal")
  redirect '/'
end

get '/encouragement' do
  session[:messages] ||= []
  encouragement = get_encouragement_by_time
  session[:messages] << system_message(encouragement, "time_based")
  redirect '/'
end

get '/motivation_combo' do
  session[:messages] ||= []
  combo = [
    "🌟 Combo Motivacional:",
    "1. #{random_affirmation}",
    "2. #{daily_tip}",
    "3. #{breathing_exercise}"
  ].join("\n")
  session[:messages] << system_message(combo, "combo")
  redirect '/'
end

get '/stats' do
  session[:messages] ||= []
  total_msgs = session[:messages].select { |m| m[:name] != "Cláudia" }.length
  stats = "📈 Suas estatísticas: #{total_msgs} mensagens enviadas hoje! Continue se expressando!"
  session[:messages] << system_message(stats, "stats")
  redirect '/'
end

# Rota para SOS - ajuda imediata
get '/sos' do
  session[:messages] ||= []
  sos_msg = [
    "🆘 Estou aqui para você! Vamos fazer o seguinte:",
    "1. Respire fundo (4 segundos inspirando, 6 expirando)",
    "2. Beba um copo de água 💧",
    "3. Se possível, saia ao ar livre por 5 minutos 🌱",
    "4. Lembre-se: este momento difícil vai passar! 💪",
    "Você não está sozinho(a)! ❤️"
  ].join("\n")
  session[:messages] << system_message(sos_msg, "sos")
  redirect '/'
end

get '/clear' do
  session[:messages] = []
  redirect '/'
end

# API endpoints para funcionalidades avançadas
get '/api/mood_data' do
  content_type :json
  user = params[:user] || "Usuario"
  (MOOD_TRACKER[user] || {}).to_json
end

post '/api/save_mood' do
  content_type :json
  user = params[:user] || "Usuario"
  rating = params[:rating].to_i
  save_mood(user, rating)
  { success: true, message: "Humor salvo com sucesso!" }.to_json
end