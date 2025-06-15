% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\mostrar_resultados.m
function imagen_resultado = mostrar_resultados(imagen_original, propiedades, tipos, tamanios)
% Crear copia de la imagen original
imagen_resultado = imagen_original;

% Definir colores para cada tipo de objeto
colores = containers.Map;
colores('Tornillo') = [255, 0, 0];    % Rojo
colores('Tuerca') = [0, 255, 0];      % Verde
colores('Arandela') = [0, 0, 255];    % Azul
colores('Perno') = [255, 255, 0];     % Amarillo

% Dibujar rectángulos y etiquetas
for i = 1:length(propiedades)
    bbox = propiedades(i).BoundingBox;

    % Convertir coordenadas del bounding box a enteros
    x = floor(bbox(1));
    y = floor(bbox(2));
    w = floor(bbox(3));
    h = floor(bbox(4));

    % Verificar límites de la imagen
    if x < 1, x = 1; end
    if y < 1, y = 1; end
    if x+w > size(imagen_resultado, 2), w = size(imagen_resultado, 2) - x; end
    if y+h > size(imagen_resultado, 1), h = size(imagen_resultado, 1) - y; end

    % Obtener color según el tipo
    color = colores(tipos{i});

    % Dibujar rectángulo
    imagen_resultado = insertShape(imagen_resultado, 'Rectangle', [x, y, w, h], ...
        'Color', color, 'LineWidth', 2);

    % Dibujar etiqueta
    texto = [tipos{i}, ' ', tamanios{i}];
    imagen_resultado = insertText(imagen_resultado, [x, y-15], texto, ...
        'FontSize', 12, 'BoxColor', color, 'TextColor', 'white');
end
end