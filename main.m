% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\main.m
%% CLASIFICADOR DE ELEMENTOS DE FERRETERÍA
% Archivo principal para ejecutar el sistema completo de clasificación
% Autor: Jesús Alejandro López Rosales
% Fecha: 2025-06-14

function main()
try
    % Limpiar workspace y pantalla
    close all;
    clear;
    clc;

    fprintf('=== CLASIFICADOR DE ELEMENTOS DE FERRETERÍA ===\n');
    fprintf('Iniciando sistema de clasificación...\n\n');

    % Llamar al clasificador principal
    clasificador_ferreteria();

    fprintf('\n=== PROCESO COMPLETADO EXITOSAMENTE ===\n');

catch ME
    % Manejo de errores
    fprintf('\nERROR: %s\n', ME.message);
    fprintf('El proceso no pudo completarse correctamente.\n');

    % Mostrar información adicional del error en modo debug
    if exist('debug_mode', 'var') && debug_mode
        fprintf('\nDetalles del error:\n');
        fprintf('Archivo: %s\n', ME.stack(1).file);
        fprintf('Línea: %d\n', ME.stack(1).line);
    end
end
end

%% Función alternativa para ejecutar con parámetros personalizados
function main_custom(ruta_imagen, mostrar_pasos, guardar_resultados)
% Función alternativa que permite mayor control sobre la ejecución
%
% Parámetros:
%   ruta_imagen: string con la ruta completa de la imagen
%   mostrar_pasos: booleano para mostrar pasos intermedios (default: true)
%   guardar_resultados: booleano para guardar resultados (default: false)

if nargin < 2
    mostrar_pasos = true;
end
if nargin < 3
    guardar_resultados = false;
end

try
    close all;

    fprintf('=== MODO PERSONALIZADO ===\n');
    fprintf('Procesando imagen: %s\n', ruta_imagen);

    % Verificar que la imagen existe
    if ~exist(ruta_imagen, 'file')
        error('La imagen especificada no existe: %s', ruta_imagen);
    end

    % Leer imagen
    imagen_original = imread(ruta_imagen);

    if mostrar_pasos
        figure('Name', 'Proceso de Clasificación', 'NumberTitle', 'off');
    end

    % Ejecutar pipeline paso a paso
    fprintf('1. Preprocesando imagen...\n');
    imagen_preprocesada = preprocesamiento(imagen_original);

    if mostrar_pasos
        subplot(2, 3, 1);
        imshow(imagen_original);
        title('Original');

        subplot(2, 3, 2);
        imshow(imagen_preprocesada);
        title('Preprocesada');
    end

    fprintf('2. Segmentando objetos...\n');
    [imagen_binaria, ~, ~] = segmentacion(imagen_preprocesada);

    if mostrar_pasos
        subplot(2, 3, 3);
        imshow(imagen_binaria);
        title('Segmentación');
    end

    fprintf('3. Detectando objetos...\n');
    [objetos_etiquetados, num_objetos, propiedades] = deteccion_objetos(imagen_binaria);

    if mostrar_pasos
        subplot(2, 3, 4);
        imshow(label2rgb(objetos_etiquetados, 'jet', 'k', 'shuffle'));
        title(sprintf('Objetos: %d', num_objetos));
    end

    fprintf('4. Clasificando objetos...\n');
    [tipos, tamanios, ~] = clasificar_objetos(propiedades, imagen_preprocesada);

    fprintf('5. Generando resultados...\n');
    imagen_resultado = mostrar_resultados(imagen_original, propiedades, tipos, tamanios);

    if mostrar_pasos
        subplot(2, 3, 5:6);
        imshow(imagen_resultado);
        title('Resultado Final');
    end

    % Generar informe
    generar_informe(tipos);

    % Guardar resultados si se solicita
    if guardar_resultados
        [~, nombre_archivo, ~] = fileparts(ruta_imagen);
        nombre_resultado = sprintf('resultado_%s.jpg', nombre_archivo);
        imwrite(imagen_resultado, nombre_resultado);
        fprintf('Resultado guardado como: %s\n', nombre_resultado);
    end

    fprintf('\nProceso completado exitosamente.\n');

catch ME
    fprintf('Error en modo personalizado: %s\n', ME.message);
    rethrow(ME);
end
end

%% Función de ayuda
function mostrar_ayuda()
fprintf('=== AYUDA DEL CLASIFICADOR ===\n');
fprintf('Funciones disponibles:\n');
fprintf('  main()                    - Ejecuta el clasificador con interfaz gráfica\n');
fprintf('  main_custom(ruta, ...)    - Ejecuta con parámetros personalizados\n');
fprintf('  mostrar_ayuda()           - Muestra esta ayuda\n\n');
fprintf('Ejemplo de uso:\n');
fprintf('  main();\n');
fprintf('  main_custom(''imagen.jpg'', true, false);\n\n');
fprintf('Archivos requeridos:\n');
fprintf('  - preprocesamiento.m\n');
fprintf('  - segmentacion.m\n');
fprintf('  - deteccion_objetos.m\n');
fprintf('  - clasificar_objetos.m\n');
fprintf('  - mostrar_resultados.m\n');
fprintf('  - generar_informe.m\n');
fprintf('  - clasificador_ferreteria.m\n');
end