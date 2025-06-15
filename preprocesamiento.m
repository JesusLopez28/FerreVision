% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\preprocesamiento.m
function imagen_preprocesada = preprocesamiento(imagen)
    % Convertir a escala de grises si es RGB
    if size(imagen, 3) == 3
        % Implementación manual de rgb2gray
        imagen_gris = 0.2989 * double(imagen(:,:,1)) + ...
                      0.5870 * double(imagen(:,:,2)) + ...
                      0.1140 * double(imagen(:,:,3));
        imagen_gris = uint8(imagen_gris);
    else
        imagen_gris = imagen;
    end
    
    % Implementación manual de ecualización de histograma
    [M, N] = size(imagen_gris);
    hist_counts = zeros(256, 1);
    
    % Calcular histograma
    for i = 1:M
        for j = 1:N
            hist_counts(imagen_gris(i,j)+1) = hist_counts(imagen_gris(i,j)+1) + 1;
        end
    end
    
    % Calcular función de distribución acumulativa
    cdf = cumsum(hist_counts) / (M * N);
    
    % Aplicar ecualización
    imagen_ecualizada = zeros(size(imagen_gris));
    for i = 1:M
        for j = 1:N
            imagen_ecualizada(i,j) = uint8(round(cdf(imagen_gris(i,j)+1) * 255));
        end
    end
    imagen_ecualizada = uint8(imagen_ecualizada);
    
    % Implementación manual de filtro de mediana
    [M, N] = size(imagen_ecualizada);
    imagen_filtrada = zeros(M, N);
    padded_image = padarray(imagen_ecualizada, [1 1], 'replicate');
    
    for i = 2:M+1
        for j = 2:N+1
            % Extraer ventana 3x3
            window = padded_image(i-1:i+1, j-1:j+1);
            % Ordenar valores y tomar la mediana
            sorted_values = sort(window(:));
            imagen_filtrada(i-2+1, j-2+1) = sorted_values(5); % El valor central de 9 elementos
        end
    end
    imagen_filtrada = uint8(imagen_filtrada);
    
    % Implementación manual de realce de bordes (unsharp masking)
    % Crear kernel gaussiano para desenfoque
    kernel_size = 5;
    sigma = 1.0;
    kernel = zeros(kernel_size, kernel_size);
    center = floor(kernel_size/2) + 1;
    
    for i = 1:kernel_size
        for j = 1:kernel_size
            x = i - center;
            y = j - center;
            kernel(i,j) = exp(-(x^2 + y^2)/(2*sigma^2)) / (2*pi*sigma^2);
        end
    end
    kernel = kernel / sum(kernel(:)); % Normalizar
    
    % Aplicar desenfoque gaussiano
    [M, N] = size(imagen_filtrada);
    blurred = zeros(M, N);
    padded_image = padarray(double(imagen_filtrada), [floor(kernel_size/2) floor(kernel_size/2)], 'replicate');
    
    for i = 1:M
        for j = 1:N
            % Extraer ventana del tamaño del kernel
            window = padded_image(i:i+kernel_size-1, j:j+kernel_size-1);
            % Aplicar convolución
            blurred(i,j) = sum(sum(window .* kernel));
        end
    end
    
    % Aplicar unsharp masking
    alpha = 0.5; % Factor de realce
    imagen_preprocesada = uint8(min(max(double(imagen_filtrada) + alpha * (double(imagen_filtrada) - blurred), 0), 255));
end