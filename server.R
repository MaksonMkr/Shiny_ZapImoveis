function(input, output, session) {
  
  # Função que calcula as features de distâncias e pontos de ônibus
  calc_features_from_location <- function(lat, lon) {
    ponto <- st_as_sf(tibble(longitude = lon, latitude = lat),
                      coords = c("longitude", "latitude"), crs = 4326) |>
      st_transform(31985)
    
    safe_min <- function(x) {
      if (length(x) == 0) return(NA_real_)
      min(as.numeric(x), na.rm = TRUE)
    }
    
    dist_praia <- safe_min(st_distance(ponto, praias_sf)) / 1000
    dist_hospital <- safe_min(st_distance(ponto, hospitais_sf)) / 1000
    dist_supermercado <- safe_min(st_distance(ponto, supermercados_sf)) / 1000
    dist_parque <- safe_min(st_distance(ponto, parques_sf)) / 1000
    
    buffer_500m <- st_buffer(ponto, 500)
    bus_count_500m <- lengths(st_intersects(buffer_500m, onibus_sf))
    
    tibble(
      dist_praia = as.numeric(dist_praia),
      dist_hospital = as.numeric(dist_hospital),
      dist_supermercado = as.numeric(dist_supermercado),
      dist_parque = as.numeric(dist_parque),
      bus_count_500m = as.integer(bus_count_500m)
    )
  }
  
  coord <- reactiveVal(NULL)
  
  output$mapa <- renderLeaflet({
    leaflet(options = leafletOptions(minZoom = 12, maxZoom = 16)) |>
      addTiles() |>
      setView(lng = -35.2094, lat = -5.7945, zoom = 13) |> 
      setMaxBounds(
        lng1 = -35.32, lat1 = -5.92,
        lng2 = -35.08, lat2 = -5.69    
      )
  })
  
  observeEvent(input$mapa_click, {
    click <- input$mapa_click
    coord(click)
    
    updateNumericInput(session, "lat", value = round(click$lat, 5))
    updateNumericInput(session, "lng", value = round(click$lng, 5))
    
    leafletProxy("mapa") |>
      clearMarkers() |>
      addMarkers(lng = click$lng, lat = click$lat, popup = "Local selecionado")
  })
  
  observeEvent(input$estimar, {
    req(coord())
    req(input$lat, input$lng)
    
    geo_features <- tryCatch(
      calc_features_from_location(input$lat, input$lng),
      error = function(e) {
        showNotification("Erro ao calcular variáveis de distância. Verifique a conexão ou os dados OSM.",
                         type = "error")
        return(tibble(
          dist_praia = NA_real_,
          dist_hospital = NA_real_,
          dist_supermercado = NA_real_,
          dist_parque = NA_real_,
          bus_count_500m = NA_integer_
        ))
      }
    )
    
    print(geo_features)  # aqui você vê os valores no console
    
    novos_dados <- tibble(
      area = input$area,
      banheiro = input$banheiro,
      quarto = input$quarto,
      vaga = input$vaga,
      tipo = input$tipo,
      area_servico = input$area_servico,
      espaco_gourmet = input$espaco_gourmet,
      piscina = input$piscina,
      elevador = input$elevador,
      salao_de_festa = input$salao_de_festa,
      academia = input$academia,
      quadra_de_esporte = input$quadra_de_esporte,
      portaria_24_horas = input$portaria_24_horas,
      varanda_gourmet = input$varanda_gourmet,
      sauna = input$sauna,
      spa = input$spa,
      latitude = input$lat,
      longitude = input$lng,
      bairro = "placeholder"
    ) |> bind_cols(geo_features)
    
    res <- tryCatch({
      predict(modelo_final, new_data = novos_dados)
    }, error = function(e) {
      showModal(modalDialog(
        title = "Erro na predição",
        paste("Mensagem:", e$message)
      ))
      return(NULL)
    })
    
    if (!is.null(res)) {
      valor_texto <- paste0(
        "Valor estimado do imóvel: R$ ",
        format(round(res$.pred, 2), big.mark = ".", decimal.mark = ",")
      )
      
      showModal(modalDialog(
        title = "Resultado da Estimativa",
        valor_texto,
        easyClose = TRUE,
        footer = modalButton("Fechar")
      ))
    }
  })
  
  output$coordenadas <- renderPrint({
    req(coord())
    paste("Lat:", round(coord()$lat, 5), "| Lng:", round(coord()$lng, 5))
  })
  
  
}
