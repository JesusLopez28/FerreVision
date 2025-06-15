% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\segmentacion.m
function [imagen_binaria, imagen_dilatada, imagen_erosionada] = segmentacion(imagen)
% Binarización adaptativa
nivel = graythresh(imagen);
imagen_binaria = imbinarize(imagen, nivel);

% Invertir imagen si es necesario (asumiendo objetos oscuros en fondo claro)
if sum(imagen_binaria(:)) > numel(imagen_binaria)/2
    imagen_binaria = ~imagen_binaria;
end

% Crear elementos estructurantes para operaciones morfológicas
se_disco = strel('disk', 3);
se_linea = strel('line', 5, 90);

% Operaciones morfológicas
imagen_erosionada = imerode(imagen_binaria, se_disco);
imagen_dilatada = imdilate(imagen_erosionada, se_disco);

% Eliminar objetos pequeños (ruido)
imagen_binaria = bwareaopen(imagen_dilatada, 100);

% Rellenar huecos en los objetos
imagen_binaria = imfill(imagen_binaria, 'holes');
end