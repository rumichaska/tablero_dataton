# nolint start: object_usage_linter.

# UI ----

#' Interface de gráfico individual
#'
#' @param id Identificador del módulo
#' @param sb Parámetro {choices} del `radioButtons()` del `sidebar()` del
#' módulo, debe ser ingresado como: `c("etiqueta1" = 1, "etiqueta2" = 2, ...)`
#' @param sl Parámetro {label} del `radioButtons()` del `sidebar()`
#' @param sd Parámetro de la opción seleccionada por defecto del `radioButtons()`
#' del `sidebar()` del módulo
#' @param sn Contenido de las notas del `sidebar()`
#' @return Card del gráfico
uc_graph_single <- function(id,
                            sb = NULL,
                            sl = NULL,
                            sd = 1,
                            sn = NULL) {
    # Namespace
    ns <- NS(id)

    # Tema del aplicativo
    c_theme <- bs_get_variables(bs_theme(), "gray-800")

    # sidebar del card
    if (!is.null(sb)) {
        sidebar_component <- sidebar(
            radioButtons(
                inputId = ns("sb_toggle"),
                label = NULL,
                choices = sb,
                selected = sd,
            ),
            span(bs_icon("info-circle"), sn, class = "note-content"),
            open = FALSE,
            title = sl,
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
#' @return Gráfico interactivo
sc_graph_model <- function(id,
                           data,
                           font_size = 2) {
    # Control de elementos reactivos
    stopifnot(is.reactive(data))
    moduleServer(
        id,
        function(input, output, session) {
            req(data)

            # Título de gráfico
            g_title <- eventReactive(data(), {
                t <- "Gráfico de modelamiento (provisional)"
            })

            # Gráfico
            grp <- eventReactive(data(), {
                data() |>
                    group_by(fuente) |>
                    e_charts(x = axis) |>
                    e_title(
                        g_title(),
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
                        # selected = list("Acumulado" = FALSE),
                        textStyle = list(
                            fontWeight = "normal",
                            fontSize = 10 + font_size
                        )
                    ) |>
                    e_grid(
                        left = "5%",
                        top = 80,
                        right = "7%",
                        bottom = 60
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
                        name = "Casos",
                        serie = casos,
                        itemStyle = list(color = "#000000")
                    ) |>
                    e_line(
                        name = "Pronóstico",
                        serie = pronostico,
                        itemStyle = list(color = "#E74C3C")
                    ) |>
                    # e_mark_line(
                    #     silent = TRUE,
                    #     label = list(
                    #         color = "inherit",
                    #         fontWeight = "normal",
                    #         fontSize = 10 + font_size
                    #     ),
                    #     data = list(
                    #         xAxis = as.character(week()),
                    #         lineStyle = list(color = "#0F4164")
                    #     ),
                    #     title = "Semana de\nAnálisis",
                    #     animation = FALSE
                    # ) |>
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
                        filter(value == 1) |>
                        pull(distrito)
                    t <- "Mapa de ubicación"
                    s <- glue::glue("Distrito: {d}")
                    list(title = t, subtitle = s, dist = d)
                })

                # Ploteo
                g <- s_dist |>
                    e_charts(x = distrito) |>
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
                        # name = "Distrito:",
                        roam = FALSE,
                        aspectScale = 1,
                        nameProperty = "distrito",
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
                            list(value = 0, label = "Otros", color = "#FFFFFF"),
                            list(value = 1, label = g_title()$dist, color = "#B13000")
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
