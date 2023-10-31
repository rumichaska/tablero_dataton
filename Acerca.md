<br/>

### Área de estudio

Se seleccionaron 10 distritos del departamento de **PIURA**:

1. Buenos Aires, Morropón, Piura (ubigeo: 200402)
2. Castilla, Piura, Piura (ubigeo: 200104)
3. Chulucanas, Morropón, Piura (ubigeo: 200401)
4. La Matanza, Morropón, Piura (ubigeo: 200404)
5. Los Órganos, Talara, Piura (ubigeo: 200705)
6. Morropón, Morropón, Piura (ubigeo: 200405)
7. Máncora, Talara, Piura (ubigeo: 200706)
8. Piura, Piura, Piura (ubigeo: 200101)
9. Salitral, Morropón, Piura (ubigeo: 200406)
10. Sullana, Sullana, Piura (ubigeo: 200601)

### Fuentes de información

#### Límites departamentales, provinciales y distritales

La información de los límites distritales se obtuvo del [portal de datos abiertos](https://www.datosabiertos.gob.pe/dataset/limites-departamentales), esta base de datos se encuentra disponible en formato **`shapefile`**. A partir de los límites distritales y usando el *software* **QGIS**, se generaron las capas vectoriales de los departamentos y provincias. Finalmente, se exportó la *geodatabse* en formato **`GeoPackage`**.

#### Datos epidemiológicos

Los datos de casos de dengue por semana epidemiológica se obtuvieron de los informes del Centro Nacional de Epidemiología, Prevención y Control de Enfermedades (**CDC - MINSA**). Para el periodo de estudio de enero del 2001 a octubre del 2023.

#### Datos meteorológicos

Los datos meteorológicos semanales, temperatura media (°C), temperatura máxima (°C), temperatura mínima (°C), variación de temperatura diurna (°C), precipitación (mm), humedad relativa (%); se obtuvieron a partir de datos de reanálisis del **ERA5 LAND**, estimaciones satelitales del **GPM** y de estaciones del **SENAMHI**. Para el periodo de estudio de enero del 2001 a octubre del 2023.

### Procesamiento de datos

Para cada distrito seleccionado, el conjunto de datos consta de casos de dengue por semana epidemiológica como variable objetivo (**variable dependiente**) y variables climáticas como variables predictoras (**variables independientes**), desde enero del 2001 a octubre del 2023. Previo al análisis se llevó a cabo la limpieza de datos, realizando la imputación de valores perdidos de las variables independientes por la media correspondiente de cada variable. Con los datos completos se realizó la ingeniería de características, el escalado de las variables independientes (**escalado robusto**), la transformación de datos de las variables independientes para que sigan una distribución normal (**transformación Yeo - Johnson**); seguido de la generación de nuevas variables, las nuevas variables consisten en retrasos de hasta 8 semanas para tener en cuenta las características temporales. También se incluye como variable predictora el número de casos de dengue con retraso de hasta 4 semanas para evaluar el impacto de los casos anteriores de dengue en los casos actuales de dengue.

Para capturar el efecto retardado de los factores climáticos en la transmisión del dengue se realizó un análisis de correlación (**correlación de *Spearman***) y se determinó el tiempo de retraso adecuado para cada factor meteorológico entre 0 y 8 semanas de retraso. Para aquellas variables con la semana 0 o 1 de retraso, se cambió por 2 semanas de retraso, ya que el objetivo es que el resultado pueda servir para la toma de decisiones con semanas de anticipación. Para cada distrito que forma parte de este trabajo, se seleccionaron las variables más significativas en función de la correlación de las variables independientes con la variable objetivo.

Antes del modelamiento, para cada distrito, los conjuntos de datos se dividieron en conjuntos para entrenar y validar los modelos de aprendizaje automático. Los datos de entrenamiento corresponden al **80 %** de las observaciones, y los datos de prueba al **20 %** de las observaciones.

### Modelamiento de datos

En el presente trabajo, se construyeron modelos de aprendizaje automático como:

- *Support Vector Regression*
- *Random Forest*
- *XGBoost (Extreme Gradient Boost)*

### Validación de modelos

El rendimiento predictivo de los modelos se midió por el error medio absoluto (**MAE**) y el error cuadrático medio (**RMSE**) como métricas de evaluación de los modelos. 

<br/>

----
