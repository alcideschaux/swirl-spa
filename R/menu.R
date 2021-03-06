## Method declarations

mainMenu <- function(e, ...)UseMethod("mainMenu")
welcome <- function(e, ...)UseMethod("welcome")
housekeeping <- function(e, ...)UseMethod("housekeeping")
inProgressMenu <- function(e, choices, ...)UseMethod("inProgressMenu")
courseMenu <- function(e, courses)UseMethod("courseMenu")
courseDir <- function(e)UseMethod("courseDir")
lessonMenu <- function(e, choices)UseMethod("lessonMenu")
restoreUserProgress <- function(e, selection)UseMethod("restoreUserProgress")
loadLesson <- function(e, ...)UseMethod("loadLesson")
loadInstructions <- function(e, ...)UseMethod("loadInstructions")

# Default course and lesson navigation logic
#
# This method implements default course and lesson navigation logic,
# decoupling menu presentation from internal processing of user
# selections. It relies on several methods for menu presentation,
# namely welcome(e), housekeeping(e), inProgressMenu(e, lessons),
# courseMenu(e, courses), and lessonMenu(e, lessons). Defaults
# are provided.
#
# @param e persistent environment accessible to the callback
#'@importFrom yaml yaml.load_file
mainMenu.default <- function(e){
  # Welcome the user if necessary and set up progress tracking
  if(!exists("usr",e,inherits = FALSE)){
    e$usr <- welcome(e)
    udat <- file.path(find.package("swirl"), "user_data", e$usr)
    if(!file.exists(udat)){
      housekeeping(e)
      dir.create(udat, recursive=TRUE)
    }
    e$udat <- udat
  }
  # If there is no active lesson, obtain one.
  if(!exists("les",e,inherits = FALSE)){
    # First, allow user to continue unfinished lessons
    # if there are any
    pfiles <- inProgress(e)
    response <- ""
    if(length(pfiles) > 0){
      response <- inProgressMenu(e, pfiles)
    }
    if(response != "" ){
      # If the user has chosen to continue, restore progress
      response <- gsub(" ", "_", response)
      response <- paste0(response,".rda")
      restoreUserProgress(e, response)
    } else {
      # Else load a new lesson.
      # Let user choose the course.
      coursesU <- dir(courseDir(e))
      # Eliminate empty directories
      idx <- unlist(sapply(coursesU,
                    function(x)length(dir(file.path(courseDir(e),x)))>0))
      coursesU <- coursesU[idx]

      # If no courses are available, offer to install one
      if(length(coursesU)==0){
        suggestions <- yaml.load_file(file.path(courseDir(e), "suggested_courses.yaml"))
        choices <- sapply(suggestions, function(x)paste0(x$Course, ": ", x$Description))
        swirl_out("Para empezar, debes instalar un Curso. Puedo instalarte un",
                  "Curso desde la Internet, o puedo enviarte a una página web",
                  "(https://github.com/swirldev/swirl_courses)",
                  "que te proveerá de opciones de Cursos (en inglés) e instrucciones para",
                  "instalar los Cursos por tu cuenta",
                  "(si no estás conectado a la Internet, tipea 0 para salir).")
        choices <- c(choices, "No instales nada. Lo haré yo mismo.")
        choice <- select.list(choices, graphics=FALSE)
        n <- which(choice == choices)
        if(length(n) == 0)return(FALSE)
        if(n < length(choices)){
          repeat {
            temp <- try(eval(parse(text=suggestions[[n]]$Install)), silent=TRUE)
            if(is(temp, "try-error")){
              swirl_out("Me disculpo, pero soy incapaz de obtener ", sQuote(choice),
                        "ahora mismo. Estás seguro que tienes una conexion a Internet?",
                        "Si es así, quieres intentarlo nuevamente o visitar",
                        "el repositorio del Curso por instrucciones sobre cómo",
                        "instalar un Curso manualmente? Tipea 0 para salir.")
              ch <- c("Intenta de nuevo!",
                      "Vamos al repositorio del Curso para una instalación manual.")
              resp <- select.list(ch, graphics=FALSE)
              if(resp == "") return(FALSE)
              if(resp == ch[2]) {
                swirl_out("OK. Estoy abriendo el repositorio de Cursos swirl en tu navegador.")
                browseURL("https://github.com/swirldev/swirl_courses")
                return(FALSE)
              }
            } else {
              break # Break repeat loop if install is successful
            }
          }
          coursesU <- dir(courseDir(e))
          # Eliminate empty directories
          idx <- unlist(sapply(coursesU,
                               function(x)length(dir(file.path(courseDir(e),x)))>0))
          coursesU <- coursesU[idx]
        } else {
          swirl_out("OK. Estoy abriendo el repositorio de Cursos swirl en tu navegador.")
          browseURL("https://github.com/swirldev/swirl_courses")
          return(FALSE)
        }
      }
      # path cosmetics
      coursesR <- gsub("_", " ", coursesU)
      lesson <- ""
      while(lesson == ""){
        course <- courseMenu(e, coursesR)
        if(!is.null(names(course)) && names(course)=="repo") {
          swirl_out("OK. Estoy abriendo el repositorio de Cursos swirl en tu navegador.")
          browseURL("https://github.com/swirldev/swirl_courses")
          return(FALSE)
        }
        if(course=="")return(FALSE)
        # Set temp course name since csv files don't carry attributes
        e$temp_course_name <- course
        # reverse path cosmetics
        courseU <- coursesU[course == coursesR]
        course_dir <- file.path(courseDir(e), courseU)
        # Get all files/folders from course dir, excluding MANIFEST
        lessons <- dir(course_dir)
        lessons <- lessons[lessons != "MANIFEST"]
        # If MANIFEST exists in course directory, then order courses
        man_path <- file.path(course_dir, "MANIFEST")
        if(file.exists(man_path)) {
          manifest <- get_manifest(course_dir)
          lessons <- order_lessons(current_order=lessons,
                                   manifest_order=manifest)
        }
        # Clean up lesson names
        lessons_clean <- gsub("_", " ", lessons)
        # Let user choose the lesson.
        lesson_choice <- lessonMenu(e, lessons_clean)
        # Set temp lesson name since csv files don't have lesson name attribute
        e$temp_lesson_name <- lesson_choice
        # reverse path cosmetics
        lesson <- ifelse(lesson_choice=="", "",
                         lessons[lesson_choice == lessons_clean])
        # Return to the course menu if the lesson failed to load
        if(lesson == ""){
          if(exists("les", e, inherits=FALSE)){
            rm("les", envir=e, inherits=FALSE)
          }
          lesson <- ""
          next()
        } else {
          # Load the lesson and intialize everything
          e$les <- loadLesson(e, courseU, lesson)
        }
      }
      # For sourcing files which construct figures etc
      e$path <- file.path(courseDir(e), courseU, lesson)
      # If running in 'test' mode and starting partway through
      # lesson, then complete first part
      if(is(e, "test") && e$test_from > 1) {
        complete_part(e)
      }

      # Remove temp lesson name and course name vars, which were surrogates
      # for csv attributes -- they've been attached via lesson() by now
      rm("temp_lesson_name", "temp_course_name", envir=e, inherits=FALSE)

      # Initialize the progress bar
      e$pbar <- txtProgressBar(style=3)
      e$pbar_seq <- seq(0, 1, length=nrow(e$les))

      # expr, val, ok, and vis should have been set by the callback.
      # The lesson's current row - could start after 1 if in 'test' mode
      if(is(e, 'test')) {
        e$row <- e$test_from
      } else {
        e$row <- 1
      }
      # The current row's instruction pointer
      e$iptr <- 1
      # A flag indicating we should return to the prompt
      e$prompt <- FALSE
      # The job of loading instructions for this "virtual machine"
      # is relegated to an S3 method to allow for different "programs."
      loadInstructions(e)
      # An identifier for the active row
      e$current.row <- NULL
      # Set up paths and files to save user progress
      # Make file path from lesson info
      fname <- progressName(attr(e$les,"course_name"), attr(e$les,"lesson_name"))
      # path to file
      e$progress <- file.path(e$udat, fname)
      # indicator that swirl is not reacting to console input
      e$playing <- FALSE
      # create the file
      suppressMessages(suppressWarnings(saveRDS(e, e$progress)))
    }
  }
  return(TRUE)
}

