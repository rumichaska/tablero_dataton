# LIBRERIAS ----

library(glue)
library(stringr)
library(arrow, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(readr)
library(dplyr, warn.conflicts = FALSE)

# UTILIDADES ----

# Función limpieza
clean_ubigeo <- function(.data, type = NULL) {
    d <- .data |>
        mutate(
            ubigeo = as.character(ubigeo),
            ubigeo = case_when(
                nchar(ubigeo) == 5 ~ paste0(strrep("0", 1), ubigeo),
                .default = ubigeo
            )
        )
    if (!is.null(type)) {
        d <- d |> mutate(fuente = type)
    }
    return(d)
}

# Información de ubigeos (Fuente: INEI 2018)
db_ubigeo <- readRDS("./data/geo/ubigeo_18.rds")

# BASES DE INGRESO ----

# Listado de archivos de modelamiento
test_files <- list.files(path = "./data/raw", pattern = "test.csv", full.names = TRUE)
train_files <- list.files(path = "./data/raw", pattern = "train.csv", full.names = TRUE)
metric_files <- list.files(path = "./data/raw", pattern = "variables.csv", full.names = TRUE)

# Union de archivos
db_test <- c()
for (file in test_files) {
    db_in <- read_csv_arrow(file) |> clean_ubigeo("test")
    db_test <- rbind(db_test, db_in)
}
db_train <- c()
for (file in train_files) {
    db_in <- read_csv_arrow(file) |> clean_ubigeo("train")
    db_train <- rbind(db_train, db_in)
}
db_metric <- c()
for (file in metric_files) {
    db_in <- read_csv_arrow(file) |> clean_ubigeo()
    db_metric <- rbind(db_metric, db_in)
}

# Union de bases de entrenamiento y validación
db_model <- rbind(db_test, db_train)

# DATA WRANGLING ----

# Información de ubigeo y semana epidemiológica
db_model_clean <- db_model |>
    select(-distrito) |>
    mutate(
        year = year(fecha),
        epiweek = as.character(epiweek(fecha)),
        epiweek = if_else(nchar(epiweek) == 1, paste0("0", epiweek), epiweek),
        axis = paste(year, epiweek, sep = "-")
    ) |>
    left_join(db_ubigeo, by = join_by(ubigeo)) |>
    relocate(year, epiweek, .after = fecha)

db_metric_clean <- db_metric |>
    left_join(db_ubigeo, by = join_by(ubigeo)) |>
    select(-ano_ref) |>
    mutate(
        numero = str_extract(variable, "\\d"),
        variable = case_when(
            str_detect(variable, "^n_") ~ glue("Casos ({numero})"),
            str_detect(variable, "tmean_") ~ glue("Temperatura media ({numero})"),
            str_detect(variable, "tmax_") ~ glue("Temperatura máxima ({numero})"),
            str_detect(variable, "tmin_") ~ glue("Temperatura mínima ({numero})"),
            str_detect(variable, "prcp_") ~ glue("Precipitación ({numero})"),
            str_detect(variable, "rdiu_") ~ glue("Radiación diurna ({numero})"),
            str_detect(variable, "hrel_") ~ glue("Humedad relativa ({numero})")
        )
    )

# EXPORTACION ----
write_parquet(db_model_clean, "./data/processed/shiny_data.parquet")
write_parquet(db_metric_clean, "./data/processed/shiny_metricas.parquet")
