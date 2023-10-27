# nolint start: object_usage_linter.

# UI ----

#' Función constructora de la interface del componente de filtro
#'
#' @param id Identificador del módulo
#' @param label Etiqueta del filtro
#' @param custom Lista personalizada de opciones del filtro, debe ser ingresada
#' como: `c("etiqueta1" = "valor1", "etiqueta2" = "valor2", ...)`
#' @param with Ancho del elemento, se hereda de `selectizeInput()`
#' @return Selector con opciones para filtrar información
uc_filter <- function(id,
                      label = NULL,
                      custom = NULL,
                      width = NULL) {
    # Namespace
    ns <- NS(id)

    # Condicionales
    choices_list <- c("..." = "", custom)
    if (is.null(custom)) {
        choices_list <- c("..." = "")
    }
    if (is.null(label)) {
        title <- label
    }

    # UI
    selectizeInput(
        inputId = ns("filter"),
        label = label,
        choices = choices_list,
        width = width
    )
}

# SERVER ----

#' Función del server del componente de filtro
#'
#' @param id Identificador del módulo
#' @param data Información de ingreso, debe ser un elemento reactivo
#' @param variable Columna de la `data` de donde se obtendran los elementos
#' del filtro
#' @param total Etiqueta cuando se incluye un filtro para totales
#' @param custom Cuando `uc_filtro()` tiene lista personaliza de opciones
#' @return Retorna elementos reactivos de `data` e `input` según el filtro
#' aplicado
sc_filter <- function(id,
                      data,
                      variable,
                      total = FALSE,
                      custom = FALSE) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    moduleServer(
        id,
        function(input, output, session) {
            req(data, variable)

            # Captura de valores de la variable
            unique_choices <- reactive({
                choices <- sort(
                    data() |>
                        distinct(.data[[variable]]) |>
                        collect() |>
                        pull()
                )
                # Condicional
                if (is.character(total)) {
                    choices <- c(total, choices)
                }
                # Salidas
                return(choices)
            })

            # Actualización de filtros
            if (custom) {
                observe({
                    updateSelectizeInput(
                        session,
                        inputId = "filter"
                    )
                })
            } else {
                observe({
                    updateSelectizeInput(
                        session,
                        inputId = "filter",
                        choices = c("..." = "", unique_choices())
                    )
                })
            }

            # Captura data filtrada
            data_out <- reactive({
                req(input$filter)
                d <- data() |> filter(.data[[variable]] == input$filter)
                if (custom) {
                    d <- data() |> filter(stringr::str_detect(.data[[variable]], input$filter))
                }
                return(d)
            })

            # Salidas
            list(
                data = data_out,
                input = reactive(input$filter)
            )
        }
    )
}

# nolint end
