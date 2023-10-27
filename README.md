# ESTRUCTURA DE PROYECTOS CON R

## Estructura global

```
 .
├──  data
│   ├──  geo
│   │   └──  README.md
│   ├──  processed
│   │   └──  README.md
│   ├──  raw
│   │   └──  README.md
│   └──  README.md
├──  docs
│   └──  README.md
├──  output
│   └──  README.md
├──  R
│   └──  README.md
├──  src
│   └──  README.md
├──  test
│   └──  README.md
├──  www
│   └──  README.md
├──  .gitignore
└──  README.md
```

* `data`: Carpeta donde se almacenan los archivos necesarios para poder ejecutar
un código o proyecto. Las principales carpetas son las `raw` y `processed`, las
cuales almacenan archivos crudos y procesados, respectivamente.
Alternativamente, se pueden agregar otros directorios a la carpeta de `raw`; por
defecto también se considera una carpeta `geo`, para el almacenamiento de
información espacial.

* `docs`: Carpeta que contendrá cualquier documentación que ayude a dar soporte
a la metodología o proceso que se esté realizando. Dentro de esta carpeta se
pueden incluir archivos de MS Office, pdf, enlaces, videos, audios, etc.

* `output`: Carpeta que contendrá archivos de salidas o productos de los
procesos ejecutados por los códigos desarrollados. Por ejemplo, dentro de esta
carpeta se pueden guardar los gráficos de algún análisis que se utilice en la
elaboración de análisis como parte de la redacción de artículos, tableros
interactivos, reportes, etc.

* `R`: Carpeta que contendrá los módulos de los aplicativos desarrollados con
`shiny`.

* `src`: Carpeta que contendrá los códigos de los subprocesos elaborados para el
proyecto que se esté desarrollando. Dentro de esta carpeta se pueden agregar
subcarpetas que permitan organizar de mejor manera el procesamiento de
información. Además, puede contener códigos desarrollados en otros lenguajes de
programación.

* `test`: Carpeta que contendrá información sobre pruebas realizadas para el
proyecto. Esta carepta puede contener códigos, archivos crudos, archivos
procesados, gráficos, tablas, etc.

* `www`: Carpeta que contendrá información complementaria para los tableros
interactivos, pudiendo contener archivos de tipo `.css` e imaǵenes.

*Las carpetas cuyo contenido es ignorado por el archivo `.gitignore`, cuando se
trabaja con un sistema de control de versiones (**git**) son: i) `data`, ii)
`output`, iii) `www`, ya que pueden ocupar mucha espacio en los repositorios 
remotos.*

## Directoriros por proyectos

### Análisis con R

Cuando se desarrollen proyectos con R que no requieran la elaboración de
tableros interactivos (*dashboards*), la estructura recomendada es la siguiente:

```
 .
├──  data
│   ├──  geo
│   │   └──  README.md
│   ├──  processed
│   │   └──  README.md
│   ├──  raw
│   │   └──  README.md
│   └──  README.md
├──  docs (opcional)
│   └──  README.md
├──  output (opcional)
│   └──  README.md
├──  src
│   └──  README.md
├──  test (opcional)
│   └──  README.md
├──  .gitignore (opcional)
└──  README.md
```

### Tableros interactivos con `shiny`

Cuando se desarrollen proyectos de tableros interactivos (*dashboards*) con el
paquete `shiny`, la estructura recomendada es la siguiente:

```
 .
├──  data
│   ├──  geo
│   │   └──  README.md
│   ├──  processed
│   │   └──  README.md
│   ├──  raw
│   │   └──  README.md
│   └──  README.md
├──  docs (opcional)
│   └──  README.md
├──  R (módulos)
│   └──  README.md
├──  output (opcional)
│   └──  README.md
├──  src
│   └──  README.md
├──  test (opcional)
│   └──  README.md
├──  www
│   └──  README.md
├──  .gitignore (opcional)
└──  README.md
```

### Tableros interactivos con `RMarkdown`

Cuando se desarrollen proyectos de tableros interactivos (*dashboards*) con el
paquete `rmarkdown`, la estructura recomendada es la siguiente:

```
 .
├──  data
│   ├──  geo
│   │   └──  README.md
│   ├──  processed
│   │   └──  README.md
│   ├──  raw
│   │   └──  README.md
│   └──  README.md
├──  docs (opcional)
│   └──  README.md
├──  output
│   └──  README.md
├──  src
│   └──  README.md
├──  test (opcional)
│   └──  README.md
├──  www
│   └──  README.md
├──  .gitignore (opcional)
└──  README.md
```
