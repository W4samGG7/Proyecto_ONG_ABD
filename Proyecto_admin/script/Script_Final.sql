--CREACION BASE DE DATOS--

--habilitar autenticacion autocontenida
EXEC sp_configure 'contained database authentication', 1;
RECONFIGURE;

--habilitar politicas de seguridad
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
    N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', 
    N'SQLServerOlxPasswordPolicy', 
    REG_DWORD, 1;

--habilitar estadisticas de tiempo
set statistics io on;
set statistics time on;

--creacion de bd con configuracion contenida
use master;

CREATE DATABASE DonacionesDB CONTAINMENT = PARTIAL;

--creacion de secuencias
USE DonacionesDB;

CREATE SEQUENCE dbo.seq_personal
	AS INT
	START WITH 100
	INCREMENT BY 1
	NO CYCLE
	CACHE 50;

CREATE SEQUENCE dbo.seq_proyecto
	AS INT
	START WITH 1
	INCREMENT BY 1
	NO CYCLE
	CACHE 50;

CREATE SEQUENCE dbo.seq_beneficiario
	AS INT
	START WITH 1
	INCREMENT BY 1
	NO CYCLE
	CACHE 50;

CREATE SEQUENCE dbo.seq_donante
	AS INT
	START WITH 1
	INCREMENT BY 1
	NO CYCLE
	CACHE 50;

CREATE SEQUENCE dbo.seq_donacion
	AS INT 
	START WITH 1
	INCREMENT BY 1
	NO CYCLE
	CACHE 50;

CREATE SEQUENCE dbo.seq_recibo
	AS INT 
	START WITH 1000
	INCREMENT BY 1
	NO CYCLE
	CACHE 50;

--definicion de tablas
USE DonacionesDB;

CREATE TABLE Rol (
    id INT PRIMARY KEY IDENTITY(1,1),
    rol VARCHAR(15) NOT NULL
);

CREATE TABLE Personal_Estado (
    id INT PRIMARY KEY IDENTITY(1,1),
    estado VARCHAR(15) NOT NULL
);

CREATE TABLE Proyecto_Categoria (
	id INT PRIMARY KEY IDENTITY(1,1),
	categoria VARCHAR(25) NOT NULL
);

CREATE TABLE Proyecto_Estado (
	id INT PRIMARY KEY IDENTITY(1,1),
	estado VARCHAR(15) NOT NULL
);

CREATE TABLE Tipo_Beneficiario (
	id INT PRIMARY KEY IDENTITY(1,1),
	tipo_beneficiario VARCHAR(25) NOT NULL
);

CREATE TABLE Genero (
    id INT PRIMARY KEY IDENTITY(1,1),
    genero VARCHAR(15) NOT NULL
);

CREATE TABLE Rubro (
    id INT PRIMARY KEY IDENTITY(1,1),
    rubro VARCHAR(25) NOT NULL
);

CREATE TABLE Tipo_Institucion (
	id INT PRIMARY KEY IDENTITY(1,1),
	tipo_institucion VARCHAR(25) NOT NULL
);

CREATE TABLE Tipo_Donante (
    id INT PRIMARY KEY IDENTITY(1,1),
    tipo_donante VARCHAR(25) NOT NULL
);

CREATE TABLE Tipo_Donacion (
    id INT PRIMARY KEY IDENTITY(1,1),
    tipo_donacion VARCHAR(15) NOT NULL
);

CREATE TABLE Metodo_Pago (
    id INT PRIMARY KEY IDENTITY(1,1),
    metodo_pago VARCHAR(25) NOT NULL
);

CREATE TABLE Bienes_Categoria (
    id INT PRIMARY KEY IDENTITY(1,1),
    categoria VARCHAR(30) NOT NULL
);


CREATE TABLE Proyecto (
    id INT NOT NULL
		CONSTRAINT DF_Proyecto_id DEFAULT(NEXT VALUE FOR dbo.seq_proyecto),
    nombre VARCHAR(75) NOT NULL,
	descripcion TEXT NOT NULL,
	presupuesto_objetivo DECIMAL(10,2) NOT NULL,
	presupuesto_recaudado DECIMAL(10,2) NOT NULL,
	ubicacion TEXT NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
    id_proyecto_categoria INT NOT NULL, FOREIGN KEY (id_proyecto_categoria) REFERENCES Proyecto_Categoria(id),
	id_proyecto_estado INT NOT NULL, FOREIGN KEY (id_proyecto_estado) REFERENCES Proyecto_Estado(id),
	lider_proyecto INT NOT NULL,
	codigo_proyecto AS ('P-'+ RIGHT(REPLICATE('0',4)+CAST(id AS
		VARCHAR(10)),4)) PERSISTED,
			CONSTRAINT PK_Proyecto PRIMARY KEY (id)
);

CREATE TABLE Personal (
    id INT NOT NULL
		CONSTRAINT DF_Personal_id DEFAULT(NEXT VALUE FOR dbo.seq_personal),
    nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	dui VARCHAR(15) NOT NULL,
	telefono VARCHAR(20) NOT NULL,
	email VARCHAR(100) NOT NULL,
	fecha_ingreso DATE NOT NULL,
    id_rol INT NOT NULL, FOREIGN KEY (id_rol) REFERENCES Rol(id),
	id_personal_estado INT NOT NULL, FOREIGN KEY (id_personal_estado) REFERENCES Personal_Estado(id),
	codigo_personal AS (
		CASE id_rol
			WHEN 1 THEN 'E-'
			WHEN 2 THEN 'V-'
		END
		+ RIGHT(REPLICATE('0',4)+CAST(id AS
		VARCHAR(10)),4)) PERSISTED,
			CONSTRAINT PK_Personal PRIMARY KEY (id)
);

