% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\deteccion_objetos.m
function [objetos_etiquetados, num_objetos, propiedades] = deteccion_objetos(imagen_binaria)
% Etiquetar objetos conectados usando implementación manual
[objetos_etiquetados, num_objetos] = etiquetado_manual(imagen_binaria);

% Extraer propiedades de los objetos usando implementación manual
propiedades = calcular_propiedades_manual(objetos_etiquetados, num_objetos);

% Filtrar objetos pequeños y objetos atípicos
if num_objetos > 0
    areas = [propiedades.Area];
    area_media = mean(areas);
    area_std = std(areas);

    % Filtrar objetos muy pequeños y muy grandes (probablemente ruido o artefactos)
    umbral_min = max(100, area_media * 0.15);  % Reducido a 100 píxeles o 15% del área media
    umbral_max = area_media + 4 * area_std;   % Aumentado a 4 desviaciones estándar

    idx_objetos_validos = find(areas >= umbral_min & areas <= umbral_max);

    % Reconstruir etiquetado con solo objetos válidos
    imagen_filtrada = false(size(imagen_binaria));
    for i = 1:length(idx_objetos_validos)
        idx = idx_objetos_validos(i);
        imagen_filtrada(propiedades(idx).PixelIdxList) = true;
    end

    % Volver a etiquetar con los objetos filtrados
    [objetos_etiquetados, num_objetos] = etiquetado_manual(imagen_filtrada);
    propiedades = calcular_propiedades_manual(objetos_etiquetados, num_objetos);

    % Filtrado adicional basado en propiedades de forma
    if num_objetos > 0
        validos = true(num_objetos, 1);
        for i = 1:num_objetos
            % Calcular compacidad (circularidad)
            compacidad = 4 * pi * propiedades(i).Area / (propiedades(i).Perimeter^2);

            % Filtrar objetos con formas muy irregulares que no corresponden a piezas de ferretería
            if compacidad < 0.08 || propiedades(i).Solidity < 0.35  % Valores reducidos
                validos(i) = false;
            end
        end

        if ~all(validos)
            imagen_filtrada = false(size(imagen_binaria));
            idx_validos = find(validos);
            for i = 1:length(idx_validos)
                idx = idx_validos(i);
                imagen_filtrada(propiedades(idx).PixelIdxList) = true;
            end

            [objetos_etiquetados, num_objetos] = etiquetado_manual(imagen_filtrada);
            propiedades = calcular_propiedades_manual(objetos_etiquetados, num_objetos);
        end
    end
end
end

% Función manual para etiquetar componentes conectados
function [imagen_etiquetada, num_etiquetas] = etiquetado_manual(imagen_binaria)
[filas, columnas] = size(imagen_binaria);
imagen_etiquetada = zeros(filas, columnas);

% 4-conectividad: arriba, abajo, izquierda, derecha
dx = [-1, 1, 0, 0];
dy = [0, 0, -1, 1];

etiqueta_actual = 0;

for i = 1:filas
    for j = 1:columnas
        if imagen_binaria(i, j) && imagen_etiquetada(i, j) == 0
            etiqueta_actual = etiqueta_actual + 1;

            % BFS para etiquetar todos los píxeles conectados
            cola = zeros(filas*columnas, 2);
            frente = 1;
            cola_fin = 1;

            cola(frente, :) = [i, j];
            imagen_etiquetada(i, j) = etiqueta_actual;
            cola_fin = cola_fin + 1;

            while frente < cola_fin
                pixel_actual = cola(frente, :);
                frente = frente + 1;

                for k = 1:4
                    ni = pixel_actual(1) + dx(k);
                    nj = pixel_actual(2) + dy(k);

                    % Verificar límites
                    if ni >= 1 && ni <= filas && nj >= 1 && nj <= columnas
                        % Si es un píxel de objeto y no ha sido etiquetado
                        if imagen_binaria(ni, nj) && imagen_etiquetada(ni, nj) == 0
                            imagen_etiquetada(ni, nj) = etiqueta_actual;
                            cola(cola_fin, :) = [ni, nj];
                            cola_fin = cola_fin + 1;
                        end
                    end
                end
            end
        end
    end
end

num_etiquetas = etiqueta_actual;
end

% Función manual para calcular propiedades de regiones
function propiedades = calcular_propiedades_manual(imagen_etiquetada, num_etiquetas)
propiedades = struct('Area', {}, 'Centroid', {}, 'BoundingBox', {}, ...
    'MajorAxisLength', {}, 'MinorAxisLength', {}, 'Perimeter', {}, ...
    'Eccentricity', {}, 'Orientation', {}, 'ConvexHull', {}, ...
    'Solidity', {}, 'PixelIdxList', {});

[filas, columnas] = size(imagen_etiquetada);

