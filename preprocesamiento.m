% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\preprocesamiento.m
function imagen_preprocesada = preprocesamiento(imagen)
    % Convertir a escala de grises si es RGB
    if size(imagen, 3) == 3
        imagen_gris = rgb2gray(imagen);
    else
        imagen_gris = imagen;
    end
    
    % Mejora de contraste mediante ecualización del histograma
    imagen_ecualizada = adapthisteq(imagen_gris);
    
    % Filtrado para reducción de ruido
    imagen_filtrada = medfilt2(imagen_ecualizada, [3 3]);
    
    % Realce de bordes usando filtro Unsharp
    h = fspecial('unsharp', 0.5);
    imagen_preprocesada = imfilter(imagen_filtrada, h, 'replicate');
end