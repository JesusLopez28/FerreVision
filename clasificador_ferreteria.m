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
figure('Name', 'Clasificador de Elementos de Ferretería', 'NumberTitle', 'off');
subplot(2, 3, 1);
imshow(imagen_original, 'InitialMagnification', 100);
title('Imagen Original');

% Preprocesamiento
imagen_preprocesada = preprocesamiento(imagen_original);
subplot(2, 3, 2);
imshow(imagen_preprocesada, 'InitialMagnification', 100);
title('Preprocesamiento');

% Segmentación y operaciones morfológicas
[imagen_binaria, imagen_dilatada, imagen_erosionada] = segmentacion(imagen_preprocesada);
subplot(2, 3, 3);
imshow(imagen_binaria, 'InitialMagnification', 100);
title('Segmentación');

% Detección y etiquetado de objetos
[objetos_etiquetados, num_objetos, propiedades] = deteccion_objetos(imagen_binaria);
subplot(2, 3, 4);
imshow(label2rgb(objetos_etiquetados, 'jet', 'k', 'shuffle'), 'InitialMagnification', 100);
title(['Objetos Detectados: ', num2str(num_objetos)]);

% Extraer características y clasificar objetos
[tipos, tamanios, esquinas] = clasificar_objetos(propiedades, imagen_preprocesada);

% Mostrar resultados
imagen_resultado = mostrar_resultados(imagen_original, propiedades, tipos, tamanios);
subplot(2, 3, 5:6);
imshow(imagen_resultado, 'InitialMagnification', 100);
title('Clasificación Final');

% Generar informe de conteo
generar_informe(tipos);
end