ALTER TABLE Proyecto
ADD CONSTRAINT FK_lider_proyecto
	FOREIGN KEY (lider_proyecto) REFERENCES Personal(id);

CREATE TABLE Personal_Proyecto (
    id INT PRIMARY KEY IDENTITY (1,1),
	fecha_asignacion DATE NOT NULL,
	id_personal INT NOT NULL, FOREIGN KEY (id_personal) REFERENCES Personal(id),
	id_proyecto INT NOT NULL, FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id)
);

CREATE TABLE Beneficiario (
	id INT NOT NULL
		CONSTRAINT DF_Beneficiario_id DEFAULT(NEXT VALUE FOR dbo.seq_beneficiario),
    direccion TEXT,
	contacto_nombre VARCHAR(50),
	contacto_telefono VARCHAR(20),
	email VARCHAR(100),
	id_tipo_beneficiario INT NOT NULL, FOREIGN KEY (id_tipo_beneficiario) REFERENCES Tipo_Beneficiario(id),
	codigo_beneficiario AS (
		CASE id_tipo_beneficiario
			WHEN 1 THEN 'BIND-'
			WHEN 2 THEN 'BINS-'
		END
		+ RIGHT(REPLICATE('0',4)+CAST(id AS
		VARCHAR(10)),4)) PERSISTED,
			CONSTRAINT PK_Beneficiario PRIMARY KEY (id)
);

CREATE TABLE Proyecto_Beneficiario (
	id INT PRIMARY KEY IDENTITY(1,1),
	fecha_asignacion DATE NOT NULL,
	id_proyecto INT NOT NULL, FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id),
	id_beneficiario INT NOT NULL, FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id)
);

CREATE TABLE Beneficiario_Institucion (
	id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(75) NOT NULL,
	codigo_registro varchar(15) NOT NULL, 
	director VARCHAR(125) NOT NULL,
	alcance INT,
	id_tipo_institucion INT NOT NULL, FOREIGN KEY (id_tipo_institucion) REFERENCES Tipo_Institucion(id),
	id_rubro INT NOT NULL, FOREIGN KEY (id_rubro) REFERENCES Rubro(id),
	id_beneficiario INT NOT NULL, FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id)
);


CREATE TABLE Beneficiario_Individuo(
	dui VARCHAR(15) PRIMARY KEY NOT NULL,
    nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	ocupacion VARCHAR(30) NOT NULL,
	id_genero INT NOT NULL, FOREIGN KEY (id_genero) REFERENCES Genero(id),
	id_beneficiario INT NOT NULL, FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id)
);

CREATE TABLE Donante (
    id INT NOT NULL
		CONSTRAINT DF_Donante_id DEFAULT(NEXT VALUE FOR dbo.seq_donante),
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion TEXT NOT NULL,
    id_tipo_donante INT NOT NULL, FOREIGN KEY (id_tipo_donante) REFERENCES Tipo_Donante(id),
	codigo_donante AS (
		CASE id_tipo_donante
			WHEN 1 THEN 'DEMP-'
			WHEN 2 THEN 'DIND-'
		END
		+ RIGHT(REPLICATE('0',4)+CAST(id AS
		VARCHAR(10)),4)) PERSISTED,
			CONSTRAINT PK_Donante PRIMARY KEY (id)
);

CREATE TABLE Donacion (
    id INT NOT NULL
		CONSTRAINT DF_Donacion_id DEFAULT(NEXT VALUE FOR dbo.seq_donacion),
    fecha_donacion DATE NOT NULL,
    id_tipo_donacion INT NOT NULL, FOREIGN KEY (id_tipo_donacion) REFERENCES Tipo_Donacion(id),
    id_proyecto INT NOT NULL, FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id),
    id_donante INT NOT NULL, FOREIGN KEY (id_donante) REFERENCES Donante(id),
	codigo_donacion AS(
		CASE id_tipo_donacion
			WHEN 1 THEN 'DB-'
			WHEN 2 THEN 'DM-'
		END
		+ RIGHT(REPLICATE('0',4)+CAST(id AS
		VARCHAR(10)),4)) PERSISTED,
			CONSTRAINT PK_Donacion PRIMARY KEY (id)
);

CREATE TABLE Recibo (
	id INT NOT NULL
		CONSTRAINT DF_Recibo_id DEFAULT(NEXT VALUE FOR dbo.seq_recibo),	
    fecha_emision DATE,
    direccion_url VARCHAR(200),
    id_donacion INT,FOREIGN KEY (id_donacion) REFERENCES Donacion(id),
	numero_recibo AS ('RB-'+ RIGHT(REPLICATE('0',5)+CAST(id AS
		VARCHAR(10)),5)) PERSISTED,
			CONSTRAINT PK_Recibo PRIMARY KEY (id)
);

CREATE TABLE Donacion_Monetaria (
    id INT PRIMARY KEY IDENTITY(1,1),
    monto DECIMAL(10,2) NOT NULL,
    id_metodo_pago INT NOT NULL, FOREIGN KEY (id_metodo_pago) REFERENCES Metodo_Pago(id),
    id_donacion INT NOT NULL, FOREIGN KEY (id_donacion) REFERENCES Donacion(id)
);

CREATE TABLE Donacion_Bienes (
    id INT PRIMARY KEY IDENTITY(1,1),
    descripcion TEXT NOT NULL,
    cantidad INT NOT NULL,
    valor_estimado DECIMAL(10,2) NOT NULL,
    id_bienes_categoria INT NOT NULL, FOREIGN KEY (id_bienes_categoria) REFERENCES Bienes_Categoria(id),
    id_donacion INT NOT NULL, FOREIGN KEY (id_donacion) REFERENCES Donacion(id)
);

