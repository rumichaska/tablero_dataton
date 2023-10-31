#! /usr/bin/env Rscript

# REQUISITOS --------------------------------------------------------------

# Haber conectado nuestro token personal, este paso solo se realiza 1 vez. La
# información del token y secret key la encontramos en nuestra cuenta de
# www.shinyapps.io

# rsconnect::setAccountInfo(
#     name = "poner usuario",
#     token = "poner token personal",
#     secret = "poner clave secreta personal"
# )

# PASO 0: -----------------------------------------------------------------

# Eliminar proyecto de www.shinyapps.io, solo cuando se desea cargar nuevamente
# el proyecto desde 0

# rsconnect::terminateApp("shiny_dataton")
# rsconnect::purgeApp("shiny_dataton")
# unlink("./rsconnect", recursive = TRUE)

# PASO 1: -----------------------------------------------------------------

# Desplegar app
rsconnect::deployApp(appName = "shiny_dataton", forceUpdate = TRUE)
