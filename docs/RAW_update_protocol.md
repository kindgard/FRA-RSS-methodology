# Protocolo para sustituir el RAW — FRA 2025 RSS

## Alcance y estado
Ejecutable único: `scripts/run_rss_2025_batch.R`. Acepta hojas NC85 de una sola pestaña, con factores de superficie `EFKm2`. Ejecuta **una sola lectura del Excel** y una pasada de los módulos disponibles. **No equivale todavía a ejecutar el notebook completo de Oliver**. Los módulos no terminados se marcan `BLOCKED`, no se imputan ni se publican como completados.

No publicar ni subir a GitHub el RAW institucional, el resumen de resultados, las listas de parcelas o los CSV generados. Las pruebas públicas usan exclusivamente datos sintéticos.

## Instalación privada (primera vez)
- Instalar R reciente, el paquete `readxl` y clonar el repositorio.
- Colocar la nueva versión del RAW fuera de la carpeta del repositorio y comprobar sus permisos.
- Ejecutar desde la raíz del repositorio. Usar una **carpeta privada de salida nueva y vacía** por cada versión; nunca sobrescribir una ejecución anterior.
- Para abrir un RAW nuevo no hay que editar fórmulas: basta con señalar la ruta al nuevo archivo.

```bash
Rscript scripts/run_rss_2025_batch.R "/ruta/privada/RAW_nuevo.xlsx" "/ruta/privada/resultados_YYYYMMDD"
```

## Contrato de entrada
Requiere una única hoja, una fila por `PL_PLOTID`, sin IDs repetidos, y las columnas:
`Subreg`, `GEZ`, `Nstr0024`, `EFKm2`,
`FOREST%24`, `OWL%24`, `OL%24`, `WATER%24`;
y las cuatro variables `%FORGAIN`, `%FORLOSS`, `%STABFOR`, `%StabNFor` para cada uno de los períodos `2000-2010`, `2010-2018`, `2018-2024`.
`IPCC24` es obligatorio para las subclases calibradas pero opcional para la etapa inicial de hexágonos.

Verificar antes de calcular si `EFKm2` mantiene su sentido: área representada **por cada hexágono muestral**. El ejecutable valida su constancia aproximada dentro de subregión × GEZ × Nstr, y rechaza modificaciones incompatibles. Si el nuevo archivo vuelve a usar hojas `RawData` y `weights`, ejecutar primero una conversión *privada y explícita* del esquema (no inferir pesos del número de registros).

## Resultados y compuertas
- `input_manifest.csv`: versión, checksum MD5, conteos y sesión de R.
- `input_missingness.csv`: vacíos por variable.
- `hexagon_by_stratum.csv` y `hexagon_global_unfiltered.csv`: estimaciones originales de Oliver, con posibles `NA` de varianza.
- `hexagon_Global.csv`, `hexagon_Region.csv` (solo con mapping regional), `hexagon_Subregion.csv`, `hexagon_GEZ.csv`, `hexagon_Subregion_GEZ.csv`: solo variables sin varianzas indefinidas.
- `forest_change_annual.csv`: pérdida, ganancia y cambio neto puntual; **no asigna incertidumbre inventada al cambio neto**.
- `ipcc_category_audit.csv`, `calibration_l3_closure.csv`, `calibration_l3_by_stratum.csv`, `calibration_l3_dictionary.csv`: se generan según aprobación de las compuertas anteriores.
- `drivers_dictionary.csv`, `drivers_calibrated_by_stratum.csv`, `drivers_Global.csv`, `drivers_Region.csv` y otros dominios: drivers por período, sujetos a QA.
- `pastoralism_dictionary.csv`, `pastoralism_calibrated_by_stratum.csv`, `pastoralism_Global.csv`, `pastoralism_Region.csv` y otros dominios: categorías de pastoralismo, sujetos a QA.
- `module_status.csv`: estado de cada bloque, con razones exactas de bloqueo.

El criterio de promoción a reportes oficiales es: checksum y conteos registrados; cero mapeos desconocidos; política aprobada para faltantes; concordancia de pesos con la plantilla; cierre de las particiones mutuamente excluyentes y diferencias contra referencia documentadas; comparación numérica del código adaptado con Oliver en la misma base.

## Módulos aún pendientes
`drivers` y `pastoralism` se ejecutan con indicadores y calibración del notebook cuando el nuevo RAW contiene sus columnas. Sus resultados se marcan `READY_FOR_REVIEW` y no deben considerarse oficiales sin validación frente a Oliver y QA categórico. `crops` y `full_notebook_equivalence` siguen `BLOCKED`. La fuente RAW queda intacta.

## Para cada nuevo ciclo
1. Congelar y etiquetar la versión del RAW; conservar también el archivo anterior.
2. Confirmar esquemas, pesos, IDs y categorías nuevas; ejecutar el script con un directorio nuevo.
3. Revisar `module_status.csv`, `input_missingness.csv`, clasificación y cierre por estrato.
4. Comparar tendencias, totales, unidades, intervalos y diferencias contra la última versión aprobada, sin recodificaciones ocultas.
5. Aprobar por escrito los indicadores listos; solo entonces actualizar tablas y gráficos del borrador.
