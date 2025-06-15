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

    % Calcular la circularidad (redondez) - 1 para círculo perfecto
    circularidad = 4 * pi * area / (perimetro^2);

    % Calcular relación de aspecto
    relacion_aspecto = propiedades(i).MajorAxisLength / propiedades(i).MinorAxisLength;

    % Clasificación por tipo
    if circularidad > 0.85 && excentricidad < 0.5
        if solidez > 0.9
            tipos{i} = 'Arandela';
        else
            tipos{i} = 'Tuerca';
        end
    elseif relacion_aspecto > 2.5
        tipos{i} = 'Tornillo';
    else
        tipos{i} = 'Perno';
    end

    % Clasificación por tamaño
    if area < 1000
        tamanios{i} = 'Pequeño';
    elseif area < 5000
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