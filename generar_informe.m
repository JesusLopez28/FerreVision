% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\generar_informe.m
function generar_informe(tipos)
% Contar objetos por tipo
tipos_unicos = unique(tipos);
conteo = zeros(length(tipos_unicos), 1);

for i = 1:length(tipos_unicos)
    conteo(i) = sum(strcmp(tipos, tipos_unicos{i}));
end

% Crear figura para el informe
figure('Name', 'Informe de Conteo', 'NumberTitle', 'off', 'Position', [100, 100, 600, 400]);

% Gráfico de barras
subplot(1, 2, 1);
bar(conteo);
set(gca, 'XTick', 1:length(tipos_unicos), 'XTickLabel', tipos_unicos);
title('Conteo por Tipo');
ylabel('Cantidad');
grid on;

% Gráfico circular
subplot(1, 2, 2);
pie(conteo, tipos_unicos);
title('Distribución de Objetos');

% Imprimir resultados en la consola
fprintf('=== INFORME DE INVENTARIO ===\n');
for i = 1:length(tipos_unicos)
    fprintf('%s: %d unidades\n', tipos_unicos{i}, conteo(i));
end
fprintf('Total: %d objetos\n', sum(conteo));
end