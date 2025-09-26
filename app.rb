require 'sinatra'
require 'time'
require 'json'

set :bind, '0.0.0.0'
enable :sessions

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
  suicida: [
    "🆘 PARE um momento. Sua vida tem valor imenso, mesmo que agora você não consiga ver isso. LIGUE AGORA para o CVV: 188 (gratuito, 24h). Você não está sozinho(a). 💙",
    "🚨 Eu me importo com você e sua vida é preciosa! CVV: 188 ou chat em cvv.org.br. Por favor, dê uma chance para as coisas melhorarem. Você merece viver! 🌟",
    "💙 Seu sofrimento é real, mas sua vida tem um valor que vai muito além desse momento de dor. Converse com alguém: CVV 188, CAPS da sua cidade, ou vá ao hospital mais próximo. Você é importante! 🤗",
    "🆘 URGENTE: Se você está pensando em se machucar, procure ajuda AGORA! CVV: 188, SAMU: 192, ou pronto-socorro. Sua vida importa mais do que você imagina. 💪❤️"
  ],
  autolesao: [
    "💔 Eu vejo sua dor e ela é real. Mas machucar seu corpo não vai curar a dor emocional. Tente alternativas: apertar gelo, desenhar na pele com caneta vermelha, ou gritar no travesseiro. CVV: 188 🤗",
    "🩹 Entendo que a dor física às vezes parece aliviar a emocional, mas você merece cuidado e carinho. Converse com alguém de confiança ou ligue para o CVV: 188. 💙",
    "⚠️ Se machucar não resolve a causa da sua dor, apenas adiciona mais sofrimento. Experimente exercício físico intenso, banho frio/quente, ou escrever tudo que sente. Procure ajuda: CVV 188 🌱",
    "🛡️ Seu corpo é seu templo. CAPS, psicólogos e o CVV (188) existem para te apoiar. Você não precisa passar por isso sozinho(a)! 💪✨"
  ],
  desesperanca: [
    "🌅 Eu sei que agora tudo parece sem saída, mas a desesperança é como um nevoeiro - parece densa e eterna, mas sempre se dissipa. Você já sobreviveu a 100% dos seus piores dias até agora. 💪",
    "💎 Mesmo no fundo do poço, existe a possibilidade de encontrar diamantes. Mudanças acontecem quando menos esperamos. Procure ajuda! 🤗",
    "🔥 A esperança não morreu, ela apenas está dormindo dentro de você. Converse com alguém: amigo, família, CVV (188), ou profissional. Pequenos passos levam a grandes mudanças! 👣✨",
    "🌱 Dentro de você existe uma semente de possibilidades infinitas. Procure ajuda e deixe alguém te ajudar a regar essa semente. 🌸"
  ],
  solidao: [
    "🤗 A solidão dói, eu entendo. Mas saiba que existem pessoas que se importam com você. Comece pequeno: mande mensagem, participe de grupos ou ligue para CVV (188). 💙",
    "👥 Sentir-se sozinho(a) não significa que você está só. Voluntariado, grupos de apoio, comunidades online... encontre sua tribo! 🌟",
    "💌 Sua presença faz diferença no mundo. Tente se conectar: escrever para um amigo, atividades locais ou grupos com interesses em comum. ✨",
    "🏠 A solidão é um sentimento, não um fato permanente. CVV (188), redes sociais positivas, ou cuidar de uma planta ajudam a se reconectar. 🌱"
  ],
  cansado: [
    "Sei que você deve estar exausto, mas descansar faz parte da jornada. 🛌 Seu corpo e mente precisam de pausas para se renovarem. 🌿",
    "Você já fez muito, está tudo bem desacelerar. ⚡ Respire fundo, faça uma pausa e valorize cada pequena vitória. ✨",
    "O cansaço é sinal de esforço. 💪 Aproveite para relaxar, se hidratar e ser gentil consigo mesmo. 🍵",
    "Seu corpo e mente pedem descanso, isso é sabedoria. 🧘 Uma pausa agora é impulso para seguir com mais força depois. 🚀"
  ],
  feliz: [
    "Que alegria ver você assim! 😄 Continue valorizando pequenos momentos e espalhando energia positiva. 🌈",
    "A felicidade que você sente reflete sua força interior. ✨ Celebre conquistas e compartilhe o brilho com quem ama. 💖",
    "Ver alguém vibrando coisas boas é lindo. 🌞 Continue irradiando luz! 🌟",
    "Essa energia positiva é combustível para novas conquistas. 🎉 Guarde esse momento no coração! ❤️"
  ],
  ansioso: [
    "A ansiedade pode tentar te dominar, mas você tem mais controle do que imagina. 🌬️ Respire fundo e dê um passo de cada vez. 🌱",
    "Quando os pensamentos ficarem confusos, pare, inspire, solte e foque no presente. 👣",
    "A ansiedade não diminui sua força. 💖 Organize pensamentos, escolha uma prioridade e siga com calma. ✨",
    "Mesmo ansioso(a), lembre-se: você já superou situações difíceis antes. ⚡ Esta também vai passar. 🌈"
  ],
  confuso: [
    "Tudo bem se sentir perdido às vezes. 🌱 Respire, organize ideias e siga um pequeno passo. 👣",
    "Não se cobre por não ter todas respostas. 🌟 Confusão é prelúdio de aprendizado. 🚶",
    "A incerteza abre espaço para novas possibilidades. 🌈 Cada dúvida é convite para explorar algo novo. ⏳",
    "Quando tudo parecer nebuloso, respire e observe. 💡 Você tem força para transformar confusão em clareza."
  ],
  estressado: [
    "O estresse pode estar pesado, mas você não precisa carregar tudo sozinho. 🌊 Respire, desacelere e desconecte-se um pouco. ✨",
    "O estresse é sinal de esforço. 🌿 Ouça música, alongue-se ou caminhe. 🎵🚶",
    "Respire fundo e solte lentamente. 🌬️ Foque no que pode mudar e deixe o resto fluir. 💖",
    "Cada desafio traz oportunidade de mostrar resiliência. 💪 Olhe para si mesmo com orgulho."
  ],
  motivado: [
    "Essa energia é poderosa! 🔥 Transforme sonhos em realidade. Cada passo é vitória. 🚀",
    "A motivação que sente é presente. ✨ Canalize para objetivos e inspire outros. 🌈",
    "Continue nesse ritmo. 💪 Desafios parecem menores quando motivado. 🌟",
    "Use essa chama para dar vida às ideias. 🎯 Cada passo é investimento no futuro. 🌻"
  ],
  agradecido: [
    "A gratidão transforma dias comuns em extraordinários. 🙏 Valorize pequenas coisas. ✨",
    "Sinto energia ao ver você valorizar bênçãos. 🌟 Gratidão atrai mais motivos para sorrir. 💖",
    "Coração grato é leve. 🌈 Reconhecer agora abre espaço para mais coisas boas. 🌞",
    "Gratidão abre portas para oportunidades. 🗝️ Continue praticando! 🌻"
  ]
}

