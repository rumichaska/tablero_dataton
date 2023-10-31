# nolint start: object_usage_linter.

# UI ----

#' Interface de gráfico individual
#'
#' @param id Identificador del módulo
#' @param sb Parámetro para mostrar el `sidebar()`
#' @param sn Contenido de las notas del `sidebar()`
#' @return Card del gráfico
uc_graph_single <- function(id,
                            sb = NULL,
                            sn = NULL) {
    # Namespace
    ns <- NS(id)

    # Tema del aplicativo
    c_theme <- bs_get_variables(bs_theme(), "default")

    # sidebar del card
    if (!is.null(sb)) {
        sidebar_component <- sidebar(
            span(sn, class = "note-content"),
            width = 200,
            open = FALSE,
            title = sb,
            bg = c_theme[[1]]
        )
    }

    # echarts4rOutput del card_body
    echart_component <- card_body(
        echarts4rOutput(outputId = ns("echart"))
    )

    # UI
    if (is.null(sb)) {
        card(
            echart_component,
            full_screen = TRUE
        )
    } else {
        card(
            layout_sidebar(
                sidebar = sidebar_component,
                echart_component,
                gap = 0,
                padding = 0
            ),
            full_screen = TRUE
        )
    }
}

#' Interface del mapa
#'
#' @param id Identificador del módulo
#' @return Card del mapa
uc_graph_map <- function(id) {
    # Namespace
    ns <- NS(id)

    # UI
    card(
        echarts4rOutput(outputId = ns("echart")),
        full_screen = TRUE
    )
}

# SERVER ----

