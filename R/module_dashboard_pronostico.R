# nolint start: object_usage_linter, line_length_linter.

# UI ----
up_frcst <- function(id) {
    # Namespace
    ns <- NS(id)

    # Esquema
    layout_sidebar(
        # Sidebar panel
        sidebar = sidebar(
            title = "Parámetros de interés",
            uc_filter(
                id = ns("depa"),
                label = "Departamento:",
                width = "auto"
            ),
            uc_filter(
                id = ns("prov"),
                label = "Provincia:",
                width = "auto"
            ),
            uc_filter(
                id = ns("dist"),
                label = "Distrito:",
                width = "auto"
            ),
            actionButton(
                inputId = ns("run"),
                label = "Filtrar",
                icon = icon("cog"),
                class = "btn btn-outline-success"
            ),
            gap = 3
        ),
        # Main panel
        layout_columns(
            uc_graph_single(id = ns("model")),
            card("Métricas"),
            uc_graph_map(id = ns("map")),
            uc_table(id = ns("table")),
            col_widths = breakpoints(
                sm = 12,
                md = 12,
                lg = c(10, 2, 5, 7)
            ),
            row_heights = c(6)
        ),
        fillable = TRUE
    )
}

# SERVER ----
sp_frcst <- function(id,
                     data,
                     shp) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    stopifnot(is.reactive(shp))
    moduleServer(
        id,
        function(input, output, session) {
            ## Filtrar y generar información ----

            # Filtrar a nivel de distrito
            var_depa <- sc_filter(
                id = "depa",
                data = data,
                variable = "departamento"
            )
            var_prov <- sc_filter(
                id = "prov",
                data = var_depa$data,
                variable = "provincia"
            )
            var_dist <- sc_filter(
                id = "dist",
                data = var_prov$data,
                variable = "distrito"
            )

            # Base de modelamiento
            db_model <- eventReactive(input$run, {
                var_dist$data() |> collect()
            })

            # Base del mapa
            db_map <- eventReactive(input$run, {
                # Filtros
                f_depa <- var_depa$input()
                f_prov <- var_prov$input()
                f_dist <- var_dist$input()
                # Polígonos
                s_depa <- shp()$s_depa |> filter(departamen == f_depa)
                s_prov <- shp()$s_prov |> filter(departamen == f_depa)
                s_dist <- shp()$s_dist |>
                    filter(departamen == f_depa) |>
                    mutate(value = if_else(distrito == f_dist, 1, 0))
                # Salidas
                list(
                    s_depa = s_depa,
                    s_prov = s_prov,
                    s_dist = s_dist
                )
            })

            # Base de la tabla
            db_table <- eventReactive(input$run, {
                # Selección de variables
                db <- db_model() |>
                    select(
                        ubigeo,
                        departamento,
                        provincia,
                        distrito,
                        ano = year,
                        semana = epiweek,
                        casos,
                        pronostico,
                        fuente
                    )
                # Salidas
                return(db)
            })

            ## Gráfico de modelamiento ----
            sc_graph_model(
                id = "model",
                data = db_model,
                font_size = 0
            )

            ## Mapa de ubicación ----
            sc_graph_map(
                id = "map",
                data = db_map,
                font_size = 0
            )

            ## Tablas de resumen ----
            sc_table(
                id = "table",
                data = db_table,
                font_size = 0
            )

            ## TEST ----
            # output$pruebas <- renderPrint(db_map())
        }
    )
}

# nolint end
