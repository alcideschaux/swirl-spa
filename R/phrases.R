# Return random praise.
praise <- function() {
  swirl_is_fun <- getOption("swirl_is_fun")
  
  if(is.null(swirl_is_fun) || isTRUE(swirl_is_fun)) {
    phrases <- c("¡Lo lograste!",
                 "¡Buen trabajo!",
                 "¡Sigue así!",
                 "¡Vas muy bien!",
                 "¡Todo el esfuerzo está dando frutos!",
                 "¡Le diste!¡Buen trabajo!",
                 "¡Eres el mejor!",
                 "¡Eres fantástico!",
                 "¡Sigue así y llegarás a destino!",
                 "Perseverancia, esa es la clave.",
                 "¡Excelente trabajo!",
                 "¡Eres bastente bueno, amigo mío!",
                 "¡Tu dedicación es inspiradora!",
                 "¡Entendiste bien!",
                 "¡Así mismo es!",
                 "¡En serio te está yendo de maravillas!",
                 "¡Excelente labor!",
                 "¡Toda esa práctica está dando frutos!",
                 "¡Excelente trabajo!",
                 "¡Ese es un trabajo bien hecho!",
                 "Esa es la respuesta que estaba buscando.")
  } else {
    phrases <- "¡Correcto!"
  }
  sample(phrases, 1)
}

# Return random "try again" message.
tryAgain <- function() {
  swirl_is_fun <- getOption("swirl_is_fun")
  
  if(is.null(swirl_is_fun) || isTRUE(swirl_is_fun)) {
    phrases <- c("¡Casi! Intenta otra vez.",
                 "Casi lo conseguiste, pero no todavía. Intenta otra vez.",
                 "Intenta una vez más.",
                 "¡No está del todo bien! Intenta otra vez.",
                 "No exactamente. Hazlo una vez más.",
                 "Eso no es exactamente lo que estoy buscando. Intenta de nuevo.",
                 "Buen intento, pero no es exactamente lo que estaba esperando. Intenta otra vez.",
                 "¡Sigue intentando!",
                 "Esa no es la respuesta que estaba buscando, pero prueba otra vez.",
                 "No del todo correcto, pero sigue intentando.",
                 "Estás cerca ... ¡Puedo sentirlo! Intenta otra vez.",
                 "Una vez más. ¡Puedes hacerlo!",
                 "No del todo bien, ¡pero estás aprendiendo! Try again.",
                 "Intenta otra vez. ¡Hacerlo bien la primera vez es aburrido de todas maneras!")
  } else {
    phrases <- "Incorrecto. Por favor intenta otra vez."
  }
  sample(phrases, 1)
}
