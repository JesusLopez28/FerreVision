% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\segmentacion.m
function [imagen_binaria, imagen_dilatada, imagen_erosionada] = segmentacion(imagen)
% Binarización adaptativa usando método de Otsu manual
nivel = otsu_manual(imagen);
imagen_binaria = binarizar_manual(imagen, nivel);

% Invertir imagen si es necesario (asumiendo objetos oscuros en fondo claro)
if sum(imagen_binaria(:)) > numel(imagen_binaria)/2
    imagen_binaria = ~imagen_binaria;
end

% Crear elementos estructurantes para operaciones morfológicas
se_disco = crear_strel_disco(3);  % Elemento estructurante de disco con radio 3
se_linea = crear_strel_linea(5, 90);  % Elemento estructurante de línea de longitud 5 y ángulo 90°

% Operaciones morfológicas
imagen_erosionada = erosion_manual(imagen_binaria, se_disco);
imagen_dilatada = dilatacion_manual(imagen_erosionada, se_disco);

% Aplicar una operación de cierre para conectar componentes cercanos
imagen_cerrada = cierre_manual(imagen_dilatada, crear_strel_disco(1));

% Eliminar objetos pequeños (ruido)
imagen_binaria = eliminar_objetos_pequenos(imagen_cerrada, 100);

% Rellenar huecos en los objetos
imagen_binaria = rellenar_huecos(imagen_binaria);
end

% Implementación manual del método de Otsu
function nivel = otsu_manual(imagen)
% Asegurarse de que la imagen esté en formato double en el rango [0,1]
if max(imagen(:)) > 1
    imagen = double(imagen)/255;
end

% Calcular histograma
[counts, x] = hist(imagen(:), 256);
counts = counts / sum(counts);

% Inicializar variables
varianza_max = 0;
umbral = 0;

% Calcular la media total
media_total = sum(x .* counts);

% Peso acumulado y media acumulada
w = cumsum(counts);
mu = cumsum(x .* counts);

% Buscar el umbral óptimo
for i = 1:length(counts)
    if w(i) > 0 && w(i) < 1
        % Calcular varianza entre clases
        w1 = w(i);
        w2 = 1 - w1;
        mu1 = mu(i) / w1;
        mu2 = (media_total - mu(i)) / w2;
        varianza = w1 * w2 * (mu1 - mu2)^2;

        % Actualizar si encontramos una varianza mayor
        if varianza > varianza_max
            varianza_max = varianza;
            umbral = x(i);
        end
    end
end

nivel = umbral;
end

% Binarización manual con umbral
function binaria = binarizar_manual(imagen, umbral)
if max(imagen(:)) > 1
    imagen = double(imagen)/255;
end
binaria = imagen > umbral;
end

% Crear elemento estructurante de disco
function se = crear_strel_disco(radio)
[y, x] = meshgrid(-radio:radio, -radio:radio);
se = (x.^2 + y.^2) <= radio^2;
end

% Crear elemento estructurante de línea
function se = crear_strel_linea(longitud, angulo)
rad = angulo * pi / 180;
dx = cos(rad);
dy = sin(rad);

% Crear una matriz lo suficientemente grande
padding = ceil(longitud/2);
[y, x] = meshgrid(-padding:padding, -padding:padding);

% Distancia desde cada punto hasta la línea
dist = abs(x*dy - y*dx) / sqrt(dx^2 + dy^2);

% Distancia a lo largo de la línea
proj = x*dx + y*dy;

% Crear el elemento estructurante
se = (dist < 0.5) & (abs(proj) <= longitud/2);
end

% Erosión manual
function resultado = erosion_manual(imagen, se)
[m, n] = size(imagen);
[sm, sn] = size(se);
padding_m = floor(sm/2);
padding_n = floor(sn/2);

% Rellenar con ceros alrededor de la imagen
imagen_padded = padarray(imagen, [padding_m, padding_n], 0, 'both');
resultado = false(m, n);