for etiqueta = 1:num_etiquetas
    % Encontrar todos los píxeles de esta etiqueta
    [i, j] = find(imagen_etiquetada == etiqueta);

    % Lista de índices de píxeles
    pixelIdxList = sub2ind(size(imagen_etiquetada), i, j);

    % Área
    area = length(i);

    % Centroide
    centroid = [mean(j), mean(i)];

    % Bounding Box [xmin, ymin, width, height]
    xmin = min(j);
    ymin = min(i);
    width = max(j) - xmin + 1;
    height = max(i) - ymin + 1;
    boundingBox = [xmin, ymin, width, height];

    % Perímetro (cálculo manual)
    perimetro = calcular_perimetro(imagen_etiquetada, etiqueta);

    % Cálculo de la solidez
    convexArea = calcular_area_convexa(i, j);
    solidity = area / convexArea;

    % Ejes principal y menor, excentricidad y orientación
    [majorAxisLength, minorAxisLength, eccentricity, orientation] = calcular_ejes_y_orientacion(i, j);

    % Casco convexo simplificado
    convexHull = calcular_casco_convexo(i, j);

    propiedades(etiqueta).Area = area;
    propiedades(etiqueta).Centroid = centroid;
    propiedades(etiqueta).BoundingBox = boundingBox;
    propiedades(etiqueta).MajorAxisLength = majorAxisLength;
    propiedades(etiqueta).MinorAxisLength = minorAxisLength;
    propiedades(etiqueta).Perimeter = perimetro;
    propiedades(etiqueta).Eccentricity = eccentricity;
    propiedades(etiqueta).Orientation = orientation;
    propiedades(etiqueta).ConvexHull = convexHull;
    propiedades(etiqueta).Solidity = solidity;
    propiedades(etiqueta).PixelIdxList = pixelIdxList;
end
end

% Función para calcular el perímetro
function perimetro = calcular_perimetro(imagen_etiquetada, etiqueta)
[filas, columnas] = size(imagen_etiquetada);
mascara = imagen_etiquetada == etiqueta;
perimetro = 0;

% Recorrer todos los píxeles de la máscara
for i = 1:filas
    for j = 1:columnas
        if mascara(i, j)
            % Verificar si es un píxel de borde (al menos un vecino es fondo)
            es_borde = false;

            % Comprobar los 4 vecinos (arriba, abajo, izquierda, derecha)
            if i > 1 && ~mascara(i-1, j)
                es_borde = true;
            elseif i < filas && ~mascara(i+1, j)
                es_borde = true;
            elseif j > 1 && ~mascara(i, j-1)
                es_borde = true;
            elseif j < columnas && ~mascara(i, j+1)
                es_borde = true;
            end

            if es_borde
                perimetro = perimetro + 1;
            end
        end
    end
end
end

% Función para calcular el área convexa (aproximación)
function convexArea = calcular_area_convexa(i, j)
% Aproximación simple: usar el área del rectángulo delimitador
width = max(j) - min(j) + 1;
height = max(i) - min(i) + 1;
% Ajustar el área para obtener una estimación más cercana a un casco convexo real
convexArea = width * height * 0.8;
end

% Función para calcular ejes principal y menor, excentricidad y orientación
function [majorAxisLength, minorAxisLength, eccentricity, orientation] = calcular_ejes_y_orientacion(i, j)
% Calcular momentos centrales
centroid_x = mean(j);
centroid_y = mean(i);

dx = j - centroid_x;
dy = i - centroid_y;

% Momentos de segundo orden
mu20 = mean(dx.^2);
mu02 = mean(dy.^2);
mu11 = mean(dx.*dy);

% Cálculo de los ejes y orientación
delta = sqrt((mu20 - mu02)^2 + 4*mu11^2);

majorAxisLength = 2 * sqrt(2) * sqrt(mu20 + mu02 + delta);
minorAxisLength = 2 * sqrt(2) * sqrt(mu20 + mu02 - delta);

% Excentricidad
if majorAxisLength > 0
    eccentricity = sqrt(1 - (minorAxisLength/majorAxisLength)^2);
else
    eccentricity = 0;
end

% Orientación en grados
if mu20 > mu02
    orientation = 0.5 * atan2(2*mu11, mu20 - mu02) * 180/pi;
else
    orientation = 0.5 * atan2(2*mu11, mu20 - mu02) * 180/pi + 90;
end
end

% Función para calcular un casco convexo simplificado
function convexHull = calcular_casco_convexo(i, j)
% Para simplificar, retornamos los puntos extremos
xmin = min(j); ymin = min(i);
xmax = max(j); ymax = max(i);

% Aproximación con 4 puntos extremos
convexHull = [xmin, ymin; xmax, ymin; xmax, ymax; xmin, ymax];
end