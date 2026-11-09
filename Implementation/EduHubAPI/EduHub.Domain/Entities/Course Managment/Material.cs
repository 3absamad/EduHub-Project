using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Course_Managment
{
    public class Material
    {
        public int MaterialId { get; set; }
        public int LessonId { get; set; }
        public string FileUrl { get; set; } = string.Empty;
        public string MaterialType { get; set; } = string.Empty;
        public int FileSizeMB { get; set; }

        public Lesson Lesson { get; set; } = null!;

    }
}