CREATE TABLE Donante_Individuo (
    dui VARCHAR(15) PRIMARY KEY NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    ocupacion VARCHAR(30) NOT NULL,
    id_genero INT NOT NULL, FOREIGN KEY (id_genero) REFERENCES Genero(id),
    id_donante INT NOT NULL,FOREIGN KEY (id_donante) REFERENCES Donante(id)
);

CREATE TABLE Donante_Empresa (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(75) NOT NULL,
    codigo_registro VARCHAR(15) NOT NULL,
    director VARCHAR(125) NOT NULL,
    id_rubro INT NOT NULL, FOREIGN KEY (id_rubro) REFERENCES Rubro(id),
    id_donante INT NOT NULL, FOREIGN KEY (id_donante) REFERENCES Donante(id)
);

--ESQUEMAS ---

CREATE SCHEMA Catalogo;

ALTER SCHEMA Catalogo TRANSFER dbo.Rol;
ALTER SCHEMA Catalogo TRANSFER dbo.Personal_Estado;
ALTER SCHEMA Catalogo TRANSFER dbo.Proyecto_Categoria;
ALTER SCHEMA Catalogo TRANSFER dbo.Proyecto_Estado;
ALTER SCHEMA Catalogo TRANSFER dbo.Tipo_Beneficiario;
ALTER SCHEMA Catalogo TRANSFER dbo.Genero;
ALTER SCHEMA Catalogo TRANSFER dbo.Rubro;
ALTER SCHEMA Catalogo TRANSFER dbo.Tipo_Institucion;
ALTER SCHEMA Catalogo TRANSFER dbo.Tipo_Donante;
ALTER SCHEMA Catalogo TRANSFER dbo.Tipo_Donacion;
ALTER SCHEMA Catalogo TRANSFER dbo.Metodo_Pago;
ALTER SCHEMA Catalogo TRANSFER dbo.Bienes_Categoria;


CREATE SCHEMA Negocio;

ALTER SCHEMA Negocio TRANSFER dbo.Proyecto;
ALTER SCHEMA Negocio TRANSFER dbo.Personal;
ALTER SCHEMA Negocio TRANSFER dbo.Personal_Proyecto;
ALTER SCHEMA Negocio TRANSFER dbo.Beneficiario;
ALTER SCHEMA Negocio TRANSFER dbo.Proyecto_Beneficiario;
ALTER SCHEMA Negocio TRANSFER dbo.Beneficiario_Institucion;
ALTER SCHEMA Negocio TRANSFER dbo.Beneficiario_Individuo;
ALTER SCHEMA Negocio TRANSFER dbo.Donacion;
ALTER SCHEMA Negocio TRANSFER dbo.Donante;
ALTER SCHEMA Negocio TRANSFER dbo.Donante_Empresa;
ALTER SCHEMA Negocio TRANSFER dbo.Donante_Individuo;

CREATE SCHEMA Transacciones;
ALTER SCHEMA Transacciones TRANSFER dbo.Donacion_Monetaria;
ALTER SCHEMA Transacciones TRANSFER dbo.Donacion_Bienes;
ALTER SCHEMA Transacciones TRANSFER dbo.Recibo;

CREATE SCHEMA Analisis;

CREATE SCHEMA Administrativo;

--VISTAS--

--vista de detalle prooyecto
CREATE VIEW Analisis.v_Proyecto_Detalle AS
SELECT
    p.id,
    p.nombre,
    p.presupuesto_objetivo,
    p.presupuesto_recaudado,
    CAST(
        ROUND(
            (p.presupuesto_recaudado * 100.0 / NULLIF(p.presupuesto_objetivo, 0)),
            2
        ) AS DECIMAL(10,2)
    ) AS porcentaje_cumplimiento,
    CASE 
        WHEN p.presupuesto_recaudado >= p.presupuesto_objetivo THEN 'Cumplido'
        ELSE 'No Cumplido'
    END AS estado_financiero,
    pe.estado AS estado_proyecto,
    pc.categoria,
    DATEDIFF(DAY, p.fecha_inicio, p.fecha_fin) AS duracion_dias
FROM Negocio.Proyecto p
INNER JOIN Catalogo.Proyecto_Estado pe ON p.id_proyecto_estado = pe.id
INNER JOIN Catalogo.Proyecto_Categoria pc ON p.id_proyecto_categoria = pc.id;


--vista de estado proyecto

CREATE VIEW Analisis.v_Estado_proyecto AS
SELECT 
    pe.estado AS estado_proyecto,
    COUNT(*) AS total,
    CAST(
        (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM Negocio.Proyecto)
        AS DECIMAL(10,2)
    ) AS porcentaje
FROM Negocio.Proyecto p
INNER JOIN Catalogo.Proyecto_Estado pe
    ON p.id_proyecto_estado = pe.id
GROUP BY pe.estado;

--vista de proyecto por categoria

CREATE VIEW Analisis.v_Categoria_Proyecto AS
SELECT  
    pc.categoria,
    COUNT(p.id) AS cantidad
FROM Negocio.Proyecto p
INNER JOIN Catalogo.Proyecto_Categoria pc
    ON p.id_proyecto_categoria = pc.id
GROUP BY pc.categoria;

-- vista total por donante
CREATE VIEW Analisis.v_total_donante AS
SELECT
    d.id AS id_donante,
    COALESCE(di.nombre + ' ' + di.apellido, de.nombre) AS donante,
    SUM(COALESCE(dm.monto, 0)) + SUM(COALESCE(db.valor_estimado, 0)) AS total_donado
