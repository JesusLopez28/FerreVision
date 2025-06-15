% filepath: e:\Escuela\CETI Colomos\7mo Semestre\PROCESAMIENTO DE IMÁGENES\3er Parcial\proyecto\main.m
%% CLASIFICADOR DE ELEMENTOS DE FERRETERÍA
% Archivo principal para ejecutar el sistema completo de clasificación
% Autor: Jesús Alejandro López Rosales
% Fecha: 2025-06-14

function main()
try
    % Limpiar workspace y pantalla
    close all;
    clear;
    clc;

    fprintf('=== CLASIFICADOR DE ELEMENTOS DE FERRETERÍA ===\n');
    fprintf('Iniciando sistema de clasificación...\n\n');

    % Llamar al clasificador principal
    clasificador_ferreteria();

    fprintf('\n=== PROCESO COMPLETADO EXITOSAMENTE ===\n');

catch ME
    % Manejo de errores
    fprintf('\nERROR: %s\n', ME.message);
    fprintf('El proceso no pudo completarse correctamente.\n');

    % Mostrar información adicional del error en modo debug
    if exist('debug_mode', 'var') && debug_mode
        fprintf('\nDetalles del error:\n');
        fprintf('Archivo: %s\n', ME.stack(1).file);
        fprintf('Línea: %d\n', ME.stack(1).line);
    end
end
end