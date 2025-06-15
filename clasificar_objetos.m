% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\clasificar_objetos.m
function [tipos, tamanios, esquinas] = clasificar_objetos(propiedades, imagen_gris)
num_objetos = length(propiedades);
tipos = cell(num_objetos, 1);
tamanios = cell(num_objetos, 1);
esquinas = cell(num_objetos, 1);

for i = 1:num_objetos
    % Extraer características relevantes
    area = propiedades(i).Area;
    perimetro = propiedades(i).Perimeter;
    excentricidad = propiedades(i).Eccentricity;
    solidez = propiedades(i).Solidity;
    eje_mayor = propiedades(i).MajorAxisLength;
    eje_menor = propiedades(i).MinorAxisLength;

    % Calcular la circularidad (redondez) - 1 para círculo perfecto
    circularidad = 4 * pi * area / (perimetro^2);

    % Calcular relación de aspecto
    relacion_aspecto = eje_mayor / eje_menor;

    % Clasificación por tipo - criterios mejorados
    if circularidad > 0.8 && excentricidad < 0.5
        % Objetos muy circulares - Arandelas o tuercas
        if solidez < 0.8 || (area < 2500 && circularidad > 0.9)
            tipos{i} = 'Arandela';
        else
            tipos{i} = 'Tuerca';
        end
    elseif relacion_aspecto > 2.5 && circularidad < 0.5
        % Tornillos: Muy alargados, baja circularidad
        tipos{i} = 'Tornillo';
    elseif excentricidad > 0.85 && relacion_aspecto > 1.8
        % Tornillos pequeños también tienen alta excentricidad
        tipos{i} = 'Tornillo';
    else
        % Pernos: Menos alargados que tornillos, pero no tan circulares como arandelas
        tipos{i} = 'Perno';
    end

    % Refinamiento adicional para casos problemáticos
    % Tornillos pequeños: tienen área pequeña pero son alargados
    if area < 1500 && relacion_aspecto > 1.5 && excentricidad > 0.7
        tipos{i} = 'Tornillo';
    end

    % Tuercas: generalmente son hexagonales y tienen solidez alta
    if solidez > 0.9 && circularidad > 0.6 && circularidad < 0.85 && excentricidad < 0.7
        tipos{i} = 'Tuerca';
    end

    % Arandelas grandes: alta circularidad y área grande
    if area > 3500 && circularidad > 0.75 && solidez < 0.95
        tipos{i} = 'Arandela';
    end

    % Clasificación por tamaño - umbrales ajustados
    if area < 1500
        tamanios{i} = 'Pequeño';
    elseif area < 4000
        tamanios{i} = 'Mediano';
    else
        tamanios{i} = 'Grande';
    end

    % Detección de esquinas
    bbox = floor(propiedades(i).BoundingBox);
    if bbox(1) > 0 && bbox(2) > 0 && ...
            bbox(1)+bbox(3) <= size(imagen_gris, 2) && ...
            bbox(2)+bbox(4) <= size(imagen_gris, 1)

        roi = imagen_gris(bbox(2):bbox(2)+bbox(4), bbox(1):bbox(1)+bbox(3));
        esquinas{i} = detectarEsquinasHarris(roi);
    else
        esquinas{i} = [];
    end
end
end

% Implementación manual del detector de esquinas de Harris
function puntos = detectarEsquinasHarris(imagen)
% Convertir a double si es necesario
imagen = double(imagen);

% Calcular gradientes usando el operador Sobel
Sx = [-1 0 1; -2 0 2; -1 0 1];
Sy = [-1 -2 -1; 0 0 0; 1 2 1];

Ix = conv2(imagen, Sx, 'same');
Iy = conv2(imagen, Sy, 'same');

% Calcular productos de gradientes
Ix2 = Ix .* Ix;
Iy2 = Iy .* Iy;
Ixy = Ix .* Iy;

% Aplicar suavizado gaussiano
sigma = 1.5;
tamanio = ceil(6*sigma);
if mod(tamanio, 2) == 0
    tamanio = tamanio + 1;
end
h = fspecial('gaussian', [tamanio tamanio], sigma);

A = conv2(Ix2, h, 'same');
B = conv2(Iy2, h, 'same');
C = conv2(Ixy, h, 'same');

% Calcular la respuesta de Harris
k = 0.04;
R = (A.*B - C.^2) - k*(A + B).^2;

% Encontrar máximos locales
umbral = 0.01 * max(R(:));
R_bin = R > umbral;

% Dilatar para encontrar máximos locales
se = strel('square', 3);
R_dilatada = imdilate(R, se);
R_maximos = (R == R_dilatada) & R_bin;

% Obtener coordenadas de esquinas
[y, x] = find(R_maximos);

% Crear estructura similar a la que devuelve detectHarrisFeatures
puntos = struct('Location', [x, y], 'Metric', zeros(length(x), 1));
for i = 1:length(x)
    puntos.Metric(i) = R(y(i), x(i));
end
end