FROM Negocio.Donante d
LEFT JOIN Negocio.Donante_Individuo di ON d.id = di.id_donante
LEFT JOIN Negocio.Donante_Empresa de ON d.id = de.id
LEFT JOIN Negocio.Donacion don ON don.id_donante = d.id
LEFT JOIN Transacciones.Donacion_Monetaria dm ON don.id = dm.id_donacion
LEFT JOIN Transacciones.Donacion_Bienes db ON don.id = db.id_donacion
GROUP BY d.id, COALESCE(di.nombre + ' ' + di.apellido, de.nombre);

--vista participacion del personal en proyecto

CREATE VIEW Analisis.v_Participacion_Personal AS
SELECT
    per.id,
    per.nombre + ' ' + per.apellido AS personal,
    COUNT(pp.id_proyecto) AS cantidad_proyectos,
    CAST(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Negocio.Personal_Proyecto)
        AS DECIMAL(10,2)
    ) AS porcentaje_participacion
FROM Negocio.Personal per
INNER JOIN Negocio.Personal_Proyecto pp
    ON per.id = pp.id_personal
GROUP BY per.id, per.nombre, per.apellido;

--vista de druacion proyecto

CREATE VIEW Analisis.v_Duracion_Proyecto AS
SELECT
    p.id,
    p.nombre,
    pe.estado,
    DATEDIFF(DAY, p.fecha_inicio, p.fecha_fin) AS duracion_dias
FROM Negocio.Proyecto p
INNER JOIN Catalogo.Proyecto_Estado pe
    ON p.id_proyecto_estado = pe.id;

SELECT * FROM Analisis.v_Duracion_Proyecto;


--vista de ver auditoria

CREATE VIEW Administrativo.v_Auditoria_Movimiento AS
SELECT
    event_time,
    action_id,
    succeeded,
    server_principal_name,
    database_name,
    schema_name,
    object_name,
    statement,
    additional_information
FROM sys.fn_get_audit_file('C:\AuditLogs\ONG\*', DEFAULT, DEFAULT);

--vista ver fragmentacion indices

CREATE VIEW Administrativo.v_Fragmentacion_Indices AS
SELECT 
    o.name AS Tabla,
    i.name AS Indice,
    ips.index_id,
    i.is_primary_key AS EsClavePrimaria,
    i.is_unique AS EsUnico,
    ips.avg_fragmentation_in_percent AS Fragmentacion,
    ips.page_count AS Paginas,
    i.type_desc AS TipoIndice,
    CASE 
        WHEN ips.avg_fragmentation_in_percent < 5 THEN 'OK'
        WHEN ips.avg_fragmentation_in_percent BETWEEN 5 AND 30 THEN 'REORGANIZE'
        WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
    END AS Recomendacion
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'SAMPLED') AS ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
JOIN sys.objects o ON i.object_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE i.index_id > 0 AND o.type = 'U';

SELECT * FROM Administrativo.V_Fragmentacion_Indices

--Vista para ver permiso de roles
CREATE VIEW Administrativo.v_Permisos_Roles AS
SELECT 
    dp.name AS RoleName,
    dp.type_desc AS RoleType,
    perm.permission_name,
    perm.state_desc AS PermissionState,
    perm.class_desc AS TargetType,
    CASE 
        WHEN perm.class_desc = 'DATABASE' THEN DB_NAME()
        WHEN perm.class_desc = 'SCHEMA' THEN SCHEMA_NAME(perm.major_id)
        WHEN perm.class_desc = 'OBJECT_OR_COLUMN' THEN SCHEMA_NAME(obj.schema_id)
        ELSE NULL 
    END AS SchemaName,
    CASE 
        WHEN perm.class_desc = 'DATABASE' THEN 'Toda la Base de Datos'
        WHEN perm.class_desc = 'SCHEMA' THEN SCHEMA_NAME(perm.major_id) 
        WHEN perm.class_desc = 'OBJECT_OR_COLUMN' THEN obj.name
        ELSE NULL 
    END AS ObjectName,
    CASE 
        WHEN perm.class_desc = 'DATABASE' THEN 'DATABASE'
        WHEN perm.class_desc = 'SCHEMA' THEN 'SCHEMA'
        WHEN perm.class_desc = 'OBJECT_OR_COLUMN' THEN obj.type_desc
        ELSE perm.class_desc
    END AS ObjectType
FROM sys.database_principals dp
JOIN sys.database_permissions perm ON dp.principal_id = perm.grantee_principal_id
LEFT JOIN sys.objects obj ON perm.major_id = obj.object_id
WHERE dp.type = 'R' 
AND dp.name NOT IN ('public','db_accessadmin','db_backupoperator','db_datareader','db_datawriter',
'db_ddladmin','db_denydatareader','db_denydatawriter','db_owner','db_securityadmin')

SELECT * FROM Administrativo.v_Permisos_Roles;

--Vista de diccionario de datos

CREATE VIEW Administrativo.v_Diccionario_Datos AS
SELECT
    s.name AS Esquema,
    t.name AS Tabla,
    c.name AS Columna,
    ty.name AS TipoDato,
    c.max_length AS Longitud,
    c.is_nullable AS PermiteNulos,
    c.column_id AS Posicion
FROM 
    sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
	JOIN sys.types ty ON c.user_type_id = ty.user_type_id
	JOIN sys.schemas s ON t.schema_id = s.schema_id

SELECT * FROM Administrativo.v_Diccionario_Datos


--ROLES Y USUARIOS--

--creacion de roles/definir permisos
CREATE ROLE db_admin;
GRANT CONTROL TO db_admin;