% Realizar erosión
for i = 1:m
    for j = 1:n
        ventana = imagen_padded(i:i+sm-1, j:j+sn-1);
        if all(ventana(se))
            resultado(i, j) = true;
        end
    end
end
end

% Dilatación manual
function resultado = dilatacion_manual(imagen, se)
[m, n] = size(imagen);
[sm, sn] = size(se);
padding_m = floor(sm/2);
padding_n = floor(sn/2);

% Rellenar con ceros alrededor de la imagen
imagen_padded = padarray(imagen, [padding_m, padding_n], 0, 'both');
resultado = false(m, n);

% Realizar dilatación
for i = 1:m
    for j = 1:n
        ventana = imagen_padded(i:i+sm-1, j:j+sn-1);
        if any(ventana(se))
            resultado(i, j) = true;
        end
    end
end
end

% Operación de cierre manual (dilatación seguida de erosión)
function resultado = cierre_manual(imagen, se)
dilatada = dilatacion_manual(imagen, se);
resultado = erosion_manual(dilatada, se);
end

% Eliminar objetos pequeños
function resultado = eliminar_objetos_pequenos(imagen, min_size)
% Etiquetar componentes conectados
[etiquetas, num_objetos] = etiquetar_componentes(imagen);

% Contar tamaño de cada objeto
tamanos = zeros(1, num_objetos);
for i = 1:num_objetos
    tamanos(i) = sum(etiquetas(:) == i);
end

% Crear imagen resultante eliminando objetos pequeños
resultado = imagen;
for i = 1:num_objetos
    if tamanos(i) < min_size
        resultado(etiquetas == i) = 0;
    end
end
end

% Etiquetar componentes conectados
function [etiquetas, num_objetos] = etiquetar_componentes(imagen)
[m, n] = size(imagen);
etiquetas = zeros(m, n);
visitado = false(m, n);
num_objetos = 0;

% Recorrer la imagen
for i = 1:m
    for j = 1:n
        if imagen(i, j) && ~visitado(i, j)
            num_objetos = num_objetos + 1;
            etiquetar_region(i, j, num_objetos);
        end
    end
end

% Función anidada para etiquetado recursivo de regiones
    function etiquetar_region(x, y, etiqueta)
        % Si está fuera de los límites o ya visitado o no es objeto, salir
        if x < 1 || y < 1 || x > m || y > n || visitado(x, y) || ~imagen(x, y)
            return;
        end

        % Etiquetar y marcar como visitado
        etiquetas(x, y) = etiqueta;
        visitado(x, y) = true;

        % Etiquetar vecinos (8-conectividad)
        for dx = -1:1
            for dy = -1:1
                if dx ~= 0 || dy ~= 0
                    etiquetar_region(x+dx, y+dy, etiqueta);
                end
            end
        end
    end
end

% Rellenar huecos en objetos
function resultado = rellenar_huecos(imagen)
% Encontrar los bordes de la imagen
bordes = true(size(imagen));
bordes(2:end-1, 2:end-1) = false;

% Crear máscara inicial: todo fuera de los objetos y conectado con el borde
mascara = ~imagen;
semillas = mascara & bordes;

% Realizar propagación de región desde los bordes
[m, n] = size(imagen);
etiquetas = zeros(m, n);
etiquetas(semillas) = 1;

cambio = true;
while cambio
    cambio = false;
    etiquetas_old = etiquetas;

    for i = 2:m-1
        for j = 2:n-1
            if mascara(i, j) && etiquetas(i, j) == 0
                % Verificar si algún vecino está etiquetado
                for di = -1:1
                    for dj = -1:1
                        if etiquetas(i+di, j+dj) == 1
                            etiquetas(i, j) = 1;
                            cambio = true;
                            break;
                        end
                    end
                    if etiquetas(i, j) == 1
                        break;
                    end
                end
            end
        end
    end
end

% Los huecos son los píxeles que no son objeto y no están conectados al borde
huecos = mascara & (etiquetas == 0);

% Rellenar huecos
resultado = imagen | huecos;
end