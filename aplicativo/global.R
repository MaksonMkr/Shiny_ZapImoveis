# --- Pacotes necessários ---
library(shiny)
library(shinydashboard)
library(shinyjs)
library(leaflet)
library(tidymodels)
library(tidyverse)
library(osmdata)
library(sf)

# --- Modelo treinado ---
load("modelo_final.RData")

# --- Função auxiliar para carregar cache com segurança ---
load_cached_sf <- function(nome) {
  caminho <- file.path("data_cache", paste0(nome, ".rds"))
  if (!file.exists(caminho)) {
    stop(paste("Arquivo", caminho, "não encontrado. Gere o cache antes de rodar o app."))
  }
  
  message("Carregando ", nome, " do cache.")
  dados <- readRDS(caminho)
  
  # Garante que é sf e tem CRS válido
  if (!inherits(dados, "sf")) stop(paste("Objeto", nome, "não é um sf válido."))
  if (is.na(st_crs(dados))) st_crs(dados) <- 4326
  
  # Filtra geometrias vazias e transforma para UTM (31985)
  dados <- dados[!st_is_empty(dados), ]
  st_transform(dados, 31985)
}

# --- Carregamento dos dados ---
praias_sf <- load_cached_sf("praias")
hospitais_sf <- load_cached_sf("hospitais")
supermercados_sf <- load_cached_sf("supermercados")
parques_sf <- load_cached_sf("parques")
onibus_sf <- load_cached_sf("onibus")

# --- Mensagens de verificação ---
message("Resumo das camadas carregadas:")
message("  Praias: ", nrow(praias_sf))
message("  Hospitais: ", nrow(hospitais_sf))
message("  Supermercados: ", nrow(supermercados_sf))
message("  Parques: ", nrow(parques_sf))
message("  Ônibus: ", nrow(onibus_sf))

# --- Função para cálculo das features ---
calc_features_from_location <- function(lat, lon) {
  tryCatch({
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
  }, error = function(e) {
    message("Erro ao calcular variáveis de distância: ", e$message)
    tibble(
      dist_praia = NA_real_,
      dist_hospital = NA_real_,
      dist_supermercado = NA_real_,
      dist_parque = NA_real_,
      bus_count_500m = NA_integer_
    )
  })
}

message("✅ Global.R carregado com sucesso e camadas prontas para uso.")