#' Server del gráfico del modelamiento
#'
#' @param id Identificador del módulo
#' @param data Información de ingreso, debe ser un elemento reactivo
#' @param font_size Incremento del tamaño base de {fontSize} de los gráficos,
#' el valor por defecto es de 2
#' @return Gráfico de modelamiento con train y test data
sc_graph_model <- function(id,
                           data,
                           font_size = 2) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    moduleServer(
        id,
        function(input, output, session) {
            req(data)

            # Tema del aplicativo
            c_theme <- bs_get_variables(
                theme = bs_current_theme(),
                varnames = c("danger", "yellow", "dark", "gray-500", "primary")
            )

            # Gráfico
            grp <- eventReactive(data(), {
                data()$data |>
                    arrange(axis) |>
                    e_charts(x = axis) |>
                    e_title(
                        text = "Modelamiento de dengue",
                        textStyle = list(
                            fontWeight = "bold",
                            fontSize = 16 + font_size
                        )
                    ) |>
                    e_title(
                        subtext = "Dataton - MINSA",
                        subtextStyle = list(
                            fontStyle = "italic",
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        left = "5%",
                        bottom = 0
                    ) |>
                    e_legend(
                        top = 30,
                        textStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_grid(
                        left = "5%",
                        top = 80,
                        bottom = 90
                    ) |>
                    e_x_axis(
                        type = "category",
                        name = "Semana epidemiológica",
                        nameLocation = "center",
                        nameTextStyle = list(
                            fontWeight = "normal",
                            fontSize = 12 + font_size
                        ),
                        nameGap = 25,
                        axisLine = list(show = TRUE),
                        axisTick = list(alignWithLabel = TRUE),
                        axisLabel = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        splitLine = list(show = FALSE)
                    ) |>
                    e_y_axis(
                        name = "Casos",
                        nameTextStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        axisLine = list(show = TRUE),
                        axisTick = list(show = TRUE),
                        axisLabel = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        splitLine = list(show = FALSE)
                    ) |>
                    e_tooltip(
                        trigger = "axis",
                        textStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_line(
                        serie = casos_test,
                        name = "Casos test",
                        symbol = "none",
                        itemStyle = list(color = c_theme[[1]]),
                        emphasis = list(
                            focus = "series",
                            blur = "coordinateSystem"
                        )
                    ) |>
                    e_line(
                        serie = casos_train,
                        name = "Casos train",
                        symbol = "none",
                        itemStyle = list(color = c_theme[[2]]),
                        emphasis = list(
                            focus = "series",
                            blur = "coordinateSystem"
                        )
                    ) |>
                    e_line(
                        serie = pronostico_test,
                        name = "Pronóstico test",
                        symbol = "none",
                        itemStyle = list(color = c_theme[[3]]),
                        emphasis = list(
                            focus = "series",
                            blur = "coordinateSystem"
                        )
                    ) |>
                    e_line(
                        serie = pronostico_train,
                        name = "Pronóstico train",
                        symbol = "none",
                        itemStyle = list(color = c_theme[[4]]),
                        emphasis = list(
                            focus = "series",
                            blur = "coordinateSystem"
                        )
                    ) |>
                    e_mark_line(
                        silent = TRUE,
                        symbol = "none",
                        label = list(
                            color = "inherit",
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        lineStyle = list(width = 2),
                        data = list(
                            xAxis = data()$cut,
                            lineStyle = list(color = c_theme[[5]])
                        ),
                        title = "<- Train |  Test ->",
                        animation = FALSE
                    ) |>
                    e_datazoom(x_index = 0, bottom = 25, height = 25) |>
                    e_toolbox_feature(feature = "dataZoom", show = FALSE) |>
                    e_toolbox_feature(feature = "saveAsImage", title = "png")
            })

            # Render de gráfico
            output$echart <- renderEcharts4r({
                grp()
            })
        }
    )
}

#' Server del gráfico de las métricas del modelo
#'
#' @param id Identificador del módulo
#' @param data Información vectorial de ingreso, debe ser un elemento reactivo
#' @return Gráfico de las métricas del modelo seleccionado
sc_graph_metrics <- function(id,
                             data,
                             font_size = 2) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    moduleServer(
        id,
        function(input, output, session) {
            req(data)

            # Tema del aplicativo
            c_theme <- bs_get_variables(
                theme = bs_current_theme(),
                varnames = c("primary")
            )

            # Título de gráfico
            g_title <- eventReactive(data(), {
                d <- unique(data()$modelo)
                t <- "Importancia de las variables"
                s <- glue("Modelo elegido: {d}")
                # Salidas
                list(title = t, subtitle = s)
            })

            # Gráfico
            grp <- eventReactive(data(), {
                data() |>
                    e_charts(x = variable) |>
                    e_title(
                        text = g_title()$title,
                        subtext = g_title()$subtitle,
                        textStyle = list(
                            fontWeight = "bold",
                            fontSize = 16 + font_size
                        ),
                        subtextStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_title(
                        subtext = "Dataton - MINSA",
                        subtextStyle = list(
                            fontStyle = "italic",
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        left = "5%",
                        bottom = 0
                    ) |>
                    e_legend(show = FALSE) |>
                    e_grid(
                        top = 45,
                        bottom = 20,
                        containLabel = TRUE
                    ) |>
                    e_x_axis(
                        type = "category",
                        axisLine = list(show = TRUE),
                        axisTick = list(alignWithLabel = TRUE),
                        axisLabel = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        splitLine = list(show = FALSE)
                    ) |>
                    e_y_axis(
                        name = "Score",
                        nameTextStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        axisLabel = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_tooltip(
                        trigger = "axis",
                        axisPointer = list(
                            type = "line",
                            axis = "y",
                            label = list(show = TRUE)
                        ),
                        textStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_bar(
                        serie = score,
                        name = "Score",
                        itemStyle = list(color = c_theme[[1]])
                    ) |>
                    e_flip_coords() |>
                    e_toolbox_feature(feature = "saveAsImage", title = "png")
            })

            # Render de gráfico
            output$echart <- renderEcharts4r({
                grp()
            })
        }
    )
}



#' Server del gráfico de mapa distrital
#'
#' @param id Identificador del módulo
#' @param data Información vectorial de ingreso, debe ser un elemento reactivo
#' @return Mapa del distrito de interés
sc_graph_map <- function(id,
                         data,
                         font_size = 2) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    moduleServer(
        id,
        function(input, output, session) {
            req(data)

            # Tema del aplicativo
            c_theme <- bs_get_variables(
                theme = bs_current_theme(),
                varnames = c("white", "gray-500", "danger")
            )

            # Gráfico
            grp <- eventReactive(data(), {
                # Información de ingreso
                s_prov <- data()$s_prov
                s_dist <- data()$s_dist

                # Registro de mapa en formato json
                json_prov <- geojsonio::geojson_list(s_prov)
                json_dist <- geojsonio::geojson_list(s_dist)

                # Título de gráfico
                g_title <- eventReactive(data(), {
                    d <- s_dist |>
                        as.data.frame() |>
                        filter(value == 2) |>
                        pull(distrito)
                    t <- "Mapa de ubicación"
                    s <- glue("Distrito: {d}")
                    # Salidas
                    list(title = t, subtitle = s, dist = d)
                })

                # Ploteo
                g <- s_dist |>
                    e_charts(x = l_distrito) |>
                    e_title(
                        text = g_title()$title,
                        subtext = g_title()$subtitle,
                        textStyle = list(
                            fontWeight = "bold",
                            fontSize = 16 + font_size
                        ),
                        subtextStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_title(
                        subtext = "Dataton - MINSA",
                        subtextStyle = list(
                            fontStyle = "italic",
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        ),
                        left = "5%",
                        bottom = 0
                    ) |>
                    e_tooltip(
                        trigger = "item",
                        formatter = htmlwidgets::JS("
                            function(params) {
                            return('<b>Distrito: </b>' + '<br/>' + params.name)
                            }
                        "),
                        textStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_map_register(name = "distrito", json = json_dist) |>
                    e_map(
                        serie = value,
                        map = "distrito",
                        roam = FALSE,
                        aspectScale = 1,
                        nameProperty = "l_distrito",
                        selectedMode = FALSE,
                        emphasis = list(
                            label = list(show = FALSE),
                            itemStyle = list(
                                areaColor = "inherit",
                                borderColor = "black",
                                borderWidth = 1,
                                shadowBlur = 5
                            )
                        )
                    ) |>
                    e_visual_map(
                        serie = value,
                        type = "piecewise",
                        pieces = list(
                            list(value = 0, color = c_theme[[1]]),
                            list(value = 1, color = c_theme[[2]]),
                            list(value = 2, color = c_theme[[3]])
                        ),
                        show = FALSE
                    ) |>
                    e_map_register(name = "provincia", json = json_prov) |>
                    e_map(
                        serie = provincia,
                        map = "provincia",
                        roam = FALSE,
                        aspectScale = 1,
                        nameProperty = "provincia",
                        selectedMode = FALSE,
                        itemStyle = list(
                            areaColor = "rgba(0, 0, 0, 0)",
                            borderWidth = 2
                        ),
                        emphasis = list(disabled = TRUE),
                        silent = TRUE
                    ) |>
                    e_toolbox_feature(feature = "saveAsImage", title = "png")
                return(g)
            })


            # Render de gráfico
            output$echart <- renderEcharts4r({
                grp()
            })
        }
    )
}

# nolint end
