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

## Procesos

### PASO 0: Activar entorno de desarrollo

El proyecto usa `renv@1.0.3` para la gestión de los paquetes. La primera vez que se clone el proyecto se iniciará la sincronización de paquetes. Para instalar por primera vez los paquetes usar el siguiente comando en la consola de `R`:

```r
renv::restore()
```

Este comando se inicia la instalación de los paquetes y versiones con los que fue desarrollado el proyecto.

Consideraciones:

- El proyecto está desarrollado en la versión `R 4.2.2`, si se cuenta con otra versión de `R` es posible que se generen problemas a la hora de instalar los paquetes desde `renv`. Se recomienda cambiar la versión de `R` (esto se puede hacer fácilmente desde **RStudio**) o, en su defecto, borrar el directorio `renv/` y los archivos `.Rprofile` y `renv.lock`, de esta manera se hará uso de los paquetes instalados de forma local en nuestro equipo.
- Antes de eliminar los archivos relacionadas a `renv` es importante tener en cuenta que las versiones de los paquetes que se instalan en el sistema no corresponden, necesariamente, a las versiones con los que se desarrolló el aplicativo. Para evitar posibles errores, el archivo `renv.lock` contiene las versiones de los paquetes utilizados al momento de desarrollar el aplicativo.

### PASO 1. Generación de base de datos del aplicativo

La generación de la base de datos que alimenta el tablero interactivo se genera a partir del archivo `src/generar_data_shiny.R`. Como *input* se utilizan las bases resultantes del modelamiento, ubicadas en la carpeta `data/raw/`.
