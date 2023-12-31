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
            # verbatimTextOutput(ns("pruebas")),
            gap = 3
        ),
        # Main panel
        layout_columns(
            uc_graph_single(id = ns("model")),
            uc_graph_single(
                id = ns("metrics"),
                sb = "Nota:",
                sn = "El número que acompaña a la variable se refiere al número 
                de semanas de retraso. Por ejemplo: en Casos (4) se tomó en cuenta
                el número de casos de hace 4 semanas para predecir el número de
                casos actual"
            ),
            uc_graph_map(id = ns("map")),
            uc_table(id = ns("table")),
            col_widths = breakpoints(
                sm = 12,
                md = 12,
                lg = c(8, 4, 5, 7)
            ),
            row_heights = c(6)
        ),
        fillable = TRUE
    )
}

# SERVER ----
sp_frcst <- function(id,
                     data,
                     metrics,
                     shp) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    stopifnot(is.reactive(metrics))
    stopifnot(is.reactive(shp))
    moduleServer(
        id,
        function(input, output, session) {
            req(data, metrics, shp)

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
                # Información
                db_in <- var_dist$data() |>
                    collect()
                # Semana de corte de train | test | forecast
                date_t <- max(db_in$fecha[db_in$fuente == "train"], na.rm = TRUE)
                date_f <- max(db_in$fecha[db_in$fuente == "test"], na.rm = TRUE)
                c_t <- paste(epiyear(date_t), epiweek(date_t), sep = "-")
                c_f <- paste(epiyear(date_f), epiweek(date_f), sep = "-")
                # Formato ancho
                db <- db_in |>
                    tidyr::pivot_wider(
                        names_from = fuente,
                        values_from = c(casos, pronostico)
                    )
                # Salidas
                list(data = db, cut_t = c_t, cut_f = c_f)
            })

            # Base de métricas del modelamiento
            db_metrics <- eventReactive(input$run, {
                req(var_depa$input(), var_prov$input(), var_dist$input())
                # Variables del modelo
                metrics() |>
                    filter(
                        departamento == var_depa$input(),
                        provincia == var_prov$input(),
                        distrito == var_dist$input()
                    ) |>
                    collect()
            })

            # Base del mapa
            db_map <- eventReactive(input$run, {
                req(var_depa$input(), var_prov$input(), var_dist$input())
                # Bases de ingreso
                data <- data() |> collect()
                distrito <- var_dist$data() |> collect()
                # Filtros
                f_depa <- var_depa$input()
                f_dist <- unique(distrito$ubigeo)
                # Listado de ubigeos modelados
                d_ubigeo <- unique(data$ubigeo[data$ubigeo != f_dist])
                # Polígonos
                s_prov <- shp()$s_prov |> filter(departamen == f_depa)
                s_dist <- shp()$s_dist |>
                    filter(departamen == f_depa) |>
                    mutate(
                        value = case_when(
                            ubigeo %in% d_ubigeo ~ 1,
                            ubigeo == f_dist ~ 2,
                            .default = 0
                        ),
                        l_distrito = glue("{distrito} ({ubigeo})")
                    )
                # Salidas
                list(
                    s_prov = s_prov,
                    s_dist = s_dist
                )
            })

            # Base de la tabla
            db_table <- eventReactive(input$run, {
                # Selección de variables
                db <- var_dist$data() |>
                    collect() |>
                    arrange(desc(axis)) |>
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

            ## Alertas ----

            # Alerta cuando no se seleccionan todas las variables de los filtros
            observeEvent(input$run, {
                # Condición para lanzar alerta
                con <- var_depa$input() == "" | var_prov$input() == "" | var_dist$input() == ""
                # Alerta cuando se cumple la condición
                if (con) {
                    sendSweetAlert(
                        session = session,
                        title = "Hay un problema!",
                        text = "Debe seleccionar departamento, provincia y distrito",
                        type = "error"
                    )
                }
            })

            ## Gráfico de modelamiento ----
            sc_graph_model(
                id = "model",
                data = db_model,
                font_size = 0
            )

            ## Métricas de modelamiento ----
            sc_graph_metrics(
                id = "metrics",
                data = db_metrics,
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
            output$pruebas <- renderPrint(db_model())
        }
    )
}

# nolint end