EMERGENCY_CONTACTS = {
  cvv: "CVV - Centro de Valorização da Vida: 188 (gratuito, 24h)",
  samu: "SAMU - Emergências médicas: 192",
  caps: "CAPS - Centro de Atenção Psicossocial (procure o mais próximo)",
  chat_cvv: "Chat online: cvv.org.br",
  emergencia: "Emergência geral: 190 (Polícia) ou 193 (Bombeiros)"
}

CRISIS_ALTERNATIVES = [
  "Segure cubos de gelo nas mãos até derreter",
  " Desenhe na pele com caneta vermelha",
  " Faça exercícios intensos",
  " Tome banho frio/quente",
  " Grite no travesseiro",
  " Escreva tudo que sente",
  " Ouça música alta e dance",
  " Ligue para alguém de confiança ou CVV (188)"
]

POSITIVE_DISTRACTIONS = [
  " Assista vídeos engraçados",
  " Veja fotos de animais fofos",
  " Saia para observar a natureza",
  " Leia um livro ou artigo",
  " Jogue um game relaxante",
  " Faça palavras cruzadas ou sudoku",
  " Desenhe ou pinte",
  " Pratique respiração profunda"
]

DAILY_TIPS = [
  "Beba água! ",
  "Dê uma caminhada de 10 minutos 🚶",
  "Escreva seus pensamentos ",
  "Medite por 5 minutos ",
  "Ouça sua música favorita ",
  "Diga algo positivo para si mesmo ",
  "Planeje o dia de forma leve ",
  "Faça algo criativo ",
  "Sorria para alguém ",
  "Leia uma frase inspiradora "
]

