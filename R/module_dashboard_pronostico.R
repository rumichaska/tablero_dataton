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
                     year,
                     week) {
    moduleServer(
        id,
        function(input, output, session) {
            # Gráfico de pronóstico de eventos ----
            output$frcst <- renderUI({
                p(bs_icon("graph-up"), " Gráfico")
            })

            # Indicador ----
            output$kpi <- renderUI({
                p(bs_icon("info-circle"), " Información")
            })

            # Tabla de resumen ----
            output$table <- renderUI({
                p(bs_icon("table"), " Tabla")
            })

            # Gráfico de condiciones climáticas ----
            output$clima <- renderUI({
                p(bs_icon("cloud-sun"), " Gráfico")
            })
        }
    )
}

# nolint end