CREATE ROLE db_coordinador_proyectos;
GRANT SELECT ON SCHEMA::Catalogo TO db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Catalogo.Tipo_Donante TO db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Catalogo.Tipo_Donacion TO db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Catalogo.Metodo_Pago TO db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Catalogo.Bienes_Categoria TO db_coordinador_proyectos;

GRANT SELECT, INSERT, UPDATE ON SCHEMA::Negocio TO db_coordinador_proyectos;
DENY INSERT, ALTER, UPDATE, DELETE ON Negocio.Personal to db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Negocio.Donacion TO db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Negocio.Donante TO db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Negocio.Donante_Empresa TO db_coordinador_proyectos;
DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON Negocio.Donante_Individuo TO db_coordinador_proyectos;

DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON SCHEMA::Transacciones TO db_coordinador_proyectos;

CREATE ROLE db_rrhh;
GRANT SELECT ON Catalogo.Rol TO db_rrhh;
GRANT SELECT ON Catalogo.Personal_Estado TO db_rrhh;
DENY INSERT, ALTER, UPDATE, DELETE ON SCHEMA::Catalogo TO db_rrhh;

GRANT SELECT, INSERT, UPDATE ON Negocio.Personal TO db_rrhh;
DENY ALTER, DELETE ON Negocio.Personal to db_rrhh;

DENY SELECT, INSERT, ALTER, UPDATE, DELETE ON SCHEMA::Transacciones TO db_rrhh;

CREATE ROLE db_gestor_finanzas;
GRANT SELECT ON Catalogo.Tipo_Donante TO db_gestor_finanzas;
GRANT SELECT ON Catalogo.Tipo_Donacion TO db_gestor_finanzas;
GRANT SELECT ON Catalogo.Metodo_Pago TO db_gestor_finanzas;
GRANT SELECT ON Catalogo.Rubro TO db_gestor_finanzas;
GRANT SELECT ON Catalogo.Genero TO db_gestor_finanzas;
DENY INSERT, ALTER, UPDATE, DELETE ON SCHEMA::Catalogo TO db_gestor_finanzas;

GRANT SELECT, INSERT, UPDATE ON Negocio.Donacion TO db_gestor_finanzas;
GRANT SELECT, INSERT, UPDATE ON Negocio.Donante TO db_gestor_finanzas;
GRANT SELECT, INSERT, UPDATE ON Negocio.Donante_Empresa TO db_gestor_finanzas;
GRANT SELECT, INSERT, UPDATE ON Negocio.Donante_Individuo TO db_gestor_finanzas;
DENY ALTER, DELETE ON SCHEMA::Negocio TO db_gestor_finanzas;

GRANT SELECT, INSERT, UPDATE ON Transacciones.Recibo TO db_gestor_finanzas;
GRANT SELECT, INSERT, UPDATE ON Transacciones.Donacion_Monetaria TO db_gestor_finanzas;
DENY SELECT, INSERT, UPDATE ON Transacciones.Donacion_Bienes TO db_gestor_finanzas;
DENY ALTER, DELETE ON SCHEMA::Transacciones TO db_gestor_finanzas;

CREATE ROLE db_gestor_inventario;

GRANT SELECT ON Catalogo.Tipo_Donante TO db_gestor_inventario;
GRANT SELECT ON Catalogo.Tipo_Donacion TO db_gestor_inventario;
GRANT SELECT ON Catalogo.Rubro TO db_gestor_inventario;
GRANT SELECT ON Catalogo.Bienes_Categoria TO db_gestor_inventario;
GRANT SELECT ON Catalogo.Genero TO db_gestor_inventario;
DENY SELECT ON Catalogo.Metodo_Pago TO db_gestor_inventario;
DENY INSERT, ALTER, UPDATE, DELETE ON SCHEMA::Catalogo TO db_gestor_inventario;

GRANT SELECT, INSERT, UPDATE ON Negocio.Donacion TO db_gestor_inventario;
GRANT SELECT, INSERT, UPDATE ON Negocio.Donante TO db_gestor_inventario;
GRANT SELECT, INSERT, UPDATE ON Negocio.Donante_Empresa TO db_gestor_inventario;
GRANT SELECT, INSERT, UPDATE ON Negocio.Donante_Individuo TO db_gestor_inventario;
DENY ALTER, DELETE ON SCHEMA::Negocio TO db_gestor_inventario;

GRANT SELECT, INSERT, UPDATE ON Transacciones.Recibo TO db_gestor_inventario;
GRANT SELECT, INSERT, UPDATE ON Transacciones.Donacion_Bienes TO db_gestor_inventario;
DENY SELECT, INSERT, UPDATE ON Transacciones.Donacion_Monetaria TO db_gestor_inventario;
DENY ALTER, DELETE ON SCHEMA::Transacciones TO db_gestor_inventario;


CREATE ROLE db_gestor_reportes;
GRANT SELECT ON SCHEMA::Analisis TO db_gestor_reportes;

CREATE ROLE db_docente;
GRANT SELECT TO db_docente;
DENY INSERT, UPDATE, ALTER, DELETE TO db_docente;

--creacion de usuarios/asignacion
CREATE USER usuario_dba
	WITH PASSWORD = '!Admin_96743$';
ALTER ROLE db_admin ADD MEMBER usuario_dba;

CREATE USER coordinador_proyectos
	WITH PASSWORD = '-CoorProy_#';
ALTER ROLE db_coordinador_proyectos ADD MEMBER coordinador_proyectos;

CREATE USER gestor_finanzas
	WITH PASSWORD = 'FNNZS25_!';
ALTER ROLE db_gestor_finanzas ADD MEMBER gestor_finanzas;

CREATE USER gestor_inventario
	WITH PASSWORD = 'NVTR$5202';