welcome.test <- function(e, ...){
  "author"
}

# Default version.
welcome.default <- function(e, ...){
  swirl_out("Bienvenido a swirl!")
  swirl_out("Por favor registrate. Si has usado swirl antes, tipea el mismo nombre",
            "que usaste entonces. Si es la primera vez, elige un nombre único.", skip_after=TRUE)
  resp <- readline("Como quieres que te llame? ")
  while(str_detect(resp, '[[:punct:]]')) {
    swirl_out("Por favor no uses comillas u otros tipos de puntuaciones en tu nombre.",
              skip_after = TRUE)
    resp <- readline("Como quieres que te llame? ")
  }
  return(resp)
}

# Presents preliminary information to a new user
#
# @param e persistent environment used here only for its class attribute
#
housekeeping.default <- function(e){
  swirl_out(paste0("Gracias, ", e$usr,". Antes de empezar con nuestra primera lección ",
            "cubramos rápidamente algunos puntos de manejo básico de swirl. ",
            "Antes que nada, deberías saber que cuando veas '...', eso significa ",
            "que debes presionar Enter cuando termines de leer y estés ",
            "listo para continuar."))
  readline("\n...  <-- Esto te indica que presiones Enter para continuar")
  swirl_out("Además, cuando veas 'PREGUNTA:', la línea de comandos de R (>),",
            "o cuando se te pida que selecciones de una lista, eso significa",
            "que es tu turno de ingresar una respuesta, para luego presionar",
            "Enter y continuar.")
  select.list(c("Continua.", "Procede.", "Vamos avanzando!"),
              title="\nSelecciona 1, 2, o 3 y presiona Enter", graphics=FALSE)
  swirl_out("Puedes salir de swirl y regresar a la línea de comandos de R (>)",
            "en cualquier momento presionando la tecla de escape (Esc).",
            "Si ya estás en la línea de comandos, tipea bye() para salir y",
            "guardar tu progreso. Cuando salgas apropiadamente, verás un mensaje",
            "corto haciéndote saber que lo has hecho.")
  info()
  swirl_out("Vamos a empezar!", skip_before=FALSE)
  readline("\n...")
}

