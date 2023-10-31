# TABLERO DATATON

Proyecto de desarrollo del tablero interactivo de Dataton, MINSA 2023.

## Estructura proyecto

```
./
├── data/
│   ├── geo/
│   │   ├── geo_peru.gpkg
│   │   ├── ubigeo_18.rds
│   │   └── README.md
│   ├── processed/
│   │   ├── shiny_data.parquet
│   │   ├── shiny_metricas.parquet
│   │   └── README.md
│   ├── raw/
│   │   ├── buenos_aires_test.csv
│   │   ├── buenos_aires_train.csv
│   │   ├── buenos_aires_variables.csv
│   │   ├── castilla_test.csv
│   │   ├── castilla_train.csv
│   │   ├── castilla_variables.csv
│   │   ├── chulucanas_test.csv
│   │   ├── chulucanas_train.csv
│   │   ├── chulucanas_variables.csv
│   │   ├── la_matanza_test.csv
│   │   ├── la_matanza_train.csv
│   │   ├── la_matanza_variables.csv
│   │   ├── los_organos_test.csv
│   │   ├── los_organos_train.csv
│   │   ├── los_organos_variables.csv
│   │   ├── mancora_test.csv
│   │   ├── mancora_train.csv
│   │   ├── mancora_variables.csv
│   │   ├── morropon_test.csv
│   │   ├── morropon_train.csv
│   │   ├── morropon_variables.csv
│   │   ├── piura_test.csv
│   │   ├── piura_train.csv
│   │   ├── piura_variables.csv
│   │   ├── salitral_test.csv
│   │   ├── salitral_train.csv
│   │   ├── salitral_variables.csv
│   │   ├── sullana_test.csv
│   │   ├── sullana_train.csv
│   │   └── sullana_variables.csv
│   │   └── README.md
│   └── README.md
├── R/
│   ├── module_component_filter.R
│   ├── module_component_graphs.R
│   ├── module_component_table.R
│   ├── module_dashboard_pronostico.R
│   └── README.md
├── src/
│   ├── generar_data_shiny.R
│   └── README.md
├── Acerca.md
├── app.R
├── deployapp.R
└── README.md

```
