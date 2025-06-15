% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\deteccion_objetos.m
function [objetos_etiquetados, num_objetos, propiedades] = deteccion_objetos(imagen_binaria)
% Etiquetar objetos conectados
[objetos_etiquetados, num_objetos] = bwlabel(imagen_binaria);

% Extraer propiedades de los objetos
propiedades = regionprops(objetos_etiquetados, 'Area', 'Centroid', 'BoundingBox', ...
    'MajorAxisLength', 'MinorAxisLength', 'Perimeter', 'Eccentricity', ...
    'Orientation', 'ConvexHull', 'Solidity', 'PixelIdxList');

% Filtrar objetos por tamaño si es necesario
if num_objetos > 100  % Si hay muchos objetos, probablemente sea ruido
    areas = [propiedades.Area];
    area_media = mean(areas);
    idx_objetos_validos = find(areas > (area_media * 0.1));

    % Reconstruir etiquetado con solo objetos válidos
    imagen_filtrada = false(size(imagen_binaria));
    for i = 1:length(idx_objetos_validos)
        idx = idx_objetos_validos(i);
        imagen_filtrada(propiedades(idx).PixelIdxList) = true;
    end

    [objetos_etiquetados, num_objetos] = bwlabel(imagen_filtrada);
    propiedades = regionprops(objetos_etiquetados, 'Area', 'Centroid', 'BoundingBox', ...
        'MajorAxisLength', 'MinorAxisLength', 'Perimeter', 'Eccentricity', ...
        'Orientation', 'ConvexHull', 'Solidity', 'PixelIdxList');
end
end