chromote_extractor <- function(url){

  chromote_ss <- ChromoteSession$new()  # Crea una nueva sesión de Chromote para interactuar con un navegador.

  chromote_ss$Page$navigate(url)  # Navega a la URL especificada usando el navegador.

  Sys.sleep(5)  # Espera 5 segundos para dar tiempo a que la página cargue completamente, incluyendo el contenido dinámico.

  content <- chromote_ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value
  # Evalúa un script en el navegador para extraer todo el contenido HTML de la página. El script `document.documentElement.outerHTML`
  # devuelve el contenido HTML completo de la página actual.

  chromote_ss$close()  # Cierra la sesión de Chromote para liberar recursos.

  return(content)  # Devuelve el HTML de la página como una cadena de texto.
}
