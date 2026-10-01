%{
#include <stdio.h>
#include <stdlib.h>

/* Variables globales para control */
int current_line = 1;
int lexical_errors = 0;

/* Declaración de la función auxiliar para imprimir tokens */
void show_token(const char *token_type, const char *lexeme) {
    printf("%s: %s\n", token_type, lexeme);
}
%}

/* Opción para que Flex no pida yylexwrap */
%option noyywrap

%%

 /* 1. Comentarios y espacios en blanco */
"//"[^\n]*       { /* Ignorar comentarios hasta el final de la línea */ }
[ \t\r]+        { /* Ignorar espacios, tabulaciones y retornos de carro */ }
\n              { current_line++; /* Contar saltos de línea */ }

 /* 2. Cadenas de texto */
\"[^"\\\n]*\"   { show_token("STRING", yytext); }

 /* 3. Palabras reservadas (van ANTES de los identificadores) */
"print"         { show_token("PRINT", yytext); }
"if"            { show_token("IF", yytext); }
"let"           { show_token("LET", yytext); }

 /* 4. Identificadores */
[a-zA-Z_][a-zA-Z0-9_]* { show_token("IDENTIFIER", yytext); }

 /* 5. Números (DECIMAL debe ir ANTES de NUMBER) */
[0-9]+\.[0-9]+  { show_token("DECIMAL", yytext); }
[0-9]+          { show_token("NUMBER", yytext); }

 /* 6. Operadores de comparación y asignación (multicarácter ANTES de 1 carácter) */
"=="            { show_token("EQUAL_EQUAL", yytext); }
"="             { show_token("ASSIGN", yytext); }
">="            { show_token("GREATER_EQUAL", yytext); }
">"             { show_token("GREATER", yytext); }

 /* 7. Operadores aritméticos y puntuación */
"+"             { show_token("PLUS", yytext); }
"-"             { show_token("MINUS", yytext); }
"*"             { show_token("STAR", yytext); }
"("             { show_token("LPAREN", yytext); }
")"             { show_token("RPAREN", yytext); }
";"             { show_token("SEMICOLON", yytext); }

 /* 8. Captura de caracteres no reconocidos / errores */
.               { 
                  printf("Linea %d: caracter inesperado %s\n", current_line, yytext); 
                  lexical_errors++; 
                }

%%

/* Función principal (main) para probar de forma independiente si es necesario */
int main(int argc, char **argv) {
    yylex();
    if (lexical_errors > 0) {
        return 1;
    }
    return 0;
}

    




//===================================================================
RESPUESTAS A LAS PREGUNTAS DE LA PRÁCTICA DE LEX / FLEX
===================================================================

Ejercicio 1:
¿Qué contiene yytext cada vez que se ejecuta la acción?
Respuesta: 
yytext es un puntero a una cadena de caracteres administrado por Flex que 
contiene exactamente la secuencia de texto de la entrada que coincidió con el 
patrón de la regla que se acaba de activar.

-------------------------------------------------------------------

Ejercicio 2:
¿Por qué el analizador divide 2total en lugar de reportarlo como un único identificador inválido?
Respuesta: 
Porque Flex analiza el texto leyendo de izquierda a derecha. Al leer '2', no puede 
coincidir con la regla de IDENTIFIER (ya que requiere empezar con una letra o '_'), 
pero sí coincide con la regla NUMBER. Por lo tanto, extrae '2' como NUMBER y deja 
'total' en la entrada, la cual luego coincide perfectamente como IDENTIFIER.

-------------------------------------------------------------------

Ejercicio 3:
¿Por qué el orden importa para print, pero no hace que printer se divida en dos tokens?
Respuesta: 
El orden importa para 'print' porque si las reglas de palabras reservadas e identificadores 
compiten con un texto de la misma longitud ('print'), Flex elegirá la regla que esté 
escrita primero. Sin embargo, no divide 'printer' porque Flex aplica la regla de la 
coincidencia más larga (Longest Match): 'printer' tiene 7 caracteres y coincide con 
IDENTIFIER, superando los 5 caracteres de 'print'.

-------------------------------------------------------------------

Ejercicio 4:
¿Reconocer los paréntesis significa que el analizador verifica que cada paréntesis de apertura tenga uno de cierre?
Respuesta: 
No. El analizador léxico solo se encarga de tokenizar, es decir, de identificar y 
clasificar los símbolos individuales. La verificación del balance de paréntesis y la 
estructura gramatical es tarea del analizador sintáctico (parser).

-------------------------------------------------------------------

Ejercicio 5:
¿Por qué === se convierte en dos tokens con estas reglas?
Respuesta: 
Ante la secuencia '===', Flex busca la coincidencia más larga posible, que es '==' 
(EQUAL_EQUAL, 2 caracteres). Tras procesar esa parte, queda en la entrada un solo '=', 
el cual coincide con la regla '=' (ASSIGN, 1 carácter).

-------------------------------------------------------------------

Ejercicio 6:
¿Cuál es la diferencia entre . y "." en un patrón de Lex?
Respuesta: 
En Lex, el punto sin comillas (.) es un carácter comodín que coincide con cualquier 
carácter excepto el salto de línea. El punto entre comillas (".") o escapado (\.) 
representa el carácter literal del punto.

-------------------------------------------------------------------

Ejercicio 7:
¿Por qué el patrón del comentario debe detenerse al llegar al salto de línea?
Respuesta: 
Debe detenerse en el salto de línea para marcar el fin del comentario y permitir 
que el analizador procese el salto de línea (incrementando el contador) y continúe 
con la siguiente instrucción del programa en la línea siguiente.

-------------------------------------------------------------------

Ejercicio 8:
¿Por qué el espacio dentro de "hola mundo" forma parte del token STRING en lugar de ser ignorado por la regla de espacios?
Respuesta: 
Porque el espacio está contenido dentro del patrón de la cadena (\"[^"\\\n]*\"), el cual 
abarca desde la comilla inicial hasta la comilla final. Al ser un solo patrón continuo de 
mayor longitud, Flex captura toda la secuencia de la cadena junta.

-------------------------------------------------------------------

Ejercicio 9:
¿Por qué hay que quitar el salto de línea de la regla anterior de espacios en blanco para que este contador funcione correctamente?
Respuesta: 
Porque se necesita una regla específica para '\n' que ejecute la acción de incrementar 
la variable 'current_line'. Si los saltos de línea se consumen agrupados dentro de un 
patrón amplio como [ \t\n\r]+, no habría forma de saber cuántos saltos se procesaron.

-------------------------------------------------------------------

Ejercicio 10 (Pregunta Final):
Describe qué ocurre desde que yylex() lee la entrada hasta que una acción llama a show_token() en C. ¿Cuáles de esas decisiones dependen de tus patrones de Lex?
Respuesta: 
1. Proceso: yylex() lee la entrada carácter por carácter y busca coincidencias con las reglas definidas.
2. Toma de decisiones de Flex:
   - Coincidencia más larga (Longest Match): Selecciona la regla que consuma la mayor cantidad de caracteres.
   - Primera regla (First Match): Si hay empate en la longitud consumida, elige la regla declarada primero en el archivo .l.
3. Decisión que depende de las reglas: Tanto el texto consumido como el token que se asigna dependen directamente de los patrones expresados en las expresiones regulares y del orden en el que fueron redactados.
4. Ejecución: Al seleccionar la regla, carga el texto reconocido en 'yytext' y ejecuta el bloque C de acción asociado, llamando a 'show_token()'.



