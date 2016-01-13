.onAttach <- function(...) {
  if(length(ls(envir=globalenv())) > 0) {
    packageStartupMessage(
      make_pretty("Hola! Veo que tienes algunas variables guardadas en tu",
      "espacio de trabajo. Para que las cosas vayan bien te recomiendo que lo",
      "vacies antes de empezar swirl.", skip_after=TRUE),
      make_pretty("Tipea ls() para ver una lista de las variables en tu espacio",
      "de trabajo. Luego, tipea rm(list=ls()) para limpiarlo.", skip_after=TRUE),
      make_pretty("Tipea swirl() cuando estés listo para empezar.", skip_after=TRUE)
    )
  } else {
    packageStartupMessage(
      make_pretty("Hola! Tipea swirl() cuando estés listo para empezar.",
                  skip_after=TRUE)
    )
  }
  invisible()
}

make_pretty <- function(..., skip_before=TRUE, skip_after=FALSE) {
  wrapped <- strwrap(str_c(..., sep = " "),
                     width = getOption("width") - 2)
  mes <- str_c("| ", wrapped, collapse = "\n")
  if(skip_before) mes <- paste0("\n", mes)
  if(skip_after) mes <- paste0(mes, "\n")
  mes
}