ALTER ROLE db_gestor_inventario ADD MEMBER gestor_inventario;

CREATE USER gestor_reportes
	WITH PASSWORD = '/gestor_rep08';
ALTER ROLE db_gestor_reportes ADD MEMBER gestor_reportes;

CREATE USER lector_maestro
	WITH PASSWORD = 'lecT-202502';
ALTER ROLE db_docente ADD MEMBER lector_maestro;


--AUDITORIA---

--archivo de auditoria
USE master;

CREATE SERVER AUDIT AuditoriaLogs_ONG
TO FILE (FILEPATH = 'C:\AuditoriaLogs\ONG', MAXSIZE = 50 MB, MAX_FILES = 20)
WITH(ON_FAILURE = CONTINUE);

ALTER SERVER AUDIT AuditoriaLogs_ONG WITH (STATE = ON);

--especificacion de auditoria
USE DonacionesDB;

CREATE DATABASE AUDIT SPECIFICATION AuditoriaDonacionesDB
FOR SERVER AUDIT AuditoriaLogs_ONG
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_OBJECT_CHANGE_GROUP),

ADD (SELECT, INSERT, UPDATE ON Transacciones.Recibo BY db_gestor_finanzas),
ADD (SELECT, INSERT, UPDATE ON Transacciones.Donacion_Monetaria BY db_gestor_finanzas),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donacion BY db_gestor_finanzas),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donante BY db_gestor_finanzas),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donante_Empresa BY db_gestor_finanzas),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donante_Individuo BY db_gestor_finanzas),

ADD (SELECT, INSERT, UPDATE ON Transacciones.Recibo BY db_gestor_inventario),
ADD (SELECT, INSERT, UPDATE ON Transacciones.Donacion_Bienes BY db_gestor_inventario),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donacion BY db_gestor_inventario),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donante BY db_gestor_inventario),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donante_Empresa BY db_gestor_inventario),
ADD (SELECT, INSERT, UPDATE ON Negocio.Donante_Individuo BY db_gestor_inventario),

ADD (INSERT, UPDATE ON Negocio.Proyecto BY db_coordinador_proyectos),
ADD (INSERT, UPDATE ON Negocio.Beneficiario BY db_coordinador_proyectos),
ADD (SELECT, INSERT, UPDATE ON Negocio.Beneficiario_Individuo BY db_coordinador_proyectos),
ADD (SELECT, INSERT, UPDATE ON Negocio.Beneficiario_Institucion BY db_coordinador_proyectos),

ADD (SELECT, INSERT, UPDATE ON Negocio.Personal BY db_rrhh),

ADD (SELECT ON SCHEMA::Negocio BY db_admin),
ADD (SELECT ON SCHEMA::Transacciones BY db_admin),
ADD (DELETE ON SCHEMA::Negocio BY db_admin),
ADD (DELETE ON SCHEMA::Transacciones BY db_admin);

ALTER DATABASE AUDIT SPECIFICATION AuditoriaDonacionesDB
WITH (STATE=ON);

--CONSULTAS---

--CONSULTAS CON FUNCIONES VENTANA


--ranking de mayores donadores

WITH Donaciones AS (
    SELECT 
        d.id AS id_donante,
        COALESCE(di.nombre + ' ' + di.apellido, de.nombre) AS donante,
        COALESCE(dm.monto, 0) AS monto_monetario,
        COALESCE(db.valor_estimado, 0) AS monto_bienes
    FROM Negocio.Donante d
    LEFT JOIN Negocio.Donante_Individuo di ON d.id = di.id_donante
    LEFT JOIN Negocio.Donante_Empresa de ON d.id = de.id
    LEFT JOIN Negocio.Donacion don ON don.id_donante = d.id
    LEFT JOIN Transacciones.Donacion_Monetaria dm ON don.id = dm.id_donacion
    LEFT JOIN Transacciones.Donacion_Bienes db ON don.id = db.id_donacion
),
Totales AS (
    SELECT 
        id_donante,
        donante,
        SUM(monto_monetario + monto_bienes) AS total_donado
    FROM Donaciones
    GROUP BY id_donante, donante
)
SELECT 
    id_donante,
    donante,
    total_donado,
    RANK() OVER (ORDER BY total_donado DESC) AS ranking
FROM Totales
ORDER BY ranking;


--Porcentaje de proyectos según estado 

SELECT DISTINCT
    pe.estado AS estado_proyecto,
    COUNT(*) OVER (PARTITION BY pe.estado) AS total_por_estado,

    CAST(
        COUNT(*) OVER (PARTITION BY pe.estado) * 100.0 /
        COUNT(*) OVER () 
        AS DECIMAL(10,2)
    ) AS porcentaje
FROM Negocio.Proyecto p
INNER JOIN Catalogo.Proyecto_Estado pe
    ON p.id_proyecto_estado = pe.id;


--Personal con más participación en proyectos 

SELECT 
    per.nombre + ' ' + per.apellido AS lider,
    COUNT(pp.id_proyecto) AS cantidad_proyectos,

    ROW_NUMBER() OVER (
        ORDER BY COUNT(pp.id_proyecto) DESC
    ) AS ranking
FROM Negocio.Personal per
INNER JOIN Negocio.Personal_Proyecto pp
    ON per.id = pp.id_personal
GROUP BY per.nombre, per.apellido;

--Demas consultas avanzadas

--Calcular Total Donado
SELECT 
    (SELECT SUM(monto) 
     FROM Transacciones.Donacion_Monetaria) 
  + (SELECT SUM(valor_estimado) 
     FROM Transacciones.Donacion_Bienes) AS total_donado;

--Caclular total en donacion_monetaria

