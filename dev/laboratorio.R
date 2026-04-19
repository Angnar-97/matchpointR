# LABORATORIO

# Load necessary libraries
library(rvest)
library(httr)
library(chromote)
library(tidyverse)
library(purrr)
library(magick)
library(rsvg)


# Llamar a la función y mostrar los resultados
url <- "https://www.wtatennis.com/players/320301/katerina-siniakova#overview"

page <- load_page_xml2(url)

# Extraer el nombre de la jugadora
nombre <- page %>%
  html_node(".profile-header-info .profile-header__name") %>%
  html_text(trim = TRUE) |>
  stringr::str_squish()

# Extraer la URL de la imagen usando la clase CSS específica
foto_jugadora <-  page %>%
  html_node(".profile-header-headshot.full-body img") |> html_attr("src")

# Si la URL es relativa, completar con el dominio base
jugadora_imagen_url <- paste0("https://www.wtatennis.com", nacionalidad_imagen)

# Descargar y convertir el SVG a PNG usando rsvg
jugadora_img <- image_read(foto_jugadora)

nacionalidad <- page %>%
  html_node(".profile-header-info__nationality") %>%
  html_text(trim = TRUE) |>
  stringr::str_squish()

nacionalidad_imagen <- page %>%
  html_node(".profile-header-info__nationalityFlag") %>%
  html_attr("src") # Extrae el atributo src que contiene la URL de la imagen

# Si la URL es relativa, completar con el dominio base
nacionalidad_imagen_url <- paste0("https://www.wtatennis.com", nacionalidad_imagen)

# Descargar y convertir el SVG a PNG usando rsvg
nacionalidad_img_svg <- image_read_svg(nacionalidad_imagen_url)


stats <- page %>%
  html_nodes(".profile-header-info__detail-stat--small") %>%
  html_text(trim = TRUE)|>
  stringr::str_squish()

altura <- stats[1]
mano <- stats[2]
fecha_nacimiento <- stats[3]
lugar_nacimiento <- stats[4]

# Crear una tibble con los datos extraídos
player_data <- tibble::tibble(
  name = nombre,
  birth_date = fecha_nacimiento,
  nationality = nacionalidad,
  birth_place = lugar_nacimiento,
  height = altura,
  handedness = mano,
  # imagen de la jugadora
  player_image = list(jugadora_img),  # Almacenar la imagen de la jugadora
  # imagen de la bandera de la nacionalidad
  nationality_flag = list(nacionalidad_img_svg)  # Almacenar la imagen de la bandera
)



overview <- get_singles_and_doubles(url)

overview_clean <- overview |>
  map(stringr::str_squish)

overview_stats <- tibble(
  stats = c('Singles', 'Doubles'),
  current_ranking = c(overview_clean$singles[1], overview_clean$doubles[1]),
  carrer_high = c(overview_clean$singles[7], overview_clean$doubles[7]),
  win_rate_year = c(overview_clean$singles[5], overview_clean$doubles[5]),
  win_rate_career = c(overview_clean$singles[11], overview_clean$doubles[11]),
  year_titles = c(overview_clean$singles[2], overview_clean$doubles[2]),
  career_titles = c(overview_clean$singles[8], overview_clean$doubles[8]),
  prize_money_year = c(overview_clean$singles[3], overview_clean$doubles[3]),
  prize_money_career = c(overview_clean$singles[9], overview_clean$doubles[9]),
)


# PLAYER BIO

# bio_title_content <- page %>%
#   html_nodes(".profile-bio__title") %>%
#   html_text(trim = TRUE)|>
#   stringr::str_squish()


bio_content <- page %>%
  html_nodes(".bio-content") |>
  html_text(trim = TRUE)




# PLAYER MATCHES
library(chromote)
library(xml2)
library(rvest)

chromote_extractor <- function(url){

  chromote_ss <- ChromoteSession$new()

  chromote_ss$Page$navigate(url)

  # Espera a que la página cargue completamente
  chromote_ss$Page$loadEventFired(wait_ = TRUE)

  # Función para hacer scroll hasta el final de la página
  scroll_to_bottom <- function() {
    chromote_ss$Runtime$evaluate("window.scrollTo(0, document.body.scrollHeight);")
    Sys.sleep(1)  # Espera un segundo para que cargue el contenido
  }

  # Simula clics en "Show more" hasta que ya no exista el botón
  while(TRUE) {
    tryCatch({
      # Verifica si el botón existe
      show_more_exists <- chromote_ss$Runtime$evaluate("document.querySelector('.player-matches__more-button') !== null")$result$value
      if(!show_more_exists) {
        break
      }
      # Clic en el botón "Show more"
      chromote_ss$Runtime$evaluate("document.querySelector('.player-matches__more-button').click();")
      Sys.sleep(2)  # Espera un poco para que el nuevo contenido cargue
      scroll_to_bottom()  # Desplázate hacia abajo para cargar contenido si es necesario
    }, error = function(e) {
      break  # Si hay un error (por ejemplo, el botón ya no existe), rompe el bucle
    })
  }

  # Una vez que todo el contenido esté cargado, extrae el HTML
  content <- chromote_ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value

  chromote_ss$close()

  return(content)
}


load_page_xml2 <- function(url) {

  content <- chromote_extractor(url)

  xml2::read_html(content)
}


url <- "https://www.wtatennis.com/players/320301/katerina-siniakova#matches"
page <- load_page_xml2(url)
tables <- page %>%
  html_nodes(".player-matches__content") %>%  # Selecciona el contenedor con la clase específica
  html_nodes("table") %>%  # Luego selecciona las tablas dentro de ese contenedor
  html_table(fill = TRUE)  # Convierte a data frames; usa fill=TRUE para manejar celdas combinadas



.player-matches__match-opponent-first

.player-matches__tournament-title-link

.player-matches__header-cell

.player-matches__match-round

.player-matches__match-opponent-first




