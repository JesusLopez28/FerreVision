% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\clasificar_objetos.m
function [tipos, esquinas] = clasificar_objetos(propiedades, imagen_gris)
num_objetos = length(propiedades);
tipos = cell(num_objetos, 1);
esquinas = cell(num_objetos, 1);

for i = 1:num_objetos
    % Extraer características relevantes
    area = propiedades(i).Area;
    perimetro = propiedades(i).Perimeter;
    excentricidad = propiedades(i).Eccentricity;
    solidez = propiedades(i).Solidity;
    eje_mayor = propiedades(i).MajorAxisLength;
    eje_menor = propiedades(i).MinorAxisLength;

    % Mejorar el cálculo de circularidad
    circularidad = 4 * pi * area / (perimetro^2);

    % Calcular circularidad normalizada (0-1, donde 1 es círculo perfecto)
    circularidad_norm = min(1, circularidad);

    % Calcular relación de aspecto
    relacion_aspecto = eje_mayor / eje_menor;

    % Calcular compacidad adicional para mejor discriminación
    compacidad = area / (eje_mayor^2);

    % Factor de forma alternativo
    factor_forma = (perimetro^2) / (4 * pi * area);

    % CLASIFICACIÓN MEJORADA PARA TUERCAS Y ARANDELAS

    % Tornillos (detectar primero para evitar confusiones)
    if (relacion_aspecto > 2.2 && circularidad_norm < 0.4) || ...
            (excentricidad > 0.8 && relacion_aspecto > 1.8) || ...
            (area < 1500 && relacion_aspecto > 1.6 && solidez < 0.9)
        tipos{i} = 'Tornillo';

        % TUERCAS - Solidez ampliada hasta 0.98
    elseif (solidez >= 0.91 && solidez <= 0.98) && ...           % Solidez característica de tuerca (ampliada)
            (circularidad_norm >= 0.65 && circularidad_norm <= 0.85) && ... % Circularidad moderada
            (excentricidad >= 0.28 && excentricidad <= 0.38) && ...         % Excentricidad ajustada para tuerca
            (relacion_aspecto < 1.3) && ...                       % Forma compacta
            (compacidad > 0.15)                                   % Compacidad razonable
        tipos{i} = 'Tuerca';

        % ARANDELAS - Solidez exactamente 0.91
    elseif (circularidad_norm >= 0.85) && ...                   % Alta circularidad
            (abs(solidez - 0.91) < 0.01) && ...                 % Solidez característica de arandela
            (excentricidad >= 0.20 && excentricidad <= 0.27) && ... % Excentricidad ajustada para arandela
            (relacion_aspecto < 1.2) && ...                      % Forma muy compacta
            (factor_forma < 1.3)                                 % Factor de forma cercano a círculo
        tipos{i} = 'Arandela';

        % Refinamientos adicionales basados en características específicas

        % Tuercas grandes con características hexagonales
    elseif (area > 2500) && ...
            (solidez >= 0.91 && solidez <= 0.98) && ... % Ajuste para tuercas grandes (ampliado)
            (circularidad_norm >= 0.70 && circularidad_norm <= 0.82) && ...
            (excentricidad >= 0.28 && excentricidad <= 0.38)
        tipos{i} = 'Tuerca';

        % Arandelas pequeñas muy circulares
    elseif (area >= 800 && area <= 3000) && ...
            (circularidad_norm >= 0.90) && ...
            (abs(solidez - 0.91) < 0.02) && ... % Ajuste para arandelas pequeñas
            (excentricidad >= 0.20 && excentricidad <= 0.27)
        tipos{i} = 'Arandela';

        % Arandelas grandes con tolerancias ajustadas
    elseif (area > 3000) && ...
            (circularidad_norm >= 0.82) && ...
            (abs(solidez - 0.91) < 0.02) && ... % Ajuste para arandelas grandes
            (excentricidad >= 0.20 && excentricidad <= 0.27) && ...
            (compacidad > 0.12)
        tipos{i} = 'Arandela';

        % Clasificación por descarte para objetos ambiguos
    elseif (circularidad_norm >= 0.6) && (excentricidad < 0.6) && (relacion_aspecto < 1.5)
        % Decidir entre tuerca y arandela basándose en solidez
        if (solidez >= 0.91 && solidez <= 0.98) && (excentricidad >= 0.28 && excentricidad <= 0.38)
            tipos{i} = 'Tuerca';
        elseif abs(solidez - 0.91) < 0.02 && (excentricidad >= 0.20 && excentricidad <= 0.27)
            tipos{i} = 'Arandela';
        else
            tipos{i} = 'Arandela';
        end

    else
        % Por defecto, objetos alargados o irregulares son tornillos
        tipos{i} = 'Tornillo';
    end

    % Detección de esquinas mejorada
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

% Implementación mejorada del detector de esquinas de Harris
function puntos = detectarEsquinasHarris(imagen)
% Convertir a double si es necesario
imagen = double(imagen);

% Aplicar filtro gaussiano inicial para reducir ruido
sigma_inicial = 0.8;
h_inicial = fspecial('gaussian', [5 5], sigma_inicial);
imagen = conv2(imagen, h_inicial, 'same');

% Calcular gradientes usando operadores mejorados
Sx = [-1 0 1; -2 0 2; -1 0 1];  % Sobel X
Sy = [-1 -2 -1; 0 0 0; 1 2 1];  % Sobel Y

Ix = conv2(imagen, Sx, 'same');
Iy = conv2(imagen, Sy, 'same');

% Calcular productos de gradientes
Ix2 = Ix .* Ix;
Iy2 = Iy .* Iy;
Ixy = Ix .* Iy;

% Aplicar suavizado gaussiano con parámetros optimizados
sigma = 1.2;  % Reducido para mejor localización
tamanio = ceil(4*sigma);  % Ventana más pequeña
if mod(tamanio, 2) == 0
    tamanio = tamanio + 1;
end
h = fspecial('gaussian', [tamanio tamanio], sigma);

A = conv2(Ix2, h, 'same');
B = conv2(Iy2, h, 'same');
C = conv2(Ixy, h, 'same');

% Calcular la respuesta de Harris con k optimizado
k = 0.06;  % Valor ajustado para mejor detección en formas geométricas
R = (A.*B - C.^2) - k*(A + B).^2;

% Mejorar la detección de máximos
umbral = 0.005 * max(R(:));  % Umbral más sensible
R_bin = R > umbral;

% Usar supresión de no-máximos más efectiva
ventana = 5;  % Ventana de supresión
se = strel('square', ventana);
R_dilatada = imdilate(R, se);
R_maximos = (R == R_dilatada) & R_bin;

% Filtrar esquinas muy cercanas al borde
margen = 3;
[alto, ancho] = size(R);
R_maximos(1:margen, :) = false;
R_maximos(end-margen+1:end, :) = false;
R_maximos(:, 1:margen) = false;
R_maximos(:, end-margen+1:end) = false;

% Obtener coordenadas de esquinas
[y, x] = find(R_maximos);

% Crear estructura con métricas mejoradas
puntos = struct('Location', [x, y], 'Metric', zeros(length(x), 1));
for i = 1:length(x)
    puntos.Metric(i) = R(y(i), x(i));
end

% Ordenar por métrica (mejores esquinas primero)
if length(puntos.Metric) > 1
    [~, idx] = sort(puntos.Metric, 'descend');
    puntos.Location = puntos.Location(idx, :);
    puntos.Metric = puntos.Metric(idx);
end
end