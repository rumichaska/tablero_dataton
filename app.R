# LIBRERIAS ----

library(markdown)

library(glue)
library(lubridate, warn.conflicts = FALSE)

library(sf)
library(arrow, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)

library(shinyWidgets)
library(reactable)
library(echarts4r)
library(bsicons)
library(bslib, warn.conflicts = FALSE)
library(shiny)

# nolint start: object_usage_linter.

# GLOBALES ----

# Tema app
app_theme <- bs_theme(
    pink = "#F1C1C0",
    bootswatch = "litera"
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
        title = "Materiales y Métodos",
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
    title = "PRONÓSTICO DE CASOS DE DENGUE",
    padding = 0,
    bg = bs_get_variables(app_theme, "primary"),
    inverse = TRUE,
    theme = bs_add_rules(
        theme = app_theme,
        rules = sass::sass_file("./www/styles.scss")
    )
)

# SERVER ----

server <- function(input, output, session) {
    ## Data ----

    # Información de modelamiento
    db <- reactive({
        read_parquet("./data/processed/shiny_data.parquet", as_data_frame = FALSE)
    })

    mt <- reactive({
        read_parquet("./data/processed/shiny_metricas.parquet", as_data_frame = FALSE)
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

    ## Dashboard: Modelamiento ----
    sp_frcst(id = "forecast", data = db, metrics = mt, shp = shp)
}

# APP ---------------------------------------------------------------------

shinyApp(ui, server)

# nolint end