housekeeping.test <- function(e){}

# A stub. Eventually this should be a full menu
inProgressMenu.default <- function(e, choices){
  nada <- "No. Déjame empezar algo nuevo."
  swirl_out("Te gustaría continuar con una de estas lecciones?")
  selection <- select.list(c(choices, nada), graphics=FALSE)
  # return a blank if the user rejects all choices
  if(identical(selection, nada))selection <- ""
  return(selection)
}

inProgressMenu.test <- function(e, choices) {
  ""
}

# A stub. Eventually this should be a full menu
courseMenu.default <- function(e, choices){
  repo_option <- "Vamos al repositorio de Cursos de swirl!"
  choices <- c(choices, repo = repo_option)
  swirl_out("Por favor elige un Curso, o tipea 0 para salir de swirl.")
  return(select.list(choices, graphics=FALSE))
}

courseMenu.test <- function(e, choices) {
  e$test_course
}

# A stub. Eventually this should be a full menu
lessonMenu.default <- function(e, choices){
  swirl_out("Por favor escoge una lección, o tipea 0 para regresar al",
            "menú del Curso.")
  return(select.list(choices, graphics=FALSE))
}

lessonMenu.test <- function(e, choices) {
  e$test_lesson
}

loadLesson.default <- function(e, courseU, lesson){
  # Load the content file
  lesPath <- file.path(courseDir(e), courseU, lesson)
  shortname <- find_lesson(lesPath)
  dataName <- file.path(lesPath,shortname)
  # Handle dependencies
  if(!loadDependencies(lesPath))return(FALSE)
  # Initialize list of official variables
  e$snapshot <- list()
  # initialize course lesson, assigning lesson-specific variables
  initFile <- file.path(lesPath,"initLesson.R")
  if(file.exists(initFile))local({
    source(initFile, local=TRUE)
    # NOTE: the order of the next two statements is important,
    # since a reference to e$snapshot will cause e to appear in
    # local environment.
    xfer(environment(), globalenv())
    # Only add to the "official record" if are auto-detecting new variables
    if(isTRUE(customTests$AUTO_DETECT_NEWVAR)) {
      e$snapshot <- as.list(environment())
    }
  })
  # load any custom tests, returning FALSE if they fail to load
  clearCustomTests()
  loadCustomTests(lesPath)

  # Attached class to content based on file extension
  class(dataName) <- get_content_class(dataName)

  # Parse content, returning object of class "lesson"
  return(parse_content(dataName, e))
}

