saveProgress <- function(e)UseMethod("saveProgress")

saveProgress.default <- function(e){
  # save progress
  suppressMessages(suppressWarnings(saveRDS(e, e$progress)))
}

#' Delete a user's progress
#'
#' @param user The user name whose progress will be deleted.
#'
#' @export
#' @examples
#' \dontrun{
#'
#' delete_progress("bill")
#' }
delete_progress <- function(user){
  # Make sure user entered a user name
  if(nchar(user) < 1){
    stop("Por favor ingresa un nombre de usuario válido.")
  }

  # Find path to user data
  path <- system.file("user_data", user, package = "swirl")

  # Delete all files within a user folder
  if(file.exists(path)){
    invisible(file.remove(list.files(path, full.names = TRUE), recursive = TRUE))
    message(paste0("Se ha borrado el progreso del usuario: ", user))
  } else {
    message(paste0("No se ha encontrado la cuenta del usuario: ", user))
  }
}
