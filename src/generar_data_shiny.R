# LIBRERIAS ----

library(arrow, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(readr)
library(dplyr, warn.conflicts = FALSE)

# UTILIDADES ----

# Información de ubigeos (Fuente: INEI 2018)
db_ubigeo <- readRDS("./data/geo/ubigeo_18.rds")

# BASES DE INGRESO ----

# Listado de archivos de modelamiento
test_files <- list.files(path = "./data/raw", pattern = "test.csv", full.names = TRUE)
train_files <- list.files(path = "./data/raw", pattern = "train.csv", full.names = TRUE)

# Union de archivos
db_test <- c()
for (file in test_files) {
    db_in <- read_csv_arrow(file) |>
        mutate(
            ubigeo = as.character(ubigeo),
            ubigeo = case_when(
                nchar(ubigeo) == 5 ~ paste0(strrep("0", 1), ubigeo),
                .default = ubigeo
            ),
            fuente = "test"
        )
    db_test <- rbind(db_test, db_in)
}
db_train <- c()
for (file in train_files) {
    db_in <- read_csv_arrow(file) |>
        mutate(
            ubigeo = as.character(ubigeo),
            ubigeo = case_when(
                nchar(ubigeo) == 5 ~ paste0(strrep("0", 1), ubigeo),
                .default = ubigeo
            ),
            fuente = "train"
        )
    db_train <- rbind(db_train, db_in)
}

# Union de bases
db_model <- rbind(db_test, db_train)

# DATA WRANGLING ----

# Información de ubigeo y semana epidemiológica
db_clean <- db_model |>
    select(-distrito) |>
    mutate(
        year = year(fecha),
        epiweek = as.character(epiweek(fecha)),
        epiweek = if_else(nchar(epiweek) == 1, paste0("0", epiweek), epiweek),
        axis = paste(year, epiweek, sep = "-")
    ) |>
    left_join(db_ubigeo, by = join_by(ubigeo)) |>
    relocate(year, epiweek, .after = fecha)

# EXPORTACION ----
write_parquet(db_clean, "./data/processed/shiny_data.parquet")
