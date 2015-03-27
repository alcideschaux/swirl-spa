# Return random praise.
praise <- function() {
  swirl_is_fun <- getOption("swirl_is_fun")

  if(is.null(swirl_is_fun) || isTRUE(swirl_is_fun)) {
    phrases <- c("Lo lograste!",
                 "Buen trabajo!",
                 "Sigue adelante!",
                 "Vas muy bien!",
                 "Todo el esfuerzo va dando frutos!",
                 "Le diste!Buen trabajo!",
                 "Eres el mejor!",
                 "Eres genial!",
                 "Sigue adelante y llegaras a destino!",
                 "Perseverancia, esa es la clave!",
                 "Excelente trabajo!",
                 "Eres bastante bueno!",
                 "Tu dedicacion es inspiradora!",
                 "Entendiste bien!",
                 "Asi mismo es!",
                 "En serio vas de maravillas!",
                 "Excelente labor!",
                 "Toda esa dedicacion va dando frutos!",
                 "Excelente trabajo!",
                 "Ese es un trabajo bien hecho!",
                 "Esa es la respuesta que estaba buscando!")
  } else {
    phrases <- "Correcto!"
  }
  sample(phrases, 1)
}

# Return random "try again" message.
tryAgain <- function() {
  swirl_is_fun <- getOption("swirl_is_fun")

  if(is.null(swirl_is_fun) || isTRUE(swirl_is_fun)) {
    phrases <- c("Casi! Intenta otra vez.",
                 "Casi lo conseguiste, pero no todavia. Intenta otra vez.",
                 "Intenta otra vez!",
                 "No del todo bien! Intenta otra vez.",
                 "No exactamente. Hazlo otra vez!",
                 "Eso no es exactamente lo que estoy buscando. Intenta de nuevo!",
                 "Buen intento, pero no es exactamente lo que estaba esperando. Intenta otra vez!",
                 "Sigue intentando!",
                 "Esa no es la respuesta que estaba buscando, pero prueba otra vez!",
                 "No del todo correcto, pero sigue intentando!",
                 "Te vas acercando ... puedo sentirlo! Intenta otra vez!",
                 "Otra vez! Puedes hacerlo!",
                 "No del todo bien, pero vas aprendiendo! Prueba otra vez!",
                 "Intenta otra vez! Hacerlo bien la primera vez es aburrido de todas maneras!")
  } else {
    phrases <- "Incorrecto. Por favor intenta otra vez."
  }
  sample(phrases, 1)
}
