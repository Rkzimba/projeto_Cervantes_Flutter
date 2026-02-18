-- Tabela principal
CREATE TABLE cadastro (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    texto TEXT NOT NULL,

    numero INTEGER NOT NULL UNIQUE CHECK(numero > 0)

);



-- Tabela de log
CREATE TABLE log (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    operacao TEXT NOT NULL,

    data TEXT NOT NULL



);

-- update