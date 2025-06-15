# FerreVision

FerreVision es un sistema de procesamiento de imágenes para la detección, segmentación y clasificación automática de elementos de ferretería (tornillos, tuercas, arandelas y pernos) en imágenes.

## Archivos principales

- `main.m`: Archivo principal para ejecutar el sistema.
- `clasificador_ferreteria.m`: Interfaz gráfica para seleccionar y procesar una imagen.
- `preprocesamiento.m`: Mejora y filtrado de la imagen.
- `segmentacion.m`: Segmentación y operaciones morfológicas.
- `deteccion_objetos.m`: Detección y etiquetado de objetos.
- `clasificar_objetos.m`: Clasificación de los objetos detectados.
- `mostrar_resultados.m`: Visualización de resultados y etiquetas.
- `generar_informe.m`: Genera un informe gráfico y en consola del conteo de objetos.

## Uso

1. Ejecuta `main` en MATLAB para iniciar el sistema.
2. Selecciona una imagen de ferretería cuando se solicite.
3. El sistema mostrará los pasos del procesamiento y el resultado final, junto con un informe de conteo.

## Requisitos

- MATLAB con Image Processing Toolbox.

---
Proyecto académico para la materia de Procesamiento de Imágenes.