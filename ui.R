dashboardPage(
  dashboardHeader(title = "", titleWidth = 0),
  
  dashboardSidebar(
    collapsed = T,
    sidebarMenu(
      menuItem("Estimador", tabName = "A", icon = icon("gear")),
      menuItem("Sobre", tabName = "B", icon = icon("info-circle")),
      menuItem("Contatos", tabName = "C", icon = icon("address-book"))
    )
  ),
  
  
  dashboardBody(
    
    useShinyjs(),
    
    tags$head(
      tags$style(HTML("
        #loading-content {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: white;
          z-index: 9999;
          display: flex;
          align-items: center;
          justify-content: center;
        }
      "))
    ),
    
    div(id = "loading-content", h2("Carregando...")),
    
    tags$script(HTML("
      $(window).on('load', function() {
        $('#loading-content').fadeOut('fast');
      });
    ")),
    
    tags$head(tags$title("Título da Aba do Navegador")),
    
    tags$head(tags$style(HTML(
      '.myClass { 
        font-size: 20px;
        line-height: 50px;
        text-align: left;
        font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
        padding: 0 15px;
        overflow: hidden;
        color: white;
      }
    '))),
    tags$script(HTML('
      $(document).ready(function() {
        $("header").find("nav").append(\'<span class="myClass"> Precificação de Imóveis em Natal </span>\');
      })
     ')),
    
    tags$head(tags$style(HTML("
      #sidebar {
        background-color: white;
        padding: 20px;
        height: auto;
        overflow-y: visible;
        max-height: none;
        box-shadow: 2px 0px 5px rgba(0,0,0,0.2);
      }
      #mapa {
        height: 100vh;
        border: 3px solid #167fa6; /* borda azul */
        border-radius: 8px;
      }
    "))),
    
    tabItems(
      
      tabItem(tabName = "A",
              
              fluidRow(
                  column(width = 4,
                          
                         div(id = "sidebar", 
                             h4(strong("Preencha os dados do imóvel:")),
                             
                             helpText(strong("Clique em algum ponto de interesse no mapa 
                                             para fornecer as coordenadas automaticamente.")),
                             # Campos para latitude e longitude
                              numericInput("lat", "Latitude:", value = NA, step = 0.00001),
                              numericInput("lng", "Longitude:", value = NA, step = 0.00001),
                             
                             hr(),
            
                              numericInput("area", "Área (m²):", value = 100, min = 50),
                              numericInput("banheiro", "Nº de banheiros:", value = 2, min = 0),
                              numericInput("quarto", "Nº de quartos:", value = 2, min = 0),
                              numericInput("vaga", "Nº de vagas:", value = 1, min = 0),
            
                              selectInput("tipo", "Tipo do imóvel:", 
                                  choices = c(
                                      "Casas" = "casas",
                                      "Apartamentos" = "apartamentos",
                                      "Terrenos / Lotes / Condomínio" = "terrenos_lotes_condominio",
                                      "Flat" = "flat",
                                      "Casas de condomínio" = "casas_de_condominio"
                                  )
                              ),
                             
                  hr(),           
                  
                  h5(strong("Comodidades:")),
                  
                  fluidRow(
                    column(4, checkboxInput("area_servico", "Área de serviço", FALSE)),
                    column(4, checkboxInput("espaco_gourmet", "Espaço gourmet", FALSE)),
                    column(4, checkboxInput("piscina", "Piscina", FALSE))
                  ),
                  
                  fluidRow(
                    column(4, checkboxInput("elevador", "Elevador", FALSE)),
                    column(4, checkboxInput("salao_de_festa", "Salão de festa", FALSE)),
                    column(4, checkboxInput("academia", "Academia", FALSE))
                  ),
                  
                  fluidRow(
                    column(4, checkboxInput("quadra_de_esporte", "Quadra de esporte", FALSE)),
                    column(4, checkboxInput("portaria_24_horas", "Portaria 24h", FALSE)),
                    column(4, checkboxInput("varanda_gourmet", "Varanda gourmet", FALSE))
                  ),
                  
                  fluidRow(
                    column(4, checkboxInput("sauna", "Sauna", FALSE)),
                    column(4, checkboxInput("spa", "Spa", FALSE))
                  ),
                  
                  actionButton("estimar", "Estimar valor", class = "btn btn-success"),
                  br(), br(),
                
                  )
                ),
              
              column(width = 8,
                     leafletOutput("mapa", height = "80vh")
                    )
        
            )
            
      ),
      
      tabItem(tabName = "B",
              h1("Sobre:"),
              h4("Esta é uma aplicação estatística envolvendo modelo de aprendizado de máquina supervisionado
                 utilizando dados de imóveis anunciados em Natal-RN no primeiro semestre de 2023 no site",
                 a("ZAP Imóveis", href = "https://www.zapimoveis.com.br/", target = "_blank"),
                 "utilizando a linguagem R."
                 ),
              h4("Trata-se de uma ferramenta web criada para estimar o preço médio de imóveis na cidade de Natal-RN.
                 O usuário deve fornecer informações das características do imóvel de interesse, como área, número de quartos, 
                 banheiros e vagas na garagem, localização geográfica, tipo de imóvel e presença de comodidades."),
              
              ),
      
      tabItem(tabName = "C",
              h1("Contatos:"),
              h3(a("Makson Pedro Rodrigues", 
                   href = "https://lacid.ccet.ufrn.br/author/makson-pedro-rodrigues/",
                   target = "_blank")),
              h4("\u2709 maksonpedro@gmail.com"),
              h3(a("Marcelo Bourguignon Pereira", 
                   href = "https://lacid.ccet.ufrn.br/author/marcelo-bourguignon/",
                   target = "_blank")),
              h4("\u2709 marcelo.bourguignon@ufrn.br")
              )
      
    )
    
    
  )
)
