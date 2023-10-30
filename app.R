# LIBRERIAS ----

library(markdown)

# library(glue)
# library(aweek)
library(lubridate, warn.conflicts = FALSE)

library(sf)
library(arrow, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)

# library(shinyWidgets)
library(reactable)
library(echarts4r)
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
    # primary = "#385C91",
    bootswatch = "journal"
)

# UI ----

ui <- page_navbar(
    # Módulo de pronóstico de eventos
    nav_panel(
        up_frcst(id = "forecast"),
        title = "Tablero"
    ),
    # Acerca
    nav_panel(
        layout_columns(
            col_widths = c(-2, 8),
            withMathJax(includeMarkdown("./Acerca.md"))
        ),
        title = "Acerca",
        icon = bs_icon("info-circle-fill")
    ),
    # Github
    nav_spacer(),
    nav_item(
        a(
            icon("github"),
            href = "https://github.com/rumichaska/tablero_dataton",
            class = "p-0",
        )
    ),
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
    ## Data ----

    # Información de modelamiento
    db <- reactive({
        read_parquet("./data/processed/shiny_data.parquet", as_data_frame = FALSE)
    })

    # Información de límites político-administrativos
    shp <- reactive({
        # Salidas
        list(
            s_depa = st_read("./data/geo/geo_peru.gpkg", layer = "departamento"),
            s_prov = st_read("./data/geo/geo_peru.gpkg", layer = "provincia"),
            s_dist = st_read("./data/geo/geo_peru.gpkg", layer = "distrito")
        )
    })

    ## Dashboard: Diresa ----
    sp_frcst(id = "forecast", data = db, shp = shp)
}

# APP ---------------------------------------------------------------------

shinyApp(ui, server)

# nolint end
