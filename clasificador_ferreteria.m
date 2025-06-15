% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\clasificador_ferreteria.m
function clasificador_ferreteria()
% Configuración inicial
close all;
clear;
clc;

% Cargar imagen
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Archivos de imagen (*.jpg, *.png, *.bmp)'}, 'Seleccionar imagen');
if isequal(filename, 0)
    disp('Operación cancelada por el usuario');
    return;
end

% Leer la imagen
ruta_completa = fullfile(pathname, filename);
imagen_original = imread(ruta_completa);

% Mostrar imagen original
figure('Name', 'Imagen Original', 'NumberTitle', 'off');
imshow(imagen_original, 'InitialMagnification', 100);
title('Imagen Original');

% Preprocesamiento
imagen_preprocesada = preprocesamiento(imagen_original);
figure('Name', 'Preprocesamiento', 'NumberTitle', 'off');
imshow(imagen_preprocesada, 'InitialMagnification', 100);
title('Preprocesamiento');

% Segmentación y operaciones morfológicas
[imagen_binaria, imagen_dilatada, imagen_erosionada] = segmentacion(imagen_preprocesada);
figure('Name', 'Segmentación', 'NumberTitle', 'off');
imshow(imagen_binaria, 'InitialMagnification', 100);
title('Segmentación');

% Detección y etiquetado de objetos
[objetos_etiquetados, num_objetos, propiedades] = deteccion_objetos(imagen_binaria);
figure('Name', 'Objetos Detectados', 'NumberTitle', 'off');
imshow(label2rgb(objetos_etiquetados, 'jet', 'k', 'shuffle'), 'InitialMagnification', 100);
title(['Objetos Detectados: ', num2str(num_objetos)]);

% Extraer características y clasificar objetos
[tipos, esquinas] = clasificar_objetos(propiedades, imagen_preprocesada);

% Mostrar resultados
imagen_resultado = mostrar_resultados(imagen_original, propiedades, tipos);
figure('Name', 'Clasificación Final', 'NumberTitle', 'off');
imshow(imagen_resultado, 'InitialMagnification', 100);
title('Clasificación Final');

% Generar informe de conteo
generar_informe(tipos);
end