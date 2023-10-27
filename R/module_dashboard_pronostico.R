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
            selectInput(
                inputId = ns("enfermedad"),
                label = tags$b("Enfermedad"),
                choices = c("..." = "", "DENGUE")
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
            card(
                card_header("Gráfico de pronóstico de eventos"),
                card_body(
                    htmlOutput(outputId = ns("frcst")),
                    class = "align-items-center fs-1",
                    fill = FALSE
                )
            ),
            card(
                card_header("Indicador"),
                card_body(
                    htmlOutput(outputId = ns("kpi")),
                    class = "align-items-center fs-1",
                    fill = FALSE
                )
            ),
            col_widths = breakpoints(
                sm = 12,
                md = 12,
                lg = c(8, 4)
            )
        ),
        layout_columns(
            card(
                card_header("Tabla de resumen"),
                card_body(
                    htmlOutput(outputId = ns("table")),
                    class = "align-items-center fs-1",
                    fill = FALSE
                )
            ),
            card(
                card_header("Gráfico de condiciones climáticas"),
                card_body(
                    htmlOutput(outputId = ns("clima")),
                    class = "align-items-center fs-1",
                    fill = FALSE
                )
            ),
            col_widths = breakpoints(
                sm = 12,
                md = 12,
                lg = c(5, 7)
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
