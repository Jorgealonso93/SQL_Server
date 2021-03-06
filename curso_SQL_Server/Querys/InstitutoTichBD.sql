USE [master]
GO
/****** Object:  Database [instituto_tich]    Script Date: 16/01/2022 12:34:45 a. m. ******/
CREATE DATABASE [instituto_tich]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'instituto_tich', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\instituto_tich.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'instituto_tich_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\instituto_tich_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [instituto_tich] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [instituto_tich].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [instituto_tich] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [instituto_tich] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [instituto_tich] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [instituto_tich] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [instituto_tich] SET ARITHABORT OFF 
GO
ALTER DATABASE [instituto_tich] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [instituto_tich] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [instituto_tich] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [instituto_tich] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [instituto_tich] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [instituto_tich] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [instituto_tich] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [instituto_tich] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [instituto_tich] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [instituto_tich] SET  ENABLE_BROKER 
GO
ALTER DATABASE [instituto_tich] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [instituto_tich] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [instituto_tich] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [instituto_tich] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [instituto_tich] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [instituto_tich] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [instituto_tich] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [instituto_tich] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [instituto_tich] SET  MULTI_USER 
GO
ALTER DATABASE [instituto_tich] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [instituto_tich] SET DB_CHAINING OFF 
GO
ALTER DATABASE [instituto_tich] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [instituto_tich] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [instituto_tich] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [instituto_tich] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [instituto_tich] SET QUERY_STORE = OFF
GO
USE [instituto_tich]
GO
/****** Object:  UserDefinedFunction [dbo].[AmortizacionAlum]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[AmortizacionAlum](@idAlumno INT)
RETURNS @ResultTable TABLE 
(Quincena INT, 
 SaldoAnterior DECIMAL(9,2),
 Pago DECIMAL(9,2),
 SaldoNuevo DECIMAL(9,2)
 )AS

BEGIN
	DECLARE @Quincena INT,
			@SaldoAnterior DECIMAL(9,2),
			@SaldoNuevo DECIMAL(9,2),
			@SaldoAlumno DECIMAL(9,2),
			@Pago DECIMAL(9,2);

	SET @Quincena = 1;
	SET @SaldoAnterior = (SELECT (a.sueldo * 2.5)
						  FROM alumnos a
						  WHERE a.id_alumno =@idAlumno);
	SET @SaldoNuevo = (SELECT @SaldoAnterior - dbo.ReembolsoQuincenal(a.sueldo)
					   FROM alumnos a
					   WHERE a.id_alumno =@idAlumno);
	SET @Pago = (SELECT dbo.ReembolsoQuincenal(a.sueldo)
				 FROM alumnos a
				 WHERE a.id_alumno =@idAlumno);

	WHILE @Quincena <= 12
	BEGIN
		INSERT  @ResultTable
			SELECT @Quincena,
				   @SaldoAnterior,
				   @Pago,
				   @SaldoNuevo;
			  
		SET @Quincena = @Quincena +1 ;
		SET @SaldoAnterior = @SaldoNuevo;
		SET @SaldoNuevo = @SaldoAnterior - @Pago;
	END;--WHILE;
	RETURN
END;
GO
/****** Object:  UserDefinedFunction [dbo].[AmortizacionInst]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[AmortizacionInst]
(@idInstructor INT)
RETURNS @amInstructores TABLE 
(Quincena INT, 
 SaldoAnterior DECIMAL(9,2),
 Pago DECIMAL(9,2),
 SaldoNuevo DECIMAL(9,2)
 )AS

 BEGIN
	DECLARE @Meses INT,
			@SaldoAnterior DECIMAL(9,2),
			@SaldoNuevo DECIMAL(9,2),
			@Pago DECIMAL(9,2),
			@Cuota DECIMAL(9,2);

			SET @Meses = 1;
			SET @Cuota =(SELECT i.cuotaHora
						 FROM instructores i
						 WHERE i.id_instructor = @idInstructor);
			SET @SaldoAnterior = (SELECT (i.cuotaHora * 200)
								  FROM instructores i
								  WHERE i.id_instructor =@idInstructor);
			SET @Pago = (SELECT (i.cuotaHora * 25)
								  FROM instructores i
								  WHERE i.id_instructor =@idInstructor);
			IF @Cuota > 200
				SET @SaldoAnterior = @SaldoAnterior + (@SaldoAnterior *0.24);
			ELSE 
				SET @SaldoAnterior = @SaldoAnterior + (@SaldoAnterior *0.18);
			SET @SaldoNuevo = @SaldoAnterior - @Pago;

			WHILE @Meses <=12
			BEGIN
				INSERT @amInstructores
					SELECT @Meses,
						   @SaldoAnterior,
						   @Pago,
						   @SaldoNuevo;

					SET @Meses = @Meses +1;
					SET @SaldoAnterior = @SaldoNuevo;
					SET @SaldoNuevo = @SaldoAnterior - @Pago;
			END--WHILE
		RETURN
 END;
GO
/****** Object:  UserDefinedFunction [dbo].[Calculadora]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Calculadora] 
(@Num1 INT,
 @Num2 INT,
 @Operador CHAR(1))
RETURNS INT AS
BEGIN
	DECLARE @Resultado INT;

	IF @Operador = '+'
		SET @Resultado = @Num1 + @Num2;
	ELSE IF @Operador = '-'
		SET @Resultado = @Num1 - @Num2;
	ELSE IF @Operador = '*'
		SET @Resultado = @Num1 * @Num2;
	ELSE IF @Operador = '/'
		IF @Num2 <>0
			SET @Resultado = @Num1 / @Num2;
	ELSE IF @Operador = '%'
		SET @Resultado = @Num1 % @Num2;

		RETURN @Resultado;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[Factorial]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Factorial]
(@Num INT)
RETURNS INT AS

BEGIN
	DECLARE @Factor INT,
			@i INT;
	
  IF @Num <= 1
    SET @Factor = 1;
  ELSE
    SELECT @Factor = @Num * (dbo.Factorial(@Num - 1));
  RETURN @Factor;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetEdad]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetEdad]
(@fechaNac DATE,
 @fechaCalc DATE)
 RETURNS INT AS

 BEGIN
	DECLARE @Edad INT,
			@EdadDia INT,
			@EdadMes INT,
			@Anio INT;

	SET @Edad = DATEDIFF(YEAR, @fechaNac, @fechaCalc);
	SET @EdadDia = DATEDIFF(DAY, @fechaNac, @fechaCalc)
	SET @EdadMes = ABS( (DATEPART(MONTH,@fechaNac)) - (DATEPART(MONTH, @fechaCalc)));

	IF @EdadDia =0
		IF @EdadMes < 12
			SET @Anio= @Edad - 1;
		ELSE IF @EdadMes=0
		SET @Anio= @Edad;
	ELSE IF @EdadDia < 365
		--SET @Anio = @Edad - 1;
		IF @EdadMes < 12
			SET @Anio= @Edad - 1;
		ELSE IF @EdadMes=0
			SET @Anio = @Edad;
	RETURN @Edad;
 END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetFechaNacimiento]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetFechaNacimiento] (@curp CHAR(18))
RETURNS DATE AS

BEGIN
	DECLARE @getFechaNacimiento VARCHAR(6),
			@fechaNacimiento DATE;
	SET @getFechaNacimiento = SUBSTRING(@curp, 5, 10);
	SET @fechaNacimiento = CONVERT(DATE, @getFechaNacimiento);

	RETURN @fechaNacimiento;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetGenero]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetGenero]
(@curp VARCHAR(20))
RETURNS VARCHAR(20) AS

BEGIN
	DECLARE @gen CHAR(1),
			@genero VARCHAR(20);
	SET @gen = SUBSTRING(@curp, 11,1);

	IF @gen = 'M'
		SET @genero = 'Femenino';
	ELSE
		SET @genero = 'Masculino';
	RETURN @genero;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetHonorarios]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetHonorarios]
(@id_istructor INT,
 @id_curso INT)
 RETURNS DECIMAL(9,2) AS

 BEGIN
	DECLARE @honorario DECIMAL(9,2);

	RETURN
	(SELECT (i.cuotaHora * cat.horas)
	FROM instructores i,
		cursoInstructores ci,
		cursos c,
		cat_cursos cat
	WHERE 1 = 1
	AND i.id_instructor = ci.id_instructor
	AND ci.id_curso = c.id_curso
	AND c.id_catCurso = cat.id_catCurso
	AND i.id_instructor = @id_istructor
	AND ci.id_curso = @id_curso);
	
 END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetidEstado]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetidEstado] (@curp CHAR(18))
RETURNS INT AS

BEGIN
	DECLARE @estado CHAR(2),
			@idEstado INT;
	SET @estado = SUBSTRING(@curp,12,2);

	RETURN 
	 CASE 
		WHEN @estado='AS'	THEN  1
		WHEN @estado='BC'	THEN  2
		WHEN @estado='BS'	THEN  3
		WHEN @estado='CC'	THEN  4
		WHEN @estado='CH'	THEN  5
		WHEN @estado='CS'	THEN  6
		WHEN @estado='CL'	THEN  7
		WHEN @estado='CM'	THEN  8
		WHEN @estado='DG'	THEN  9
		WHEN @estado='GT'	THEN  10
		WHEN @estado='GR'	THEN  11
		WHEN @estado='HG'	THEN  12
		WHEN @estado='JC'	THEN  13
		WHEN @estado='MC'	THEN  14
		WHEN @estado='MN'	THEN  15
		WHEN @estado='MS'	THEN 16
		WHEN @estado='NT'	THEN 17
		WHEN @estado='NL'	THEN 18
		WHEN @estado='OC'	THEN 19
		WHEN @estado='PL'	THEN 20
		WHEN @estado='QT'	THEN 21
		WHEN @estado='QR'	THEN 22
		WHEN @estado='SP'	THEN 23
		WHEN @estado='SL'	THEN 24
		WHEN @estado='SR'	THEN 25
		WHEN @estado='TC'	THEN 26
		WHEN @estado='TS'	THEN 27
		WHEN @estado='TL'	THEN 28
		WHEN @estado='VZ'	THEN 29
		WHEN @estado='YN'	THEN 30
		ELSE 31
	END
END;
GO
/****** Object:  UserDefinedFunction [dbo].[ImpuestoIstructor]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ImpuestoIstructor]
(@id_istructor INT,
 @id_curso INT)
 RETURNS DECIMAL(9,2) AS

 BEGIN
	DECLARE @estado INT, @impuesto DECIMAL(9,2);
	SET @estado = (SELECT dbo.GetidEstado(i.curp)
				 FROM instructores i
				 WHERE i.id_instructor = @id_istructor);
	IF @estado = 6
		SET @impuesto = ((SELECT dbo.GetHonorarios(@id_istructor, @id_curso)) * 0.05);
	ELSE IF @estado = 25
		SET @impuesto = ((SELECT dbo.GetHonorarios(@id_istructor, @id_curso)) * 0.1);
	ELSE IF @estado = 29
		SET @impuesto = ((SELECT dbo.GetHonorarios(@id_istructor, @id_curso)) * 0.07);
	ELSE 
		SET @impuesto = ((SELECT dbo.GetHonorarios(@id_istructor, @id_curso)) * 0.08);
	
	RETURN @impuesto;
 END;
GO
/****** Object:  UserDefinedFunction [dbo].[Initcap]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Initcap]
(@string VARCHAR(255))
RETURNS VARCHAR(255) AS

BEGIN
	RETURN UPPER(LEFT(@string,1)) + SUBSTRING(@string, 2, LEN(@string));
END;
GO
/****** Object:  UserDefinedFunction [dbo].[ReembolsoQuincenal]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ReembolsoQuincenal]
(@sueldoM DECIMAL(9,2))
RETURNS DECIMAL(9,2) AS

BEGIN
	DECLARE @reembolsoQ DECIMAL(9,2),
			@TotalReembolso DECIMAL(9,2);
	SET @TotalReembolso = (@sueldoM * 2.5);
	SET @reembolsoQ = @TotalReembolso / 12;
	
	RETURN @reembolsoQ;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[ReembolsoTich]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ReembolsoTich]
(@sueldoM	DECIMAL(9,2),
	@NumMeses INT)
RETURNS INT AS

BEGIN
	DECLARE	@Porcentaje INT;

	RETURN 
		CASE
			WHEN @NumMeses = 1 THEN (@sueldoM / 1000) /1
			WHEN @NumMeses = 2 THEN (@sueldoM / 1000) /1.5
			WHEN @NumMeses = 3 THEN ((@sueldoM / 1000)) / 2
			WHEN @NumMeses = 4 THEN (@sueldoM / 1000) /2.5
			WHEN @NumMeses = 5 THEN (@sueldoM / 1000) /3
			WHEN @NumMeses = 6 THEN (@sueldoM / 1000) * 0
		END;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[Suma]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Suma] ( @Num1 INT,
					   @Num2 INT)
RETURNS INT AS

BEGIN
	DECLARE @SUMA INT;
	SET @SUMA = @Num1 + @Num2;
	RETURN @SUMA
END;
GO
/****** Object:  Table [dbo].[estados]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[estados](
	[id_estado] [int] IDENTITY(1,1) NOT NULL,
	[nombre_estado] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_estado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[estatus_alumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[estatus_alumnos](
	[id_estatus] [smallint] IDENTITY(1,1) NOT NULL,
	[clave] [char](10) NOT NULL,
	[nombre] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_estatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[alumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[alumnos](
	[id_alumno] [int] IDENTITY(1,1) NOT NULL,
	[nombre_alumno] [varchar](60) NOT NULL,
	[primerApellido] [varchar](50) NOT NULL,
	[segundoApellido] [varchar](50) NULL,
	[correo] [varchar](80) NOT NULL,
	[telefono] [nchar](10) NOT NULL,
	[fechaNacimiento] [date] NOT NULL,
	[curp] [char](18) NOT NULL,
	[sueldo] [decimal](9, 2) NOT NULL,
	[id_estado] [int] NOT NULL,
	[id_estatus] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_alumno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vAlumnos]
AS
	SELECT a.id_alumno nombre,
		   a.primerApellido primerApellido,
		   a.segundoApellido segundoApellido,
		   a.correo correo,
		   a.telefono telefono,
		   a.curp curp,
		   e.nombre_estado Estado,
		   ea.nombre Estatus
	FROM alumnos a,
		 estados e,
		 estatus_alumnos ea
	WHERE 1 = 1
	AND a.id_estado = e.id_estado
	AND a.id_estatus = ea.id_estatus
GO
/****** Object:  Table [dbo].[alumnosBaja]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[alumnosBaja](
	[idAlumnos_Baja] [int] IDENTITY(1,1) NOT NULL,
	[nombreAlumno] [varchar](60) NOT NULL,
	[primerApellido] [varchar](50) NOT NULL,
	[segundoApellido] [varchar](50) NULL,
	[fechaBaja] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idAlumnos_Baja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_cursos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_cursos](
	[id_catCurso] [smallint] IDENTITY(1,1) NOT NULL,
	[clave_catCurso] [varchar](15) NOT NULL,
	[nombre_catCurso] [varchar](50) NOT NULL,
	[desc_catCurso] [varchar](1000) NULL,
	[horas] [tinyint] NOT NULL,
	[idPrerequisito] [smallint] NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_catCurso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cursoAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cursoAlumnos](
	[idCurso_alumno] [int] IDENTITY(1,1) NOT NULL,
	[id_curso] [smallint] NOT NULL,
	[id_alumno] [int] NOT NULL,
	[fechaInscripcion] [date] NOT NULL,
	[fechaBaja] [date] NULL,
	[calificacion] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[idCurso_alumno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cursoInstructores]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cursoInstructores](
	[idCurso_instructor] [int] IDENTITY(1,1) NOT NULL,
	[id_curso] [smallint] NOT NULL,
	[id_instructor] [smallint] NOT NULL,
	[fechaContratacion] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[idCurso_instructor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cursos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cursos](
	[id_curso] [smallint] IDENTITY(1,1) NOT NULL,
	[id_catCurso] [smallint] NULL,
	[fechaInicio] [date] NULL,
	[fechaTermino] [date] NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_curso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[instructores]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[instructores](
	[id_instructor] [smallint] IDENTITY(1,1) NOT NULL,
	[nombre_instructor] [varchar](60) NOT NULL,
	[primerApellido] [varchar](50) NOT NULL,
	[segundoApellido] [varchar](50) NULL,
	[correo] [varchar](80) NOT NULL,
	[telefono] [nchar](10) NOT NULL,
	[fechaNacimiento] [date] NOT NULL,
	[rfc] [char](13) NOT NULL,
	[curp] [char](18) NOT NULL,
	[cuotaHora] [decimal](9, 2) NOT NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_instructor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[saldos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[saldos](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NULL,
	[saldo] [decimal](9, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TablaISR]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TablaISR](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[LimInf] [decimal](19, 2) NOT NULL,
	[LimSup] [decimal](19, 2) NOT NULL,
	[CuotaFija] [decimal](19, 2) NOT NULL,
	[ExedLimInf] [decimal](19, 2) NOT NULL,
	[Subsidio] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Transacciones]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transacciones](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idOrigen] [int] NOT NULL,
	[idDestino] [int] NOT NULL,
	[monto] [decimal](9, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[alumnos] ON 

INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (2, N'GIOVANNI', N'PEREZ', NULL, N'giovanni@4ce.com.mx', N'5545367801', CAST(N'1995-02-20' AS Date), N'ABCD950220HOCLMR01', CAST(0.00 AS Decimal(9, 2)), 14, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (3, N'IVAN', N'HERNANDEZ', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1995-08-10' AS Date), N'ABCD950810HOCLMR01', CAST(0.00 AS Decimal(9, 2)), 10, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (4, N'JUAN GERARDO', N'SUAREZ', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1992-05-15' AS Date), N'ABCD920515HOCLMR01', CAST(0.00 AS Decimal(9, 2)), 19, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (5, N'WILLIAM', N'LOPEZ', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1992-03-21' AS Date), N'ABCD920321HOCLMR01', CAST(0.00 AS Decimal(9, 2)), 19, 1)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (6, N'JABNEL', N'MENDOZA', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1996-02-22' AS Date), N'ABCD960222MOCLMR01', CAST(0.00 AS Decimal(9, 2)), 12, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (7, N'GABRIEL', N'SANTIAGO', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1996-04-12' AS Date), N'ABCD960412HOCLMR01', CAST(0.00 AS Decimal(9, 2)), 19, 6)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (8, N'LUIS', N'MATUS', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1996-07-03' AS Date), N'ABCD960703HOCLMR01', CAST(24000.00 AS Decimal(9, 2)), 19, 6)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (9, N'EDITH', N'RASGADO', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1994-04-30' AS Date), N'ABCD940430MOCLMR01', CAST(30000.00 AS Decimal(9, 2)), 19, 5)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (10, N'JIOVANY', N'LOPEZ', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1994-06-14' AS Date), N'ABCD940614HOCLMR01', CAST(22000.00 AS Decimal(9, 2)), 19, 5)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (11, N'PEDRO', N'PEREZ', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1993-11-07' AS Date), N'ABCD931107HOCLMR01', CAST(0.00 AS Decimal(9, 2)), 3, 1)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (12, N'REYNA', N'LOPEZ', NULL, N'email@4ce.com.mx', N'5555555555', CAST(N'1992-11-26' AS Date), N'ABCD921126MOCLMR01', CAST(0.00 AS Decimal(9, 2)), 10, 1)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (13, N'Marcelo Isai a', N'García', N'Mirón', N'marcelo@outlook.com', N'9911362600', CAST(N'1997-12-12' AS Date), N'MADA971212HVZRMN04', CAST(22000.00 AS Decimal(9, 2)), 29, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (14, N'Oliver Alexis', N'Martínez', N'Estudillo', N'alexis@gmail.com', N'8897877417', CAST(N'1996-04-18' AS Date), N'DIAE960418HOCSVL07', CAST(20000.00 AS Decimal(9, 2)), 19, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (15, N'Oscar', N'Mendoza', N'García', N'omscar@outlook.es', N'7711589568', CAST(N'1994-04-07' AS Date), N'RUVJ940407HOCSSN03', CAST(0.00 AS Decimal(9, 2)), 29, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (16, N'Edgar', N'Martínez', N'Espinoza', N'edgargmail.com', N'5528356144', CAST(N'1996-05-23' AS Date), N'DOML960323HMNMTS00', CAST(25000.00 AS Decimal(9, 2)), 12, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (17, N'Rodrigo', N'Tolentino', N'Martínez', N'rodrigo@gmail.com', N'4421436224', CAST(N'1998-03-13' AS Date), N'TOMR980313HHGLRD06', CAST(0.00 AS Decimal(9, 2)), 13, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (18, N'Jesiel', N'García', N'Pérez', N'jesiel@gmail.com', N'3317901341', CAST(N'1990-11-08' AS Date), N'GAPJ901108HHGRRS00', CAST(0.00 AS Decimal(9, 2)), 13, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (19, N'Christian Josue ', N'Gonzalez', N'Lozano', N'christian@gmail.com', N'4922153353', CAST(N'1996-06-19' AS Date), N'GOLC960619HZSNZH08', CAST(0.00 AS Decimal(9, 2)), 31, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (20, N'Luis Enrique', N'Lopez ', N'Cruz', N'luis@gmail.com', N'2235700644', CAST(N'1997-07-15' AS Date), N'LOCL970715HGTPRS04', CAST(0.00 AS Decimal(9, 2)), 16, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (21, N'Rolando', N'Marquez', N'Hernandez', N'rolando@gmail.com', N'1168329969', CAST(N'1997-03-08' AS Date), N'MAHR97030815HRL600', CAST(0.00 AS Decimal(9, 2)), 15, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (22, N'Jesús Yotecatl', N'Miranda', N'Espinosa', N'jesus@gmail.com', N'2213335247', CAST(N'1997-06-14' AS Date), N'MIEJ970614HMCRSS05', CAST(0.00 AS Decimal(9, 2)), 15, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (23, N'Cecilia', N'Cruz', N'Luna', N'cecilia@outlook.com', N'3317052376', CAST(N'1997-08-08' AS Date), N'CULC970808MPLRNC02', CAST(22000.00 AS Decimal(9, 2)), 21, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (24, N'Baldomero', N'Gómez', N'García', N'baldomero@gmail.com', N'4419055010', CAST(N'2000-11-08' AS Date), N'GOGB001108HPLMRLA2', CAST(23000.00 AS Decimal(9, 2)), 21, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (25, N'Rubén', N'Rojas', N'Mantilla', N'ruben@outlook.com', N'5594228277', CAST(N'1997-01-17' AS Date), N'ROMR910117HVZJNB00', CAST(21000.00 AS Decimal(9, 2)), 30, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (26, N'Ana Patricia', N'Apatiga ', N'Olguín', N'patricia@gmail.com', N'6614913002', CAST(N'1998-06-23' AS Date), N'AAOA980623MHGPLN03', CAST(22000.00 AS Decimal(9, 2)), 13, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (27, N'Bryan Adiel ', N'Arroyo ', N'Tavera', N'brayan@gmail.com', N'7719034047', CAST(N'1998-04-02' AS Date), N'AOTB980402HHGRVR05', CAST(20000.00 AS Decimal(9, 2)), 13, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (28, N'Carlos Arath', N'Serrano', N'Berna', N'carlos@gmail.com', N'8878893014', CAST(N'2000-03-05' AS Date), N'SEBC000305HQTRRRA5', CAST(250000.00 AS Decimal(9, 2)), 22, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (29, N'Edith', N'Rasgado', N'Sarabia', N'edith@gmail.com', N'9911777500', CAST(N'1994-04-29' AS Date), N'RASE940429MOCSRD00', CAST(20000.00 AS Decimal(9, 2)), 20, 3)
INSERT [dbo].[alumnos] ([id_alumno], [nombre_alumno], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [curp], [sueldo], [id_estado], [id_estatus]) VALUES (30, N'Víctor', N'Marín', N'Pérez', N'victor@gmail.com', N'2215066253', CAST(N'1998-06-04' AS Date), N'MAPV980604HDFRRC01', CAST(21000.00 AS Decimal(9, 2)), 15, 3)
SET IDENTITY_INSERT [dbo].[alumnos] OFF
GO
SET IDENTITY_INSERT [dbo].[alumnosBaja] ON 

INSERT [dbo].[alumnosBaja] ([idAlumnos_Baja], [nombreAlumno], [primerApellido], [segundoApellido], [fechaBaja]) VALUES (1, N'JORGE', N'ALONSO', N'Jimenenez', CAST(N'2022-01-15T20:51:45.563' AS DateTime))
SET IDENTITY_INSERT [dbo].[alumnosBaja] OFF
GO
SET IDENTITY_INSERT [dbo].[cat_cursos] ON 

INSERT [dbo].[cat_cursos] ([id_catCurso], [clave_catCurso], [nombre_catCurso], [desc_catCurso], [horas], [idPrerequisito], [activo]) VALUES (1, N'SQL', N'Bases de datos SQL Server', N'Curso de SQL Server (conceptos basicos, DDL, DML) y manipulacion de datos', 50, NULL, 1)
INSERT [dbo].[cat_cursos] ([id_catCurso], [clave_catCurso], [nombre_catCurso], [desc_catCurso], [horas], [idPrerequisito], [activo]) VALUES (2, N'Asp .NET y C#', N'Introduccion a Asp .NET y C#', N'Curso de introduccion a los lenguajes Asp .NET y C#', 50, 1, 0)
INSERT [dbo].[cat_cursos] ([id_catCurso], [clave_catCurso], [nombre_catCurso], [desc_catCurso], [horas], [idPrerequisito], [activo]) VALUES (5, N'Asp .NET y C# 2', N'Asp .NET y C#', N'Curso de reforzamiento a los lenguajes Asp .NET y C#', 50, 2, 0)
INSERT [dbo].[cat_cursos] ([id_catCurso], [clave_catCurso], [nombre_catCurso], [desc_catCurso], [horas], [idPrerequisito], [activo]) VALUES (8, N'Asp .NET -MVC', N'Tecnologia MVC', N'Curso Tecnologia Asp .NET -MVC', 50, 5, 0)
SET IDENTITY_INSERT [dbo].[cat_cursos] OFF
GO
SET IDENTITY_INSERT [dbo].[cursoAlumnos] ON 

INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (2, 1, 2, CAST(N'2021-01-04' AS Date), NULL, 9)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (3, 1, 3, CAST(N'2021-01-06' AS Date), NULL, 7)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (4, 1, 4, CAST(N'2021-01-01' AS Date), NULL, 10)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (5, 1, 5, CAST(N'2021-01-08' AS Date), NULL, 2)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (6, 2, 6, CAST(N'2021-02-01' AS Date), NULL, 6)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (7, 2, 7, CAST(N'2021-02-03' AS Date), NULL, 8)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (8, 2, 8, CAST(N'2021-02-02' AS Date), NULL, 10)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (9, 2, 9, CAST(N'2021-02-07' AS Date), NULL, 4)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (10, 3, 10, CAST(N'2021-02-10' AS Date), NULL, 6)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (11, 3, 11, CAST(N'2021-02-12' AS Date), NULL, 8)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (12, 3, 12, CAST(N'2021-02-11' AS Date), NULL, 8)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (13, 3, 13, CAST(N'2021-02-14' AS Date), NULL, 6)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (14, 3, 14, CAST(N'2021-02-18' AS Date), NULL, 9)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (15, 4, 15, CAST(N'2021-03-01' AS Date), NULL, 10)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (16, 4, 16, CAST(N'2021-03-04' AS Date), NULL, 7)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (17, 4, 17, CAST(N'2021-03-03' AS Date), NULL, 7)
INSERT [dbo].[cursoAlumnos] ([idCurso_alumno], [id_curso], [id_alumno], [fechaInscripcion], [fechaBaja], [calificacion]) VALUES (18, 4, 18, CAST(N'2021-03-05' AS Date), NULL, 5)
SET IDENTITY_INSERT [dbo].[cursoAlumnos] OFF
GO
SET IDENTITY_INSERT [dbo].[cursoInstructores] ON 

INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (1, 1, 1, CAST(N'2015-05-11' AS Date))
INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (2, 2, 1, CAST(N'2015-05-10' AS Date))
INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (3, 3, 2, CAST(N'2017-03-20' AS Date))
INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (4, 4, 2, CAST(N'2017-03-20' AS Date))
INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (5, 1, 3, CAST(N'2018-08-27' AS Date))
INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (6, 2, 3, CAST(N'2018-08-27' AS Date))
INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (7, 3, 4, CAST(N'2020-01-07' AS Date))
INSERT [dbo].[cursoInstructores] ([idCurso_instructor], [id_curso], [id_instructor], [fechaContratacion]) VALUES (8, 4, 4, CAST(N'2020-01-07' AS Date))
SET IDENTITY_INSERT [dbo].[cursoInstructores] OFF
GO
SET IDENTITY_INSERT [dbo].[cursos] ON 

INSERT [dbo].[cursos] ([id_curso], [id_catCurso], [fechaInicio], [fechaTermino], [activo]) VALUES (1, 1, CAST(N'2021-01-10' AS Date), CAST(N'2021-01-28' AS Date), 1)
INSERT [dbo].[cursos] ([id_curso], [id_catCurso], [fechaInicio], [fechaTermino], [activo]) VALUES (2, 2, CAST(N'2021-02-08' AS Date), CAST(N'2021-02-17' AS Date), 1)
INSERT [dbo].[cursos] ([id_curso], [id_catCurso], [fechaInicio], [fechaTermino], [activo]) VALUES (3, 5, CAST(N'2021-02-22' AS Date), CAST(N'2021-03-12' AS Date), 1)
INSERT [dbo].[cursos] ([id_curso], [id_catCurso], [fechaInicio], [fechaTermino], [activo]) VALUES (4, 8, CAST(N'2021-03-15' AS Date), CAST(N'2021-03-24' AS Date), 1)
INSERT [dbo].[cursos] ([id_curso], [id_catCurso], [fechaInicio], [fechaTermino], [activo]) VALUES (5, 2, CAST(N'2021-03-29' AS Date), CAST(N'2021-04-07' AS Date), 1)
INSERT [dbo].[cursos] ([id_curso], [id_catCurso], [fechaInicio], [fechaTermino], [activo]) VALUES (6, 1, CAST(N'2021-04-12' AS Date), CAST(N'2021-04-30' AS Date), 1)
SET IDENTITY_INSERT [dbo].[cursos] OFF
GO
SET IDENTITY_INSERT [dbo].[estados] ON 

INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (1, N'Aguascalientes')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (2, N'Baja California')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (3, N'Baja California Sur')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (4, N'Campeche')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (5, N'Chihuahua')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (6, N'Chiapas')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (7, N'Coahuila')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (8, N'Colima')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (9, N'Durango')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (10, N'Guanajuato')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (11, N'Guerrero')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (12, N'Hid_estadoalgo')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (13, N'Jalisco')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (14, N'México')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (15, N'Michoacán')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (16, N'Morelos')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (17, N'Nayarit')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (18, N'Nuevo León')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (19, N'Oaxaca')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (20, N'Puebla')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (21, N'Querétaro')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (22, N'Quintana Roo')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (23, N'San Luis Potosí')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (24, N'Sinaloa')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (25, N'Sonora')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (26, N'Tabasco')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (27, N'Tamaulipas')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (28, N'Tlaxcala')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (29, N'Veracruz')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (30, N'Yucatán')
INSERT [dbo].[estados] ([id_estado], [nombre_estado]) VALUES (31, N'Zacatecas')
SET IDENTITY_INSERT [dbo].[estados] OFF
GO
SET IDENTITY_INSERT [dbo].[estatus_alumnos] ON 

INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (1, N'PTO       ', N'Prospecto')
INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (2, N'PRO       ', N'En curso propedéutico')
INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (3, N'CAP       ', N'En capacitación')
INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (4, N'INC       ', N'En Incursión')
INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (5, N'LAB       ', N'Laborando')
INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (6, N'LIB       ', N'Liberado')
INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (7, N'NI        ', N'No le interesó')
INSERT [dbo].[estatus_alumnos] ([id_estatus], [clave], [nombre]) VALUES (8, N'BA        ', N'Baja')
SET IDENTITY_INSERT [dbo].[estatus_alumnos] OFF
GO
SET IDENTITY_INSERT [dbo].[instructores] ON 

INSERT [dbo].[instructores] ([id_instructor], [nombre_instructor], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [rfc], [curp], [cuotaHora], [activo]) VALUES (1, N'Oscar', N'López', N'Osorio', N'olopez@ti-capitalhumano.com', N'7226181450', CAST(N'1984-08-03' AS Date), N'LOOO840803S08', N'LOOO840803HMCPSS08', CAST(110.00 AS Decimal(9, 2)), 1)
INSERT [dbo].[instructores] ([id_instructor], [nombre_instructor], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [rfc], [curp], [cuotaHora], [activo]) VALUES (2, N'Jorge', N'Valdivia', N'Rosas', N'jvaldivia@ti-capitalhumano.com', N'5561040510', CAST(N'1964-01-26' AS Date), N'VARJ640126R00', N'VARJ640126HDFLSR00', CAST(110.00 AS Decimal(9, 2)), 1)
INSERT [dbo].[instructores] ([id_instructor], [nombre_instructor], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [rfc], [curp], [cuotaHora], [activo]) VALUES (3, N'Luis', N'Vázquez', N'Cuj', N'luisvazquez@ti-capitalhumano.com', N'5540612941', CAST(N'1974-10-11' AS Date), N'VACL741011JS5', N'VACL741011HTCZJS05', CAST(80.00 AS Decimal(9, 2)), 1)
INSERT [dbo].[instructores] ([id_instructor], [nombre_instructor], [primerApellido], [segundoApellido], [correo], [telefono], [fechaNacimiento], [rfc], [curp], [cuotaHora], [activo]) VALUES (4, N'José', N'Morales', N'Narváez', N'jose.morales@ti-capitalhumano.com', N'5511506288', CAST(N'1984-12-31' AS Date), N'MONM941231N07', N'MONM941231HCCRRN07', CAST(77.00 AS Decimal(9, 2)), 1)
SET IDENTITY_INSERT [dbo].[instructores] OFF
GO
SET IDENTITY_INSERT [dbo].[saldos] ON 

INSERT [dbo].[saldos] ([id], [Nombre], [saldo]) VALUES (1, N'Jorge Alonso', CAST(10000.50 AS Decimal(9, 2)))
INSERT [dbo].[saldos] ([id], [Nombre], [saldo]) VALUES (2, N'Gerardo Suarez Vazquez', CAST(265000.75 AS Decimal(9, 2)))
SET IDENTITY_INSERT [dbo].[saldos] OFF
GO
SET IDENTITY_INSERT [dbo].[TablaISR] ON 

INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (1, CAST(0.01 AS Decimal(19, 2)), CAST(285.45 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)), CAST(1.92 AS Decimal(19, 2)), CAST(200.85 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (2, CAST(285.46 AS Decimal(19, 2)), CAST(872.85 AS Decimal(19, 2)), CAST(5.55 AS Decimal(19, 2)), CAST(6.40 AS Decimal(19, 2)), CAST(200.85 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (3, CAST(872.86 AS Decimal(19, 2)), CAST(1309.20 AS Decimal(19, 2)), CAST(5.55 AS Decimal(19, 2)), CAST(6.40 AS Decimal(19, 2)), CAST(200.70 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (4, CAST(1309.21 AS Decimal(19, 2)), CAST(1713.60 AS Decimal(19, 2)), CAST(5.55 AS Decimal(19, 2)), CAST(6.40 AS Decimal(19, 2)), CAST(200.70 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (5, CAST(1713.61 AS Decimal(19, 2)), CAST(1745.70 AS Decimal(19, 2)), CAST(5.55 AS Decimal(19, 2)), CAST(6.40 AS Decimal(19, 2)), CAST(193.80 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (6, CAST(1745.71 AS Decimal(19, 2)), CAST(2193.75 AS Decimal(19, 2)), CAST(5.55 AS Decimal(19, 2)), CAST(6.40 AS Decimal(19, 2)), CAST(188.70 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (7, CAST(2193.76 AS Decimal(19, 2)), CAST(2327.55 AS Decimal(19, 2)), CAST(5.55 AS Decimal(19, 2)), CAST(6.40 AS Decimal(19, 2)), CAST(174.75 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (8, CAST(2327.56 AS Decimal(19, 2)), CAST(2422.80 AS Decimal(19, 2)), CAST(5.55 AS Decimal(19, 2)), CAST(6.40 AS Decimal(19, 2)), CAST(160.35 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (9, CAST(2422.81 AS Decimal(19, 2)), CAST(2632.65 AS Decimal(19, 2)), CAST(142.20 AS Decimal(19, 2)), CAST(10.88 AS Decimal(19, 2)), CAST(160.35 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (10, CAST(2632.66 AS Decimal(19, 2)), CAST(3071.40 AS Decimal(19, 2)), CAST(142.20 AS Decimal(19, 2)), CAST(10.88 AS Decimal(19, 2)), CAST(145.35 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (11, CAST(3071.41 AS Decimal(19, 2)), CAST(3510.15 AS Decimal(19, 2)), CAST(142.20 AS Decimal(19, 2)), CAST(10.88 AS Decimal(19, 2)), CAST(125.10 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (12, CAST(3510.16 AS Decimal(19, 2)), CAST(3642.60 AS Decimal(19, 2)), CAST(142.20 AS Decimal(19, 2)), CAST(10.88 AS Decimal(19, 2)), CAST(107.40 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (13, CAST(3642.61 AS Decimal(19, 2)), CAST(4257.90 AS Decimal(19, 2)), CAST(142.20 AS Decimal(19, 2)), CAST(10.88 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (14, CAST(4257.91 AS Decimal(19, 2)), CAST(4949.55 AS Decimal(19, 2)), CAST(341.85 AS Decimal(19, 2)), CAST(16.00 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (15, CAST(4949.56 AS Decimal(19, 2)), CAST(5925.90 AS Decimal(19, 2)), CAST(452.55 AS Decimal(19, 2)), CAST(17.92 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (16, CAST(5925.91 AS Decimal(19, 2)), CAST(11951.85 AS Decimal(19, 2)), CAST(627.60 AS Decimal(19, 2)), CAST(21.36 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (17, CAST(11951.86 AS Decimal(19, 2)), CAST(18837.75 AS Decimal(19, 2)), CAST(1914.75 AS Decimal(19, 2)), CAST(23.52 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (18, CAST(18837.76 AS Decimal(19, 2)), CAST(35964.30 AS Decimal(19, 2)), CAST(3534.30 AS Decimal(19, 2)), CAST(30.00 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (19, CAST(35964.31 AS Decimal(19, 2)), CAST(47952.30 AS Decimal(19, 2)), CAST(8672.25 AS Decimal(19, 2)), CAST(32.00 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (20, CAST(47952.31 AS Decimal(19, 2)), CAST(143856.90 AS Decimal(19, 2)), CAST(12508.35 AS Decimal(19, 2)), CAST(34.00 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
INSERT [dbo].[TablaISR] ([id], [LimInf], [LimSup], [CuotaFija], [ExedLimInf], [Subsidio]) VALUES (21, CAST(143856.91 AS Decimal(19, 2)), CAST(99999999.00 AS Decimal(19, 2)), CAST(45115.95 AS Decimal(19, 2)), CAST(35.00 AS Decimal(19, 2)), CAST(0.00 AS Decimal(19, 2)))
SET IDENTITY_INSERT [dbo].[TablaISR] OFF
GO
SET IDENTITY_INSERT [dbo].[Transacciones] ON 

INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (1, 1, 2, CAST(15000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (2, 1, 2, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (3, 1, 2, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (4, 2, 1, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (5, 2, 1, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (6, 2, 1, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (7, 2, 1, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (8, 2, 1, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (9, 1, 2, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (10, 1, 2, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (11, 1, 2, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (12, 1, 2, CAST(35000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (13, 1, 2, CAST(50000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (14, 2, 1, CAST(90000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (15, 2, 1, CAST(90000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (16, 1, 2, CAST(90000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (17, 1, 2, CAST(90000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (18, 1, 2, CAST(90000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (19, 1, 2, CAST(90000.00 AS Decimal(9, 2)))
INSERT [dbo].[Transacciones] ([id], [idOrigen], [idDestino], [monto]) VALUES (20, 1, 2, CAST(90000.00 AS Decimal(9, 2)))
SET IDENTITY_INSERT [dbo].[Transacciones] OFF
GO
ALTER TABLE [dbo].[alumnos]  WITH CHECK ADD  CONSTRAINT [FK_alumnosEstado] FOREIGN KEY([id_estado])
REFERENCES [dbo].[estados] ([id_estado])
GO
ALTER TABLE [dbo].[alumnos] CHECK CONSTRAINT [FK_alumnosEstado]
GO
ALTER TABLE [dbo].[alumnos]  WITH CHECK ADD  CONSTRAINT [FK_alumnosEstatus] FOREIGN KEY([id_estatus])
REFERENCES [dbo].[estatus_alumnos] ([id_estatus])
GO
ALTER TABLE [dbo].[alumnos] CHECK CONSTRAINT [FK_alumnosEstatus]
GO
ALTER TABLE [dbo].[cat_cursos]  WITH CHECK ADD  CONSTRAINT [FK_catCursos] FOREIGN KEY([idPrerequisito])
REFERENCES [dbo].[cat_cursos] ([id_catCurso])
GO
ALTER TABLE [dbo].[cat_cursos] CHECK CONSTRAINT [FK_catCursos]
GO
ALTER TABLE [dbo].[cursoAlumnos]  WITH CHECK ADD  CONSTRAINT [FK_alumno_CursoAlumno] FOREIGN KEY([id_alumno])
REFERENCES [dbo].[alumnos] ([id_alumno])
GO
ALTER TABLE [dbo].[cursoAlumnos] CHECK CONSTRAINT [FK_alumno_CursoAlumno]
GO
ALTER TABLE [dbo].[cursoAlumnos]  WITH CHECK ADD  CONSTRAINT [FK_curso_CursoAlumno] FOREIGN KEY([id_curso])
REFERENCES [dbo].[cursos] ([id_curso])
GO
ALTER TABLE [dbo].[cursoAlumnos] CHECK CONSTRAINT [FK_curso_CursoAlumno]
GO
ALTER TABLE [dbo].[cursoInstructores]  WITH CHECK ADD  CONSTRAINT [FK_curso_CursoInstructor] FOREIGN KEY([id_curso])
REFERENCES [dbo].[cursos] ([id_curso])
GO
ALTER TABLE [dbo].[cursoInstructores] CHECK CONSTRAINT [FK_curso_CursoInstructor]
GO
ALTER TABLE [dbo].[cursoInstructores]  WITH CHECK ADD  CONSTRAINT [FK_inst_CursoInstructor] FOREIGN KEY([id_instructor])
REFERENCES [dbo].[instructores] ([id_instructor])
GO
ALTER TABLE [dbo].[cursoInstructores] CHECK CONSTRAINT [FK_inst_CursoInstructor]
GO
ALTER TABLE [dbo].[cursos]  WITH CHECK ADD  CONSTRAINT [FK_curso_catCurso] FOREIGN KEY([id_catCurso])
REFERENCES [dbo].[cat_cursos] ([id_catCurso])
GO
ALTER TABLE [dbo].[cursos] CHECK CONSTRAINT [FK_curso_catCurso]
GO
ALTER TABLE [dbo].[Transacciones]  WITH CHECK ADD FOREIGN KEY([idDestino])
REFERENCES [dbo].[saldos] ([id])
GO
ALTER TABLE [dbo].[Transacciones]  WITH CHECK ADD FOREIGN KEY([idOrigen])
REFERENCES [dbo].[saldos] ([id])
GO
/****** Object:  StoredProcedure [dbo].[actualizarAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[actualizarAlumnos] 
@idAlumno INT,
@NOMBRE VARCHAR (60),
@primerApellido VARCHAR (50),
@segundoApellido VARCHAR (50),
@correo VARCHAR (80),
@telefono NCHAR(10),
@fechaNacimiento DATE,
@curp char(18),
@sueldo DECIMAL(9,2),
@id_estado INT,
@id_estatus INT
AS
BEGIN
	UPDATE alumnos
	SET nombre_alumno =@NOMBRE,
		primerApellido = @primerApellido,
		segundoApellido =@segundoApellido,
		correo = @correo,
		telefono = @telefono,
		fechaNacimiento = @fechaNacimiento,
		curp = @curp,
		sueldo = @sueldo,
		id_estado = @id_estado,
		id_estatus = @id_estatus
	WHERE id_alumno = @idAlumno;

	SELECT @@ROWCOUNT  

	IF @@ROWCOUNT = 0
		PRINT 'No se actualizo ningun registro'
END
GO
/****** Object:  StoredProcedure [dbo].[actualizarEstatusAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[actualizarEstatusAlumnos] @idAlumno INT,
@idEstatusNuevo INT
AS
BEGIN
	UPDATE alumnos
	SET id_estatus = @idEstatusNuevo
	WHERE id_alumno  = @idAlumno
END;
GO
/****** Object:  StoredProcedure [dbo].[agregarAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[agregarAlumnos]
@NOMBRE VARCHAR (60),
@primerApellido VARCHAR (50),
@segundoApellido VARCHAR (50),
@correo VARCHAR (80),
@telefono NCHAR(10),
@fechaNacimiento DATE,
@curp char(18),
@sueldo DECIMAL(9,2),
@id_estado INT,
@id_estatus INT

AS
BEGIN
	INSERT INTO alumnos (nombre_alumno,
						 primerApellido,
						 segundoApellido,
						 correo,
						 telefono,
						 fechaNacimiento,
						 curp,
						 sueldo,
						 id_estado,
						 id_estatus)
				VALUES (@NOMBRE,
						@primerApellido,
						@segundoApellido,
						@correo,
						@telefono,
						@fechaNacimiento,
						@curp,
						@sueldo,
						@id_estado,
						@id_estatus);

	SELECT MAX(id_alumno)
	FROM alumnos;
END
GO
/****** Object:  StoredProcedure [dbo].[consultarAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[consultarAlumnos] @idAlumno INT 
AS
BEGIN
	IF @idAlumno = -1
		SELECT a.id_alumno id,
			   a.nombre_alumno nombre,
			   a.primerApellido primerApellido,
			   a.segundoApellido segundoApelllido,
			   a.correo correo,
			   a.fechaNacimiento fechaNaci,
			   a.telefono telefono,
			   a.curp curp,
			   e.nombre_estado Estado,
			   ea.nombre Estatus
		FROM alumnos a,
			 estados e,
			 estatus_alumnos ea
	   WHERE 1 = 1
	   AND a.id_estado = e.id_estado
	   AND a.id_estatus = ea.id_estatus
	ELSE IF @idAlumno >= 1
		SELECT a.id_alumno id,
			   a.nombre_alumno nombre,
			   a.primerApellido primerApellido,
			   a.segundoApellido segundoApelllido,
			   a.correo correo,
			   a.fechaNacimiento fechaNaci,
			   a.telefono telefono,
			   a.curp curp,
			   e.nombre_estado Estado,
			   ea.nombre Estatus
		FROM alumnos a,
			 estados e,
			 estatus_alumnos ea
		WHERE 1 = 1
		AND a.id_estado = e.id_estado
	    AND a.id_estatus = ea.id_estatus
END
GO
/****** Object:  StoredProcedure [dbo].[consultarEAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[consultarEAlumnos] @idAlumno INT 
AS
BEGIN
	IF @idAlumno = -1
		SELECT a.id_alumno id,
			   a.nombre_alumno nombre,
			   a.primerApellido primerApellido,
			   a.segundoApellido segundoApelllido,
			   a.fechaNacimiento fechaNaci,
			   a.correo correo,
			   a.telefono telefono,
			   a.curp curp,
			   a.id_estado idEstadoOrigen,
			   a.id_estatus idEstatus
		FROM alumnos a
	ELSE IF @idAlumno >= 1
		SELECT a.id_alumno id,
			   a.nombre_alumno nombre,
			   a.primerApellido primerApellido,
			   a.segundoApellido segundoApelllido,
			   a.fechaNacimiento fechaNaci,
			   a.correo correo,
			   a.telefono telefono,
			   a.curp curp,
			   a.id_estado idEstadoOrigen,
			   a.id_estatus idEstatus
		FROM alumnos a
		WHERE id_alumno = @idAlumno
END
GO
/****** Object:  StoredProcedure [dbo].[consultarEstados]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[consultarEstados] @idEstado INT 
AS
BEGIN
	IF @idEstado = -1
		SELECT *
		FROM estados;
	ELSE IF @idEstado >= 1
		SELECT * 
		FROM estados
		WHERE id_estado = @idEstado
END
GO
/****** Object:  StoredProcedure [dbo].[consultarEstatusAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[consultarEstatusAlumnos] @idEstatus INT 
AS
BEGIN
	IF @idEstatus = -1
		SELECT *
		FROM estatus_alumnos
	ELSE IF @idEstatus >= 1
		SELECT * 
		FROM estatus_alumnos
		WHERE id_estatus = @idEstatus
END
GO
/****** Object:  StoredProcedure [dbo].[eliminarAlumnos]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[eliminarAlumnos] @idAlumno INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE FROM cursoAlumnos WHERE id_alumno = @idAlumno;

			DELETE FROM alumnos WHERE id_alumno = @idAlumno;
		COMMIT TRANSACTION
		PRINT 'La Transaccion fue Exitosa';
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		PRINT 'La Transaccion No se puedo realizar';
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[FactorialNum]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FactorialNum] @num INT, 
@Factor INT OUT
AS

BEGIN
	DECLARE @i INT = 1;
	SET @Factor = 1
	WHILE @i <= @num
	BEGIN
		IF @num <= 1
			PRINT @Factor;
		ELSE
			SET @Factor = @Factor * @i;
			SET @i +=1;
	END;
	PRINT @Factor;
END;
GO
/****** Object:  StoredProcedure [dbo].[procedureCodigoAscii]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procedureCodigoAscii] 
AS
BEGIN
	DECLARE @i INT,
			@PrintMessage NVARCHAR(50),
			@ASCI CHAR(2),
			@CARACTER int;
	SET @i = 32;
	
	WHILE @i <=255
	BEGIN
		SET @ASCI = CHAR(@i);
		SET @CARACTER = ASCII(@ASCI);
		SET @PrintMessage = @ASCI + 
							N'  ' + 
							N'ASCII => ' + 
							N'  ';
		PRINT @PrintMessage + CAST(@CARACTER AS nvarchar(10));
		SET @i = @i + 1;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[Transactions]    Script Date: 16/01/2022 12:34:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Transactions] @idOrigen INT,
@idDestino INT,
@Monto DECIMAL(9,2)
AS
BEGIN
	----DECLARE @montoEnviar DECIMAL(9,2) = (SELECT s.saldo
	----									FROM saldos s
	----									WHERE id = @idOrigen);
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE @montoEnviar DECIMAL(9,2) = (SELECT s.saldo
									FROM saldos s
										WHERE id = @idOrigen);
			IF @montoEnviar >= @Monto
				UPDATE saldos
				SET saldo = saldo - @Monto
				WHERE id = @idOrigen;

				UPDATE saldos
				SET saldo = saldo + @Monto
				WHERE id = @idDestino;

				INSERT Transacciones
					SELECT @idOrigen, 
						   @idDestino,
					      @Monto;
 
		 
		COMMIT TRANSACTION;
		PRINT 'La Transaccion fue Exitosa';
		END TRY
		BEGIN CATCH
		ROLLBACK TRANSACTION
			SELECT ERROR_MESSAGE() AS ErrorMessage;
			PRINT 'La Transaccion No se puedo realizar';
		END CATCH
END;
GO
USE [master]
GO
ALTER DATABASE [instituto_tich] SET  READ_WRITE 
GO
