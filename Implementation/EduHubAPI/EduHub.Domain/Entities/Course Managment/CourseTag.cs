using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Course_Managment
{
    public class CourseTag
    {
        public int TagId { get; set; }
        public int CourseId { get; set; }
        public string TagName { get; set; } = string.Empty;

        public Course Course { get; set; } = null!;
    }
}
