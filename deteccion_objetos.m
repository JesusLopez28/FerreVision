% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\deteccion_objetos.m
function [objetos_etiquetados, num_objetos, propiedades] = deteccion_objetos(imagen_binaria)
% Etiquetar objetos conectados
[objetos_etiquetados, num_objetos] = bwlabel(imagen_binaria);

% Extraer propiedades de los objetos
propiedades = regionprops(objetos_etiquetados, 'Area', 'Centroid', 'BoundingBox', ...
    'MajorAxisLength', 'MinorAxisLength', 'Perimeter', 'Eccentricity', ...
    'Orientation', 'ConvexHull', 'Solidity', 'PixelIdxList');

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
    [objetos_etiquetados, num_objetos] = bwlabel(imagen_filtrada);
    propiedades = regionprops(objetos_etiquetados, 'Area', 'Centroid', 'BoundingBox', ...
        'MajorAxisLength', 'MinorAxisLength', 'Perimeter', 'Eccentricity', ...
        'Orientation', 'ConvexHull', 'Solidity', 'PixelIdxList');
    
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
            
            [objetos_etiquetados, num_objetos] = bwlabel(imagen_filtrada);
            propiedades = regionprops(objetos_etiquetados, 'Area', 'Centroid', 'BoundingBox', ...
                'MajorAxisLength', 'MinorAxisLength', 'Perimeter', 'Eccentricity', ...
                'Orientation', 'ConvexHull', 'Solidity', 'PixelIdxList');
        end
    end
end
end