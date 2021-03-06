USE [PruebasTich]
GO
/****** Object:  StoredProcedure [dbo].[spEliminaAlumnosCurso]    Script Date: 16/01/2022 12:40:37 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEliminaAlumnosCurso] @nombreCurso VARCHAR (50)
AS
BEGIN
	/*DELETE FROM cursoAlumnos
	WHERE id_curso IN (SELECT c.id_curso
					  FROM cursos c,
							cat_cursos cat
					   WHERE cat.id_catCurso = c.id_catCurso
					   AND cat.nombre_catCurso = 'Bases de datos SQL Server');*/

	DELETE FROM alumnos
	WHERE id_alumno IN (SELECT a.id_alumno
						FROM alumnos a,
							cursoAlumnos ca,
							cursos c,
							cat_cursos cat
						WHERE 1 =1
						AND cat.id_catCurso = c.id_catCurso
						AND c.id_curso = ca.id_curso
						AND ca.id_alumno = a.id_alumno
						AND cat.nombre_catCurso = @nombreCurso)
END;
GO
