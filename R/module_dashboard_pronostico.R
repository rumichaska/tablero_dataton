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
            uc_graph_map(id = ns("map")),
            card(
                card_header("Métricas de modelamiento"),
                card_body(reactableOutput(outputId = ns("table"))),
                card_body(verbatimTextOutput(outputId = ns("pruebas")))
            ),
            col_widths = breakpoints(
                sm = 12,
                md = 12,
                lg = c(12, 5, 7)
            )
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
                var_dist$data()
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

            ## Mapa de ubicación ----
            sc_graph_map(
                id = "map",
                data = db_map,
                font_size = 0
            )

            ## Tabla de resumen ----
            output$table <- renderReactable({
                db_model() |>
                    collect() |>
                    reactable()
            })

            ## TEST ----
            output$pruebas <- renderPrint(db_map())
        }
    )
}

# nolint end
