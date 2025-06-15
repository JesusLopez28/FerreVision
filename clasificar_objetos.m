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
        esquinas{i} = detectHarrisFeatures(roi);
    else
        esquinas{i} = [];
    end
end
end