BREATHING_EXERCISES = [
  " 4-7-8: Inspire 4s, segure 7s, expire 8s. 3x",
  "Respiração quadrada: Inspire 4s → Segure 4s → Expire 4s → Segure 4s. 5 ciclos",
  " Respiração do oceano: Inspire profundamente e expire 'ahhhh'",
  " Respiração das estrelas: Inspire luz, expire tensão"
]

QUICK_MEDITATIONS = [
  " Feche olhos e conte 10 a 1 respirando",
  " Visualize lugar calmo e respire 2 min",
  " Concentre-se nos sons por 3 min",
  " Relaxe cada parte do corpo dos pés à cabeça"
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
  "Aceito os desafios como oportunidades de crescimento! 🚀",
  "Minha vida tem valor e significado únicos! 💎",
  "Eu sou merecedor(a) de amor e cuidado! ❤️"
]

MOOD_TRACKER = {}

# -----------------------
# Helpers
# -----------------------
helpers do
  def system_message(text, type="normal")
    { name: "Cláudia", msg: text, time: Time.now.strftime("%H:%M"), type: type }
  end

  def user_message(name, text)
    { name: name, msg: text, time: Time.now.strftime("%H:%M"), type: "user" }
  end

  def detect_crisis_keywords(msg)
    msg_down = msg.downcase

    suicide_words = ['suicid', 'me matar', 'não quero viver', 'quero morrer', 'acabar com tudo', 'não aguento mais', 'melhor morto', 'vou me matar', 'não vale a pena viver', 'cansei da vida', 'prefiro estar morto']
    self_harm_words = ['me corto', 'me cortando', 'me machucar', 'me machuco', 'cortar o punho', 'autolesão', 'auto lesão', 'me ferir', 'me ferindo', 'lâmina', 'gilete']
    hopeless_words = ['sem esperança', 'não há saída', 'sem solução', 'desespero total', 'não tem jeito', 'perdido na vida', 'sem sentido', 'vazio total']
    loneliness_words = ['totalmente sozinho', 'ninguém me ama', 'completamente isolado', 'não tenho ninguém', 'abandonado por todos']

    return :suicida if suicide_words.any? { |w| msg_down.include?(w) }
    return :autolesao if self_harm_words.any? { |w| msg_down.include?(w) }
    return :desesperanca if hopeless_words.any? { |w| msg_down.include?(w) }
    return :solidao if loneliness_words.any? { |w| msg_down.include?(w) }

    nil
  end

  def generate_response(msg)
    sleep rand(1..2)
    crisis_type = detect_crisis_keywords(msg)
    return CUSTOM_RESPONSES[crisis_type].sample if crisis_type

    msg_down = msg.downcase
    case
    when msg_down.match?(/triste|depressivo|mal|down/) then CUSTOM_RESPONSES[:triste].sample
    when msg_down.match?(/cansado|exausto|desanimado|tired/) then CUSTOM_RESPONSES[:cansado].sample
    when msg_down.match?(/feliz|animado|alegre|happy|bem/) then CUSTOM_RESPONSES[:feliz].sample
    when msg_down.match?(/ansioso|preocupado|nervoso|anxiety/) then CUSTOM_RESPONSES[:ansioso].sample
    when msg_down.match?(/confuso|perdido|não sei|dúvida/) then CUSTOM_RESPONSES[:confuso].sample
    when msg_down.match?(/estressado|irritado|raiva|stress/) then CUSTOM_RESPONSES[:estressado].sample
    when msg_down.match?(/motivado|energizado|determinado/) then CUSTOM_RESPONSES[:motivado].sample
    when msg_down.match?(/obrigado|obrigada|agradec|grato|grata/) then CUSTOM_RESPONSES[:agradecido].sample
    else MOTIVATIONAL_QUOTES.sample
    end
  end

  def daily_tip; DAILY_TIPS.sample; end
  def breathing_exercise; BREATHING_EXERCISES.sample; end
  def quick_meditation; QUICK_MEDITATIONS.sample; end
  def random_affirmation; AFFIRMATIONS.sample; end
  def crisis_alternative; CRISIS_ALTERNATIVES.sample; end
  def positive_distraction; POSITIVE_DISTRACTIONS.sample; end
  def emergency_contacts; EMERGENCY_CONTACTS.values.join("\n"); end

  def mood_check_in
    "Como você se sente numa escala de 1-10? 1 sendo muito mal e 10 excelente! "
  end

  def save_mood(user, rating)
    date = Time.now.strftime("%Y-%m-%d")
    MOOD_TRACKER[user] ||= {}
    MOOD_TRACKER[user][date] = rating.to_i
  end

  def get_mood_trend(user)
    return "Ainda não temos dados suficientes! Continue registrando. " unless MOOD_TRACKER[user]

    recent_moods = MOOD_TRACKER[user].values.last(7)
    return "Registre seu humor por mais alguns dias! " if recent_moods.length < 3

    avg = recent_moods.sum.to_f / recent_moods.length
    case avg
    when 8..10 then "Seu humor tem estado ótimo! "
    when 6..7.9 then "Seu humor está numa boa média! "
    when 4..5.9 then "Seu humor tem oscilado. Que tal algumas dicas para melhorar? "
    when 1..3.9 then "Você não tem se sentido muito bem. Converse com alguém de confiança ou ligue para o CVV: 188. "
    end
  end

  def generate_goal_suggestion
    GOAL_TEMPLATES.sample + "[escreva aqui seu objetivo] "
  end

  def get_encouragement_by_time
    hour = Time.now.hour
    case hour
    when 5..11 then "Bom dia! ☀️ Comece o dia com energia positiva!"
    when 12..17 then "Boa tarde!  Continue firme!"
    when 18..21 then "Boa noite!  Hora de relaxar e refletir!"
    else "Que horas são essas acordado?  Lembre-se de descansar!"
    end
  end
