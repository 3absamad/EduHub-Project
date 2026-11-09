using EduHub.Domain.Entities.Assessments;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Course_Managment
{
    public class Lesson
    {
        public int LessonId { get; set; }
        public int ModuleId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public int DurationInMinutes { get; set; }
        public int OrderIndex { get; set; }

        public Module Module { get; set; } = null!;
        public ICollection<Material> Materials { get; set; } = new List<Material>();
        public ICollection<Quiz> Quizzes { get; set; } = new List<Quiz>();
    }
}