SELECT 
	( SELECT SUM(monto) 
	from Transacciones.Donacion_Monetaria) 
AS Total 


--Calcular cantidad de beneficiarios
SELECT 
    (
        SELECT ISNULL(SUM(bi.alcance), 0)
        FROM Negocio.Proyecto p
        INNER JOIN Catalogo.Proyecto_Estado pe ON p.id_proyecto_estado = pe.id
        INNER JOIN Negocio.Proyecto_Beneficiario pb ON p.id = pb.id_proyecto
        INNER JOIN Negocio.Beneficiario_Institucion bi ON pb.id_beneficiario = bi.id_beneficiario
        WHERE pe.estado NOT IN ('Propuesto', 'Cancelado','Suspendido')
    ) 
    + 
    (
        SELECT COUNT(bind.dui)
        FROM Negocio.Proyecto p
        INNER JOIN Catalogo.Proyecto_Estado pe ON p.id_proyecto_estado = pe.id
        INNER JOIN Negocio.Proyecto_Beneficiario pb ON p.id = pb.id_proyecto
        INNER JOIN Negocio.Beneficiario_Individuo bind ON pb.id_beneficiario = bind.id_beneficiario
        WHERE pe.estado NOT IN ('Propuesto', 'Cancelado', 'Suspendido')
    ) 
AS Total_Beneficiados_Global;

--estado y duracion de los proyectos
SELECT
    p.id,
    p.nombre AS proyecto,
    pe.estado AS estado_proyecto,
    CASE 
        WHEN p.fecha_inicio IS NOT NULL AND p.fecha_fin IS NOT NULL
             THEN DATEDIFF(DAY, p.fecha_inicio, p.fecha_fin)
        ELSE NULL
    END AS duracion_dias
FROM Negocio.Proyecto p
LEFT JOIN Catalogo.Proyecto_Estado pe
    ON p.id_proyecto_estado = pe.id
ORDER BY duracion_dias DESC;

--proyectos dentro o fuera del presupuesto
SELECT
    p.id,
    p.nombre,
    p.presupuesto_objetivo,
    p.presupuesto_recaudado,
	 CAST(
    ROUND(
        (p.presupuesto_recaudado * 100.0 / NULLIF(p.presupuesto_objetivo, 0)),
        2
    ) AS DECIMAL(10,2)
	) AS porcentaje_cumplimiento,
    CASE 
        WHEN p.presupuesto_recaudado >= p.presupuesto_objetivo THEN 'Cumplido'
        ELSE 'No Cumplido'
    END AS estado_financiero
FROM Negocio.Proyecto p
ORDER BY porcentaje_cumplimiento DESC;

--Categorías con más proyectos
SELECT  
    pc.categoria,
    COUNT(p.id) AS cantidad
FROM Negocio.Proyecto p
INNER JOIN Catalogo.Proyecto_Categoria pc
    ON p.id_proyecto_categoria = pc.id
GROUP BY pc.categoria
ORDER BY cantidad DESC;

--Proyectos por año
SELECT 
    YEAR(fecha_inicio) AS anio,
    COUNT(*) AS cantidad
FROM Negocio.Proyecto
GROUP BY YEAR(fecha_inicio)
ORDER BY anio;

--Proyecto por estado

SELECT 
    pe.estado,
    COUNT(*) AS cantidad
FROM Negocio.Proyecto p
JOIN Catalogo.Proyecto_Estado pe ON p.id_proyecto_estado = pe.id
GROUP BY pe.estado;

--Lideres proyectos ranking

SELECT 
    (per.nombre + ' ' + per.apellido) AS lider,
    COUNT(*) AS proyectos_dirigidos
FROM Negocio.Proyecto p
JOIN Negocio.Personal per ON per.id = p.lider_proyecto
GROUP BY per.nombre, per.apellido
ORDER BY proyectos_dirigidos DESC;


-- Proyectos Activos Actualmente
SELECT 
    nombre,
    fecha_inicio,
    fecha_fin
FROM Negocio.Proyecto
WHERE GETDATE() BETWEEN fecha_inicio AND fecha_fin;

--INDICES ---
--	Crear indices
CREATE INDEX IX_Proyecto_lider_proyecto ON Negocio.Proyecto(lider_proyecto);
CREATE INDEX IX_Donacion_id_proyecto ON Negocio.Donacion(id_proyecto);
CREATE INDEX IX_Donacion_id_donante ON Negocio.Donacion(id_donante);
CREATE INDEX IX_Personal_nombrexapellido ON Negocio.Personal(nombre,apellido);
CREATE INDEX IX_Proyecto_nombre ON Negocio.Proyecto(nombre);
CREATE INDEX IX_Recibo_numero_recibo ON Transacciones.Recibo(numero_recibo);
CREATE INDEX IX_Beneficiario_Institucion_nombre ON Negocio.Beneficiario_Institucion(nombre);
CREATE INDEX IX_Donante_Empresa_nombre ON Negocio.Donante_Empresa(nombre);
CREATE INDEX IX_Beneficiario_Individuo_nombrexapellido ON Negocio.Beneficiario_Individuo(nombre,apellido);
CREATE INDEX IX_Donante_Individuo_nombrexapellido ON Negocio.Donante_Individuo(nombre,apellido);

