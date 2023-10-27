# LIBRERIAS ----

# library(markdown)

# library(glue)
# library(aweek)
library(lubridate, warn.conflicts = FALSE)

# library(arrow, warn.conflicts = FALSE)
# library(dplyr, warn.conflicts = FALSE)

# library(shinyWidgets)
# library(reactable)
# library(echarts4r)
library(bsicons)
library(bslib, warn.conflicts = FALSE)
library(shiny)

## Funciones del aplicativo ----
# source("./src/util.R")

# nolint start: object_usage_linter.

# GLOBALES ----

# Parámetros de entrada
fecha_actual <- Sys.Date()
year <- year(fecha_actual)

# Cálculo de semana de análisis
# week <- 33
week <- epiweek(fecha_actual) - 1
if (wday(fecha_actual) <= 3) {
    week <- week - 1
}

# Tema app
app_theme <- bs_theme(
    primary = "#385C91",
    bootswatch = "flatly"
)

# UI ----

ui <- page_navbar(
    # Módulo de pronóstico de eventos
    nav_panel(
        up_frcst(id = "forecast"),
        title = "Pronóstico",
        value = "pronostico"
    ),
    # Acerca
    # nav_panel(
    #     layout_columns(
    #         col_widths = c(-2, 8),
    #         withMathJax(includeMarkdown("./Acerca.md"))
    #     ),
    #     title = "Acerca",
    #     icon = bs_icon("info-circle-fill")
    # ),
    # Logo
    # nav_spacer(),
    # nav_item(
    #     a(
    #         href = "https://www.dge.gob.pe/portalnuevo/",
    #         class = "p-0",
    #         style = "height: 40px;",
    #         img(src = "cdc_48px.png", height = "40")
    #     )
    # ),
    title = "DENGUE DATATON",
    padding = 0,
    inverse = FALSE,
    theme = bs_add_rules(
        theme = app_theme,
        sass::sass_file("./www/styles.scss")
    )
)

# SERVER ----

server <- function(input, output, session) {
    ## Dashboard: Diresa ----
    sp_frcst(id = "forecast", year = year, week = week)
}

# APP ---------------------------------------------------------------------

shinyApp(ui, server)

# nolint end
