get_player_basics <- function(player_url) {

  # Usar la función 'chromoter' para obtener el HTML dinámico completo de la página.
  content <- chromoter(player_url)
  # Leer la página de la jugadora
  page <- read_html(content)

  # Extraer el nombre de la jugadora
  nombre <- page %>%
    html_node(".profile-header-info .profile-header__name") %>%
    html_text(trim = TRUE) |>
    stringr::str_squish()

  # Intentar extraer la URL de la imagen de la jugadora con el primer selector
  foto_jugadora <-  page %>%
    html_node(".profile-header-headshot.full-body img") %>%
    html_attr("src")

  # Si no se encuentra la imagen con el primer selector, usar el segundo selector alternativo
  if (is.na(foto_jugadora) || is.null(foto_jugadora)) {
    foto_jugadora <-  page %>%
      html_node(".fade-in-on-load.is-loaded") %>%
      html_attr("src")
  }

  # Descargar la imagen de la jugadora
  jugadora_img <- image_read(foto_jugadora)

  # Extraer la nacionalidad
  nacionalidad <- page %>%
    html_node(".profile-header-info__nationality") %>%
    html_text(trim = TRUE) |>
    stringr::str_squish()

  # Extraer la URL de la imagen de la bandera de la nacionalidad
  nacionalidad_imagen <- page %>%
    html_node(".profile-header-info__nationalityFlag") %>%
    html_attr("src")

  # Completar la URL de la bandera si es relativa
  nacionalidad_imagen_url <- paste0("https://www.wtatennis.com", nacionalidad_imagen)

  # Descargar y convertir el SVG a PNG usando rsvg
  nacionalidad_img_svg <- image_read_svg(nacionalidad_imagen_url)

  # Extraer las estadísticas (altura, mano, fecha y lugar de nacimiento)
  stats <- page %>%
    html_nodes(".profile-header-info__detail-stat--small") %>%
    html_text(trim = TRUE) |>
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
    player_image = list(jugadora_img),  # Imagen de la jugadora
    nationality_flag = list(nacionalidad_img_svg)  # Imagen de la bandera
  )

  return(player_data)
}

