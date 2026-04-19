# Función para cambiar entre las pestañas de "Singles" y "Doubles" usando el selector correcto
get_singles_and_doubles <- function(url) {

  chromote_ss <- ChromoteSession$new()

  # Navegar a la página
  chromote_ss$Page$navigate(url)
  Sys.sleep(5)  # Espera a que la página cargue

  # Cambiar a la pestaña de "Singles" (usando el selector del switch)
  chromote_ss$Runtime$evaluate('document.querySelectorAll(".profile-header-toggle__switch-selector")[0].click();')
  Sys.sleep(2)  # Espera a que cargue la sección de Singles
  content_singles <- chromote_ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value

  # Cambiar a la pestaña de "Doubles" (usando el selector del switch)
  chromote_ss$Runtime$evaluate('document.querySelectorAll(".profile-header-toggle__switch-selector")[1].click();')
  Sys.sleep(2)  # Espera a que cargue la sección de Doubles
  content_doubles <- chromote_ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value

  chromote_ss$close()  # Cerrar la sesión

  # Extraer los datos de Singles y Doubles
  page_singles <- read_html(content_singles)
  page_doubles <- read_html(content_doubles)

  singles_stats <- page_singles %>%
    html_nodes(".profile-header-stats__value") %>%
    html_text(trim = TRUE)

  doubles_stats <- page_doubles %>%
    html_nodes(".profile-header-stats__value") %>%
    html_text(trim = TRUE)

  return(list(singles = singles_stats, doubles = doubles_stats))
}
