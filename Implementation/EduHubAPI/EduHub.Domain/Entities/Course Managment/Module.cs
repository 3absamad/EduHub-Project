using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Course_Managment
{
    public class Module
    {
        public int ModuleId { get; set; }
        public int CourseId { get; set; }
        public string Title { get; set; } = string.Empty;
        public int OrderIndex { get; set; }

        public Course Course { get; set; } = null!;
        public ICollection<Lesson> Lessons { get; set; }  = new List<Lesson>();
    }
}
