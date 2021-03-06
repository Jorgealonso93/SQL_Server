USE [master]
GO
/****** Object:  Database [instituto_tich]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[alumnos]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[alumnosBaja]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[cat_cursos]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[cursoAlumnos]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[cursoInstructores]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[cursos]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[estados]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[estatus_alumnos]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[instructores]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
/****** Object:  Table [dbo].[TablaISR]    Script Date: 12/01/2022 07:12:52 p. m. ******/
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
USE [master]
GO
ALTER DATABASE [instituto_tich] SET  READ_WRITE 
GO
