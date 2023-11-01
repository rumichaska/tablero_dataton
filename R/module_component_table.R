# nolint start: object_usage_linter.

# UI ----

#' Interface de tablas
#'
#' @param id Identificador del módulo
#' @return Card para la tabla de resumen
uc_table <- function(id) {
    # Namespace
    ns <- NS(id)

    # UI
    card(
        card_body(
            reactableOutput(outputId = ns("table")),
        ),
        full_screen = TRUE
    )
}

# SERVER ----

#' Server de la tabla de resumen
#'
#' @param id Identificador del módulo
#' @param data Información de ingreso, debe ser un elemento reactivo
#' @param font_size Incremento del tamaño base de las fuentes de las tablas,
#' el valor por defecto es de 2
#' @return Tabla de resumen
sc_table <- function(id,
                     data,
                     font_size = 4) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    moduleServer(
        id,
        function(input, output, session) {
            req(data)

            # Tema del aplicativo
            c_theme <- bs_get_variables(bs_current_theme(), c("primary", "white"))

            # Tema de la tabla
            header_theme <- reactableTheme(
                groupHeaderStyle = list(
                    color = c_theme[["white"]],
                    backgroundColor = c_theme[["primary"]],
                    borderColor = c_theme[["primary"]]
                ),
                headerStyle = list(
                    color = c_theme[["white"]],
                    backgroundColor = c_theme[["primary"]],
                    borderColor = c_theme[["primary"]],
                    fontWeight = "bold"
                ),
                style = list(fontSize = 12 + font_size)
            )

            # Personalización de columnas y valores
            custom_col <- list(
                ubigeo = colDef(
                    name = "Ubigeo",
                    sticky = "left",
                    style = list(borderRight = "1px solid"),
                    headerStyle = list(borderRight = "1px solid")
                ),
                departamento = colDef(name = "Departamento"),
                provincia = colDef(name = "Provincia"),
                distrito = colDef(name = "Distrito"),
                ano = colDef(name = "Año", filterable = TRUE),
                semana = colDef(name = "Semana epidemiológica", filterable = TRUE),
                casos = colDef(
                    name = "Casos obsevados",
                    style = list(borderRight = "1px solid"),
                    headerStyle = list(borderRight = "1px solid")
                ),
                pronostico = colDef(name = "Casos esperados"),
                fuente = colDef(name = "Tipo", filterable = TRUE)
            )

            # Tabla de resumen
            output$table <- renderReactable({
                data() |>
                    reactable(
                        defaultColDef = colDef(
                            minWidth = 100
                        ),
                        columns = custom_col,
                        highlight = TRUE,
                        bordered = TRUE,
                        outlined = TRUE,
                        wrap = FALSE,
                        pagination = TRUE,
                        showPageSizeOptions = TRUE,
                        pageSizeOptions = c(25, 50, 100),
                        defaultPageSize = 50,
                        resizable = TRUE,
                        language = reactableLang(
                            searchPlaceholder = "Buscar...",
                            noData = "No se cuenta con información"
                        ),
                        theme = header_theme
                    )
            })
        }
    )
}

# nolint end