end

get '/' do
  session[:messages] ||= []
  if session[:messages].empty?
    welcome_msg = "Bem-vindo ao Chat de Apoio Emocional! #{get_encouragement_by_time} Como você está hoje? \n\n Se estiver em crise, busque ajuda: CVV 188"
    session[:messages] << system_message(welcome_msg)
  end
  @messages = session[:messages].last(100)
  erb :index
end

post '/send' do
  session[:messages] ||= []
  name = params[:name].strip
  msg  = params[:msg].strip

  unless name.empty? || msg.empty?
    session[:messages] << user_message(name, msg)

    if msg.downcase.match?(/humor|mood/) && msg.match(/(\d+)/)
      rating = msg.match(/(\d+)/)[1]
      save_mood(name, rating)
      response = "Humor registrado como #{rating}/10. #{get_mood_trend(name)}"
    else
      response = generate_response(msg)
    end

    session[:messages] << system_message(response)
  end

  redirect '/'
end


get '/daily_tip' do
  session[:messages] << system_message(" Dica do dia: #{daily_tip}", "tip")
  redirect '/'
end

get '/breathing' do
  session[:messages] << system_message("Exercício: #{breathing_exercise}", "exercise")
  redirect '/'
end

get '/meditation' do
  session[:messages] << system_message(" Meditação: #{quick_meditation}", "meditation")
  redirect '/'
end

get '/affirmation' do
  session[:messages] << system_message(" Afirmação: #{random_affirmation}", "affirmation")
  redirect '/'
end

get '/alternatives' do
  session[:messages] << system_message(" Alternativa: #{crisis_alternative}", "alternative")
  redirect '/'
end

get '/distraction' do
  session[:messages] << system_message(" Atividade: #{positive_distraction}", "distraction")
  redirect '/'
end

get '/mood_check' do
  session[:messages] << system_message(mood_check_in, "mood")
  redirect '/'
end

get '/goal' do
  session[:messages] << system_message(" Meta: #{generate_goal_suggestion}", "goal")
  redirect '/'
end

get '/encouragement' do
  session[:messages] << system_message(get_encouragement_by_time, "time_based")
  redirect '/'
end

get '/clear' do
  session[:messages] = []
  redirect '/'
end


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