restoreUserProgress.default <- function(e, selection){
  # read the progress file
  temp <- readRDS(file.path(e$udat, selection))
  # transfer its contents to e
  xfer(temp, e)
  # Since loadDepencies will have worked once, we don't
  # check for failure here. Perhaps we should.
  loadDependencies(e$path)
  # source the initLesson.R file if it exists
  initf <- file.path(e$path, "initLesson.R")
  if(file.exists(initf))local({
    source(initf, local=TRUE)
    xfer(environment(), globalenv())
  })
  # transfer swirl's "official" list of variables to the
  # global environment.
  if(length(e$snapshot)>0){
    xfer(as.environment(e$snapshot), globalenv())
  }
  # load any custom tests
  clearCustomTests()
  loadCustomTests(e$path)
  # Restore figures which precede current row (Issue #44)
  idx <- 1:(e$row - 1)
  figs <- e$les[idx,"Figure"]
  # Check for missing Figure column (Issue #47) and omit NA's
  if(is.null(figs) || length(figs) == 0)return()
  figs <- figs[!is.na(figs)]
  figs <- file.path(e$path, figs)
  lapply(figs, function(x)source(file=x, local=TRUE))
}

loadInstructions.default <- function(e){
  e$instr <- list(present, waitUser, testResponse)
}


# UTILITIES

progressName <- function(courseName, lesName){
  pn <- paste0(courseName, "_", lesName, ".rda")
  gsub(" ", "_", pn)
}

inProgress <- function(e){
  pfiles <- dir(e$udat)[grep("[.]rda$", dir(e$udat))]
  pfiles <- gsub("[.]rda", "", pfiles)
  pfiles <- str_trim(gsub("_", " ", pfiles))
  return(pfiles)
}

completed <- function(e){
  pfiles <- dir(e$udat)[grep("[.]done$", dir(e$udat))]
  pfiles <- gsub("[.]done", "", pfiles)
  pfiles <- gsub("[.]rda", "", pfiles)
  pfiles <- str_trim(gsub("_", " ", pfiles))
  return(pfiles)
}

get_manifest <- function(course_dir) {
  man <- readLines(file.path(course_dir, "MANIFEST"), warn=FALSE)
  # Remove leading and trailing whitespace
  man <- str_trim(man)
  # Remove empty lines
  man <- man[which(man != "")]
}

# Take vector of lessons and return in order given by manifest.
# Any courses not included in manifest are excluded!
order_lessons <- function(current_order, manifest_order) {
  current_order[match(manifest_order, current_order)]
}

courseDir.default <- function(e){
  # e's only role is to determine the method used
  file.path(find.package("swirl"), "Courses")
}

# Default for determining the user
getUser <- function()UseMethod("getUser")
getUser.default <- function(){"swirladmin"}