--Indicies unique
CREATE UNIQUE INDEX IX_Rol_rol ON Catalogo.Rol (rol);
CREATE UNIQUE INDEX IX_Personal_Estado_estado ON Catalogo.Personal_Estado (estado);
CREATE UNIQUE INDEX IX_Proyecto_Categoria_categoria ON Catalogo.Proyecto_Categoria (categoria);
CREATE UNIQUE INDEX IX_Proyecto_Estado_estado ON Catalogo.Proyecto_Estado (estado);
CREATE UNIQUE INDEX IX_Tipo_Beneficiario_tipo ON Catalogo.Tipo_Beneficiario (tipo_beneficiario);
CREATE UNIQUE INDEX IX_Genero_genero ON Catalogo.Genero (genero);
CREATE UNIQUE INDEX IX_Rubro_rubro ON Catalogo.Rubro (rubro);
CREATE UNIQUE INDEX IX_Tipo_Institucion_tipo ON Catalogo.Tipo_Institucion (tipo_institucion);
CREATE UNIQUE INDEX IX_Tipo_Donante_tipo ON Catalogo.Tipo_Donante (tipo_donante);
CREATE UNIQUE INDEX IX_Tipo_Donacion_tipo ON Catalogo.Tipo_Donacion (tipo_donacion);
CREATE UNIQUE INDEX IX_Metodo_Pago_metodo ON Catalogo.Metodo_Pago (metodo_pago);
CREATE UNIQUE INDEX IX_Bienes_Categoria_categoria ON catalogo.Bienes_Categoria (categoria);

CREATE UNIQUE INDEX IX_Proyecto_codigo ON Negocio.Proyecto (codigo_proyecto);
CREATE UNIQUE INDEX IX_Personal_codigo ON Negocio.Personal (codigo_personal);
CREATE UNIQUE INDEX IX_Beneficiario_codigo ON Negocio.Beneficiario (codigo_beneficiario);
CREATE UNIQUE INDEX IX_Donante_codigo ON Negocio.Donante (codigo_donante);
CREATE UNIQUE INDEX IX_Donacion_codigo ON Negocio.Donacion (codigo_donacion);
CREATE UNIQUE INDEX IX_Recibo_numero ON Transacciones.Recibo (numero_recibo);

CREATE UNIQUE INDEX IX_Personal_dui ON Negocio.Personal (dui);
CREATE UNIQUE INDEX IX_Beneficiario_Institucion_codigo ON Negocio.Beneficiario_Institucion (codigo_registro);
CREATE UNIQUE INDEX IX_Donante_Empresa_codigo ON Negocio.Donante_Empresa (codigo_registro);
CREATE UNIQUE INDEX IX_Beneficiario_Institucion_codigo ON Negocio.Beneficiario_Institucion (codigo_registro);
CREATE UNIQUE INDEX IX_Donante_Empresa_codigo ON Negocio.Donante_Empresa (codigo_registro);

CREATE UNIQUE INDEX IX_Personal_Proyecto ON Negocio.Personal_Proyecto (id_personal, id_proyecto);
CREATE UNIQUE INDEX IX_Proyecto_Beneficiario ON Negocio.Proyecto_Beneficiario (id_proyecto, id_beneficiario);

CREATE UNIQUE INDEX IX_Beneficiario_Individuo_ID ON Negocio.Beneficiario_Individuo (id_beneficiario);
CREATE UNIQUE INDEX IX_Beneficiario_Institucion_ID ON Negocio.Beneficiario_Institucion (id_beneficiario);
CREATE UNIQUE INDEX IX_Donante_Individuo_ID ON Negocio.Donante_Individuo (id_donante);
CREATE UNIQUE INDEX IX_Donante_Empresa_ID ON Negocio.Donante_Empresa (id_donante);

--CREACION DE JOBS-


--job para respaldo completo
USE msdb;

EXEC msdb.dbo.sp_add_job
	@job_name =N'Job_Full_Backup_DonacionesDB',
	@enabled = 1,
	@description = N'Respaldo completo semanal';

EXEC msdb.dbo.sp_add_jobstep
	@job_name = N'Job_Full_Backup_DonacionesDB',
	@step_name = N'Backup_Full_Step',
	@subsystem = N'TSQL',
	@command = N'BACKUP DATABASE DonacionesDB
    TO DISK = ''C:\Backup\DonacionesDB_FULL_$(ESCAPE_SQUOTE(DATE)).bak''
    WITH INIT, STATS = 10, COMPRESSION;',
	@database_name = N'DonacionesDB';

EXEC msdb.dbo.sp_add_schedule
	@schedule_name = N'Schedule_Semanal_Dom_03h_FULL',
    @freq_type = 8, 
    @freq_interval = 1,
    @freq_recurrence_factor = 1, 
    @active_start_time = 030000;

EXEC msdb.dbo.sp_attach_schedule
    @job_name=N'Job_Full_Backup_DonacionesDB',
    @schedule_name=N'Schedule_Semanal_Dom_03h_FULL';

--job para registro de transacciones
USE msdb;

EXEC msdb.dbo.sp_add_job
    @job_name=N'Job_Log_Backup_DonacionesDB',
    @enabled=1, 
    @description=N'Respaldo de Registro de Transacciones.';

EXEC msdb.dbo.sp_add_jobstep
    @job_name=N'Job_Log_Backup_DonacionesDB',
    @step_name=N'Backup_Log_Step',
    @subsystem=N'TSQL',
    @command=N'BACKUP LOG DonacionesDB
    TO DISK = ''C:\Backup\DonacionesDB_LOG_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).trn''
    WITH NOINIT, STATS = 10, COMPRESSION;', 
    @database_name=N'DonacionesDB';

EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Schedule_4_Horas_LOG',
    @freq_type = 4,
    @freq_interval = 1, 
    @freq_subday_type = 8,
    @freq_subday_interval = 4,
    @active_start_time = 080000;

EXEC msdb.dbo.sp_attach_schedule
    @job_name=N'Job_Log_Backup_DonacionesDB',
    @schedule_name=N'Schedule_4_Horas_LOG';
